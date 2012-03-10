//
//  FormattedStringToDateValueTransformer.h
//  KVCMapping
//
//  Created by Nicolas Bouilleaud on 29/11/11.
//  Copyright (c) 2011 Nicolas Bouilleaud. All rights reserved.
//

#import <Foundation/Foundation.h>

// A Simple, reusable, ValueTransformer using an NSDateFormatter as its engine.
// 
@interface FormattedStringToDateValueTransformer : NSValueTransformer
- (id) initWithDateFormatter:(NSDateFormatter*)dateFormatter;
@end
