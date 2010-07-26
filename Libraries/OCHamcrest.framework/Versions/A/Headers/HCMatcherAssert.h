//
//  OCHamcrest - HCMatcherAssert.h
//  Copyright 2009 www.hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid
//

@protocol HCMatcher;


#ifdef __cplusplus
extern "C" {
#endif

void HC_assertThatWithLocation(id testCase, id actual, id<HCMatcher> matcher,
                               const char* fileName, int lineNumber);

#ifdef __cplusplus
}
#endif

/**
    OCUnit integration asserting that actual value satisfies matcher.
*/
#define HC_assertThat(actual, matcher)  \
    HC_assertThatWithLocation(self, actual, matcher, __FILE__, __LINE__)


#ifdef HC_SHORTHAND

/**
    Shorthand for HC_assertThat, available if HC_SHORTHAND is defined.
*/
#define assertThat HC_assertThat

#endif
