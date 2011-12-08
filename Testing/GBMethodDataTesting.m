//
//  GBAdoptedProtocolsProviderTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 26.7.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBTestObjectsRegistry.h"
#import "GBDataObjects.h"

@interface GBMethodData (PrivateAPI)
@property (readonly) NSString *methodSelectorDelimiter;
@property (readonly) NSString *methodPrefix;
@end

#pragma mark -

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

#pragma mark - Property initializations

- (void)testMethodData_shouldInitializePropertyWithSingleComponent {
	// setup & execute
	NSArray *attributes = [NSArray arrayWithObjects:@"readonly", nil];
	NSArray *components = [NSArray arrayWithObjects:@"UIView", @"*", @"value", nil];
	GBMethodData *data = [GBMethodData propertyDataWithAttributes:attributes components:components];
	// verify
	assertThat(data.methodAttributes, onlyContains(@"readonly", nil));
	assertThat(data.methodResultTypes, onlyContains(@"UIView", @"*", nil));
	assertThat(data.methodSelector, is(@"value"));
}

- (void)testMethodData_shouldInitializePropertyWithMultipleComponents {
	// setup & execute
	NSArray *attributes = [NSArray arrayWithObjects:@"nonatomic", @"assign", nil];
	NSArray *components = [NSArray arrayWithObjects:@"IBOutlet", @"UIView", @"*", @"value", nil];
	GBMethodData *data = [GBMethodData propertyDataWithAttributes:attributes components:components];
	// verify
	assertThat(data.methodAttributes, onlyContains(@"nonatomic", @"assign", nil));
	assertThat(data.methodResultTypes, onlyContains(@"IBOutlet", @"UIView", @"*", nil));
	assertThat(data.methodSelector, is(@"value"));
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

- (void)testMergeDataFromObject_shouldMergeMethodWithDifferentResultType {
	// setup
	GBMethodData *original = [GBMethodData methodDataWithType:GBMethodTypeInstance result:[NSArray arrayWithObject:@"id"] arguments:[NSArray arrayWithObject:[GBMethodArgument methodArgumentWithName:@"method"]]];
	GBMethodData *source = [GBMethodData methodDataWithType:GBMethodTypeInstance result:[NSArray arrayWithObject:@"NSString *"] arguments:[NSArray arrayWithObject:[GBMethodArgument methodArgumentWithName:@"method"]]];
	// execute
	[original mergeDataFromObject:source];
	// verify - should keep original return type
	assertThatInteger([original.methodResultTypes count], equalToInteger(1));
	assertThat([original.methodResultTypes objectAtIndex:0], is(@"id"));
}

- (void)testMergeDataFromObject_shouldMergePropertyWithDifferentResultType {
	// setup
	GBMethodData *original = [GBMethodData propertyDataWithAttributes:[NSArray arrayWithObjects:@"readonly", @"retain", nil] components:[NSArray arrayWithObjects:@"id", @"value", nil]];
	GBMethodData *source = [GBMethodData propertyDataWithAttributes:[NSArray arrayWithObjects:@"readwrite", @"retain", nil] components:[NSArray arrayWithObjects:@"NSString *", @"value", nil]];
	// execute
	[original mergeDataFromObject:source];
	// verify - should keep original return type
	assertThatInteger([original.methodResultTypes count], equalToInteger(1));
	assertThat([original.methodResultTypes objectAtIndex:0], is(@"id"));
}

- (void)testMergeDataFromObject_shouldMergePropertyWithDifferentAttributes {
	// setup
	GBMethodData *original = [GBMethodData propertyDataWithAttributes:[NSArray arrayWithObjects:@"readonly", @"retain", nil] components:[NSArray arrayWithObjects:@"BOOL", @"value", nil]];
	GBMethodData *source = [GBMethodData propertyDataWithAttributes:[NSArray arrayWithObjects:@"readwrite", @"retain", nil] components:[NSArray arrayWithObjects:@"BOOL", @"value", nil]];
	// execute
	[original mergeDataFromObject:source];
	// verify - should keep original attributes
	assertThat([original.methodAttributes objectAtIndex:0], is(@"readonly"));
	assertThat([original.methodAttributes objectAtIndex:1], is(@"retain"));
}

- (void)testMergeDataFromObject_shouldMergeManualPropertyGetterImplementation {
	// setup
	GBMethodData *original = [GBMethodData propertyDataWithAttributes:[NSArray arrayWithObjects:@"readonly", nil] components:[NSArray arrayWithObjects:@"BOOL", @"value", nil]];
	[original registerSourceInfo:[GBSourceInfo infoWithFilename:@"file1" lineNumber:1]];
	GBMethodArgument *arg = [GBMethodArgument methodArgumentWithName:@"value"];
	GBMethodData *source = [GBMethodData methodDataWithType:GBMethodTypeInstance result:[NSArray arrayWithObject:@"BOOL"] arguments:[NSArray arrayWithObject:arg]];
	[source registerSourceInfo:[GBSourceInfo infoWithFilename:@"file2" lineNumber:1]];
	// execute
	[original mergeDataFromObject:source];
	// verify - simple testing here, just to make sure both are used and manual implementation is properly detected (i.e. no exception is thrown), fully tested in GBModelBaseTesting!
	assertThatInteger([original.sourceInfos count], equalToInteger(2));
}

- (void)testMergeDataFromObject_shouldMergeManualPropertySetterImplementation {
	// setup
	GBMethodData *original = [GBMethodData propertyDataWithAttributes:[NSArray arrayWithObjects:@"readonly", nil] components:[NSArray arrayWithObjects:@"BOOL", @"value", nil]];
	[original registerSourceInfo:[GBSourceInfo infoWithFilename:@"file1" lineNumber:1]];
	GBMethodData *source = [GBTestObjectsRegistry instanceMethodWithNames:@"setValue", nil];
	[source registerSourceInfo:[GBSourceInfo infoWithFilename:@"file2" lineNumber:1]];
	// execute
	[original mergeDataFromObject:source];
	// verify - simple testing here, just to make sure both are used and manual implementation is properly detected (i.e. no exception is thrown), fully tested in GBModelBaseTesting!
	assertThatInteger([original.sourceInfos count], equalToInteger(2));
}

- (void)testMergeDataFromObject_shouldMergeManualPropertyGetterAndSetterImplementation {
	// setup
	GBMethodData *original = [GBMethodData propertyDataWithAttributes:[NSArray arrayWithObjects:@"readonly", nil] components:[NSArray arrayWithObjects:@"BOOL", @"value", nil]];
	[original registerSourceInfo:[GBSourceInfo infoWithFilename:@"file1" lineNumber:1]];
	GBMethodArgument *arg = [GBMethodArgument methodArgumentWithName:@"value"];
	GBMethodData *getter = [GBMethodData methodDataWithType:GBMethodTypeInstance result:[NSArray arrayWithObject:@"BOOL"] arguments:[NSArray arrayWithObject:arg]];
	[getter registerSourceInfo:[GBSourceInfo infoWithFilename:@"file2" lineNumber:1]];
	GBMethodData *setter = [GBTestObjectsRegistry instanceMethodWithNames:@"setValue", nil];
	[setter registerSourceInfo:[GBSourceInfo infoWithFilename:@"file3" lineNumber:1]];
	// execute
	[original mergeDataFromObject:getter];
	[original mergeDataFromObject:setter];
	// verify - simple testing here, just to make sure both are used and manual implementation is properly detected (i.e. no exception is thrown), fully tested in GBModelBaseTesting!
	assertThatInteger([original.sourceInfos count], equalToInteger(3));
}

- (void)testMergeDataFromObject_shouldUseArgumentNamesFromComment {
	// setup
	GBMethodArgument *arg1 = [GBMethodArgument methodArgumentWithName:@"method" types:[NSArray arrayWithObject:@"id"] var:@"var"];
	GBMethodData *original = [GBTestObjectsRegistry instanceMethodWithArguments:arg1, nil];
	GBMethodArgument *arg2 = [GBMethodArgument methodArgumentWithName:@"method" types:[NSArray arrayWithObject:@"id"] var:@"theVar"];
	GBMethodData *source = [GBTestObjectsRegistry instanceMethodWithArguments:arg2, nil];
	[source setComment:[GBComment commentWithStringValue:@"Comment"]];
	// execute
	[original mergeDataFromObject:source];
	// verify
	GBMethodArgument *mergedArgument = [original.methodArguments objectAtIndex:0];
	assertThat(mergedArgument.argumentVar, is(@"theVar"));
}

#pragma mark Property helpers

- (void)testPropertySelectors_shouldReturnProperValueForProperties {
	// setup & execute
	NSArray *components = [NSArray arrayWithObjects:@"BOOL", @"value", nil];
	GBMethodData *property1 = [GBMethodData propertyDataWithAttributes:[NSArray arrayWithObjects:@"readonly", nil] components:components];
	GBMethodData *property2 = [GBMethodData propertyDataWithAttributes:[NSArray arrayWithObjects:@"getter", @"=", @"isValue", nil] components:components];
	GBMethodData *property3 = [GBMethodData propertyDataWithAttributes:[NSArray arrayWithObjects:@"setter", @"=", @"setTheValue:", nil] components:components];
	GBMethodData *property4 = [GBMethodData propertyDataWithAttributes:[NSArray arrayWithObjects:@"getter", @"=", @"isValue", @"setter", @"=", @"setTheValue:", nil] components:components];
	// verify
	assertThat(property1.propertyGetterSelector, is(@"value"));
	assertThat(property1.propertySetterSelector, is(@"setValue:"));
	assertThat(property2.propertyGetterSelector, is(@"isValue"));
	assertThat(property2.propertySetterSelector, is(@"setValue:"));
	assertThat(property3.propertyGetterSelector, is(@"value"));
	assertThat(property3.propertySetterSelector, is(@"setTheValue:"));
	assertThat(property4.propertyGetterSelector, is(@"isValue"));
	assertThat(property4.propertySetterSelector, is(@"setTheValue:"));
}

- (void)testPropertySelectors_shouldReturnNilForMethods {
	// setup & execute
	GBMethodData *method = [GBTestObjectsRegistry instanceMethodWithNames:@"value", nil];
	// verify
	assertThat(method.propertyGetterSelector, is(nil));
	assertThat(method.propertySetterSelector, is(nil));
}

#pragma mark Convenience methods testing

- (void)testIsInstanceMethod_shouldReturnProperValue {
	// setup & execute
	GBMethodData *method1 = [GBTestObjectsRegistry classMethodWithNames:@"method", nil];
	GBMethodData *method2 = [GBTestObjectsRegistry instanceMethodWithNames:@"method", nil];
	GBMethodData *method3 = [GBTestObjectsRegistry propertyMethodWithArgument:@"method"];
	// verify
	assertThatBool(method1.isInstanceMethod, equalToBool(NO));
	assertThatBool(method2.isInstanceMethod, equalToBool(YES));
	assertThatBool(method3.isInstanceMethod, equalToBool(NO));
}

- (void)testIsClassMethod_shouldReturnProperValue {
	// setup & execute
	GBMethodData *method1 = [GBTestObjectsRegistry classMethodWithNames:@"method", nil];
	GBMethodData *method2 = [GBTestObjectsRegistry instanceMethodWithNames:@"method", nil];
	GBMethodData *method3 = [GBTestObjectsRegistry propertyMethodWithArgument:@"method"];
	// verify
	assertThatBool(method1.isClassMethod, equalToBool(YES));
	assertThatBool(method2.isClassMethod, equalToBool(NO));
	assertThatBool(method3.isClassMethod, equalToBool(NO));
}

- (void)testIsMethod_shouldReturnProperValue {
	// setup & execute
	GBMethodData *method1 = [GBTestObjectsRegistry classMethodWithNames:@"method", nil];
	GBMethodData *method2 = [GBTestObjectsRegistry instanceMethodWithNames:@"method", nil];
	GBMethodData *method3 = [GBTestObjectsRegistry propertyMethodWithArgument:@"method"];
	// verify
	assertThatBool(method1.isMethod, equalToBool(YES));
	assertThatBool(method2.isMethod, equalToBool(YES));
	assertThatBool(method3.isMethod, equalToBool(NO));
}

- (void)testIsProperty_shouldReturnProperValue {
	// setup & execute
	GBMethodData *method1 = [GBTestObjectsRegistry classMethodWithNames:@"method", nil];
	GBMethodData *method2 = [GBTestObjectsRegistry instanceMethodWithNames:@"method", nil];
	GBMethodData *method3 = [GBTestObjectsRegistry propertyMethodWithArgument:@"method"];
	// verify
	assertThatBool(method1.isProperty, equalToBool(NO));
	assertThatBool(method2.isProperty, equalToBool(NO));
	assertThatBool(method3.isProperty, equalToBool(YES));
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

- (void)testFormattedComponents_shouldProperlyHandlePropertyWithNoAttributes {
	// setup
	NSArray *attributes = [NSArray array];
	NSArray *components = [NSArray arrayWithObjects:@"NSString", @"*", @"name", nil];
	GBMethodData *method = [GBMethodData propertyDataWithAttributes:attributes components:components];
	// execute
	NSArray *result = [method formattedComponents];
	// verify: {@property}-{ }-{NSString}-{ }-{*}-{name}
	[self assertFormattedComponents:result match:
	 @"@property", 0, GBNULL, 
	 @" ", 0, GBNULL, 
	 @"NSString", 0, GBNULL,
	 @" ", 0, GBNULL,
	 @"*", 0, GBNULL,
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

- (void)testFormattedComponents_shouldCombineGetterAndSetterAttributes {
	// setup
	NSArray *attributes = [NSArray arrayWithObjects:@"readonly", @"getter", @"=", @"isName", @"setter", @"=", @"setName:", nil];
	NSArray *components = [NSArray arrayWithObjects:@"NSString", @"*", @"name", nil];
	GBMethodData *method = [GBMethodData propertyDataWithAttributes:attributes components:components];
	// execute
	NSArray *result = [method formattedComponents];
	// verify: {@property}-{ }-{(}-{readonly}-{,}-{ }-{getter}-{=}-{isName}-{,}-{ }-{setter}-{=}-{setName:}-{)}-{ }-{NSString}-{ }-{*}-{name}
	[self assertFormattedComponents:result match:
	 @"@property", 0, GBNULL, 
	 @" ", 0, GBNULL, 
	 @"(", 0, GBNULL,
	 @"readonly", 0, GBNULL,
	 @",", 0, GBNULL,
	 @" ", 0, GBNULL,
	 @"getter", 0, GBNULL,
	 @"=", 0, GBNULL,
	 @"isName", 0, GBNULL,
	 @",", 0, GBNULL,
	 @" ", 0, GBNULL,
	 @"setter", 0, GBNULL,
	 @"=", 0, GBNULL,
	 @"setName:", 0, GBNULL,
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

- (void)testFormattedComponents_shouldReturnVariableArgumentInstanceMethodComponents {
	// setup
	NSArray *results = [NSArray arrayWithObjects:@"void", nil];
	NSArray *types = [NSArray arrayWithObjects:@"id", nil];
	NSArray *macros = [NSArray array];
	NSArray *arguments = [NSArray arrayWithObjects:[GBMethodArgument methodArgumentWithName:@"method" types:types var:@"format" variableArg:YES terminationMacros:macros], nil];
	GBMethodData *method = [GBMethodData methodDataWithType:GBMethodTypeInstance result:results arguments:arguments];
	// execute
	NSArray *result = [method formattedComponents];
	// verify: {-}-{ }-{(}-{void}-{)}-{method}-{:}-{(}-{id}-{)}-{format}-{,}-{ }-{...}
	[self assertFormattedComponents:result match:
	 @"-", 0, GBNULL, 
	 @" ", 0, GBNULL, 
	 @"(", 0, GBNULL,
	 @"void", 0, GBNULL,
	 @")", 0, GBNULL,
	 @"method", 0, GBNULL,
	 @":", 0, GBNULL, 
	 @"(", 0, GBNULL, 
	 @"id", 0, GBNULL, 
	 @")", 0, GBNULL, 
	 @"format", 1, GBNULL, 
	 @",", 0, GBNULL,
	 @" ", 0, GBNULL,
	 @"...", 1, GBNULL,
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

- (void)testFormattedComponents_shouldNotAddSpaceForProtocols {
	// setup
	NSArray *results = [NSArray arrayWithObjects:@"NSArray", @"*", nil];
	NSArray *types = [NSArray arrayWithObjects:@"id", @"<", @"Protocol", @">", nil];
	NSArray *arguments = [NSArray arrayWithObjects:[GBMethodArgument methodArgumentWithName:@"method" types:types var:@"val"], nil];
	GBMethodData *method = [GBMethodData methodDataWithType:GBMethodTypeInstance result:results arguments:arguments];
	// execute
	NSArray *result = [method formattedComponents];
	// verify: {-}-{ }-{(}-{BOOL}-{)}-{method}-{:}-{(}-{id}-{<}-{Protocol}-{>}-{)}-{val}
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
	 @"id", 0, GBNULL, 
	 @"<", 0, GBNULL, 
	 @"Protocol", 0, GBNULL, 
	 @">", 0, GBNULL,
	 @")", 0, GBNULL, 
	 @"val", 1, GBNULL, 
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
	assertThat([[GBTestObjectsRegistry propertyMethodWithArgument:@"name"] methodPrefix], is(@"@property"));
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
