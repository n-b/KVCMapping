//
//  NSManagedObject+KVCRelationship.m
//  CapitaineTrain
//
//  Created by Nicolas Bouilleaud - Capitaine Train on 19/09/12.
//  Copyright (c) 2012 Capitaine Train. All rights reserved.
//

#import "NSManagedObject+KVCRelationship.h"
#import "NSManagedObject+KVCFetching.h"
#import "NSObject+KVCMapping.h"

#pragma mark NSManagedObject (KVCRelationship)

@implementation NSManagedObject (KVCRelationship)

- (void) setRelationship:(NSString*)relationshipName withObjectsWithValues:(id)valueOrValues forKey:(NSString*)key options:(NSDictionary*)options
{
    id objectValues;
    if([valueOrValues isKindOfClass:[NSArray class]]) {
        objectValues = [NSMutableArray new];
        for (id value in valueOrValues) {
            [objectValues addObject:@{key: value}];
        }
        objectValues = [NSArray arrayWithArray:objectValues];
    } else {
        objectValues = @{key: valueOrValues};
    }
    
    KVCEntityMapping * mapping = [[KVCEntityMapping alloc] initWithMappingDictionary:@{KVCPrimaryKey: key, KVCMapping: @{key: key}}];
    [self setRelationship:relationshipName with:objectValues withMapping:mapping options:options];
}

- (void) setRelationship:(NSString*)relationshipName with:(id)valueOrValues withMapping:(KVCEntityMapping*)entityMapping options:(NSDictionary*)options
{
    NSEntityDescription * entity = [self entity];
    NSRelationshipDescription * relationshipDesc = [entity relationshipsByName][relationshipName];
    if (relationshipDesc==nil) {
        return;
    }
    
    NSEntityDescription * destinationEntity = [relationshipDesc destinationEntity];
    // If cache is used and the destination entity is not in the cache, ignore it.
    KVCEntitiesCache * entitiesCache = options[KVCEntitiesCacheOption];
    if(entitiesCache!=nil && entitiesCache[destinationEntity.name]==nil) {
        return;
    }
    
    if(relationshipDesc.maxCount==1) {
        id singleObjectValues = valueOrValues;
        id destinationObject = [destinationEntity fetchObjectInContext:self.managedObjectContext withValues:singleObjectValues withMappingDictionary:entityMapping options:options];
        [self setValue:destinationObject forKey:relationshipName];
    } else {
        id objectsValues = [valueOrValues isKindOfClass:[NSArray class]]||[valueOrValues isKindOfClass:[NSSet class]]||[valueOrValues isKindOfClass:[NSOrderedSet class]] ? valueOrValues : @[valueOrValues];
        id collection = relationshipDesc.isOrdered ? [NSMutableOrderedSet new] : [NSMutableSet new];
        for (id singleObjectValues in objectsValues) {
            id destinationObject = [destinationEntity fetchObjectInContext:self.managedObjectContext withValues:singleObjectValues withMappingDictionary:entityMapping options:options];
            [collection addObject:destinationObject];
        }
        [self setValue:collection forKey:relationshipName];
    }
}

@end
