//
//  NSEntityDescription+KVCFetching.h
//  CapitaineTrain
//
//  Created by Nicolas Bouilleaud - Capitaine Train on 20/09/12.
//  Copyright (c) 2012 Capitaine Train. All rights reserved.
//
#import "KVCEntityMapping.h"

@interface NSEntityDescription (KVCFetching)

// Fetch an object of the receiver entity whose value for `key` is equal to the passed `value`
//
// if a `KVCEntitiesCache` is passed in `KVCEntitiesCacheOption`, this method performs no actual Coredata fetch, and only looks up the cache.
//
// If no match is found and `KVCCreateObjectOption` is @YES,
//  a new object of the receiver entity is created,
//  its value for `key` is set to `value`,
//  and it is added to the `KVCEntitiesCache`, if any.
- (id) kvc_fetchObjectInContext:(NSManagedObjectContext*)moc withValue:(id)value forKey:(NSString*)key options:(NSDictionary*)options;

// Fetch an object of the receiver entity using the primaryKey of `mapping`,
// then set its values, using `mapping` again.
// If no primaryKey is set, always create a new object.
- (id) kvc_fetchObjectInContext:(NSManagedObjectContext*)moc withValues:(id)values withMappingDictionary:(KVCEntityMapping*)mapping options:(NSDictionary*)options;

@end



@interface NSManagedObject (KVCFetching)
// Convenience Method
//
// Grabs the NSEntityDescription for the receiving NSManagedObject specific subclass,
// and fetches a matching object of this entity.
//
// Uses the receiver class to decide what entity to look for.
// In other words, should only be called on NSManagedObject *subclasses*.
+ (instancetype) kvc_fetchObjectInContext:(NSManagedObjectContext*)moc withValue:(id)value forKey:(NSString*)key options:(NSDictionary*)options;
@end


// options keys
extern NSString* const KVCCreateObjectOption;  // A NSNumber (bool)
extern NSString* const KVCEntitiesCacheOption; // A KVCEntitiesCache
