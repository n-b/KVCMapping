//
//  NSManagedObject+KVCFetching.m
//  CapitaineTrain
//
//  Created by Nicolas Bouilleaud - Capitaine Train on 20/09/12.
//  Copyright (c) 2012 Capitaine Train. All rights reserved.
//

#import "NSManagedObject+KVCFetching.h"
#import "NSManagedObject+Coercion.h"

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

+ (instancetype) fetchObjectInContext:(NSManagedObjectContext*)moc withValue:(id)value forKey:(NSString*)key createObject:(BOOL)createObject instancesCache:(KVCInstancesCache*)instancesCache
{
    NSEntityDescription * entity = [self entityInManagedObjectContext:moc];
    return [entity fetchObjectInContext:moc withValue:value forKey:key createObject:createObject instancesCache:instancesCache];
}

+ (instancetype) fetchObjectInContext:(NSManagedObjectContext*)moc withValue:(id)value forKey:(NSString*)key createObject:(BOOL)createObject
{
    return [self fetchObjectInContext:moc withValue:value forKey:key createObject:createObject instancesCache:nil];
}

@end


@implementation NSEntityDescription (KVCFetching)

// Find info about key in entity
- (id) fetchObjectInContext:(NSManagedObjectContext*)moc withValue:(id)value forKey:(NSString*)key createObject:(BOOL)createObject instancesCache:(KVCInstancesCache*)instancesCache
{
    NSAttributeDescription * attributeDesc = [self attributesByName][key];
    if(nil==attributeDesc)
        return nil;

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

- (id) fetchObjectInContext:(NSManagedObjectContext*)moc withValue:(id)value forKey:(NSString*)key createObject:(BOOL)createObject
{
    return [self fetchObjectInContext:moc withValue:value forKey:key createObject:createObject instancesCache:nil];
}

@end
