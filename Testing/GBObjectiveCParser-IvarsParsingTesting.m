//
//  GBObjectiveCParser-IvarsParsingTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 25.7.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBStore.h"
#import "GBDataObjects.h"
#import "GBObjectiveCParser.h"

// Note that we use class for invoking parsing of ivars. Probably not the best option - i.e. we could isolate ivars parsing code altogether and only parse relevant stuff here, but it seemed not much would be gained by doing this. Separating unit tests does avoid repetition in top-level objects testing code - we only need to test specific data there.

@interface GBObjectiveCParserIvarsParsingTesting : GBObjectsAssertor
@end

@implementation GBObjectiveCParserIvarsParsingTesting

#pragma mark Ivars parsing testing

- (void)testParseObjectsFromString_shouldIgnoreIVar {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass { int _var; } @end" sourceFile:@"filename.h" toStore:store];
	// verify
	GBClassData *class = [[store classes] anyObject];
	NSArray *ivars = [[class ivars] ivars];
	assertThatInteger([ivars count], equalToInteger(0));
}

- (void)testParseObjectsFromString_shouldIgnoreAllIVars {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass { int _var1; long _var2; } @end" sourceFile:@"filename.h" toStore:store];
	// verify
	GBClassData *class = [[store classes] anyObject];
	NSArray *ivars = [[class ivars] ivars];
	assertThatInteger([ivars count], equalToInteger(0));
}

- (void)testParseObjectsFromString_shouldIgnoreComplexIVar {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass { id<Protocol>* _var; } @end" sourceFile:@"filename.h" toStore:store];
	// verify
	GBClassData *class = [[store classes] anyObject];
	NSArray *ivars = [[class ivars] ivars];
	assertThatInteger([ivars count], equalToInteger(0));
}

- (void)testParseObjectsFromString_shouldIgnoreIVarEndingWithParenthesis {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass { void (^_name)(id obj, NSUInteger idx, BOOL *stop); } @end" sourceFile:@"filename.h" toStore:store];
	// verify
	GBClassData *class = [[store classes] anyObject];
	NSArray *ivars = [[class ivars] ivars];
	assertThatInteger([ivars count], equalToInteger(0));
}

@end
