//
//  OCHamcrest - HCIsDictionaryContaining.h
//  Copyright 2009 www.hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid
//

    // Inherited
#import <OCHamcrest/HCBaseMatcher.h>


@interface HCIsDictionaryContaining : HCBaseMatcher
{
    id<HCMatcher> keyMatcher;
    id<HCMatcher> valueMatcher;
}

+ (HCIsDictionaryContaining*) isDictionaryContainingKey:(id<HCMatcher>)theKeyMatcher
                                                  value:(id<HCMatcher>)theValueMatcher;
- (id) initWithKeyMatcher:(id<HCMatcher>)theKeyMatcher valueMatcher:(id<HCMatcher>)theValueMatcher;

@end


#ifdef __cplusplus
extern "C" {
#endif

id<HCMatcher> HC_hasEntry(id key, id value);

#ifdef __cplusplus
}
#endif


#ifdef HC_SHORTHAND

/**
    Shorthand for HC_hasEntry, available if HC_SHORTHAND is defined.
*/
#define hasEntry HC_hasEntry

#endif
