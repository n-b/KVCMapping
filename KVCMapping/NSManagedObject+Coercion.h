//
//  NSManagedObject+Coercion.h
//  CapitaineTrain
//
//  Created by Nicolas Bouilleaud on 20/09/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

@interface NSManagedObject (Coercion)
/*
 * Converts the passed value to the expected value fot the attribute type.
 */
+ (id) coerceValue:(id)value toAttributeType:(NSAttributeType)attributeType;
@end
