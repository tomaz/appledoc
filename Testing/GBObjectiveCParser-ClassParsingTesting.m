//
//  GBObjectiveCParser-ClassParsingTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 25.7.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBStore.h"
#import "GBObjectiveCParser.h"

@interface GBObjectiveCParserClassParsingTesting : GBObjectsAssertor
@end

@implementation GBObjectiveCParserClassParsingTesting

#pragma mark Classes common data parsing testing

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

#pragma mark Classes adopted protocols parsing testing

- (void)testParseObjectsFromString_shouldRegisterAdoptedProtocol {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass <MyProtocol> @end" toStore:store];
	// verify
	GBClassData *class = [[store classes] anyObject];
	NSArray *protocols = [[class adoptedProtocols] protocolsSortedByName];
	assertThatInteger([protocols count], equalToInteger(1));
	assertThat([[protocols objectAtIndex:0] protocolName], is(@"MyProtocol"));
}

- (void)testParseObjectsFromString_shouldRegisterAllAdoptedProtocols {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass <MyProtocol1, MyProtocol2> @end" toStore:store];
	// verify
	GBClassData *class = [[store classes] anyObject];
	NSArray *protocols = [[class adoptedProtocols] protocolsSortedByName];
	assertThatInteger([protocols count], equalToInteger(2));
	assertThat([[protocols objectAtIndex:0] protocolName], is(@"MyProtocol1"));
	assertThat([[protocols objectAtIndex:1] protocolName], is(@"MyProtocol2"));
}

#pragma mark Ivars parsing testing

- (void)testParseObjectsFromString_shouldRegisterIVar {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass { int _var; } @end" toStore:store];
	// verify
	GBClassData *class = [[store classes] anyObject];
	NSArray *ivars = [[class ivars] ivars];
	assertThatInteger([ivars count], equalToInteger(1));
	[self assertIvar:[ivars objectAtIndex:0] matches:@"int", @"_var", nil];
}

- (void)testParseObjectsFromString_shouldRegisterAllIVars {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass { int _var1; long _var2; } @end" toStore:store];
	// verify
	GBClassData *class = [[store classes] anyObject];
	NSArray *ivars = [[class ivars] ivars];
	assertThatInteger([ivars count], equalToInteger(2));
	[self assertIvar:[ivars objectAtIndex:0] matches:@"int", @"_var1", nil];
	[self assertIvar:[ivars objectAtIndex:1] matches:@"long", @"_var2", nil];
}

- (void)testParseObjectsFromString_shouldRegisterComplexIVar {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass { id<Protocol>* _var; } @end" toStore:store];
	// verify
	GBClassData *class = [[store classes] anyObject];
	NSArray *ivars = [[class ivars] ivars];
	assertThatInteger([ivars count], equalToInteger(1));
	[self assertIvar:[ivars objectAtIndex:0] matches:@"id", @"<", @"Protocol", @">", @"*", @"_var", nil];
}

#pragma mark Methods parsing testing

- (void)testParseObjectsFromString_shouldRegisterMethodDefinitionWithNoArguments {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass -(id)method; @end" toStore:store];
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
	[parser parseObjectsFromString:@"@interface MyClass -(id)method:(NSString*)var; @end" toStore:store];
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
	[parser parseObjectsFromString:@"@interface MyClass -(id)arg1:(int)var1 arg2:(long)var2; @end" toStore:store];
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
	[parser parseObjectsFromString:@"@interface MyClass -(id)method1; +(void)method2; @end" toStore:store];
	// verify
	GBClassData *class = [[store classes] anyObject];
	NSArray *methods = [[class methods] methods];
	assertThatInteger([methods count], equalToInteger(2));
	[self assertMethod:[methods objectAtIndex:0] matchesInstanceComponents:@"id", @"method1", nil];
	[self assertMethod:[methods objectAtIndex:1] matchesClassComponents:@"void", @"method2", nil];
}

#pragma mark Properties parsing testing

- (void)testParseObjectsFromString_shouldRegisterSimplePropertyDefinition {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass @property(readonly) int name; @end" toStore:store];
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
	[parser parseObjectsFromString:@"@interface MyClass @property(retain,nonatomic) IBOutlet NSString *name; @end" toStore:store];
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
	[parser parseObjectsFromString:@"@interface MyClass @property(readonly) int name1; @property(readwrite)long name2; @end" toStore:store];
	// verify
	GBClassData *class = [[store classes] anyObject];
	NSArray *methods = [[class methods] methods];
	assertThatInteger([methods count], equalToInteger(2));
	[self assertMethod:[methods objectAtIndex:0] matchesPropertyComponents:@"readonly", @"int", @"name1", nil];
	[self assertMethod:[methods objectAtIndex:1] matchesPropertyComponents:@"readwrite", @"long", @"name2", nil];
}

#pragma mark Complex parsing testing

- (void)testParseObjectsFromString_shouldRegisterClassFromRealLifeInput {
	// setup
}

@end
