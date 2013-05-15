//
//  KVCEntitiesCacheTests.m
//  KVCMapping
//
//  Created by Nicolas Bouilleaud on 27/11/11.
//  Copyright (c) 2011 Nicolas Bouilleaud. All rights reserved.
//
#import <SenTestingKit/SenTestingKit.h>
#import "NSManagedObject+KVCRelationship.h"

/****************************************************************************/
#pragma mark Fetch Tests

@interface KVCEntitiesCacheTests : SenTestCase
@end

@implementation KVCEntitiesCacheTests
{
    @protected
    NSManagedObjectContext * moc;
}

- (void) setUp
{
    [super setUp];
    
    moc = [NSManagedObjectContext new];
    moc.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:
                                      [[NSManagedObjectModel alloc] initWithContentsOfURL:
                                       [[NSBundle bundleForClass:[self class]] URLForResource:@"NSManagedObject_KVCMapping_Tests"
                                                                                withExtension:@"mom"]]];

}

- (void) testCachePresenceOfEntities
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
    KVCEntitiesCache * cache = [[KVCEntitiesCache alloc] initWithEntities:@[[NSEntityDescription entityForName:@"TestRelatedEntityA"
                                                                                        inManagedObjectContext:moc]]
                                                                inContext:moc onKey:@"attributeInA"];

    // Then
    STAssertEqualObjects(cache[@"TestRelatedEntityA"][@"value1"], a1, @"object a1 should be in cache");
    STAssertNil(cache[@"TestRelatedEntityB"][@"value1"], @"object b1 should not be in cache");

    // When
    // Create a new A instance
    NSManagedObject * a2 = [NSEntityDescription insertNewObjectForEntityForName:@"TestRelatedEntityA" inManagedObjectContext:moc];
    [a2 setValue:@"value2" forKey:@"attributeInA"];

    // Then
    // It should not be in the cache
    STAssertNil(cache[@"TestRelatedEntityA"][@"value2"], @"object a2 should not be in cache");
    
    // When
    // Register the new A instance
    cache[@"TestRelatedEntityA"][@"value2"] = a2;
    STAssertEqualObjects(cache[@"TestRelatedEntityA"][@"value2"], a2, @"object a2 should be in cache");
}

- (void) testCacheAccessedEntities
{
    // Given
    // Create an A instance
    NSManagedObject * a1 = [NSEntityDescription insertNewObjectForEntityForName:@"TestRelatedEntityA" inManagedObjectContext:moc];
    [a1 setValue:@"value1" forKey:@"attributeInA"];
    
    // When
    // Create a cache of A instances
    KVCEntitiesCache * cache = [[KVCEntitiesCache alloc] initWithEntities:@[[NSEntityDescription entityForName:@"TestRelatedEntityA"
                                                                                        inManagedObjectContext:moc]]
                                                                inContext:moc onKey:@"attributeInA"];
    
    // Then
    STAssertEqualObjects([cache accessedInstances], [NSSet set], @"accessed instances should be empty");

    // When
    // Access the instance
    __unused id a_ = cache[@"TestRelatedEntityA"][@"value1"];
    STAssertEqualObjects([cache accessedInstances], [NSSet setWithObject:a1], @"accessed instances should contain a1");

    // When
    // Create a new A instance
    NSManagedObject * a2 = [NSEntityDescription insertNewObjectForEntityForName:@"TestRelatedEntityA" inManagedObjectContext:moc];
    [a2 setValue:@"value2" forKey:@"attributeInA"];
    // Register the new A instance
    cache[@"TestRelatedEntityA"][@"value2"] = a2;

    // Then
    STAssertEqualObjects([cache accessedInstances], ([NSSet setWithObjects:a1, a2, nil]), @"accessed instances should coutain a1 and a2");
}

@end
