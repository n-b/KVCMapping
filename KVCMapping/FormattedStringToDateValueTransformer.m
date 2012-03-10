//
//  FormattedStringToDateValueTransformer.m
//  KVCMapping
//
//  Created by Nicolas Bouilleaud on 29/11/11.
//  Copyright (c) 2011 Nicolas Bouilleaud. All rights reserved.
//

#import "FormattedStringToDateValueTransformer.h"

@implementation FormattedStringToDateValueTransformer
{
    NSDateFormatter * dateFormatter;
}

- (id) initWithDateFormatter:(NSDateFormatter*)dateFormatter_
{
    self = [super init];
    if (self) {
        dateFormatter = dateFormatter_;
    }
    return self;
}

#pragma mark -

+ (Class)transformedValueClass
{
    return [NSDate self];
}

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id)transformedValue:(id)value
{
    NSAssert([value isKindOfClass:[NSString self]],@"");
    return [dateFormatter dateFromString:value];
}

- (id)reverseTransformedValue:(id)value
{
    NSAssert([value isKindOfClass:[NSDate self]],@"");
    return [dateFormatter stringFromDate:value];
}

@end
