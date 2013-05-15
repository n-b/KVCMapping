//
//  NSObject+KVCFetching_Tests.m
//  KVCMapping
//
//  Created by Nicolas Bouilleaud on 27/11/11.
//  Copyright (c) 2011 Nicolas Bouilleaud. All rights reserved.
//
#import <SenTestingKit/SenTestingKit.h>
#import "NSManagedObject+KVCFetching.h"

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

@interface NSManagedObject_KVCFetching_Tests : SenTestCase
@end

@implementation NSManagedObject_KVCFetching_Tests
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

- (void) testEntityName
{
    STAssertEqualObjects([[TestEntityClass entityInManagedObjectContext:moc] name], @"TestEntityWithClass", nil);
    STAssertEqualObjects([[NSManagedObject entityInManagedObjectContext:moc] name], nil, nil);
}

- (void) testFetchObject
{
    NSString * entityName = [[TestEntityClass entityInManagedObjectContext:moc] name];
    TestEntityClass * objectA = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:moc];
    objectA.testAttribute = @"A";
    TestEntityClass * objectB = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:moc];
    objectB.testAttribute = @"B";

    STAssertEqualObjects([TestEntityClass fetchObjectInContext:moc withValue:@"A" forKey:@"testAttribute" createObject:NO], objectA, nil);
    STAssertEqualObjects([TestEntityClass fetchObjectInContext:moc withValue:@"B" forKey:@"testAttribute" createObject:NO], objectB, nil);
    STAssertEqualObjects([TestEntityClass fetchObjectInContext:moc withValue:@"C" forKey:@"testAttribute" createObject:NO], nil, nil);
}

- (void) testFetchObjectWithCoercion
{
    NSString * entityName = [[TestEntityClass entityInManagedObjectContext:moc] name];
    TestEntityClass * objectA = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:moc];
    objectA.testAttribute = @"1234";
    
    STAssertEqualObjects([TestEntityClass fetchObjectInContext:moc withValue:@1234 forKey:@"testAttribute" createObject:NO], objectA, nil);
}

- (void) testCreateOrFetchObject
{
    STAssertEqualObjects([TestEntityClass fetchObjectInContext:moc withValue:@"A" forKey:@"testAttribute" createObject:NO], nil, nil);
    TestEntityClass * objectA = [TestEntityClass fetchObjectInContext:moc withValue:@"A" forKey:@"testAttribute" createObject:YES];
    STAssertNotNil(objectA, nil);
    objectA.testAttribute = @"A";

    STAssertEqualObjects([TestEntityClass fetchObjectInContext:moc withValue:@"A" forKey:@"testAttribute" createObject:NO], objectA, nil);
}

- (void) testFetchObjectWithCache
{
    NSString * entityName = [[TestEntityClass entityInManagedObjectContext:moc] name];
    TestEntityClass * objectA = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:moc];
    objectA.testAttribute = @"A";
    
    KVCEntitiesCache * cache = [[KVCEntitiesCache alloc] initWithEntities:@[[NSEntityDescription entityForName:@"TestEntityWithClass"
                                                                                        inManagedObjectContext:moc]]
                                                                inContext:moc onKey:@"testAttribute"];

    STAssertEqualObjects(cache[@"TestEntityWithClass"][@"A"], objectA, nil);
    STAssertEqualObjects([TestEntityClass fetchObjectInContext:moc withValue:@"A" forKey:@"testAttribute" createObject:YES instancesCache:cache[@"TestEntityWithClass"]], objectA, nil);
}

- (void) testCreateObjectWithCacheMiss
{
    KVCEntitiesCache * cache = [[KVCEntitiesCache alloc] initWithEntities:@[[NSEntityDescription entityForName:@"TestEntityWithClass"
                                                                                        inManagedObjectContext:moc]]
                                                                inContext:moc onKey:@"testAttribute"];

    TestEntityClass * objectA = [TestEntityClass fetchObjectInContext:moc withValue:@"A" forKey:@"testAttribute" createObject:NO instancesCache:cache[@"TestEntityWithClass"]];
    STAssertNil(objectA, nil);

    objectA = [TestEntityClass fetchObjectInContext:moc withValue:@"A" forKey:@"testAttribute" createObject:YES instancesCache:cache[@"TestEntityWithClass"]];
    STAssertNotNil(objectA, nil);
    STAssertEqualObjects(objectA.testAttribute, @"A", nil);
    
    STAssertEqualObjects(cache[@"TestEntityWithClass"][@"A"], objectA, nil);
}

@end


