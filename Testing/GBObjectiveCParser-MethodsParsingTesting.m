//
//  GBObjectiveCParser-MethodsParsingTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 25.7.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBStore.h"
#import "GBObjectiveCParser.h"

// Note that we use class for invoking parsing of methods. Probably not the best option - i.e. we could isolate method
// parsing code altogether and only parse relevant stuff here, but it seemed not much would be gained by doing this.
// Separating unit tests does avoid repetition in top-level objects testing code - we only need to test specific data
// there.

@interface GBObjectiveCParserMethodsParsingTesting : GBObjectsAssertor
@end

@implementation GBObjectiveCParserMethodsParsingTesting

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
	assertThatInteger([methods count], equalToInteger(1));
	[self assertMethod:[methods objectAtIndex:0] matchesInstanceComponents:@"id", @"method", nil];
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
	assertThatInteger([methods count], equalToInteger(1));
	[self assertMethod:[methods objectAtIndex:0] matchesInstanceComponents:@"id", @"method", @"NSString", @"*", @"var", nil];
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
	assertThatInteger([methods count], equalToInteger(1));
	[self assertMethod:[methods objectAtIndex:0] matchesInstanceComponents:@"id", @"arg1", @"int", @"var1", @"arg2", @"long", @"var2", nil];
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
	assertThatInteger([methods count], equalToInteger(2));
	[self assertMethod:[methods objectAtIndex:0] matchesInstanceComponents:@"id", @"method1", nil];
	[self assertMethod:[methods objectAtIndex:1] matchesClassComponents:@"void", @"method2", nil];
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
	assertThatInteger([methods count], equalToInteger(1));
	[self assertMethod:[methods objectAtIndex:0] matchesInstanceComponents:@"id", @"method", nil];
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
	assertThatInteger([methods count], equalToInteger(1));
	[self assertMethod:[methods objectAtIndex:0] matchesInstanceComponents:@"id", @"method", @"NSString", @"*", @"var", nil];
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
	assertThatInteger([methods count], equalToInteger(1));
	[self assertMethod:[methods objectAtIndex:0] matchesInstanceComponents:@"id", @"arg1", @"int", @"var1", @"arg2", @"long", @"var2", nil];
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
	assertThatInteger([methods count], equalToInteger(2));
	[self assertMethod:[methods objectAtIndex:0] matchesInstanceComponents:@"id", @"method1", nil];
	[self assertMethod:[methods objectAtIndex:1] matchesClassComponents:@"void", @"method2", nil];
}

- (void)testParseObjectsFromString_shouldRegisterNestedMethodDeclaration {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@implementation MyClass -(id)method { if (_var) { if(a>b) { [self quit]; } else { MY_MACRO(_var); } } } @end" sourceFile:@"filename.h" toStore:store];
	// verify
	GBClassData *class = [[store classes] anyObject];
	NSArray *methods = [[class methods] methods];
	assertThatInteger([methods count], equalToInteger(1));
	[self assertMethod:[methods objectAtIndex:0] matchesInstanceComponents:@"id", @"method", nil];
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
	assertThatInteger([methods count], equalToInteger(1));
	[self assertMethod:[methods objectAtIndex:0] matchesPropertyComponents:@"readonly", @"int", @"name", nil];
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
	assertThatInteger([methods count], equalToInteger(1));
	[self assertMethod:[methods objectAtIndex:0] matchesPropertyComponents:@"retain", @"nonatomic", @"IBOutlet", @"NSString", @"*", @"name", nil];
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
	assertThatInteger([methods count], equalToInteger(2));
	[self assertMethod:[methods objectAtIndex:0] matchesPropertyComponents:@"readonly", @"int", @"name1", nil];
	[self assertMethod:[methods objectAtIndex:1] matchesPropertyComponents:@"readwrite", @"long", @"name2", nil];
}

@end
