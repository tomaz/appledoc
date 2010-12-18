//
//  OCHamcrest - HCIsIn.h
//  Copyright 2009 www.hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid
//

    // Inherited
#import <OCHamcrest/HCBaseMatcher.h>


@interface HCIsIn : HCBaseMatcher
{
    id collection;
}

+ (HCIsIn*) isInCollection:(id)aCollection;
- (id) initWithCollection:(id)aCollection;

@end


#ifdef __cplusplus
extern "C" {
#endif

id<HCMatcher> HC_isIn(id collection);

#ifdef __cplusplus
}
#endif


#ifdef HC_SHORTHAND

/**
    Shorthand for HC_isIn, available if HC_SHORTHAND is defined.
*/
#define isIn HC_isIn

#endif
