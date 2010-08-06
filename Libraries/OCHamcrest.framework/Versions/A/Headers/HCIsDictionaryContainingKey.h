//
//  OCHamcrest - HCIsDictionaryContainingKey.h
//  Copyright 2009 www.hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid
//

    // Inherited
#import <OCHamcrest/HCBaseMatcher.h>


@interface HCIsDictionaryContainingKey : HCBaseMatcher
{
    id<HCMatcher> keyMatcher;
}

+ (HCIsDictionaryContainingKey*) isDictionaryContainingKey:(id<HCMatcher>)theKeyMatcher;
- (id) initWithKeyMatcher:(id<HCMatcher>)theKeyMatcher;

@end


#ifdef __cplusplus
extern "C" {
#endif

id<HCMatcher> HC_hasKey(id item);

#ifdef __cplusplus
}
#endif


#ifdef HC_SHORTHAND

/**
    Shorthand for HC_hasKey, available if HC_SHORTHAND is defined.
*/
#define hasKey HC_hasKey

#endif
