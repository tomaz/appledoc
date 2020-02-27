//
//  GObjectiveCParser-BlockParsingTesting.m
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

@interface GObjectiveCParser_BlockParsingTesting : XCTestCase

@end

@implementation GObjectiveCParser_BlockParsingTesting

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testParseObjectsFromString_shouldRegisterSimpleBlockComment {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    
    // execute
    [parser parseObjectsFromString:@"/// copyright\n/** Comment 1*/\ntypedef void(^anyBlock)(BOOL boolean);" sourceFile:@"filename.h" toStore:store];
    
    // verify
    GBTypedefBlockData *blockData = [store typedefBlockWithName:@"anyBlock"];
    
    XCTAssertEqualObjects([blockData.comment stringValue], @"Comment 1");
    XCTAssertNotNil(blockData.parameters);
    XCTAssertEqual(blockData.parameters.count, 1);
    GBTypedefBlockArgument *blockArgument = [[blockData parameters] firstObject];
    XCTAssertEqualObjects(blockArgument.className, @"BOOL");
    XCTAssertEqualObjects(blockArgument.name, @"boolean");
}

- (void)testParseObjectsFromString_shouldRegisterBlockComment {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    
    // execute
    [parser parseObjectsFromString:@"/// copyright\n/** Comment 1 */\ntypedef void(^anyBlock)(BOOL boolean, NSString *string);" sourceFile:@"filename.h" toStore:store];
    
    // verify
    GBTypedefBlockData *blockData = [store typedefBlockWithName:@"anyBlock"];
    
    XCTAssertEqualObjects([blockData.comment stringValue], @"Comment 1");
    XCTAssertNotNil(blockData.parameters);
    XCTAssertEqual(blockData.parameters.count, 2);
    GBTypedefBlockArgument *blockArgument = [[blockData parameters] firstObject];
    XCTAssertEqualObjects(blockArgument.className, @"BOOL");
    XCTAssertEqualObjects(blockArgument.name, @"boolean");
    blockArgument = [blockData parameters][1];
    XCTAssertEqualObjects(blockArgument.className, @"NSString");
    XCTAssertEqualObjects(blockArgument.name, @"*string");
}

- (void)testParseObjectsFromString_shouldRegisterBlockCommentWithNoArgName {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    
    // execute
    [parser parseObjectsFromString:@"/// copyright\n/** Comment 1*/\ntypedef void(^anyBlock)(BOOL, NSString *);" sourceFile:@"filename.h" toStore:store];
    
    // verify
    GBTypedefBlockData *blockData = [store typedefBlockWithName:@"anyBlock"];
    
    XCTAssertEqualObjects([[blockData comment] stringValue], @"Comment 1");
    XCTAssertNotNil([blockData parameters]);
    XCTAssertEqual([blockData parameters].count, 2);
    GBTypedefBlockArgument *blockArgument = [[blockData parameters] firstObject];
    XCTAssertEqualObjects(blockArgument.className, @"BOOL");
    XCTAssertEqualObjects(blockArgument.name, @"");
    blockArgument = [blockData parameters][1];
    XCTAssertEqualObjects(blockArgument.className, @"NSString");
    XCTAssertEqualObjects(blockArgument.name, @"*");
}

@end
