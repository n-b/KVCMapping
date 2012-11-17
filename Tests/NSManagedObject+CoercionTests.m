//
//  NSObject+KVCMapping_Tests.m
//  KVCMapping
//
//  Created by Nicolas Bouilleaud on 27/11/11.
//  Copyright (c) 2011 Nicolas Bouilleaud. All rights reserved.
//
#import <SenTestingKit/SenTestingKit.h>
#import "NSManagedObject+Coercion.h"

/******************************************************************************/
#pragma mark Coercion Tests

@interface NSManagedObject_KVCMappingCoercion_Tests : SenTestCase
@end

@implementation NSManagedObject_KVCMappingCoercion_Tests

- (void) testCoercionToNumber
{
    // From proper strings
    STAssertEqualObjects([NSManagedObject coerceValue:@"1234" toAttributeType:NSInteger16AttributeType],@1234,nil);
    STAssertEqualObjects([NSManagedObject coerceValue:@"1234" toAttributeType:NSInteger32AttributeType],@1234,nil);
    STAssertEqualObjects([NSManagedObject coerceValue:@"1234" toAttributeType:NSInteger16AttributeType],@1234,nil);
    STAssertEqualObjects([NSManagedObject coerceValue:@"1234" toAttributeType:NSInteger64AttributeType],@1234,nil);

    STAssertEqualObjects([NSManagedObject coerceValue:@"12.3456789" toAttributeType:NSDecimalAttributeType],[NSDecimalNumber decimalNumberWithString:@"12.3456789"],nil);
    STAssertEqualObjects([NSManagedObject coerceValue:@"12.34" toAttributeType:NSDoubleAttributeType],@12.34,nil);
    STAssertEqualObjects([NSManagedObject coerceValue:@"12.34" toAttributeType:NSFloatAttributeType],@(12.34f),nil);

    // From garbage strings
    STAssertEqualObjects([NSManagedObject coerceValue:@"toto" toAttributeType:NSInteger16AttributeType],@0,nil);
    STAssertEqualObjects([NSManagedObject coerceValue:@"toto" toAttributeType:NSInteger32AttributeType],@0,nil);
    STAssertEqualObjects([NSManagedObject coerceValue:@"toto" toAttributeType:NSInteger16AttributeType],@0,nil);
    STAssertEqualObjects([NSManagedObject coerceValue:@"toto" toAttributeType:NSInteger64AttributeType],@0,nil);
    
    STAssertEqualObjects([NSManagedObject coerceValue:@"toto" toAttributeType:NSDecimalAttributeType],[NSDecimalNumber notANumber],nil);
    STAssertEqualObjects([NSManagedObject coerceValue:@"toto" toAttributeType:NSDoubleAttributeType],@0,nil);
    STAssertEqualObjects([NSManagedObject coerceValue:@"toto" toAttributeType:NSFloatAttributeType],@0,nil);

    // From numbers
    STAssertEqualObjects([NSManagedObject coerceValue:@1234 toAttributeType:NSInteger16AttributeType],@1234,nil);
    STAssertEqualObjects([NSManagedObject coerceValue:@1234 toAttributeType:NSInteger32AttributeType],@1234,nil);
    STAssertEqualObjects([NSManagedObject coerceValue:@1234 toAttributeType:NSInteger16AttributeType],@1234,nil);
    STAssertEqualObjects([NSManagedObject coerceValue:@1234 toAttributeType:NSInteger64AttributeType],@1234,nil);
    
    STAssertEqualObjects([NSManagedObject coerceValue:@12.3456789 toAttributeType:NSDecimalAttributeType],[NSDecimalNumber decimalNumberWithString:@"12.3456789"],nil);
    STAssertEqualObjects([NSManagedObject coerceValue:@12.34 toAttributeType:NSDoubleAttributeType],@12.34,nil);
    STAssertEqualObjects([NSManagedObject coerceValue:@12.34 toAttributeType:NSFloatAttributeType],@(12.34f),nil);
    
    // From nil
    STAssertEqualObjects([NSManagedObject coerceValue:nil toAttributeType:NSInteger16AttributeType],nil,nil);
    STAssertEqualObjects([NSManagedObject coerceValue:nil toAttributeType:NSInteger32AttributeType],nil,nil);
    STAssertEqualObjects([NSManagedObject coerceValue:nil toAttributeType:NSInteger16AttributeType],nil,nil);
    STAssertEqualObjects([NSManagedObject coerceValue:nil toAttributeType:NSInteger64AttributeType],nil,nil);
    
    STAssertEqualObjects([NSManagedObject coerceValue:nil toAttributeType:NSDecimalAttributeType],nil,nil);
    STAssertEqualObjects([NSManagedObject coerceValue:nil toAttributeType:NSDoubleAttributeType],nil,nil);
    STAssertEqualObjects([NSManagedObject coerceValue:nil toAttributeType:NSFloatAttributeType],nil,nil);
    
    // From garbage data
    id value = [NSData dataWithBytes:"bla" length:4];
    STAssertEqualObjects([NSManagedObject coerceValue:value toAttributeType:NSInteger16AttributeType],nil,nil);
    STAssertEqualObjects([NSManagedObject coerceValue:value toAttributeType:NSInteger32AttributeType],nil,nil);
    STAssertEqualObjects([NSManagedObject coerceValue:value toAttributeType:NSInteger16AttributeType],nil,nil);
    STAssertEqualObjects([NSManagedObject coerceValue:value toAttributeType:NSInteger64AttributeType],nil,nil);
    
    STAssertEqualObjects([NSManagedObject coerceValue:value toAttributeType:NSDecimalAttributeType],nil,nil);
    STAssertEqualObjects([NSManagedObject coerceValue:value toAttributeType:NSDoubleAttributeType],nil,nil);
    STAssertEqualObjects([NSManagedObject coerceValue:value toAttributeType:NSFloatAttributeType],nil,nil);
}

- (void) testCoercionToString
{
    STAssertEqualObjects([NSManagedObject coerceValue:@"abcd" toAttributeType:NSStringAttributeType],@"abcd",nil);
    STAssertEqualObjects([NSManagedObject coerceValue:@1234 toAttributeType:NSStringAttributeType],@"1234",nil);
    STAssertEqualObjects([NSManagedObject coerceValue:@12.34 toAttributeType:NSStringAttributeType],@"12.34",nil);
}

- (void) testCoercionToBool
{
    STAssertEqualObjects([NSManagedObject coerceValue:@YES toAttributeType:NSBooleanAttributeType],@YES,nil);
    STAssertEqualObjects([NSManagedObject coerceValue:@"true" toAttributeType:NSBooleanAttributeType],@YES,nil);
    STAssertEqualObjects([NSManagedObject coerceValue:@"false" toAttributeType:NSBooleanAttributeType],@NO,nil);
    STAssertEqualObjects([NSManagedObject coerceValue:@"abcd" toAttributeType:NSBooleanAttributeType],@NO,nil);
}

- (void) testCoercionToDate
{
    NSDate * date = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
    STAssertEqualObjects([NSManagedObject coerceValue:date toAttributeType:NSDateAttributeType],date,nil);
    STAssertEqualObjects([NSManagedObject coerceValue:@"abcd" toAttributeType:NSDateAttributeType],nil,nil);
}

- (void) testCoercionToData
{
    NSDate * data = [NSData dataWithBytes:"abcd" length:5];
    STAssertEqualObjects([NSManagedObject coerceValue:data toAttributeType:NSBinaryDataAttributeType],data,nil);
    STAssertEqualObjects([NSManagedObject coerceValue:@"abcd" toAttributeType:NSBinaryDataAttributeType],nil,nil);
}

- (void) testCoercionToOtherTypes
{
    // Passed-through
    id value = [NSObject new];
    STAssertEqualObjects([NSManagedObject coerceValue:value toAttributeType:NSUndefinedAttributeType],value,nil);    
    STAssertEqualObjects([NSManagedObject coerceValue:value toAttributeType:NSTransformableAttributeType],value,nil);
    STAssertEqualObjects([NSManagedObject coerceValue:value toAttributeType:NSObjectIDAttributeType],value,nil);
}

@end
