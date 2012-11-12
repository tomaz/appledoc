//
//  OCMockito - OCMockito.h
//  Copyright 2012 Jonathan M. Reid. See LICENSE.txt
//

#import <Foundation/Foundation.h>

#import "MKTClassObjectMock.h"
#import "MKTObjectMock.h"
#import "MKTObjectAndProtocolMock.h"
#import "MKTOngoingStubbing.h"
#import "MKTProtocolMock.h"
#import <objc/objc-api.h>


/**
    Returns a mock object of a given class.
 
    Unless there is a name clash, you can \#define @c MOCKITO_SHORTHAND and use the synonym
    @c mock.
 */
#define MKTMock(aClass) [MKTObjectMock mockForClass:aClass]

#ifdef MOCKITO_SHORTHAND
    #define mock(aClass) MKTMock(aClass)
#endif


/**
    Returns a mock class object of a given class.

    Unless there is a name clash, you can \#define @c MOCKITO_SHORTHAND and use the synonym
    @c mock.
 */
#define MKTMockClass(aClass) [MKTClassObjectMock mockForClass:aClass]

#ifdef MOCKITO_SHORTHAND
    #define mockClass(aClass) MKTMockClass(aClass)
#endif


/**
    Returns a mock object implementing a given protocol.

    Unless there is a name clash, you can \#define @c MOCKITO_SHORTHAND and use the synonym
    @c mockProtocol.
 */
#define MKTMockProtocol(aProtocol) [MKTProtocolMock mockForProtocol:aProtocol]

#ifdef MOCKITO_SHORTHAND
    #define mockProtocol(aProtocol) MKTMockProtocol(aProtocol)
#endif


/**
    Returns a mock object of a given class that also implements a given protocol.
 */

#define MKTMockObjectAndProtocol(aClass, aProtocol) [MKTObjectAndProtocolMock mockForClass:aClass protocol:aProtocol]

#ifdef MOCKITO_SHORTHAND
    #define mockObjectAndProtocol(aClass, aProtocol) MKTMockObjectAndProtocol(aClass, aProtocol)
#endif

OBJC_EXPORT MKTOngoingStubbing *MKTGivenWithLocation(id testCase, const char *fileName, int lineNumber, ...);

/**
    Enables method stubbing.

    Unless there is a name clash, you can \#define @c MOCKITO_SHORTHAND and use the synonym
    @c given.

    Use @c given when you want the mock to return particular value when particular method is called.

    Example:
    @li @ref [given([mockObject methodReturningString]) willReturn:@"foo"];

    See @ref MKTOngoingStubbing for other methods to stub different types of return values.
 */
#define MKTGiven(methodCall) MKTGivenWithLocation(self, __FILE__, __LINE__, methodCall)

#ifdef MOCKITO_SHORTHAND
    #define given(methodCall) MKTGiven(methodCall)
#endif


OBJC_EXPORT id MKTVerifyWithLocation(id mock, id testCase, const char *fileName, int lineNumber);

/**
    Verifies certain behavior happened once.

    Unless there is a name clash, you can \#define @c MOCKITO_SHORTHAND and use the synonym
    @c verify.

    @c verify checks that a method was invoked once, with arguments that match given OCHamcrest
    matchers. If an argument is not a matcher, it is implicitly wrapped in an @c equalTo matcher to
    check for equality.

    Examples:
@code
[verify(mockObject) someMethod:startsWith(@"foo")];
[verify(mockObject) someMethod:@"bar"];
@endcode

    @c verify(mockObject) is equivalent to
@code
verifyCount(mockObject, times(1))
@endcode
 */
#define MKTVerify(mock) MKTVerifyWithLocation(mock, self, __FILE__, __LINE__)

#ifdef MOCKITO_SHORTHAND
    #undef verify
    #define verify(mock) MKTVerify(mock)
#endif


OBJC_EXPORT id MKTVerifyCountWithLocation(id mock, id mode, id testCase, const char *fileName, int lineNumber);

/**
    Verifies certain behavior happened a given number of times.

    Unless there is a name clash, you can \#define @c MOCKITO_SHORTHAND and use the synonym
    @c verifyCount.

    Examples:
@code
[verifyCount(mockObject, times(5)) someMethod:@"was called five times"];
[verifyCount(mockObject, never()) someMethod:@"was never called"];
@endcode

    @c verifyCount checks that a method was invoked a given number of times, with arguments that
    match given OCHamcrest matchers. If an argument is not a matcher, it is implicitly wrapped in an
    @c equalTo matcher to check for equality.
 */
#define MKTVerifyCount(mock, mode) MKTVerifyCountWithLocation(mock, mode, self, __FILE__, __LINE__)

#ifdef MOCKITO_SHORTHAND
    #define verifyCount(mock, mode) MKTVerifyCount(mock, mode)
#endif


/**
    Verifies exact number of invocations.

    Unless there is a name clash, you can \#define @c MOCKITO_SHORTHAND and use the synonym
    @c times.

    Example:
@code
[verifyCount(mockObject, times(2)) someMethod:@"some arg"];
@endcode
 */
OBJC_EXPORT id MKTTimes(NSUInteger wantedNumberOfInvocations);

#ifdef MOCKITO_SHORTHAND
    #define times(wantedNumberOfInvocations) MKTTimes(wantedNumberOfInvocations)
#endif


/**
    Verifies that interaction did not happen.

    Unless there is a name clash, you can \#define @c MOCKITO_SHORTHAND and use the synonym
    @c never.

    Example:
    @code
    [verifyCount(mockObject, never()) someMethod:@"some arg"];
    @endcode
 */
OBJC_EXPORT id MKTNever(void);

#ifdef MOCKITO_SHORTHAND
    #define never() MKTNever()
#endif
