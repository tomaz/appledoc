//
//  GBAdoptedProtocolsProviderTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 26.7.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBTestObjectsRegistry.h"
#import "GBDataObjects.h"

@interface GBMethodDataTesting : GBObjectsAssertor
@end

@implementation GBMethodDataTesting

#pragma mark Initialization testing

- (void)testMethodData_shouldInitializeSingleTypelessInstanceSelector {
	// setup & execute
	GBMethodData *data = [GBTestObjectsRegistry instanceMethodWithArguments:[GBMethodArgument methodArgumentWithName:@"method"], nil];
	// verify
	assertThat(data.methodSelector, is(@"method"));
}

- (void)testMethodData_shouldInitializeSingleTypedInstanceSelector {
	// setup & execute
	GBMethodData *data = [GBTestObjectsRegistry instanceMethodWithNames:@"method", nil];
	// verify
	assertThat(data.methodSelector, is(@"method:"));
}

- (void)testMethodData_shouldInitializeMultipleArgumentInstanceSelector {
	// setup & execute
	GBMethodData *data = [GBTestObjectsRegistry instanceMethodWithNames:@"delegate", @"checked", @"something", nil];
	// verify
	assertThat(data.methodSelector, is(@"delegate:checked:something:"));
}

- (void)testMethodData_shouldInitializeSingleTypelessClassSelector {
	// setup & execute
	GBMethodData *data = [GBTestObjectsRegistry classMethodWithArguments:[GBMethodArgument methodArgumentWithName:@"method"], nil];
	// verify
	assertThat(data.methodSelector, is(@"method"));
}

- (void)testMethodData_shouldInitializeSingleTypedClassSelector {
	// setup & execute
	GBMethodData *data = [GBTestObjectsRegistry classMethodWithNames:@"method", nil];
	// verify
	assertThat(data.methodSelector, is(@"method:"));
}

- (void)testMethodData_shouldInitializeMultipleArgumentClassSelector {
	// setup & execute
	GBMethodData *data = [GBTestObjectsRegistry classMethodWithNames:@"delegate", @"checked", @"something", nil];
	// verify
	assertThat(data.methodSelector, is(@"delegate:checked:something:"));
}

- (void)testMethodData_shouldInitializePropertySelector {
	// setup & execute
	GBMethodData *data = [GBTestObjectsRegistry propertyMethodWithArgument:@"isSelected"];
	// verify
	assertThat(data.methodSelector, is(@"isSelected"));
}

#pragma mark Merging testing

- (void)testMergeDataFromObject_shouldMergeImplementationDetails {
	// setup - methods don't merge any data, except they need to send base class merging message!
	GBMethodData *original = [GBTestObjectsRegistry instanceMethodWithNames:@"method", nil];
	GBMethodData *source = [GBTestObjectsRegistry instanceMethodWithNames:@"method", nil];
	[source registerSourceInfo:[GBSourceInfo infoWithFilename:@"file" lineNumber:1]];
	// execute
	[original mergeDataFromObject:source];
	// verify - simple testing here, fully tested in GBModelBaseTesting!
	assertThatInteger([original.sourceInfos count], equalToInteger(1));
}

#pragma mark Formatted components testing

- (void)testFormattedComponents_shouldReturnSimplePropertyComponents {
	// setup
	NSArray *attributes = [NSArray arrayWithObjects:@"readonly", nil];
	NSArray *components = [NSArray arrayWithObjects:@"BOOL", @"name", nil];
	GBMethodData *method = [GBMethodData propertyDataWithAttributes:attributes components:components];
	// execute
	NSArray *result = [method formattedComponents];
	// verify: {@property}-{ }-{(}-{readonly}-{)}-{ }-{BOOL}-{ }-{name}
	[self assertFormattedComponents:result match:
	 @"@property", 0, GBNULL, 
	 @" ", 0, GBNULL, 
	 @"(", 0, GBNULL,
	 @"readonly", 0, GBNULL,
	 @")", 0, GBNULL,
	 @" ", 0, GBNULL,
	 @"BOOL", 0, GBNULL,
	 @" ", 0, GBNULL,
	 @"name", 0, GBNULL,
	 nil];
}

- (void)testFormattedComponents_shouldReturnComplexPropertyComponents {
	// setup
	NSArray *attributes = [NSArray arrayWithObjects:@"readonly", @"nonatomic", nil];
	NSArray *components = [NSArray arrayWithObjects:@"unsigned", @"int", @"name", nil];
	GBMethodData *method = [GBMethodData propertyDataWithAttributes:attributes components:components];
	// execute
	NSArray *result = [method formattedComponents];
	// verify: {@property}-{ }-{(}-{readonly}-{,}-{ }-{nonatomic}-{)}-{ }-{unsigned}-{ }-{int}-{ }-{name}
	[self assertFormattedComponents:result match:
	 @"@property", 0, GBNULL, 
	 @" ", 0, GBNULL, 
	 @"(", 0, GBNULL,
	 @"readonly", 0, GBNULL,
	 @",", 0, GBNULL,
	 @" ", 0, GBNULL,
	 @"nonatomic", 0, GBNULL,
	 @")", 0, GBNULL,
	 @" ", 0, GBNULL,
	 @"unsigned", 0, GBNULL,
	 @" ", 0, GBNULL,
	 @"int", 0, GBNULL,
	 @" ", 0, GBNULL,
	 @"name", 0, GBNULL,
	 nil];
}

- (void)testFormattedComponents_shouldReturnPointerPropertyComponents {
	// setup
	NSArray *attributes = [NSArray arrayWithObjects:@"readonly", nil];
	NSArray *components = [NSArray arrayWithObjects:@"NSString", @"*", @"name", nil];
	GBMethodData *method = [GBMethodData propertyDataWithAttributes:attributes components:components];
	// execute
	NSArray *result = [method formattedComponents];
	// verify: {@property}-{ }-{(}-{readonly}-{)}-{ }-{NSString}-{ }-{*}-{name}
	[self assertFormattedComponents:result match:
	 @"@property", 0, GBNULL, 
	 @" ", 0, GBNULL, 
	 @"(", 0, GBNULL,
	 @"readonly", 0, GBNULL,
	 @")", 0, GBNULL,
	 @" ", 0, GBNULL,
	 @"NSString", 0, GBNULL,
	 @" ", 0, GBNULL,
	 @"*", 0, GBNULL,
	 @"name", 0, GBNULL,
	 nil];
}

- (void)testFormattedComponents_shouldReturnSimpleInstanceMethodComponents {
	// setup
	NSArray *results = [NSArray arrayWithObjects:@"void", nil];
	NSArray *arguments = [NSArray arrayWithObjects:[GBMethodArgument methodArgumentWithName:@"method"], nil];
	GBMethodData *method = [GBMethodData methodDataWithType:GBMethodTypeInstance result:results arguments:arguments];
	// execute
	NSArray *result = [method formattedComponents];
	// verify: {-}-{ }-{(}-{void}-{)}-{method}
	[self assertFormattedComponents:result match:
	 @"-", 0, GBNULL, 
	 @" ", 0, GBNULL, 
	 @"(", 0, GBNULL,
	 @"void", 0, GBNULL,
	 @")", 0, GBNULL,
	 @"method", 0, GBNULL,
	 nil];
}

- (void)testFormattedComponents_shouldReturnSingleArgumentInstanceMethodComponents {
	// setup
	NSArray *results = [NSArray arrayWithObjects:@"unsigned", @"int", nil];
	NSArray *types = [NSArray arrayWithObjects:@"bla", @"blu", nil];
	NSArray *arguments = [NSArray arrayWithObjects:[GBMethodArgument methodArgumentWithName:@"method" types:types var:@"val"], nil];
	GBMethodData *method = [GBMethodData methodDataWithType:GBMethodTypeInstance result:results arguments:arguments];
	// execute
	NSArray *result = [method formattedComponents];
	// verify: {-}-{ }-{(}-{BOOL}-{)}-{method}-{:}-{(}-{int}-{)}-{val}
	[self assertFormattedComponents:result match:
	 @"-", 0, GBNULL, 
	 @" ", 0, GBNULL, 
	 @"(", 0, GBNULL,
	 @"unsigned", 0, GBNULL,
	 @" ", 0, GBNULL, 
	 @"int", 0, GBNULL,
	 @")", 0, GBNULL,
	 @"method", 0, GBNULL,
	 @":", 0, GBNULL, 
	 @"(", 0, GBNULL, 
	 @"bla", 0, GBNULL, 
	 @" ", 0, GBNULL, 
	 @"blu", 0, GBNULL, 
	 @")", 0, GBNULL, 
	 @"val", 1, GBNULL, 
	 nil];
}

- (void)testFormattedComponents_shouldReturnMultiArgumentInstanceMethodComponents {
	// setup
	NSArray *results = [NSArray arrayWithObjects:@"BOOL", nil];
	NSArray *types = [NSArray arrayWithObjects:@"int", nil];
	NSArray *arguments = [NSArray arrayWithObjects:
						  [GBMethodArgument methodArgumentWithName:@"doSomething" types:types var:@"val"], 
						  [GBMethodArgument methodArgumentWithName:@"withOperator" types:types var:@"op"], nil];
	GBMethodData *method = [GBMethodData methodDataWithType:GBMethodTypeInstance result:results arguments:arguments];
	// execute
	NSArray *result = [method formattedComponents];
	// verify: {-}-{ }-{(}-{BOOL}-{)}-{doSomething}-{:}-{(}-{int}-{)}-{val}-{ }-{withOperator}-{:}-{(}-{int}-{)}-{op}
	[self assertFormattedComponents:result match:
	 @"-", 0, GBNULL, 
	 @" ", 0, GBNULL, 
	 @"(", 0, GBNULL,
	 @"BOOL", 0, GBNULL,
	 @")", 0, GBNULL,
	 @"doSomething", 0, GBNULL,
	 @":", 0, GBNULL, 
	 @"(", 0, GBNULL, 
	 @"int", 0, GBNULL, 
	 @")", 0, GBNULL, 
	 @"val", 1, GBNULL, 
	 @" ", 0, GBNULL, 
	 @"withOperator", 0, GBNULL,
	 @":", 0, GBNULL, 
	 @"(", 0, GBNULL, 
	 @"int", 0, GBNULL, 
	 @")", 0, GBNULL, 
	 @"op", 1, GBNULL, 
	 nil];
}

- (void)testFormattedComponents_shouldReturnPointerInstanceMethodComponents {
	// setup
	NSArray *results = [NSArray arrayWithObjects:@"NSArray", @"*", nil];
	NSArray *types = [NSArray arrayWithObjects:@"NSString", @"*", nil];
	NSArray *arguments = [NSArray arrayWithObjects:[GBMethodArgument methodArgumentWithName:@"method" types:types var:@"val"], nil];
	GBMethodData *method = [GBMethodData methodDataWithType:GBMethodTypeInstance result:results arguments:arguments];
	// execute
	NSArray *result = [method formattedComponents];
	// verify: {-}-{ }-{(}-{BOOL}-{)}-{method}-{:}-{(}-{int}-{)}-{val}
	[self assertFormattedComponents:result match:
	 @"-", 0, GBNULL, 
	 @" ", 0, GBNULL, 
	 @"(", 0, GBNULL,
	 @"NSArray", 0, GBNULL,
	 @" ", 0, GBNULL, 
	 @"*", 0, GBNULL,
	 @")", 0, GBNULL,
	 @"method", 0, GBNULL,
	 @":", 0, GBNULL, 
	 @"(", 0, GBNULL, 
	 @"NSString", 0, GBNULL, 
	 @" ", 0, GBNULL, 
	 @"*", 0, GBNULL, 
	 @")", 0, GBNULL, 
	 @"val", 1, GBNULL, 
	 nil];
}

- (void)testFormattedComponents_shouldReturnClassMethodComponents {
	// setup
	NSArray *results = [NSArray arrayWithObjects:@"void", nil];
	NSArray *arguments = [NSArray arrayWithObjects:[GBMethodArgument methodArgumentWithName:@"method"], nil];
	GBMethodData *method = [GBMethodData methodDataWithType:GBMethodTypeClass result:results arguments:arguments];
	// execute
	NSArray *result = [method formattedComponents];
	// verify: {+}-{ }-{(}-{void}-{)}-{method}
	[self assertFormattedComponents:result match:
	 @"+", 0, GBNULL, 
	 @" ", 0, GBNULL, 
	 @"(", 0, GBNULL,
	 @"void", 0, GBNULL,
	 @")", 0, GBNULL,
	 @"method", 0, GBNULL,
	 nil];
}

#pragma mark Helper methods testing

- (void)testMethodSelectorDelimiter_shouldReturnEmptyStringForProperties {
	// setup
	GBMethodData *method = [GBTestObjectsRegistry propertyMethodWithArgument:@"name"];
	// execute & verify
	assertThat(method.methodSelectorDelimiter, is(@""));
}

- (void)testMethodSelectorDelimiter_shouldReturnEmptyStringForMethodsWithoutParameters {
	// setup
	GBMethodArgument *argument = [GBMethodArgument methodArgumentWithName:@"method"];
	GBMethodData *method = [GBTestObjectsRegistry instanceMethodWithArguments:argument, nil];
	// execute & verify
	assertThat(method.methodSelectorDelimiter, is(@""));
}

- (void)testMethodSelectorDelimiter_shouldReturnEmptyStringForMethodsWithParameters {
	// setup
	GBMethodData *method1 = [GBTestObjectsRegistry instanceMethodWithNames:@"method", nil];
	GBMethodData *method2 = [GBTestObjectsRegistry instanceMethodWithNames:@"doSomething", @"withStyle", nil];
	// execute & verify
	assertThat(method1.methodSelectorDelimiter, is(@":"));
	assertThat(method2.methodSelectorDelimiter, is(@":"));
}

- (void)testMethodPrefix_shouldReturnProperPrefix {
	// setup, execute & verify
	assertThat([[GBTestObjectsRegistry propertyMethodWithArgument:@"name"] methodPrefix], is(@""));
	assertThat(([[GBTestObjectsRegistry instanceMethodWithNames:@"method", nil] methodPrefix]), is(@"-"));
	assertThat(([[GBTestObjectsRegistry classMethodWithNames:@"method", nil] methodPrefix]), is(@"+"));
}

- (void)testIsTopLevelObject_shouldReturnNO {
	// setup & execute
	GBMethodData *method = [GBTestObjectsRegistry instanceMethodWithNames:@"method", nil];
	// verify
	assertThatBool(method.isTopLevelObject, equalToBool(NO));
}

@end
