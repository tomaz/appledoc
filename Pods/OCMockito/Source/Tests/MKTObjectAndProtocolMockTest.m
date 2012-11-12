//
//  OCMockito - MKTObjectAndProtocolMockTest.m
//  Copyright 2012 Jonathan M. Reid. See LICENSE.txt
//  
//  Created by: Kevin Lundberg
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


@protocol TestProtocol <NSObject>
@required
- (void)requiredMethod;
@end


@interface TestClass : NSObject 
- (void)instanceMethod;
@end

@implementation TestClass
- (void)instanceMethod {}
@end


@interface TestSubclass : TestClass <TestProtocol>
@end

@implementation TestSubclass
- (void)requiredMethod {}
@end


#pragma mark -

@interface MKTObjectAndProtocolMockTest : SenTestCase
@end


@implementation MKTObjectAndProtocolMockTest

- (void)testClassProtocolMockCanCallMethodFromClass
{
    // given
    TestClass<TestProtocol> *mock = mockObjectAndProtocol([TestClass class], @protocol(TestProtocol));
    
    // then
    STAssertNoThrow([mock instanceMethod],nil);
}

- (void)testClassProtocolMockCanCallMethodFromProtocol
{
    // given
    TestClass<TestProtocol> *mock = mockObjectAndProtocol([TestClass class], @protocol(TestProtocol));
    
    // then
    STAssertNoThrow([mock requiredMethod],nil);
}

- (void)testMockShouldAnswerSameMethodSignatureForSelectorAsRealObject
{
    // given
    TestClass<TestProtocol> *mock = mockObjectAndProtocol([TestClass class], @protocol(TestProtocol));
    TestClass<TestProtocol> *obj = [[[TestSubclass alloc] init] autorelease];
    SEL selector = @selector(instanceMethod);
    
    // when
    NSMethodSignature *mockSig = [mock methodSignatureForSelector:selector];
    
    // then
    HC_assertThat(mockSig, HC_equalTo([obj methodSignatureForSelector:selector]));
}

- (void)testMethodSignatureForSelectorNotInClassOrProtocolShouldAnswerNil
{
    // given
    TestClass<TestProtocol> *mock = mockObjectAndProtocol([TestClass class], @protocol(TestProtocol));
    SEL bogusSelector = @selector(objectAtIndex:);
    
    // when
    NSMethodSignature *signature = [mock methodSignatureForSelector:bogusSelector];
    
    // then
    HC_assertThat(signature, HC_nilValue());
}

- (void)testMockShouldRespondToKnownSelector
{
    // given
    TestClass<TestProtocol> *mock = mockObjectAndProtocol([TestClass class], @protocol(TestProtocol));
    
    // then
    HC_assertThatBool([mock respondsToSelector:@selector(instanceMethod)], HC_equalToBool(YES));
}

- (void)testMockShouldNotRespondToUnknownSelector
{
    // given
    TestClass<TestProtocol> *mock = mockObjectAndProtocol([TestClass class], @protocol(TestProtocol));
    
    // then
    HC_assertThatBool([mock respondsToSelector:@selector(objectAtIndex:)], HC_equalToBool(NO));
}

- (void)testMockShouldAnswerSameMethodSignatureForRequiredSelectorAsRealImplementor
{
    // given
    TestClass<TestProtocol> *mock = mockObjectAndProtocol([TestClass class], @protocol(TestProtocol));
    TestClass<TestProtocol> *obj = [[[TestSubclass alloc] init] autorelease];
    SEL selector = @selector(requiredMethod);
    
    // when
    NSMethodSignature *signature = [mock methodSignatureForSelector:selector];
    
    // then
    HC_assertThat(signature, HC_equalTo([obj methodSignatureForSelector:selector]));
}

- (void)testMockShouldConformToItsOwnProtocol
{
    // given
    Protocol *protocol = @protocol(TestProtocol);
    TestClass<TestProtocol> *mock = mockObjectAndProtocol([TestClass class], protocol);
    
    // then
    STAssertTrue([mock conformsToProtocol:protocol],nil);
}

- (void)testMockShouldConformToParentProtocol
{
    // given
    TestClass<TestProtocol> *mock = mockObjectAndProtocol([TestClass class], @protocol(TestProtocol));
    
    // then
    STAssertTrue([mock conformsToProtocol:@protocol(NSObject)], nil);
}

- (void)testMockShouldNotConformToUnrelatedProtocol
{
    // given
    TestClass<TestProtocol> *mock = mockObjectAndProtocol([TestClass class], @protocol(TestProtocol));
    
    // then
    STAssertFalse([mock conformsToProtocol:@protocol(NSCoding)], nil);
}

- (void)testMockShouldRespondToRequiredSelector
{
    // given
    TestClass<TestProtocol> *mock = mockObjectAndProtocol([TestClass class], @protocol(TestProtocol));
    
    // then
    STAssertTrue([mock respondsToSelector:@selector(requiredMethod)], nil);
}

@end
