//
//  KVCEntityMapping.m
//  CapitaineTrain
//
//  Created by Nicolas @ Capitaine Train on 06/05/13.
//  Copyright (c) 2013 Capitaine Train. All rights reserved.
//

#import "KVCEntityMapping.h"
#import "NSManagedObject+KVCFetching.h"

#pragma mark - Private Methods

@interface KVCEntityMapping ()
@property id primaryKey;
@property NSDictionary * keysMappings;
@end

@interface KVCPropertyMapping ()
@property NSString * property;
@property NSValueTransformer * transformer;
@end

@interface KVCRelationshipMapping ()
@property NSString * relationship;
@property NSString * foreignKey;
@property KVCEntityMapping * mapping;
@end

#pragma mark - Implementations

@implementation KVCKeyMapping
@end

@implementation KVCPropertyMapping
@end

@implementation KVCRelationshipMapping
@end

NSString * const KVCMapTransformerSeparator = @":";
NSString * const KVCMapRelationshipSeparator = @".";

@implementation KVCEntityMapping

#pragma mark - Entity Mapping Factory

- (id)initWithMappingDictionary:(NSDictionary *)mappingDictionary
{
    self = [super init];
    if (self) {
        id primaryKey_ = mappingDictionary[KVCPrimaryKey];
        NSDictionary * rawEntityMapping_ = mappingDictionary[KVCMapping] ?: mappingDictionary;
        
        NSMutableDictionary * keysMappings = [NSMutableDictionary new];
        // For each key
        for (NSString* key_ in rawEntityMapping_) {
            NSMutableArray * keyMappings = [NSMutableArray new];
            id rawMappings_ = rawEntityMapping_[key_];
            if(![rawMappings_ isKindOfClass:[NSArray class]]) {
                rawMappings_ = @[rawMappings_];
            }
            // For each mapping
            for (id rawMapping_ in rawMappings_) {
                if([rawMapping_ isKindOfClass:[KVCKeyMapping class]]) {
                    [keyMappings addObject:rawMapping_];
                } else {
                    NSParameterAssert([rawMapping_ isKindOfClass:[NSString class]] || [rawMapping_ isKindOfClass:[NSDictionary class]]);
                    
                    if([rawMapping_ isKindOfClass:[NSString class]]) {
                        // Parse raw mapping string
                        NSArray * components;
                        
                        // relationship
                        components = [rawMapping_ componentsSeparatedByString:KVCMapRelationshipSeparator];
                        if([components count]==2) {
                            KVCRelationshipMapping * relationshipMapping = [KVCRelationshipMapping new];
                            relationshipMapping.relationship = components[0];
                            relationshipMapping.foreignKey = components[1];
                            [keyMappings addObject:relationshipMapping];
                            continue;
                        }
                        
                        // transformed property
                        components = [rawMapping_ componentsSeparatedByString:KVCMapTransformerSeparator];
                        if([components count]==2) {
                            NSValueTransformer * transformer = [NSValueTransformer valueTransformerForName:components[0]];
                            NSParameterAssert(transformer);
                            KVCPropertyMapping * propertyMapping = [KVCPropertyMapping new];
                            propertyMapping.property = components[1];
                            propertyMapping.transformer = transformer;
                            [keyMappings addObject:propertyMapping];
                            continue;
                        }
                        
                        // direct property
                        {
                            KVCPropertyMapping * propertyMapping = [KVCPropertyMapping new];
                            propertyMapping.property = rawMapping_;
                            [keyMappings addObject:propertyMapping];
                        }
                    } else {
                        // sub-object
                        // key:relationship, value: mapping dictionary
                        NSParameterAssert([rawMapping_ count]==1);
                        NSString * relationship = [[rawMapping_ allKeys] lastObject];
                        NSDictionary * submappingDictionary = [[rawMapping_ allValues] lastObject];
                        KVCRelationshipMapping * relationshipMapping = [KVCRelationshipMapping new];
                        relationshipMapping.relationship = relationship;
                        relationshipMapping.mapping = [[KVCEntityMapping alloc] initWithMappingDictionary:submappingDictionary];
                        [keyMappings addObject:relationshipMapping];
                    }
                }
            }
            keysMappings[key_] = [NSArray arrayWithArray:keyMappings];
        }
        self.keysMappings = [NSDictionary dictionaryWithDictionary:keysMappings];
        self.primaryKey = primaryKey_;
        return self;
    }
    return self;
}

- (NSArray*)objectForKeyedSubscript:(id)key
{
    return [self mappingsForKey:key];
}

- (NSArray*) mappingsForKey:(id)key
{
    return self.keysMappings[key];
}

- (id)keyMappedTo:(NSString*)property
{
    for (id key in self.keysMappings) {
        NSArray* keyMappings = self.keysMappings[key];
        for (KVCKeyMapping * keyMapping in keyMappings) {
            if([keyMapping isKindOfClass:[KVCPropertyMapping class]] &&
               [((KVCPropertyMapping*)keyMapping).property isEqualToString:property])
                return key;
        }
    }
    return nil;
}

@end
