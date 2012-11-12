//
//  OCMockito - MKTProtocolMockTest.m
//  Copyright 2012 Jonathan M. Reid. See LICENSE.txt
//

#define MOCKITO_SHORTHAND
#import "OCMockito.h"

    // Test support
#import <SenTestingKit/SenTestingKit.h>

#if TARGET_OS_MAC
    #import <OCHamcrest/OCHamcrest.h>
#else
    #import <OCHamcrestIOS/OCHamcrestIOS.h>
#endif


@protocol TestingProtocol <NSObject>

@required
- (NSString *)required;

@optional
- (NSString *)optional;

@end


@interface PartialImplementor : NSObject <TestingProtocol>
@end

@implementation PartialImplementor

- (NSString *)required
{
    return nil;
}

@end


@interface FullImplementor : NSObject <TestingProtocol>
@end

@implementation FullImplementor

- (NSString *)required
{
    return nil;
}

- (NSString *)optional
{
    return nil;
}

@end


#pragma mark -

@interface MKTProtocolMockTest : SenTestCase
@end


@implementation MKTProtocolMockTest

- (void)testMockShouldAnswerSameMethodSignatureForRequiredSelectorAsRealImplementor
{
    // given
    id <TestingProtocol> mockImplementor = mockProtocol(@protocol(TestingProtocol));
    PartialImplementor *realImplementor = [[[PartialImplementor alloc] init] autorelease];
    SEL selector = @selector(required);
    
    // when
    NSMethodSignature *signature = [(id)mockImplementor methodSignatureForSelector:selector];
    
    // then
    HC_assertThat(signature, HC_equalTo([realImplementor methodSignatureForSelector:selector]));
}

- (void)testMockShouldAnswerSameMethodSignatureForOptionalSelectorAsRealImplementor
{
    // given
    id <TestingProtocol> mockImplementor = mockProtocol(@protocol(TestingProtocol));
    FullImplementor *realImplementor = [[[FullImplementor alloc] init] autorelease];
    SEL selector = @selector(optional);
    
    // when
    NSMethodSignature *signature = [(id)mockImplementor methodSignatureForSelector:selector];
    
    // then
    HC_assertThat(signature, HC_equalTo([realImplementor methodSignatureForSelector:selector]));
}

- (void)testMethodSignatureForSelectorNotInProtocolShouldAnswerNil
{
    // given
    id <TestingProtocol> mockImplementor = mockProtocol(@protocol(TestingProtocol));
    SEL selector = @selector(objectAtIndex:);
    
    // when
    NSMethodSignature *signature = [(id)mockImplementor methodSignatureForSelector:selector];
    
    // then
    HC_assertThat(signature, HC_nilValue());
}

- (void)testMockShouldConformToItsOwnProtocol
{
    // given
    id <TestingProtocol> mockImplementor = mockProtocol(@protocol(TestingProtocol));
    
    // then
    STAssertTrue([mockImplementor conformsToProtocol:@protocol(TestingProtocol)], nil);
}

- (void)testMockShouldConformToParentProtocol
{
    // given
    id <TestingProtocol> mockImplementor = mockProtocol(@protocol(TestingProtocol));
    
    // then
    STAssertTrue([mockImplementor conformsToProtocol:@protocol(NSObject)], nil);
}

- (void)testMockShouldNotConformToUnrelatedProtocol
{
    // given
    id <TestingProtocol> mockImplementor = mockProtocol(@protocol(TestingProtocol));
    
    // then
    STAssertFalse([mockImplementor conformsToProtocol:@protocol(NSCoding)], nil);
}

- (void)testMockShouldRespondToRequiredSelector
{
    // given
    id <TestingProtocol> mockImplementor = mockProtocol(@protocol(TestingProtocol));
    
    // then
    STAssertTrue([mockImplementor respondsToSelector:@selector(required)], nil);
}

- (void)testMockShouldRespondToOptionalSelector
{
    // given
    id <TestingProtocol> mockImplementor = mockProtocol(@protocol(TestingProtocol));
    
    // then
    STAssertTrue([mockImplementor respondsToSelector:@selector(optional)], nil);
}

- (void)testMockShouldNotRespondToUnrelatedSelector
{
    // given
    id <TestingProtocol> mockImplementor = mockProtocol(@protocol(TestingProtocol));
    
    // then
    STAssertFalse([mockImplementor respondsToSelector:@selector(objectAtIndex:)], nil);
}

@end
