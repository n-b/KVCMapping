//
//  NSManagedObject+KVCRelationship.m
//  CapitaineTrain
//
//  Created by Nicolas Bouilleaud on 19/09/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "NSManagedObject+KVCRelationship.h"
#import "NSManagedObject+KVCFetching.h"

/******************************************************************************/
#pragma mark NSManagedObject (KVCRelationship)

@implementation NSManagedObject (KVCRelationship)

- (id) setRelationship:(NSString*)relationshipName withObjectWithValue:(id)value forKey:(NSString*)key createObject:(BOOL)createObject
{
    NSEntityDescription * entity = [self entity];
    NSRelationshipDescription * relationshipDesc = [entity relationshipsByName][relationshipName];
    if (relationshipDesc==nil || relationshipDesc.maxCount!=1)
        return nil;
    
    NSEntityDescription * destinationEntity = [relationshipDesc destinationEntity];
    
    id destinationObject = [destinationEntity fetchObjectInContext:self.managedObjectContext withValue:value forKey:key createObject:createObject];
    
    [self setValue:destinationObject forKey:relationshipName];
    
    return destinationObject;
}

- (void) setRelationshipsWithDictionary:(NSDictionary*)keyedRelationships withMappingDictionary:(NSDictionary *)mapping createObjects:(BOOL)createObjects
{
    for (NSString * wantedKey in keyedRelationships)
    {
        NSArray * components = [mapping[wantedKey] componentsSeparatedByString:@":"];
        if([components count]==2)
        {
            NSString * relationshipName = components[0];
            NSString * keyInDestinationEntity = components[1];
            [self setRelationship:relationshipName withObjectWithValue:keyedRelationships[wantedKey] forKey:keyInDestinationEntity createObject:createObjects];
        }
    }
}

@end
