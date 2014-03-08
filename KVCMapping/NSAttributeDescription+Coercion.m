//
//  NSAttributeDescription+Coercion.m
//  CapitaineTrain
//
//  Created by Nicolas Bouilleaud - Capitaine Train on 20/09/12.
//  Copyright (c) 2012 Capitaine Train. All rights reserved.
//

#import "NSAttributeDescription+Coercion.h"
#import <objc/runtime.h>

@implementation NSAttributeDescription (Coercion)

- (Class) kvc_expectedClass
{
    Class class = objc_getAssociatedObject(self, _cmd);
    if(!class){
        class = NSClassFromString(self.attributeValueClassName);
        objc_setAssociatedObject(self, _cmd, class, OBJC_ASSOCIATION_ASSIGN);
    }
    return class;
}

static NSString * KVCNumberStringValue(NSNumber* num_)
{
    char * buf;
    NSUInteger len;
    switch (CFNumberGetType((CFNumberRef)num_)) {
        case kCFNumberSInt8Type: len = asprintf(&buf, "%c", [num_ charValue]); break;
        case kCFNumberSInt16Type: len = asprintf(&buf, "%hd", [num_ shortValue]); break;
        case kCFNumberSInt32Type: len = asprintf(&buf, "%d", [num_ intValue]); break;
        case kCFNumberSInt64Type: len = asprintf(&buf, "%lld", [num_ longLongValue]); break;
        case kCFNumberFloat32Type: len = asprintf(&buf, "%g", [num_ floatValue]); break;
        case kCFNumberFloat64Type: len = asprintf(&buf, "%g", [num_ doubleValue]); break;
            
        case kCFNumberCharType: len = asprintf(&buf, "%c", [num_ charValue]); break;
        case kCFNumberShortType: len = asprintf(&buf, "%d", [num_ shortValue]); break;
        case kCFNumberIntType: len = asprintf(&buf, "%i", [num_ intValue]); break;
        case kCFNumberLongType: len = asprintf(&buf, "%ld", [num_ longValue]); break;
        case kCFNumberLongLongType: len = asprintf(&buf, "%lld", [num_ longLongValue]); break;
        case kCFNumberFloatType: len = asprintf(&buf, "%g", [num_ floatValue]); break;
        case kCFNumberDoubleType: len = asprintf(&buf, "%g", [num_ doubleValue]); break;
            
        case kCFNumberCFIndexType: len = asprintf(&buf, "%ld", [num_ longValue]); break;
        case kCFNumberNSIntegerType: len = asprintf(&buf, "%ld", [num_ longValue]); break;
        case kCFNumberCGFloatType: len = asprintf(&buf, "%g", [num_ doubleValue]); break;
            
        default: return [num_ stringValue];
    }
    if(buf) {
        return [[NSString alloc] initWithBytesNoCopy:buf length:len encoding:NSASCIIStringEncoding freeWhenDone:YES];
    } else {
        return [num_ stringValue];
    }
}

- (id) kvc_coerceValue:(id)value
{
    if(nil==value) {
        return nil;
    }
    
    if( [value isKindOfClass:[self kvc_expectedClass]]) {
        return value;
    }
    
    switch (self.attributeType)
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
            // Avoid using stringValue, which uses locale info. We don't need that.
        case NSStringAttributeType :
            if([value isKindOfClass:[NSNumber class]])
                return KVCNumberStringValue(value);
            if([value respondsToSelector:@selector(stringValue)])
                return [value stringValue];
            return nil;
            
            // Date, Data :
            // We can't coerce automatically.
        case NSDateAttributeType :
            return nil;
        case NSBinaryDataAttributeType:
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

- (id) kvc_fixNumberValueType:(id)value
{
    if(nil==value || ![value isKindOfClass:[NSNumber class]]) {
        return value;
    }
    
    NSParameterAssert([value isKindOfClass:[self kvc_expectedClass]]);
    
    switch (self.attributeType)
    {
            // Numbers
        case NSBooleanAttributeType : return [NSNumber numberWithBool:[value boolValue]];
        case NSInteger16AttributeType : return [NSNumber numberWithShort:[value shortValue]];
        case NSInteger32AttributeType : return [NSNumber numberWithLong:[value intValue]];
        case NSInteger64AttributeType : return [NSNumber numberWithLongLong:[value longLongValue]];
        case NSFloatAttributeType : return [NSNumber numberWithFloat:[value floatValue]];
        case NSDoubleAttributeType : return [NSNumber numberWithDouble:[value doubleValue]];
        case NSDecimalAttributeType : return [NSDecimalNumber decimalNumberWithDecimal:[value decimalValue]];
        default : return value;
    }
}

@end
