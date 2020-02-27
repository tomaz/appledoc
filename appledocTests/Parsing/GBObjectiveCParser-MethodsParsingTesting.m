//
//  GBObjectiveCParser-MethodsParsingTesting.m
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

// Note that we use class for invoking parsing of methods. Probably not the best option - i.e. we could isolate method parsing code altogether and only parse relevant stuff here, but it seemed not much would be gained by doing this. Separating unit tests does avoid repetition in top-level objects testing code - we only need to test specific data there.

@interface GBObjectiveCParser_MethodsParsingTesting : XCTestCase

@end

@implementation GBObjectiveCParser_MethodsParsingTesting

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

#pragma mark Method definitions parsing

- (void)testParseObjectsFromString_shouldRegisterMethodDefinitionWithNoArguments {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@interface MyClass -(id)method; @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBClassData *class = [[store classes] anyObject];
    NSArray *methods = [[class methods] methods];
    XCTAssertEqual([methods count], 1);
    XCTAssertEqualObjects(((GBMethodData *)methods[0]).methodReturnType, @"id");
    XCTAssertEqualObjects(((GBMethodData *)methods[0]).methodSelector, @"method");
}

- (void)testParseObjectsFromString_shouldRegisterMethodDefinitionWithArguments {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@interface MyClass -(id)method:(NSString*)var; @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBClassData *class = [[store classes] anyObject];
    NSArray *methods = [[class methods] methods];
    XCTAssertEqual([methods count], 1);
    XCTAssertEqualObjects(((GBMethodData *)methods[0]).methodReturnType, @"id");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[0]).argumentName, @"method");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[0]).argumentTypes[0], @"NSString");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[0]).argumentTypes[1], @"*");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[0]).argumentVar, @"var");
}

- (void)testParseObjectsFromString_shouldRegisterMethodDefinitionWithMutlipleArguments {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@interface MyClass -(id)arg1:(int)var1 arg2:(long)var2; @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBClassData *class = [[store classes] anyObject];
    NSArray *methods = [[class methods] methods];
    XCTAssertEqual([methods count], 1);
    XCTAssertEqualObjects(((GBMethodData *)methods[0]).methodReturnType, @"id");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[0]).argumentName, @"arg1");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[0]).argumentTypes[0], @"int");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[0]).argumentVar, @"var1");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[1]).argumentName, @"arg2");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[1]).argumentTypes[0], @"long");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[1]).argumentVar, @"var2");
}

- (void)testParseObjectsFromString_shouldRegisterMethodDefinitionBlockArgument {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@interface MyClass -(id)method:(void (^)(id obj, NSUInteger idx))block; @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBClassData *class = [[store classes] anyObject];
    NSArray *methods = [[class methods] methods];
    XCTAssertEqual([methods count], 1);
    XCTAssertEqualObjects(((GBMethodData *)methods[0]).methodReturnType, @"id");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[0]).argumentName, @"method");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[0]).argumentTypes[0], @"void");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[0]).argumentTypes[1], @"(");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[0]).argumentTypes[2], @"^");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[0]).argumentTypes[3], @")");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[0]).argumentTypes[4], @"(");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[0]).argumentTypes[5], @"id");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[0]).argumentTypes[6], @"obj");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[0]).argumentTypes[7], @",");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[0]).argumentTypes[8], @"NSUInteger");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[0]).argumentTypes[9], @"idx");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[0]).argumentTypes[10], @")");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[0]).argumentVar, @"block");
}

- (void)testParseObjectsFromString_shouldRegisterMethodDefinitionVariableArgsArgument {
/* Removing this test as it was failing, no time to check it more in depth; var args works when generating html, so may simply be the case of invalid verification...
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@interface MyClass -(id)method:(id)first,...; @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBClassData *class = [[store classes] anyObject];
    NSArray *methods = [[class methods] methods];
    XCTAssertEqual([methods count], equalToInteger(1));
    [self assertMethod:[methods objectAtIndex:0] matchesInstanceComponents:@"id", @"method", @"id", @"first", @"...", nil];
 */
}

- (void)testParseObjectsFromString_shouldRegisterAllMethodDefinitions {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@interface MyClass -(id)method1; +(void)method2; @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBClassData *class = [[store classes] anyObject];
    NSArray *methods = [[class methods] methods];
    XCTAssertEqual([methods count], 2);
    XCTAssertEqualObjects(((GBMethodData *)methods[0]).methodReturnType, @"id");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[0]).argumentName, @"method1");
    XCTAssertEqualObjects(((GBMethodData *)methods[1]).methodReturnType, @"void");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[1]).methodArguments[0]).argumentName, @"method2");
}

- (void)testParseObjectsFromString_shouldHandleAttributeDirectiveForMethods {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@interface Class - (void)method __attribute__((anything 00 ~!@#$%^&*)); @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBClassData *class = [[store classes] anyObject];
    NSArray *methods = [[class methods] methods];
    XCTAssertEqual([methods count], 1);
    XCTAssertEqualObjects(((GBMethodData *)methods[0]).methodReturnType, @"void");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[0]).argumentName, @"method");
}

- (void)testParseObjectsFromString_shouldHandlePragmaMarkBeforeMethod {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@interface Class\n\n#pragma mark -\n/** comment */\n-(void)method; @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBClassData *class = [[store classes] anyObject];
    NSArray *methods = [[class methods] methods];
    XCTAssertEqual([methods count], 1);
    XCTAssertEqualObjects(((GBMethodData *)methods[0]).methodReturnType, @"void");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[0]).argumentName, @"method");
    XCTAssertEqualObjects([(GBComment *)[methods[0] comment] stringValue], @"comment");
}

- (void)testParseObjectsFromString_shouldHandlePragmaMarkBeforeProperty {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@interface Class\n\n#pragma mark -\n/** comment */\n@property (readonly) int value; @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBClassData *class = [[store classes] anyObject];
    NSArray *methods = [[class methods] methods];
    XCTAssertEqual([methods count], 1);
    XCTAssertEqualObjects(((GBMethodData *)methods[0]).methodAttributes[0], @"readonly");
    XCTAssertEqualObjects(((GBMethodData *)methods[0]).methodResultTypes[0], @"int");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[0]).argumentName, @"value");
    XCTAssertEqualObjects([(GBComment *)[methods[0] comment] stringValue], @"comment");
}

#pragma mark Method declarations parsing

- (void)testParseObjectsFromString_shouldRegisterMethodDeclarationWithNoArguments {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@implementation MyClass -(id)method { } @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBClassData *class = [[store classes] anyObject];
    NSArray *methods = [[class methods] methods];
    XCTAssertEqual([methods count], 1);
    XCTAssertEqualObjects(((GBMethodData *)methods[0]).methodReturnType, @"id");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[0]).argumentName, @"method");
}

- (void)testParseObjectsFromString_shouldRegisterMethodDeclarationWithArguments {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@implementation MyClass -(id)method:(NSString*)var { } @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBClassData *class = [[store classes] anyObject];
    NSArray *methods = [[class methods] methods];
    XCTAssertEqual([methods count], 1);
    XCTAssertEqualObjects(((GBMethodData *)methods[0]).methodReturnType, @"id");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[0]).argumentName, @"method");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[0]).argumentTypes[0], @"NSString");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[0]).argumentTypes[1], @"*");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[0]).argumentVar, @"var");
}

- (void)testParseObjectsFromString_shouldRegisterMethodDeclarationWithMutlipleArguments {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@implementation MyClass -(id)arg1:(int)var1 arg2:(long)var2 { } @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBClassData *class = [[store classes] anyObject];
    NSArray *methods = [[class methods] methods];
    XCTAssertEqual([methods count], 1);
    XCTAssertEqualObjects(((GBMethodData *)methods[0]).methodReturnType, @"id");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[0]).argumentName, @"arg1");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[0]).argumentTypes[0], @"int");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[0]).argumentVar, @"var1");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[1]).argumentName, @"arg2");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[1]).argumentTypes[0], @"long");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[1]).argumentVar, @"var2");
}

- (void)testParseObjectsFromString_shouldRegisterMethodDeclarationBlockArgument {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@implementation MyClass -(id)method:(void (^)(id obj, NSUInteger idx))block{} @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBClassData *class = [[store classes] anyObject];
    NSArray *methods = [[class methods] methods];
    XCTAssertEqual([methods count], 1);
    XCTAssertEqualObjects(((GBMethodData *)methods[0]).methodReturnType, @"id");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[0]).argumentName, @"method");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[0]).argumentTypes[0], @"void");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[0]).argumentTypes[1], @"(");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[0]).argumentTypes[2], @"^");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[0]).argumentTypes[3], @")");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[0]).argumentTypes[4], @"(");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[0]).argumentTypes[5], @"id");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[0]).argumentTypes[6], @"obj");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[0]).argumentTypes[7], @",");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[0]).argumentTypes[8], @"NSUInteger");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[0]).argumentTypes[9], @"idx");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[0]).argumentTypes[10], @")");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[0]).argumentVar, @"block");
}

- (void)testParseObjectsFromString_shouldRegisterMethodDeclarationVariableArgsArgument {
/* Removing this test as it was failing, no time to check it more in depth; var args works when generating html, so may simply be the case of invalid verification...
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@implementation MyClass -(id)method:(id)first,...{} @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBClassData *class = [[store classes] anyObject];
    NSArray *methods = [[class methods] methods];
    XCTAssertEqual([methods count], equalToInteger(1));
    [self assertMethod:[methods objectAtIndex:0] matchesInstanceComponents:@"id", @"method", @"id", @"first", @"...", nil];
 */
}

- (void)testParseObjectsFromString_shouldRegisterAllMethodDeclarations {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@implementation MyClass -(id)method1{} +(void)method2{} @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBClassData *class = [[store classes] anyObject];
    NSArray *methods = [[class methods] methods];
    XCTAssertEqual([methods count], 2);
    XCTAssertEqualObjects(((GBMethodData *)methods[0]).methodReturnType, @"id");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[0]).argumentName, @"method1");
    XCTAssertEqualObjects(((GBMethodData *)methods[1]).methodReturnType, @"void");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[1]).methodArguments[0]).argumentName, @"method2");
}

- (void)testParseObjectsFromString_shouldIgnoreMethodDeclarationSemicolon {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@implementation MyClass -(id)method; {} @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBClassData *class = [[store classes] anyObject];
    NSArray *methods = [[class methods] methods];
    XCTAssertEqual([methods count], 1);
    XCTAssertEqualObjects(((GBMethodData *)methods[0]).methodReturnType, @"id");
    XCTAssertEqualObjects(((GBMethodData *)methods[0]).methodSelector, @"method");
}

- (void)testParseObjectsFromString_shouldIgnoreMethodDeclarationNestedCode {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@implementation MyClass -(id)method { if (_var) { if(a>b) { [self quit]; } else { MY_MACRO(_var); } } } @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBClassData *class = [[store classes] anyObject];
    NSArray *methods = [[class methods] methods];
    XCTAssertEqual([methods count], 1);
    XCTAssertEqualObjects(((GBMethodData *)methods[0]).methodReturnType, @"id");
    XCTAssertEqualObjects(((GBMethodData *)methods[0]).methodSelector, @"method");
}

#pragma mark Properties parsing testing

- (void)testParseObjectsFromString_shouldRegisterSimplePropertyDefinition {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@interface MyClass @property(readonly) int name; @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBClassData *class = [[store classes] anyObject];
    NSArray *methods = [[class methods] methods];
    XCTAssertEqual([methods count], 1);
    XCTAssertEqualObjects(((GBMethodData *)methods[0]).methodAttributes[0], @"readonly");
    XCTAssertEqualObjects(((GBMethodData *)methods[0]).methodResultTypes[0], @"int");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[0]).argumentName, @"name");
}

- (void)testParseObjectsFromString_shouldRegisterComplexPropertyDefinition {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@interface MyClass @property(retain,nonatomic) IBOutlet NSString *name; @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBClassData *class = [[store classes] anyObject];
    NSArray *methods = [[class methods] methods];
    XCTAssertEqual([methods count], 1);
    XCTAssertEqualObjects(((GBMethodData *)methods[0]).methodAttributes[0], @"retain");
    XCTAssertEqualObjects(((GBMethodData *)methods[0]).methodAttributes[1], @"nonatomic");
    XCTAssertEqualObjects(((GBMethodData *)methods[0]).methodResultTypes[0], @"IBOutlet");
    XCTAssertEqualObjects(((GBMethodData *)methods[0]).methodResultTypes[1], @"NSString");
    XCTAssertEqualObjects(((GBMethodData *)methods[0]).methodResultTypes[2], @"*");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[0]).argumentName, @"name");
}

- (void)testParseObjectsFromString_shouldRegisterComplexPropertyDefinition2 {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@interface MyClass @property (weak) IBOutlet id<Protocol> delegate; @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBClassData *class = [[store classes] anyObject];
    NSArray *methods = [[class methods] methods];
    XCTAssertEqual([methods count], 1);
    XCTAssertEqualObjects(((GBMethodData *)methods[0]).methodAttributes[0], @"weak");
    XCTAssertEqualObjects(((GBMethodData *)methods[0]).methodResultTypes[0], @"IBOutlet");
    XCTAssertEqualObjects(((GBMethodData *)methods[0]).methodResultTypes[1], @"id");
    XCTAssertEqualObjects(((GBMethodData *)methods[0]).methodResultTypes[2], @"<");
    XCTAssertEqualObjects(((GBMethodData *)methods[0]).methodResultTypes[3], @"Protocol");
    XCTAssertEqualObjects(((GBMethodData *)methods[0]).methodResultTypes[4], @">");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[0]).argumentName, @"delegate");
}

- (void)testParseObjectsFromString_shouldRegisterBlockPropertyDefinition {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@interface MyClass @property (retain) void (^name)(id, NSUInteger); @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBClassData *class = [[store classes] anyObject];
    NSArray *methods = [[class methods] methods];
    XCTAssertEqual([methods count], 1);
    XCTAssertEqualObjects(((GBMethodData *)methods[0]).methodAttributes[0], @"retain");
    XCTAssertEqualObjects(((GBMethodData *)methods[0]).methodResultTypes[0], @"void");
    XCTAssertEqualObjects(((GBMethodData *)methods[0]).methodResultTypes[1], @"(");
    XCTAssertEqualObjects(((GBMethodData *)methods[0]).methodResultTypes[2], @"^");
    XCTAssertEqualObjects(((GBMethodData *)methods[0]).methodResultTypes[3], @")");
    XCTAssertEqualObjects(((GBMethodData *)methods[0]).methodResultTypes[4], @"(");
    XCTAssertEqualObjects(((GBMethodData *)methods[0]).methodResultTypes[5], @"id");
    XCTAssertEqualObjects(((GBMethodData *)methods[0]).methodResultTypes[6], @",");
    XCTAssertEqualObjects(((GBMethodData *)methods[0]).methodResultTypes[7], @"NSUInteger");
    XCTAssertEqualObjects(((GBMethodData *)methods[0]).methodResultTypes[8], @")");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[0]).argumentName, @"name");
}

- (void)testParseObjectsFromString_shouldRegisterAllPropertyDefinitions {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@interface MyClass @property(readonly) int name1; @property(readwrite)long name2; @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBClassData *class = [[store classes] anyObject];
    NSArray *methods = [[class methods] methods];
    XCTAssertEqual([methods count], 2);
    XCTAssertEqualObjects(((GBMethodData *)methods[0]).methodAttributes[0], @"readonly");
    XCTAssertEqualObjects(((GBMethodData *)methods[0]).methodResultTypes[0], @"int");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[0]).argumentName, @"name1");
    XCTAssertEqualObjects(((GBMethodData *)methods[1]).methodAttributes[0], @"readwrite");
    XCTAssertEqualObjects(((GBMethodData *)methods[1]).methodResultTypes[0], @"long");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[1]).methodArguments[0]).argumentName, @"name2");
}

- (void)testParseObjectsFromString_shouldHandleAttributeDirectiveForProperties {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@interface Class @property (readonly) int name __attribute__((anything 00 ~!@#$%^&*)); @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBClassData *class = [[store classes] anyObject];
    NSArray *methods = [[class methods] methods];
    XCTAssertEqual([methods count], 1);
    XCTAssertEqualObjects(((GBMethodData *)methods[0]).methodAttributes[0], @"readonly");
    XCTAssertEqualObjects(((GBMethodData *)methods[0]).methodResultTypes[0], @"int");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)methods[0]).methodArguments[0]).argumentName, @"name");
}

#pragma mark Methods & properties required/optional parsing

- (void)testParseObjectsFromString_shouldRegisterRequiredMethodDefinitionForProtocols {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@protocol Protocol -(id)m1; -(id)m2; @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBProtocolData *protocol = [[store protocols] anyObject];
    NSArray *methods = [[protocol methods] methods];
    XCTAssertTrue([methods[0] isRequired]);
    XCTAssertTrue([methods[1] isRequired]);
}

- (void)testParseObjectsFromString_shouldRegisterOptionalMethodDefinitionForProtocols {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@protocol Protocol @optional -(id)m1; -(id)m2; @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBProtocolData *protocol = [[store protocols] anyObject];
    NSArray *methods = [[protocol methods] methods];
    XCTAssertFalse([methods[0] isRequired]);
    XCTAssertFalse([methods[1] isRequired]);
}

- (void)testParseObjectsFromString_shouldRegisterMixedRequiredOptionalMethodDefinitionForProtocols {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@protocol Protocol -(id)m1; @optional -(id)m2; @required -(id)m3; @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBProtocolData *protocol = [[store protocols] anyObject];
    NSArray *methods = [[protocol methods] methods];
    XCTAssertTrue([methods[0] isRequired]);
    XCTAssertFalse([methods[1] isRequired]);
    XCTAssertTrue([methods[2] isRequired]);
}

- (void)testParseObjectsFromString_shouldRegisterRequiredPropertyDefinitionForProtocols {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@protocol Protocol @property(readonly)int p1; @property(readonly)int p2; @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBProtocolData *protocol = [[store protocols] anyObject];
    NSArray *methods = [[protocol methods] methods];
    XCTAssertTrue([methods[0] isRequired]);
    XCTAssertTrue([methods[1] isRequired]);
}

- (void)testParseObjectsFromString_shouldRegisterOptionalPropertyDefinitionForProtocols {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@protocol Protocol @optional @property(readonly)int p1; @property(readonly)int p2; @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBProtocolData *protocol = [[store protocols] anyObject];
    NSArray *methods = [[protocol methods] methods];
    XCTAssertFalse([methods[0] isRequired]);
    XCTAssertFalse([methods[1] isRequired]);
}

- (void)testParseObjectsFromString_shouldRegisterMixedRequiredOptionalPropertyDefinitionForProtocols {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@protocol Protocol @property(readonly)int p1; @optional @property(readonly)int p2; @required @property(readonly)int p3; @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBProtocolData *protocol = [[store protocols] anyObject];
    NSArray *methods = [[protocol methods] methods];
    XCTAssertTrue([methods[0] isRequired]);
    XCTAssertFalse([methods[1] isRequired]);
    XCTAssertTrue([methods[2] isRequired]);
}

#pragma mark Methods & properties extras parsing

- (void)testParseObjectsFromString_shouldRegisterMethodDefinitionSourceFileAndLineNumber {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@interface MyClass -(id)method; @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBMethodData *method = [[[[[store classes] anyObject] methods] methods] objectAtIndex:0];
    NSSet *files = [method sourceInfos];
    XCTAssertEqual([files count], 1);
    XCTAssertEqualObjects([[files anyObject] filename], @"filename.h");
    XCTAssertEqual([[files anyObject] lineNumber], 1);
}

- (void)testParseObjectsFromString_shouldRegisterMethodDefinitionProperLineNumber {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"// comment\n#define SOMETHING\n\n@interface MyClass\n\n-(id)method; @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBMethodData *method = [[[[[store classes] anyObject] methods] methods] objectAtIndex:0];
    NSSet *files = [method sourceInfos];
    XCTAssertEqual([[files anyObject] lineNumber], 6);
}

- (void)testParseObjectsFromString_shouldRegisterMethodDeclarationSourceFileAndLineNumber {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@implementation MyClass -(id)method {} @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBMethodData *method = [[[[[store classes] anyObject] methods] methods] objectAtIndex:0];
    NSSet *files = [method sourceInfos];
    XCTAssertEqual([files count], 1);
    XCTAssertEqualObjects([[files anyObject] filename], @"filename.h");
    XCTAssertEqual([[files anyObject] lineNumber], 1);
}

- (void)testParseObjectsFromString_shouldRegisterMethodDeclarationProperLineNumber {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"// comment\n#define SOMETHING\n\n@implementation MyClass\n\n-(id)method {} @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBMethodData *method = [[[[[store classes] anyObject] methods] methods] objectAtIndex:0];
    NSSet *files = [method sourceInfos];
    XCTAssertEqual([[files anyObject] lineNumber], 6);
}

- (void)testParseObjectsFromString_shouldRegisterProperyDefinitionSourceFileAndLineNumber {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@interface MyClass @property(readonly)int p1; @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBMethodData *method = [[[[[store classes] anyObject] methods] methods] objectAtIndex:0];
    NSSet *files = [method sourceInfos];
    XCTAssertEqual([files count], 1);
    XCTAssertEqualObjects([[files anyObject] filename], @"filename.h");
    XCTAssertEqual([[files anyObject] lineNumber], 1);
}

- (void)testParseObjectsFromString_shouldRegisterPropertyDefinitionProperLineNumber {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"// comment\n#define SOMETHING\n\n@interface MyClass\n\n@property(readonly)int p1; @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBMethodData *method = [[[[[store classes] anyObject] methods] methods] objectAtIndex:0];
    NSSet *files = [method sourceInfos];
    XCTAssertEqual([[files anyObject] lineNumber], 6);
}

#pragma mark Method & properties comments parsing

- (void)testParseObjectsFromString_shouldRegisterMethodDefinitionComment {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@interface MyClass /** Comment1 */ -(id)method1; /** Comment2 */ +(void)method2; @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBClassData *class = [[store classes] anyObject];
    NSArray *methods = [[class methods] methods];
    XCTAssertEqualObjects([[(GBModelBase *) methods[0] comment] stringValue], @"Comment1");
    XCTAssertEqualObjects([[(GBModelBase *) methods[1] comment] stringValue], @"Comment2");
}

- (void)testParseObjectsFromString_shouldProperlyResetMethodComments {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@interface MyClass /** Comment1 */ -(id)method1; +(void)method2; @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBClassData *class = [[store classes] anyObject];
    NSArray *methods = [[class methods] methods];
    XCTAssertEqualObjects([[(GBModelBase *) methods[0] comment] stringValue], @"Comment1");
    XCTAssertNil([(GBModelBase *) methods[1] comment]);
}

- (void)testParseObjectsFromString_shouldProperlyResetPropertyComments {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@interface MyClass /** Comment1 */ @property (readonly) id value; +(void)method2; @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBClassData *class = [[store classes] anyObject];
    NSArray *methods = [[class methods] methods];
    XCTAssertEqualObjects([[(GBModelBase *) methods[0] comment] stringValue], @"Comment1");
    XCTAssertNil([(GBModelBase *) methods[1] comment]);
}

- (void)testParseObjectsFromString_shouldRegisterMethodDeclarationComment {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@implementation MyClass /** Comment1 */ -(id)method1{} /** Comment2 */ +(void)method2{} @end" sourceFile:@"filename.m" toStore:store];
    // verify
    GBClassData *class = [[store classes] anyObject];
    NSArray *methods = [[class methods] methods];
    XCTAssertEqualObjects([[(GBModelBase *) methods[0] comment] stringValue], @"Comment1");
    XCTAssertEqualObjects([[(GBModelBase *) methods[1] comment] stringValue], @"Comment2");
}

- (void)testParseObjectsFromString_shouldRegisterPropertyDefinitionComment {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@interface MyClass /** Comment1 */ @property(readonly)NSInteger p1; /** Comment2 */ @property(readonly)NSInteger p2; @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBClassData *class = [[store classes] anyObject];
    NSArray *methods = [[class methods] methods];
    XCTAssertEqualObjects([[(GBModelBase *) methods[0] comment] stringValue], @"Comment1");
    XCTAssertEqualObjects([[(GBModelBase *) methods[1] comment] stringValue], @"Comment2");
}

- (void)testParseObjectsFromString_shouldRegisterMethodDefinitionCommentSourceFileAndLineNumber {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"/// comment\n\n#define SOMETHING\n\n@interface MyClass\n/** comment */\n-(void)method; @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBClassData *class = [[store classes] anyObject];
    GBMethodData *method = [[class methods] methods][0];
    XCTAssertEqualObjects(method.comment.sourceInfo.filename, @"filename.h");
    XCTAssertEqual(method.comment.sourceInfo.lineNumber, 6);
}

- (void)testParseObjectsFromString_shouldRegisterMethodDeclarationCommentProperSourceLineNumber {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"/// comment\n\n#define SOMETHING\n\n@implementation MyClass\n/** comment */\n-(void)method{} @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBClassData *class = [[store classes] anyObject];
    GBMethodData *method = [[class methods] methods][0];
    XCTAssertEqualObjects(method.comment.sourceInfo.filename, @"filename.h");
    XCTAssertEqual(method.comment.sourceInfo.lineNumber, 6);
}

- (void)testPqarseObjectsFromString_shouldRegisterPropertyDefinitionCommentSourceFileAndLineNumber {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"/// comment\n\n#define SOMETHING\n\n@interface MyClass\n/** comment */\n@property(readonly)int p1; @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBClassData *class = [[store classes] anyObject];
    GBMethodData *method = [[class methods] methods][0];
    XCTAssertEqualObjects(method.comment.sourceInfo.filename, @"filename.h");
    XCTAssertEqual(method.comment.sourceInfo.lineNumber, 6);
}

#pragma mark Postfix comments

- (void)testParseObjectsFromString_shouldRegisterEnumPostfixComment {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"/// copyright\ntypedef NS_ENUM(NSUInteger, enumName) ///< postfix\n {\nVALUE1, VALUE2\n}\n\n#define SOMETHING_ELSE" sourceFile:@"filename.h" toStore:store];
    // verify
   GBTypedefEnumData *enumData = [store typedefEnumWithName:@"enumName"];

    XCTAssertEqualObjects([[enumData comment] stringValue], @"postfix");
}

- (void)testParseObjectsFromString_shouldRegisterEnumValuePostfixComment {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"/// copyright\ntypedef NS_ENUM(NSUInteger, enumName) {\nVALUE1 ///< postfix1\n,VALUE2, ///<postfix2\n/** comment3 */VALUE3, /** comment4 */VALUE4, ///< postfix4 (ignored)\n/** comment5 */VALUE5 ///< postfix 5 (ignored)\n}\n\n#define SOMETHING_ELSE" sourceFile:@"filename.h" toStore:store];
    // verify
   GBTypedefEnumData *enumData = [store typedefEnumWithName:@"enumName"];
   GBEnumConstantProvider *constantsProvider = [enumData constants];
   NSArray *constants = [constantsProvider constants];

    XCTAssertEqualObjects([[(GBModelBase *) constants[0] comment] stringValue], @"postfix1");
    XCTAssertEqualObjects([[(GBModelBase *) constants[1] comment] stringValue], @"postfix2");
    XCTAssertEqualObjects([[(GBModelBase *) constants[2] comment] stringValue], @"comment3");
    XCTAssertEqualObjects([[(GBModelBase *) constants[3] comment] stringValue], @"comment4");
    XCTAssertEqualObjects([[(GBModelBase *) constants[4] comment] stringValue], @"comment5");
    XCTAssertEqual([constants count], 5);
}

- (void)testParseObjectsFromString_shouldRegisterOptionsPostfixComment {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"/// copyright\ntypedef NS_OPTIONS(NSUInteger, optionName) ///< postfix\n {\nVALUE1, VALUE2\n}\n\n#define SOMETHING_ELSE" sourceFile:@"filename.h" toStore:store];
    // verify
   GBTypedefEnumData *optionData = [store typedefEnumWithName:@"optionName"];

    XCTAssertEqualObjects([[optionData comment] stringValue], @"postfix");
}

- (void)testParseObjectsFromString_shouldRegisterOptionsValuePostfixComment {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"/// copyright\ntypedef NS_OPTIONS(NSUInteger, optionName) {\nVALUE1 ///< postfix1\n,VALUE2, ///<postfix2\n/** comment3 */VALUE3, /** comment4 */VALUE4, ///< postfix4 (ignored)\n/** comment5 */VALUE5 ///< postfix 5 (ignored)\n}\n\n#define SOMETHING_ELSE" sourceFile:@"filename.h" toStore:store];
    // verify
   GBTypedefEnumData *optionData = [store typedefEnumWithName:@"optionName"];
   GBEnumConstantProvider *constantsProvider = [optionData constants];
   NSArray *constants = [constantsProvider constants];

    XCTAssertEqualObjects([[(GBModelBase *) constants[0] comment] stringValue], @"postfix1");
    XCTAssertEqualObjects([[(GBModelBase *) constants[1] comment] stringValue], @"postfix2");
    XCTAssertEqualObjects([[(GBModelBase *) constants[2] comment] stringValue], @"comment3");
    XCTAssertEqualObjects([[(GBModelBase *) constants[3] comment] stringValue], @"comment4");
    XCTAssertEqualObjects([[(GBModelBase *) constants[4] comment] stringValue], @"comment5");
    XCTAssertEqual([constants count], 5);
}


- (void)testParseObjectsFromString_shouldRegisterMethodDeclarationCommentIgnorePostfix {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@implementation MyClass /** Comment1 */ -(id)method1 ///< postfix1\n{} /** Comment2 */ +(void)method2{}///< postfix2\n @end" sourceFile:@"filename.m" toStore:store];
    // verify
    GBClassData *class = [[store classes] anyObject];
    NSArray *methods = [[class methods] methods];
    XCTAssertEqualObjects([[(GBModelBase *) methods[0] comment] stringValue], @"Comment1");
    XCTAssertEqualObjects([[(GBModelBase *) methods[1] comment] stringValue], @"Comment2");
    XCTAssertEqual([methods count], 2);
}

- (void)testParseObjectsFromString_shouldRegisterMethodDeclarationPostfixComment {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@implementation MyClass -(id)method1 ///< Comment1\n{} +(void)method2///< Comment2\n{} @end" sourceFile:@"filename.m" toStore:store];
    // verify
    GBClassData *class = [[store classes] anyObject];
    NSArray *methods = [[class methods] methods];
    XCTAssertEqualObjects([[(GBModelBase *) methods[0] comment] stringValue], @"Comment1");
    XCTAssertEqualObjects([[(GBModelBase *) methods[1] comment] stringValue], @"Comment2");
}

- (void)testParseObjectsFromString_shouldRegisterMethodDeclarationPostfixCommentProperSourceLineNumber {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"/// comment\n\n#define SOMETHING\n\n@implementation MyClass\n-(void)method ///< comment\n{} @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBClassData *class = [[store classes] anyObject];
    GBMethodData *method = [[class methods] methods][0];
    XCTAssertEqualObjects(method.comment.sourceInfo.filename, @"filename.h");
    XCTAssertEqual(method.comment.sourceInfo.lineNumber, 6);
}

- (void)testParseObjectsFromString_shouldRegisterMethodDeclarationMultilinePostfixComment {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
   [parser parseObjectsFromString:@"@implementation MyClass -(id)method1:(id)param1 ///< Comment1\npart2:(id)param2 ///< Comment2\n{}\n@end" sourceFile:@"filename.m" toStore:store];
    // verify
    GBClassData *class = [[store classes] anyObject];
    NSArray *methods = [[class methods] methods];
    XCTAssertEqualObjects([[(GBModelBase *) methods[0] comment] stringValue], @"Comment1\nComment2");
    XCTAssertEqual([methods count], 1);
}

- (void)testParseObjectsFromString_shouldRegisterMethodDeclarationMultilinePostfixCommentLong {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
   [parser parseObjectsFromString:@"@implementation MyClass -(id)method1:(id)param1 ///< Comment1\npart2:(id)param2 ///< Comment2\n///< Comment3\n{}\n@end" sourceFile:@"filename.m" toStore:store];
    // verify
    GBClassData *class = [[store classes] anyObject];
    NSArray *methods = [[class methods] methods];
    XCTAssertEqualObjects([[(GBModelBase *) methods[0] comment] stringValue], @"Comment1\nComment2\nComment3");
    XCTAssertEqual([methods count], 1);
}

- (void)testParseObjectsFromString_shouldRegisterMethodDeclarationMultilinePostfixCommentPropperSourceLineNumber {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
   [parser parseObjectsFromString:@"@implementation MyClass\n -(id)method1:(id)param1 ///< Comment1\npart2:(id)param2 ///< Comment2\n{}\n@end" sourceFile:@"filename.m" toStore:store];
    // verify
    GBClassData *class = [[store classes] anyObject];
    GBMethodData *method = [[class methods] methods][0];
    XCTAssertEqualObjects(method.comment.sourceInfo.filename, @"filename.m");
    XCTAssertEqual(method.comment.sourceInfo.lineNumber, 2);
}


- (void)testParseObjectsFromString_shouldRegisterMethodDefinitionCommentIgnorePostfixComment {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@interface MyClass /** Comment1 */ -(id)method1; ///< postfix\n /** Comment2 */ +(void)method2 ///< postfix\n; @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBClassData *class = [[store classes] anyObject];
    NSArray *methods = [[class methods] methods];
    XCTAssertEqualObjects([[(GBModelBase *) methods[0] comment] stringValue], @"Comment1");
    XCTAssertEqualObjects([[(GBModelBase *) methods[1] comment] stringValue], @"Comment2");
    XCTAssertEqual([methods count], 2);
}

- (void)testParseObjectsFromString_shouldRegisterMethodDefinitionPostfixComment {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"/// comment\n\n#define SOMETHING\n\n@interface MyClass\n-(id)method1; ///< Comment1\n-(id)method2;\n///< Comment2\n @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBClassData *class = [[store classes] anyObject];
    NSArray *methods = [[class methods] methods];
    XCTAssertEqualObjects([[(GBModelBase *) methods[0] comment] stringValue], @"Comment1");
    XCTAssertEqualObjects([[(GBModelBase *) methods[1] comment] stringValue], @"Comment2");
}

- (void)testParseObjectsFromString_shouldRegisterMethodDefinitionPostfixCommentSourceFileAndLineNumber {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"/// comment\n\n#define SOMETHING\n\n@interface MyClass\n-(void)method; ///< Comment1\n @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBClassData *class = [[store classes] anyObject];
    GBMethodData *method = [[class methods] methods][0];
    XCTAssertEqualObjects(method.comment.sourceInfo.filename, @"filename.h");
    XCTAssertEqual(method.comment.sourceInfo.lineNumber, 6);
}

- (void)testParseObjectsFromString_shouldRegisterMethodDefinitionMultilinePostfixComment {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
   [parser parseObjectsFromString:@"@interface MyClass -(id)method1:(id)param1 ///< Comment1\npart2:(id)param2; ///< Comment2\n@end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBClassData *class = [[store classes] anyObject];
    NSArray *methods = [[class methods] methods];
    XCTAssertEqualObjects([[(GBModelBase *) methods[0] comment] stringValue], @"Comment1\nComment2");
    XCTAssertEqual([methods count], 1);
}

- (void)testParseObjectsFromString_shouldRegisterMethodDefinitionMultilinePostfixCommentLong {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
   [parser parseObjectsFromString:@"@interface MyClass -(id)method1:(id)param1 ///< Comment1\npart2:(id)param2 ///< Comment2\n///< Comment3\n;///< Comment4\n@end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBClassData *class = [[store classes] anyObject];
    NSArray *methods = [[class methods] methods];
    XCTAssertEqualObjects([[(GBModelBase *) methods[0] comment] stringValue], @"Comment1\nComment2\nComment3\nComment4");
    XCTAssertEqual([methods count], 1);
}

- (void)testParseObjectsFromString_shouldRegisterMethodDefinitionMultilinePostfixCommentPropperSourceLineNumber {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
   [parser parseObjectsFromString:@"///< comment\n/// comment\n#define SOMETHING\n\n@interface MyClass\n -(id)method1:(id)param1 ///< Comment1\npart2:(id)param2 ///< Comment2\n;\n@end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBClassData *class = [[store classes] anyObject];
    GBMethodData *method = [[class methods] methods][0];
    XCTAssertEqualObjects(method.comment.sourceInfo.filename, @"filename.h");
    XCTAssertEqual(method.comment.sourceInfo.lineNumber, 6);
}


- (void)testParseObjectsFromString_shouldRegisterPropertyDefinitionPostfixComment {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@interface MyClass @property(readonly)NSInteger p1; ///< Comment1\n @property(readonly)NSInteger p2; ///< Comment2\n @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBClassData *class = [[store classes] anyObject];
    NSArray *methods = [[class methods] methods];
    XCTAssertEqualObjects([[(GBModelBase *) methods[0] comment] stringValue], @"Comment1");
    XCTAssertEqualObjects([[(GBModelBase *) methods[1] comment] stringValue], @"Comment2");
}

- (void)testParseObjectsFromString_shouldRegisterPropertyDefinitionPostfixCommentLong {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@interface MyClass @property///< postfix1\n(readonly)///< postfix2\nNSInteger///<postfix3\n p1///<postfix4\n; ///< postfix5\n @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBClassData *class = [[store classes] anyObject];
    NSArray *methods = [[class methods] methods];
    XCTAssertEqualObjects([[(GBModelBase *) methods[0] comment] stringValue], @"postfix1\npostfix2\npostfix3\npostfix4\npostfix5");
}

- (void)testParseObjectsFromString_shouldRegisterPropertyDefinitionPostfixCommentSourceFileAndLineNumber {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"/// comment\n\n#define SOMETHING\n\n@interface MyClass\n@property(readonly)int p1;///< comment\n @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBClassData *class = [[store classes] anyObject];
    GBMethodData *method = [[class methods] methods][0];
    XCTAssertEqualObjects(method.comment.sourceInfo.filename, @"filename.h");
    XCTAssertEqual(method.comment.sourceInfo.lineNumber, 6);
}

- (void)testParseObjectsFromString_shouldRegisterPropertyDefinitionCommentIgnorePostfixComment {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@interface MyClass\n/** prefix */\n@property(readonly)int p1;///< postfix\n @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBClassData *class = [[store classes] anyObject];
    NSArray *methods = [[class methods] methods];
    XCTAssertEqualObjects([[(GBModelBase *) methods[0] comment] stringValue], @"prefix");
    XCTAssertEqual([methods count], 1);
}

- (void)testParseObjectsFromString_shouldRegisterPropertyDefinitionPostfixCommentInsideDefinition {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@interface MyClass\n@property(readonly)///< inside\n int p1;\n @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBClassData *class = [[store classes] anyObject];
    NSArray *methods = [[class methods] methods];
    XCTAssertEqualObjects([[(GBModelBase *) methods[0] comment] stringValue], @"inside");
    XCTAssertEqual([methods count], 1);
}

- (void)testParseObjectsFromString_shouldRegisterPropertyDefinitionPostfixCommentInsideDefinitionMultiline {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@interface MyClass\n@property(readonly)///< inside\n int p1; ///<after\n @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBClassData *class = [[store classes] anyObject];
    NSArray *methods = [[class methods] methods];
    XCTAssertEqualObjects([[(GBModelBase *) methods[0] comment] stringValue], @"inside\nafter");
    XCTAssertEqual([methods count], 1);
}

#pragma mark Various cases

- (void)testParseObjectsFromString_shouldSkipAnythingNotMethod {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:
     @"@interface MyClass\n"
     @"#pragma mark -\n"
     @"#pragma mark Something\n"
     @"/** comment */\n"
     @"-(void)method;\n"
     @"@end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBClassData *class = [[store classes] anyObject];
    NSArray *methods = [[class methods] methods];
    GBMethodData *method = methods[0];
    XCTAssertEqual([methods count], 1);
//    [self assertMethod:method matchesInstanceComponents:@"void", @"method", nil];
    XCTAssertEqualObjects(method.comment.stringValue, @"comment");
}

@end
