//
//  NSObject+KVCMapping.m
//  KVCMapping
//
//  Created by Nicolas Bouilleaud on 18/06/11.
//  Copyright 2011 Nicolas Bouilleaud. All rights reserved.
//

#import "NSObject+KVCMapping.h"

#pragma mark NSObject

@implementation NSObject (KVCMapping)

// Forward mapping
- (void) kvc_setValues:(id)values withEntityMapping:(KVCEntityMapping*)entityMapping options:(NSDictionary*)options
{
    NSParameterAssert([values isKindOfClass:[NSDictionary class]] || [values isKindOfClass:[NSArray class]]);
    if([values isKindOfClass:[NSDictionary class]]) {
        // Values is a dictionary : just iterate on its keys.
        for (NSString * wantedKey in [values allKeys]) {
            [self kvc_setValue:values[wantedKey] forKey:wantedKey withEntityMapping:entityMapping options:options];
        }
    } else if([values isKindOfClass:[NSArray class]]) {
        // Values is an nsarray : use the index as the key
        [values enumerateObjectsUsingBlock:^(id value, NSUInteger index, BOOL *stop) {
            NSNumber * wantedKey = @(index);
            [self kvc_setValue:value forKey:wantedKey withEntityMapping:entityMapping options:options];
        }];
    }
}

- (void) kvc_setValue:(id)value forKey:(id)wantedKey withEntityMapping:(KVCEntityMapping*)entityMapping options:(NSDictionary*)options
{
    // Find the mappings to use for this key.
    NSArray* keyMappings = [entityMapping mappingsForKey:wantedKey];
    
    for (KVCKeyMapping * keyMapping in keyMappings){
        [keyMapping assignValue:value toObject:self options:options];
    }
}

// Convenience Methods
- (void) kvc_setValues:(id)values withMappingDictionary:(NSDictionary*)mappingDict options:(NSDictionary*)options
{
    [self kvc_setValues:values withEntityMapping:[[KVCEntityMapping alloc] initWithMappingDictionary:mappingDict primaryKey:nil entityName:nil] options:options];
}

- (void) kvc_setValue:(id)value forKey:(id)wantedKey withMappingDictionary:(NSDictionary*)mappingDict options:(NSDictionary*)options
{
    [self kvc_setValue:value forKey:wantedKey withEntityMapping:[[KVCEntityMapping alloc] initWithMappingDictionary:mappingDict primaryKey:nil entityName:nil] options:options];
}

// Reverse Mapping
- (id) kvc_valueForKey:(id)key withEntityMapping:(KVCEntityMapping*)entityMapping options:(NSDictionary*)options
{
    NSArray * mappings = [entityMapping mappingsForKey:key];
    if([mappings count]) {
         // Only use the first mapping in reverse mapping
       	return [mappings[0] valueFromObject:self options:options];
    } else {
        return nil;
    }
}

- (id) kvc_valuesWithEntityMapping:(KVCEntityMapping*)entityMapping options:(NSDictionary*)options
{
    id values = [NSMutableDictionary new];
    for (id key in [entityMapping allKeys]) {
        id value = [self kvc_valueForKey:key withEntityMapping:entityMapping options:options];
        if(value) {
            values[key] = value;
        }
    }
    // Convert to an NSArray if all the keys are NSNumbers
    NSArray * keysClasses = [[values allKeys] valueForKeyPath:@"@distinctUnionOfObjects.class"];
    if([keysClasses count]==1 && [keysClasses[0] isSubclassOfClass:[NSNumber class]])
    {
        NSMutableArray * valuesArray = [NSMutableArray new];
        for (NSUInteger i=0; i<[values count]; i++) {
            [valuesArray addObject:values[@(i)]];
        }
        values = valuesArray;
    }
    return values;
}

// Convenience Methods
- (id) kvc_valuesWithMappingDictionary:(NSDictionary*)mappingDict options:(NSDictionary*)options
{
    return [self kvc_valuesWithEntityMapping:[[KVCEntityMapping alloc] initWithMappingDictionary:mappingDict primaryKey:nil entityName:nil] options:options];
}

- (id) kvc_valueForKey:(id)key withMappingDictionary:(NSDictionary*)mappingDict options:(NSDictionary*)options
{
    return [self kvc_valueForKey:key withEntityMapping:[[KVCEntityMapping alloc] initWithMappingDictionary:mappingDict primaryKey:nil entityName:nil] options:options];
}

@end
