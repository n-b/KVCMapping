//
//  NSObject+KVCMapping.h
//  KVCMapping
//
//  Created by Nicolas Bouilleaud on 18/06/11.
//  Copyright 2011 Nicolas Bouilleaud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (KVCMapping)
/* 
 KVC Mapping
 -----------
 
 The passed mapping dictionary is used to translate the wantedKey (the key name in the external representation,
 like a webservice) to the real object property.
 The NSDictionary keys and values should only be NSStrings.
 
 An example of a simple mapping dictionary would be : 
 	@{
 		@"ID": @"identifier"
 	}
 It can be used for assigning this data:
    @{
    	@"ID": @"1234"
    }
 to an object such as : 
    @interface SomeObject
    @property id identifier;
    @end
 
 Type Coercion and Value Transformers
 ------------------------------------
 
 More complex mapping can specify valuetransformers by name in the mapping dictionary, such as :
 	@{
 		@"updated_at": @"ISOFormattedStringToDateValueTransformer:updateDate"
 	}
 This would use the value for the key "updated_at", 
 pass it through the the NSValueTransformer registered for the name "ISOFormattedStringToDateValueTransformer",
 and assign it to the object for the key "updateDate".

 Using the same wantedKey for several real keys
 ----------------------------------------------

 The mapping dictionary can map the same external key to several internal model keys, by using an array of strings instead of a single string :
  	@{
 		@"updated_at": @[ @"updateDate", @"creationDate" ]
 	}

 Or even using different value transformers for each model key :
  	@{
 		@"duration": @[ @"DurationToMinutesValueTransformer:durationMinutes", @"DurationToHoursValueTransformer:durationHours" ]
 	}
 
 Automatic Type Coercion
 -----------------------
 
 For NSManagedObjects, - setValue:forKey:withMappingDictionary also does automatic type coercion from string to numbers and vice-versa.
 
 */
- (void) setValue:(id)value forKey:(NSString*)wantedKey withMappingDictionary:(NSDictionary*)kvcMappingDictionnary;

/*
 Calls - setValue:forKey:withMappingDictionary: repeatedly with the key-value pairs in `keyedValues`.
 */
- (void) setValuesForKeysWithDictionary:(NSDictionary *)keyedValues withMappingDictionary:(NSDictionary*)kvcMappingDictionnary;
@end

#pragma mark -

/*
 * Helper methods
 */
@interface NSString (KVCMappingKeysHelperMethods)

// Formats a transformer key, <transformer>:<key>.
//
- (NSString*) usingKVCValueTransformerNamed:(NSString*)valueTransformerName;
@end