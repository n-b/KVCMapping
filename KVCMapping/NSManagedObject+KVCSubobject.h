//
//  NSManagedObject+KVCSubobject.h
//  KVCMapping
//
//  Created by Nicolas @ Capitaine Train on 24/05/13.
//
//

#import "KVCEntityMapping.h"

@interface NSManagedObject (KVCSubobject)

// Fetch of create an object, set its values, and set it as the destination of a relationship.
//
// If entityMapping has a primary key, an existing object will be searched first.
// Otherwise, a new object will be created, regardless of KVCCreateObjectOption.
- (void)kvc_setRelationship:(NSString*)relationshipName toSubobjectFromValues:(id)values
                usingMapping:(KVCEntityMapping*)entityMapping options:(NSDictionary*)options;
// To-many relationship variant : valuesCollection is a collection of object values. (e.g. an Array of Dictionaries)
- (void)kvc_setRelationship:(NSString*)relationshipName toSubobjectsFromValuesCollection:(id)valuesCollection
                usingMapping:(KVCEntityMapping*)entityMapping options:(NSDictionary*)options;

@end
