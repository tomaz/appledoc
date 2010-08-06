//
//  OCHamcrest - HCWrapInMatcher.h
//  Copyright 2009 www.hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid
//

@protocol HCMatcher;


#ifdef __cplusplus
extern "C" {
#endif

/**
    Returns @a item wrapped (if necessary) in an HCIsEqual matcher.
    
    @a item is returned as-is if it is already an HCMatcher.
*/
id<HCMatcher> HC_wrapInMatcher(id item);

#ifdef __cplusplus
}
#endif
