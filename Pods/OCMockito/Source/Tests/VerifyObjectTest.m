//
//  OCMockito - VerifyObjectTest.m
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


@interface VerifyObjectTest : SenTestCase
@end

@implementation VerifyObjectTest

- (void)testInvokingMethodShouldPassVerify
{
    // given
    NSMutableArray *mockArray = mock([NSMutableArray class]);
    
    // when
    [mockArray removeAllObjects];
    
    // then
    [verify(mockArray) removeAllObjects];
}

- (void)testNotInvokingMethodShouldFailVerify
{
    // given
    NSMutableArray *mockArray = mock([NSMutableArray class]);
    MockTestCase *mockTestCase = [[[MockTestCase alloc] init] autorelease];
    
    // then
    [verifyWithMockTestCase(mockArray) removeAllObjects];
    assertThatUnsignedInteger([mockTestCase failureCount], is(equalToUnsignedInteger(1)));    
}

- (void)testInvokingWithEqualObjectArgumentsShouldPassVerify
{
    // given
    NSMutableArray *mockArray = mock([NSMutableArray class]);
    
    // when
    [mockArray removeObject:@"same"];
    
    // then
    [verify(mockArray) removeObject:@"same"];
}

- (void)testInvokingWithDifferentObjectArgumentsShouldFailVerify
{
    // given
    NSMutableArray *mockArray = mock([NSMutableArray class]);
    MockTestCase *mockTestCase = [[[MockTestCase alloc] init] autorelease];
    
    // when
    [mockArray removeObject:@"same"];
    
    // then
    [verifyWithMockTestCase(mockArray) removeObject:@"different"];
    assertThatUnsignedInteger([mockTestCase failureCount], is(equalToUnsignedInteger(1)));    
}

- (void)testInvokingWithArgumentMatcherSatisfiedShouldPassVerify
{
    // given
    NSMutableArray *mockArray = mock([NSMutableArray class]);
    
    // when
    [mockArray removeObject:@"same"];

    // then
    [verify(mockArray) removeObject:equalTo(@"same")];
}

- (void)testInvokingWithEqualPrimitiveNumericArgumentsShouldPassVerify
{
    // given
    NSMutableArray *mockArray = mock([NSMutableArray class]);
    
    // then
    [mockArray removeObjectAtIndex:2];
    
    // then
    [verify(mockArray) removeObjectAtIndex:2];
}

- (void)testInvokingWithDifferentPrimitiveNumericArgumentsShouldFailVerify
{
    // given
    NSMutableArray *mockArray = mock([NSMutableArray class]);
    MockTestCase *mockTestCase = [[[MockTestCase alloc] init] autorelease];
    
    // when
    [mockArray removeObjectAtIndex:2];
    [verifyWithMockTestCase(mockArray) removeObjectAtIndex:99];
    
    // then
    assertThatUnsignedInteger([mockTestCase failureCount], is(equalToUnsignedInteger(1)));    
}

- (void)testMatcherSatisfiedWithNumericArgumentShouldPassVerify
{
    // given
    NSMutableArray *mockArray = mock([NSMutableArray class]);
    
    // when
    [mockArray removeObjectAtIndex:2];
    
    // then
    [[verify(mockArray) withMatcher:greaterThan([NSNumber numberWithInt:1]) forArgument:0]
     removeObjectAtIndex:0];
}

- (void)testShouldSupportShortcutForSpecifyingMatcherForFirstArgument
{
    // given
    NSMutableArray *mockArray = mock([NSMutableArray class]);
    
    // when
    [mockArray removeObjectAtIndex:2];
    
    // then
    [[verify(mockArray) withMatcher:greaterThan([NSNumber numberWithInt:1])] removeObjectAtIndex:0];
}

- (void)testVerifyTimesOneShouldFailForMethodNotInvoked
{
    // given
    NSMutableArray *mockArray = mock([NSMutableArray class]);
    MockTestCase *mockTestCase = [[[MockTestCase alloc] init] autorelease];
    
    // then
    [verifyCountWithMockTestCase(mockArray, times(1)) removeAllObjects];
    assertThatUnsignedInteger([mockTestCase failureCount], is(equalToUnsignedInteger(1)));    
}

- (void)testVerifyTimesOneShouldPassForMethodInvokedOnce
{
    // given
    NSMutableArray *mockArray = mock([NSMutableArray class]);
    
    // when
    [mockArray removeAllObjects];
    
    // then
    [verifyCount(mockArray, times(1)) removeAllObjects];
}

- (void)testVerifyTimesOneShouldFailForMethodInvokedTwice
{
    // given
    NSMutableArray *mockArray = mock([NSMutableArray class]);
    MockTestCase *mockTestCase = [[[MockTestCase alloc] init] autorelease];
    
    // when
    [mockArray removeAllObjects];
    [mockArray removeAllObjects];

    // then
    [verifyCountWithMockTestCase(mockArray, times(1)) removeAllObjects];
    assertThatUnsignedInteger([mockTestCase failureCount], is(equalToUnsignedInteger(1)));    
}

- (void)testVerifyTimesTwoShouldFailForMethodInvokedOnce
{
    // given
    NSMutableArray *mockArray = mock([NSMutableArray class]);
    MockTestCase *mockTestCase = [[[MockTestCase alloc] init] autorelease];
    
    // when
    [mockArray removeAllObjects];
    
    // then
    [verifyCountWithMockTestCase(mockArray, times(2)) removeAllObjects];
    assertThatUnsignedInteger([mockTestCase failureCount], is(equalToUnsignedInteger(1)));    
}

- (void)testVerifyTimesTwoShouldPassForMethodInvokedTwice
{
    // given
    NSMutableArray *mockArray = mock([NSMutableArray class]);
    
    // when
    [mockArray removeAllObjects];
    [mockArray removeAllObjects];
    
    // then
    [verifyCount(mockArray, times(2)) removeAllObjects];
}

- (void)testVerifyTimesTwoShouldFailForMethodInvokedThreeTimes
{
    // given
    NSMutableArray *mockArray = mock([NSMutableArray class]);
    MockTestCase *mockTestCase = [[[MockTestCase alloc] init] autorelease];
    
    // when
    [mockArray removeAllObjects];
    [mockArray removeAllObjects];
    [mockArray removeAllObjects];
    
    // then
    [verifyCountWithMockTestCase(mockArray, times(2)) removeAllObjects];
    assertThatUnsignedInteger([mockTestCase failureCount], is(equalToUnsignedInteger(1)));    
}

- (void)testVerifyTimesOneFailureShouldStateExpectedNumberOfInvocations
{
    // given
    NSMutableArray *mockArray = mock([NSMutableArray class]);
    MockTestCase *mockTestCase = [[[MockTestCase alloc] init] autorelease];
    
    // then
    [verifyCountWithMockTestCase(mockArray, times(1)) removeAllObjects];
    assertThat([[mockTestCase failureException] description],
               is(@"Expected 1 matching invocation, but received 0"));
}

- (void)testVerifyTimesTwoFailureShouldStateExpectedNumberOfInvocations
{
    // given
    NSMutableArray *mockArray = mock([NSMutableArray class]);
    MockTestCase *mockTestCase = [[[MockTestCase alloc] init] autorelease];
    
    // when
    [mockArray removeAllObjects];
    
    // then
    [verifyCountWithMockTestCase(mockArray, times(2)) removeAllObjects];
    assertThat([[mockTestCase failureException] description],
               is(@"Expected 2 matching invocations, but received 1"));
}

- (void)testVerifyNeverShouldPassForMethodInvoked
{
    // given
    NSMutableArray *mockArray = mock([NSMutableArray class]);
    
    // then
    [verifyCount(mockArray, never()) removeAllObjects];
}

- (void)testVerifyNeverShouldFailForInvokedMethod
{
    // given
    NSMutableArray *mockArray = mock([NSMutableArray class]);
    MockTestCase *mockTestCase = [[[MockTestCase alloc] init] autorelease];
    
    // when
    [mockArray removeAllObjects];

    // then
    [verifyCountWithMockTestCase(mockArray, never()) removeAllObjects];
    assertThatUnsignedInteger([mockTestCase failureCount], is(equalToUnsignedInteger(1)));    
}

- (void)testVerifyWithNilShouldGiveError
{
    // given
    MockTestCase *mockTestCase = [[[MockTestCase alloc] init] autorelease];
    
    // then
    [verifyWithMockTestCase(nil) removeAllObjects];
    assertThat([[mockTestCase failureException] description],
               is(@"Argument passed to verify() should be a mock but is nil"));
}

- (void)testVerifyCountWithNilShouldGiveError
{
    // given
    MockTestCase *mockTestCase = [[[MockTestCase alloc] init] autorelease];
    
    // then
    [verifyCountWithMockTestCase(nil, times(1)) removeAllObjects];
    assertThat([[mockTestCase failureException] description],
               is(@"Argument passed to verifyCount() should be a mock but is nil"));
}

- (void)testVerifyWithNonMockShouldGiveError
{
    // given
    NSMutableArray *realArray = [NSMutableArray array];
    MockTestCase *mockTestCase = [[[MockTestCase alloc] init] autorelease];
    
    // then
    [verifyWithMockTestCase(realArray) removeAllObjects];
    assertThat([[mockTestCase failureException] description],
               startsWith(@"Argument passed to verify() should be a mock but is type "));
}

- (void)testVerifyCountWithNonMockShouldGiveError
{
    // given
    NSMutableArray *realArray = [NSMutableArray array];
    MockTestCase *mockTestCase = [[[MockTestCase alloc] init] autorelease];
    
    // then
    [verifyCountWithMockTestCase(realArray, times(1)) removeAllObjects];
    assertThat([[mockTestCase failureException] description],
               startsWith(@"Argument passed to verifyCount() should be a mock but is type "));
}

@end
