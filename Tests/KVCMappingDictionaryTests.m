//
//  KVCEntityMappingTests.m
//  KVCMapping
//
//  Created by Nicolas Bouilleaud on 13/05/13.
//  Copyright (c) 2011 Nicolas Bouilleaud. All rights reserved.
//
#import <SenTestingKit/SenTestingKit.h>
#import "KVCMapping.h"

@interface KVCEntityMappingTests : SenTestCase
@end

@implementation KVCEntityMappingTests

- (void) testParseMappingDictionarySimple
{
    // Given
    id mappingDictionary = @{ @"id" : @"identifier",
                              @"first_name" : @"firstName",
                              @"last_name" : @"lastName" };

    // When
    id entitymapping = [[KVCEntityMapping alloc] initWithMappingDictionary:mappingDictionary primaryKey:@"identifier" entityName:nil];
    
    // Assert
    STAssertEquals([[entitymapping mappingsForKey:@"id"] count], (NSUInteger)1, @"There should be one key mapping");
    STAssertEqualObjects([entitymapping primaryKey], @"identifier", @"Primary key not set");
    STAssertEqualObjects([[entitymapping mappingsForKey:@"id"][0] property] , @"identifier", @"Key Mapping property not set");
    STAssertEqualObjects([[entitymapping mappingsForKey:@"first_name"][0] property] , @"firstName", @"Key Mapping property not set");
    STAssertEqualObjects([[entitymapping mappingsForKey:@"last_name"][0] property] , @"lastName", @"Key Mapping property not set");
    STAssertNil([entitymapping mappingsForKey:@"unknown_key"], @"The mapping for an unmapped key must be nil");
}

- (void) testParseMappingDictionaryMultipleMapping
{
    // Given
    id mappingDictionary = @{ @"modified_at" : @[@"openDate",@"updateDate"] };

    // When
    id entitymapping = [[KVCEntityMapping alloc] initWithMappingDictionary:mappingDictionary primaryKey:nil entityName:nil];
    
    // Assert
    STAssertEquals(([[entitymapping mappingsForKey:@"modified_at"] count]), (NSUInteger)2,  @"There should be two key mappings");
    STAssertEqualObjects([[entitymapping mappingsForKey:@"modified_at"][0] property] , @"openDate", @"Key Mapping property not set");
    STAssertEqualObjects([[entitymapping mappingsForKey:@"modified_at"][1] property] , @"updateDate", @"Key Mapping property not set");
}

- (void) testParseMappingDictionaryWithTransformers
{
    // Given
    NSValueTransformer * fakeTransformer = [NSValueTransformer new];
    [NSValueTransformer setValueTransformer:fakeTransformer forName:@"fake"];
    id mappingDictionary = @{ @"somekey" : @"fake:someproperty" };

    // When
    id entitymapping = [[KVCEntityMapping alloc] initWithMappingDictionary:mappingDictionary primaryKey:nil entityName:nil];
    
    // Assert
    STAssertEqualObjects([[entitymapping mappingsForKey:@"somekey"][0] property] , @"someproperty", @"Key Mapping property not set");
    STAssertEqualObjects([[entitymapping mappingsForKey:@"somekey"][0] transformer] , fakeTransformer, @"Key Mapping transformer not set");
}

- (void) testParseMappingDictionaryWithRelationship
{
    // Given
    id mappingDictionary =  @{ @"partner": @"partner.identifier" };

    // When
    id entitymapping = [[KVCEntityMapping alloc] initWithMappingDictionary:mappingDictionary primaryKey:nil entityName:nil];
    
    // Assert
    STAssertEqualObjects([[entitymapping mappingsForKey:@"partner"][0] relationship] , @"partner", @"Relationship Mapping relationship not set");
    STAssertEqualObjects([[entitymapping mappingsForKey:@"partner"][0] foreignKey] , @"identifier", @"Relationship Mapping foreign key not set");
}

- (void) testParseMappingDictionaryWithSubobject
{
    // Given
    id mappingDictionary =  @{ @"partner": @{ @"partner.identifier": @{@"id": @"identifier",
                                                                       @"partner_name" : @"name" }
                                              }
                               };
    
    // When
    id entitymapping = [[KVCEntityMapping alloc] initWithMappingDictionary:mappingDictionary primaryKey:nil entityName:nil];
    
    // Assert
    STAssertEqualObjects([[entitymapping mappingsForKey:@"partner"][0] relationship] , @"partner", @"Subobject Mapping relationship not set");
    id submapping = [[entitymapping mappingsForKey:@"partner"][0] mapping];
    STAssertEqualObjects([submapping primaryKey] , @"identifier", @"Subobject submapping primary key not set");
    STAssertEqualObjects([[submapping mappingsForKey:@"partner_name"][0] property] , @"name", @"Subobject submapping primary key not set");
}


- (void) testParseSimpleModelDictionary
{
    // Given
    id mappingDictionary = @{ @"user" : @{@"User" :  @{ @"first_name" : @"firstName",
                                                        @"last_name" : @"lastName" } } };
    
    // When
    id modelmapping = [[KVCModelMapping alloc] initWithMappingDictionary:mappingDictionary];
    
    // Assert
    id entityMapping = [modelmapping entityMappingForKey:@"user"];
    STAssertNotNil(entityMapping, @"Entity Mapping should be created");
    STAssertEqualObjects([entityMapping entityName], @"User", @"Entity Mapping entity name not  set");
    STAssertNil([entityMapping primaryKey], @"Entity Mapping primary Key should be nil");
    STAssertEquals([[entityMapping mappingsForKey:@"first_name"] count], (NSUInteger)1, @"Key Mapping should be created");
}

- (void) testParseComplexModelDictionary
{
    // Given
    id mappingDictionary = @{ @[@"user",@"users"] : @{@"User.identifier" :  @{ @"id": @"identifier",
                                                                  @"first_name" : @"firstName",
                                                                  @"last_name" : @"lastName" } } };
    
    // When
    id modelmapping = [[KVCModelMapping alloc] initWithMappingDictionary:mappingDictionary];
    
    // Assert
    STAssertEqualObjects([modelmapping entityMappingForKey:@"user"], [modelmapping entityMappingForKey:@"users"], @"The same Entity Mapping should be set for both keys.");
    STAssertNotNil([[modelmapping entityMappingForKey:@"user"] primaryKey], @"Entity Mapping primary Key should not be nil");
}

@end
