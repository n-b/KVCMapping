//
//  NSObject+KVCMapping_Tests.m
//  KVCMapping
//
//  Created by Nicolas Bouilleaud on 27/11/11.
//  Copyright (c) 2011 Nicolas Bouilleaud. All rights reserved.
//
#import <XCTest/XCTest.h>
#import "KVCMapping.h"

#pragma mark Forward Declarations

@interface UppercaseTransformer : NSValueTransformer
@end
@interface LowercaseTransformer : NSValueTransformer
@end
@interface OppositeNumberTransformer : NSValueTransformer
@end

#pragma mark Test class

@interface TestClass : NSObject
@property id actualProperty1;
@property id actualProperty2;
@end

@implementation TestClass
@end

/****************************************************************************/
#pragma mark Basic Tests

@interface NSObject_KVCMapping_Tests : XCTestCase
@end

@implementation NSObject_KVCMapping_Tests

- (void) testBasic
{
    TestClass * test = [TestClass new];

    [test kvc_setValue:@"testValue" forKey:@"usedProperty" withMappingDictionary:@{@"usedProperty": @"actualProperty1"} options:nil ];

    XCTAssertThrows([test valueForKey:@"usedName"]);
    XCTAssertEqualObjects([test valueForKey:@"actualProperty1"], @"testValue");
}

- (void) testMultipleKey
{
    TestClass * test = [TestClass new];
    
    [test kvc_setValues:@{@"usedProperty1" : @"testValue1", @"usedProperty2" : @"testValue2"}
 withMappingDictionary:@{@"usedProperty1": @"actualProperty1", @"usedProperty2": @"actualProperty2"}
               options:nil];
    
    XCTAssertEqualObjects([test valueForKey:@"actualProperty1"], @"testValue1");
    XCTAssertEqualObjects([test valueForKey:@"actualProperty2"], @"testValue2");
}

- (void) testValuesFromArray
{
    TestClass * test = [TestClass new];
    
    [test kvc_setValues:@[@"testValue1", @"testValue2"]
 withMappingDictionary:@{@0: @"actualProperty1", @1: @"actualProperty2"}
               options:nil];
    
    XCTAssertEqualObjects([test valueForKey:@"actualProperty1"], @"testValue1");
    XCTAssertEqualObjects([test valueForKey:@"actualProperty2"], @"testValue2");
}

- (void) testCompositeValue
{
    TestClass * test = [TestClass new];

    [test kvc_setValue:@"testValue" forKey:@"usedProperty" withMappingDictionary:@{@"usedProperty": @[@"actualProperty1",@"actualProperty2"]} options:nil];

    XCTAssertEqualObjects([test valueForKey:@"actualProperty1"], @"testValue");
    XCTAssertEqualObjects([test valueForKey:@"actualProperty2"], @"testValue");
}

- (void) testKVCSimpleValueTransformer
{
    [NSValueTransformer setValueTransformer:[UppercaseTransformer new] forName:@"uppercase"];
    TestClass * test = [TestClass new];

    [test kvc_setValue:@"testValue" forKey:@"usedProperty" withMappingDictionary:@{@"usedProperty": @"uppercase:actualProperty1"} options:nil];

    XCTAssertEqualObjects([test valueForKey:@"actualProperty1"], @"TESTVALUE");
}

- (void) testCompositeValueTransformer
{
    [NSValueTransformer setValueTransformer:[UppercaseTransformer new] forName:@"uppercase"];
    [NSValueTransformer setValueTransformer:[LowercaseTransformer new] forName:@"lowercase"];
    TestClass * test = [TestClass new];
    
    [test kvc_setValue:@"testValue" forKey:@"usedProperty" withMappingDictionary:
     @{@"usedProperty": @[@"uppercase:actualProperty1",
     @"lowercase:actualProperty2"]}  options:nil];
    
    XCTAssertEqualObjects([test valueForKey:@"actualProperty1"], @"TESTVALUE");
    XCTAssertEqualObjects([test valueForKey:@"actualProperty2"], @"testvalue");
}

@end

#pragma mark -

@implementation UppercaseTransformer
+ (BOOL)allowsReverseTransformation { return NO; }
+ (Class) transformedValueClass; { return [NSString class]; }
- (id) transformedValue:(id)value { return [value uppercaseString]; }
@end

@implementation LowercaseTransformer
+ (BOOL)allowsReverseTransformation { return NO; }
+ (Class) transformedValueClass; { return [NSString class]; }
- (id) transformedValue:(id)value { return [value lowercaseString]; }
@end

@implementation OppositeNumberTransformer
+ (BOOL)allowsReverseTransformation { return YES; }
+ (Class) transformedValueClass; { return [NSNumber class]; }
- (id) transformedValue:(id)value { return value ? @(-[value doubleValue]) : nil; }
@end

/****************************************************************************/
#pragma mark Reverse Mapping Tests

@interface NSObject_KVCReverseMapping_Tests : XCTestCase
@end

@implementation NSObject_KVCReverseMapping_Tests

- (void) testBasic
{
    TestClass * test = [TestClass new];
    test.actualProperty1 = @"testValue1";

    id value = [test kvc_valueForKey:@"usedProperty" withMappingDictionary:@{@"usedProperty": @"actualProperty1"} options:nil];
    
    XCTAssertEqualObjects(value, @"testValue1");
}

- (void) testMultipleKey
{
    TestClass * test = [TestClass new];
    test.actualProperty1 = @"testValue1";
    test.actualProperty2 = @"testValue2";
    
    id values = [test kvc_valuesWithMappingDictionary:@{@"usedProperty1": @"actualProperty1", @"usedProperty2": @"actualProperty2"}
                                              options:nil];
    
    XCTAssertEqualObjects(values[@"usedProperty1"], @"testValue1");
    XCTAssertEqualObjects(values[@"usedProperty2"], @"testValue2");
}

- (void) testNilValues
{
    TestClass * test = [TestClass new];
    test.actualProperty1 = nil;
    
    id values = [test kvc_valuesWithMappingDictionary:@{@"usedProperty1": @"actualProperty1"}
                                              options:nil];
    
    XCTAssertEqualObjects(values[@"usedProperty1"], [NSNull null]);
}

- (void) testValuesFromArray
{
    TestClass * test = [TestClass new];
    test.actualProperty1 = @"testValue1";
    test.actualProperty2 = @"testValue2";

    id values = [test kvc_valuesWithMappingDictionary:@{@0: @"actualProperty1", @1: @"actualProperty2"}
                                              options:nil];
    
    XCTAssertEqualObjects(values[0], @"testValue1");
    XCTAssertEqualObjects(values[1], @"testValue2");
}

- (void) testCompositeValue
{
    TestClass * test = [TestClass new];
    test.actualProperty1 = @"testValue1";
    test.actualProperty2 = @"testValue2";

    id value = [test kvc_valueForKey:@"usedProperty" withMappingDictionary:@{@"usedProperty": @[@"actualProperty1",@"actualProperty2"]} options:nil];
    
    XCTAssertEqualObjects(value, @"testValue1");
}

- (void) testUnsupportedValueTransformer
{
    [NSValueTransformer setValueTransformer:[UppercaseTransformer new] forName:@"uppercase"];
    TestClass * test = [TestClass new];
    test.actualProperty1 = @"testValue1";
    
    id value = [test kvc_valueForKey:@"usedProperty" withMappingDictionary:@{@"usedProperty": @"uppercase:actualProperty1"} options:nil];
    
    XCTAssertNil(value);
}

- (void) testSupportedValueTransformer
{
    [NSValueTransformer setValueTransformer:[OppositeNumberTransformer new] forName:@"opposite"];
    TestClass * test = [TestClass new];
    test.actualProperty1 = @123;
    
    id value = [test kvc_valueForKey:@"usedProperty" withMappingDictionary:@{@"usedProperty": @"opposite:actualProperty1"} options:nil];
    
    XCTAssertEqualObjects(value, @(-123));
}

- (void) testSupportedValueTransformerWithNilValue
{
    [NSValueTransformer setValueTransformer:[OppositeNumberTransformer new] forName:@"opposite"];
    TestClass * test = [TestClass new];
    test.actualProperty1 = nil;
    
    id value = [test kvc_valueForKey:@"usedProperty" withMappingDictionary:@{@"usedProperty": @"opposite:actualProperty1"} options:nil];
    
    XCTAssertEqualObjects(value, [NSNull null]);
}

@end