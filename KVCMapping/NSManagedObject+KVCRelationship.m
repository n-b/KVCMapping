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

@end
