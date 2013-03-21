//
//  NSObject+KVCMapping.m
//  KVCMapping
//
//  Created by Nicolas Bouilleaud on 18/06/11.
//  Copyright 2011 Nicolas Bouilleaud. All rights reserved.
//

#import "NSObject+KVCMapping.h"
#import "NSManagedObject+Coercion.h"

/******************************************************************************/
#pragma mark Helper Methods

@implementation NSString (KVCMappingKeysHelperMethods)

- (NSValueTransformer*) kvcExtractValueTransformer:(NSString**)realKey
{
    NSArray * realComponents = [self componentsSeparatedByString:@":"];
    if(realComponents.count!=2)
    {
        if(realKey)
            *realKey = self;
        return nil;
    }
    
    if(realKey)
        *realKey = realComponents[1];
    return [NSValueTransformer valueTransformerForName:realComponents[0]];
}

@end

/******************************************************************************/
#pragma mark NSObject

#define DEBUG_KV_MAPPING 0

@implementation NSObject (KVCMapping)

- (void) setValuesForKeysWithDictionary:(NSDictionary *)keyedValues withMappingDictionary:(NSDictionary*)kvcMappingDictionnary
{
    for (NSString * wantedKey in [keyedValues allKeys]) 
        [self setValue:keyedValues[wantedKey] forKey:wantedKey withMappingDictionary:kvcMappingDictionnary];
}

- (void) setValue:(id)value forKey:(NSString*)wantedKey withMappingDictionary:(NSDictionary*)kvcMappingDictionnary
{
    // Find the actual keys to use in the mapping dictionary.
    id realKeys = kvcMappingDictionnary[wantedKey];
    
    // realKeys might be an NSArray of NSStrings, or a single NSString.
    // Convert it to an NSArray.
    if([realKeys isKindOfClass:[NSString class]])
        realKeys = @[realKeys];
    
    for (__strong NSString * realKey in realKeys)
    {
        id realValue;

        NSValueTransformer * transformer = [realKey kvcExtractValueTransformer:&realKey];
        if(transformer)
            realValue = [transformer transformedValue:value];
        else
            realValue = value;
        
        // Only set the value if we found a valid realKey. Otherwise, do nothing.
        // (We could have decided to use the wantedKey instead. See "Security Considerations" in the README.)
        if([realKey length])
            [self setTransformedValue:realValue forRealKey:realKey];
#if DEBUG_KVC_MAPPING
        else
            NSLog(@"ignored key : %@ for class %@. Mapping dictionary : %@",wantedKey, [self class], kvcMappingDictionnary);
#endif
    }
}

- (void) setTransformedValue:(id)value forRealKey:(NSString*)realKey
{
    // This method is only useful as a hook for NSManagedObject's reimplementation
    [self setValue:value forKey:realKey];
}

@end

/****************************************************************************/
#pragma mark NSManagedObject

@implementation NSManagedObject (KVCMapping)

- (void) setTransformedValue:(id)value forRealKey:(NSString*)realKey
{
    // `realKey` is already converted to a valid KVC key by - setValue:forKey:withMappingDictionary.
    
    // Find whether we're setting a CoreData attribute or a regular 
    NSAttributeDescription * attributeDesc = [[self entity] attributesByName][realKey];
    if(attributeDesc==nil)
    {
        // We have no attribute description, use regular KVC.
        [super setTransformedValue:value forRealKey:realKey];
        return;
    }
    
    // Check wether we need to convert the value.
    NSAttributeType attributeType = attributeDesc.attributeType;
    Class expectedClass = NSClassFromString(attributeDesc.attributeValueClassName);
    if([value isKindOfClass:expectedClass] || value==nil)
    {
        // Value is as expected : just use it as it is.
        [self setValue:value forKey:realKey];
        return;
    }

    // Check for NSNull : just set to nil
    if(value==[NSNull null])
    {
        [self setValue:nil forKey:realKey];
        return;
    }
    
    // Convert !
    id coercedValue = [[self class] coerceValue:value toAttributeType:attributeType];
    
#if DEBUG_KVC_MAPPING
    if(coercedValue)
        NSLog(@"fixed %@(%@) to %@(%@) for key %@ of class %@",
              value, [value class], coercedValue, [coercedValue class], realKey, [self class]);
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

@implementation NSDictionary(KVCMappingHelper)
- (NSString*) wantedKeyForRealKey:(NSString*)searchedRealKey
{
    for (NSString * wantedKey in self) {
        id realKeys = self[wantedKey];
        
        // realKeys might be an NSArray of NSStrings, or a single NSString.
        // Convert it to an NSArray.
        if([realKeys isKindOfClass:[NSString class]])
            realKeys = @[realKeys];
        
        for (__strong NSString * realKey in realKeys)
        {
            [realKey kvcExtractValueTransformer:&realKey];
            if([realKey isEqualToString:searchedRealKey])
                return wantedKey;
        }
    }
    return nil;
}
@end
