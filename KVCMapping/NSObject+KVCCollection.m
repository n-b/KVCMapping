//
//  NSObject+KVCCollection.m
//  KVCMapping
//
//  Created by Pierre de La Morinerie on 24/05/13.
//
//

#import "NSObject+KVCCollection.h"

@implementation NSObject (KVCCollection)
- (BOOL) kvc_isCollection {
    return [self isKindOfClass:[NSArray class]]
    || [self isKindOfClass:[NSSet class]]
    || [self isKindOfClass:[NSOrderedSet class]];
}
- (id) kvc_embedInCollectionIfNeeded {
    return [self kvc_isCollection] ? self : @[ self ];
}
@end
