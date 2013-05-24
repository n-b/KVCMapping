//
//  NSManagedObjectContext+KVCMapping.h
//  CapitaineTrain
//
//  Created by Nicolas @ Capitaine Train on 15/05/13.
//  Copyright (c) 2013 Capitaine Train. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "KVCEntityMapping.h"

@interface NSManagedObjectContext (KVCMapping)

// Create or update the values for the object represented in values in the receiver context
// using `entityMapping` to map the values to the entity properties and relationships.
//
// `values` is the representation of a single NSManagedObject.
// If entityMapping specifies a primary key, search for a matching existing object first.
//
// See also `KVCEntitiesCacheOption` and `KVCCreateObjectOption`
- (NSManagedObject *) kvc_importObject:(NSDictionary*)values
                     withEntityMapping:(KVCEntityMapping*)entityMapping
                               options:(NSDictionary*)options;

// Create or update objects from the passed objects values in the receiver context,
// mapping to entities using the modelMapping.
//
// `objectsValues` is a dictionary whoses keys match the keys in modelMapping.
//
// Return a debug help dictionary containing the imported values for each created/updated managedObjectID.
- (NSDictionary*) kvc_importObjects:(NSDictionary *)objectsValues
                   withModelMapping:(KVCModelMapping *)modelMapping
                            options:(NSDictionary *)options;

@end
