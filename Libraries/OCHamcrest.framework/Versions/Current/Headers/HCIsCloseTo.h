//
//  OCHamcrest - HCIsCloseTo.h
//  Copyright 2009 www.hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid
//

    // Inherited
#import <OCHamcrest/HCBaseMatcher.h>


/**
    Is the value a number equal to a value within some range of acceptable error?
*/
@interface HCIsCloseTo : HCBaseMatcher
{
    double value;
    double error;
}

+ (HCIsCloseTo*) isCloseTo:(double)aValue within:(double)anError;
- (id) initWithValue:(double)aValue error:(double)anError;

@end


#ifdef __cplusplus
extern "C" {
#endif

/**
    Is the value a number equal to a value within some range of acceptable error?
*/
id<HCMatcher> HC_closeTo(double aValue, double anError);

#ifdef __cplusplus
}
#endif


#ifdef HC_SHORTHAND

/**
    Shorthand for HC_closeTo, available if HC_SHORTHAND is defined.
*/
#define closeTo HC_closeTo

#endif
