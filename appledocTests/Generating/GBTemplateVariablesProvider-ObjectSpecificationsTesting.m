//
//  GBTemplateVariablesProvider-ObjectSpecificationsTesting.m
//  appledocTests
//
//  Created by Jebeom Gyeong on 2/22/20.
//  Copyright © 2020 Gentle Bytes. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "GBApplicationSettingsProvider.h"
#import "GBHTMLTemplateVariablesProvider.h"
#import "GBTokenizer.h"
#import "GBTestObjectsRegistry.h"

@interface GBTemplateVariablesProvider_ObjectSpecificationsTesting : XCTestCase

@end

@implementation GBTemplateVariablesProvider_ObjectSpecificationsTesting

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

#pragma mark Inherits from

- (void)testVariablesForClass_inheritsFrom_shouldIgnoreSpecificationForRootClass {
    // setup
    GBHTMLTemplateVariablesProvider *provider = [GBHTMLTemplateVariablesProvider providerWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
    GBClassData *class = [GBClassData classDataWithName:@"Class"];
    // execute
    NSDictionary *vars = [provider variablesForClass:class withStore:[GBTestObjectsRegistry store]];
    NSArray *specifications = [vars valueForKeyPath:@"page.specifications.values"];
    // verify
    XCTAssertEqual([specifications count], 0);
}

- (void)testVariablesForClass_inheritsFrom_shouldPrepareSpecificationForUnknownSuperclass {
    // setup
    GBHTMLTemplateVariablesProvider *provider = [GBHTMLTemplateVariablesProvider providerWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
    GBClassData *class = [GBClassData classDataWithName:@"Class"];
    class.nameOfSuperclass = @"NSObject";
    // execute
    NSDictionary *vars = [provider variablesForClass:class withStore:[GBTestObjectsRegistry store]];
    NSArray *specifications = [vars valueForKeyPath:@"page.specifications.values"];
    // verify
    NSDictionary *specification = specifications[0];
    NSArray *values = specification[@"values"];
    XCTAssertEqual([values count], 1);
    XCTAssertEqualObjects([values[0] objectForKey:@"string"], @"NSObject");
    XCTAssertNil([values[0] objectForKey:@"href"]);
}

- (void)testVariablesForClass_inheritsFrom_shouldPrepareSpecificationForKnownSuperclass {
    // setup
    GBHTMLTemplateVariablesProvider *provider = [GBHTMLTemplateVariablesProvider providerWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
    GBClassData *superclass = [GBClassData classDataWithName:@"Base"];
    GBStore *store = [GBTestObjectsRegistry store];
    [store registerClass:superclass];
    GBClassData *class = [GBClassData classDataWithName:@"Class"];
    class.nameOfSuperclass = superclass.nameOfClass;
    class.superclass = superclass;
    // execute
    NSDictionary *vars = [provider variablesForClass:class withStore:store];
    NSArray *specifications = [vars valueForKeyPath:@"page.specifications.values"];
    // verify
    NSDictionary *specification = specifications[0];
    NSArray *values = specification[@"values"];
    XCTAssertEqual([values count], 1);
    XCTAssertEqualObjects([values[0] objectForKey:@"string"], @"Base");
    XCTAssertNotNil([values[0] objectForKey:@"href"]);
}

- (void)testVariablesForClass_inheritsFrom_shouldPrepareSpecificationForClassHierarchy {
    // setup
    GBHTMLTemplateVariablesProvider *provider = [GBHTMLTemplateVariablesProvider providerWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
    GBClassData *level2 = [GBClassData classDataWithName:@"Level2"];
    level2.nameOfSuperclass = @"NSObject";
    GBClassData *level1 = [GBClassData classDataWithName:@"Level1"];
    level1.nameOfSuperclass = level2.nameOfClass;
    level1.superclass = level2;
    GBClassData *class = [GBClassData classDataWithName:@"Class"];
    class.nameOfSuperclass = level1.nameOfClass;
    class.superclass = level1;
    GBStore *store = [GBTestObjectsRegistry store];
    [store registerClass:level1];
    [store registerClass:level2];
    // execute
    NSDictionary *vars = [provider variablesForClass:class withStore:store];
    NSArray *specifications = [vars valueForKeyPath:@"page.specifications.values"];
    // verify - note that href is created even if superclass is not registered to store as long as a superclass property is non-nil.
    NSDictionary *specification = specifications[0];
    NSArray *values = specification[@"values"];
    XCTAssertEqual([values count], 3);
    XCTAssertEqualObjects([values[0] objectForKey:@"string"], @"Level1");
    XCTAssertNotNil([values[0] objectForKey:@"href"]);
    XCTAssertEqualObjects([values[1] objectForKey:@"string"], @"Level2");
    XCTAssertNotNil([values[1] objectForKey:@"href"]);
    XCTAssertEqualObjects([values[2] objectForKey:@"string"], @"NSObject");
    XCTAssertNil([values[2] objectForKey:@"href"]);
}

#pragma mark Conforms to

- (void)testVariablesForClass_conformsTo_shouldIgnoreSpecificationForNonAdoptingClass {
    // setup
    GBHTMLTemplateVariablesProvider *provider = [GBHTMLTemplateVariablesProvider providerWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
    GBClassData *class = [GBClassData classDataWithName:@"Class"];
    // execute
    NSDictionary *vars = [provider variablesForClass:class withStore:[GBTestObjectsRegistry store]];
    NSArray *specifications = [vars valueForKeyPath:@"page.specifications.values"];
    // verify
    XCTAssertEqual([specifications count], 0);
}

- (void)testVariablesForClass_conformsTo_shouldPrepareSpecificationForUnknownProtocol {
    // setup
    GBHTMLTemplateVariablesProvider *provider = [GBHTMLTemplateVariablesProvider providerWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
    GBClassData *class = [GBClassData classDataWithName:@"Class"];
    [class.adoptedProtocols registerProtocol:[GBProtocolData protocolDataWithName:@"Protocol"]];
    // execute
    NSDictionary *vars = [provider variablesForClass:class withStore:[GBTestObjectsRegistry store]];
    NSArray *specifications = [vars valueForKeyPath:@"page.specifications.values"];
    // verify
    NSDictionary *specification = specifications[0];
    NSArray *values = specification[@"values"];
    XCTAssertEqual([values count], 1);
    XCTAssertEqualObjects([values[0] objectForKey:@"string"], @"Protocol");
    XCTAssertNil([values[0] objectForKey:@"href"]);
}

- (void)testVariablesForClass_conformsTo_shouldPrepareSpecificationForKnownProtocol {
    // setup
    GBHTMLTemplateVariablesProvider *provider = [GBHTMLTemplateVariablesProvider providerWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
    GBProtocolData *protocol = [GBProtocolData protocolDataWithName:@"Protocol"];
    GBStore *store = [GBTestObjectsRegistry store];
    [store registerProtocol:protocol];
    GBClassData *class = [GBClassData classDataWithName:@"Class"];
    [class.adoptedProtocols registerProtocol:protocol];
    // execute
    NSDictionary *vars = [provider variablesForClass:class withStore:store];
    NSArray *specifications = [vars valueForKeyPath:@"page.specifications.values"];
    // verify
    NSDictionary *specification = specifications[0];
    NSArray *values = specification[@"values"];
    XCTAssertEqual([values count], 1);
    XCTAssertEqualObjects([values[0] objectForKey:@"string"], @"Protocol");
    XCTAssertNotNil([values[0] objectForKey:@"href"]);
}

- (void)testVariablesForClass_conformsTo_shouldPrepareSpecificationForComplexProtocolsList {
    // setup
    GBHTMLTemplateVariablesProvider *provider = [GBHTMLTemplateVariablesProvider providerWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
    GBProtocolData *protocol1 = [GBProtocolData protocolDataWithName:@"Protocol1"];
    GBProtocolData *protocol2 = [GBProtocolData protocolDataWithName:@"Protocol2"];
    GBProtocolData *protocol3 = [GBProtocolData protocolDataWithName:@"Protocol3"];
    GBStore *store = [GBTestObjectsRegistry store];
    [store registerProtocol:protocol1];
    [store registerProtocol:protocol3];
    GBClassData *class = [GBClassData classDataWithName:@"Class"];
    [class.adoptedProtocols registerProtocol:protocol1];
    [class.adoptedProtocols registerProtocol:protocol2];
    [class.adoptedProtocols registerProtocol:protocol3];
    // execute
    NSDictionary *vars = [provider variablesForClass:class withStore:store];
    NSArray *specifications = [vars valueForKeyPath:@"page.specifications.values"];
    // verify
    NSDictionary *specification = specifications[0];
    NSArray *values = specification[@"values"];
    XCTAssertEqual([values count], 3);
    XCTAssertEqualObjects([values[0] objectForKey:@"string"], @"Protocol1");
    XCTAssertNotNil([values[0] objectForKey:@"href"]);
    XCTAssertEqualObjects([values[1] objectForKey:@"string"], @"Protocol2");
    XCTAssertNil([values[1] objectForKey:@"href"]);
    XCTAssertEqualObjects([values[2] objectForKey:@"string"], @"Protocol3");
    XCTAssertNotNil([values[2] objectForKey:@"href"]);
}

#pragma mark Declared in

- (void)testVariablesForClass_declaredIn_shouldPrepareSpecificationForSingleSourceInfo {
    // setup
    GBHTMLTemplateVariablesProvider *provider = [GBHTMLTemplateVariablesProvider providerWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
    GBClassData *class = [GBClassData classDataWithName:@"Class"];
    [class registerSourceInfo:[GBSourceInfo infoWithFilename:@"file.h" lineNumber:10]];
    // execute
    NSDictionary *vars = [provider variablesForClass:class withStore:[GBTestObjectsRegistry store]];
    NSArray *specifications = [vars valueForKeyPath:@"page.specifications.values"];
    // verify
    NSDictionary *specification = specifications[0];
    NSArray *values = specification[@"values"];
    XCTAssertEqual([values count], 1);
    XCTAssertEqualObjects([values[0] objectForKey:@"string"], @"file.h");
    XCTAssertNil([values[0] objectForKey:@"href"]);
}

- (void)testVariablesForClass_declaredIn_shouldPrepareSpecificationForMultipleSourceInfos {
    // setup
    GBHTMLTemplateVariablesProvider *provider = [GBHTMLTemplateVariablesProvider providerWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
    GBClassData *class = [GBClassData classDataWithName:@"Class"];
    [class registerSourceInfo:[GBSourceInfo infoWithFilename:@"file1.h" lineNumber:10]];
    [class registerSourceInfo:[GBSourceInfo infoWithFilename:@"file2.h" lineNumber:55]];
    // execute
    NSDictionary *vars = [provider variablesForClass:class withStore:[GBTestObjectsRegistry store]];
    NSArray *specifications = [vars valueForKeyPath:@"page.specifications.values"];
    // verify
    NSDictionary *specification = specifications[0];
    NSArray *values = specification[@"values"];
    XCTAssertEqual([values count], 2);
    XCTAssertEqualObjects([values[0] objectForKey:@"string"], @"file1.h");
    XCTAssertNil([values[0] objectForKey:@"href"]);
    XCTAssertEqualObjects([values[1] objectForKey:@"string"], @"file2.h");
    XCTAssertNil([values[1] objectForKey:@"href"]);
}

@end
