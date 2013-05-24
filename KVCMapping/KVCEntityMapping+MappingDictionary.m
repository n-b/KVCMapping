//
//  KVCEntityMapping+MappingDictionary.m
//  KVCMapping
//
//  Created by Nicolas @ Capitaine Train on 24/05/13.
//
//

#import "KVCEntityMapping+MappingDictionary.h"

@interface KVCKeyMapping (MappingDictionary)
- (id) initWithRawMapping:(id)rawMapping_ key:(id)key_;
@end

/****************************************************************************/
#pragma mark - Mapping Dictionary Factories

@implementation NSString (MappingDictionary)
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

@implementation KVCModelMapping (MappingDictionary)
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
    self.entityMappings = [NSDictionary dictionaryWithDictionary:dict];
    
    return self;
}
@end

@implementation KVCEntityMapping (MappingDictionary)
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
