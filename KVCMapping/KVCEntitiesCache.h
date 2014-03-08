//
//  KVCEntitiesCache.h
//  CapitaineTrain
//
//  Created by Nicolas @ Capitaine Train on 15/04/13.
//  Copyright (c) 2013 Capitaine Train. All rights reserved.
//

#import "KVCEntityMapping.h"

@class KVCInstancesCache;

// Entities Cache.
// Entities cache are optionally used when fetching an object (in NSManagedObject+KVCFetching)
// directly or via a relationship (NSManagedObject+KVCRelationship).
//
// An Entities Cache is built before a large Fetch/Set/Set operation, like a parsing.
// It will then be used instead of actual accesses to the CoreData database.
//
// This can provide a significant speedup of operations involving a large number of fetches: as all
// objects are prefetched in a single pass at the beginning, all subsequent access to objects are
// basically free.

// A collection of Instance Caches
@interface KVCEntitiesCache : NSObject
- (id) initWithInstanceCaches:(NSArray*)instanceCaches;
- (KVCInstancesCache*) instancesCacheForEntity:(NSEntityDescription*)entity;
- (NSSet*) accessedInstances;
- (NSSet*) unaccessedInstances;
@end

// A simple key-value collection for each Entity Cache.
@interface KVCInstancesCache : NSObject
// Fetches all instances of an entity, and cache it using the specified key.
- (id) initWithContext:(NSManagedObjectContext*)moc entityName:(NSString*)entityName primaryKey:(id)primaryKey;
@property (readonly) NSEntityDescription * entityDescription;
- (id) instanceForKey:(id)key;
- (void) setInstance:(id)instance forKey:(id<NSCopying>)key;
// Everytime an instance is accessed from the cache (via instanceForKey:), it's added to this property.
- (NSSet*) accessedInstances;
- (NSSet*) unaccessedInstances;
@end

#pragma mark - Creation using a ModelMapping

@interface KVCEntitiesCache (ModelMapping)
// Create instance caches on the specified `moc` for the Entities described in `modelMapping`,
// using only the EntityMappings fro the passed `keys`.
- (id) initWithObjectKeys:(NSArray*)keys inModelMapping:(KVCModelMapping*)modelMapping inContext:(NSManagedObjectContext*)moc;
@end

@interface KVCInstancesCache (ModelMapping)
// Create an Instance cache on the specifiec context using the entity info (entity name and primary key) from the mapping
- (id) initWithContext:(NSManagedObjectContext*)moc entityMapping:(KVCEntityMapping*)entityMapping;
@end

#pragma mark - Subscripting

@interface KVCEntitiesCache (Subscripting)
- (KVCInstancesCache*)objectForKeyedSubscript:(id)key;
@end

@interface KVCInstancesCache (Subscripting)
- (id)objectForKeyedSubscript:(id)key;
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;
@end
