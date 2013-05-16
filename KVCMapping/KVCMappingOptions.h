//
//  KVCMappingOptions.h
//  KVCMapping
//
//  Created by Nicolas @ Capitaine Train on 16/05/13.
//
//

// Mapping and fetching options

// A NSNumber (bool)
// When YES, if no object is found in a fetch or when setting a relationship,
// a new object matching the requirement is created in returned.
extern NSString* const KVCCreateObjectOption;

// A KVCEntitiesCache
// If an entities cache is passed, no actual fetch requests will be performed.
// Instead, the cache will be looked up for matching objects.
extern NSString* const KVCEntitiesCacheOption;


// Reverse Mapping options

// A NSNumber (bool)
// Include two-many relationships when obtaining values from an object.
// (By default, only the properties and the to-one relationships are returned.)
extern NSString* const KVCIncludeToManyRelationshipsOption;

// A NSNumber (bool)
// Include subobjects values when obtaining values from an object.
// (By default, only the properties and the to-one relationships are returned.)
extern NSString* const KVCIncludeSubobjectsOption;
