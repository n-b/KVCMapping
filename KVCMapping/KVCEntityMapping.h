//
//  KVCEntityMapping.h
//  CapitaineTrain
//
//  Created by Nicolas @ Capitaine Train on 06/05/13.
//  Copyright (c) 2013 Capitaine Train. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KVCEntityMapping : NSObject

// Factory
- (id) initWithMappingDictionary:(NSDictionary*)mappingDictionary;

//
@property (readonly) id primaryKey;
- (NSArray*)mappingsForKey:(id)key;
- (id)keyMappedTo:(NSString*)property;

- (NSArray*)objectForKeyedSubscript:(id)key;
@end

#pragma mark - KVCKeyMapping

@interface KVCKeyMapping : NSObject
@end

#pragma mark - KVCPropertyMapping

@interface KVCPropertyMapping : KVCKeyMapping
@property (readonly) NSString * property;
@property (readonly) NSValueTransformer * transformer;
@end

#pragma mark - KVCRelationshipMapping

@interface KVCRelationshipMapping : KVCKeyMapping
@property (readonly) NSString * relationship;
@property (readonly) NSString * foreignKey;
@property (readonly) KVCEntityMapping * mapping;
@end

extern NSString * const KVCMapTransformerSeparator; // @":"
extern NSString * const KVCMapRelationshipSeparator; // @"."
