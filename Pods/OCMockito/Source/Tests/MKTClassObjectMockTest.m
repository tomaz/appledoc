//
//  OCMockito - MKTClassObjectMockTest.m
//  Copyright 2012 Jonathan M. Reid. See LICENSE.txt
//
//  Created by: David Hart
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


@interface MKTClassObjectMockTest : SenTestCase
@end

@implementation MKTClassObjectMockTest

- (void)testMockShouldAnswerSameMethodSignatureForSelectorAsRealObject
{
    // given
    Class mockStringClass = mockClass([NSString class]);
    Class realStringClass = [NSString class];
    SEL selector = @selector(string);
    
    // when
    NSMethodSignature *signature = [mockStringClass methodSignatureForSelector:selector];
    
    // then
    assertThat(signature, is(equalTo([realStringClass methodSignatureForSelector:selector])));
}

- (void)testMethodSignatureForSelectorNotInClassShouldAnswerNil
{
    // given
    Class mockStringClass = mockClass([NSString class]);
    SEL selector = @selector(rangeOfString:options:);
    
    // when
    NSMethodSignature *signature = [mockStringClass methodSignatureForSelector:selector];
    
    // then
    assertThat(signature, is(nilValue()));
}

- (void)testMockShouldRespondToKnownSelector
{
    // given
    Class mockStringClass = mockClass([NSString class]);
    
    // then
    STAssertTrue([mockStringClass respondsToSelector:@selector(pathWithComponents:)], nil);
}

- (void)testMockShouldNotRespondToUnknownSelector
{
    // given
    Class mockStringClass = mockClass([NSString class]);
    
    // then
    STAssertFalse([mockStringClass respondsToSelector:@selector(pathExtension)], nil);
}

@end
