//
//  OCHamcrest - HCIsEqual.h
//  Copyright 2009 www.hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid
//

    // Inherited
#import <OCHamcrest/HCBaseMatcher.h>


/**
    Is the object equal to another object, as tested by the isEqual: method?
*/
@interface HCIsEqual : HCBaseMatcher
{
    id object;
}

+ (HCIsEqual*) isEqualTo:(id)equalArg;
- (id) initEqualTo:(id)equalArg;

@end


#ifdef __cplusplus
extern "C" {
#endif

/**
    Is the object equal to another object, as tested by the isEqual: method?
*/
id<HCMatcher> HC_equalTo(id equalArg);

#ifdef __cplusplus
}
#endif


#ifdef HC_SHORTHAND

/**
    Shorthand for HC_equalTo, available if HC_SHORTHAND is defined.
*/
#define equalTo HC_equalTo

#endif
