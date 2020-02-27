//
//  GBModelBaseTesting.m
//  appledocTests
//
//  Created by Jebeom Gyeong on 2/22/20.
//  Copyright © 2020 Gentle Bytes. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "GBDataObjects.h"

@interface GBModelBaseTesting : XCTestCase

@end

@implementation GBModelBaseTesting

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

#pragma mark Common merging testing

- (void)testMergeDataFromObject_shouldMergeDeclaredFiles {
    // setup
    GBModelBase *original = [[GBModelBase alloc] init];
    [original registerSourceInfo:[GBSourceInfo infoWithFilename:@"f1" lineNumber:1]];
    [original registerSourceInfo:[GBSourceInfo infoWithFilename:@"f2" lineNumber:2]];
    GBModelBase *source = [[GBModelBase alloc] init];
    [source registerSourceInfo:[GBSourceInfo infoWithFilename:@"f1" lineNumber:3]];
    [source registerSourceInfo:[GBSourceInfo infoWithFilename:@"f3" lineNumber:4]];
    // execute
    [original mergeDataFromObject:source];
    // verify
    NSArray *files = [original sourceInfosSortedByName];
    XCTAssertEqual([files count], 3);
    XCTAssertEqualObjects([files[0] filename], @"f1");
    XCTAssertEqualObjects([files[1] filename], @"f2");
    XCTAssertEqualObjects([files[2] filename], @"f3");
    XCTAssertEqual([files[0] lineNumber], 3);
    XCTAssertEqual([files[1] lineNumber], 2);
    XCTAssertEqual([files[2] lineNumber], 4);
}

- (void)testMergeDataFromObject_shouldPreserveSourceDeclaredFiles {
    // setup
    GBModelBase *original = [[GBModelBase alloc] init];
    [original registerSourceInfo:[GBSourceInfo infoWithFilename:@"f1" lineNumber:4]];
     [original registerSourceInfo:[GBSourceInfo infoWithFilename:@"f2" lineNumber:3]];
    GBModelBase *source = [[GBModelBase alloc] init];
     [source registerSourceInfo:[GBSourceInfo infoWithFilename:@"f1" lineNumber:2]];
     [source registerSourceInfo:[GBSourceInfo infoWithFilename:@"f3" lineNumber:1]];
    // execute
    [original mergeDataFromObject:source];
    // verify
    NSArray *files = [source sourceInfosSortedByName];
    XCTAssertEqual([files count], 2);
    XCTAssertEqualObjects([files[0] filename], @"f1");
    XCTAssertEqualObjects([files[1] filename], @"f3");
    XCTAssertEqual([files[0] lineNumber], 2);
    XCTAssertEqual([files[1] lineNumber], 1);
}

#pragma mark Comments merging handling

- (void)testMergeDataFromObject_shouldUseOriginalCommentIfSourceIsNotGiven {
    // setup
    GBModelBase *original = [[GBModelBase alloc] init];
    original.comment = [GBComment commentWithStringValue:@"Comment"];
    GBModelBase *source = [[GBModelBase alloc] init];
    // execute
    [original mergeDataFromObject:source];
    // verify
    XCTAssertEqualObjects(original.comment.stringValue, @"Comment");
    XCTAssertNil(source.comment.stringValue);
}

- (void)testMergeDataFromObject_shouldUseSourceCommentIfOriginalIsNotGiven {
    // setup
    GBModelBase *original = [[GBModelBase alloc] init];
    GBModelBase *source = [[GBModelBase alloc] init];
    source.comment = [GBComment commentWithStringValue:@"Comment"];
    // execute
    [original mergeDataFromObject:source];
    // verify
    XCTAssertEqualObjects(original.comment.stringValue, @"Comment");
    XCTAssertEqualObjects(source.comment.stringValue, @"Comment");
}

- (void)testMergeDataFromObject_shouldKeepOriginalCommentIfBothObjectsHaveComments {
    // setup
    GBModelBase *original = [[GBModelBase alloc] init];
    original.comment = [GBComment commentWithStringValue:@"Comment1"];
    GBModelBase *source = [[GBModelBase alloc] init];
    source.comment = [GBComment commentWithStringValue:@"Comment2"];
    // execute
    [original mergeDataFromObject:source];
    // verify
    XCTAssertEqualObjects(original.comment.stringValue, @"Comment1");
    XCTAssertEqualObjects(source.comment.stringValue, @"Comment2");
}

#pragma mark Source information testing

- (void)testPrefferedSourceInfo_shouldReturnSourceInfoFromComment {
    // setup
    GBModelBase *object = [[GBModelBase alloc] init];
    object.comment = [GBComment commentWithStringValue:@"comment"];
    object.comment.sourceInfo = [GBSourceInfo infoWithFilename:@"file1" lineNumber:1];
    [object registerSourceInfo:[GBSourceInfo infoWithFilename:@"file.h" lineNumber:1]];
    // execute & verify
    XCTAssertEqualObjects(object.prefferedSourceInfo, object.comment.sourceInfo);
}

- (void)testPrefferedSourceInfo_shouldReturnHeaderFileSourceInfoIfCommentNotGiven {
    // setup
    GBModelBase *object = [[GBModelBase alloc] init];
    [object registerSourceInfo:[GBSourceInfo infoWithFilename:@"a.m" lineNumber:1]];
    [object registerSourceInfo:[GBSourceInfo infoWithFilename:@"b.h" lineNumber:1]];
    // execute & verify
    XCTAssertEqualObjects(object.prefferedSourceInfo.filename, @"b.h");
}
               
- (void)testPrefferedSourceInfo_shouldReturnHeaderFileSourceInfoIfCommentDoesntHaveSourceInfo {
    // setup
    GBModelBase *object = [[GBModelBase alloc] init];
    object.comment = [GBComment commentWithStringValue:@"comment"];
    [object registerSourceInfo:[GBSourceInfo infoWithFilename:@"a.m" lineNumber:1]];
    [object registerSourceInfo:[GBSourceInfo infoWithFilename:@"b.h" lineNumber:1]];
    // execute & verify
    XCTAssertEqualObjects(object.prefferedSourceInfo.filename, @"b.h");
}

- (void)testPrefferedSourceInfo_shouldReturnSingleSourceInfo {
    // setup
    GBModelBase *object = [[GBModelBase alloc] init];
    [object registerSourceInfo:[GBSourceInfo infoWithFilename:@"a.m" lineNumber:1]];
    // execute & verify
    XCTAssertEqualObjects(object.prefferedSourceInfo.filename, @"a.m");
}

- (void)testPrefferedSourceInfo_shouldReturnNilIfNoSourceInfoAvailable {
    // setup
    GBModelBase *object = [[GBModelBase alloc] init];
    // execute & verify
    XCTAssertNil(object.prefferedSourceInfo);
}
@end
