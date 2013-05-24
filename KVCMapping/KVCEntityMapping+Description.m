//
//  KVCEntityMapping+Description.m
//  KVCMapping
//
//  Created by Nicolas @ Capitaine Train on 24/05/13.
//
//

#import "KVCEntityMapping.h"

@implementation KVCKeyMapping (Description)
- (NSString*) description
{
    return [self descriptionWithIndent:0];
}
- (NSString*) descriptionWithIndent:(NSUInteger)indent
{
    return [NSString stringWithFormat:@"Mapping key %@",self.key];
}
@end

@implementation KVCEntityMapping (Description)
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

@implementation KVCPropertyMapping (Description)
- (NSString*) descriptionWithIndent:(NSUInteger)indent
{
    return [NSString stringWithFormat:@"%@ to property %@, transformer %@",[super descriptionWithIndent:indent], self.property, self.transformer];
}
@end

@implementation KVCRelationshipMapping (Description)
- (NSString*) descriptionWithIndent:(NSUInteger)indent
{
    return [NSString stringWithFormat:@"%@ to relationship %@, foreign key %@",[super descriptionWithIndent:indent], self.relationship, self.foreignKey];
}
@end

@implementation KVCSubobjectMapping (Description)
- (NSString*) descriptionWithIndent:(NSUInteger)indent
{
    return [NSString stringWithFormat:@"%@ to relationship %@, submapping %@",[super descriptionWithIndent:indent], self.relationship, [self.mapping descriptionWithIndent:indent+1]];
}
@end

@implementation KVCModelMapping (Description)
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
