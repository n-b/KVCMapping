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

// Set value for a wanted key, with a mapping dictionary. (maybe several mappings)
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

@end
