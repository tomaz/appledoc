//
//  OCHamcrest - HCIsNil.h
//  Copyright 2009 www.hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid
//

    // Inherited
#import <OCHamcrest/HCBaseMatcher.h>


/**
    Is the value @c nil?
*/
@interface HCIsNil : HCBaseMatcher
{
}

+ (HCIsNil*) isNil;

@end


#ifdef __cplusplus
extern "C" {
#endif

/**
    Matches if the value is @c nil.
*/
id<HCMatcher> HC_nilValue();

/**
    Matches if the value is not @c nil.
*/
id<HCMatcher> HC_notNilValue();

#ifdef __cplusplus
}
#endif


#ifdef HC_SHORTHAND

/**
    Shorthand for HC_nilValue, available if HC_SHORTHAND is defined.
*/
#define nilValue HC_nilValue

/**
    Shorthand for HC_notNilValue, available if HC_SHORTHAND is defined.
*/
#define notNilValue HC_notNilValue

#endif
