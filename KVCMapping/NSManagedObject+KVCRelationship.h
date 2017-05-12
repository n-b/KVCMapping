//
//  NSManagedObject+KVCRelationship.h
//  CapitaineTrain
//
//  Created by Nicolas Bouilleaud - Capitaine Train on 19/09/12.
//  Copyright (c) 2012 Capitaine Train. All rights reserved.
//

#import "KVCEntityMapping.h"

@interface NSManagedObject (KVCRelationship)

//
// Fetch an existing object (or create it) and set it as the destination of a relationship.
- (void)kvc_setRelationship:(NSString*)relationshipName toObjectWithValue:(id)value
                      forKey:(NSString*)key options:(NSDictionary*)options;
// To-many relationship variant : valueCollection is an array or set of values.
- (void)kvc_setRelationship:(NSString*)relationshipName toObjectsWithValueIn:(id)valueCollection
                      forKey:(NSString*)key options:(NSDictionary*)options;

@end
