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

#pragma mark Utility

@implementation NSObject (KVC_isCollection)
- (BOOL) kvc_isCollection {
    return [self isKindOfClass:[NSArray class]]
            || [self isKindOfClass:[NSSet class]]
            || [self isKindOfClass:[NSOrderedSet class]];
}
- (id) kvc_embedInCollectionIfNeeded {
    return [self kvc_isCollection] ? self : @[ self ];
}
@end

#pragma mark -

@implementation NSManagedObject (KVCRelationship)

- (void) kvc_setRelationship:(NSString*)relationshipName with:(id)valueOrValues withMapping:(KVCEntityMapping*)entityMapping options:(NSDictionary*)options
{
    NSEntityDescription * entity = [self entity];
    NSRelationshipDescription * relationshipDesc = [entity relationshipsByName][relationshipName];
    if (relationshipDesc==nil) {
        return;
    }
    
    NSEntityDescription * destinationEntity = [relationshipDesc destinationEntity];
    
    if(relationshipDesc.maxCount==1) {
        id singleObjectValues = valueOrValues;
        id destinationObject = [destinationEntity kvc_fetchObjectInContext:self.managedObjectContext withValues:singleObjectValues withMappingDictionary:entityMapping options:options];
        [self setValue:destinationObject forKey:relationshipName];
    } else {
        id objectsValues = [valueOrValues kvc_embedInCollectionIfNeeded];
        id collection = relationshipDesc.isOrdered ? [NSMutableOrderedSet new] : [NSMutableSet new];
        for (id singleObjectValues in objectsValues) {
            id destinationObject = [destinationEntity kvc_fetchObjectInContext:self.managedObjectContext withValues:singleObjectValues withMappingDictionary:entityMapping options:options];
            [collection addObject:destinationObject];
        }
        [self setValue:collection forKey:relationshipName];
    }
}

- (void) kvc_setRelationship:(NSString*)relationshipName withObjectsWithValues:(id)valueOrValues forKey:(NSString*)key options:(NSDictionary*)options
{
    id objectValues;
    // Box values an key:value dictionaries
    if( ! [valueOrValues kvc_isCollection] ) {
        objectValues = @{key: valueOrValues};
    } else {
        objectValues = [NSMutableArray new];
        for (id value in valueOrValues) {
            [objectValues addObject:@{key: value}];
        }
    }
    
    // Make up an entity mapping
    KVCEntityMapping * mapping = [[KVCEntityMapping alloc] initWithMappingDictionary:nil primaryKey:key entityName:nil];
    [self kvc_setRelationship:relationshipName with:objectValues withMapping:mapping options:options];
}


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
