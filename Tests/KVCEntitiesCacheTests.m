//
//  KVCEntitiesCacheTests.m
//  KVCMapping
//
//  Created by Nicolas Bouilleaud on 27/11/11.
//  Copyright (c) 2011 Nicolas Bouilleaud. All rights reserved.
//
#import <XCTest/XCTest.h>
#import "KVCEntitiesCache.h"
#import "NSManagedObject+KVCRelationship.h"

/****************************************************************************/
#pragma mark Fetch Tests

@interface KVCEntitiesCacheTests : XCTestCase
@end

@implementation KVCEntitiesCacheTests
{
    @protected
    NSManagedObjectContext * moc;
}

- (void)setUp
{
    [super setUp];
    
    moc = NSManagedObjectContext.new;
    moc.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:
                                      [[NSManagedObjectModel alloc] initWithContentsOfURL:
                                       [[NSBundle bundleForClass:self.class] URLForResource:@"NSManagedObject_KVCMapping_Tests"
                                                                                withExtension:@"mom"]]];

}

- (void)testCachePresenceOfEntities
{
    // Given
    // Create an A instance
    NSManagedObject * a1 = [NSEntityDescription insertNewObjectForEntityForName:@"TestRelatedEntityA" inManagedObjectContext:moc];
    [a1 setValue:@"value1" forKey:@"attributeInA"];
    // Create an B instance
    NSManagedObject * b1 = [NSEntityDescription insertNewObjectForEntityForName:@"TestRelatedEntityB" inManagedObjectContext:moc];
    [b1 setValue:@"value1" forKey:@"attributeInB"];
   
    // When
    // Create a cache of A instances
    KVCEntitiesCache * cache = [[KVCEntitiesCache alloc] initWithInstanceCaches:
                                @[[[KVCInstancesCache alloc] initWithContext:moc
                                                                  entityName:@"TestRelatedEntityA"
                                                                  primaryKey:@"attributeInA"]]];

    // Then
    XCTAssertEqualObjects(cache[@"TestRelatedEntityA"][@"value1"], a1, @"object a1 should be in cache");
    XCTAssertNil(cache[@"TestRelatedEntityB"][@"value1"], @"object b1 should not be in cache");

    // When
    // Create a new A instance
    NSManagedObject * a2 = [NSEntityDescription insertNewObjectForEntityForName:@"TestRelatedEntityA" inManagedObjectContext:moc];
    [a2 setValue:@"value2" forKey:@"attributeInA"];

    // Then
    // It should not be in the cache
    XCTAssertNil(cache[@"TestRelatedEntityA"][@"value2"], @"object a2 should not be in cache");
    
    // When
    // Register the new A instance
    cache[@"TestRelatedEntityA"][@"value2"] = a2;
    XCTAssertEqualObjects(cache[@"TestRelatedEntityA"][@"value2"], a2, @"object a2 should be in cache");
}

- (void)testCacheAccessedEntities
{
    // Given
    // Create an A instance
    NSManagedObject * a1 = [NSEntityDescription insertNewObjectForEntityForName:@"TestRelatedEntityA" inManagedObjectContext:moc];
    [a1 setValue:@"value1" forKey:@"attributeInA"];
    
    // When
    // Create a cache of A instances
    KVCEntitiesCache * cache = [[KVCEntitiesCache alloc] initWithInstanceCaches:
                                @[[[KVCInstancesCache alloc] initWithContext:moc
                                                                  entityName:@"TestRelatedEntityA"
                                                                  primaryKey:@"attributeInA"]]];

    // Then
    XCTAssertEqualObjects([cache accessedInstances], [NSSet set], @"accessed instances should be empty");

    // When
    // Access the instance
    __unused id a_ = cache[@"TestRelatedEntityA"][@"value1"];
    XCTAssertEqualObjects([cache accessedInstances], [NSSet setWithObject:a1], @"accessed instances should contain a1");

    // When
    // Create a new A instance
    NSManagedObject * a2 = [NSEntityDescription insertNewObjectForEntityForName:@"TestRelatedEntityA" inManagedObjectContext:moc];
    [a2 setValue:@"value2" forKey:@"attributeInA"];
    // Register the new A instance
    cache[@"TestRelatedEntityA"][@"value2"] = a2;

    // Then
    XCTAssertEqualObjects([cache accessedInstances], ([NSSet setWithObjects:a1, a2, nil]), @"accessed instances should coutain a1 and a2");
}

@end
