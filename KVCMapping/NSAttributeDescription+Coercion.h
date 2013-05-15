//
//  NSAttributeDescription+Coercion.h
//  CapitaineTrain
//
//  Created by Nicolas Bouilleaud - Capitaine Train on 20/09/12.
//  Copyright (c) 2012 Capitaine Train. All rights reserved.
//

@interface NSAttributeDescription (Coercion)
// Converts the passed value, if necessary, to the expected type for the attribute type.
// (i.e. NSStrings to NSNumbers and vice-versa.)
//
// NSDateAttributeType or NSBinaryDataAttributeType can't be converted to automatically.
//
// If `value` is not in the expected type and can't be converted, returns nil.
- (id) kvc_coerceValue:(id)value;
@end
