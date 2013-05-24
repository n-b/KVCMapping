//
//  KVCEntityMapping.h
//  CapitaineTrain
//
//  Created by Nicolas @ Capitaine Train on 06/05/13.
//  Copyright (c) 2013 Capitaine Train. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KVCEntityMapping, KVCKeyMapping, KVCPropertyMapping, KVCRelationshipMapping, KVCSubobjectMapping;

#pragma mark - KVCModelMapping

// Model Mapping
// Maps arbitrary keys to entityMapping
@interface KVCModelMapping : NSObject
- (KVCEntityMapping*) entityMappingForKey:(id)key;
- (KVCEntityMapping*) entityMappingForEntityName:(NSString*)entityName;
- (NSArray*) keysForEntityName:(NSString*)entityName;
@end

#pragma mark - KVCEntityMapping

// maps an external object representation to its internal properties and relationships.
// Each external key is mapped to one or several KVCKeyMappings.
@interface KVCEntityMapping : NSObject

@property (readonly) NSString* entityName;

// Returns the KVCKeyMappings for this data key.
//
// `key` can be an NSString (if the external object representation is an NSDictionary)
// or an NSNumber (if the external object representation is an NSArray).
- (NSArray*)mappingsForKey:(id)key;

// All keys in mapping
- (NSArray*) allKeys;

// The Primary Key for the Entity in the external representation.
// used in KVCRelationshipMapping, when
@property (readonly) id primaryKey;

// Reverse mapping

// Return the external mappings for a given property or relationship.
- (NSArray*)mappingsTo:(NSString*)propertyOrRelationship;

// Given the name of a property or relationship, extract the associated value from a collection of `values`.
//
// The collection of `values` is usually a dictionary, but can also be an array. In this case, the key
// in the mapping is expected to be an NSNumber that provides the index of the value in the `values` array.
//
// If the mapping associated to the property defines a value transformer, the returned value
// will be converted using this transformer.
- (id) extractValueFor:(id)propertyOrRelationship fromValues:(id)values;

@end

#pragma mark - KVCKeyMapping

// Abstract Key mapping base class
@interface KVCKeyMapping : NSObject
@property (readonly) id key;
@end

#pragma mark - KVCPropertyMapping

// Key <-> Property mapping, with an optional Value Transformer

/*
 Mapping Dictionary:
 
 Map to 1 property:
 @{ @"externalkey" : @"internalproperty" }
 
 Map using a value transformer:
 @{ @"externalkey" : @"transformername:internalproperty" }
 
 Map to two properties, using different value transformers:
 @{ @"full_name" : @[@"ExtractFirstName:firstName", @"ExtractLastName:lastName"] }
 */
@interface KVCPropertyMapping : KVCKeyMapping
@property (readonly) NSString * property;
@property (readonly) NSValueTransformer * transformer;
@end

#pragma mark - KVCRelationshipMapping

// Key <-> Relationship mapping.
// In the data, values are mapped to a foreign key in the remote object(s)  :
// The mapping works the same for to-one or to-many relationships.
//
// This only makes sense when using NSManagedObject, as we need to find out the remote entity automatically.

/*
 Mapping Dictionary:

 @{ @"externalkey" : @"relationship.foreignkey" }
 Given a Company *-. Enployee data model,
 This:
 @{ @"company" : @"company.identifier" }
 can be used to map data of the form
 @{ @"first_name": @"John", @"last_name": @"Doe, @"company": @"1234" }
 while this:
 @{ @"employees" : @"employees.identifier" }
 can be used to map data of the form
 @{ @"company_name": @"ACME Inc.", @"employees": @[ @"1", @"2", @"27", @"42" ] }
 */
@interface KVCRelationshipMapping : KVCKeyMapping
@property (readonly) NSString * relationship;
@property (readonly) NSString * foreignKey;
@end

// Key <-> Subobject mapping
// In the data, values are mapped to values of subobject, using the subobject mapping dictionary.
// The mapping works the same for to-one or to-many relationships.
//
// This only makes sense when using NSManagedObject, as we need to find out the remote entity automatically.

/*
 Mapping Dictionary:

 @{ @"externalkey" : @"relationship.identifier", mappingDict }
 e.g. this:
 @{ @"company_name": @"name", @"employees" : @{ @"employees.identifier": @{ @"first_name": @"firstName", @"last_name": @"lastName" } } }
 can be used to map data like this:
 @{ @"company_name": @"Avengers Inc.", @"employees": @[ @{@"first_name": @"Tony", @"last_name": @"Stark"}, @{ @"first_name": @"Bruce", @"last_name": @"Banner"} ] }
 */
@interface KVCSubobjectMapping : KVCKeyMapping
@property (readonly) NSString * relationship;
@property (readonly) KVCEntityMapping * mapping;
@end

#pragma mark - Assign Value

@interface KVCKeyMapping (KVCAssignValue)
// Interpret the value and set it to the object, depending of the receiver's settings.
// Base implementation does nothing.
- (void) assignValue:(id)value toObject:(id)object options:(NSDictionary*)options;

// Obtain the external value from the object for this mapping.
// Base implementation does nothing.
- (id) valueFromObject:(id)object options:(NSDictionary*)options;
@end

#pragma mark - Mapping Dictionary Factories

/*
 Parse a Mapping Dictionary in a KVCEntityMapping
 
 Examples of Mapping Dictionary:
 
 * Map keys to properties
 @{ @"id" : @"identifier",
 @"first_name" : @"firstName",
 @"last_name" : @"lastName" }
 
 * Map one key to several properties
 @{ @"id" : @"identifier",
 @"modified_at" : @[@"openDate",@"updateDate"] }
 
 * Map using a value transformer
 @{ @"id" : @"identifier",
 @"city_name" : @"uppercase:firstName" }
 
 * Map values from an array
 @{ @0 : @"identifier",
 @1 : @"firstName",
 @2 : @"lastName" }
 
 * Map to relationships
 @{ @"first_name" : @"firstName",
 @"last_name" : @"lastName"
 @"partner": @"partner.identifier",      // to-one relationship
 @"children" : @"children.identifier" }  // to-many relationship
 
 * Map to subobjects
 @{ @"first_name" : @"firstName",
 @"last_name" : @"lastName"
 @"partner": @{ @"partner.identifier": @{@"id": @"identifier,
                                         @"first_name" : @"firstName",
                                         @"last_name" : @"lastName" } }      // to-one relationship
 @"children" : @{ @"children.identifier": @{@"id": @"identifier,
                                            @"first_name" : @"firstName",
                                            @"last_name" : @"lastName" } } } // to-many relationship
 */
@interface KVCEntityMapping (KVCMappingDictionary)
- (id)initWithMappingDictionary:(NSDictionary *)rawEntityMapping_ primaryKey:(NSString*)primaryKey_ entityName:(NSString*)entityName_;
@end

/* 
 Parse a complete Model Mapping Dictionary

 Examples:
 
 * Maps the values for the key @"user" to the "User" entity, with no primary key.
 { @"user" : @{@"User" :  @{ @"first_name" : @"firstName",
                              @"last_name" : @"lastName" } } }

 * ... using "identifier" as the primary key.
 { @"user" : @{@"User.identifier" :  @{ @"id" : @"identifier",
                                        @"first_name" : @"firstName",
                                        @"last_name" : @"lastName" } } }

 * ... maps both the "user" and "users" keys.
 { [@"user", @"users"] : @{@"User.identifier" :  @{ @"id" : @"identifier",
                                                    @"first_name" : @"firstName",
                                                    @"last_name" : @"lastName" } } }

 
 */
@interface KVCModelMapping (KVCMappingDictionary)
- (id)initWithMappingDictionary:(NSDictionary *)rawModelMapping_;
@end
