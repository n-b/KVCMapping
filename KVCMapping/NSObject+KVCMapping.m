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

// Public API (normalize mapping dictionary before doing anything
- (void) setKVCValues:(id)values withMappingDictionary:(NSDictionary*)mappingDict options:(NSDictionary*)options
{
    [self kvc_setValues:values
             withEntityMapping:[[KVCEntityMapping alloc] initWithMappingDictionary:mappingDict]
                                     options:options];
}

- (void) setKVCValue:(id)value forKey:(id)wantedKey withMappingDictionary:(NSDictionary*)mappingDict options:(NSDictionary*)options
{
    [self kvc_setValue:value forKey:wantedKey withEntityMapping:[[KVCEntityMapping alloc] initWithMappingDictionary:mappingDict] options:options];
}

// Set values from a dictionary or an array, using a mapping dictionary
- (void) kvc_setValues:(id)values withEntityMapping:(KVCEntityMapping*)entityMapping options:(NSDictionary*)options
{
    NSParameterAssert([values isKindOfClass:[NSDictionary class]] || [values isKindOfClass:[NSArray class]]);
    if([values isKindOfClass:[NSDictionary class]]) {
        for (NSString * wantedKey in [values allKeys]) {
            [self kvc_setValue:values[wantedKey] forKey:wantedKey withEntityMapping:entityMapping options:options];
        }
    } else if([values isKindOfClass:[NSArray class]]) {
        [values enumerateObjectsUsingBlock:^(id value, NSUInteger index, BOOL *stop) {
            [self kvc_setValue:value forKey:@(index) withEntityMapping:entityMapping options:options];
        }];
    }
}

// Set value for a wanted key, with a mapping dictionary. (maybe several mappings)
- (void) kvc_setValue:(id)value forKey:(id)wantedKey withEntityMapping:(KVCEntityMapping*)entityMapping options:(NSDictionary*)options
{
    // Find the mappings to use for this key.
    NSArray* keyMappings = entityMapping[wantedKey];
    
    for (KVCKeyMapping * keyMapping in keyMappings){
        [self kvc_setValue:value withMapping:keyMapping options:options];
    }
}

// Set value for a given mapping,
// NSObject only handles the "property" kind of mapping
- (void) kvc_setValue:(id)value withMapping:(KVCKeyMapping*)keyMapping options:(NSDictionary*)options
{
    if ([keyMapping isKindOfClass:[KVCPropertyMapping class]]) {
        KVCPropertyMapping * propertyMapping = (KVCPropertyMapping*)keyMapping;
        id transformedValue = propertyMapping.transformer ? [propertyMapping.transformer transformedValue:value] : value;
        [self kvc_setValue:transformedValue forProperty:propertyMapping.property options:options];
    }
}

// mapping to a "property"
- (void) kvc_setValue:(id)value forProperty:(NSString*)property options:(NSDictionary*)options
{
    [self setValue:value forKey:property];
}

@end

/****************************************************************************/
#pragma mark NSManagedObject

#import "NSManagedObject+Coercion.h"
#import "NSManagedObject+KVCRelationship.h"

@implementation NSManagedObject (KVCMapping)

// Set value for a given mapping,
// NSManagedObject handles the "relationship" kind of mapping as well
- (void) kvc_setValue:(id)value withMapping:(KVCKeyMapping*)keyMapping options:(NSDictionary*)options
{
    if ([keyMapping isKindOfClass:[KVCRelationshipMapping class]]) {
        KVCRelationshipMapping * relationshipMapping = (KVCRelationshipMapping *)keyMapping;
        NSParameterAssert(relationshipMapping.foreignKey || relationshipMapping.mapping);
        if(relationshipMapping.foreignKey) {
            [self setRelationship:relationshipMapping.relationship withObjectsWithValues:value forKey:relationshipMapping.foreignKey options:options];
        } else {
            [self setRelationship:relationshipMapping.relationship with:value withMapping:relationshipMapping.mapping options:options];
        }
    } else {
        [super kvc_setValue:value withMapping:keyMapping options:options];
    }
}

- (void) kvc_setValue:(id)value forProperty:(NSString*)property options:(NSDictionary*)options
{
    NSAttributeDescription * attributeDesc = [[self entity] attributesByName][property];
    if(attributeDesc) {
        // Core Data Attribute
        
        // Convert the value if necessary
        NSAttributeType attributeType = attributeDesc.attributeType;
        Class expectedClass = NSClassFromString(attributeDesc.attributeValueClassName);
        if( value && ! [value isKindOfClass:expectedClass]) {
            value = [[self class] coerceValue:value toAttributeType:attributeType];
        }
        
        [self setValue:value forKey:property];
        return;
    }
    
    // No attribute or relationship description, use regular KVC.
    [super kvc_setValue:value forProperty:property options:options];
}

@end



@implementation NSDictionary (KVCMapping)
- (id) extractValueForPrimaryKeyWithEntityMapping:(KVCEntityMapping*)entityMapping
{
    id rawValue = self[entityMapping.primaryKey];
    NSArray * mappings = [entityMapping mappingsForKey:entityMapping.primaryKey];
    return ([mappings count] && [mappings[0] transformer])? [[mappings[0] transformer] transformedValue:rawValue]: rawValue;
}
@end

@implementation NSArray (KVCMapping)
- (id) extractValueForPrimaryKeyWithEntityMapping:(KVCEntityMapping*)entityMapping
{
    id rawValue = self[[entityMapping.primaryKey unsignedIntegerValue]];
    NSArray * mappings = [entityMapping mappingsForKey:entityMapping.primaryKey];
    return ([mappings count] && [mappings[0] transformer])? [[mappings[0] transformer] transformedValue:rawValue]: rawValue;
}
@end

