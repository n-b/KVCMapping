//
//  NSManagedObject+KVCRelationship.h
//  CapitaineTrain
//
//  Created by Nicolas Bouilleaud - Capitaine Train on 19/09/12.
//  Copyright (c) 2012 Capitaine Train. All rights reserved.
//
#import "NSManagedObject+KVCFetching.h"
#import "KVCEntityMapping.h"

// NSManagedObject+KVCRelationship
//
// Similar to NSObject+KVCMapping : automatically creates relationships using a values dictionary and mapping info.
//
@interface NSManagedObject (KVCRelationship)

// Fetch and assign object(s) for the other end of a relationship.
//
// * Get information about the named relationship on the receiver's entity
// * Find the destination entity of this relationship
// * Fetch the object of destination entity with `valueOrValues` for `key`
// * Set it for the relationship of the receiver
//
// If relationshipName describes a to-many relationship, valueOrValues is a collection (array, set or orderedset).
// objects for these values are fetched and assigned as the relationship with the receiver.
// It replaces the previous relationships entirely.
//
// If relationshipName describes a to-many relationship and valueOrValue is not a collection, the to-many relationship is set to this object exclusively.
//
// If createObject is YES, non-existing destination object(s) are created (with the `key` property set to the value).
//
// If not nil, the Entities Cache is searched for an Instances Cache for the remote entity.
// If no instance cache is found for this entity, the relationship is not set.
- (void) setRelationship:(NSString*)relationshipName withObjectsWithValues:(id)valueOrValues forKey:(NSString*)key options:(NSDictionary*)options;

- (void) setRelationship:(NSString*)relationshipName with:(id)valueOrValues withMapping:(KVCEntityMapping*)entityMapping options:(NSDictionary*)options;

@end
