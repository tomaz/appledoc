//
//  OCMockito - MKTObjectMockTest.m
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


@interface MKTObjectMockTest : SenTestCase
@end

@implementation MKTObjectMockTest

- (void)testMockShouldAnswerSameMethodSignatureForSelectorAsRealObject
{
    // given
    NSString *mockString = mock([NSString class]);
    NSString *realString = [NSString string];
    SEL selector = @selector(rangeOfString:options:);
    
    // when
    NSMethodSignature *signature = [mockString methodSignatureForSelector:selector];
    
    // then
    assertThat(signature, is(equalTo([realString methodSignatureForSelector:selector])));
}

- (void)testMethodSignatureForSelectorNotInClassShouldAnswerNil
{
    // given
    NSString *mockString = mock([NSString class]);
    SEL selector = @selector(objectAtIndex:);
    
    // when
    NSMethodSignature *signature = [mockString methodSignatureForSelector:selector];
    
    // then
    assertThat(signature, is(nilValue()));
}

- (void)testMockShouldRespondToKnownSelector
{
    // given
    NSString *mockString = mock([NSString class]);
    
    // then
    STAssertTrue([mockString respondsToSelector:@selector(substringFromIndex:)], nil);
}

- (void)testMockShouldNotRespondToUnknownSelector
{
    // given
    NSString *mockString = mock([NSString class]);
    
    // then
    STAssertFalse([mockString respondsToSelector:@selector(removeAllObjects)], nil);
}

@end
