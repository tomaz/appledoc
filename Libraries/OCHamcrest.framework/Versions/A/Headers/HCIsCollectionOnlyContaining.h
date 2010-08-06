//
//  OCHamcrest - HCIsCollectionOnlyContaining.h
//  Copyright 2009 www.hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid
//

    // Inherited
#import <OCHamcrest/HCBaseMatcher.h>


/**
    Matches collections that only contain elements satisfying a given matcher.

    This matcher will never match an empty collection.
*/
@interface HCIsCollectionOnlyContaining : HCBaseMatcher
{
    id<HCMatcher> matcher;
}

+ (HCIsCollectionOnlyContaining*) isCollectionOnlyContaining:(id<HCMatcher>)aMatcher;
- (id) initWithMatcher:(id<HCMatcher>)aMatcher;

@end


#ifdef __cplusplus
extern "C" {
#endif

/**
    Matches collections that only contain elements satisfying any of a list of items.

    For example,
    <code>[NSArray arrayWithObjects:@"a", "b", @"c", nil]</code>
    would satisfy
    <code>onlyContains(lessThan(@"d"), nil)</code>.
    
    If an item is not a matcher, it is equivalent to equalTo(item), so the array in the example
    above would also satisfy
    <code>onlyContains(@"a", @"b", @"c", nil)</code>.

    @param item comma-separated list of items ending with nil.
*/
id<HCMatcher> HC_onlyContains(id item, ...);

#ifdef __cplusplus
}
#endif


#ifdef HC_SHORTHAND

/**
    Shorthand for HC_onlyContains, available if HC_SHORTHAND is defined.
*/
#define onlyContains HC_onlyContains

#endif
