//
//  NSObject+KVCMapping.h
//  KVCMapping
//
//  Created by Nicolas Bouilleaud on 18/06/11.
//  Copyright 2011 Nicolas Bouilleaud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KVCEntityMapping.h"

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
 		@"updated_at": @{ @"property": @"updateDate", @"transformer": @"ISOFormattedStringToDateValueTransformer"
 	}
 This would use the value for the key "updated_at", 
 pass it through the the NSValueTransformer registered for the name "ISOFormattedStringToDateValueTransformer",
 and assign it to the object for the key "updateDate".

 Mapping the same key for several properties
 -------------------------------------------

 The mapping dictionary can map the same external key to several internal model keys, by using an array of strings instead of a single string :
  	@{
 		@"updated_at": @[ @{@"property: @"updateDate"}, @{@"property": @"creationDate"} ]
 	}

 Or even using different value transformers for each model key :
  	@{
 		@"duration": @[ @{@"property": @"durationMinutes, @"transformer": @"DurationToMinutesValueTransformer"},
                        @{@"property": @"durationHours", @"transformer" @"DurationToHoursValueTransformer"} ]
 	}
  
 */
- (void) setKVCValue:(id)value forKey:(NSString*)wantedKey withMappingDictionary:(NSDictionary*)kvcMappingDictionnary options:(NSDictionary*)options;

/*
 Calls - setValue:forKey:withMappingDictionary: repeatedly with the key-value pairs in `keyedValues` if values is a dictionary, 
 or with each value (using the index as the key) if `values` is an array.
 */
- (void) setKVCValues:(id)values withMappingDictionary:(NSDictionary*)mappingDict options:(NSDictionary*)options;

- (void) kvc_setValues:(id)values withEntityMapping:(KVCEntityMapping*)entityMapping options:(NSDictionary*)options;
- (void) kvc_setValue:(id)value forKey:(id)wantedKey withEntityMapping:(KVCEntityMapping*)entityMapping options:(NSDictionary*)options;

@end

@interface NSDictionary (KVCMapping)
- (id) extractValueForPrimaryKeyWithEntityMapping:(KVCEntityMapping*)entityMapping;
@end

@interface NSArray (KVCMapping)
- (id) extractValueForPrimaryKeyWithEntityMapping:(KVCEntityMapping*)entityMapping;
@end

