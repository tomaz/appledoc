//
//  OCHamcrest - HCBaseMatcher.h
//  Copyright 2009 www.hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid
//

    // Inherited
#import <Foundation/Foundation.h>
#import <OCHamcrest/HCMatcher.h>


/**
    Base class for all Matcher implementations.
    
    Most implementations can just implement matches: and let matches:describingMismatchTo: call
    it. But if it makes more sense to generate the mismatch description during the matching,
    override matches:describingMismatchTo: and have matches: call it with a nil description.
*/
@interface HCBaseMatcher : NSObject<HCMatcher>
@end
