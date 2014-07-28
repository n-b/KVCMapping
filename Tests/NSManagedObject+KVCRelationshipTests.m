//
//  NSObject+KVCRelationshipTests.m
//  KVCMapping
//
//  Created by Nicolas Bouilleaud on 27/11/11.
//  Copyright (c) 2011 Nicolas Bouilleaud. All rights reserved.
//
#import <XCTest/XCTest.h>
#import "KVCMapping.h"

/****************************************************************************/
#pragma mark Fetch Tests

@interface NSManagedObject_KVCRelationship_Tests : XCTestCase
@end

@implementation NSManagedObject_KVCRelationship_Tests
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
    
    [b kvc_setRelationship:@"relationToA" toObjectWithValue:@"value1" forKey:@"attributeInA" options:nil];
    
    XCTAssertEqualObjects([b valueForKey:@"relationToA"], a);
    XCTAssertEqualObjects([a valueForKey:@"relationToB"], b);
}

- (void) testSetRelationshipToMany
{
    NSManagedObject * a1 = [NSEntityDescription insertNewObjectForEntityForName:@"TestRelatedEntityA" inManagedObjectContext:moc];
    NSManagedObject * a2 = [NSEntityDescription insertNewObjectForEntityForName:@"TestRelatedEntityA" inManagedObjectContext:moc];
    NSManagedObject * b = [NSEntityDescription insertNewObjectForEntityForName:@"TestRelatedEntityB" inManagedObjectContext:moc];
    
    [a1 setValue:@"value1" forKey:@"attributeInA"];
    [a2 setValue:@"value2" forKey:@"attributeInA"];

    [b kvc_setRelationship:@"relationToManyAs" toObjectsWithValueIn:@[@"value1",@"value2"] forKey:@"attributeInA" options:nil];

    XCTAssertEqualObjects([b valueForKey:@"relationToManyAs"], ([NSSet setWithObjects:a1, a2, nil]));

    // It works too if a single value is passed
    [b kvc_setRelationship:@"relationToManyAs" toObjectsWithValueIn:@[@"value1"] forKey:@"attributeInA" options:nil];
    
    XCTAssertEqualObjects([b valueForKey:@"relationToManyAs"], [NSSet setWithObject:a1]);

    // It replaces (doesn't add) when we set to another
    [b kvc_setRelationship:@"relationToManyAs" toObjectsWithValueIn:@[@"value2"] forKey:@"attributeInA" options:nil];

    XCTAssertEqualObjects([b valueForKey:@"relationToManyAs"], [NSSet setWithObject:a2]);
}

- (void) testSetRelationshipWithCoercion
{
    NSManagedObject * a = [NSEntityDescription insertNewObjectForEntityForName:@"TestRelatedEntityA" inManagedObjectContext:moc];
    NSManagedObject * b = [NSEntityDescription insertNewObjectForEntityForName:@"TestRelatedEntityB" inManagedObjectContext:moc];
    
    [a setValue:@"1234" forKey:@"attributeInA"];
    
    [b kvc_setRelationship:@"relationToA" toObjectWithValue:@1234 forKey:@"attributeInA" options:nil];
    
    XCTAssertEqualObjects([b valueForKey:@"relationToA"], a);
    XCTAssertEqualObjects([a valueForKey:@"relationToB"], b);
}

- (void) testSetRelationshipToNonexistingObject
{
    NSManagedObject * a = [NSEntityDescription insertNewObjectForEntityForName:@"TestRelatedEntityA" inManagedObjectContext:moc];
    NSManagedObject * b = [NSEntityDescription insertNewObjectForEntityForName:@"TestRelatedEntityB" inManagedObjectContext:moc];
    
    [a setValue:@"value1" forKey:@"attributeInA"];
    
    [b kvc_setRelationship:@"relationToA" toObjectWithValue:@"value2" forKey:@"attributeInA" options:nil];
    
    XCTAssertEqualObjects([b valueForKey:@"relationToA"], nil);
}

- (void) testSetRelationshipToNonexistingObjectAndCreate
{
    NSManagedObject * a = [NSEntityDescription insertNewObjectForEntityForName:@"TestRelatedEntityA" inManagedObjectContext:moc];
    
    [a kvc_setRelationship:@"relationToB" toObjectWithValue:@"value1" forKey:@"attributeInB" options:(@{KVCCreateObjectOption:@YES})];
    NSManagedObject * b = [a valueForKey:@"relationToB"];

    XCTAssertNotNil(b);
    XCTAssertEqualObjects([b valueForKey:@"relationToA"], a);
}

- (void) testSetRelationshipWithCache
{
    NSManagedObject * a = [NSEntityDescription insertNewObjectForEntityForName:@"TestRelatedEntityA" inManagedObjectContext:moc];
    NSManagedObject * b = [NSEntityDescription insertNewObjectForEntityForName:@"TestRelatedEntityB" inManagedObjectContext:moc];
    [a setValue:@"value1" forKey:@"attributeInA"];
    
    KVCEntitiesCache * cache = [[KVCEntitiesCache alloc] initWithInstanceCaches:
                                @[[[KVCInstancesCache alloc] initWithContext:moc
                                                                  entityName:@"TestRelatedEntityA"
                                                                  primaryKey:@"attributeInA"]]];
    
    [b kvc_setRelationship:@"relationToA" toObjectWithValue:@"value1" forKey:@"attributeInA" options:@{KVCEntitiesCacheOption: cache}];
    
    XCTAssertEqualObjects([b valueForKey:@"relationToA"], a);
}

- (void) testSetRelationshipWithCacheMissAndCreateObject
{
    NSManagedObject * a = [NSEntityDescription insertNewObjectForEntityForName:@"TestRelatedEntityA" inManagedObjectContext:moc];

    KVCEntitiesCache * cache = [[KVCEntitiesCache alloc] initWithInstanceCaches:
                                @[[[KVCInstancesCache alloc] initWithContext:moc
                                                                  entityName:@"TestRelatedEntityB"
                                                                  primaryKey:@"attributeInA"]]];

    [a kvc_setRelationship:@"relationToB" toObjectWithValue:@"value1" forKey:@"attributeInB" options:@{KVCCreateObjectOption: @YES, KVCEntitiesCacheOption: cache}];
    NSManagedObject * b = [a valueForKey:@"relationToB"];
    
    XCTAssertNotNil(b);
    XCTAssertEqualObjects(cache[@"TestRelatedEntityB"][@"value1"], b);
}

- (void) testSetRelationshipToMissingEntity
{
    NSManagedObject * a = [NSEntityDescription insertNewObjectForEntityForName:@"TestRelatedEntityA" inManagedObjectContext:moc];
    NSManagedObject * b = [NSEntityDescription insertNewObjectForEntityForName:@"TestRelatedEntityB" inManagedObjectContext:moc];
    [a setValue:@"value1" forKey:@"attributeInA"];
    [b setValue:@"value1" forKey:@"attributeInB"];
    KVCEntitiesCache * cache = [[KVCEntitiesCache alloc] initWithInstanceCaches:
                                @[[[KVCInstancesCache alloc] initWithContext:moc
                                                                  entityName:@"TestRelatedEntityA"
                                                                  primaryKey:@"attributeInA"]]];
    // Entity B is not in the cache, but will be fetched regularly
    [a kvc_setRelationship:@"relationToB" toObjectWithValue:@"value1" forKey:@"attributeInB" options:@{KVCCreateObjectOption: @YES, KVCEntitiesCacheOption: cache}];
    NSManagedObject * b2 = [a valueForKey:@"relationToB"];
    XCTAssertEqualObjects(b, b2);
}

- (void) testSetRelationshipWithDictionary
{
    NSManagedObject * a = [NSEntityDescription insertNewObjectForEntityForName:@"TestRelatedEntityA" inManagedObjectContext:moc];
    NSManagedObject * b = [NSEntityDescription insertNewObjectForEntityForName:@"TestRelatedEntityB" inManagedObjectContext:moc];
    
    [a setValue:@"value1" forKey:@"attributeInA"];
    
    [b kvc_setValues:@{@"a" : @"value1"} withMappingDictionary:@{@"a": @"relationToA.attributeInA"} options:nil];
    
    XCTAssertEqualObjects([b valueForKey:@"relationToA"], a);
    XCTAssertEqualObjects([a valueForKey:@"relationToB"], b);
}

- (void) testGetReverseRelationshipWithDictionary
{
    NSManagedObject * a = [NSEntityDescription insertNewObjectForEntityForName:@"TestRelatedEntityA" inManagedObjectContext:moc];
    NSManagedObject * b = [NSEntityDescription insertNewObjectForEntityForName:@"TestRelatedEntityB" inManagedObjectContext:moc];
    
    [a setValue:@"value1" forKey:@"attributeInA"];
    [b setValue:a forKey:@"relationToA"];
    
    id values = [b kvc_valuesWithMappingDictionary:@{@"a": @"relationToA.attributeInA"} options:nil];
    
    XCTAssertEqualObjects(values, @{@"a": @"value1"});
}

- (void) testGetReverseRelationshipWithDictionaryToMany
{
    NSManagedObject * a1 = [NSEntityDescription insertNewObjectForEntityForName:@"TestRelatedEntityA" inManagedObjectContext:moc];
    NSManagedObject * a2 = [NSEntityDescription insertNewObjectForEntityForName:@"TestRelatedEntityA" inManagedObjectContext:moc];
    NSManagedObject * b = [NSEntityDescription insertNewObjectForEntityForName:@"TestRelatedEntityB" inManagedObjectContext:moc];
    
    [a1 setValue:@"value1" forKey:@"attributeInA"];
    [a2 setValue:@"value2" forKey:@"attributeInA"];
    [b setValue:[NSSet setWithArray:@[a1, a2 ]] forKey:@"relationToManyAs"];

    // To many relationships are ignored by default
    id values = [b kvc_valuesWithMappingDictionary:@{@"a": @"relationToManyAs.attributeInA"} options:nil];
    XCTAssertEqualObjects(values, @{});
    
    values = [b kvc_valuesWithMappingDictionary:@{@"a": @"relationToManyAs.attributeInA"} options:@{KVCIncludeToManyRelationshipsOption: @YES}];
    XCTAssertEqualObjects([NSSet setWithArray:[values valueForKey:@"a"]], [NSSet setWithArray:(@[@"value1", @"value2"])]);
}

- (void) testSetRelationshipWithSubobjectMapping
{
    NSManagedObject * a = [NSEntityDescription insertNewObjectForEntityForName:@"TestRelatedEntityA" inManagedObjectContext:moc];
    
    id mappingDictionary = @{ @"b" : @{ @"relationToB" : @{@"attr": @"attributeInB" }}};
    
    id values = @{@"b": @{@"attr":@"VALUE"}};
    
    [a kvc_setValues:values withMappingDictionary:mappingDictionary options:nil];
    
    NSManagedObject * b = [a valueForKey:@"relationToB"];
    XCTAssertNotNil(b);
    XCTAssertEqualObjects([b valueForKey:@"attributeInB"], @"VALUE");
}

- (void) testSetRelationshipWithManySubobjectMapping
{
    NSManagedObject * a = [NSEntityDescription insertNewObjectForEntityForName:@"TestRelatedEntityA" inManagedObjectContext:moc];
    
    id mappingDictionary = @{ @"b" : @{ @"relationToManyBs" : @{@"attr": @"attributeInB" }}};
    
    id values = @{@"b": @[@{@"attr":@"VALUE_1"},@{@"attr":@"VALUE_2"}]};
    
    [a kvc_setValues:values withMappingDictionary:mappingDictionary options:nil];
    
    NSSet * b = [a valueForKey:@"relationToManyBs"];
    
    XCTAssertEqual([b count], (NSUInteger)2);
    XCTAssertEqualObjects([b valueForKey:@"attributeInB"], ([NSSet setWithArray:@[@"VALUE_1", @"VALUE_2" ]]));
}

- (void) testSetRelationshipWithExistingSubobjectMapping
{
    NSManagedObject * a = [NSEntityDescription insertNewObjectForEntityForName:@"TestRelatedEntityA" inManagedObjectContext:moc];
    NSManagedObject * b = [NSEntityDescription insertNewObjectForEntityForName:@"TestRelatedEntityB" inManagedObjectContext:moc];
    [b setValue:@"VALUE" forKey:@"attributeInB"];
    
    id mappingDictionary = @{ @"b" : @{ @"relationToB.attributeInB" : @{@"attr": @"attributeInB" }}};
    
    id values = @{@"b": @{@"attr":@"VALUE"}};
    
    [a kvc_setValues:values withMappingDictionary:mappingDictionary options:nil];
        
    NSManagedObject * newb = [a valueForKey:@"relationToB"];

    XCTAssertEqual(b, newb);
}

- (void) testGetReverseRelationshipWithSubobjectMapping
{
    NSManagedObject * a = [NSEntityDescription insertNewObjectForEntityForName:@"TestRelatedEntityA" inManagedObjectContext:moc];
    NSManagedObject * b = [NSEntityDescription insertNewObjectForEntityForName:@"TestRelatedEntityB" inManagedObjectContext:moc];
    [b setValue:@"VALUE" forKey:@"attributeInB"];
    [a setValue:b forKey:@"relationToB"];
    
    id mappingDictionary = @{ @"b" : @{ @"relationToB" : @{@"attr": @"attributeInB" }}};
    
    // Subobjects are ignored by default
    id values = [a kvc_valuesWithMappingDictionary:mappingDictionary options:nil];
    XCTAssertEqualObjects(values, @{});
    
    values = [a kvc_valuesWithMappingDictionary:mappingDictionary options:@{KVCIncludeSubobjectsOption: @YES}];
    XCTAssertEqualObjects(values, @{@"b": @{@"attr":@"VALUE"}});
}

- (void) testGetReverseRelationshipWithManySubobjectsMapping
{
    NSManagedObject * a = [NSEntityDescription insertNewObjectForEntityForName:@"TestRelatedEntityA" inManagedObjectContext:moc];
    NSManagedObject * b1 = [NSEntityDescription insertNewObjectForEntityForName:@"TestRelatedEntityB" inManagedObjectContext:moc];
    NSManagedObject * b2 = [NSEntityDescription insertNewObjectForEntityForName:@"TestRelatedEntityB" inManagedObjectContext:moc];
    [b1 setValue:@"VALUE_1" forKey:@"attributeInB"];
    [b2 setValue:@"VALUE_2" forKey:@"attributeInB"];
    [a setValue:[NSSet setWithArray:@[b1, b2]] forKey:@"relationToManyBs"];
    
    id mappingDictionary = @{ @"b" : @{ @"relationToManyBs" : @{@"attr": @"attributeInB" }}};
    
    // Subobjects are ignored by default
    id values = [a kvc_valuesWithMappingDictionary:mappingDictionary options:nil];
    XCTAssertEqualObjects(values, @{});

    values = [a kvc_valuesWithMappingDictionary:mappingDictionary options:@{KVCIncludeSubobjectsOption: @YES}];
    XCTAssertEqualObjects([NSSet setWithArray:[values valueForKey:@"b"]], [NSSet setWithArray:(@[@{@"attr":@"VALUE_1"}, @{@"attr":@"VALUE_2"}])]);
}

@end
