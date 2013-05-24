//
//  KVCEntityMapping+AssignValue.h
//  KVCMapping
//
//  Created by Nicolas @ Capitaine Train on 24/05/13.
//
//

#import "KVCEntityMapping.h"

@interface KVCKeyMapping (KVCAssignValue)
// Interpret the value and set it to the object, depending of the receiver's settings.
// Base implementation does nothing.
- (void) assignValue:(id)value toObject:(id)object options:(NSDictionary*)options;

// Obtain the external value from the object for this mapping.
// Base implementation does nothing.
- (id) valueFromObject:(id)object options:(NSDictionary*)options;
@end

