//
//  KVCEntitiesCache.m
//  CapitaineTrain
//
//  Created by Nicolas @ Capitaine Train on 15/04/13.
//  Copyright (c) 2013 Capitaine Train. All rights reserved.
//

#import "KVCEntitiesCache.h"

#pragma mark KVCEntitiesCache

@implementation KVCEntitiesCache
{
    NSDictionary * _entitiesCache;
}

- (id) initWithInstanceCaches:(NSArray*)instanceCaches_
{
    self = [super init];
    NSMutableDictionary * dict = [NSMutableDictionary new];
    for (KVCInstancesCache * instanceCache in instanceCaches_) {
        dict[instanceCache.entityDescription.name] = instanceCache;
    }
    _entitiesCache = [NSDictionary dictionaryWithDictionary:dict];
    return self;
}

- (KVCInstancesCache*) instancesCacheForEntity:(NSEntityDescription*)entity
{
    return self[entity.name];
}

- (NSSet*) accessedInstances
{
    return [[NSSet setWithArray:[_entitiesCache allValues]] valueForKeyPath:@"@distinctUnionOfSets.accessedInstances"];
}

- (NSSet*) unaccessedInstances
{
    return [[NSSet setWithArray:[_entitiesCache allValues]] valueForKeyPath:@"@distinctUnionOfSets.unaccessedInstances"];
}

@end

#pragma mark KVCInstancesCache

@implementation KVCInstancesCache
{
    NSMutableDictionary * _instances;
    NSMutableSet * _accessedInstances;
}

- (id) initWithContext:(NSManagedObjectContext*)moc entityName:(NSString*)entityName primaryKey:(id)primaryKey
{
    self = [super init];
    NSEntityDescription * entityDescription = [NSEntityDescription entityForName:entityName inManagedObjectContext:moc];
    NSFetchRequest * frequest = [NSFetchRequest new];
    frequest.entity = entityDescription;
    frequest.returnsObjectsAsFaults = NO; // Actually load everything.
    NSError * error;
    NSArray * objects = [moc executeFetchRequest:frequest error:&error];
    NSAssert(error==nil, @"fetch should not fail %@ %@", frequest, error);
    NSMutableDictionary * instances = [NSMutableDictionary new];
    for (id object in objects) {
        instances[[object valueForKey:primaryKey]] = object;
    }
    _instances = instances;
    _entityDescription = entityDescription;
    _accessedInstances = [NSMutableSet new];
    return self;
}

- (id) init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id) instanceForKey:(id)key
{
    id instance = _instances[key];
    if(instance) {
        [_accessedInstances addObject:instance];
    }
    return instance;
}

- (void) setInstance:(id)instance forKey:(id<NSCopying>)key
{
    [_accessedInstances addObject:instance];
    _instances[key] = instance;
}

- (NSSet*) accessedInstances
{
    return [NSSet setWithSet:_accessedInstances];
}

- (NSSet*) unaccessedInstances
{
    if([_accessedInstances count] == [_instances count]) {
        return [NSSet set];
    } else {
        NSMutableSet * unaccessedInstances = [NSMutableSet setWithArray:[_instances allValues]];
        [unaccessedInstances minusSet:_accessedInstances];
        return [NSSet setWithSet:unaccessedInstances];
    }
}

@end


#pragma mark - Creation using a ModelMapping

@implementation KVCEntitiesCache (ModelMapping)
- (id) initWithObjectKeys:(NSArray*)keys inModelMapping:(KVCModelMapping*)modelMapping inContext:(NSManagedObjectContext*)moc
{
    NSMutableArray * instanceCaches = [NSMutableArray new];
    for (NSString * key in keys) {
        KVCEntityMapping * entityMapping = [modelMapping entityMappingForKey:key];
        if(entityMapping) {
            [instanceCaches addObject:[[KVCInstancesCache alloc] initWithContext:moc
                                                                   entityMapping:entityMapping]];
        }
    }
    return [self initWithInstanceCaches:instanceCaches];
}
@end

@implementation KVCInstancesCache (ModelMapping)
- (id) initWithContext:(NSManagedObjectContext*)moc entityMapping:(KVCEntityMapping*)entityMapping
{
    return [self initWithContext:moc entityName:entityMapping.entityName primaryKey:entityMapping.primaryKey];
}
@end

#pragma mark - Subscripting

@implementation KVCEntitiesCache (Subscripting)
- (id)objectForKeyedSubscript:(id)key
{
    return _entitiesCache[key];
}
@end


@implementation KVCInstancesCache (Subscripting)
- (id)objectForKeyedSubscript:(id)key
{
    return [self instanceForKey:key];
}

- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key
{
    [self setInstance:obj forKey:key];
}
@end
