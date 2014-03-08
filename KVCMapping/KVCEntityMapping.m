//
//  KVCEntityMapping.m
//  CapitaineTrain
//
//  Created by Nicolas @ Capitaine Train on 06/05/13.
//  Copyright (c) 2013 Capitaine Train. All rights reserved.
//

#import "KVCEntityMapping.h"

#pragma mark - KVCModelMapping

@implementation KVCModelMapping

- (KVCEntityMapping*) entityMappingForKey:(id)key
{
    return self.entityMappings[key];
}

- (KVCEntityMapping*) entityMappingForEntityName:(NSString*)entityName
{
    for (KVCEntityMapping * entityMapping in [self.entityMappings allValues]) {
        if ([entityMapping.entityName isEqualToString:entityName]) {
            return entityMapping;
        }
    }
    return nil;
}

- (NSArray*) keysForEntityName:(NSString*)entityName
{
    NSMutableArray * keys = [NSMutableArray new];
    for (NSString * key in self.entityMappings) {
        if ([[self.entityMappings[key] entityName] isEqualToString:entityName]) {
            [keys addObject:key];
        }
    }
    return [NSArray arrayWithArray:keys];
}

@end

#pragma mark - KVCEntityMapping

@implementation KVCEntityMapping
{
    NSDictionary * _mappingsForKey;
    NSMutableDictionary * _reverseMappingsTo;
}

- (id) initWithKeyMappings:(NSArray*)keyMappings_ primaryKey:(NSString*)primaryKey_ entityName:(NSString*)entityName_
{
    self = [super init];
    _keyMappings = keyMappings_;
    _primaryKey = primaryKey_;
    _entityName = entityName_;
    if(_primaryKey) {
        NSParameterAssert([[self mappingsTo:_primaryKey] count]>0);
    }
    
    // Group mappings by key for faster lookup
    // The resulting _mappingsForKey dictionary has the following form:
    //     @{ @"foo": @[KVCKeyMapping-to-fooProperty],
    //        @"bar": @[KVCKeyMapping-to-barProperty, KVCKeyMapping-to-denormalizedBar] }
    NSMutableDictionary * mappingsForKey = [NSMutableDictionary dictionaryWithCapacity:[_keyMappings count]];
    for (KVCKeyMapping * mapping in _keyMappings) {
        NSMutableArray * mappings = mappingsForKey[mapping.key];
        if (!mappings) {
            mappings = [NSMutableArray arrayWithCapacity:1];
            mappingsForKey[mapping.key] = mappings;
        }
        [mappings addObject:mapping];
    }
    _mappingsForKey = mappingsForKey;
    
    _reverseMappingsTo = [NSMutableDictionary new];
    
    return self;
}

- (NSArray*) mappingsForKey:(id)key
{
    return _mappingsForKey[key];
}

- (NSArray*) allKeys
{
    return [self.keyMappings valueForKey:@"key"];
}

- (NSArray*)mappingsTo:(NSString*)propertyOrRelationship
{
    NSArray * cachedMappingsTo = _reverseMappingsTo[propertyOrRelationship];
    if(cachedMappingsTo==nil) {
        NSMutableArray * mappingsTo = [NSMutableArray new];
        for (id keyMapping in self.keyMappings) {
            if( ([keyMapping respondsToSelector:@selector(property)] &&
                 [[keyMapping property] isEqualToString:propertyOrRelationship] )
               || ([keyMapping respondsToSelector:@selector(relationship)] &&
                   [[keyMapping relationship] isEqualToString:propertyOrRelationship] ) )
            {
                [mappingsTo addObject:keyMapping];
            }
        }
        cachedMappingsTo = [NSArray arrayWithArray:mappingsTo];
        _reverseMappingsTo[propertyOrRelationship] = cachedMappingsTo;
    }
    return cachedMappingsTo;
}

- (id) extractValueFor:(NSString*)propertyOrRelationship fromValues:(id)values
{
    NSArray * mappings = [self mappingsTo:propertyOrRelationship];
    if([mappings count]==0) {
        return nil;
    } else {
        id keyMapping = mappings[0];
        id key = [keyMapping key];
        id value;
        if([values isKindOfClass:[NSDictionary class]]) {
            value = values[key];
        } else if ([values isKindOfClass:[NSArray class]]) {
            value = values[[key unsignedIntegerValue]];
        }
        if([keyMapping respondsToSelector:@selector(transformer)] && [keyMapping transformer]) {
            value = [[keyMapping transformer] transformedValue:value];
        }
        return value;
    }
}

@end
