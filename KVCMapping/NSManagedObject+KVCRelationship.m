//
//  NSManagedObject+KVCRelationship.m
//  CapitaineTrain
//
//  Created by Nicolas Bouilleaud - Capitaine Train on 19/09/12.
//  Copyright (c) 2012 Capitaine Train. All rights reserved.
//

#import "NSManagedObject+KVCRelationship.h"
#import "NSManagedObject+KVCFetching.h"

#pragma mark Helper Methods

@implementation NSString (KVCMappingKeysHelperMethods)

- (NSString*) usingKVCKeyInDestinationEntity:(NSString*)keyInDestinationEntity;
{
    return [NSString stringWithFormat:@"%@:%@", self, keyInDestinationEntity];
}

@end

#pragma mark NSManagedObject (KVCRelationship)

@implementation NSManagedObject (KVCRelationship)

- (id) setRelationship:(NSString*)relationshipName withObjectWithValue:(id)value forKey:(NSString*)key createObject:(BOOL)createObject entitiesCache:(KVCEntitiesCache*)entitiesCache
{
    NSEntityDescription * entity = [self entity];
    NSRelationshipDescription * relationshipDesc = [entity relationshipsByName][relationshipName];
    if (relationshipDesc==nil || relationshipDesc.maxCount!=1)
        return nil;
    
    NSEntityDescription * destinationEntity = [relationshipDesc destinationEntity];
    
    // If the destination entity is not in the cache, ignore it.
    if(entitiesCache!=nil && entitiesCache[destinationEntity.name]==nil)
        return nil;
    
    id destinationObject = [destinationEntity fetchObjectInContext:self.managedObjectContext withValue:value forKey:key createObject:createObject instancesCache:entitiesCache[destinationEntity.name]];
    
    [self setValue:destinationObject forKey:relationshipName];
    
    return destinationObject;
}

- (id) setRelationship:(NSString*)relationshipName withObjectWithValue:(id)value forKey:(NSString*)key createObject:(BOOL)createObject
{
    return [self setRelationship:relationshipName withObjectWithValue:value forKey:key createObject:createObject entitiesCache:nil];
}

- (void) setRelationshipsWithDictionary:(NSDictionary*)keyedRelationships withMappingDictionary:(NSDictionary *)mapping createObjects:(BOOL)createObjects entitiesCache:(KVCEntitiesCache*)entitiesCache
{
    for (NSString * wantedKey in keyedRelationships)
    {
        NSArray * components = [mapping[wantedKey] componentsSeparatedByString:@":"];
        if([components count]==2)
        {
            NSString * relationshipName = components[0];
            NSString * keyInDestinationEntity = components[1];
            [self setRelationship:relationshipName withObjectWithValue:keyedRelationships[wantedKey] forKey:keyInDestinationEntity createObject:createObjects entitiesCache:entitiesCache];
        }
    }
}

- (void) setRelationshipsWithDictionary:(NSDictionary*)keyedRelationships withMappingDictionary:(NSDictionary *)mapping createObjects:(BOOL)createObjects
{
    [self setRelationshipsWithDictionary:keyedRelationships withMappingDictionary:mapping createObjects:createObjects entitiesCache:nil];
}

@end
