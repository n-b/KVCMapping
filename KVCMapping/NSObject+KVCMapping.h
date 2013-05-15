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

// setValue:forKey:withEntityMapping:options:
//
// Set a `value` for a given `wantedKey` of the receiver, using the `entityMapping` to map the value to a real key.
// * a single `wantedKey` may map to several actual properties or relationships in the receiver. (See KVCKeyMapping)
// * `wantedKey` can be an NSString or an NSNumber. (See KVCEntityMapping)
// * `value` should be of the expected type for the KVCKeyMapping
//
// If the receiver is an NSManagedObject, this can set relationships and create subobjects.
// 
// If the receiver is an NSManagedObject, attempt to automatically coerce the data to the expected type of the property.
//
// Does nothing if no mapping is found, or if the value can't be converted to the expected type.
- (void) kvc_setValue:(id)value forKey:(id)wantedKey withEntityMapping:(KVCEntityMapping*)entityMapping options:(NSDictionary*)options;

// Batch Method.
// Calls - kvc_setValue:forKey:withEntityMapping: repeatedly with the passed `values`.
//
// `values` can be an NSDictionary or an NSArray;
// If `values` is a dictionary, its keys are used as the `wantedKey`s.
// If `values` is an array, its indexes, as NSNumbers, are used as the `wantedKey`s.
- (void) kvc_setValues:(id)values withEntityMapping:(KVCEntityMapping*)entityMapping options:(NSDictionary*)options;

// Convenience variants:
// Automatically create a KVCEntityMapping with `kvcMappingDictionary`
- (void) kvc_setValue:(id)value forKey:(NSString*)wantedKey withMappingDictionary:(NSDictionary*)kvcMappingDictionary options:(NSDictionary*)options;
- (void) kvc_setValues:(id)values withMappingDictionary:(NSDictionary*)kvcMappingDictionary options:(NSDictionary*)options;
@end

