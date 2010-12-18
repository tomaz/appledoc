//
//  OCHamcrest - HCIsAnything.h
//  Copyright 2009 www.hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid
//

    // Inherited
#import <OCHamcrest/HCBaseMatcher.h>


/**
    A matcher that always returns @c YES.
*/
@interface HCIsAnything : HCBaseMatcher
{
    NSString* description;
}

+ (HCIsAnything*) isAnything;
+ (HCIsAnything*) isAnythingWithDescription:(NSString*)aDescription;
- (id) init;
- (id) initWithDescription:(NSString*)aDescription;

@end


#ifdef __cplusplus
extern "C" {
#endif

/**
    This matcher always evaluates to @c YES.
*/
id<HCMatcher> HC_anything();

/**
    This matcher always evaluates to <code>YES</code>.
    
    @param aDescription A meaningful string used when describing itself.
*/
id<HCMatcher> HC_anythingWithDescription(NSString* aDescription);

#ifdef __cplusplus
}
#endif


#ifdef HC_SHORTHAND

/**
    Shorthand for HC_anything, available if HC_SHORTHAND is defined.
*/
#define anything HC_anything

/**
    Shorthand for HC_anythingWithDescription, available if HC_SHORTHAND is defined.
*/
#define anythingWithDescription HC_anythingWithDescription

#endif
