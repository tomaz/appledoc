//
//  GBObjectiveCParser-ClassParsingTesting.m
//  appledocTests
//
//  Created by Jebeom Gyeong on 2/22/20.
//  Copyright © 2020 Gentle Bytes. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "GBStore.h"
#import "GBDataObjects.h"
#import "GBObjectiveCParser.h"
#import "GBTestObjectsRegistry.h"
#import "GBRealLifeDataProvider.h"

@interface GBObjectiveCParser_ClassParsingTesting : XCTestCase

@end

@implementation GBObjectiveCParser_ClassParsingTesting

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

#pragma mark Classes definitions parsing testing

- (void)testParseObjectsFromString_shouldRegisterClassDefinition {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@interface MyClass @end" sourceFile:@"filename.h" toStore:store];
    // verify
    NSArray *classes = [store classesSortedByName];
    XCTAssertEqual([classes count], 1);
    XCTAssertEqualObjects([classes[0] nameOfClass], @"MyClass");
}

- (void)testParseObjectsFromString_shouldRegisterClassDefinitionSourceFileAndLineNumber {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@interface MyClass @end" sourceFile:@"filename.h" toStore:store];
    // verify
    NSSet *files = [[store classesSortedByName][0] sourceInfos];
    XCTAssertEqual([files count], 1);
    XCTAssertEqualObjects([[files anyObject] filename], @"filename.h");
    XCTAssertEqual([[files anyObject] lineNumber], 1);
}

- (void)testParseObjectsFromString_shouldRegisterClassDefinitionProperSourceLineNumber {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"\n// cmt\n\n#define DEBUG\n\n/// hello\n@interface MyClass @end" sourceFile:@"filename.h" toStore:store];
    // verify
    NSSet *files = [[store classesSortedByName][0] sourceInfos];
    XCTAssertEqual([[files anyObject] lineNumber], 7);
}

- (void)testParseObjectsFromString_shouldRegisterAllClassDefinitions {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@interface MyClass1 @end   @interface MyClass2 @end" sourceFile:@"filename.h" toStore:store];
    // verify
    NSArray *classes = [store classesSortedByName];
    XCTAssertEqual([classes count], 2);
    XCTAssertEqualObjects([classes[0] nameOfClass], @"MyClass1");
    XCTAssertEqualObjects([classes[1] nameOfClass], @"MyClass2");
}

- (void)testParseObjectsFromString_shouldRegisterRootClass {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@interface MyClass @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBClassData *class = [[store classes] anyObject];
    XCTAssertNil(class.nameOfSuperclass);
}

- (void)testParseObjectsFromString_shouldRegisterDerivedClass {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@interface MyClass : NSObject @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBClassData *class = [[store classes] anyObject];
    XCTAssertEqualObjects(class.nameOfSuperclass, @"NSObject");
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
    XCTAssertEqual([classes count], 1);
    XCTAssertEqualObjects([classes[0] nameOfClass], @"MyClass");
}

- (void)testParseObjectsFromString_shouldRegisterClassDeclarationSourceFileAndLineNumber {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@implementation MyClass @end" sourceFile:@"filename.h" toStore:store];
    // verify
    NSSet *files = [[store classesSortedByName][0] sourceInfos];
    XCTAssertEqual([files count], 1);
    XCTAssertEqualObjects([[files anyObject] filename], @"filename.h");
    XCTAssertEqual([[files anyObject] lineNumber], 1);
}

- (void)testParseObjectsFromString_shouldRegisterClassDeclarationProperSourceLineNumber {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"\n// cmt\n\n#define DEBUG\n\n/// hello\n@implementation MyClass @end" sourceFile:@"filename.h" toStore:store];
    // verify
    NSSet *files = [[store classesSortedByName][0] sourceInfos];
    XCTAssertEqual([[files anyObject] lineNumber], 7);
}

- (void)testParseObjectsFromString_shouldRegisterAllClassDeclarations {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@implementation MyClass1 @end   @implementation MyClass2 @end" sourceFile:@"filename.h" toStore:store];
    // verify
    NSArray *classes = [store classesSortedByName];
    XCTAssertEqual([classes count], 2);
    XCTAssertEqualObjects([classes[0] nameOfClass], @"MyClass1");
    XCTAssertEqualObjects([classes[1] nameOfClass], @"MyClass2");
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
    XCTAssertEqualObjects(class.comment.stringValue, @"Comment");
}

- (void)testParseObjectsFromString_shouldRegisterClassDeclarationComment {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"/** Comment */ @implementation MyClass @end" sourceFile:@"filename.m" toStore:store];
    // verify
    GBClassData *class = [[store classes] anyObject];
    XCTAssertEqualObjects(class.comment.stringValue, @"Comment");
}

- (void)testParseObjectsFromString_shouldRegisterClassDefinitionCommentSourceFileAndLineNumber {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"/// comment\n\n#define SOMETHING\n\n/** comment */ @interface MyClass @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBClassData *class = [[store classes] anyObject];
    XCTAssertEqualObjects(class.comment.sourceInfo.filename, @"filename.h");
    XCTAssertEqual(class.comment.sourceInfo.lineNumber, 5);
}

- (void)testParseObjectsFromString_shouldRegisterClassDeclarationCommentProperSourceLineNumber {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"/// comment\n\n#define SOMETHING\n\n/** comment */ @implementation MyClass @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBClassData *class = [[store classes] anyObject];
    XCTAssertEqualObjects(class.comment.sourceInfo.filename, @"filename.h");
    XCTAssertEqual(class.comment.sourceInfo.lineNumber, 5);
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
    XCTAssertEqualObjects(class.nameOfClass, @"MyClass");
    XCTAssertEqualObjects(class.nameOfSuperclass, @"SuperClass");
    XCTAssertEqualObjects(class.comment.stringValue, @"Comment");
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
    XCTAssertNil(method.comment);
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
    XCTAssertEqual([protocols count], 1);
    XCTAssertEqualObjects([protocols[0] nameOfProtocol], @"Protocol");
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
    XCTAssertEqual([protocols count], 1);
    XCTAssertEqualObjects([protocols[0] nameOfProtocol], @"Protocol");
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
    XCTAssertEqual([ivars count], 0);
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
    XCTAssertEqual([methods count], 1);
    XCTAssertEqualObjects([methods[0] methodSelector], @"method");
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
    XCTAssertEqual([methods count], 1);
    XCTAssertEqualObjects([methods[0] methodSelector], @"name");
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
    XCTAssertEqual([methods count], 1);
    XCTAssertEqualObjects([methods[0] methodSelector], @"method");
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
    XCTAssertEqual([[store classes] count], 1);
    GBClassData *class = [[store classes] anyObject];
    NSArray *methods = [class.methods methods];
    XCTAssertEqual([methods count], 2);
    XCTAssertEqualObjects([methods[0] methodSelector], @"method1");
    XCTAssertEqualObjects([methods[1] methodSelector], @"method2");
}

- (void)testParseObjectsFromString_shouldMergeClassDeclarations {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@implementation MyClass -(void)method1{} @end" sourceFile:@"filename1.m" toStore:store];
    [parser parseObjectsFromString:@"@implementation MyClass -(void)method2{} @end" sourceFile:@"filename2.m" toStore:store];
    // verify - simple testing here, details within GBModelBaseTesting!
    XCTAssertEqual([[store classes] count], 1);
    GBClassData *class = [[store classes] anyObject];
    NSArray *methods = [class.methods methods];
    XCTAssertEqual([methods count], 2);
    XCTAssertEqualObjects([methods[0] methodSelector], @"method1");
    XCTAssertEqualObjects([methods[1] methodSelector], @"method2");
}

- (void)testParseObjectsFromString_shouldMergeClassDefinitionAndDeclaration {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@interface MyClass -(void)method1; @end" sourceFile:@"filename.h" toStore:store];
    [parser parseObjectsFromString:@"@implementation MyClass -(void)method2{} @end" sourceFile:@"filename.m" toStore:store];
    // verify - simple testing here, details within GBModelBaseTesting!
    XCTAssertEqual([[store classes] count], 1);
    GBClassData *class = [[store classes] anyObject];
    NSArray *methods = [class.methods methods];
    XCTAssertEqual([methods count], 2);
    XCTAssertEqualObjects([methods[0] methodSelector], @"method1");
    XCTAssertEqualObjects([methods[1] methodSelector], @"method2");
}

#pragma mark Complex parsing testing

- (void)testParseObjectsFromString_shouldRegisterClassFromRealLifeHeaderInput {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:[GBRealLifeDataProvider headerWithClassCategoryAndProtocol] sourceFile:@"filename.h" toStore:store];
    // verify - we're not going into details here, just checking that top-level objects were properly parsed!
    XCTAssertEqual([[store classes] count], 1);
    GBClassData *class = [[store classes] anyObject];
    XCTAssertEqualObjects(class.nameOfClass, @"GBCalculator");
    XCTAssertEqualObjects(class.nameOfSuperclass, @"NSObject");
}

- (void)testParseObjectsFromString_shouldRegisterClassFromRealLifeCodeInput {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:[GBRealLifeDataProvider codeWithClassAndCategory] sourceFile:@"filename.m" toStore:store];
    // verify - we're not going into details here, just checking that top-level objects were properly parsed!
    XCTAssertEqual([[store classes] count], 1);
    GBClassData *class = [[store classes] anyObject];
    XCTAssertEqualObjects(class.nameOfClass, @"GBCalculator");
    XCTAssertEqual([class.methods.methods count], 1);
}

@end
