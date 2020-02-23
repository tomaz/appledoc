//
//  GBCommentComponentsListTesting.m
//  appledocTests
//
//  Created by Jebeom Gyeong on 2/22/20.
//  Copyright © 2020 Gentle Bytes. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "GBDataObjects.h"

@interface GBCommentComponentsListTesting : XCTestCase

@end

@implementation GBCommentComponentsListTesting

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

#pragma mark Initialization & disposal

- (void)testInit_shouldInitializeEmptyList {
    // setup & execute
    GBCommentComponentsList *list = [[GBCommentComponentsList alloc] init];
    // verify
    XCTAssertNotNil(list.components);
    XCTAssertEqual([list.components count], 0);
}

#pragma mark Registration testing

- (void)testRegisterComponent_shouldAddComponentToComponentsArray {
    // setup
    GBCommentComponentsList *list = [[GBCommentComponentsList alloc] init];
    // execute
    [list registerComponent:[GBCommentComponent componentWithStringValue:@"a"]];
    // verify
    XCTAssertEqual([list.components count], 1);
    XCTAssertEqualObjects([list.components[0] stringValue], @"a");
}

- (void)testRegisterComponent_shouldAddComponentsToArrayInOrder {
    // setup
    GBCommentComponentsList *list = [[GBCommentComponentsList alloc] init];
    // execute
    [list registerComponent:[GBCommentComponent componentWithStringValue:@"a"]];
    [list registerComponent:[GBCommentComponent componentWithStringValue:@"b"]];
    [list registerComponent:[GBCommentComponent componentWithStringValue:@"c"]];
    // verify
    XCTAssertEqual([list.components count], 3);
    XCTAssertEqualObjects([list.components[0] stringValue], @"a");
    XCTAssertEqualObjects([list.components[1] stringValue], @"b");
    XCTAssertEqualObjects([list.components[2] stringValue], @"c");
}


@end
