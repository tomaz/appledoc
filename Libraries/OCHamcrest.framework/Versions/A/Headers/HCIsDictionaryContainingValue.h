//
//  OCHamcrest - HCIsDictionaryContainingValue.h
//  Copyright 2009 www.hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid
//

    // Inherited
#import <OCHamcrest/HCBaseMatcher.h>


@interface HCIsDictionaryContainingValue : HCBaseMatcher
{
    id<HCMatcher> valueMatcher;
}

+ (HCIsDictionaryContainingValue*) isDictionaryContainingValue:(id<HCMatcher>)theValueMatcher;
- (id) initWithValueMatcher:(id<HCMatcher>)theValueMatcher;

@end


#ifdef __cplusplus
extern "C" {
#endif

id<HCMatcher> HC_hasValue(id item);

#ifdef __cplusplus
}
#endif


#ifdef HC_SHORTHAND

/**
    Shorthand for HC_hasValue, available if HC_SHORTHAND is defined.
*/
#define hasValue HC_hasValue

#endif
