//
//  KVCEntitiesCache.m
//  CapitaineTrain
//
//  Created by Nicolas @ Capitaine Train on 15/04/13.
//  Copyright (c) 2013 Capitaine Train. All rights reserved.
//

#import "KVCEntitiesCache.h"

@interface KVCInstancesCache ()
- (id) initWithInstances:(NSMutableDictionary*)instances;
@end

/****************************************************************************/
#pragma mark KVCEntitiesCache

@implementation KVCEntitiesCache
{
    NSDictionary * _entitiesCache;
}

- (id)initWithEntities:(NSArray*)entities inContext:(NSManagedObjectContext*)context onKey:(NSString*)key
{
    self = [super init];
    NSMutableDictionary * dict = [NSMutableDictionary new];
    for (NSEntityDescription* entity in entities) {
        NSFetchRequest * frequest = [NSFetchRequest new];
        frequest.entity = entity;
        frequest.returnsObjectsAsFaults = NO; // Actually load everything.
        NSError * error;
        NSArray * objects = [context executeFetchRequest:frequest error:&error];
        NSAssert(error==nil, @"fetch should not fail %@ %@", frequest, error);
        NSMutableDictionary * instances = [NSMutableDictionary new];
        for (id object in objects) {
            instances[[object valueForKey:key]] = object;
        }

        dict[entity.name] = [[KVCInstancesCache alloc] initWithInstances:instances];
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

@end

/****************************************************************************/
#pragma mark KVCInstancesCache

@implementation KVCInstancesCache
{
    NSMutableDictionary * _instances;
    NSMutableSet * _accessedInstances;
}

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id) initWithInstances:(NSMutableDictionary*)instances_;
{
    self = [super init];
    _instances = instances_;
    _accessedInstances = [NSMutableSet new];
    return self;
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

@end

/****************************************************************************/
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
