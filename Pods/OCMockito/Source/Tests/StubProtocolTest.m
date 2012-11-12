//
//  OCMockito - StubProtocolTest.m
//  Copyright 2012 Jonathan M. Reid. See LICENSE.txt
//

#define MOCKITO_SHORTHAND
#import "OCMockito.h"

    // Test support
#import <SenTestingKit/SenTestingKit.h>

#define HC_SHORTHAND
#if TARGET_OS_MAC
    #import <OCHamcrest/OCHamcrest.h>
#else
    #import <OCHamcrestIOS/OCHamcrestIOS.h>
#endif


@protocol ReturningProtocol <NSObject>

- (id)methodReturningObject;
- (id)methodReturningObjectWithArg:(id)arg;
- (id)methodReturningObjectWithIntArg:(int)arg;
- (short)methodReturningShort;

@end


#pragma mark -

@interface StubProtocolTest : SenTestCase
@end

@implementation StubProtocolTest

- (void)testStubbedMethoShouldReturnGivenObject
{
    // given
    id <ReturningProtocol> mockProtocol = mockProtocol(@protocol(ReturningProtocol));
    
    // when
    [given([mockProtocol methodReturningObject]) willReturn:@"STUBBED"];
    
    // then
    assertThat([mockProtocol methodReturningObject], is(@"STUBBED"));
}

- (void)testUnstubbedMethodReturningObjectShouldReturnNil
{
    // given
    id <ReturningProtocol> mockProtocol = mockProtocol(@protocol(ReturningProtocol));
    
    // then
    assertThat([mockProtocol methodReturningObject], is(nilValue()));
}

- (void)testStubsWithDifferentArgsShouldHaveDifferentReturnValues
{
    // given
    id <ReturningProtocol> mockProtocol = mockProtocol(@protocol(ReturningProtocol));
    
    // when
    [given([mockProtocol methodReturningObjectWithArg:@"foo"]) willReturn:@"FOO"];
    [given([mockProtocol methodReturningObjectWithArg:@"bar"]) willReturn:@"BAR"];
    
    // then
    assertThat([mockProtocol methodReturningObjectWithArg:@"foo"], is(@"FOO"));
}

- (void)testStubShouldAcceptArgumentMatchers
{
    // given
    id <ReturningProtocol> mockProtocol = mockProtocol(@protocol(ReturningProtocol));
    
    // when
    [given([mockProtocol methodReturningObjectWithArg:equalTo(@"foo")]) willReturn:@"FOO"];
    
    // then
    assertThat([mockProtocol methodReturningObjectWithArg:@"foo"], is(@"FOO"));
}

- (void)testStubShouldReturnValueForMatchingNumericArgument
{
    // given
    id <ReturningProtocol> mockProtocol = mockProtocol(@protocol(ReturningProtocol));
    
    // when
    [given([mockProtocol methodReturningObjectWithIntArg:1]) willReturn:@"FOO"];
    [given([mockProtocol methodReturningObjectWithIntArg:2]) willReturn:@"BAR"];
    
    // then
    assertThat([mockProtocol methodReturningObjectWithIntArg:1], is(@"FOO"));
}

- (void)testStubShouldAcceptMatcherForNumericArgument
{
    // given
    id <ReturningProtocol> mockProtocol = mockProtocol(@protocol(ReturningProtocol));
    
    // when
    [[given([mockProtocol methodReturningObjectWithIntArg:0])
      withMatcher:greaterThan([NSNumber numberWithInt:1]) forArgument:0] willReturn:@"FOO"];
    
    // then
    assertThat([mockProtocol methodReturningObjectWithIntArg:2], is(@"FOO"));
}

- (void)testShouldSupportShortcutForSpecifyingMatcherForFirstArgument
{
    // given
    id <ReturningProtocol> mockProtocol = mockProtocol(@protocol(ReturningProtocol));
    
    // when
    [[given([mockProtocol methodReturningObjectWithIntArg:0])
      withMatcher:greaterThan([NSNumber numberWithInt:1])] willReturn:@"FOO"];
    
    // then
    assertThat([mockProtocol methodReturningObjectWithIntArg:2], is(@"FOO"));
}

- (void)testStubbedMethodShouldReturnGivenShort
{
    // given
    id <ReturningProtocol> mockProtocol = mockProtocol(@protocol(ReturningProtocol));
    
    // when
    [given([mockProtocol methodReturningShort]) willReturnShort:42];
    
    // then
    assertThatShort([mockProtocol methodReturningShort], equalToShort(42));
}

@end
