//
//  GBObjectiveCParser-AdoptedProtocolsParsingTesting.m
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

// Note that we use class for invoking parsing of adopted protocols. Probably not the best option - i.e. we could isolate parsing code altogether and only parse relevant stuff here, but it seemed not much would be gained by doing this. Separating unit tests does avoid repetition in top-level objects testing code - we only need to test specific data there.

@interface GBObjectiveCParser_AdoptedProtocolsParsingTesting : XCTestCase

@end

@implementation GBObjectiveCParser_AdoptedProtocolsParsingTesting

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testParseObjectsFromString_shouldRegisterAdoptedProtocol {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@interface MyClass <MyProtocol> @end" sourceFile:@"filename.h" toStore:store];
    // verify
    NSArray *protocols = [[[[store classes] anyObject] adoptedProtocols] protocolsSortedByName];
    XCTAssertEqual([protocols count], 1);
    XCTAssertEqualObjects([protocols[0] nameOfProtocol], @"MyProtocol");
}

- (void)testParseObjectsFromString_shouldRegisterAllAdoptedProtocols {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@interface MyClass <MyProtocol1, MyProtocol2> @end" sourceFile:@"filename.h" toStore:store];
    // verify
    NSArray *protocols = [[[[store classes] anyObject] adoptedProtocols] protocolsSortedByName];
    XCTAssertEqual([protocols count], 2);
    XCTAssertEqualObjects([protocols[0] nameOfProtocol], @"MyProtocol1");
    XCTAssertEqualObjects([protocols[1] nameOfProtocol], @"MyProtocol2");
}

@end
