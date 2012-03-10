//
//  NSObject+KVCMapping_Tests.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 27/11/11.
//  Copyright (c) 2011 Nicolas Bouilleaud. All rights reserved.
//
#import <SenTestingKit/SenTestingKit.h>
#import "NSObject+KVCMapping.h"
#import "FormattedStringToDateValueTransformer.h"

@interface NSObject_KVCMapping_Tests : SenTestCase
@end

@implementation NSObject_KVCMapping_Tests
{
    NSDictionary * mapping;
}

- (void) setUp
{
    [super setUp];
    mapping = [NSDictionary dictionaryWithObjectsAndKeys:
               @"actualName", @"usedName",
               @"ISO8601StringToDate:actualDate", @"usedDate",
               nil];
    
    // Setup formatter and transformer
    NSDateFormatter * dateFormatter = [NSDateFormatter new];
	dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
	[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    NSValueTransformer * valueTransformer = [[FormattedStringToDateValueTransformer alloc] initWithDateFormatter:dateFormatter];
    [NSValueTransformer setValueTransformer:valueTransformer forName:@"ISO8601StringToDate"];
}

- (void) testBasicMapping
{
    NSMutableDictionary * test = [NSMutableDictionary dictionary];
    [test setValue:@"testValue" forKey:@"usedName" withMappingDictionary:mapping];
    STAssertNil([test valueForKey:@"usedName"], nil);
    STAssertEqualObjects([test valueForKey:@"actualName"], @"testValue", nil);
}

- (void) testTransformerMapping
{
    // Setup date (my birthdate)
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:372671100];

    // Test
    NSMutableDictionary * test = [NSMutableDictionary dictionary];
    [test setValue:@"1981-10-23T07:45:00Z" forKey:@"usedDate" withMappingDictionary:mapping];
    STAssertEqualObjects([test valueForKey:@"actualDate"], date, nil);
}

@end

/****************************************************************************/
#pragma mark -

@interface NSManagedObject_KVCMapping_Tests : SenTestCase
@end

@implementation NSManagedObject_KVCMapping_Tests
{
    NSManagedObjectContext * moc;
    NSDictionary * mapping;
    NSDictionary * goodDataset, * badDataSet;
}

- (void) setUp
{
    [super setUp];

    moc = [NSManagedObjectContext new];
    moc.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:
                                      [[NSManagedObjectModel alloc] initWithContentsOfURL:
                                       [[NSBundle bundleForClass:[self class]] URLForResource:@"NSObject+KVCMappingTests" 
                                                                                withExtension:@"mom"]]];

    mapping = [NSDictionary dictionaryWithObjectsAndKeys:
               @"actualBoolean", @"usedBoolean",
               @"actualData", @"usedData",
               @"actualDate", @"usedDate",
               @"actualDecimal", @"usedDecimal",
               @"actualDouble", @"usedDouble",
               @"actualFloat", @"usedFloat",
               @"actualInt16", @"usedInt16",
               @"actualInt32", @"usedInt32",
               @"actualInt64", @"usedInt64",
               @"actualString", @"usedString",
               nil];

    NSDate * date = [NSDate date];
    
    goodDataset = [NSDictionary dictionaryWithObjectsAndKeys:
                   [NSNumber numberWithBool:YES], @"usedBoolean",
                   [NSNumber numberWithShort:100], @"usedInt16",
                   [NSNumber numberWithInt:100], @"usedInt32",
                   [NSNumber numberWithLongLong:100], @"usedInt64",
                   [NSDecimalNumber numberWithInt:100], @"usedDecimal",
                   [NSNumber numberWithFloat:100], @"usedFloat",
                   [NSNumber numberWithDouble:100], @"usedDouble",
                   @"100", @"usedString",
                   [@"test" dataUsingEncoding:NSUTF8StringEncoding], @"usedData",
                   date, @"usedDate",
                   nil];
    
    badDataSet = [NSDictionary dictionaryWithObjectsAndKeys:
                  @"YES", @"usedBoolean",
                  @"100", @"usedInt16",
                  @"100", @"usedInt32",
                  @"100", @"usedInt64",
                  @"100", @"usedDecimal",
                  @"100", @"usedFloat",
                  @"100", @"usedDouble",
                  [NSNumber numberWithInt:100], @"usedString",
                  [@"test" dataUsingEncoding:NSUTF8StringEncoding], @"usedData",
                  date, @"usedDate",
                  nil];
}

- (void) testBasic
{
    NSManagedObject * test = [NSEntityDescription insertNewObjectForEntityForName:@"TestEntity" inManagedObjectContext:moc];
    [test setValue:@"testValue" forKey:@"usedString" withMappingDictionary:mapping];
    //    STAssertThrows([test valueForKey:@"usedName"], nil);  // Tests passes, but crashes in iOS Xcode 4.3b3
    STAssertEqualObjects([test valueForKey:@"actualString"], @"testValue", nil);
}

- (void) testSimpleDataset
{
    NSManagedObject * test = [NSEntityDescription insertNewObjectForEntityForName:@"TestEntity" inManagedObjectContext:moc];
    [test setValuesForKeysWithDictionary:goodDataset withMappingDictionary:mapping];
    
    for (NSString * wantedKey in goodDataset) {
        id value = [goodDataset objectForKey:wantedKey];
        NSString * realKey = [mapping objectForKey:wantedKey];
        STAssertEqualObjects([test valueForKey:realKey], value, nil);
    }
}

- (void) testAutomaticCoercionDataset
{
    NSManagedObject * test = [NSEntityDescription insertNewObjectForEntityForName:@"TestEntity" inManagedObjectContext:moc];
    [test setValuesForKeysWithDictionary:badDataSet withMappingDictionary:mapping];
    
    for (NSString * wantedKey in goodDataset) {
        id value = [goodDataset objectForKey:wantedKey];
        NSString * realKey = [mapping objectForKey:wantedKey];
        STAssertEqualObjects([test valueForKey:realKey], value, nil);
    }
}

@end
