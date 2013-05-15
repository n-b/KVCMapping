//
//  NSManagedObject+KVCRelationship.h
//  CapitaineTrain
//
//  Created by Nicolas Bouilleaud - Capitaine Train on 19/09/12.
//  Copyright (c) 2012 Capitaine Train. All rights reserved.
//
#import "KVCEntitiesCache.h"

// NSManagedObject+KVCRelationship
//
// Similar to NSObject+KVCMapping : automatically creates relationships using a values dictionary and mapping info.
//
@interface NSManagedObject (KVCRelationship)

// Fetch an object for the other end of a to-one relationship.
//
// * Get information about the named relationship on the receiver's entity
// * Find the destination entity of this relationship
// * Fetch the object of destination entity with `value` for `key`
// * Set it for the relationship of the receiver
//
// Optionally create the remote object with the key set to the value
//
// If used, the Entities Cache is searched for an Instances Cache for the remote entity.
// If no instance cache is found for this entity, the relationship is not set.
- (id) setRelationship:(NSString*)relationshipName withObjectWithValue:(id)value forKey:(NSString*)key createObject:(BOOL)createObject entitiesCache:(KVCEntitiesCache*)entitiesCache;
- (id) setRelationship:(NSString*)relationshipName withObjectWithValue:(id)value forKey:(NSString*)key createObject:(BOOL)createObject;

// Calls setRelationship:withObjectWithValue:forKey: with a number of values.
//
// relationshipValues is of the form :
// @{ @"named_relationship": @"valueToFetchTheDestinationObject" }
//
// mapping is of the form :
// @{ @"named_relationship": @"actualRelationshipName:keyToFetchTheDestinationObject" }
//
// If used, the Entities Cache is searched for an Instances Cache for the remote entities.
// If no instance cache is found for an entity, that relationship is not set.
- (void) setRelationshipsWithDictionary:(NSDictionary*)relationshipValues withMappingDictionary:(NSDictionary *)mapping createObjects:(BOOL)createObjects entitiesCache:(KVCEntitiesCache*)entitiesCache;
- (void) setRelationshipsWithDictionary:(NSDictionary*)relationshipValues withMappingDictionary:(NSDictionary *)mapping createObjects:(BOOL)createObjects;

@end


@interface NSString (KVCRelationshipHelperMethods)
// Formats a relationship mapping key, <relationshipKey>:<keyInDestinationEntity>.
- (id) usingKVCKeyInDestinationEntity:(NSString*)keyInDestinationEntity;
@end