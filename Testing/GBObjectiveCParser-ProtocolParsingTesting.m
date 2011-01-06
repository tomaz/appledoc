//
//  GBObjectiveCParser-ProtocolParsingTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 25.7.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBStore.h"
#import "GBDataObjects.h"
#import "GBObjectiveCParser.h"

// Note that we're only testing protocol specific stuff here - i.e. all common parsing modules (adopted protocols, ivars, methods...) are tested separately to avoid repetition.

@interface GBObjectiveCParserProtocolsParsingTesting : GBObjectsAssertor
@end

@implementation GBObjectiveCParserProtocolsParsingTesting

#pragma mark Protocols common data parsing testing

- (void)testParseObjectsFromString_shouldRegisterProtocolDefinition {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@protocol MyProtocol @end" sourceFile:@"filename.h" toStore:store];
	// verify
	NSArray *protocols = [store protocolsSortedByName];
	assertThatInteger([protocols count], equalToInteger(1));
	assertThat([[protocols objectAtIndex:0] nameOfProtocol], is(@"MyProtocol"));
}

- (void)testParseObjectsFromString_shouldRegisterProtocolSourceFileAndLineNumber {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@protocol MyProtocol @end" sourceFile:@"filename.h" toStore:store];
	// verify
	NSSet *files = [[[store protocolsSortedByName] objectAtIndex:0] sourceInfos];
	assertThatInteger([files count], equalToInteger(1));
	assertThat([[files anyObject] filename], is(@"filename.h"));
	assertThatInteger([[files anyObject] lineNumber], equalToInteger(1));
}

- (void)testParseObjectsFromString_shouldRegisterProtocolProperSourceLineNumber {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"\n// cmt\n\n#define DEBUG\n\n/// hello\n@protocol MyProtocol @end" sourceFile:@"filename.h" toStore:store];
	// verify
	NSSet *files = [[[store protocolsSortedByName] objectAtIndex:0] sourceInfos];
	assertThatInteger([[files anyObject] lineNumber], equalToInteger(7));
}

- (void)testParseObjectsFromString_shouldRegisterAllProtocolDefinitions {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@protocol MyProtocol1 @end   @protocol MyProtocol2 @end" sourceFile:@"filename.h" toStore:store];
	// verify
	NSArray *protocols = [store protocolsSortedByName];
	assertThatInteger([protocols count], equalToInteger(2));
	assertThat([[protocols objectAtIndex:0] nameOfProtocol], is(@"MyProtocol1"));
	assertThat([[protocols objectAtIndex:1] nameOfProtocol], is(@"MyProtocol2"));
}

#pragma mark Protocol comments parsing testing

- (void)testParseObjectsFromString_shouldRegisterProtocolDefinitionComment {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"/** Comment */ @protocol MyProtocol @end" sourceFile:@"filename.h" toStore:store];
	// verify
	GBProtocolData *protocol = [[store protocols] anyObject];
	assertThat(protocol.comment.stringValue, is(@"Comment"));
}

- (void)testParseObjectsFromString_shouldRegisterProtocolDefinitionCommentSourceFileAndLineNumber {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"/// comment\n\n#define SOMETHING\n\n/** comment */ @protocol MyProtocol @end" sourceFile:@"filename.h" toStore:store];
	// verify
	GBClassData *protocol = [[store protocols] anyObject];
	assertThat(protocol.comment.sourceInfo.filename, is(@"filename.h"));
	assertThatInteger(protocol.comment.sourceInfo.lineNumber, equalToInteger(5));
}

- (void)testParseObjectsFromString_shouldRegisterProtocolDefinitionCommentForComplexDeclarations {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:
	 @"/** Comment */\n"
	 @"#ifdef SOMETHING\n"
	 @"@protocol MyProtocol\n"
	 @"#else\n"
	 @"@protocol MyProtocol1\n"
	 @"#endif\n"
	 @"@end" sourceFile:@"filename.h" toStore:store];
	// verify
	GBProtocolData *protocol = [store.protocols anyObject];
	assertThat(protocol.nameOfProtocol, is(@"MyProtocol"));
	assertThat(protocol.comment.stringValue, is(@"Comment"));
}

- (void)testParseObjectsFromString_shouldProperlyResetComments { 
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"/** Comment */ @protocol MyProtocol -(void)method; @end" sourceFile:@"filename.h" toStore:store];
	// verify
	GBProtocolData *protocol = [store.protocols anyObject];
	GBMethodData *method = [protocol.methods.methods lastObject];
	assertThat(method.comment, is(nil));
}

#pragma mark Protocol components parsing testing

- (void)testParseObjectsFromString_shouldRegisterAdoptedProtocols {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@protocol MyProtocol <Protocol1, Protocol2> @end" sourceFile:@"filename.h" toStore:store];
	// verify
	GBProtocolData *protocol = [[store protocols] anyObject];
	NSArray *protocols = [protocol.adoptedProtocols protocolsSortedByName];
	assertThatInteger([protocols count], equalToInteger(2));
	assertThat([[protocols objectAtIndex:0] nameOfProtocol], is(@"Protocol1"));
	assertThat([[protocols objectAtIndex:1] nameOfProtocol], is(@"Protocol2"));
}

- (void)testParseObjectsFromString_shouldRegisterMethods {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@protocol MyProtocol -(void)method1; -(void)method2; @end" sourceFile:@"filename.h" toStore:store];
	// verify
	GBProtocolData *protocol = [[store protocols] anyObject];
	NSArray *methods = [protocol.methods methods];
	assertThatInteger([methods count], equalToInteger(2));
	assertThat([[methods objectAtIndex:0] methodSelector], is(@"method1"));
	assertThat([[methods objectAtIndex:1] methodSelector], is(@"method2"));
}

#pragma mark Merging testing

- (void)testParseObjectsFromString_shouldMergeProtocolDefinitions {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@protocol MyProtocol1 -(void)method1; @end" sourceFile:@"filename1.h" toStore:store];
	[parser parseObjectsFromString:@"@protocol MyProtocol1 -(void)method2; @end" sourceFile:@"filename2.h" toStore:store];
	// verify - simple testing here, details within GBModelBaseTesting!
	assertThatInteger([[store protocols] count], equalToInteger(1));
	GBProtocolData *protocol = [[store protocols] anyObject];
	NSArray *methods = [protocol.methods methods];
	assertThatInteger([methods count], equalToInteger(2));
	assertThat([[methods objectAtIndex:0] methodSelector], is(@"method1"));
	assertThat([[methods objectAtIndex:1] methodSelector], is(@"method2"));
}

#pragma mark Complex parsing testing

- (void)testParseObjectsFromString_shouldRegisterProtocolFromRealLifeInput {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:[GBRealLifeDataProvider headerWithClassCategoryAndProtocol] sourceFile:@"filename.h" toStore:store];
	// verify - we're not going into details here, just checking that top-level objects were properly parsed!
	assertThatInteger([[store protocols] count], equalToInteger(1));
	GBProtocolData *protocol = [[store protocols] anyObject];
	assertThat(protocol.nameOfProtocol, is(@"GBObserving"));
}

@end
