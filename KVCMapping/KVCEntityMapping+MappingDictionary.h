//
//  KVCEntityMapping+MappingDictionary.h
//  KVCMapping
//
//  Created by Nicolas @ Capitaine Train on 24/05/13.
//
//

#import "KVCEntityMapping.h"

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
 NSEntityMapping
 @"last_name" : @"lastName" } } } // to-many relationship
 */
@interface KVCEntityMapping (MappingDictionary)
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
@interface KVCModelMapping (MappingDictionary)
- (id)initWithMappingDictionary:(NSDictionary *)rawModelMapping_;
@end
