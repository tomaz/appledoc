//
//  GBObjectiveCParser-ClassParsingTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 25.7.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBStore.h"
#import "GBClassData.h"
#import "GBObjectiveCParser.h"

@interface GBObjectiveCParserClassParsingTesting : SenTestCase

- (OCMockObject *)mockSettingsProvider;
- (void)assertIvar:(GBIvarData *)ivar matches:(NSString *)firstType,... NS_REQUIRES_NIL_TERMINATION;

@end

@implementation GBObjectiveCParserClassParsingTesting

#pragma mark Classes common data parsing testing

- (void)testParseObjectsFromString_classes_shouldRegisterClassDefinition {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[self mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass @end" toStore:store];
	// verify
	NSArray *classes = [store classesSortedByName];
	assertThatInteger([classes count], equalToInteger(1));
	assertThat([[classes objectAtIndex:0] className], is(@"MyClass"));
}

- (void)testParseObjectsFromString_classes_shouldRegisterAllClassDefinitions {
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

- (void)testParseObjectsFromString_classes_shouldRegisterRootClass {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[self mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass @end" toStore:store];
	// verify
	GBClassData *class = [[store classes] anyObject];
	assertThat(class.superclassName, is(nil));
}

- (void)testParseObjectsFromString_classes_shouldRegisterDerivedClass {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[self mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass : NSObject @end" toStore:store];
	// verify
	GBClassData *class = [[store classes] anyObject];
	assertThat(class.superclassName, is(@"NSObject"));
}

#pragma mark Classes adopted protocols parsing testing

- (void)testParseObjectsFromString_classes_shouldRegisterAdoptedProtocol {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[self mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass <MyProtocol> @end" toStore:store];
	// verify
	GBClassData *class = [[store classes] anyObject];
	NSArray *protocols = [[class adoptedProtocols] protocolsSortedByName];
	assertThatInteger([protocols count], equalToInteger(1));
	assertThat([[protocols objectAtIndex:0] protocolName], is(@"MyProtocol"));
}

- (void)testParseObjectsFromString_classes_shouldRegisterAllAdoptedProtocols {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[self mockSettingsProvider]];
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

- (void)testParseObjectsFromString_classes_shouldRegisterIVar {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[self mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass { int _var; } @end" toStore:store];
	// verify
	GBClassData *class = [[store classes] anyObject];
	NSArray *ivars = [[class ivars] ivars];
	assertThatInteger([ivars count], equalToInteger(1));
	[self assertIvar:[ivars objectAtIndex:0] matches:@"int", @"_var", nil];
}

- (void)testParseObjectsFromString_classes_shouldRegisterAllIVars {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[self mockSettingsProvider]];
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

- (void)testParseObjectsFromString_classes_shouldRegisterComplexIVar {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[self mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass { id<Protocol>* _var; } @end" toStore:store];
	// verify
	GBClassData *class = [[store classes] anyObject];
	NSArray *ivars = [[class ivars] ivars];
	assertThatInteger([ivars count], equalToInteger(1));
	[self assertIvar:[ivars objectAtIndex:0] matches:@"id", @"<", @"Protocol", @">", @"*", @"_var", nil];
}

#pragma mark Creation methods

- (OCMockObject *)mockSettingsProvider {
	return [OCMockObject niceMockForProtocol:@protocol(GBApplicationSettingsProviding)];
}

#pragma mark Assertion methods

- (void)assertIvar:(GBIvarData *)ivar matches:(NSString *)firstType,... {
	NSMutableArray *arguments = [NSMutableArray array];
	va_list args;
	va_start(args, firstType);
	for (NSString *arg=firstType; arg != nil; arg=va_arg(args, NSString*)) {
		[arguments addObject:arg];
	}
	va_end(args);
	
	assertThatInteger([[ivar ivarTypes] count], equalToInteger([arguments count] - 1));
	for (NSUInteger i=0; i<[arguments count] - 1; i++)
		assertThat([ivar.ivarTypes objectAtIndex:i], is([arguments objectAtIndex:i]));
	
	assertThat(ivar.ivarName, is([arguments lastObject]));
}

@end
