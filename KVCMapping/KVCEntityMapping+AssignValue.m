//
//  KVCEntityMapping+AssignValue.m
//  KVCMapping
//
//  Created by Nicolas @ Capitaine Train on 24/05/13.
//
//

#import "KVCEntityMapping+AssignValue.h"
#import "NSAttributeDescription+Coercion.h"
#import "KVCMappingOptions.h"
#import "NSObject+KVCMapping.h"
#import "NSObject+KVCCollection.h"
#import "NSManagedObject+KVCRelationship.h"
#import "NSManagedObject+KVCSubobject.h"

#pragma mark -

@implementation KVCKeyMapping (KVCAssignValue)
- (void) assignValue:(id)value toObject:(id)object options:(NSDictionary*)options {
    [self doesNotRecognizeSelector:_cmd];
}
- (id) valueFromObject:(id)object options:(NSDictionary*)options {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}
@end

#pragma mark -

@implementation KVCPropertyMapping (KVCAssignValue)
- (void) assignValue:(id)value toObject:(id)object options:(NSDictionary*)options
{
    if(self.transformer) {
        value = [self.transformer transformedValue:value];
    }
    
    // If the object is a NSManagedObject and the property is a CoreData attribute,
    // use the attribute description to convert value, if necessary.
    if([[object class] isSubclassOfClass:[NSManagedObject class]]) {
        NSAttributeDescription * attributeDesc = [[object entity] attributesByName][self.property];
        if(attributeDesc) {
            value = [attributeDesc kvc_coerceValue:value];
        }
    }
    
    [object setValue:value forKey:self.property];
}
- (id) valueFromObject:(id)object options:(NSDictionary*)options
{
    id value = [object valueForKey:self.property];
    
    if(self.transformer) {
        if([[self.transformer class] allowsReverseTransformation]) {
            return [self.transformer reverseTransformedValue:value];
        } else {
            return nil;
        }
    }
    return value;
}
@end

#pragma mark -

@implementation KVCRelationshipMapping (KVCAssignValue)
- (void) assignValue:(id)value toObject:(id)object options:(NSDictionary*)options
{
    NSRelationshipDescription * relationshipDesc = [[object entity] relationshipsByName][self.relationship];
    if(!relationshipDesc.isToMany) {
        [object kvc_setRelationship:self.relationship toObjectWithValue:value forKey:self.foreignKey options:options];
    } else {
        value =  [value kvc_embedInCollectionIfNeeded];
        [object kvc_setRelationship:self.relationship toObjectsWithValueIn:value forKey:self.foreignKey options:options];
    }
}
- (id) valueFromObject:(id)object options:(NSDictionary*)options
{
    NSRelationshipDescription * relationshipDesc = [[object entity] relationshipsByName][self.relationship];
    if(!relationshipDesc.isToMany) {
        return [[object valueForKey:self.relationship] valueForKey:self.foreignKey];
    } else if ([options[KVCIncludeToManyRelationshipsOption] boolValue]) {
        if(relationshipDesc.isOrdered) {
            return [[[object valueForKey:self.relationship] array] valueForKey:self.foreignKey];
        } else {
            return [[[object valueForKey:self.relationship] allObjects] valueForKey:self.foreignKey];
        }
    }
    return nil;
}
@end

#pragma mark -

@implementation KVCSubobjectMapping (KVCAssignValue)
- (void) assignValue:(id)value toObject:(id)object options:(NSDictionary*)options
{
    NSRelationshipDescription * relationshipDesc = [[object entity] relationshipsByName][self.relationship];
    if(!relationshipDesc.isToMany) {
        [object kvc_setRelationship:self.relationship toSubobjectFromValues:value usingMapping:self.mapping options:options];
    } else {
        value =  [value kvc_embedInCollectionIfNeeded];
        [object kvc_setRelationship:self.relationship toSubobjectsFromValuesCollection:value usingMapping:self.mapping options:options];
    }
}
- (id) valueFromObject:(id)object options:(NSDictionary*)options
{
    if ([options[KVCIncludeSubobjectsOption] boolValue]) {
        NSRelationshipDescription * relationshipDesc = [[object entity] relationshipsByName][self.relationship];
        
        if(!relationshipDesc.isToMany) {
            return [[object valueForKey:self.relationship] kvc_valuesWithEntityMapping:self.mapping options:options];
        } else {
            NSMutableArray * result = [NSMutableArray new];
            for (id subobject in [object valueForKey:self.relationship]) {
                [result addObject:[subobject kvc_valuesWithEntityMapping:self.mapping options:options]];
            }
            return [NSArray arrayWithArray:result];
        }
    }
    return nil;
}
@end
