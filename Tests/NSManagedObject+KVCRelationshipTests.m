//
//  NSObject+KVCFetching_Tests.m
//  KVCMapping
//
//  Created by Nicolas Bouilleaud on 27/11/11.
//  Copyright (c) 2011 Nicolas Bouilleaud. All rights reserved.
//
#import <SenTestingKit/SenTestingKit.h>
#import "NSManagedObject+KVCRelationship.h"

/****************************************************************************/
#pragma mark Fetch Tests

@interface NSManagedObject_Relationship_Tests : SenTestCase
@end

@implementation NSManagedObject_Relationship_Tests
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

- (void) testSetRelationship
{
    NSManagedObject * a = [NSEntityDescription insertNewObjectForEntityForName:@"TestRelatedEntityA" inManagedObjectContext:moc];
    NSManagedObject * b = [NSEntityDescription insertNewObjectForEntityForName:@"TestRelatedEntityB" inManagedObjectContext:moc];

    [a setValue:@"value1" forKey:@"attributeInA"];
    
    [b setRelationship:@"relationToA" withObjectWithValue:@"value1" forKey:@"attributeInA" createObject:NO];
    
    STAssertEqualObjects([b valueForKey:@"relationToA"], a, nil);
    STAssertEqualObjects([a valueForKey:@"relationToB"], b, nil);
}

- (void) testSetWithDictionary
{
    NSManagedObject * a = [NSEntityDescription insertNewObjectForEntityForName:@"TestRelatedEntityA" inManagedObjectContext:moc];
    NSManagedObject * b = [NSEntityDescription insertNewObjectForEntityForName:@"TestRelatedEntityB" inManagedObjectContext:moc];
    
    [a setValue:@"value1" forKey:@"attributeInA"];

    [b setRelationshipsWithDictionary:@{@"a" : @"value1"} withMappingDictionary:@{@"a" : @"relationToA:attributeInA"} createObjects:NO];
    
    STAssertEqualObjects([b valueForKey:@"relationToA"], a, nil);
    STAssertEqualObjects([a valueForKey:@"relationToB"], b, nil);
}

- (void) testSetWithCoercion
{
    NSManagedObject * a = [NSEntityDescription insertNewObjectForEntityForName:@"TestRelatedEntityA" inManagedObjectContext:moc];
    NSManagedObject * b = [NSEntityDescription insertNewObjectForEntityForName:@"TestRelatedEntityB" inManagedObjectContext:moc];
    
    [a setValue:@"1234" forKey:@"attributeInA"];
    
    [b setRelationship:@"relationToA" withObjectWithValue:@1234 forKey:@"attributeInA" createObject:NO];
    
    STAssertEqualObjects([b valueForKey:@"relationToA"], a, nil);
    STAssertEqualObjects([a valueForKey:@"relationToB"], b, nil);
}

- (void) testSetRelationshipToNonexistingObject
{
    NSManagedObject * a = [NSEntityDescription insertNewObjectForEntityForName:@"TestRelatedEntityA" inManagedObjectContext:moc];
    NSManagedObject * b = [NSEntityDescription insertNewObjectForEntityForName:@"TestRelatedEntityB" inManagedObjectContext:moc];
    
    [a setValue:@"value1" forKey:@"attributeInA"];
    
    [b setRelationship:@"relationToA" withObjectWithValue:@"value2" forKey:@"attributeInA" createObject:NO];
    
    STAssertEqualObjects([b valueForKey:@"relationToA"], nil, nil);
}

- (void) testSetRelationshipToNonexistingObjectAndCreate
{
    NSManagedObject * a = [NSEntityDescription insertNewObjectForEntityForName:@"TestRelatedEntityA" inManagedObjectContext:moc];
    
    NSManagedObject * b =  [a setRelationship:@"relationToB" withObjectWithValue:@"value1" forKey:@"attributeInB" createObject:YES];

    STAssertNotNil(b, nil);
    STAssertEqualObjects([b valueForKey:@"relationToA"], a, nil);
    STAssertEqualObjects([a valueForKey:@"relationToB"], b, nil);
}

@end


