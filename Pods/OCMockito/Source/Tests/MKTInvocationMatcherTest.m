//
//  OCMockito - MKTInvocationMatcherTest.m
//  Copyright 2012 Jonathan M. Reid. See LICENSE.txt
//

    // Class under test
#import "MKTInvocationMatcher.h"

    // Test support
#import <SenTestingKit/SenTestingKit.h>

#define HC_SHORTHAND
#if TARGET_OS_MAC
    #import <OCHamcrest/OCHamcrest.h>
#else
    #import <OCHamcrestIOS/OCHamcrestIOS.h>
#endif


@interface DummyObject : NSObject
@end

@implementation DummyObject

- (void)methodWithNoArgs {}
- (void)differentMethodWithNoArgs {}

- (void)methodWithObjectArg:(id)arg {}
- (void)differentMethodWithObjectArg:(id)arg {}

- (void)methodWithBoolArg:(BOOL)arg {}
- (void)methodWithCharArg:(char)arg {}
- (void)methodWithIntArg:(int)arg {}
- (void)methodWithShortArg:(short)arg {}
- (void)methodWithLongArg:(long)arg {}
- (void)methodWithLongLongArg:(long long)arg {}
- (void)methodWithIntegerArg:(NSInteger)arg {}
- (void)methodWithUnsignedCharArg:(unsigned char)arg {}
- (void)methodWithUnsignedIntArg:(unsigned int)arg {}
- (void)methodWithUnsignedShortArg:(unsigned short)arg {}
- (void)methodWithUnsignedLongArg:(unsigned long)arg {}
- (void)methodWithUnsignedLongLongArg:(unsigned long long)arg {}
- (void)methodWithUnsignedIntegerArg:(NSUInteger)arg {}
- (void)methodWithFloatArg:(float)arg {}
- (void)methodWithDoubleArg:(double)arg {}

- (void)methodWithObjectArg:(id)arg1 intArg:(int)arg2 {}

+ (NSInvocation *)invocationWithSelector:(SEL)selector
{
    NSMethodSignature *methodSignature = [self instanceMethodSignatureForSelector:selector];
    return [NSInvocation invocationWithMethodSignature:methodSignature];
}

+ (NSInvocation *)invocationWithNoArgs
{
    return [self invocationWithSelector:@selector(methodWithNoArgs)];
}

#define DEFINE_INVOCATION_METHOD(type, typeName)                                                    \
    + (NSInvocation *)invocationWith ## typeName ## Arg:(type)argument                              \
    {                                                                                               \
        NSInvocation *invocation = [self invocationWithSelector:@selector(methodWith ## typeName ## Arg:)]; \
        [invocation setArgument:&argument atIndex:2];                                               \
        return invocation;                                                                          \
    }

DEFINE_INVOCATION_METHOD(id, Object)
DEFINE_INVOCATION_METHOD(BOOL, Bool)
DEFINE_INVOCATION_METHOD(char, Char)
DEFINE_INVOCATION_METHOD(int, Int)
DEFINE_INVOCATION_METHOD(short, Short)
DEFINE_INVOCATION_METHOD(long, Long)
DEFINE_INVOCATION_METHOD(long long, LongLong)
DEFINE_INVOCATION_METHOD(NSInteger, Integer)
DEFINE_INVOCATION_METHOD(unsigned char, UnsignedChar)
DEFINE_INVOCATION_METHOD(unsigned int, UnsignedInt)
DEFINE_INVOCATION_METHOD(unsigned short, UnsignedShort)
DEFINE_INVOCATION_METHOD(unsigned long, UnsignedLong)
DEFINE_INVOCATION_METHOD(unsigned long long, UnsignedLongLong)
DEFINE_INVOCATION_METHOD(NSUInteger, UnsignedInteger)
DEFINE_INVOCATION_METHOD(float, Float)
DEFINE_INVOCATION_METHOD(double, Double)

+ (NSInvocation *)invocationWithObjectArg:(id)argument1 intArg:(int)argument2
{
    NSInvocation *invocation = [self invocationWithSelector:@selector(methodWithObjectArg:intArg:)];
    [invocation setArgument:&argument1 atIndex:2];
    [invocation setArgument:&argument2 atIndex:3];
    return invocation;
}

@end


#pragma mark -

@interface MKTInvocationMatcherTest : SenTestCase
{
    MKTInvocationMatcher *invocationMatcher;
}
@end


@implementation MKTInvocationMatcherTest

- (void)setUp
{
    [super setUp];
    invocationMatcher = [[MKTInvocationMatcher alloc] init];
}

- (void)tearDown
{
    [invocationMatcher release];
    [super tearDown];
}

- (void)testShouldMatchNoArgumentInvocationsIfSelectorsMatch
{
    // given
    NSInvocation *expected = [DummyObject invocationWithNoArgs];
    NSInvocation *actual = [DummyObject invocationWithNoArgs];
    
    // when
    [invocationMatcher setExpectedInvocation:expected];
    
    // then
    STAssertTrue([invocationMatcher matches:actual], nil);
}

- (void)testShouldNotMatchNoArgumentInvocationsIfSelectorsDiffer
{
    // given
    NSInvocation *expected = [DummyObject invocationWithNoArgs];
    NSInvocation *actual = [DummyObject invocationWithNoArgs];
    [expected setSelector:@selector(methodWithNoArgs)];
    [actual setSelector:@selector(differentMethodWithNoArgs)];
    
    // when
    [invocationMatcher setExpectedInvocation:expected];
    
    // then
    STAssertFalse([invocationMatcher matches:actual], nil);
}

- (void)testShouldMatchIfObjectArgumentEqualsExpectedArgument
{
    // given
    NSInvocation *expected = [DummyObject invocationWithObjectArg:@"something"];
    NSInvocation *actual = [DummyObject invocationWithObjectArg:@"something"];
    
    // when
    [invocationMatcher setExpectedInvocation:expected];
    
    // then
    STAssertTrue([invocationMatcher matches:actual], nil);
}

- (void)testShouldMatchIfObjectArgumentsAreNil
{
    // given
    NSInvocation *expected = [DummyObject invocationWithObjectArg:nil];
    NSInvocation *actual = [DummyObject invocationWithObjectArg:nil];
    
    // when
    [invocationMatcher setExpectedInvocation:expected];
    
    // then
    STAssertTrue([invocationMatcher matches:actual], nil);
}

- (void)testShouldNotMatchIfObjectArgumentDoesNotEqualExpectedArgument
{
    // given
    NSInvocation *expected = [DummyObject invocationWithObjectArg:@"something"];
    NSInvocation *actual = [DummyObject invocationWithObjectArg:@"different"];
    
    // when
    [invocationMatcher setExpectedInvocation:expected];
    
    // then
    STAssertFalse([invocationMatcher matches:actual], nil);
}

- (void)testShouldNotMatchIfArgumentsMatchButSelectorsDiffer
{
    // given
    NSInvocation *expected = [DummyObject invocationWithObjectArg:@"something"];
    NSInvocation *actual = [DummyObject invocationWithObjectArg:@"something"];
    [expected setSelector:@selector(methodWithObjectArg:)];
    [actual setSelector:@selector(differentMethodWithObjectArg:)];
    
    // when
    [invocationMatcher setExpectedInvocation:expected];
    
    // then
    STAssertFalse([invocationMatcher matches:actual], nil);
}

- (void)testShouldMatchIfObjectArgumentSatisfiesArgumentExpectation
{
    // given
    id <HCMatcher> argumentExpectation = equalTo(@"something");
    NSInvocation *expected = [DummyObject invocationWithObjectArg:argumentExpectation];
    NSInvocation *actual = [DummyObject invocationWithObjectArg:@"something"];
    
    // when
    [invocationMatcher setExpectedInvocation:expected];
    
    // then
    STAssertTrue([invocationMatcher matches:actual], nil);
}

- (void)testShouldNotMatchIfObjectArgumentDoesNotSatisfyArgumentExpectation
{
    // given
    id <HCMatcher> argumentExpectation = equalTo(@"something");
    NSInvocation *expected = [DummyObject invocationWithObjectArg:argumentExpectation];
    NSInvocation *actual = [DummyObject invocationWithObjectArg:@"different"];
    
    // when
    [invocationMatcher setExpectedInvocation:expected];
    
    // then
    STAssertFalse([invocationMatcher matches:actual], nil);
}

- (void)testShouldMatchIfBoolArgumentEqualsExpectedArgument
{
    // given
    NSInvocation *expected = [DummyObject invocationWithBoolArg:YES];
    NSInvocation *actual = [DummyObject invocationWithBoolArg:YES];
    
    // when
    [invocationMatcher setExpectedInvocation:expected];
    
    // then
    STAssertTrue([invocationMatcher matches:actual], nil);
}

- (void)testShouldNotMatchIfBoolArgumentDoesNotEqualExpectedArgument
{
    // given
    NSInvocation *expected = [DummyObject invocationWithBoolArg:NO];
    NSInvocation *actual = [DummyObject invocationWithBoolArg:YES];
    
    // when
    [invocationMatcher setExpectedInvocation:expected];
    
    // then
    STAssertFalse([invocationMatcher matches:actual], nil);
}

- (void)testShouldMatchIfCharArgumentEqualsExpectedArgument
{
    // given
    NSInvocation *expected = [DummyObject invocationWithCharArg:'a'];
    NSInvocation *actual = [DummyObject invocationWithCharArg:'a'];
    
    // when
    [invocationMatcher setExpectedInvocation:expected];
    
    // then
    STAssertTrue([invocationMatcher matches:actual], nil);
}

- (void)testShouldNotMatchIfCharArgumentDoesNotEqualExpectedArgument
{
    // given
    NSInvocation *expected = [DummyObject invocationWithCharArg:'a'];
    NSInvocation *actual = [DummyObject invocationWithCharArg:'z'];
    
    // when
    [invocationMatcher setExpectedInvocation:expected];
    
    // then
    STAssertFalse([invocationMatcher matches:actual], nil);
}

- (void)testNotShouldMatchIfCharArgumentConvertedToObjectDoesNotSatisfyOverrideMatcher
{
    // given
    NSInvocation *expected = [DummyObject invocationWithCharArg:0];   // Argument will be ignored.
    NSInvocation *actual = [DummyObject invocationWithCharArg:'z'];
    
    // when
    [invocationMatcher setMatcher:lessThan([NSNumber numberWithChar:'n']) atIndex:2];
    [invocationMatcher setExpectedInvocation:expected];
    
    // then
    STAssertFalse([invocationMatcher matches:actual], nil);
}

- (void)testShouldNotMatchIfIntArgumentDoesNotEqualExpectedArgument
{
    // given
    NSInvocation *expected = [DummyObject invocationWithIntArg:42];
    NSInvocation *actual = [DummyObject invocationWithIntArg:99];
    
    // when
    [invocationMatcher setExpectedInvocation:expected];
    
    // then
    STAssertFalse([invocationMatcher matches:actual], nil);
}

- (void)testShouldNotMatchIfIntArgumentConvertedToObjectDoesNotSatisfyOverrideMatcher
{
    // given
    NSInvocation *expected = [DummyObject invocationWithCharArg:0];   // Argument will be ignored.
    NSInvocation *actual = [DummyObject invocationWithCharArg:51];
    
    // when
    [invocationMatcher setMatcher:lessThan([NSNumber numberWithInt:50]) atIndex:2];
    [invocationMatcher setExpectedInvocation:expected];
    
    // then
    STAssertFalse([invocationMatcher matches:actual], nil);
}

- (void)testShouldNotMatchIfShortArgumentDoesNotEqualExpectedArgument
{
    // given
    NSInvocation *expected = [DummyObject invocationWithShortArg:42];
    NSInvocation *actual = [DummyObject invocationWithShortArg:99];
    
    // when
    [invocationMatcher setExpectedInvocation:expected];
    
    // then
    STAssertFalse([invocationMatcher matches:actual], nil);
}

- (void)testShouldNotMatchIfLongArgumentDoesNotEqualExpectedArgument
{
    // given
    NSInvocation *expected = [DummyObject invocationWithLongArg:42];
    NSInvocation *actual = [DummyObject invocationWithLongArg:99];
    
    // when
    [invocationMatcher setExpectedInvocation:expected];
    
    // then
    STAssertFalse([invocationMatcher matches:actual], nil);
}

- (void)testShouldNotMatchIfLongLongArgumentDoesNotEqualExpectedArgument
{
    // given
    NSInvocation *expected = [DummyObject invocationWithLongLongArg:42];
    NSInvocation *actual = [DummyObject invocationWithLongLongArg:99];
    
    // when
    [invocationMatcher setExpectedInvocation:expected];
    
    // then
    STAssertFalse([invocationMatcher matches:actual], nil);
}

- (void)testShouldNotMatchIfIntegerArgumentDoesNotEqualExpectedArgument
{
    // given
    NSInvocation *expected = [DummyObject invocationWithIntegerArg:42];
    NSInvocation *actual = [DummyObject invocationWithIntegerArg:99];
    
    // when
    [invocationMatcher setExpectedInvocation:expected];
    
    // then
    STAssertFalse([invocationMatcher matches:actual], nil);
}

- (void)testShouldNotMatchIfUnsignedCharArgumentDoesNotEqualExpectedArgument
{
    // given
    NSInvocation *expected = [DummyObject invocationWithUnsignedCharArg:42];
    NSInvocation *actual = [DummyObject invocationWithUnsignedCharArg:99];
    
    // when
    [invocationMatcher setExpectedInvocation:expected];
    
    // then
    STAssertFalse([invocationMatcher matches:actual], nil);
}

- (void)testShouldNotMatchIfUnsignedIntArgumentDoesNotEqualExpectedArgument
{
    // given
    NSInvocation *expected = [DummyObject invocationWithUnsignedIntArg:42];
    NSInvocation *actual = [DummyObject invocationWithUnsignedIntArg:99];
    
    // when
    [invocationMatcher setExpectedInvocation:expected];
    
    // then
    STAssertFalse([invocationMatcher matches:actual], nil);
}

- (void)testShouldNotMatchIfUnsignedShortArgumentDoesNotEqualExpectedArgument
{
    // given
    NSInvocation *expected = [DummyObject invocationWithUnsignedShortArg:42];
    NSInvocation *actual = [DummyObject invocationWithUnsignedShortArg:99];
    
    // when
    [invocationMatcher setExpectedInvocation:expected];
    
    // then
    STAssertFalse([invocationMatcher matches:actual], nil);
}

- (void)testShouldNotMatchIfUnsignedLongArgumentDoesNotEqualExpectedArgument
{
    // given
    NSInvocation *expected = [DummyObject invocationWithUnsignedLongArg:42];
    NSInvocation *actual = [DummyObject invocationWithUnsignedLongArg:99];
    
    // when
    [invocationMatcher setExpectedInvocation:expected];
    
    // then
    STAssertFalse([invocationMatcher matches:actual], nil);
}

- (void)testShouldNotMatchIfUnsignedLongLongArgumentDoesNotEqualExpectedArgument
{
    // given
    NSInvocation *expected = [DummyObject invocationWithUnsignedLongLongArg:42];
    NSInvocation *actual = [DummyObject invocationWithUnsignedLongLongArg:99];
    
    // when
    [invocationMatcher setExpectedInvocation:expected];
    
    // then
    STAssertFalse([invocationMatcher matches:actual], nil);
}

- (void)testShouldNotMatchIfUnsignedIntegerArgumentDoesNotEqualExpectedArgument
{
    // given
    NSInvocation *expected = [DummyObject invocationWithUnsignedIntegerArg:42];
    NSInvocation *actual = [DummyObject invocationWithUnsignedIntegerArg:99];
    
    // when
    [invocationMatcher setExpectedInvocation:expected];
    
    // then
    STAssertFalse([invocationMatcher matches:actual], nil);
}

- (void)testShouldNotMatchIfFloatArgumentConvertedToObjectDoesNotSatisfyOverrideMatcher
{
    // given
    NSInvocation *expected = [DummyObject invocationWithFloatArg:0];   // Argument will be ignored.
    NSInvocation *actual = [DummyObject invocationWithFloatArg:3.14];
    
    // when
    [invocationMatcher setMatcher:closeTo(3.5, 0.1) atIndex:2];
    [invocationMatcher setExpectedInvocation:expected];
    
    // then
    STAssertFalse([invocationMatcher matches:actual], nil);
}

- (void)testShouldNotMatchIfDoubleArgumentConvertedToObjectDoesNotSatisfyOverrideMatcher
{
    // given
    NSInvocation *expected = [DummyObject invocationWithDoubleArg:0];   // Argument will be ignored.
    NSInvocation *actual = [DummyObject invocationWithDoubleArg:3.14];
    
    // when
    [invocationMatcher setMatcher:closeTo(3.5, 0.1) atIndex:2];
    [invocationMatcher setExpectedInvocation:expected];
    
    // then
    STAssertFalse([invocationMatcher matches:actual], nil);
}

- (void)testShouldMatchOverrideMatcherSpecifiedForSecondPrimitiveArgument
{
    // given
    NSInvocation *expected = [DummyObject invocationWithObjectArg:@"something" intArg:0];
    NSInvocation *actual = [DummyObject invocationWithObjectArg:@"something" intArg:51];
    
    // when
    [invocationMatcher setMatcher:greaterThan([NSNumber numberWithInt:50]) atIndex:3];
    [invocationMatcher setExpectedInvocation:expected];
    
    // then
    STAssertTrue([invocationMatcher matches:actual], nil);
}

- (void)testArgumentMatchersCountShouldReflectLargestSetMatcherIndex
{
    // given
    [invocationMatcher setMatcher:equalTo(@"irrelevant") atIndex:3];
    [invocationMatcher setMatcher:equalTo(@"irrelevant") atIndex:2];
    
    // then
    assertThatUnsignedInteger([invocationMatcher argumentMatchersCount], equalToUnsignedInteger(4));
}

@end
