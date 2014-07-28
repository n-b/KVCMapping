//
//  NSObject+KVCMapping_Tests.m
//  KVCMapping
//
//  Created by Nicolas Bouilleaud on 27/11/11.
//  Copyright (c) 2011 Nicolas Bouilleaud. All rights reserved.
//
#import <XCTest/XCTest.h>
#import "NSAttributeDescription+Coercion.h"

#pragma mark Coercion Tests

@interface NSManagedObject_KVCMappingCoercion_Tests : XCTestCase
@end

@implementation NSManagedObject_KVCMappingCoercion_Tests

- (id) coerceValue:(id)value toAttributeType:(NSAttributeType)attributeType
{
    NSAttributeDescription * attributeDesc = [NSAttributeDescription new];
    attributeDesc.attributeType = attributeType;
    return [attributeDesc kvc_coerceValue:value];
}

- (void) testCoercionToNumber
{
    // From proper strings
    XCTAssertEqualObjects([self coerceValue:@"1234" toAttributeType:NSInteger16AttributeType],@1234);
    XCTAssertEqualObjects([self coerceValue:@"1234" toAttributeType:NSInteger32AttributeType],@1234);
    XCTAssertEqualObjects([self coerceValue:@"1234" toAttributeType:NSInteger16AttributeType],@1234);
    XCTAssertEqualObjects([self coerceValue:@"1234" toAttributeType:NSInteger64AttributeType],@1234);

    XCTAssertEqualObjects([self coerceValue:@"12.3456789" toAttributeType:NSDecimalAttributeType],[NSDecimalNumber decimalNumberWithString:@"12.3456789"]);
    XCTAssertEqualObjects([self coerceValue:@"12.34" toAttributeType:NSDoubleAttributeType],@12.34);
    XCTAssertEqualObjects([self coerceValue:@"12.34" toAttributeType:NSFloatAttributeType],@(12.34f));

    // From garbage strings
    XCTAssertEqualObjects([self coerceValue:@"toto" toAttributeType:NSInteger16AttributeType],@0);
    XCTAssertEqualObjects([self coerceValue:@"toto" toAttributeType:NSInteger32AttributeType],@0);
    XCTAssertEqualObjects([self coerceValue:@"toto" toAttributeType:NSInteger16AttributeType],@0);
    XCTAssertEqualObjects([self coerceValue:@"toto" toAttributeType:NSInteger64AttributeType],@0);
    
    XCTAssertEqualObjects([self coerceValue:@"toto" toAttributeType:NSDecimalAttributeType],[NSDecimalNumber notANumber]);
    XCTAssertEqualObjects([self coerceValue:@"toto" toAttributeType:NSDoubleAttributeType],@0);
    XCTAssertEqualObjects([self coerceValue:@"toto" toAttributeType:NSFloatAttributeType],@0);

    // From numbers
    XCTAssertEqualObjects([self coerceValue:@1234 toAttributeType:NSInteger16AttributeType],@1234);
    XCTAssertEqualObjects([self coerceValue:@1234 toAttributeType:NSInteger32AttributeType],@1234);
    XCTAssertEqualObjects([self coerceValue:@1234 toAttributeType:NSInteger16AttributeType],@1234);
    XCTAssertEqualObjects([self coerceValue:@1234 toAttributeType:NSInteger64AttributeType],@1234);
    
    XCTAssertEqualObjects([self coerceValue:@12.3456789 toAttributeType:NSDecimalAttributeType],[NSDecimalNumber decimalNumberWithString:@"12.3456789"]);
    XCTAssertEqualObjects([self coerceValue:@12.34 toAttributeType:NSDoubleAttributeType],@12.34);
    XCTAssertEqualObjects([self coerceValue:@(12.34f) toAttributeType:NSFloatAttributeType],@(12.34f));
    
    // From nil
    XCTAssertEqualObjects([self coerceValue:nil toAttributeType:NSInteger16AttributeType],nil);
    XCTAssertEqualObjects([self coerceValue:nil toAttributeType:NSInteger32AttributeType],nil);
    XCTAssertEqualObjects([self coerceValue:nil toAttributeType:NSInteger16AttributeType],nil);
    XCTAssertEqualObjects([self coerceValue:nil toAttributeType:NSInteger64AttributeType],nil);
    
    XCTAssertEqualObjects([self coerceValue:nil toAttributeType:NSDecimalAttributeType],nil);
    XCTAssertEqualObjects([self coerceValue:nil toAttributeType:NSDoubleAttributeType],nil);
    XCTAssertEqualObjects([self coerceValue:nil toAttributeType:NSFloatAttributeType],nil);
    
    // From garbage data
    id value = [NSData dataWithBytes:"bla" length:4];
    XCTAssertEqualObjects([self coerceValue:value toAttributeType:NSInteger16AttributeType],nil);
    XCTAssertEqualObjects([self coerceValue:value toAttributeType:NSInteger32AttributeType],nil);
    XCTAssertEqualObjects([self coerceValue:value toAttributeType:NSInteger16AttributeType],nil);
    XCTAssertEqualObjects([self coerceValue:value toAttributeType:NSInteger64AttributeType],nil);
    
    XCTAssertEqualObjects([self coerceValue:value toAttributeType:NSDecimalAttributeType],nil);
    XCTAssertEqualObjects([self coerceValue:value toAttributeType:NSDoubleAttributeType],nil);
    XCTAssertEqualObjects([self coerceValue:value toAttributeType:NSFloatAttributeType],nil);
}

- (void) testCoercionToString
{
    XCTAssertEqualObjects([self coerceValue:@"abcd" toAttributeType:NSStringAttributeType],@"abcd");
    XCTAssertEqualObjects([self coerceValue:@1234 toAttributeType:NSStringAttributeType],@"1234");
    XCTAssertEqualObjects([self coerceValue:@12.34 toAttributeType:NSStringAttributeType],@"12.34");
}

- (void) testCoercionToBool
{
    XCTAssertEqualObjects([self coerceValue:@YES toAttributeType:NSBooleanAttributeType],@YES);
    XCTAssertEqualObjects([self coerceValue:@"true" toAttributeType:NSBooleanAttributeType],@YES);
    XCTAssertEqualObjects([self coerceValue:@"false" toAttributeType:NSBooleanAttributeType],@NO);
    XCTAssertEqualObjects([self coerceValue:@"abcd" toAttributeType:NSBooleanAttributeType],@NO);
}

- (void) testCoercionToDate
{
    NSDate * date = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
    XCTAssertEqualObjects([self coerceValue:date toAttributeType:NSDateAttributeType],date);
    XCTAssertEqualObjects([self coerceValue:@"abcd" toAttributeType:NSDateAttributeType],nil);
}

- (void) testCoercionToData
{
    NSData * data = [NSData dataWithBytes:"abcd" length:5];
    XCTAssertEqualObjects([self coerceValue:data toAttributeType:NSBinaryDataAttributeType],data);
    XCTAssertEqualObjects([self coerceValue:@"abcd" toAttributeType:NSBinaryDataAttributeType],nil);
}

- (void) testCoercionToOtherTypes
{
    // Passed-through
    id value = [NSObject new];
    XCTAssertEqualObjects([self coerceValue:value toAttributeType:NSUndefinedAttributeType],value);
    XCTAssertEqualObjects([self coerceValue:value toAttributeType:NSTransformableAttributeType],value);
}

- (void) testFixNumberType
{
    NSAttributeDescription * attributeDesc = [NSAttributeDescription new];
    attributeDesc.attributeType = NSBooleanAttributeType;
    XCTAssertEqual(CFNumberGetType((__bridge CFNumberRef)[attributeDesc kvc_fixNumberValueType:@1]), kCFNumberCharType);

    attributeDesc.attributeType = NSInteger16AttributeType;
    XCTAssertEqual(CFNumberGetType((__bridge CFNumberRef)[attributeDesc kvc_fixNumberValueType:@YES]), kCFNumberSInt16Type);

    attributeDesc.attributeType = NSDoubleAttributeType;
    XCTAssertEqual(CFNumberGetType((__bridge CFNumberRef)[attributeDesc kvc_fixNumberValueType:@1]), kCFNumberFloat64Type);
}

@end
