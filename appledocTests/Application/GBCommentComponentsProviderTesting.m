//
//  GBCommentComponentsProviderTesting.m
//  appledocTests
//
//  Created by Jebeom Gyeong on 2/22/20.
//  Copyright © 2020 Gentle Bytes. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "GBApplicationSettingsProvider.h"
#import "GBCommentComponentsProvider.h"

@interface GBCommentComponentsProviderTesting : XCTestCase

@end

@implementation GBCommentComponentsProviderTesting

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testInitializer_shouldPrepareOptionalCrossReferencePrefixAndSuffix {
    // setup & execute
    GBCommentComponentsProvider *provider = [GBCommentComponentsProvider provider];
    // verify
    XCTAssertEqualObjects(provider.crossReferenceMarkersTemplate, @"<?%@>?");
}

@end
