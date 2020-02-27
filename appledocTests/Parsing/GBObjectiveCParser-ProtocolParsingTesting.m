//
//  GBObjectiveCParser-ProtocolParsingTesting.m
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

// Note that we're only testing protocol specific stuff here - i.e. all common parsing modules (adopted protocols, ivars, methods...) are tested separately to avoid repetition.

@interface GBObjectiveCParser_ProtocolParsingTesting : XCTestCase

@end

@implementation GBObjectiveCParser_ProtocolParsingTesting

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

#pragma mark Protocols common data parsing testing

- (void)testParseObjectsFromString_shouldRegisterProtocolDefinition {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@protocol MyProtocol @end" sourceFile:@"filename.h" toStore:store];
    // verify
    NSArray *protocols = [store protocolsSortedByName];
    XCTAssertEqual([protocols count], 1);
    XCTAssertEqualObjects([protocols[0] nameOfProtocol], @"MyProtocol");
}

- (void)testParseObjectsFromString_shouldRegisterProtocolSourceFileAndLineNumber {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@protocol MyProtocol @end" sourceFile:@"filename.h" toStore:store];
    // verify
    NSSet *files = [[store protocolsSortedByName][0] sourceInfos];
    XCTAssertEqual([files count], 1);
    XCTAssertEqualObjects([[files anyObject] filename], @"filename.h");
    XCTAssertEqual([[files anyObject] lineNumber], 1);
}

- (void)testParseObjectsFromString_shouldRegisterProtocolProperSourceLineNumber {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"\n// cmt\n\n#define DEBUG\n\n/// hello\n@protocol MyProtocol @end" sourceFile:@"filename.h" toStore:store];
    // verify
    NSSet *files = [[store protocolsSortedByName][0] sourceInfos];
    XCTAssertEqual([[files anyObject] lineNumber], 7);
}

- (void)testParseObjectsFromString_shouldRegisterAllProtocolDefinitions {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@protocol MyProtocol1 @end   @protocol MyProtocol2 @end" sourceFile:@"filename.h" toStore:store];
    // verify
    NSArray *protocols = [store protocolsSortedByName];
    XCTAssertEqual([protocols count], 2);
    XCTAssertEqualObjects([protocols[0] nameOfProtocol], @"MyProtocol1");
    XCTAssertEqualObjects([protocols[1] nameOfProtocol], @"MyProtocol2");
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
    XCTAssertEqualObjects(protocol.comment.stringValue, @"Comment");
}

- (void)testParseObjectsFromString_shouldRegisterProtocolDefinitionCommentSourceFileAndLineNumber {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"/// comment\n\n#define SOMETHING\n\n/** comment */ @protocol MyProtocol @end" sourceFile:@"filename.h" toStore:store];
    // verify
    GBClassData *protocol = [[store protocols] anyObject];
    XCTAssertEqualObjects(protocol.comment.sourceInfo.filename, @"filename.h");
    XCTAssertEqual(protocol.comment.sourceInfo.lineNumber, 5);
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
    XCTAssertEqualObjects(protocol.nameOfProtocol, @"MyProtocol");
    XCTAssertEqualObjects(protocol.comment.stringValue, @"Comment");
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
    XCTAssertNil(method.comment);
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
    XCTAssertEqual([protocols count], 2);
    XCTAssertEqualObjects([protocols[0] nameOfProtocol], @"Protocol1");
    XCTAssertEqualObjects([protocols[1] nameOfProtocol], @"Protocol2");
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
    XCTAssertEqual([methods count], 2);
    XCTAssertEqualObjects([methods[0] methodSelector], @"method1");
    XCTAssertEqualObjects([methods[1] methodSelector], @"method2");
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
    XCTAssertEqual([[store protocols] count], 1);
    GBProtocolData *protocol = [[store protocols] anyObject];
    NSArray *methods = [protocol.methods methods];
    XCTAssertEqual([methods count], 2);
    XCTAssertEqualObjects([methods[0] methodSelector], @"method1");
    XCTAssertEqualObjects([methods[1] methodSelector], @"method2");
}

#pragma mark Complex parsing testing

- (void)testParseObjectsFromString_shouldRegisterProtocolFromRealLifeInput {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:[GBRealLifeDataProvider headerWithClassCategoryAndProtocol] sourceFile:@"filename.h" toStore:store];
    // verify - we're not going into details here, just checking that top-level objects were properly parsed!
    XCTAssertEqual([[store protocols] count], 1);
    GBProtocolData *protocol = [[store protocols] anyObject];
    XCTAssertEqualObjects(protocol.nameOfProtocol, @"GBObserving");
}

@end
