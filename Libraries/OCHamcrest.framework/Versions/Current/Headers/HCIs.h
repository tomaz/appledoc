//
//  OCHamcrest - HCIs.h
//  Copyright 2009 www.hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid
//

    // Inherited
#import <OCHamcrest/HCBaseMatcher.h>


/**
    Decorates another HCMatcher, retaining the behavior but allowing tests to be slightly more
    expressive.

    For example:
@code
assertThat(cheese, equalTo(smelly))
@endcode
    vs.
@code
assertThat(cheese, is(equalTo(smelly)))
@endcode
*/
@interface HCIs : HCBaseMatcher
{
    id<HCMatcher> matcher;
}

+ (HCIs*) is:(id<HCMatcher>)aMatcher;
- (id) initWithMatcher:(id<HCMatcher>)aMatcher;

@end


#ifdef __cplusplus
extern "C" {
#endif

/**
    Decorates an item, providing shortcuts to the frequently used is(equalTo(x)).
    
    For example:
@code
assertThat(cheese, is(equalTo(smelly)))
@endcode
    vs.
@code
assertThat(cheese, is(smelly))
@endcode
*/
id<HCMatcher> HC_is(id item);

#ifdef __cplusplus
}
#endif


#ifdef HC_SHORTHAND

/**
    Shorthand for HC_is, available if HC_SHORTHAND is defined.
*/
#define is HC_is

#endif
