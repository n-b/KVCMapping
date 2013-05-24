//
//  NSObject+KVCCollection.h
//  KVCMapping
//
//  Created by Pierre de La Morinerie on 24/05/13.
//
//

@interface NSObject (KVCCollection)
- (BOOL) kvc_isCollection;
- (id) kvc_embedInCollectionIfNeeded;
@end
