//
//  GBObjectiveCParserTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 25.7.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBStore.h"
#import "GBObjectiveCParser.h"

@interface GBObjectiveCParserTesting : SenTestCase

- (OCMockObject *)mockSettingsProvider;

@end

@implementation GBObjectiveCParserTesting

#pragma mark Classes parsing testing

- (void)testParseObjectsFromString_shouldRegisterAllClassDefinitions {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[self mockSettingsProvider]];
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
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[self mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass @end" toStore:store];
	// verify
	GBClassData *class = [[store classes] anyObject];
	assertThat(class.superclassName, is(nil));
}

- (void)testParseObjectsFromString_shouldRegisterDerivedClass {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[self mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass : NSObject @end" toStore:store];
	// verify
	GBClassData *class = [[store classes] anyObject];
	assertThat(class.superclassName, is(@"NSObject"));
}

#pragma mark Creation methods

- (OCMockObject *)mockSettingsProvider {
	return [OCMockObject niceMockForProtocol:@protocol(GBApplicationSettingsProviding)];
}

@end
