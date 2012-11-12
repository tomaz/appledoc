#import <SenTestingKit/SenTestingKit.h>

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

@interface Example : SenTestCase
@end

@implementation Example

- (void)testSimpleVerify
{
    NSMutableArray *mockArray = mock([NSMutableArray class]);
    
    [mockArray removeAllObjects];
    
    [verify(mockArray) removeAllObjects];
}

- (void)testVerifyWithArgument
{
    NSMutableArray *mockArray = mock([NSMutableArray class]);
    
    [mockArray removeObject:@"This is a test"];
    
    [verify(mockArray) removeObject:@"This is a test"];
}

- (void)testVerifyWithMatcher
{
    NSMutableArray *mockArray = mock([NSMutableArray class]);
    
    [mockArray removeObject:@"This is a test"];
    
    [verify(mockArray) removeObject:startsWith(@"This is")];
}

- (void)testVerifyWithPrimitive
{
    NSMutableArray *mockArray = mock([NSMutableArray class]);
    
    [mockArray removeObjectAtIndex:2];
    
    [verify(mockArray) removeObjectAtIndex:2];
}

- (void)testVerifyWithMatcherForPrimitive
{
    NSMutableArray *mockArray = mock([NSMutableArray class]);
    
    [mockArray removeObjectAtIndex:2];
    
    [[verify(mockArray) withMatcher:greaterThan([NSNumber numberWithInt:1]) forArgument:0]
     removeObjectAtIndex:0];    // The 0 is a placeholder, replaced by the matcher
}

- (void)testSimpleStub
{
    NSArray *mockArray = mock([NSArray class]);
    
    [given([mockArray lastObject]) willReturn:@"last"];
    
    assertThat([mockArray lastObject], is(@"last"));
}

- (void)testStubsWithArguments
{
    NSArray *mockArray = mock([NSArray class]);
    
    [given([mockArray objectAtIndex:0]) willReturn:@"foo"];
    [given([mockArray objectAtIndex:1]) willReturn:@"bar"];
    
    assertThat([mockArray objectAtIndex:0], is(@"foo"));
}

- (void)testStubReturningPrimitive
{
    NSArray *mockArray = mock([NSArray class]);
    
    [given([mockArray count]) willReturnUnsignedInteger:3];
    
    assertThatUnsignedInteger([mockArray count], is(equalToUnsignedInteger(3)));
}

@end
