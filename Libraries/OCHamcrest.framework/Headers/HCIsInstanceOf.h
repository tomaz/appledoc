//
//  OCHamcrest - HCIsInstanceOf.h
//  Copyright 2009 www.hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid
//

    // Inherited
#import <OCHamcrest/HCBaseMatcher.h>


/**
    Tests whether the value is an instance of a class (including subclasses).
*/
@interface HCIsInstanceOf : HCBaseMatcher
{
    Class theClass;
}

+ (HCIsInstanceOf*) isInstanceOf:(Class)type;
- (id) initWithType:(Class)type;

@end


#ifdef __cplusplus
extern "C" {
#endif

/**
    Is the value an instance of a particular type?
*/
id<HCMatcher> HC_instanceOf(Class type);

#ifdef __cplusplus
}
#endif


#ifdef HC_SHORTHAND

/**
    Shorthand for HC_instanceOf, available if HC_SHORTHAND is defined.
*/
#define instanceOf HC_instanceOf

#endif
