//
//  NSEntityDescription+KVCFetching.m
//  CapitaineTrain
//
//  Created by Nicolas Bouilleaud - Capitaine Train on 20/09/12.
//  Copyright (c) 2012 Capitaine Train. All rights reserved.
//

#import "NSEntityDescription+KVCFetching.h"
#import "KVCEntitiesCache.h"
#import "NSAttributeDescription+Coercion.h"
#import "NSObject+KVCMapping.h"
#import "KVCMappingOptions.h"

@implementation NSEntityDescription (KVCFetching)

// Find info about key in entity
- (id) kvc_fetchObjectInContext:(NSManagedObjectContext*)moc withValue:(id)value forKey:(NSString*)key options:(NSDictionary*)options
{
    NSAttributeDescription * attributeDesc = [self attributesByName][key];
    if(nil==attributeDesc) {
        return nil;
    }

#if DEBUG
    if(!attributeDesc.isIndexed) {
        NSLog(@"%@: fetching a \"%@\" on key %@, which is not indexed.", NSStringFromSelector(_cmd), [self name], key);
    }
#endif

    // convert data if necessary
    id correctValue = [attributeDesc kvc_coerceValue:value];
    
    // Bail out if we could not coerce the value
    // (this also prevents the creation of empty objects)
    if(!correctValue)
        return nil;
    
    // Search object, in cache if possible
    NSManagedObject * obj;
    KVCEntitiesCache * entitiesCache = options[KVCEntitiesCacheOption];
    KVCInstancesCache * instancesCache = entitiesCache[self.name];
    // Use cache if available
    // If we have an entitiesCache but no instances Cache for this specific entity,
    // fallback to regular fetch.
    if(entitiesCache && instancesCache!=nil) {
        obj = instancesCache[correctValue];
    } else {
        // Regular fetch
        NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:[self name]];
        request.fetchLimit = 1;
        request.returnsObjectsAsFaults = NO;
        
        // Using a NSComparisonPredicate here is 2-3 times faster than using predicateWithFormat
        request.predicate = [NSComparisonPredicate predicateWithLeftExpression:[NSExpression expressionForKeyPath:key]
                                                               rightExpression:[NSExpression expressionForConstantValue:correctValue]
                                                                      modifier:NSDirectPredicateModifier
                                                                          type:NSEqualToPredicateOperatorType
                                                                       options:0];
        
        NSError * error=nil;
        NSArray *result = [moc executeFetchRequest:request error:&error];
        NSAssert(result!=nil, @"Fetch Request %@ failed %@",request, error);
        obj = [result lastObject];
    }
    
    // Not found : create object, if asked.
    BOOL createObject = [options[KVCCreateObjectOption] boolValue];
    if(nil==obj && createObject)
    {
        obj = [self.class insertNewObjectForEntityForName:[self name] inManagedObjectContext:moc];
        [obj setValue:correctValue forKey:key];

        instancesCache[correctValue] = obj;
    }
    return obj;
}

@end

#pragma mark - 

@implementation NSManagedObject (KVCFetching)

// Finds the entity in the passed context's model whose object class is the receiver, or a superclass of the receiver.
// Obviously, it's to be called in subclasses.
//
// Incidentally, this method is overridden in mogenerator's boilerplate code.
// When using mogenerator, this specific NSManagedObject implementation will not be used.
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)context
{
    NSManagedObjectModel * model = context.persistentStoreCoordinator.managedObjectModel;
    for (NSEntityDescription * entity in [model entities])
    {
        Class entityClass = NSClassFromString([entity managedObjectClassName]);
        if ( ! [entityClass isEqual:[NSManagedObject class]] && [self isSubclassOfClass:entityClass])
        {
            return entity;
        }
    }
    return nil;
}

+ (instancetype) kvc_fetchObjectInContext:(NSManagedObjectContext*)moc withValue:(id)value forKey:(NSString*)key options:(NSDictionary*)options
{
    NSEntityDescription * entity = [self entityInManagedObjectContext:moc];
    return [entity kvc_fetchObjectInContext:moc withValue:value forKey:key options:options];
}

@end
