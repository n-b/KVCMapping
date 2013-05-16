//
//  KVCEntityMapping.m
//  CapitaineTrain
//
//  Created by Nicolas @ Capitaine Train on 06/05/13.
//  Copyright (c) 2013 Capitaine Train. All rights reserved.
//

#import "KVCEntityMapping.h"
#import "NSAttributeDescription+Coercion.h"
#import "NSManagedObject+KVCRelationship.h"

#pragma mark - Private Methods

@interface KVCModelMapping ()
@property (readonly) NSDictionary * entityMappings;
@end

@interface KVCEntityMapping ()
@property (readonly) NSArray * keyMappings;
@end

@interface KVCKeyMapping (KVCMappingDictionary)
- (id) initWithRawMapping:(id)rawMapping_ key:(id)key_;
@end

/****************************************************************************/
#pragma mark - KVCModelMapping

@implementation KVCModelMapping

- (KVCEntityMapping*) entityMappingForKey:(id)key
{
    return self.entityMappings[key];
}

- (KVCEntityMapping*) entityMappingForEntityName:(NSString*)entityName
{
    for (KVCEntityMapping * entityMapping in [self.entityMappings allValues]) {
        if ([entityMapping.entityName isEqualToString:entityName]) {
            return entityMapping;
        }
    }
    return nil;
}

@end
/****************************************************************************/
#pragma mark - KVCEntityMapping

@implementation KVCEntityMapping

- (id) initWithKeyMappings:(NSArray*)keyMappings_ primaryKey:(NSString*)primaryKey_ entityName:(NSString*)entityName_
{
    self = [super init];
    _keyMappings = keyMappings_;
    _primaryKey = primaryKey_;
    _entityName = entityName_;
    if(_primaryKey) {
        NSParameterAssert([[self mappingsTo:_primaryKey] count]>0);
    }
    return self;
}

- (NSArray*) mappingsForKey:(id)key
{
    return [self.keyMappings filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(KVCKeyMapping* keymapping, NSDictionary *bindings) {
        return [keymapping.key isEqual:key];
    }]];
}

- (NSArray*) allKeys
{
    return [self.keyMappings valueForKey:@"key"];
}

- (NSArray*)mappingsTo:(NSString*)propertyOrRelationship
{
    NSMutableArray * mappings = [NSMutableArray new];
    for (id keyMapping in self.keyMappings) {
        if( ([keyMapping respondsToSelector:@selector(property)] &&
             [[keyMapping property] isEqualToString:propertyOrRelationship] )
           || ([keyMapping respondsToSelector:@selector(relationship)] &&
               [[keyMapping relationship] isEqualToString:propertyOrRelationship] ) )
        {
            [mappings addObject:keyMapping];
        }
    }
    return [NSArray arrayWithArray:mappings];
}

- (id) extractValueFor:(id)propertyOrRelationship fromValues:(id)values
{
    NSArray * mappings = [self mappingsTo:propertyOrRelationship];
    if([mappings count]==0) {
        return nil;
    } else {
        id keyMapping = mappings[0];
        id key = [keyMapping key];
        id value;
        if([values isKindOfClass:[NSDictionary class]]) {
            value = values[key];
        } else if ([values isKindOfClass:[NSArray class]]) {
            value = values[[key unsignedIntegerValue]];
        }
        if([keyMapping respondsToSelector:@selector(transformer)] && [keyMapping transformer]) {
            value = [[keyMapping transformer] transformedValue:value];
        }
        return value;
    }
}

@end

/****************************************************************************/
#pragma mark - Mapping Dictionary Factories

@implementation NSString (KVCMappingDictionary)
- (NSArray*) kvc_splitWithSeparator:(NSString*)separator
{
    NSRange range = [self rangeOfString:separator];
    if(range.location==NSNotFound) {
        return @[self];
    } else {
        return @[[self substringToIndex:range.location], [self substringFromIndex:range.location+range.length]];
    }
}
@end

NSString * const KVCMapTransformerSeparator = @":";
NSString * const KVCMapPrimaryKeySeparator = @".";

@implementation KVCModelMapping (KVCMappingDictionary)
- (id)initWithMappingDictionary:(NSDictionary *)rawModelMapping_
{
    self = [super init];
    NSMutableDictionary * dict = [NSMutableDictionary new];
    for (NSArray * keys in rawModelMapping_) {
        NSDictionary * entityDict = rawModelMapping_[keys];
        NSParameterAssert([entityDict count]==1);
        NSString * entityNameAndPrimaryKey = [entityDict allKeys][0];
        NSArray * components = [entityNameAndPrimaryKey componentsSeparatedByString:KVCMapPrimaryKeySeparator];
        NSString * entityName = components[0];
        NSString * primaryKey = [components count]>1 ? components[1] : nil;
        NSDictionary * entityMappingDictionary = [entityDict allValues][0];
        KVCEntityMapping * entityMapping = [[KVCEntityMapping alloc] initWithMappingDictionary:entityMappingDictionary
                                                                                    primaryKey:primaryKey
                                                                                    entityName:entityName];
        if([keys isKindOfClass:[NSArray class]]) {
            for (id key in keys) {
                dict[key] = entityMapping;
            }
        } else {
            dict[keys] = entityMapping;
        }
    }
    _entityMappings = [NSDictionary dictionaryWithDictionary:dict];
    
    return self;
}
@end

@implementation KVCEntityMapping (KVCMappingDictionary)
- (id)initWithMappingDictionary:(NSDictionary *)rawEntityMapping_ primaryKey:(NSString*)primaryKey_ entityName:(NSString*)entityName_
{
    NSMutableArray * keyMappings = [NSMutableArray new];
    // For each key
    if(rawEntityMapping_) {
        for (NSString* key_ in rawEntityMapping_) {
            id rawMappings_ = rawEntityMapping_[key_];
            if(![rawMappings_ isKindOfClass:[NSArray class]]) {
                rawMappings_ = @[rawMappings_];
            }
            // For each mapping
            for (id rawMapping_ in rawMappings_) {
                [keyMappings addObject:[[KVCKeyMapping alloc] initWithRawMapping:rawMapping_ key:key_]];
            }
        }
    } else {
        [keyMappings addObject:[[KVCKeyMapping alloc] initWithRawMapping:primaryKey_ key:primaryKey_]];
    }
    return [self initWithKeyMappings:[NSArray arrayWithArray:keyMappings] primaryKey:primaryKey_ entityName:entityName_];
}
@end

@implementation KVCKeyMapping

- (id) initWithKey:(id)key_
{
    self = [super init];
    _key = key_;
    return self;
}

- (id) initWithRawMapping:(id)rawMapping_ key:(id)key_
{
    if([rawMapping_ isKindOfClass:[self class]]) {
        ((KVCKeyMapping*)rawMapping_)->_key = key_;
        return rawMapping_;
    }

    Class class = [[self class] _mappingClassWithRawMapping:rawMapping_];
    NSParameterAssert([class isSubclassOfClass:[self class]] && ![class isEqual:[self class]]);
    return [[class alloc] initWithRawMapping:rawMapping_ key:key_];
}

+ (Class) _mappingClassWithRawMapping:(id)rawMapping_
{
    // Parse raw mapping string
    if([rawMapping_ isKindOfClass:[NSString class]]) {
        
        // Relationship
        if([rawMapping_ rangeOfString:KVCMapPrimaryKeySeparator].location != NSNotFound) {
            return [KVCRelationshipMapping class];
        }
        
        // Property
        return [KVCPropertyMapping class];
    }
    
    // Subobject
    if([rawMapping_ isKindOfClass:[NSDictionary class]]) {
        return [KVCSubobjectMapping class];
    }
    return Nil;
}
@end

@implementation KVCPropertyMapping
- (id) initWithRawMapping:(NSString*)mappingString key:(id)key_
{
    self = [super initWithKey:key_];
    NSArray * components = [mappingString componentsSeparatedByString:KVCMapTransformerSeparator];
    if([components count]==2){
        _property = components[1];
        _transformer = [NSValueTransformer valueTransformerForName:components[0]];
        NSParameterAssert(_transformer);
    } else {
        _property = components[0];
    }
    return self;
}
@end

@implementation KVCRelationshipMapping
- (id) initWithRawMapping:(NSString*)mappingString key:(id)key_
{
    self = [super initWithKey:key_];
    NSArray * components = [mappingString componentsSeparatedByString:KVCMapPrimaryKeySeparator];
    NSParameterAssert([components count]==2);
    _relationship = components[0];
    _foreignKey = components[1];
    return self;
}
@end

@implementation KVCSubobjectMapping
- (id) initWithRawMapping:(NSDictionary*)relationshipDictionary key:(id)key_
{
    NSParameterAssert([relationshipDictionary count]==1);
    self = [super initWithKey:key_];
    NSArray * components = [[relationshipDictionary allKeys][0] componentsSeparatedByString:KVCMapPrimaryKeySeparator];
    _relationship = components[0];
    _mapping = [[KVCEntityMapping alloc] initWithMappingDictionary:[relationshipDictionary allValues][0]
                                                        primaryKey:[components count]==2?components[1]:nil
                                                        entityName:nil];
    return self;
}
@end

/****************************************************************************/
#pragma mark - Assign Value

@implementation KVCKeyMapping (KVCAssignValue)
- (void) assignValue:(id)value toObject:(id)object options:(NSDictionary*)options {
    [self doesNotRecognizeSelector:_cmd];
}
- (id) valueFromObject:(id)object options:(NSDictionary*)options {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}
@end

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

@implementation KVCRelationshipMapping (KVCAssignValue)
- (void) assignValue:(id)value toObject:(id)object options:(NSDictionary*)options
{
    [object kvc_setRelationship:self.relationship withObjectsWithValues:value forKey:self.foreignKey options:options];
}
- (id) valueFromObject:(id)object options:(NSDictionary*)options
{
    return [object kvc_relationshipValues:self.relationship forKey:self.foreignKey options:options];
}
@end

@implementation KVCSubobjectMapping (KVCAssignValue)
- (void) assignValue:(id)value toObject:(id)object options:(NSDictionary*)options
{
    [object kvc_setRelationship:self.relationship with:value withMapping:self.mapping options:options];
}
- (id) valueFromObject:(id)object options:(NSDictionary*)options
{
    return [object kvc_relationshipValues:self.relationship withMapping:self.mapping options:options];
}
@end

/****************************************************************************/
#pragma mark Descriptions

@implementation KVCKeyMapping (KVCDescription)
- (NSString*) description
{
    return [self descriptionWithIndent:0];
}
- (NSString*) descriptionWithIndent:(NSUInteger)indent
{
    return [NSString stringWithFormat:@"Mapping key %@",self.key];
}
@end

@implementation KVCEntityMapping (KVCDescription)
- (NSString*) description
{
    return [self descriptionWithIndent:0];
}
- (NSString*) descriptionWithIndent:(NSUInteger)indent
{
    NSMutableString * description = [NSMutableString stringWithFormat:@"Entity Mapping: %p primary key: %@",self, self.primaryKey];
    for (KVCKeyMapping* keyMapping in self.keyMappings) {
        [description appendString:@"\n"];
        for (NSUInteger i=0; i<indent+1; i++) {
            [description appendString:@"\t"];
        }
        [description appendString:[keyMapping descriptionWithIndent:indent]];
    }
    return description;
}
@end

@implementation KVCPropertyMapping (KVCDescription)
- (NSString*) descriptionWithIndent:(NSUInteger)indent
{
    return [NSString stringWithFormat:@"%@ to property %@, transformer %@",[super descriptionWithIndent:indent], self.property, self.transformer];
}
@end

@implementation KVCRelationshipMapping (KVCDescription)
- (NSString*) descriptionWithIndent:(NSUInteger)indent
{
    return [NSString stringWithFormat:@"%@ to relationship %@, foreign key %@",[super descriptionWithIndent:indent], self.relationship, self.foreignKey];
}
@end

@implementation KVCSubobjectMapping (KVCDescription)
- (NSString*) descriptionWithIndent:(NSUInteger)indent
{
    return [NSString stringWithFormat:@"%@ to relationship %@, submapping %@",[super descriptionWithIndent:indent], self.relationship, [self.mapping descriptionWithIndent:indent+1]];
}
@end

@implementation KVCModelMapping (KVCDescription)
- (NSString*) description
{
    NSMutableString * description = [NSMutableString stringWithFormat:@"Model Mapping: %p",self];
    for (KVCEntityMapping* entityMappinMapping in self.entityMappings) {
        [description appendString:@"\n\t"];
        [description appendString:[entityMappinMapping descriptionWithIndent:1]];
    }
    return description;
}
@end
