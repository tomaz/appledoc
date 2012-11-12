//
//  OCHamcrest - HCAssertThat.m
//  Copyright 2012 hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Docs: http://hamcrest.github.com/OCHamcrest/
//  Source: https://github.com/hamcrest/OCHamcrest
//

#import "HCAssertThat.h"

#import "HCStringDescription.h"
#import "HCMatcher.h"

#if TARGET_OS_IPHONE
    #import <objc/runtime.h>
#else
    #import <objc/objc-class.h>
#endif


/**
    Create OCUnit failure
    
    With OCUnit's extension to NSException, this is effectively the same as
@code
[NSException failureInFile: [NSString stringWithUTF8String:fileName]
                    atLine: lineNumber
           withDescription: description]
@endcode
    except we use an NSInvocation so that OCUnit (SenTestingKit) does not have to be linked.
 */
static NSException *createOCUnitException(const char* fileName, int lineNumber, NSString *description)
{
    NSException *result = nil;

    // See http://www.omnigroup.com/mailman/archive/macosx-dev/2001-February/021441.html
    // for an explanation of how to use create an NSInvocation of a class method.
    SEL selector = @selector(failureInFile:atLine:withDescription:);
    NSMethodSignature *signature =
        [[NSException class]->isa instanceMethodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:[NSException class]];
    [invocation setSelector:selector];
    
    id fileArg = [NSString stringWithUTF8String:fileName];
    [invocation setArgument:&fileArg atIndex:2];
    [invocation setArgument:&lineNumber atIndex:3];
    [invocation setArgument:&description atIndex:4];
    
    [invocation invoke];
    [invocation getReturnValue:&result];
    return result;
}

static NSException *createAssertThatFailure(const char *fileName, int lineNumber, NSString *description)
{
    // If the Hamcrest client has linked to OCUnit, generate an OCUnit failure.
    if (NSClassFromString(@"SenTestCase") != Nil)
        return createOCUnitException(fileName, lineNumber, description);

    NSString *failureReason = [NSString stringWithFormat:@"%s:%d: matcher error: %@",
                                                        fileName, lineNumber, description];
    return [NSException exceptionWithName:@"Hamcrest Error" reason:failureReason userInfo:nil];
}


#pragma mark -

// As of 2010-09-09, the iPhone simulator has a bug where you can't catch
// exceptions when they are thrown across NSInvocation boundaries. (See
// dmaclach's comment at http://openradar.appspot.com/8081169 ) So instead of
// using an NSInvocation to call failWithException:assertThatFailure without
// linking in OCUnit, we simply pretend it exists on NSObject.
@interface NSObject (HCExceptionBugHack)
- (void)failWithException:(NSException *)exception;
@end

void HC_assertThatWithLocation(id testCase, id actual, id<HCMatcher> matcher,
                                           const char *fileName, int lineNumber)
{
    if (![matcher matches:actual])
    {
        HCStringDescription *description = [HCStringDescription stringDescription];
        [[[description appendText:@"Expected "]
                       appendDescriptionOf:matcher]
                       appendText:@", but "];
        [matcher describeMismatchOf:actual to:description];
        
        NSException *assertThatFailure = createAssertThatFailure(fileName, lineNumber,
                                                                 [description description]);
        [testCase failWithException:assertThatFailure];
    }
}
