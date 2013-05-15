//
//  KVCEntitiesCache.h
//  CapitaineTrain
//
//  Created by Nicolas @ Capitaine Train on 15/04/13.
//  Copyright (c) 2013 Capitaine Train. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KVCInstancesCache;

// Entities Cache.
// Entities cache are optionally used when fetching an object (in NSManagedObject+KVCFetching)
// directly or via a relationship (NSManagedObject+KVCRelationship).
//
// An Entities Cache is built before a large Fetch/Set/Set operation, like a parsing.
// It will then be used instead of actual accesses to the CoreData database.
//
//
@interface KVCEntitiesCache : NSObject
// Create a Cache, by fetching all the objects if the specified entities in the context.
// All objects are then stored in instance caches, using the key specified.
- (id)initWithEntities:(NSArray*)entities inContext:(NSManagedObjectContext*)context onKey:(NSString*)key;
- (KVCInstancesCache*) instancesCacheForEntity:(NSEntityDescription*)entity;
- (NSSet*) accessedInstances;
@end

// A simple key-value collection for each Entity Cache.
@interface KVCInstancesCache : NSObject
- (id) instanceForKey:(id)key;
- (void) setInstance:(id)instance forKey:(id<NSCopying>)key;
- (NSSet*) accessedInstances;
@end

@interface KVCEntitiesCache (Subscripting)
- (KVCInstancesCache*)objectForKeyedSubscript:(id)key;
@end

@interface KVCInstancesCache (Subscripting)
- (id)objectForKeyedSubscript:(id)key;
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;
@end