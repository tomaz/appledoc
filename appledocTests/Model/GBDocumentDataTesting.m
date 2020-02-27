//
//  GBDocumentDataTesting.m
//  appledocTests
//
//  Created by Jebeom Gyeong on 2/22/20.
//  Copyright © 2020 Gentle Bytes. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "GBDataObjects.h"
#import "GBApplicationSettingsProvider.h"

@interface GBDocumentDataTesting : XCTestCase

@end

@implementation GBDocumentDataTesting

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

#pragma mark Initializers testing

- (void)testInitWithContentsData_shouldCreateCommentWithContentsAsStringValue {
    // setup & execute
    GBDocumentData *document = [GBDocumentData documentDataWithContents:@"contents" path:@"path"];
    // verify
    XCTAssertNotNil(document.comment);
    XCTAssertEqualObjects(document.comment.stringValue, @"contents");
}

- (void)testInitWithContentsData_shouldCreateSourceInfoUsingThePathAsFilename {
    // setup & execute
    GBDocumentData *document = [GBDocumentData documentDataWithContents:@"contents" path:@"path/to/document.ext"];
    // verify
    XCTAssertEqual([document.sourceInfos count], 1);
    XCTAssertEqual([[document.sourceInfos anyObject] lineNumber], 1);
    XCTAssertEqualObjects([[document.sourceInfos anyObject] filename], @"document.ext");
}

- (void)testInitWithContentsData_shouldAssignNameOfDocument {
    // setup & execute
    GBDocumentData *document = [GBDocumentData documentDataWithContents:@"contents" path:@"path/document.extension"];
    // verify
    XCTAssertEqualObjects(document.nameOfDocument, @"document.extension");
}

- (void)testInitWithContentsData_shouldAssignPathOfDocument {
    // setup & execute
    GBDocumentData *document = [GBDocumentData documentDataWithContents:@"contents" path:@"path/document.extension"];
    // verify
    XCTAssertEqualObjects(document.pathOfDocument, @"path/document.extension");
}

#pragma mark Convenience methods testing

- (void)testSubpathOfDocument_shouldReturnProperValue {
    // setup & execute
    GBDocumentData *document1 = [GBDocumentData documentDataWithContents:@"c" path:@"document.ext" basePath:@""];
    GBDocumentData *document2 = [GBDocumentData documentDataWithContents:@"c" path:@"path/sub/document.ext" basePath:@""];
    GBDocumentData *document3 = [GBDocumentData documentDataWithContents:@"c" path:@"path/document.ext" basePath:@"path"];
    GBDocumentData *document4 = [GBDocumentData documentDataWithContents:@"c" path:@"path/sub/document.ext" basePath:@"path"];
    GBDocumentData *document5 = [GBDocumentData documentDataWithContents:@"c" path:@"path/sub/document.ext" basePath:@"path/sub"];
    // verify
    XCTAssertEqualObjects(document1.subpathOfDocument, @"document.ext");
    XCTAssertEqualObjects(document2.subpathOfDocument, @"path/sub/document.ext");
    XCTAssertEqualObjects(document3.subpathOfDocument, @"document.ext");
    XCTAssertEqualObjects(document4.subpathOfDocument, @"sub/document.ext");
    XCTAssertEqualObjects(document5.subpathOfDocument, @"document.ext");
}

#pragma mark Overriden methods

- (void)testIsStaticDocument_shouldReturnYES {
    // setup & execute
    GBDocumentData *document = [GBDocumentData documentDataWithContents:@"contents" path:@"path"];
    // verify
    XCTAssertTrue(document.isStaticDocument);
}

- (void)testIsTopLevelObject_shouldReturnNO {
    // setup & execute
    GBDocumentData *document = [GBDocumentData documentDataWithContents:@"contents" path:@"path"];
    // verify
    XCTAssertFalse(document.isTopLevelObject);
}

@end
