//
//  NSManagedObject+KVCRelationship.m
//  CapitaineTrain
//
//  Created by Nicolas Bouilleaud - Capitaine Train on 19/09/12.
//  Copyright (c) 2012 Capitaine Train. All rights reserved.
//

#import "NSManagedObject+KVCRelationship.h"
#import "NSEntityDescription+KVCFetching.h"
#import "NSObject+KVCCollection.h"

@implementation NSManagedObject (KVCRelationship)

- (void) kvc_setRelationship:(NSString*)relationshipName toObjectWithValue:(id)value
                      forKey:(NSString*)key options:(NSDictionary*)options
{
    NSRelationshipDescription * relationshipDesc = [[self entity] relationshipsByName][relationshipName];
    
    NSParameterAssert(!relationshipDesc.isToMany);
    
    NSEntityDescription * destinationEntity = [relationshipDesc destinationEntity];
    if(nil==destinationEntity) {
        return;
    }
    
    id destinationObject = [destinationEntity kvc_fetchObjectInContext:self.managedObjectContext withValue:value forKey:key options:options];
    [self setValue:destinationObject forKey:relationshipName];
}

- (void) kvc_setRelationship:(NSString*)relationshipName toObjectsWithValueIn:(id)valueCollection
                      forKey:(NSString*)key options:(NSDictionary*)options
{
    NSRelationshipDescription * relationshipDesc = [[self entity] relationshipsByName][relationshipName];
    
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

@end
