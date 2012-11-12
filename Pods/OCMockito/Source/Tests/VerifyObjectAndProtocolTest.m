//
//  OCMockito - VerifyObjectAndProtocolTest.m
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


@interface VerifyObjectAndProtocolTest : SenTestCase
@end

@implementation VerifyObjectAndProtocolTest

- (void)testInvokingClassInstanceMethodShouldPassVerify
{
    // given
    NSMutableArray <NSLocking> *mockLockingArray = mockObjectAndProtocol([NSMutableArray class],
                                                                         @protocol(NSLocking));
    
    // when
    [mockLockingArray removeAllObjects];
    
    // then
    [verify(mockLockingArray) removeAllObjects];
}

- (void)testNotInvokingClassInstanceMethodShouldFailVerify
{
    // given
    NSMutableArray <NSLocking> *mockLockingArray = mockObjectAndProtocol([NSMutableArray class],
                                                                         @protocol(NSLocking));
    MockTestCase *mockTestCase = [[[MockTestCase alloc] init] autorelease];

    // then
    [verifyWithMockTestCase(mockLockingArray) removeAllObjects];
    assertThatUnsignedInteger([mockTestCase failureCount], is(equalToUnsignedInteger(1)));    
}

- (void)testInvokingProtocolMethodShouldPassVerify
{
    // given
    NSMutableArray <NSLocking> *mockLockingArray = mockObjectAndProtocol([NSMutableArray class],
                                                                         @protocol(NSLocking));
    
    // when
    [mockLockingArray lock];
    
    // then
    [verify(mockLockingArray) lock];
}

- (void)testNotInvokingProtocolMethodShouldFailVerify
{
    // given
    NSMutableArray <NSLocking> *mockLockingArray = mockObjectAndProtocol([NSMutableArray class],
                                                                         @protocol(NSLocking));
    MockTestCase *mockTestCase = [[[MockTestCase alloc] init] autorelease];

    // then
    [verifyWithMockTestCase(mockLockingArray) lock];
    assertThatUnsignedInteger([mockTestCase failureCount], is(equalToUnsignedInteger(1)));    
}

@end
