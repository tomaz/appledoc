//
//  GBObjectiveCParser-CategoryParsingTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 27.7.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBStore.h"
#import "GBObjectiveCParser.h"

// Note that we're only testing category specific stuff here - i.e. all common parsing modules (adopted protocols,
// methods...) are tested separately to avoid repetition.

@interface GBObjectiveCParserCategoryParsingTesting : GBObjectsAssertor
@end

@implementation GBObjectiveCParserCategoryParsingTesting

#pragma mark Categories common data parsing testing

- (void)testParseObjectsFromString_shouldRegisterCategoryDefinition {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass (MyCategory) @end" toStore:store];
	// verify
	NSArray *categories = [store categoriesSortedByName];
	assertThatInteger([categories count], equalToInteger(1));
	assertThat([[categories objectAtIndex:0] className], is(@"MyClass"));
	assertThat([[categories objectAtIndex:0] categoryName], is(@"MyCategory"));
}

- (void)testParseObjectsFromString_shouldRegisterAllCategoryDefinitions {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass(MyCategory1) @end   @interface MyClass(MyCategory2) @end" toStore:store];
	// verify
	NSArray *categories = [store categoriesSortedByName];
	assertThatInteger([categories count], equalToInteger(2));
	assertThat([[categories objectAtIndex:0] categoryName], is(@"MyCategory1"));
	assertThat([[categories objectAtIndex:1] categoryName], is(@"MyCategory2"));
}

#pragma mark Extensions common data parsing testing

- (void)testParseObjectsFromString_shouldRegisterExtensionDefinition {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass () @end" toStore:store];
	// verify
	NSArray *categories = [store categoriesSortedByName];
	assertThatInteger([categories count], equalToInteger(1));
	assertThat([[categories objectAtIndex:0] className], is(@"MyClass"));
	assertThat([[categories objectAtIndex:0] categoryName], is(nil));
}

- (void)testParseObjectsFromString_shouldRegisterAllExtensionDefinitions {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass1() @end   @interface MyClass2() @end" toStore:store];
	// verify
	NSArray *categories = [store categoriesSortedByName];
	assertThatInteger([categories count], equalToInteger(2));
	assertThat([[categories objectAtIndex:0] className], is(@"MyClass1"));
	assertThat([[categories objectAtIndex:1] className], is(@"MyClass2"));
}

#pragma mark Complex parsing testing

- (void)testParseObjectsFromString_shouldRegisterCategoriesAndExtensionsFromRealLifeInput {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:[GBRealLifeDataProvider headerWithClassCategoryAndProtocol] toStore:store];
	// verify - we're not going into details here, just checking that top-level objects were properly parsed!
	NSArray *categories = [store categoriesSortedByName];
	assertThatInteger([categories count], equalToInteger(2));
	assertThat([[categories objectAtIndex:0] className], is(@"GBCalculator"));
	assertThat([[categories objectAtIndex:0] categoryName], is(nil));
	assertThat([[categories objectAtIndex:1] className], is(@"GBCalculator"));
	assertThat([[categories objectAtIndex:1] categoryName], is(@"Multiplication"));
}

@end
