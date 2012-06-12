//---------------------------------------------------------------------------------------
//  $Id$
//  Copyright (c) 2006-2008 by Mulle Kybernetik. See License file for details.
//---------------------------------------------------------------------------------------

#import "NSInvocationOCMAdditionsTests.h"
#import "NSInvocation+OCMAdditions.h"

#define TestString @"foo"
#define TestInt 1

@implementation NSInvocationOCMAdditionsTests

- (void)testInvocationDescriptionWithNoArguments
{
	SEL selector = @selector(lowercaseString);
	NSMethodSignature *signature = [[NSString string] methodSignatureForSelector:selector];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
	[invocation setSelector:selector];
	
	STAssertEqualObjects(@"lowercaseString", [invocation invocationDescription], @"");
}

- (void)testInvocationDescriptionWithObjectArgument
{
	SEL selector = @selector(isEqualToNumber:);
	NSMethodSignature *signature = [[NSNumber alloc] methodSignatureForSelector:selector];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
	[invocation setSelector:selector];
	// Give it one argument (starts at index 2)
	NSNumber *argument = [NSNumber numberWithInt:TestInt];
	[invocation setArgument:&argument atIndex:2];
	
	NSString *expected = [NSString stringWithFormat:@"isEqualToNumber:%d", TestInt];
	STAssertEqualObjects(expected, [invocation invocationDescription], @"");
}

- (void)testInvocationDescriptionWithNSStringArgument
{
	SEL selector = @selector(isEqualToString:);
	NSMethodSignature *signature = [[NSString string] methodSignatureForSelector:selector];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
	[invocation setSelector:selector];
	// Give it one argument (starts at index 2)
	NSString *argument = [NSString stringWithString:TestString];
	[invocation setArgument:&argument atIndex:2];
	
	NSString *expected = [NSString stringWithFormat:@"isEqualToString:@\"%@\"", TestString];
	STAssertEqualObjects(expected, [invocation invocationDescription], @"");
}

- (void)testInvocationDescriptionWithObjectArguments
{
	SEL selector = @selector(setValue:forKey:);
	NSMethodSignature *signature = [[NSArray array] methodSignatureForSelector:selector];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
	[invocation setSelector:selector];
	// Give it two arguments
	NSNumber *argumentOne = [NSNumber numberWithInt:TestInt];
	NSString *argumentTwo = [NSString stringWithString:TestString];
	[invocation setArgument:&argumentOne atIndex:2];
	[invocation setArgument:&argumentTwo atIndex:3];
	
	NSString *expected = [NSString stringWithFormat:@"setValue:%d forKey:@\"%@\"", TestInt, TestString];
	STAssertEqualObjects(expected, [invocation invocationDescription], @"");
}

- (void)testInvocationDescriptionWithArrayArgument
{
	SEL selector = @selector(addObjectsFromArray:);
	NSMethodSignature *signature = [[NSMutableArray array] methodSignatureForSelector:selector];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
	[invocation setSelector:selector];
	// Give it one argument (starts at index 2)
	NSArray *argument = [NSArray arrayWithObject:TestString];
	[invocation setArgument:&argument atIndex:2];
	
	NSString *expected = [NSString stringWithFormat:@"addObjectsFromArray:%@", [argument description]];
	STAssertEqualObjects(expected, [invocation invocationDescription], @"");
}

- (void)testInvocationDescriptionWithIntArgument
{
	SEL selector = @selector(initWithInt:);
	NSMethodSignature *signature = [[NSNumber alloc] methodSignatureForSelector:selector];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
	[invocation setSelector:selector];
	// Give it an argument
	int argumentOne = TestInt;
	[invocation setArgument:&argumentOne atIndex:2];
	
	NSString *expected = [NSString stringWithFormat:@"initWithInt:%d", TestInt];
	STAssertEqualObjects(expected, [invocation invocationDescription], @"");
}

- (void)testInvocationDescriptionWithUnsignedIntArgument
{
	SEL selector = @selector(initWithUnsignedInt:);
	NSMethodSignature *signature = [[NSNumber alloc] methodSignatureForSelector:selector];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
	[invocation setSelector:selector];
	// Give it an argument
	unsigned int argumentOne = TestInt;
	[invocation setArgument:&argumentOne atIndex:2];
	
	NSString *expected = [NSString stringWithFormat:@"initWithUnsignedInt:%d", TestInt];
	STAssertEqualObjects(expected, [invocation invocationDescription], @"");
}

- (void)testInvocationDescriptionWithBoolArgument
{
	SEL selector = @selector(initWithBool:);
	NSMethodSignature *signature = [[NSNumber alloc] methodSignatureForSelector:selector];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
	[invocation setSelector:selector];
	// Give it an argument
	BOOL argumentOne = TRUE;
	[invocation setArgument:&argumentOne atIndex:2];
	
	NSString *expected = [NSString stringWithFormat:@"initWithBool:YES"];
	STAssertEqualObjects(expected, [invocation invocationDescription], @"");
}

- (void)testInvocationDescriptionWithCharArgument
{
	SEL selector = @selector(initWithChar:);
	NSMethodSignature *signature = [[NSNumber alloc] methodSignatureForSelector:selector];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
	[invocation setSelector:selector];
	// Give it an argument
	char argumentOne = 'd';
	[invocation setArgument:&argumentOne atIndex:2];
	
	NSString *expected = [NSString stringWithFormat:@"initWithChar:'%c'", argumentOne];
	STAssertEqualObjects(expected, [invocation invocationDescription], @"");
}

- (void)testInvocationDescriptionWithUnsignedCharArgument
{
	NSNumber *dummyNumber = [NSNumber alloc];
	
	SEL selector = @selector(initWithUnsignedChar:);
	NSMethodSignature *signature = [dummyNumber methodSignatureForSelector:selector];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
	[invocation setSelector:selector];
	// Give it an argument
	unsigned char argumentOne = 'd';
	[invocation setArgument:&argumentOne atIndex:2];
	
	NSString *expected = [NSString stringWithFormat:@"initWithUnsignedChar:'%c'", argumentOne];
	STAssertEqualObjects(expected, [invocation invocationDescription], @"");
}

- (void)testInvocationDescriptionWithDoubleArgument
{
	SEL selector = @selector(initWithDouble:);
	NSMethodSignature *signature = [[NSNumber alloc] methodSignatureForSelector:selector];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
	[invocation setSelector:selector];
	// Give it an argument
	double argumentOne = 1;
	[invocation setArgument:&argumentOne atIndex:2];
	
	NSString *expected = [NSString stringWithFormat:@"initWithDouble:%f", argumentOne];
	STAssertEqualObjects(expected, [invocation invocationDescription], @"");
}

- (void)testInvocationDescriptionWithFloatArgument
{
	SEL selector = @selector(initWithFloat:);
	NSMethodSignature *signature = [[NSNumber alloc] methodSignatureForSelector:selector];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
	[invocation setSelector:selector];
	// Give it an argument
	float argumentOne = 1;
	[invocation setArgument:&argumentOne atIndex:2];
	
	NSString *expected = [NSString stringWithFormat:@"initWithFloat:%f", argumentOne];
	STAssertEqualObjects(expected, [invocation invocationDescription], @"");
}

- (void)testInvocationDescriptionWithLongArgument
{
	SEL selector = @selector(initWithLong:);
	NSMethodSignature *signature = [[NSNumber alloc] methodSignatureForSelector:selector];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
	[invocation setSelector:selector];
	// Give it an argument
	long argumentOne = 1;
	[invocation setArgument:&argumentOne atIndex:2];
	
	NSString *expected = [NSString stringWithFormat:@"initWithLong:%d", argumentOne];
	STAssertEqualObjects(expected, [invocation invocationDescription], @"");
}

- (void)testInvocationDescriptionWithUnsignedLongArgument
{
	SEL selector = @selector(initWithUnsignedLong:);
	NSMethodSignature *signature = [[NSNumber alloc] methodSignatureForSelector:selector];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
	[invocation setSelector:selector];
	// Give it an argument
	unsigned long argumentOne = 1;
	[invocation setArgument:&argumentOne atIndex:2];
	
	NSString *expected = [NSString stringWithFormat:@"initWithUnsignedLong:%u", argumentOne];
	STAssertEqualObjects(expected, [invocation invocationDescription], @"");
}

- (void)testInvocationDescriptionWithLongLongArgument
{
	SEL selector = @selector(initWithLongLong:);
	NSMethodSignature *signature = [[NSNumber alloc] methodSignatureForSelector:selector];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
	[invocation setSelector:selector];
	// Give it an argument
	long long argumentOne = 1;
	[invocation setArgument:&argumentOne atIndex:2];
	
	NSString *expected = [NSString stringWithFormat:@"initWithLongLong:%qi", argumentOne];
	STAssertEqualObjects(expected, [invocation invocationDescription], @"");
}

- (void)testInvocationDescriptionWithUnsignedLongLongArgument
{
	SEL selector = @selector(initWithUnsignedLongLong:);
	NSMethodSignature *signature = [[NSNumber alloc] methodSignatureForSelector:selector];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
	[invocation setSelector:selector];
	// Give it an argument
	unsigned long long argumentOne = 1;
	[invocation setArgument:&argumentOne atIndex:2];
	
	NSString *expected = [NSString stringWithFormat:@"initWithUnsignedLongLong:%qu", argumentOne];
	STAssertEqualObjects(expected, [invocation invocationDescription], @"");
}

- (void)testInvocationDescriptionWithShortArgument
{
	SEL selector = @selector(initWithShort:);
	NSMethodSignature *signature = [[NSNumber alloc] methodSignatureForSelector:selector];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
	[invocation setSelector:selector];
	// Give it an argument
	short argumentOne = 1;
	[invocation setArgument:&argumentOne atIndex:2];
	
	NSString *expected = [NSString stringWithFormat:@"initWithShort:%hi", argumentOne];
	STAssertEqualObjects(expected, [invocation invocationDescription], @"");
}

- (void)testInvocationDescriptionWithUnsignedShortArgument
{
	SEL selector = @selector(initWithUnsignedShort:);
	NSMethodSignature *signature = [[NSNumber alloc] methodSignatureForSelector:selector];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
	[invocation setSelector:selector];
	// Give it an argument
	unsigned short argumentOne = 1;
	[invocation setArgument:&argumentOne atIndex:2];

	NSString *expected = [NSString stringWithFormat:@"initWithUnsignedShort:%hu", argumentOne];
	STAssertEqualObjects(expected, [invocation invocationDescription], @"");
}
/*
- (void)testInvocationDescriptionWithStructArgument
{
	SEL selector = @selector(setFrameSize:);
	NSMethodSignature *signature = [[[NSView alloc] init] methodSignatureForSelector:selector];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
	[invocation setSelector:selector];
	// Give it an argument
	NSSize size;
	size.width = 1;
	size.height = 1;
	[invocation setArgument:&size atIndex:2];
	
	NSString *expected = [NSString stringWithFormat:@"setFrameSize:(struct)"];
	STAssertTrue(expected, [[invocation invocationDescription] rangeOfString:description].length > 0, @"");
}
*/
/*
- (void)testInvocationDescriptionWithCStringArgument
{
	SEL selector = @selector(initWithUTF8String:);
	NSMethodSignature *signature = [[NSString alloc] methodSignatureForSelector:selector];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
	[invocation setSelector:selector];
	// Give it an argument
	NSString *string = [NSString stringWithString:@"foo"];
	const char *cString = [string UTF8String]; 
	[invocation setArgument:&cString atIndex:2];

	NSString *expected = @"initWithUTF8String:\"foo\"";
	STAssertEqualObjects(expected, [invocation invocationDescription], @"");
}
*/
- (void)testInvocationDescriptionWithSelectorArgument
{
	SEL selector = @selector(respondsToSelector:);
	NSMethodSignature *signature = [[NSString alloc] methodSignatureForSelector:selector];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
	[invocation setSelector:selector];
	// Give it an argument
	SEL selectorValue = @selector(foo);
	[invocation setArgument:&selectorValue atIndex:2];
	
	NSString *expected = [NSString stringWithFormat:@"respondsToSelector:@selector(%@)", NSStringFromSelector(selectorValue)];
	STAssertEqualObjects(expected, [invocation invocationDescription], @"");
}

- (void)testInvocationDescriptionWithPointerArgument
{
	SEL selector = @selector(initWithBytes:length:);
	NSMethodSignature *signature = [[NSData alloc] methodSignatureForSelector:selector];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
	[invocation setSelector:selector];
	// Give it an argument
	NSData *data = [@"foo" dataUsingEncoding:NSUTF8StringEncoding];
	const void *bytes = [[@"foo" dataUsingEncoding:NSUTF8StringEncoding] bytes];
	NSUInteger length = [data length];
	[invocation setArgument:&bytes atIndex:2];
	[invocation setArgument:&length atIndex:3];
	
	NSString *expected1 = [NSString stringWithFormat:@"initWithBytes:"];
	NSString *expected2 = [NSString stringWithFormat:@"length:%d", length];
	NSString *invocationDescription = [invocation invocationDescription];
	STAssertTrue([invocationDescription rangeOfString:expected1].length > 0, @"");
	STAssertTrue([invocationDescription rangeOfString:expected2].length > 0, @"");
}

- (void)testInvocationDescriptionWithNilArgument
{
	SEL selector = @selector(initWithString:);
	NSMethodSignature *signature = [[NSString alloc] methodSignatureForSelector:selector];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
	[invocation setSelector:selector];
	// Give it an argument
	NSString *argString = nil;
	[invocation setArgument:&argString atIndex:2];
	
	NSString *expected = [NSString stringWithFormat:@"initWithString:nil"];
	STAssertEqualObjects(expected, [invocation invocationDescription], @"");
}

@end
