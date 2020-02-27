//
//  GBCommentTesting.m
//  appledocTests
//
//  Created by Jebeom Gyeong on 2/22/20.
//  Copyright © 2020 Gentle Bytes. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <OCMock/OCMockObject.h>

#import "GBApplicationSettingsProvider.h"
#import "GBDataObjects.h"
#import "GBTestObjectsRegistry.h"

@interface GBCommentTesting : XCTestCase

@end

@implementation GBCommentTesting

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

#pragma mark Initialization & disposal

- (void)testInit_shouldSetupDefaultComponents {
    // setup & execute
    GBComment *comment = [GBComment commentWithStringValue:@""];
    // verify
    XCTAssertNotNil(comment.longDescription);
    XCTAssertNotNil(comment.relatedItems);
    XCTAssertNotNil(comment.methodParameters);
    XCTAssertNotNil(comment.methodExceptions);
    XCTAssertNotNil(comment.methodResult);
    XCTAssertNotNil(comment.availability);
}

#pragma mark Comment components testing

- (void)testHtmlString_shouldUseAssignedSettings {
    // setup
    GBCommentComponent *component = [GBCommentComponent componentWithStringValue:@"source"];
    component.markdownValue = @"markdown";
    OCMockObject *settings = [GBTestObjectsRegistry mockSettingsProvider];
    component.settings = settings;
    [[settings expect] stringByConvertingMarkdownToHTML:component.markdownValue];
    // execute
    (void)component.htmlValue;
    // verify
    [settings verify];

}

- (void)testTextString_shouldUseAssignedSettings {
    // setup
    GBCommentComponent *component = [GBCommentComponent componentWithStringValue:@"source"];
    component.markdownValue = @"markdown";
    OCMockObject *settings = [GBTestObjectsRegistry mockSettingsProvider];
    component.settings = settings;
    [[settings expect] stringByConvertingMarkdownToText:component.markdownValue];
    // execute
    (void)component.textValue;
    // verify
    [settings verify];
}
@end
