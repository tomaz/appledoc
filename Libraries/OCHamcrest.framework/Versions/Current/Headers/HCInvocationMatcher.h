//
//  OCHamcrest - HCInvocationMatcher.h
//  Copyright 2009 www.hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid
//

    // Inherited
#import <OCHamcrest/HCBaseMatcher.h>


/**
    Supporting class for matching a feature of an object.
    
    Tests whether the result of passing a given invocation to the value satisfies a given matcher.
*/
@interface HCInvocationMatcher : HCBaseMatcher
{
    NSInvocation* invocation;
    id<HCMatcher> subMatcher;
}

/**
    Helper method for creating an invocation.
    
    A class is specified only so we can determine the method signature.
*/
+ (NSInvocation*) createInvocationForSelector:(SEL)selector onClass:(Class)aClass;

- (id) initWithInvocation:(NSInvocation*)anInvocation matching:(id<HCMatcher>)aMatcher;

/**
    Returns string representation of the invocation's selector.
*/
- (NSString*) stringFromSelector;

@end
