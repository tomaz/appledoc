//
//  GBObjectiveCParser-ClassParsingTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 25.7.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBStore.h"
#import "GBDataObjects.h"
#import "GBObjectiveCParser.h"

// Note that we're only testing class specific stuff here - i.e. all common parsing modules (adopted protocols, ivars, methods...) are tested separately to avoid repetition.

@interface GBObjectiveCParserClassParsingTesting : GBObjectsAssertor
@end

@implementation GBObjectiveCParserClassParsingTesting

#pragma mark Classes definitions parsing testing

- (void)testParseObjectsFromString_shouldRegisterClassDefinition {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass @end" sourceFile:@"filename.h" toStore:store];
	// verify
	NSArray *classes = [store classesSortedByName];
	assertThatInteger([classes count], equalToInteger(1));
	assertThat([[classes objectAtIndex:0] nameOfClass], is(@"MyClass"));
}

- (void)testParseObjectsFromString_shouldRegisterClassDefinitionSourceFileAndLineNumber {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass @end" sourceFile:@"filename.h" toStore:store];
	// verify
	NSSet *files = [[[store classesSortedByName] objectAtIndex:0] sourceInfos];
	assertThatInteger([files count], equalToInteger(1));
	assertThat([[files anyObject] filename], is(@"filename.h"));
	assertThatInteger([[files anyObject] lineNumber], equalToInteger(1));
}

- (void)testParseObjectsFromString_shouldRegisterClassDefinitionProperSourceLineNumber {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"\n// cmt\n\n#define DEBUG\n\n/// hello\n@interface MyClass @end" sourceFile:@"filename.h" toStore:store];
	// verify
	NSSet *files = [[[store classesSortedByName] objectAtIndex:0] sourceInfos];
	assertThatInteger([[files anyObject] lineNumber], equalToInteger(7));
}

- (void)testParseObjectsFromString_shouldRegisterAllClassDefinitions {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass1 @end   @interface MyClass2 @end" sourceFile:@"filename.h" toStore:store];
	// verify
	NSArray *classes = [store classesSortedByName];
	assertThatInteger([classes count], equalToInteger(2));
	assertThat([[classes objectAtIndex:0] nameOfClass], is(@"MyClass1"));
	assertThat([[classes objectAtIndex:1] nameOfClass], is(@"MyClass2"));
}

- (void)testParseObjectsFromString_shouldRegisterRootClass {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass @end" sourceFile:@"filename.h" toStore:store];
	// verify
	GBClassData *class = [[store classes] anyObject];
	assertThat(class.nameOfSuperclass, is(nil));
}

- (void)testParseObjectsFromString_shouldRegisterDerivedClass {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass : NSObject @end" sourceFile:@"filename.h" toStore:store];
	// verify
	GBClassData *class = [[store classes] anyObject];
	assertThat(class.nameOfSuperclass, is(@"NSObject"));
}

#pragma mark Classes declarations parsing testing

- (void)testParseObjectsFromString_shouldRegisterClassDeclaration {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@implementation MyClass @end" sourceFile:@"filename.h" toStore:store];
	// verify
	NSArray *classes = [store classesSortedByName];
	assertThatInteger([classes count], equalToInteger(1));
	assertThat([[classes objectAtIndex:0] nameOfClass], is(@"MyClass"));
}

- (void)testParseObjectsFromString_shouldRegisterClassDeclarationSourceFileAndLineNumber {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@implementation MyClass @end" sourceFile:@"filename.h" toStore:store];
	// verify
	NSSet *files = [[[store classesSortedByName] objectAtIndex:0] sourceInfos];
	assertThatInteger([files count], equalToInteger(1));
	assertThat([[files anyObject] filename], is(@"filename.h"));
	assertThatInteger([[files anyObject] lineNumber], equalToInteger(1));
}

- (void)testParseObjectsFromString_shouldRegisterClassDeclarationProperSourceLineNumber {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"\n// cmt\n\n#define DEBUG\n\n/// hello\n@implementation MyClass @end" sourceFile:@"filename.h" toStore:store];
	// verify
	NSSet *files = [[[store classesSortedByName] objectAtIndex:0] sourceInfos];
	assertThatInteger([[files anyObject] lineNumber], equalToInteger(7));
}

- (void)testParseObjectsFromString_shouldRegisterAllClassDeclarations {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@implementation MyClass1 @end   @implementation MyClass2 @end" sourceFile:@"filename.h" toStore:store];
	// verify
	NSArray *classes = [store classesSortedByName];
	assertThatInteger([classes count], equalToInteger(2));
	assertThat([[classes objectAtIndex:0] nameOfClass], is(@"MyClass1"));
	assertThat([[classes objectAtIndex:1] nameOfClass], is(@"MyClass2"));
}

#pragma mark Class comments parsing testing

- (void)testParseObjectsFromString_shouldRegisterClassDefinitionComment {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"/** Comment */ @interface MyClass @end" sourceFile:@"filename.h" toStore:store];
	// verify
	GBClassData *class = [[store classes] anyObject];
	assertThat(class.comment.stringValue, is(@"Comment"));
}

- (void)testParseObjectsFromString_shouldRegisterClassDeclarationComment {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"/** Comment */ @implementation MyClass @end" sourceFile:@"filename.m" toStore:store];
	// verify
	GBClassData *class = [[store classes] anyObject];
	assertThat(class.comment.stringValue, is(@"Comment"));
}

- (void)testParseObjectsFromString_shouldRegisterClassDefinitionCommentSourceFileAndLineNumber {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"/// comment\n\n#define SOMETHING\n\n/** comment */ @interface MyClass @end" sourceFile:@"filename.h" toStore:store];
	// verify
	GBClassData *class = [[store classes] anyObject];
	assertThat(class.comment.sourceInfo.filename, is(@"filename.h"));
	assertThatInteger(class.comment.sourceInfo.lineNumber, equalToInteger(5));
}

- (void)testParseObjectsFromString_shouldRegisterClassDeclarationCommentProperSourceLineNumber {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"/// comment\n\n#define SOMETHING\n\n/** comment */ @implementation MyClass @end" sourceFile:@"filename.h" toStore:store];
	// verify
	GBClassData *class = [[store classes] anyObject];
	assertThat(class.comment.sourceInfo.filename, is(@"filename.h"));
	assertThatInteger(class.comment.sourceInfo.lineNumber, equalToInteger(5));
}

- (void)testParseObjectsFromString_shouldRegisterClassDefinitionCommentForComplexDeclarations {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:
	 @"/** Comment */\n"
	 @"#ifdef SOMETHING\n"
	 @"@interface MyClass : SuperClass\n"
	 @"#else\n"
	 @"@interface MyClass\n"
	 @"#endif\n"
	 @"@end" sourceFile:@"filename.h" toStore:store];
	// verify
	GBClassData *class = [[store classes] anyObject];
	assertThat(class.nameOfClass, is(@"MyClass"));
	assertThat(class.nameOfSuperclass, is(@"SuperClass"));
	assertThat(class.comment.stringValue, is(@"Comment"));
}

- (void)testParseObjectsFromString_shouldProperlyResetComments { 
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"/** Comment */ @interface MyClass -(void)method; @end" sourceFile:@"filename.h" toStore:store];
	// verify
	GBClassData *class = [[store classes] anyObject];
	GBMethodData *method = [class.methods.methods lastObject];
	assertThat(method.comment, is(nil));
}

#pragma mark Class definition components parsing testing

- (void)testParseObjectsFromString_shouldRegisterAdoptedProtocols {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass : NSObject <Protocol> @end" sourceFile:@"filename.h" toStore:store];
	// verify
	GBClassData *class = [[store classes] anyObject];
	NSArray *protocols = [class.adoptedProtocols protocolsSortedByName];
	assertThatInteger([protocols count], equalToInteger(1));
	assertThat([[protocols objectAtIndex:0] nameOfProtocol], is(@"Protocol"));
}

- (void)testParseObjectsFromString_shouldRegisterRootClassAdoptedProtocols {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass <Protocol> @end" sourceFile:@"filename.h" toStore:store];
	// verify
	GBClassData *class = [[store classes] anyObject];
	NSArray *protocols = [class.adoptedProtocols protocolsSortedByName];
	assertThatInteger([protocols count], equalToInteger(1));
	assertThat([[protocols objectAtIndex:0] nameOfProtocol], is(@"Protocol"));
}

- (void)testParseObjectsFromString_shouldIgnoreIvars {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass { int var; } @end" sourceFile:@"filename.h" toStore:store];
	// verify
	GBClassData *class = [[store classes] anyObject];
	NSArray *ivars = [class.ivars ivars];
	assertThatInteger([ivars count], equalToInteger(0));
}

- (void)testParseObjectsFromString_shouldRegisterMethodDefinitions {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass -(void)method; @end" sourceFile:@"filename.h" toStore:store];
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
	[parser parseObjectsFromString:@"@interface MyClass @property (readonly) int name; @end" sourceFile:@"filename.h" toStore:store];
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
	[parser parseObjectsFromString:@"@implementation MyClass -(void)method { } @end" sourceFile:@"filename.h" toStore:store];
	// verify
	GBClassData *class = [[store classes] anyObject];
	NSArray *methods = [class.methods methods];
	assertThatInteger([methods count], equalToInteger(1));
	assertThat([[methods objectAtIndex:0] methodSelector], is(@"method"));
}

#pragma mark Merging testing

- (void)testParseObjectsFromString_shouldMergeClassDefinitions {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass -(void)method1; @end" sourceFile:@"filename1.h" toStore:store];
	[parser parseObjectsFromString:@"@interface MyClass -(void)method2; @end" sourceFile:@"filename2.h" toStore:store];
	// verify - simple testing here, details within GBModelBaseTesting!
	assertThatInteger([[store classes] count], equalToInteger(1));
	GBClassData *class = [[store classes] anyObject];
	NSArray *methods = [class.methods methods];
	assertThatInteger([methods count], equalToInteger(2));
	assertThat([[methods objectAtIndex:0] methodSelector], is(@"method1"));
	assertThat([[methods objectAtIndex:1] methodSelector], is(@"method2"));
}

- (void)testParseObjectsFromString_shouldMergeClassDeclarations {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@implementation MyClass -(void)method1{} @end" sourceFile:@"filename1.m" toStore:store];
	[parser parseObjectsFromString:@"@implementation MyClass -(void)method2{} @end" sourceFile:@"filename2.m" toStore:store];
	// verify - simple testing here, details within GBModelBaseTesting!
	assertThatInteger([[store classes] count], equalToInteger(1));
	GBClassData *class = [[store classes] anyObject];
	NSArray *methods = [class.methods methods];
	assertThatInteger([methods count], equalToInteger(2));
	assertThat([[methods objectAtIndex:0] methodSelector], is(@"method1"));
	assertThat([[methods objectAtIndex:1] methodSelector], is(@"method2"));
}

- (void)testParseObjectsFromString_shouldMergeClassDefinitionAndDeclaration {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass -(void)method1; @end" sourceFile:@"filename.h" toStore:store];
	[parser parseObjectsFromString:@"@implementation MyClass -(void)method2{} @end" sourceFile:@"filename.m" toStore:store];
	// verify - simple testing here, details within GBModelBaseTesting!
	assertThatInteger([[store classes] count], equalToInteger(1));
	GBClassData *class = [[store classes] anyObject];
	NSArray *methods = [class.methods methods];
	assertThatInteger([methods count], equalToInteger(2));
	assertThat([[methods objectAtIndex:0] methodSelector], is(@"method1"));
	assertThat([[methods objectAtIndex:1] methodSelector], is(@"method2"));
}

#pragma mark Complex parsing testing

- (void)testParseObjectsFromString_shouldRegisterClassFromRealLifeHeaderInput {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:[GBRealLifeDataProvider headerWithClassCategoryAndProtocol] sourceFile:@"filename.h" toStore:store];
	// verify - we're not going into details here, just checking that top-level objects were properly parsed!
	assertThatInteger([[store classes] count], equalToInteger(1));
	GBClassData *class = [[store classes] anyObject];
	assertThat(class.nameOfClass, is(@"GBCalculator"));
	assertThat(class.nameOfSuperclass, is(@"NSObject"));
}

- (void)testParseObjectsFromString_shouldRegisterClassFromRealLifeCodeInput {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:[GBRealLifeDataProvider codeWithClassAndCategory] sourceFile:@"filename.m" toStore:store];
	// verify - we're not going into details here, just checking that top-level objects were properly parsed!
	assertThatInteger([[store classes] count], equalToInteger(1));
	GBClassData *class = [[store classes] anyObject];
	assertThat(class.nameOfClass, is(@"GBCalculator"));
	assertThatInteger([class.methods.methods count], equalToInteger(1));
}

@end
