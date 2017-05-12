//
//  NSObject+KVCFetching_Tests.m
//  KVCMapping
//
//  Created by Nicolas Bouilleaud on 27/11/11.
//  Copyright (c) 2011 Nicolas Bouilleaud. All rights reserved.
//
#import <XCTest/XCTest.h>
#import "KVCMapping.h"

/****************************************************************************/
#pragma mark Entity Class

@interface TestEntityClass : NSManagedObject
@property NSString * testAttribute;
@end

@implementation TestEntityClass
@dynamic testAttribute;
@end

/****************************************************************************/
#pragma mark Fetch Tests

@interface NSManagedObject_KVCFetching_Tests : XCTestCase
@end

@implementation NSManagedObject_KVCFetching_Tests
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

- (void)testFetchObject
{
    TestEntityClass * objectA = [NSEntityDescription insertNewObjectForEntityForName:@"TestEntityWithClass" inManagedObjectContext:moc];
    objectA.testAttribute = @"A";
    TestEntityClass * objectB = [NSEntityDescription insertNewObjectForEntityForName:@"TestEntityWithClass" inManagedObjectContext:moc];
    objectB.testAttribute = @"B";

    XCTAssertEqualObjects([TestEntityClass kvc_fetchObjectInContext:moc withValue:@"A" forKey:@"testAttribute" options:nil], objectA);
    XCTAssertEqualObjects([TestEntityClass kvc_fetchObjectInContext:moc withValue:@"B" forKey:@"testAttribute" options:nil], objectB);
    XCTAssertEqualObjects([TestEntityClass kvc_fetchObjectInContext:moc withValue:@"C" forKey:@"testAttribute" options:nil], nil);
}

- (void)testFetchObjectWithCoercion
{
    TestEntityClass * objectA = [NSEntityDescription insertNewObjectForEntityForName:@"TestEntityWithClass" inManagedObjectContext:moc];
    objectA.testAttribute = @"1234";
    
    XCTAssertEqualObjects([TestEntityClass kvc_fetchObjectInContext:moc withValue:@1234 forKey:@"testAttribute" options:nil], objectA);
}

- (void)testCreateOrFetchObject
{
    XCTAssertEqualObjects([TestEntityClass kvc_fetchObjectInContext:moc withValue:@"A" forKey:@"testAttribute" options:nil], nil);
    TestEntityClass * objectA = [TestEntityClass kvc_fetchObjectInContext:moc withValue:@"A" forKey:@"testAttribute" options:@{KVCCreateObjectOption:@YES}];
    XCTAssertNotNil(objectA);
    objectA.testAttribute = @"A";

    XCTAssertEqualObjects([TestEntityClass kvc_fetchObjectInContext:moc withValue:@"A" forKey:@"testAttribute" options:nil], objectA);
}

- (void)testFetchObjectWithCache
{
    TestEntityClass * objectA = [NSEntityDescription insertNewObjectForEntityForName:@"TestEntityWithClass" inManagedObjectContext:moc];
    objectA.testAttribute = @"A";

    KVCEntitiesCache * cache = [[KVCEntitiesCache alloc] initWithInstanceCaches:
                                @[[[KVCInstancesCache alloc] initWithContext:moc
                                                                  entityName:@"TestEntityWithClass"
                                                                  primaryKey:@"testAttribute"]]];

    XCTAssertEqualObjects(cache[@"TestEntityWithClass"][@"A"], objectA);

    XCTAssertEqualObjects([TestEntityClass kvc_fetchObjectInContext:moc withValue:@"A" forKey:@"testAttribute" options:(@{KVCCreateObjectOption:@YES, KVCEntitiesCacheOption:cache})], objectA);
}

- (void)testCreateObjectWithCacheMiss
{
    KVCEntitiesCache * cache = [[KVCEntitiesCache alloc] initWithInstanceCaches:
                                @[[[KVCInstancesCache alloc] initWithContext:moc
                                                                  entityName:@"TestEntityWithClass"
                                                                  primaryKey:@"testAttribute"]]];

    TestEntityClass * objectA = [TestEntityClass kvc_fetchObjectInContext:moc withValue:@"A" forKey:@"testAttribute" options:(@{KVCEntitiesCacheOption:cache})];
    XCTAssertNil(objectA);

    objectA = [TestEntityClass kvc_fetchObjectInContext:moc withValue:@"A" forKey:@"testAttribute" options:(@{KVCCreateObjectOption:@YES, KVCEntitiesCacheOption:cache})];
    XCTAssertNotNil(objectA);
    XCTAssertEqualObjects(objectA.testAttribute, @"A");
    
    XCTAssertEqualObjects(cache[@"TestEntityWithClass"][@"A"], objectA);
}

@end


