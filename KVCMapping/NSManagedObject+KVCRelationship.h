//
//  NSManagedObject+KVCRelationship.h
//  CapitaineTrain
//
//  Created by Nicolas Bouilleaud - Capitaine Train on 19/09/12.
//  Copyright (c) 2012 Capitaine Train. All rights reserved.
//
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
// * Fetch the object(s) of destination entity with `valueOrValues` for `key`
// * Set it for the relationship of the receiver
//
// To-one Relationships:
// `valueOrValues` is a representation of values (NSDictionary or NSArray), mapped to the destination entity using `entityMapping`.
//
// To-many Relationships:
// If `relationshipName` describes a to-many relationship, `valueOrValues` is treated as a collection (array, set or orderedset) of representations.
// Objects for these values are fetched and assigned as the relationship with the receiver, replacing the previous relationships.
// (if `valueOrValues` is not a collection, relationship is set to this object)
//
// The remote objects of the relationship are fetched using the "primaryKey" property of the entityMapping, if any.
// If no primaryKey is specified, new objects are created.
//
// Once the objects are fetched/created, values are set using kvc_setValues:withEntityMapping:options:.
- (void) kvc_setRelationship:(NSString*)relationshipName with:(id)valueOrValues withMapping:(KVCEntityMapping*)entityMapping options:(NSDictionary*)options;


// Convenience method:
// Only Fetch objects with `valueOrValues` for `key`.
// `key` is a primary key in the destination entity of the relationship.
// valueOrValues should be either a single value (NSString, NSNumber...) for `key` or a collection of values for `key`.
- (void) kvc_setRelationship:(NSString*)relationshipName withObjectsWithValues:(id)valueOrValues forKey:(NSString*)key options:(NSDictionary*)options;


// Perform reverse mapping, using `mapping`, of the remote object(s) of the relationship.
- (id) kvc_relationshipValues:(NSString*)relationshipName withMapping:(KVCEntityMapping*)mapping options:(NSDictionary*)options;

// Obtain the value, or values for the passed key of the remote object of the relationship.
- (id) kvc_relationshipValues:(NSString*)relationshipName forKey:(NSString*)key options:(NSDictionary*)options;

@end
