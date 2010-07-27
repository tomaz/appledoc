//
//  GBObjectiveCParser-ClassParsingTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 25.7.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBStore.h"
#import "GBObjectiveCParser.h"

// Note that we're only testing class specific stuff here - i.e. all common parsing modules (adopted protocols,
// ivars, methods...) are tested separately to avoid repetition.

@interface GBObjectiveCParserClassParsingTesting : GBObjectsAssertor
@end

@implementation GBObjectiveCParserClassParsingTesting

#pragma mark Classes definitions parsing testing

- (void)testParseObjectsFromString_shouldRegisterClassDefinition {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass @end" toStore:store];
	// verify
	NSArray *classes = [store classesSortedByName];
	assertThatInteger([classes count], equalToInteger(1));
	assertThat([[classes objectAtIndex:0] className], is(@"MyClass"));
}

- (void)testParseObjectsFromString_shouldRegisterAllClassDefinitions {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass1 @end   @interface MyClass2 @end" toStore:store];
	// verify
	NSArray *classes = [store classesSortedByName];
	assertThatInteger([classes count], equalToInteger(2));
	assertThat([[classes objectAtIndex:0] className], is(@"MyClass1"));
	assertThat([[classes objectAtIndex:1] className], is(@"MyClass2"));
}

- (void)testParseObjectsFromString_shouldRegisterRootClass {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass @end" toStore:store];
	// verify
	GBClassData *class = [[store classes] anyObject];
	assertThat(class.superclassName, is(nil));
}

- (void)testParseObjectsFromString_shouldRegisterDerivedClass {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass : NSObject @end" toStore:store];
	// verify
	GBClassData *class = [[store classes] anyObject];
	assertThat(class.superclassName, is(@"NSObject"));
}

#pragma mark Classes declarations parsing testing

- (void)testParseObjectsFromString_shouldRegisterClassDeclaration {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@implementation MyClass @end" toStore:store];
	// verify
	NSArray *classes = [store classesSortedByName];
	assertThatInteger([classes count], equalToInteger(1));
	assertThat([[classes objectAtIndex:0] className], is(@"MyClass"));
}

- (void)testParseObjectsFromString_shouldRegisterAllClassDeclarations {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@implementation MyClass1 @end   @implementation MyClass2 @end" toStore:store];
	// verify
	NSArray *classes = [store classesSortedByName];
	assertThatInteger([classes count], equalToInteger(2));
	assertThat([[classes objectAtIndex:0] className], is(@"MyClass1"));
	assertThat([[classes objectAtIndex:1] className], is(@"MyClass2"));
}

#pragma mark Class definition components parsing testing

- (void)testParseObjectsFromString_shouldRegisterAdoptedProtocols {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass : NSObject <Protocol> @end" toStore:store];
	// verify
	GBClassData *class = [[store classes] anyObject];
	NSArray *protocols = [class.adoptedProtocols protocolsSortedByName];
	assertThatInteger([protocols count], equalToInteger(1));
	assertThat([[protocols objectAtIndex:0] protocolName], is(@"Protocol"));
}

- (void)testParseObjectsFromString_shouldRegisterRootClassAdoptedProtocols {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass <Protocol> @end" toStore:store];
	// verify
	GBClassData *class = [[store classes] anyObject];
	NSArray *protocols = [class.adoptedProtocols protocolsSortedByName];
	assertThatInteger([protocols count], equalToInteger(1));
	assertThat([[protocols objectAtIndex:0] protocolName], is(@"Protocol"));
}

- (void)testParseObjectsFromString_shouldRegisterIvars {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass { int var; } @end" toStore:store];
	// verify
	GBClassData *class = [[store classes] anyObject];
	NSArray *ivars = [class.ivars ivars];
	assertThatInteger([ivars count], equalToInteger(1));
	assertThat([[ivars objectAtIndex:0] ivarName], is(@"var"));
}

- (void)testParseObjectsFromString_shouldRegisterMethodDefinitions {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass -(void)method; @end" toStore:store];
	// verify
	GBClassData *class = [[store classes] anyObject];
	NSArray *methods = [class.methods methods];
	assertThatInteger([methods count], equalToInteger(1));
	assertThat([[methods objectAtIndex:0] methodSelector], is(@"method"));
}

- (void)testParseObjectsFromString_shouldRegisterProperties {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass @property (readonly) int name; @end" toStore:store];
	// verify
	GBClassData *class = [[store classes] anyObject];
	NSArray *methods = [class.methods methods];
	assertThatInteger([methods count], equalToInteger(1));
	assertThat([[methods objectAtIndex:0] methodSelector], is(@"name"));
}

#pragma mark Class declaration components parsing testing

- (void)testParseObjectsFromString_shouldRegisterMethodDeclarations {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@implementation MyClass -(void)method { } @end" toStore:store];
	// verify
	GBClassData *class = [[store classes] anyObject];
	NSArray *methods = [class.methods methods];
	assertThatInteger([methods count], equalToInteger(1));
	assertThat([[methods objectAtIndex:0] methodSelector], is(@"method"));
}

#pragma mark Complex parsing testing

- (void)testParseObjectsFromString_shouldRegisterClassFromRealLifeInput {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:[GBRealLifeDataProvider headerWithClassCategoryAndProtocol] toStore:store];
	// verify - we're not going into details here, just checking that top-level objects were properly parsed!
	assertThatInteger([[store classes] count], equalToInteger(1));
	GBClassData *class = [[store classes] anyObject];
	assertThat(class.className, is(@"GBCalculator"));
	assertThat(class.superclassName, is(@"NSObject"));
}

@end
