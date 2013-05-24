//
//  NSManagedObject+KVCSubobject.m
//  KVCMapping
//
//  Created by Nicolas @ Capitaine Train on 24/05/13.
//
//

#import "NSManagedObject+KVCSubobject.h"
#import "NSEntityDescription+KVCFetching.h"
#import "NSObject+KVCMapping.h"
#import "NSObject+KVCCollection.h"
#import "KVCEntityMapping.h"

@implementation NSManagedObject (KVCSubobject)

- (void) kvc_setRelationship:(NSString*)relationshipName toSubobjectFromValues:(id)values
                usingMapping:(KVCEntityMapping*)entityMapping options:(NSDictionary*)options
{
    NSRelationshipDescription * relationshipDesc = [[self entity] relationshipsByName][relationshipName];
    
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

- (void) kvc_setRelationship:(NSString*)relationshipName toSubobjectsFromValuesCollection:(id)valuesCollection
                usingMapping:(KVCEntityMapping*)entityMapping options:(NSDictionary*)options
{
    NSRelationshipDescription * relationshipDesc = [[self entity] relationshipsByName][relationshipName];
    
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

@end
