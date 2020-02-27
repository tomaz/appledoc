//
//  GBIvarDataTesting.m
//  appledocTests
//
//  Created by Jebeom Gyeong on 2/22/20.
//  Copyright © 2020 Gentle Bytes. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "GBIvarData.h"
#import "GBSourceInfo.h"
#import "GBTestObjectsRegistry.h"

@interface GBIvarDataTesting : XCTestCase

@end

@implementation GBIvarDataTesting

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testMergeDataFromObject_shouldMergeImplementationDetails {
    // setup - ivars don't merge any data, except they need to send base class merging message!
    GBIvarData *original = [GBTestObjectsRegistry ivarWithComponents:@"int", @"_name", nil];
    GBIvarData *source = [GBTestObjectsRegistry ivarWithComponents:@"int", @"_name", nil];
    [source registerSourceInfo:[GBSourceInfo infoWithFilename:@"file" lineNumber:1]];
    // execute
    [original mergeDataFromObject:source];
    // verify - simple testing here, fully tested in GBModelBaseTesting!
    XCTAssertEqual([original.sourceInfos count], 1);
}

- (void)testIsTopLevelObject_shouldReturnNO {
    // setup & execute
    GBIvarData *ivar = [GBTestObjectsRegistry ivarWithComponents:@"int", @"_name", nil];
    // verify
    XCTAssertFalse(ivar.isTopLevelObject);
}
@end
