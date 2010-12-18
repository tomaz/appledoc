//
//  OCHamcrest - HCOrderingComparison.h
//  Copyright 2009 www.hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid
//

    // Inherited
#import <OCHamcrest/HCBaseMatcher.h>


@interface HCOrderingComparison : HCBaseMatcher
{
    id value;
    NSComparisonResult minCompare;
    NSComparisonResult maxCompare;
}

+ (HCOrderingComparison*) compare:(id)aValue
                       minCompare:(NSComparisonResult)min
                       maxCompare:(NSComparisonResult)max;
- (id) initComparing:(id)aValue
          minCompare:(NSComparisonResult)min
          maxCompare:(NSComparisonResult)max;

@end


#ifdef __cplusplus
extern "C" {
#endif

/**
    Is value > expected?
*/
id<HCMatcher> HC_greaterThan(id aValue);

/**
    Is value >= expected?
*/
id<HCMatcher> HC_greaterThanOrEqualTo(id aValue);

/**
    Is value < expected?
*/
id<HCMatcher> HC_lessThan(id aValue);

/**
    Is value <= expected?
*/
id<HCMatcher> HC_lessThanOrEqualTo(id aValue);

#ifdef __cplusplus
}
#endif


#ifdef HC_SHORTHAND

/**
    Shorthand for HC_greaterThan, available if HC_SHORTHAND is defined.
*/
#define greaterThan HC_greaterThan

/**
    Shorthand for HC_greaterThan, available if HC_SHORTHAND is defined.
*/
#define greaterThanOrEqualTo HC_greaterThanOrEqualTo

/**
    Shorthand for HC_greaterThan, available if HC_SHORTHAND is defined.
*/
#define lessThan HC_lessThan

/**
    Shorthand for HC_lessThanOrEqualTo, available if HC_SHORTHAND is defined.
*/
#define lessThanOrEqualTo HC_lessThanOrEqualTo

#endif
