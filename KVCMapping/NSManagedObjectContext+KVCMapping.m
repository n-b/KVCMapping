//
//  NSManagedObjectContext+KVCMapping.m
//  CapitaineTrain
//
//  Created by Nicolas @ Capitaine Train on 15/05/13.
//  Copyright (c) 2013 Capitaine Train. All rights reserved.
//

#import "NSManagedObjectContext+KVCMapping.h"
#import "NSObject+KVCMapping.h"
#import "NSEntityDescription+KVCFetching.h"

@implementation NSManagedObjectContext (KVCMapping)

- (NSDictionary*) kvc_importObjects:(NSDictionary *)objectsValues
                  withModelMapping:(KVCModelMapping *)modelMapping
                           options:(NSDictionary *)options
{
    NSMutableDictionary *parsedObjectsInfo = [NSMutableDictionary new];
    
    for (NSString * key in [objectsValues allKeys]) {
        KVCEntityMapping * entityMapping = [modelMapping entityMappingForKey:key];
        
        id valueForClass = objectsValues[key];
        
        NSDictionary *dictionaries = ([valueForClass isKindOfClass:[NSArray class]]      ? valueForClass :
                                      [valueForClass isKindOfClass:[NSDictionary class]] ? [NSArray arrayWithObject:valueForClass] :
                                      nil);
        
        for (NSDictionary * objectDict in dictionaries) {
            NSManagedObject * object = [self kvc_importObject:objectDict withEntityMapping:entityMapping options:options];
            if(object) {
                parsedObjectsInfo[object.objectID] = objectDict;
            }
        }
    }
    
    return [NSDictionary dictionaryWithDictionary:parsedObjectsInfo];
}

- (NSManagedObject *) kvc_importObject:(NSDictionary*)values
                    withEntityMapping:(KVCEntityMapping*)entityMapping
                              options:(NSDictionary*)options
{
    // All the objects returned by the CT server have an "id" field, mapped to the "identifier" property in CoreData
    id primaryValue = [entityMapping kvc_extractValueForProperty:entityMapping.primaryKey fromValues:values];
    NSEntityDescription * entityDescription = [self.persistentStoreCoordinator.managedObjectModel entitiesByName][entityMapping.entityName];
    id object = [entityDescription kvc_fetchObjectInContext:self withValue:primaryValue forKey:entityMapping.primaryKey options:options];
    [object kvc_setValues:values withEntityMapping:entityMapping options:options];
    return object;
}
@end

