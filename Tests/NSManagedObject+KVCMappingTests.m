//
//  NSObject+KVCMapping_Tests.m
//  KVCMapping
//
//  Created by Nicolas Bouilleaud on 27/11/11.
//  Copyright (c) 2011 Nicolas Bouilleaud. All rights reserved.
//
#import <SenTestingKit/SenTestingKit.h>
#import "NSObject+KVCMapping.h"

@interface NSManagedObject_KVCMapping_Tests : SenTestCase
@end

@implementation NSManagedObject_KVCMapping_Tests
{
    NSManagedObjectContext * _moc;
    NSDictionary * _mapping;
    NSDictionary * _goodDataset, * _badDataSet;
}

- (void) setUp
{
    [super setUp];
    
    _moc = [NSManagedObjectContext new];
    _moc.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:
                                       [[NSManagedObjectModel alloc] initWithContentsOfURL:
                                        [[NSBundle bundleForClass:[self class]] URLForResource:@"NSManagedObject_KVCMapping_Tests"
                                                                                 withExtension:@"mom"]]];
    
    NSDate * date = [NSDate date];
    
    _mapping = @{@"usedBoolean": @"actualBoolean",
                @"usedData": @"actualData",
                @"usedDate": @"actualDate",
                @"usedDecimal": @"actualDecimal",
                @"usedDouble": @"actualDouble",
                @"usedFloat": @"actualFloat",
                @"usedInt16": @"actualInt16",
                @"usedInt32": @"actualInt32",
                @"usedInt64": @"actualInt64",
                @"usedString": @"actualString",
                };
    
    _goodDataset = @{@"usedBoolean": @YES,
                     @"usedInt16": [NSNumber numberWithShort:100],
                     @"usedInt32": @100,
                     @"usedInt64": @100LL,
                     @"usedDecimal": [NSDecimalNumber numberWithInt:100],
                     @"usedFloat": @100.0f,
                     @"usedDouble": @100.0,
                     @"usedString": @"100",
                     @"usedData": [@"test" dataUsingEncoding:NSUTF8StringEncoding],
                     @"usedDate": date
                     };
    
    _badDataSet = @{@"usedBoolean": @"YES",
                    @"usedInt16": @"100",
                    @"usedInt32": @"100",
                    @"usedInt64": @"100",
                    @"usedDecimal": @"100",
                    @"usedFloat": @"100",
                    @"usedDouble": @"100",
                    @"usedString": @100,
                    @"usedData": [@"test" dataUsingEncoding:NSUTF8StringEncoding],
                    @"usedDate": date};
}

- (void) testSimpleDataset
{
    // Checks the values in the goodDataSet are correctly set
    NSManagedObject * test = [NSEntityDescription insertNewObjectForEntityForName:@"TestEntity" inManagedObjectContext:_moc];

    [test kvc_setValues:_goodDataset withMappingDictionary:_mapping options:nil];
    
    for (NSString * wantedKey in _goodDataset) {
        id value = _goodDataset[wantedKey];
        NSString * realKey = _mapping[wantedKey];
        STAssertEqualObjects([test valueForKey:realKey], value, nil);
    }
    // reverse
    id values = [test kvc_valuesWithMappingDictionary:_mapping options:nil];
    
    STAssertEqualObjects(values, _goodDataset, nil);
}

- (void) testAutomaticCoercionDataset
{
    // Checks the values from the badDataSet are converted to values equal to the ones in the goodDataSet
    NSManagedObject * test = [NSEntityDescription insertNewObjectForEntityForName:@"TestEntity" inManagedObjectContext:_moc];

    [test kvc_setValues:_badDataSet withMappingDictionary:_mapping options:nil];
    
    for (NSString * wantedKey in _goodDataset) {
        id value = _goodDataset[wantedKey];
        NSString * realKey = _mapping[wantedKey];
        STAssertEqualObjects([test valueForKey:realKey], value, nil);
    }

    // reverse
    id values = [test kvc_valuesWithMappingDictionary:_mapping options:nil];
    
    STAssertEqualObjects(values, _goodDataset, nil);
}

@end
