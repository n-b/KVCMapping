//
//  KVCEntityMappingTests.m
//  KVCMapping
//
//  Created by Nicolas Bouilleaud on 13/05/13.
//  Copyright (c) 2011 Nicolas Bouilleaud. All rights reserved.
//
#import <XCTest/XCTest.h>
#import "KVCMapping.h"

@interface KVCEntityMappingTests : XCTestCase
@end

@implementation KVCEntityMappingTests

- (void)testParseMappingDictionarySimple
{
    // Given
    id mappingDictionary = @{ @"id" : @"identifier",
                              @"first_name" : @"firstName",
                              @"last_name" : @"lastName" };

    // When
    id entitymapping = [[KVCEntityMapping alloc] initWithMappingDictionary:mappingDictionary primaryKey:@"identifier" entityName:nil];
    
    // Assert
    XCTAssertEqual([[entitymapping mappingsForKey:@"id"] count], (NSUInteger)1, @"There should be one key mapping");
    XCTAssertEqualObjects([entitymapping primaryKey], @"identifier", @"Primary key not set");
    XCTAssertEqualObjects([[entitymapping mappingsForKey:@"id"][0] property] , @"identifier", @"Key Mapping property not set");
    XCTAssertEqualObjects([[entitymapping mappingsForKey:@"first_name"][0] property] , @"firstName", @"Key Mapping property not set");
    XCTAssertEqualObjects([[entitymapping mappingsForKey:@"last_name"][0] property] , @"lastName", @"Key Mapping property not set");
    XCTAssertNil([entitymapping mappingsForKey:@"unknown_key"], @"The mapping for an unmapped key must be nil");
}

- (void)testParseMappingDictionaryMultipleMapping
{
    // Given
    id mappingDictionary = @{ @"modified_at" : @[@"openDate",@"updateDate"] };

    // When
    id entitymapping = [[KVCEntityMapping alloc] initWithMappingDictionary:mappingDictionary primaryKey:nil entityName:nil];
    
    // Assert
    XCTAssertEqual(([[entitymapping mappingsForKey:@"modified_at"] count]), (NSUInteger)2,  @"There should be two key mappings");
    XCTAssertEqualObjects([[entitymapping mappingsForKey:@"modified_at"][0] property] , @"openDate", @"Key Mapping property not set");
    XCTAssertEqualObjects([[entitymapping mappingsForKey:@"modified_at"][1] property] , @"updateDate", @"Key Mapping property not set");
}

- (void)testParseMappingDictionaryWithTransformers
{
    // Given
    NSValueTransformer * fakeTransformer = NSValueTransformer.new;
    [NSValueTransformer setValueTransformer:fakeTransformer forName:@"fake"];
    id mappingDictionary = @{ @"somekey" : @"fake:someproperty" };

    // When
    id entitymapping = [[KVCEntityMapping alloc] initWithMappingDictionary:mappingDictionary primaryKey:nil entityName:nil];
    
    // Assert
    XCTAssertEqualObjects([[entitymapping mappingsForKey:@"somekey"][0] property] , @"someproperty", @"Key Mapping property not set");
    XCTAssertEqualObjects([[entitymapping mappingsForKey:@"somekey"][0] transformer] , fakeTransformer, @"Key Mapping transformer not set");
}

- (void)testParseMappingDictionaryWithRelationship
{
    // Given
    id mappingDictionary =  @{ @"partner": @"partner.identifier" };

    // When
    id entitymapping = [[KVCEntityMapping alloc] initWithMappingDictionary:mappingDictionary primaryKey:nil entityName:nil];
    
    // Assert
    XCTAssertEqualObjects([[entitymapping mappingsForKey:@"partner"][0] relationship] , @"partner", @"Relationship Mapping relationship not set");
    XCTAssertEqualObjects([[entitymapping mappingsForKey:@"partner"][0] foreignKey] , @"identifier", @"Relationship Mapping foreign key not set");
}

- (void)testParseMappingDictionaryWithSubobject
{
    // Given
    id mappingDictionary =  @{ @"partner": @{ @"partner.identifier": @{@"id": @"identifier",
                                                                       @"partner_name" : @"name" }
                                              }
                               };
    
    // When
    id entitymapping = [[KVCEntityMapping alloc] initWithMappingDictionary:mappingDictionary primaryKey:nil entityName:nil];
    
    // Assert
    XCTAssertEqualObjects([[entitymapping mappingsForKey:@"partner"][0] relationship] , @"partner", @"Subobject Mapping relationship not set");
    id submapping = [[entitymapping mappingsForKey:@"partner"][0] mapping];
    XCTAssertEqualObjects([submapping primaryKey] , @"identifier", @"Subobject submapping primary key not set");
    XCTAssertEqualObjects([[submapping mappingsForKey:@"partner_name"][0] property] , @"name", @"Subobject submapping primary key not set");
}


- (void)testParseSimpleModelDictionary
{
    // Given
    id mappingDictionary = @{ @"user" : @{@"User" :  @{ @"first_name" : @"firstName",
                                                        @"last_name" : @"lastName" } } };
    
    // When
    id modelmapping = [[KVCModelMapping alloc] initWithMappingDictionary:mappingDictionary];
    
    // Assert
    id entityMapping = [modelmapping entityMappingForKey:@"user"];
    XCTAssertNotNil(entityMapping, @"Entity Mapping should be created");
    XCTAssertEqualObjects([entityMapping entityName], @"User", @"Entity Mapping entity name not  set");
    XCTAssertNil([entityMapping primaryKey], @"Entity Mapping primary Key should be nil");
    XCTAssertEqual([[entityMapping mappingsForKey:@"first_name"] count], (NSUInteger)1, @"Key Mapping should be created");
}

- (void)testParseComplexModelDictionary
{
    // Given
    id mappingDictionary = @{ @[@"user",@"users"] : @{@"User.identifier" :  @{ @"id": @"identifier",
                                                                  @"first_name" : @"firstName",
                                                                  @"last_name" : @"lastName" } } };
    
    // When
    id modelmapping = [[KVCModelMapping alloc] initWithMappingDictionary:mappingDictionary];
    
    // Assert
    XCTAssertEqualObjects([modelmapping entityMappingForKey:@"user"], [modelmapping entityMappingForKey:@"users"], @"The same Entity Mapping should be set for both keys.");
    XCTAssertNotNil([[modelmapping entityMappingForKey:@"user"] primaryKey], @"Entity Mapping primary Key should not be nil");
}

@end
