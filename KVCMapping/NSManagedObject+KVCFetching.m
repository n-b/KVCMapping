//
//  NSManagedObject+KVCFetching.m
//  CapitaineTrain
//
//  Created by Nicolas Bouilleaud - Capitaine Train on 20/09/12.
//  Copyright (c) 2012 Capitaine Train. All rights reserved.
//

#import "NSManagedObject+KVCFetching.h"
#import "NSManagedObject+Coercion.h"
#import "NSObject+KVCMapping.h"

NSString* const KVCCreateObjectOption = @"KVCCreateObjectOption";
NSString* const KVCEntitiesCacheOption = @"KVCEntitiesCacheOption";

NSString* const KVCPrimaryKey = @"KVCPrimaryKey";
NSString* const KVCMapping = @"KVCMapping";

@implementation NSManagedObject (KVCFetching)

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

+ (instancetype) fetchObjectInContext:(NSManagedObjectContext*)moc withValue:(id)value forKey:(NSString*)key options:(NSDictionary*)options
{
    NSEntityDescription * entity = [self entityInManagedObjectContext:moc];
    return [entity fetchObjectInContext:moc withValue:value forKey:key options:options];
}

@end


@implementation NSEntityDescription (KVCFetching)

// Find info about key in entity
- (id) fetchObjectInContext:(NSManagedObjectContext*)moc withValue:(id)value forKey:(NSString*)key options:(NSDictionary*)options
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
    
    Class expectedClass = NSClassFromString(attributeDesc.attributeValueClassName);
    id correctValue;
    if([value isKindOfClass:expectedClass] || value==nil)
    {
        correctValue = value;
    }
    else
    {
        NSAttributeType attributeType = attributeDesc.attributeType;
        correctValue = [NSManagedObject coerceValue:value toAttributeType:attributeType];
    }
    
    // Bail out if we could not coerce the value
    // (this also prevents the creation of empty objects)
    if(!correctValue)
        return nil;
    
    // Search object, in cache if possible
    KVCEntitiesCache * entitiesCache = options[KVCEntitiesCacheOption];
    KVCInstancesCache * instancesCache = entitiesCache[self.name];
    NSManagedObject * obj;
    if(instancesCache) {
        obj = instancesCache[correctValue];
    } else {
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
    
    BOOL createObject = [options[KVCCreateObjectOption] boolValue];
    if(nil==obj && createObject)
    {
        obj = [[self class] insertNewObjectForEntityForName:[self name] inManagedObjectContext:moc];
        [obj setValue:correctValue forKey:key];
        if(instancesCache) {
            instancesCache[correctValue] = obj;
        }
    }
    return obj;
}

- (id) fetchObjectInContext:(NSManagedObjectContext*)moc withValues:(id)values withMappingDictionary:(KVCEntityMapping*)entityMapping options:(NSDictionary*)options
{
    id object;
    if(entityMapping.primaryKey) {
        id primaryValue = [values extractValueForPrimaryKeyWithEntityMapping:entityMapping];
        object = [self fetchObjectInContext:moc withValue:primaryValue forKey:entityMapping.primaryKey options:options];
    } else {
        // Alway create subobjects with no primarykey
        object = [[self class] insertNewObjectForEntityForName:self.name inManagedObjectContext:moc];
    }
    [object kvc_setValues:values withEntityMapping:entityMapping options:options];
    return object;
}

@end
