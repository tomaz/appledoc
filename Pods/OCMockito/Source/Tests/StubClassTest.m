//
//  OCMockito - StubClassTest.m
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


@interface ReturningObject : NSObject
@end

@implementation ReturningObject

- (id)methodReturningObject { return self; }
- (id)methodReturningObjectWithArg:(id)arg { return self; }
- (id)methodReturningObjectWithIntArg:(int)arg { return self; }

- (BOOL)methodReturningBool { return NO; }
- (char)methodReturningChar { return 0; }
- (int)methodReturningInt { return 0; }
- (short)methodReturningShort { return 0; }
- (long)methodReturningLong { return 0; }
- (long long)methodReturningLongLong { return 0; }
- (NSInteger)methodReturningInteger { return 0; }
- (unsigned char)methodReturningUnsignedChar { return 0; }
- (unsigned int)methodReturningUnsignedInt { return 0; }
- (unsigned short)methodReturningUnsignedShort { return 0; }
- (unsigned long)methodReturningUnsignedLong { return 0; }
- (unsigned long long)methodReturningUnsignedLongLong { return 0; }
- (NSUInteger)methodReturningUnsignedInteger { return 0; }
- (float)methodReturningFloat { return 0; }
- (double)methodReturningDouble { return 0; }

@end


#pragma mark -

@interface StubClassTest : SenTestCase
@end

@implementation StubClassTest

- (void)testStubbedMethoShouldReturnGivenObject
{
    // given
    ReturningObject *mockObject = mock([ReturningObject class]);
    
    // when
    [given([mockObject methodReturningObject]) willReturn:@"STUBBED"];
    
    // then
    assertThat([mockObject methodReturningObject], is(@"STUBBED"));
}

- (void)testUnstubbedMethodReturningObjectShouldReturnNil
{
    // given
    ReturningObject *mockObject = mock([ReturningObject class]);
    
    // then
    assertThat([mockObject methodReturningObject], is(nilValue()));
}

- (void)testStubsWithDifferentArgsShouldHaveDifferentReturnValues
{
    // given
    ReturningObject *mockObject = mock([ReturningObject class]);
    
    // when
    [given([mockObject methodReturningObjectWithArg:@"foo"]) willReturn:@"FOO"];
    [given([mockObject methodReturningObjectWithArg:@"bar"]) willReturn:@"BAR"];
    
    // then
    assertThat([mockObject methodReturningObjectWithArg:@"foo"], is(@"FOO"));
}

- (void)testStubShouldAcceptArgumentMatchers
{
    // given
    ReturningObject *mockObject = mock([ReturningObject class]);
    
    // when
    [given([mockObject methodReturningObjectWithArg:equalTo(@"foo")]) willReturn:@"FOO"];
    
    // then
    assertThat([mockObject methodReturningObjectWithArg:@"foo"], is(@"FOO"));
}

- (void)testStubShouldReturnValueForMatchingNumericArgument
{
    // given
    ReturningObject *mockObject = mock([ReturningObject class]);
    
    // when
    [given([mockObject methodReturningObjectWithIntArg:1]) willReturn:@"FOO"];
    [given([mockObject methodReturningObjectWithIntArg:2]) willReturn:@"BAR"];
    
    // then
    assertThat([mockObject methodReturningObjectWithIntArg:1], is(@"FOO"));
}

- (void)testStubShouldAcceptMatcherForNumericArgument
{
    // given
    ReturningObject *mockObject = mock([ReturningObject class]);
    
    // when
    [[given([mockObject methodReturningObjectWithIntArg:0])
      withMatcher:greaterThan([NSNumber numberWithInt:1]) forArgument:0] willReturn:@"FOO"];
    
    // then
    assertThat([mockObject methodReturningObjectWithIntArg:2], is(@"FOO"));
}

- (void)testShouldSupportShortcutForSpecifyingMatcherForFirstArgument
{
    // given
    ReturningObject *mockObject = mock([ReturningObject class]);
    
    // when
    [[given([mockObject methodReturningObjectWithIntArg:0])
      withMatcher:greaterThan([NSNumber numberWithInt:1])] willReturn:@"FOO"];
    
    // then
    assertThat([mockObject methodReturningObjectWithIntArg:2], is(@"FOO"));
}

- (void)testStubbedMethodShouldReturnGivenBool
{
    // given
    ReturningObject *mockObject = mock([ReturningObject class]);
    
    // when
    [given([mockObject methodReturningBool]) willReturnBool:YES];
    
    // then
    STAssertTrue([mockObject methodReturningBool], nil);
}

- (void)testStubbedMethodShouldReturnGivenChar
{
    // given
    ReturningObject *mockObject = mock([ReturningObject class]);
    
    // when
    [given([mockObject methodReturningChar]) willReturnChar:'a'];
    
    // then
    assertThatChar([mockObject methodReturningChar], equalToChar('a'));
}

- (void)testStubbedMethodShouldReturnGivenInt
{
    // given
    ReturningObject *mockObject = mock([ReturningObject class]);
    
    // when
    [given([mockObject methodReturningInt]) willReturnInt:42];
    
    // then
    assertThatInt([mockObject methodReturningInt], equalToInt(42));
}

- (void)testStubbedMethodShouldReturnGivenShort
{
    // given
    ReturningObject *mockObject = mock([ReturningObject class]);
    
    // when
    [given([mockObject methodReturningShort]) willReturnShort:42];
    
    // then
    assertThatShort([mockObject methodReturningShort], equalToShort(42));
}

- (void)testStubbedMethodShouldReturnGivenLong
{
    // given
    ReturningObject *mockObject = mock([ReturningObject class]);
    
    // when
    [given([mockObject methodReturningLong]) willReturnLong:42];
    
    // then
    assertThatLong([mockObject methodReturningLong], equalToLong(42));
}

- (void)testStubbedMethodShouldReturnGivenLongLong
{
    // given
    ReturningObject *mockObject = mock([ReturningObject class]);
    
    // when
    [given([mockObject methodReturningLongLong]) willReturnLongLong:42];
    
    // then
    assertThatLongLong([mockObject methodReturningLongLong], equalToLongLong(42));
}

- (void)testStubbedMethodShouldReturnGivenInteger
{
    // given
    ReturningObject *mockObject = mock([ReturningObject class]);
    
    // when
    [given([mockObject methodReturningInteger]) willReturnInteger:42];
    
    // then
    assertThatInteger([mockObject methodReturningInteger], equalToInteger(42));
}

- (void)testStubbedMethodShouldReturnGivenUnsignedChar
{
    // given
    ReturningObject *mockObject = mock([ReturningObject class]);
    
    // when
    [given([mockObject methodReturningUnsignedChar]) willReturnUnsignedChar:'a'];
    
    // then
    assertThatUnsignedChar([mockObject methodReturningUnsignedChar], equalToUnsignedChar('a'));
}

- (void)testStubbedMethodShouldReturnGivenUnsignedInt
{
    // given
    ReturningObject *mockObject = mock([ReturningObject class]);
    
    // when
    [given([mockObject methodReturningUnsignedInt]) willReturnUnsignedInt:42];
    
    // then
    assertThatUnsignedInt([mockObject methodReturningUnsignedInt], equalToUnsignedInt(42));
}

- (void)testStubbedMethodShouldReturnGivenUnsignedShort
{
    // given
    ReturningObject *mockObject = mock([ReturningObject class]);
    
    // when
    [given([mockObject methodReturningUnsignedShort]) willReturnUnsignedShort:42];
    
    // then
    assertThatUnsignedShort([mockObject methodReturningUnsignedShort], equalToUnsignedShort(42));
}

- (void)testStubbedMethodShouldReturnGivenUnsignedLong
{
    // given
    ReturningObject *mockObject = mock([ReturningObject class]);
    
    // when
    [given([mockObject methodReturningUnsignedLong]) willReturnUnsignedLong:42];
    
    // then
    assertThatUnsignedLong([mockObject methodReturningUnsignedLong], equalToUnsignedLong(42));
}

- (void)testStubbedMethodShouldReturnGivenUnsignedLongLong
{
    // given
    ReturningObject *mockObject = mock([ReturningObject class]);
    
    // when
    [given([mockObject methodReturningUnsignedLongLong]) willReturnUnsignedLongLong:42];
    
    // then
    assertThatUnsignedLongLong([mockObject methodReturningUnsignedLongLong], equalToUnsignedLongLong(42));
}

- (void)testStubbedMethodShouldReturnGivenUnsignedInteger
{
    // given
    ReturningObject *mockObject = mock([ReturningObject class]);
    
    // when
    [given([mockObject methodReturningUnsignedInteger]) willReturnUnsignedInteger:42];
    
    // then
    assertThatUnsignedInteger([mockObject methodReturningUnsignedInteger], equalToUnsignedInteger(42));
}

- (void)testStubbedMethodShouldReturnGivenFloat
{
    // given
    ReturningObject *mockObject = mock([ReturningObject class]);
    
    // when
    [given([mockObject methodReturningFloat]) willReturnFloat:42.5];
    
    // then
    assertThatFloat([mockObject methodReturningFloat], equalToFloat(42.5));
}

- (void)testStubbedMethodShouldReturnGivenDouble
{
    // given
    ReturningObject *mockObject = mock([ReturningObject class]);
    
    // when
    [given([mockObject methodReturningDouble]) willReturnDouble:42];
    
    // then
    assertThatDouble([mockObject methodReturningDouble], equalToDouble(42));
}

@end
