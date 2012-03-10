//
//  NSObject+KVCMapping.h
//  KVCMapping
//
//  Created by Nicolas Bouilleaud on 18/06/11.
//  Copyright 2011 Nicolas Bouilleaud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (NSObject_KVCMapping)
/* 
 KVC Mapping
 -----------
 
 The passed mapping dictionary is used to translate the wantedKey (the key name in the external representation,
 like a webservice) to the real object property.
 The NSDictionary keys and values should only be NSStrings.
 
 An example of a simple mapping dictionary would be : 
 	{
 		"ID" = "identifier";
 	}
 It can be used for assigning this data:
    {
    	"ID" = "1234";
    }
 to an object such as : 
    @interface SomeObject
    @property id identifier;
    @end
 
  
 Type Coercion and Value Transformers
 ------------------------------------
 
 More complex mapping can specify valuetransformers by name in the mapping dictionary, such as :
 	{
 		"updated_at" = "ISOFormattedStringToDateValueTransformer:updateDate";
 	}
 This would use the value for the key "updated_at", 
 pass it through the the NSValueTransformer registered for the name "ISOFormattedStringToDateValueTransformer",
 and assign it to the object for the key "updateDate".

 For NSManagedObjects, setValue:forKey:withMappingDictionary also does automatic type coercion from string to numbers.
 */
- (void) setValue:(id)value forKey:(NSString*)wantedKey withMappingDictionary:(NSDictionary*)kvcMappingDictionnary;
- (void) setValuesForKeysWithDictionary:(NSDictionary *)keyedValues withMappingDictionary:(NSDictionary*)kvcMappingDictionnary;
@end

