//
//  OCMockito - VerifyClassObjectTest.m
//  Copyright 2012 Jonathan M. Reid. See LICENSE.txt
//

#define MOCKITO_SHORTHAND
#import "OCMockito.h"

	// Test support
#import "MockTestCase.h"
#import <SenTestingKit/SenTestingKit.h>

#define HC_SHORTHAND
#if TARGET_OS_MAC
    #import <OCHamcrest/OCHamcrest.h>
#else
    #import <OCHamcrestIOS/OCHamcrestIOS.h>
#endif


@interface VerifyClassObjectTest : SenTestCase
@end

@implementation VerifyClassObjectTest

- (void)testInvokingClassMethodShouldPassVerify
{
    // given
    Class mockStringClass = mockClass([NSString class]);
    
    // when
    [mockStringClass string];
    
    // then
    [verify(mockStringClass) string];
}

- (void)testNotInvokingClassMethodShouldFailVerify
{
    // given
    Class mockStringClass = mockClass([NSString class]);
    MockTestCase *mockTestCase = [[[MockTestCase alloc] init] autorelease];
    
    // then
    [verifyWithMockTestCase(mockStringClass) string];
    assertThatUnsignedInteger([mockTestCase failureCount], is(equalToUnsignedInteger(1)));    
}

@end
