//
//  GBTemplateVariablesProvider-CommonTesting.m
//  appledocTests
//
//  Created by Jebeom Gyeong on 2/22/20.
//  Copyright © 2020 Gentle Bytes. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <OCMock/OCMockObject.h>

#import "GBApplicationSettingsProvider.h"
#import "GBHTMLTemplateVariablesProvider.h"
#import "GBHTMLTemplateVariablesProvider.h"
#import "GBTokenizer.h"
#import "GBClassData.h"
#import "GBTestObjectsRegistry.h"

@interface GBTemplateVariablesProvider_CommonTesting : XCTestCase

//- (NSDateFormatter *)yearFormatterFromSettings:(GBApplicationSettingsProvider *)settings;
//- (NSDateFormatter *)yearToDayFormatterFromSettings:(GBApplicationSettingsProvider *)settings;

@end

@implementation GBTemplateVariablesProvider_CommonTesting

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testVariablesForClass_shouldPrepareDefaultVariables {
    // setup
    id settings = [GBTestObjectsRegistry realSettingsProvider];
    GBHTMLTemplateVariablesProvider *provider = [GBHTMLTemplateVariablesProvider providerWithSettingsProvider:settings];
    GBClassData *class = [GBClassData classDataWithName:@"Class"];
    // execute
    NSDictionary *vars = [provider variablesForClass:class withStore:[GBTestObjectsRegistry store]];
    // verify - just basic tests...
    XCTAssertNotNil(vars[@"page"]);
    XCTAssertNotNil([vars valueForKeyPath:@"page.title"]);
    XCTAssertNotNil([vars valueForKeyPath:@"page.specifications"]);
    XCTAssertEqualObjects(vars[@"object"], class);
}

- (void)testVariableForClass_shouldPrepareFooterVariables {
    // setup
    id settings = [GBTestObjectsRegistry realSettingsProvider];
    GBHTMLTemplateVariablesProvider *provider = [GBHTMLTemplateVariablesProvider providerWithSettingsProvider:settings];
    GBClassData *class = [GBClassData classDataWithName:@"Class"];
    // execute
    NSDictionary *vars = [provider variablesForClass:class withStore:[GBTestObjectsRegistry store]];
    // verify - just basic tests...
    NSDate *date = [NSDate date];
    NSString *year = [[self yearFormatterFromSettings:settings] stringFromDate:date];
    NSString *day = [[self yearToDayFormatterFromSettings:settings] stringFromDate:date];
    XCTAssertEqualObjects([vars valueForKeyPath:@"page.copyrightDate"], year);
    XCTAssertEqualObjects([vars valueForKeyPath:@"page.lastUpdatedDate"], day);
}

#pragma mark Creation methods

- (NSDateFormatter *)yearFormatterFromSettings:(GBApplicationSettingsProvider *)settings {
    return [settings valueForKey:@"yearDateFormatter"];
}

- (NSDateFormatter *)yearToDayFormatterFromSettings:(GBApplicationSettingsProvider *)settings {
    return [settings valueForKey:@"yearToDayDateFormatter"];
}

@end
