//
//  NSManagedObject+KVCFetching.h
//  CapitaineTrain
//
//  Created by Nicolas Bouilleaud - Capitaine Train on 20/09/12.
//  Copyright (c) 2012 Capitaine Train. All rights reserved.
//
#import "KVCEntitiesCache.h"

// KVCFetching
//
//
// NSManagedObject class method to fetch (and optionally create) an object based on a simple key=value search.
// These methods use the receiver class to decide what entity to look for,
// in other words they should only be called on NSManagedObject subclasses
@interface NSManagedObject (KVCFetching)

// Finds the entity in the passed context's model whose object class is the receiver, or a superclass of the receiver.
// Obviously, it's to be called in subclasses. The implementation does not return entities whose object class is NSManagedObject.
//
// Note that this method is overridden in mogenerator's boilerplate code. If you use mogenerator, the NSManagedObject implementation will not be used.
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)context;

// Fetch an existing object of the receiver entity whose value for `key` is equal to the passed `value`
// Creates a new object (with the `key` set to the `value`) optionally
//
// if instancesCache is is used, no actual Coredata fetch is performed, but the cache is simply searched for the object.
// if an object is created, it is added to the cache.
+ (instancetype) fetchObjectInContext:(NSManagedObjectContext*)moc withValue:(id)value forKey:(NSString*)key createObject:(BOOL)createObject instancesCache:(KVCInstancesCache*)instancesCache;
+ (instancetype) fetchObjectInContext:(NSManagedObjectContext*)moc withValue:(id)value forKey:(NSString*)key createObject:(BOOL)createObject;

@end

@interface NSEntityDescription (KVCFetching)
// Fetch an existing object of the receiver entity whose value for `key` is equal to the passed `value`
// Creates a new object (with the `key` set to the `value`) optionally
//
// if instancesCache is is used, no actual Coredata fetch is performed, but the cache is simply searched for the object.
// if an object is created, it is added to the cache.
- (id) fetchObjectInContext:(NSManagedObjectContext*)moc withValue:(id)value forKey:(NSString*)key createObject:(BOOL)createObject instancesCache:(KVCInstancesCache*)instancesCache;
- (id) fetchObjectInContext:(NSManagedObjectContext*)moc withValue:(id)value forKey:(NSString*)key createObject:(BOOL)createObject;

@end
