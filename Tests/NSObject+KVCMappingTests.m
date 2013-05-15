//
//  NSObject+KVCMapping_Tests.m
//  KVCMapping
//
//  Created by Nicolas Bouilleaud on 27/11/11.
//  Copyright (c) 2011 Nicolas Bouilleaud. All rights reserved.
//
#import <SenTestingKit/SenTestingKit.h>
#import "KVCMapping.h"

#pragma mark Forward Declarations

@interface UppercaseTransformer : NSValueTransformer
@end
@interface LowercaseTransformer : NSValueTransformer
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

@interface NSObject_KVCMapping_Tests : SenTestCase
@end

@implementation NSObject_KVCMapping_Tests

- (void) testBasic
{
    TestClass * test = [TestClass new];

    [test setKVCValue:@"testValue" forKey:@"usedProperty" withMappingDictionary:@{@"usedProperty": @"actualProperty1"} options:nil ];

    STAssertThrows([test valueForKey:@"usedName"], nil);
    STAssertEqualObjects([test valueForKey:@"actualProperty1"], @"testValue", nil);
}

- (void) testMultipleKey
{
    TestClass * test = [TestClass new];
    
    [test setKVCValues:@{@"usedProperty1" : @"testValue1", @"usedProperty2" : @"testValue2"}
 withMappingDictionary:@{@"usedProperty1": @"actualProperty1", @"usedProperty2": @"actualProperty2"}
               options:nil];
    
    STAssertEqualObjects([test valueForKey:@"actualProperty1"], @"testValue1", nil);
    STAssertEqualObjects([test valueForKey:@"actualProperty2"], @"testValue2", nil);
}

- (void) testValuesFromArray
{
    TestClass * test = [TestClass new];
    
    [test setKVCValues:@[@"testValue1", @"testValue2"]
 withMappingDictionary:@{@0: @"actualProperty1", @1: @"actualProperty2"}
               options:nil];
    
    STAssertEqualObjects([test valueForKey:@"actualProperty1"], @"testValue1", nil);
    STAssertEqualObjects([test valueForKey:@"actualProperty2"], @"testValue2", nil);
}

- (void) testCompositeValue
{
    TestClass * test = [TestClass new];

    [test setKVCValue:@"testValue" forKey:@"usedProperty" withMappingDictionary:@{@"usedProperty": @[@"actualProperty1",@"actualProperty2"]} options:nil];

    STAssertEqualObjects([test valueForKey:@"actualProperty1"], @"testValue", nil);
    STAssertEqualObjects([test valueForKey:@"actualProperty2"], @"testValue", nil);
}

- (void) testKVCSimpleValueTransformer
{
    [NSValueTransformer setValueTransformer:[UppercaseTransformer new] forName:@"uppercase"];
    TestClass * test = [TestClass new];

    [test setKVCValue:@"testValue" forKey:@"usedProperty" withMappingDictionary:@{@"usedProperty": @"uppercase:actualProperty1"} options:nil];

    STAssertEqualObjects([test valueForKey:@"actualProperty1"], @"TESTVALUE", nil);
}

- (void) testCompositeValueTransformer
{
    [NSValueTransformer setValueTransformer:[UppercaseTransformer new] forName:@"uppercase"];
    [NSValueTransformer setValueTransformer:[LowercaseTransformer new] forName:@"lowercase"];
    TestClass * test = [TestClass new];
    
    [test setKVCValue:@"testValue" forKey:@"usedProperty" withMappingDictionary:
     @{@"usedProperty": @[@"uppercase:actualProperty1",
     @"lowercase:actualProperty2"]}  options:nil];
    
    STAssertEqualObjects([test valueForKey:@"actualProperty1"], @"TESTVALUE", nil);
    STAssertEqualObjects([test valueForKey:@"actualProperty2"], @"testvalue", nil);
}

@end

#pragma mark -

@implementation UppercaseTransformer
+ (Class) transformedValueClass; { return [NSString class]; }
- (id) transformedValue:(id)value { return [value uppercaseString]; }
@end

@implementation LowercaseTransformer
+ (Class) transformedValueClass; { return [NSString class]; }
- (id) transformedValue:(id)value { return [value lowercaseString]; }
@end
