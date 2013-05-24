//
//  NSManagedObject+KVCRelationship.m
//  CapitaineTrain
//
//  Created by Nicolas Bouilleaud - Capitaine Train on 19/09/12.
//  Copyright (c) 2012 Capitaine Train. All rights reserved.
//

#import "NSManagedObject+KVCRelationship.h"
#import "NSEntityDescription+KVCFetching.h"
#import "NSObject+KVCMapping.h"
#import "KVCMappingOptions.h"
#import "NSObject+KVCCollection.h"

#pragma mark -

@implementation NSManagedObject (KVCRelationship)

// 1 -> id
- (void) kvc_setRelationship:(NSString*)relationshipName toObjectWithValue:(id)value
                      forKey:(NSString*)key options:(NSDictionary*)options
{
    NSEntityDescription * entity = [self entity];
    NSRelationshipDescription * relationshipDesc = [entity relationshipsByName][relationshipName];
    
    NSParameterAssert(!relationshipDesc.isToMany);
    
    NSEntityDescription * destinationEntity = [relationshipDesc destinationEntity];
    if(nil==destinationEntity) {
        return;
    }
    
    id destinationObject = [destinationEntity kvc_fetchObjectInContext:self.managedObjectContext withValue:value forKey:key options:options];
    [self setValue:destinationObject forKey:relationshipName];
}

// n -> id
// [user setRelationship:@"passengers" toObjectsWithValueIn:@[@1, @2, @3] forKey:@"identifier" options:nil]
- (void) kvc_setRelationship:(NSString*)relationshipName toObjectsWithValueIn:(id)valueCollection
                      forKey:(NSString*)key options:(NSDictionary*)options
{
    NSEntityDescription * entity = [self entity];
    NSRelationshipDescription * relationshipDesc = [entity relationshipsByName][relationshipName];
    
    NSParameterAssert([valueCollection kvc_isCollection]);
    NSParameterAssert(relationshipDesc.isToMany);
    
    NSEntityDescription * destinationEntity = [relationshipDesc destinationEntity];
    if(nil==destinationEntity) {
        return;
    }
    
    id destinationObjects = relationshipDesc.isOrdered ? [NSMutableOrderedSet new] : [NSMutableSet new];
    for (id value in valueCollection) {
        id destinationObject = [destinationEntity kvc_fetchObjectInContext:self.managedObjectContext withValue:value forKey:key options:options];
        [destinationObjects addObject:destinationObject];
    }
    [self setValue:destinationObjects forKey:relationshipName];
}

#pragma mark -

// 1 -> subobject
- (void) kvc_setRelationship:(NSString*)relationshipName toSubobjectFromValues:(id)values
                usingMapping:(KVCEntityMapping*)entityMapping options:(NSDictionary*)options
{
    NSEntityDescription * entity = [self entity];
    NSRelationshipDescription * relationshipDesc = [entity relationshipsByName][relationshipName];
    
    NSParameterAssert(!relationshipDesc.isToMany);
    
    NSEntityDescription * destinationEntity = [relationshipDesc destinationEntity];
    if(nil==destinationEntity) {
        return;
    }
    
    id destinationObject;
    if(entityMapping.primaryKey) {
        id primaryValue = [entityMapping extractValueFor:entityMapping.primaryKey fromValues:values];
        destinationObject = [destinationEntity kvc_fetchObjectInContext:self.managedObjectContext withValue:primaryValue forKey:entityMapping.primaryKey options:options];
    } else {
        // Alway create subobjects with no primarykey
        destinationObject = [NSEntityDescription insertNewObjectForEntityForName:destinationEntity.name inManagedObjectContext:self.managedObjectContext];
    }
    // set other values
    [destinationObject kvc_setValues:values withEntityMapping:entityMapping options:options];
    
    [self setValue:destinationObject forKey:relationshipName];
}

// n -> subobjects
- (void) kvc_setRelationship:(NSString*)relationshipName toSubobjectsFromValuesCollection:(id)valuesCollection
                usingMapping:(KVCEntityMapping*)entityMapping options:(NSDictionary*)options
{
    NSEntityDescription * entity = [self entity];
    NSRelationshipDescription * relationshipDesc = [entity relationshipsByName][relationshipName];
    
    NSParameterAssert([valuesCollection kvc_isCollection]);
    NSParameterAssert(relationshipDesc.isToMany);
    
    NSEntityDescription * destinationEntity = [relationshipDesc destinationEntity];
    if(nil==destinationEntity) {
        return;
    }
    
    id destinationObjects = relationshipDesc.isOrdered ? [NSMutableOrderedSet new] : [NSMutableSet new];
    for (id values in valuesCollection) {
        id destinationObject;
        if(entityMapping.primaryKey) {
            id primaryValue = [entityMapping extractValueFor:entityMapping.primaryKey fromValues:values];
            destinationObject = [destinationEntity kvc_fetchObjectInContext:self.managedObjectContext withValue:primaryValue forKey:entityMapping.primaryKey options:options];
        } else {
            // Alway create subobjects with no primarykey
            destinationObject = [NSEntityDescription insertNewObjectForEntityForName:destinationEntity.name inManagedObjectContext:self.managedObjectContext];
        }
        // set other values
        [destinationObject kvc_setValues:values withEntityMapping:entityMapping options:options];

        [destinationObjects addObject:destinationObject];
    }
    [self setValue:destinationObjects forKey:relationshipName];
}


#pragma mark -

- (id) kvc_relationshipValues:(NSString*)relationshipName forKey:(NSString*)key options:(NSDictionary*)options
{
    NSRelationshipDescription * relationshipDesc = [[self entity] relationshipsByName][relationshipName];
    id valueOrValues = [self valueForKey:relationshipName];
    if(relationshipDesc.maxCount==1) {
        return [valueOrValues valueForKey:key];
    } else {
        if ([options[KVCIncludeToManyRelationshipsOption] boolValue]) {
            if([valueOrValues respondsToSelector:@selector(allObjects)]) {
                return [[valueOrValues allObjects] valueForKey:key];
            } else if([valueOrValues respondsToSelector:@selector(array)]) {
                return [[valueOrValues array] valueForKey:key];
            }
        }
        return nil;
    }
}

- (id) kvc_relationshipValues:(NSString*)relationshipName withMapping:(KVCEntityMapping*)mapping options:(NSDictionary*)options
{
    if ([options[KVCIncludeSubobjectsOption] boolValue]) {
        NSRelationshipDescription * relationshipDesc = [[self entity] relationshipsByName][relationshipName];
        
        id objects = [self valueForKey:relationshipName];
        if(relationshipDesc.maxCount==1) {
            return [objects kvc_valuesWithEntityMapping:mapping options:options];
        } else {
            NSMutableArray * result = [NSMutableArray new];
            for (id object in objects) {
                [result addObject:[object kvc_valuesWithEntityMapping:mapping options:options]];
            }
            return [NSArray arrayWithArray:result];
        }
    }
    return nil;
}

@end
