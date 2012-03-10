//
//  NSObject+KVCMapping.m
//  KVCMapping
//
//  Created by Nicolas Bouilleaud on 18/06/11.
//  Copyright 2011 Nicolas Bouilleaud. All rights reserved.
//

#import "NSObject+KVCMapping.h"
#define DEBUG_KV_MAPPING 0

@implementation NSObject (NSObject_KVCMapping)

- (void) setTransformedValue:(id)value forRealKey:(NSString*)realKey
{
    [self setValue:value forKey:realKey];
}

- (void) setValue:(id)value forKey:(NSString*)wantedKey withMappingDictionary:(NSDictionary*)kvcMappingDictionnary
{
    NSString * realKey = [kvcMappingDictionnary objectForKey:wantedKey];
    // find a value transformer
    NSArray * realComponents = [realKey componentsSeparatedByString:@":"];
    if(realComponents.count==2)
    {
        realKey = [realComponents objectAtIndex:1];
        NSValueTransformer * transformer = [NSValueTransformer valueTransformerForName:[realComponents objectAtIndex:0]];
        value = [transformer transformedValue:value];
    }
    
    if([realKey length])
        [self setTransformedValue:value forRealKey:realKey];
#if DEBUG
    else
        NSLog(@"ignored key : %@ for class %@",wantedKey, [self class]);
#endif
}

- (void) setValuesForKeysWithDictionary:(NSDictionary *)keyedValues withMappingDictionary:(NSDictionary*)kvcMappingDictionnary
{
    for (NSString * wantedKey in [keyedValues allKeys]) 
        [self setValue:[keyedValues objectForKey:wantedKey] forKey:wantedKey withMappingDictionary:kvcMappingDictionnary];
}

@end

/****************************************************************************/
#pragma mark -

@implementation NSManagedObject (NSObject_KVCMapping)

- (void) setTransformedValue:(id)value forRealKey:(NSString*)realKey
{
    NSAttributeDescription * attributeDesc = [[[self entity] attributesByName] objectForKey:realKey];
    if(attributeDesc==nil)
    {
        [super setTransformedValue:value forRealKey:realKey];
        return;
    }
    
    NSAttributeType attributeType = attributeDesc.attributeType;
    Class expectedClass = NSClassFromString(attributeDesc.attributeValueClassName);
    if([value isKindOfClass:expectedClass])
    {
        [self setValue:value forKey:realKey];
        return;
    }

    id coercedValue = nil;
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
                coercedValue = [NSNumber numberWithBool:[value boolValue]];  
            break;
        case NSInteger16AttributeType :
        case NSInteger32AttributeType :
            if([value respondsToSelector:@selector(intValue)])
                coercedValue = [NSNumber numberWithLong:[value intValue]];  
            break;
        case NSInteger64AttributeType :
            if([value respondsToSelector:@selector(longLongValue)])
                coercedValue = [NSNumber numberWithLongLong:[value longLongValue]];  
            break;
        case NSDecimalAttributeType :
            if([value isKindOfClass:[NSString self]])
                coercedValue = [NSDecimalNumber decimalNumberWithString:value];  
            break;
        case NSDoubleAttributeType :
            if([value respondsToSelector:@selector(doubleValue)])
                coercedValue = [NSNumber numberWithDouble:[value doubleValue]];  
            break;
        case NSFloatAttributeType :
            if([value respondsToSelector:@selector(floatValue)])
                coercedValue = [NSNumber numberWithFloat:[value floatValue]];  
            break;
            
            // NSStrings
        case NSStringAttributeType : 
            if([value respondsToSelector:@selector(stringValue)])
                coercedValue = [value stringValue];
            break;
            
            // Date, Data, Transformable : 
            // We can't coerce automatically. 
        case NSDateAttributeType :
        case NSBinaryDataAttributeType:
            break;
            
            // Default behaviour for these (probably gonna crash later anyway)
        case NSObjectIDAttributeType:
        case NSTransformableAttributeType:
            break;
        default :
            coercedValue = value;
            break;
    }
#if DEBUG && DEBUG_KV_MAPPING
    if(correctValue)
        NSLog(@"fixed %@(%@) to %@(%@) for key %@ of class %@",
              value, [value class], correctValue, [correctValue class], realKey, [self class]);
    else
        NSLog(@"invalid value : %@(%@), expected %@ for key %@ of class %@",
              value, [value class], expectedClass, realKey, [self class]);
#endif
    NSAssert([[coercedValue class] isSubclassOfClass:expectedClass],
             @"The result value %@(%@) is incorrect (expected %@) for key %@ of class %@",
             coercedValue, [coercedValue class], expectedClass, realKey, [self class]);
    
    [self setValue:coercedValue forKey:realKey];
}

@end
