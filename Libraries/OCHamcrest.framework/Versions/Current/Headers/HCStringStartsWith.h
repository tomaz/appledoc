//
//  OCHamcrest - HCStringStartsWith.h
//  Copyright 2009 www.hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid
//

    // Inherited
#import <OCHamcrest/HCSubstringMatcher.h>


/**
    Tests if the argument is a string that starts with a substring.
*/
@interface HCStringStartsWith : HCSubstringMatcher
{
}

+ (HCStringStartsWith*) stringStartsWith:(NSString*)aSubstring;

@end


#ifdef __cplusplus
extern "C" {
#endif

id<HCMatcher> HC_startsWith(NSString* aSubstring);

#ifdef __cplusplus
}
#endif


#ifdef HC_SHORTHAND

/**
    Shorthand for HC_startsWith, available if HC_SHORTHAND is defined.
*/
#define startsWith HC_startsWith

#endif
