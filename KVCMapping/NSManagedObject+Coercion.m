//
//  NSManagedObject+Coercion.m
//  CapitaineTrain
//
//  Created by Nicolas Bouilleaud on 20/09/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "NSManagedObject+Coercion.h"

@implementation NSManagedObject (Coercion)

+ (id) coerceValue:(id)value toAttributeType:(NSAttributeType)attributeType
{
    switch (attributeType)
    {
            // Numbers
            /*
             Notes :
             * Core data has only signed integers,
             * There's no "shortValue" in NSString,
             * Using intValue always return a 32-bit integer (an int), while integerValue returns an NSInteger, which may be 64-bit.
             */
        case NSBooleanAttributeType :
            if([value respondsToSelector:@selector(boolValue)])
                return [NSNumber numberWithBool:[value boolValue]];
            return nil;
            
        case NSInteger16AttributeType :
        case NSInteger32AttributeType :
            if([value respondsToSelector:@selector(intValue)])
                return [NSNumber numberWithLong:[value intValue]];
            return nil;
            
        case NSInteger64AttributeType :
            if([value respondsToSelector:@selector(longLongValue)])
                return [NSNumber numberWithLongLong:[value longLongValue]];
            return nil;
            
        case NSDecimalAttributeType :
            if([value respondsToSelector:@selector(decimalValue)])
                return [NSDecimalNumber decimalNumberWithDecimal:[value decimalValue]];
            return nil;
            
        case NSDoubleAttributeType :
            if([value respondsToSelector:@selector(doubleValue)])
                return [NSNumber numberWithDouble:[value doubleValue]];
            return nil;
            
        case NSFloatAttributeType :
            if([value respondsToSelector:@selector(floatValue)])
                return [NSNumber numberWithFloat:[value floatValue]];
            return nil;
            
            // NSStrings
        case NSStringAttributeType :
            if([value isKindOfClass:[NSString class]])
                return value;
            if([value respondsToSelector:@selector(stringValue)])
                return [value stringValue];
            return nil;
            
            // Date, Data :
            // We can't coerce automatically.
        case NSDateAttributeType :
            if([value isKindOfClass:[NSDate class]])
                return value;
            return nil;
        case NSBinaryDataAttributeType:
            if([value isKindOfClass:[NSData class]])
                return value;
            return nil;
            
            // Default behaviour for these (probably gonna crash later anyway)
        case NSUndefinedAttributeType:
        case NSObjectIDAttributeType:
        case NSTransformableAttributeType:
            return value;
        default :
            return value;
    }
}

@end
