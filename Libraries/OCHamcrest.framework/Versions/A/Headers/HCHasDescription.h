//
//  OCHamcrest - HCHasDescription.h
//  Copyright 2009 www.hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid
//

    // Inherited
#import <OCHamcrest/HCInvocationMatcher.h>


/**
    Does the object's description satisfy a given matcher?
*/
@interface HCHasDescription : HCInvocationMatcher
{
}

+ (HCHasDescription*) hasDescription:(id<HCMatcher>)descriptionMatcher;
- (id) initWithDescription:(id<HCMatcher>)descriptionMatcher;

@end


#ifdef __cplusplus
extern "C" {
#endif

/**
    Evaluates whether [item description] satisfies a given matcher.

    Example: hasDescription(equalTo(result))
*/
id<HCMatcher> HC_hasDescription(id item);

#ifdef __cplusplus
}
#endif


#ifdef HC_SHORTHAND

/**
    Shorthand for HC_hasDescription, available if HC_SHORTHAND is defined.
*/
#define hasDescription HC_hasDescription

#endif
