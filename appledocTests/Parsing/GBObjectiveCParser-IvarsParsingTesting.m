//
//  GBObjectiveCParser-IvarsParsingTesting.m
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

// Note that we use class for invoking parsing of ivars. Probably not the best option - i.e. we could isolate ivars parsing code altogether and only parse relevant stuff here, but it seemed not much would be gained by doing this. Separating unit tests does avoid repetition in top-level objects testing code - we only need to test specific data there.

@interface GBObjectiveCParser_IvarsParsingTesting : XCTestCase

@end

@implementation GBObjectiveCParser_IvarsParsingTesting

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

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
    XCTAssertEqual([ivars count], 0);
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
    XCTAssertEqual([ivars count], 0);
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
    XCTAssertEqual([ivars count], 0);
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
    XCTAssertEqual([ivars count], 0);
}
@end
