//
//  GBProcessor-KnownObjectsTesting.m
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
#import "GBStore.h"
#import "GBProcessor.h"
#import "GBTestObjectsRegistry.h"

@interface GBProcessor_KnownObjectsTesting : XCTestCase

- (OCMockObject *)mockSettingsProvider;

@end

#pragma mark -

@implementation GBProcessor_KnownObjectsTesting

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

#pragma mark Adopted protocols handling

- (void)testProcessObjectsFromStore_shouldReplaceKnownClassAdoptedProtocolsWithProtocolsFromStore {
    // setup
    GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[self mockSettingsProvider]];
    GBProtocolData *realProtocol = [GBProtocolData protocolDataWithName:@"P1"];
    GBProtocolData *adoptedProtocol1 = [GBProtocolData protocolDataWithName:@"P1"];
    GBProtocolData *adoptedProtocol2 = [GBProtocolData protocolDataWithName:@"P2"];
    GBClassData *class = [GBClassData classDataWithName:@"Class"];
    [class.adoptedProtocols registerProtocol:adoptedProtocol1];
    [class.adoptedProtocols registerProtocol:adoptedProtocol2];
    GBStore *store = [[GBStore alloc] init];
    [store registerClass:class];
    [store registerProtocol:realProtocol];
    // execute
    [processor processObjectsFromStore:store];
    // verify
    NSArray *protocols = [class.adoptedProtocols protocolsSortedByName];
    XCTAssertEqual([protocols count],2);
    XCTAssertEqualObjects(protocols[0], realProtocol);
    XCTAssertEqualObjects(protocols[1], adoptedProtocol2);
}

- (void)testProcessObjectsFromStore_shouldReplaceKnownCategoryAdoptedProtocolsWithProtocolsFromStore {
    // setup
    GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[self mockSettingsProvider]];
    GBProtocolData *realProtocol = [GBProtocolData protocolDataWithName:@"P1"];
    GBProtocolData *adoptedProtocol1 = [GBProtocolData protocolDataWithName:@"P1"];
    GBProtocolData *adoptedProtocol2 = [GBProtocolData protocolDataWithName:@"P2"];
    GBCategoryData *category = [GBCategoryData categoryDataWithName:@"Category" className:@"Class"];
    [category.adoptedProtocols registerProtocol:adoptedProtocol1];
    [category.adoptedProtocols registerProtocol:adoptedProtocol2];
    GBStore *store = [[GBStore alloc] init];
    [store registerCategory:category];
    [store registerProtocol:realProtocol];
    // execute
    [processor processObjectsFromStore:store];
    // verify
    NSArray *protocols = [category.adoptedProtocols protocolsSortedByName];
    XCTAssertEqual([protocols count], 2);
    XCTAssertEqualObjects(protocols[0], realProtocol);
    XCTAssertEqualObjects(protocols[1], adoptedProtocol2);
}

- (void)testProcessObjectsFromStore_shouldReplaceKnownProtocolAdoptedProtocolsWithProtocolsFromStore {
    // setup
    GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[self mockSettingsProvider]];
    GBProtocolData *realProtocol = [GBProtocolData protocolDataWithName:@"P1"];
    GBProtocolData *adoptedProtocol1 = [GBProtocolData protocolDataWithName:@"P1"];
    GBProtocolData *adoptedProtocol2 = [GBProtocolData protocolDataWithName:@"P2"];
    GBProtocolData *protocol = [GBProtocolData protocolDataWithName:@"Protocol"];
    [protocol.adoptedProtocols registerProtocol:adoptedProtocol1];
    [protocol.adoptedProtocols registerProtocol:adoptedProtocol2];
    GBStore *store = [[GBStore alloc] init];
    [store registerProtocol:protocol];
    [store registerProtocol:realProtocol];
    // execute
    [processor processObjectsFromStore:store];
    // verify
    NSArray *protocols = [protocol.adoptedProtocols protocolsSortedByName];
    XCTAssertEqual([protocols count], 2);
    XCTAssertEqualObjects(protocols[0], realProtocol);
    XCTAssertEqualObjects(protocols[1], adoptedProtocol2);
}

#pragma mark Subclasses handling

- (void)testProcessObjectsFromStore_shouldSetupSubclassesWithKnownClassesFromStore {
    // setup
    GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[self mockSettingsProvider]];
    GBClassData *class1 = [GBClassData classDataWithName:@"Class1"];
    GBClassData *class2 = [GBClassData classDataWithName:@"Class2"];
    GBClassData *class3 = [GBClassData classDataWithName:@"Class3"];
    GBClassData *class4 = [GBClassData classDataWithName:@"Class4"];
    class3.nameOfSuperclass = @"Class2";
    class2.nameOfSuperclass = @"Class1";
    class1.nameOfSuperclass = @"NSObject";
    GBStore *store = [[GBStore alloc] init];
    [store registerClass:class1];
    [store registerClass:class2];
    [store registerClass:class3];
    [store registerClass:class4];
    // execute
    [processor processObjectsFromStore:store];
    // verify
    XCTAssertNil(class1.superclass);
    XCTAssertEqualObjects(class2.superclass, class1);
    XCTAssertEqualObjects(class3.superclass, class2);
    XCTAssertNil(class4.superclass);
}

#pragma mark Objects and methods references handling

- (void)testProcessObjectsFromStore_shouldAssignHtmlReferencesToClasses {
    // setup
    OCMockObject *settings = [self mockSettingsProvider];
    GBProcessor *processor = [GBProcessor processorWithSettingsProvider:settings];
    GBClassData *class1 = [GBClassData classDataWithName:@"Class1"];
    GBClassData *class2 = [GBClassData classDataWithName:@"Class2"];
    [[[settings expect] andReturn:@"#class1"] htmlReferenceForObject:class1 fromSource:class1];
    [[[settings expect] andReturn:@"#class2"] htmlReferenceForObject:class2 fromSource:class2];
    [[[settings expect] andReturn:@"class1"] htmlReferenceNameForObject:class1];
    [[[settings expect] andReturn:@"class2"] htmlReferenceNameForObject:class2];
    GBStore *store = [[GBStore alloc] init];
    [store registerClass:class1];
    [store registerClass:class2];
    // execute
    [processor processObjectsFromStore:store];
    // verify
    XCTAssertEqualObjects(class1.htmlLocalReference, @"#class1");
    XCTAssertEqualObjects(class2.htmlLocalReference, @"#class2");
    XCTAssertEqualObjects(class1.htmlReferenceName, @"class1");
    XCTAssertEqualObjects(class2.htmlReferenceName, @"class2");
}

- (void)testProcessObjectsFromStore_shouldAssignHtmlReferencesToCategories {
    // setup
    OCMockObject *settings = [self mockSettingsProvider];
    GBProcessor *processor = [GBProcessor processorWithSettingsProvider:settings];
    GBCategoryData *category1 = [GBCategoryData categoryDataWithName:@"Category1" className:@"Class"];
    GBCategoryData *category2 = [GBCategoryData categoryDataWithName:@"Category2" className:@"Class"];
    [[[settings expect] andReturn:@"#category1"] htmlReferenceForObject:category1 fromSource:category1];
    [[[settings expect] andReturn:@"#category2"] htmlReferenceForObject:category2 fromSource:category2];
    [[[settings expect] andReturn:@"category1"] htmlReferenceNameForObject:category1];
    [[[settings expect] andReturn:@"category2"] htmlReferenceNameForObject:category2];
    GBStore *store = [[GBStore alloc] init];
    [store registerCategory:category1];
    [store registerCategory:category2];
    // execute
    [processor processObjectsFromStore:store];
    // verify
    XCTAssertEqualObjects(category1.htmlLocalReference, @"#category1");
    XCTAssertEqualObjects(category2.htmlLocalReference, @"#category2");
    XCTAssertEqualObjects(category1.htmlReferenceName, @"category1");
    XCTAssertEqualObjects(category2.htmlReferenceName, @"category2");
}

- (void)testProcessObjectsFromStore_shouldAssignHtmlReferencesToExtensions {
    // setup
    OCMockObject *settings = [self mockSettingsProvider];
    GBProcessor *processor = [GBProcessor processorWithSettingsProvider:settings];
    GBCategoryData *category1 = [GBCategoryData categoryDataWithName:nil className:@"Class1"];
    GBCategoryData *category2 = [GBCategoryData categoryDataWithName:nil className:@"Class2"];
    [[[settings expect] andReturn:@"#category1"] htmlReferenceForObject:category1 fromSource:category1];
    [[[settings expect] andReturn:@"#category2"] htmlReferenceForObject:category2 fromSource:category2];
    [[[settings expect] andReturn:@"category1"] htmlReferenceNameForObject:category1];
    [[[settings expect] andReturn:@"category2"] htmlReferenceNameForObject:category2];
    GBStore *store = [[GBStore alloc] init];
    [store registerCategory:category1];
    [store registerCategory:category2];
    // execute
    [processor processObjectsFromStore:store];
    // verify
    XCTAssertEqualObjects(category1.htmlLocalReference, @"#category1");
    XCTAssertEqualObjects(category2.htmlLocalReference, @"#category2");
    XCTAssertEqualObjects(category1.htmlReferenceName, @"category1");
    XCTAssertEqualObjects(category2.htmlReferenceName, @"category2");
}

- (void)testProcessObjectsFromStore_shouldAssignHtmlReferencesToProtocols {
    // setup
    OCMockObject *settings = [self mockSettingsProvider];
    GBProcessor *processor = [GBProcessor processorWithSettingsProvider:settings];
    GBProtocolData *protocol1 = [GBProtocolData protocolDataWithName:@"Protocol1"];
    GBProtocolData *protocol2 = [GBProtocolData protocolDataWithName:@"Protocol2"];
    [[[settings expect] andReturn:@"#protocol1"] htmlReferenceForObject:protocol1 fromSource:protocol1];
    [[[settings expect] andReturn:@"#protocol2"] htmlReferenceForObject:protocol2 fromSource:protocol2];
    [[[settings expect] andReturn:@"protocol1"] htmlReferenceNameForObject:protocol1];
    [[[settings expect] andReturn:@"protocol2"] htmlReferenceNameForObject:protocol2];
    GBStore *store = [[GBStore alloc] init];
    [store registerProtocol:protocol1];
    [store registerProtocol:protocol2];
    // execute
    [processor processObjectsFromStore:store];
    // verify
    XCTAssertEqualObjects(protocol1.htmlLocalReference, @"#protocol1");
    XCTAssertEqualObjects(protocol2.htmlLocalReference, @"#protocol2");
    XCTAssertEqualObjects(protocol1.htmlReferenceName, @"protocol1");
    XCTAssertEqualObjects(protocol2.htmlReferenceName, @"protocol2");
}

- (void)testProcessObjectsFromStore_shouldAssignHtmlReferencesToMethods {
    // setup
    OCMockObject *settings = [self mockSettingsProvider];
    GBProcessor *processor = [GBProcessor processorWithSettingsProvider:settings];
    GBMethodData *method1 = [GBTestObjectsRegistry classMethodWithNames:@"method1", nil];
    GBMethodData *method2 = [GBTestObjectsRegistry instanceMethodWithNames:@"method2", nil];
    GBMethodData *property = [GBTestObjectsRegistry propertyMethodWithArgument:@"value"];
    [[[settings expect] andReturn:@"#method1"] htmlReferenceForObject:method1 fromSource:OCMOCK_ANY];
    [[[settings expect] andReturn:@"#method2"] htmlReferenceForObject:method2 fromSource:OCMOCK_ANY];
    [[[settings expect] andReturn:@"#property"] htmlReferenceForObject:property fromSource:OCMOCK_ANY];
    [[[settings expect] andReturn:@"method1"] htmlReferenceNameForObject:method1];
    [[[settings expect] andReturn:@"method2"] htmlReferenceNameForObject:method2];
    [[[settings expect] andReturn:@"property"] htmlReferenceNameForObject:property];
    GBClassData *class = [GBClassData classDataWithName:@"Class"];
    [class.methods registerMethod:method1];
    [class.methods registerMethod:method2];
    [class.methods registerMethod:property];
    GBStore *store = [[GBStore alloc] init];
    [store registerClass:class];
    // execute
    [processor processObjectsFromStore:store];
    // verify
    XCTAssertEqualObjects(method1.htmlLocalReference, @"#method1");
    XCTAssertEqualObjects(method2.htmlLocalReference, @"#method2");
    XCTAssertEqualObjects(property.htmlLocalReference, @"#property");
    XCTAssertEqualObjects(method1.htmlReferenceName, @"method1");
    XCTAssertEqualObjects(method2.htmlReferenceName, @"method2");
    XCTAssertEqualObjects(property.htmlReferenceName, @"property");
}

#pragma mark Creation methods

- (OCMockObject *)mockSettingsProvider {
    OCMockObject *result = [GBTestObjectsRegistry mockSettingsProvider];
    [GBTestObjectsRegistry settingsProvider:result keepObjects:YES keepMembers:YES];
    return result;
}

@end
