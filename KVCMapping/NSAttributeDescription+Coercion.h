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


// Make sure the underlying CFNumberType matches the attributetype
// (Only makes sense for Number values, obviously)
//
// CoreData may return NSNumbers whose internal type do not match
// the attribute type. (See CFNumberGetType())
//
// This leads to issues when encoding the data in a format where this matters,
// e.g. in JSON bools should be `true` or `false`, not `0` or `1`
- (id) kvc_fixNumberValueType:(id)value;
@end
