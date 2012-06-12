//---------------------------------------------------------------------------------------
//  $Id$
//  Copyright (c) 2004-2010 by Mulle Kybernetik. See License file for details.
//---------------------------------------------------------------------------------------

#import "OCMConstraintTests.h"
#import <OCMock/OCMConstraint.h>


@implementation OCMConstraintTests

- (void)setUp
{
	didCallCustomConstraint = NO;
}

- (void)testAnyAcceptsAnything
{
	OCMConstraint *constraint = [OCMAnyConstraint constraint];
	
	STAssertTrue([constraint evaluate:@"foo"], @"Should have accepted a value.");
	STAssertTrue([constraint evaluate:@"foo"], @"Should have accepted another value.");
	STAssertTrue([constraint evaluate:@"foo"], @"Should have accepted nil.");	
}

- (void)testIsNilAcceptsOnlyNil
{
	OCMConstraint *constraint = [OCMIsNilConstraint constraint];
	
	STAssertFalse([constraint evaluate:@"foo"], @"Should not have accepted a value.");
	STAssertTrue([constraint evaluate:nil], @"Should have accepted nil.");	
}

- (void)testIsNotNilAcceptsAnythingButNil
{
	OCMConstraint *constraint = [OCMIsNotNilConstraint constraint];
	
	STAssertTrue([constraint evaluate:@"foo"], @"Should have accepted a value.");
	STAssertFalse([constraint evaluate:nil], @"Should not have accepted nil.");	
}

- (void)testNotEqualAcceptsAnythingButValue
{
	OCMIsNotEqualConstraint *constraint = [OCMIsNotEqualConstraint constraint];
	constraint->testValue = @"foo";
	
	STAssertFalse([constraint evaluate:@"foo"], @"Should not have accepted value.");
	STAssertTrue([constraint evaluate:@"bar"], @"Should have accepted other value.");	
	STAssertTrue([constraint evaluate:nil], @"Should have accepted nil.");	
}


- (BOOL)checkArg:(id)theArg
{
	didCallCustomConstraint = YES;
	return [theArg isEqualToString:@"foo"];
}

- (void)testUsesPlainMethod
{
	OCMConstraint *constraint = CONSTRAINT(@selector(checkArg:));

	STAssertTrue([constraint evaluate:@"foo"], @"Should have accepted foo.");
	STAssertTrue(didCallCustomConstraint, @"Should have used custom method.");
	STAssertFalse([constraint evaluate:@"bar"], @"Should not have accepted bar.");
}


- (BOOL)checkArg:(id)theArg withValue:(id)value
{
	didCallCustomConstraint = YES;
	return [theArg isEqual:value];
}

- (void)testUsesMethodWithValue
{
	OCMConstraint *constraint = CONSTRAINTV(@selector(checkArg:withValue:), @"foo");

	STAssertTrue([constraint evaluate:@"foo"], @"Should have accepted foo.");
	STAssertTrue(didCallCustomConstraint, @"Should have used custom method.");
	STAssertFalse([constraint evaluate:@"bar"], @"Should not have accepted bar.");
}


- (void)testRaisesExceptionWhenConstraintMethodDoesNotTakeArgument
{
	STAssertThrows(CONSTRAINTV(@selector(checkArg:), @"bar"), @"Should have thrown for invalid constraint method.");
}


- (void)testRaisesExceptionOnUnknownSelector
{
	STAssertThrows(CONSTRAINTV(@selector(checkArgXXX:), @"bar"), @"Should have thrown for unknown constraint method.");	
}


#if NS_BLOCKS_AVAILABLE

-(void)testUsesBlock
{
	BOOL (^checkForFooBlock)(id) = ^(id value)
		{
			return [value isEqualToString:@"foo"];
		};
	
	OCMBlockConstraint *constraint = [[[OCMBlockConstraint alloc] initWithConstraintBlock:checkForFooBlock] autorelease];

	STAssertTrue([constraint evaluate:@"foo"], @"Should have accepted foo.");
	STAssertFalse([constraint evaluate:@"bar"], @"Should not have accepted bar.");
}

-(void)testBlockConstraintCanCaptureArgument 
{
	__block NSString *captured;
	BOOL (^captureArgBlock)(id) = ^(id value)
		{
			captured = value;
			return YES;
		};
	
	OCMBlockConstraint *constraint = [[[OCMBlockConstraint alloc] initWithConstraintBlock:captureArgBlock] autorelease];

	[constraint evaluate:@"foo"];
	STAssertEqualObjects(@"foo", captured, @"Should have captured value from last invocation.");
	[constraint evaluate:@"bar"];
	STAssertEqualObjects(@"bar", captured, @"Should have captured value from last invocation.");
}

#endif

@end
