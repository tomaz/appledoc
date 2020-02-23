//
//  GBStoreTesting.m
//  appledocTests
//
//  Created by Jebeom Gyeong on 2/22/20.
//  Copyright © 2020 Gentle Bytes. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <OCMock/OCMockObject.h>

#import "GBStore.h"
#import "GBDataObjects.h"

@interface GBStoreTesting : XCTestCase

@end

@implementation GBStoreTesting

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

#pragma mark Class registration testing

- (void)testRegisterClass_shouldAddClassToList {
    // setup
    GBStore *store = [[GBStore alloc] init];
    GBClassData *class = [GBClassData classDataWithName:@"MyClass"];
    // execute
    [store registerClass:class];
    // verify
    XCTAssertTrue([store.classes containsObject:class]);
    XCTAssertEqual([[store.classes allObjects] count], 1);
    XCTAssertEqualObjects([store.classes allObjects][0], class);
}

- (void)testRegisterClass_shouldIgnoreSameInstance {
    // setup
    GBStore *store = [[GBStore alloc] init];
    GBClassData *class = [GBClassData classDataWithName:@"MyClass"];
    // execute
    [store registerClass:class];
    [store registerClass:class];
    // verify
    XCTAssertEqual([[store.classes allObjects] count], 1);
}

- (void)testRegisterClass_shouldMergeDataFromInstancesOfSameName {
    // setup - only basic stuff here, details are tested within GBClassDataTesting!
    GBStore *store = [[GBStore alloc] init];
    GBClassData *class2 = [GBClassData classDataWithName:@"MyClass"];
    OCMockObject *class1 = [OCMockObject niceMockForClass:[GBClassData class]];
    [[[class1 stub] andReturn:@"MyClass"] nameOfClass];
    [[class1 expect] mergeDataFromObject:class2];
    // execute
    [store registerClass:(GBClassData *)class1];
    [store registerClass:class2];
    // verify
    XCTAssertEqual([store.classes count], 1);
    [class1 verify];
}

- (void)testClassByName_shouldReturnProperInstanceOrNil {
    // setup
    GBStore *store = [[GBStore alloc] init];
    GBClassData *class1 = [GBClassData classDataWithName:@"Class1"];
    GBClassData *class2 = [GBClassData classDataWithName:@"Class2"];
    [store registerClass:class1];
    [store registerClass:class2];
    // execute & verify
    XCTAssertEqualObjects([store classWithName:@"Class1"], class1);
    XCTAssertEqualObjects([store classWithName:@"Class2"], class2);
    XCTAssertNil([store classWithName:@"Class3"]);
    XCTAssertNil([store classWithName:@""]);
    XCTAssertNil([store classWithName:nil]);
}

#pragma mark Category registration testing

- (void)testRegisterCategory_shouldAddCategoryToList {
    // setup
    GBStore *store = [[GBStore alloc] init];
    GBCategoryData *category = [GBCategoryData categoryDataWithName:@"MyCategory" className:@"MyClass"];
    // execute
    [store registerCategory:category];
    // verify
    XCTAssertTrue([store.categories containsObject:category]);
    XCTAssertEqual([[store.categories allObjects] count], 1);
    XCTAssertEqualObjects([store.categories allObjects][0], category);
}

- (void)testRegisterCategory_shouldIgnoreSameInstance {
    // setup
    GBStore *store = [[GBStore alloc] init];
    GBCategoryData *category = [GBCategoryData categoryDataWithName:@"MyCategory" className:@"MyClass"];
    // execute
    [store registerCategory:category];
    [store registerCategory:category];
    // verify
    XCTAssertEqual([[store.categories allObjects] count], 1);
}

- (void)testRegisterCategory_shouldPreventAddingDifferentInstanceWithSameName {
    // setup
    GBStore *store = [[GBStore alloc] init];
    GBCategoryData *category2 = [GBCategoryData categoryDataWithName:@"MyCategory" className:@"MyClass"];
    OCMockObject *category1 = [OCMockObject niceMockForClass:[GBCategoryData class]];
    [[[category1 stub] andReturn:@"MyClass"] nameOfClass];
    [[[category1 stub] andReturn:@"MyCategory"] nameOfCategory];
    [[category1 expect] mergeDataFromObject:category2];
    // execute
    [store registerCategory:(GBCategoryData *)category1];
    [store registerCategory:category2];
    // verify
    XCTAssertEqual([store.categories count], 1);
    [category1 verify];
}

- (void)testRegisterExtension_shouldAddExtensionToList {
    // setup
    GBStore *store = [[GBStore alloc] init];
    GBCategoryData *extension = [GBCategoryData categoryDataWithName:nil className:@"MyClass"];
    // execute
    [store registerCategory:extension];
    // verify
    XCTAssertTrue([store.categories containsObject:extension]);
    XCTAssertEqual([[store.categories allObjects] count], 1);
    XCTAssertEqualObjects([store.categories allObjects][0], extension);
}

- (void)testRegisterExtension_shouldIgnoreSameInstance {
    // setup
    GBStore *store = [[GBStore alloc] init];
    GBCategoryData *extension = [GBCategoryData categoryDataWithName:nil className:@"MyClass"];
    // execute
    [store registerCategory:extension];
    [store registerCategory:extension];
    // verify
    XCTAssertEqual([[store.categories allObjects] count], 1);
}

- (void)testRegisterExtension_shouldPreventAddingDifferentInstanceWithSameName {
    // setup
    GBStore *store = [[GBStore alloc] init];
    GBCategoryData *extension2 = [GBCategoryData categoryDataWithName:nil className:@"MyClass"];
    OCMockObject *extension1 = [OCMockObject niceMockForClass:[GBCategoryData class]];
    [[[extension1 stub] andReturn:@"MyClass"] nameOfClass];
    [[[extension1 stub] andReturn:nil] nameOfCategory];
    [[extension1 expect] mergeDataFromObject:extension2];
    // execute
    [store registerCategory:(GBCategoryData *)extension1];
    [store registerCategory:extension2];
    // verify
    XCTAssertEqual([store.categories count], 1);
    [extension1 verify];
}

- (void)testRegisterExtension_shouldAllowCategoryAndExtensionOfSameClass {
    // setup
    GBStore *store = [[GBStore alloc] init];
    GBCategoryData *category = [GBCategoryData categoryDataWithName:@"MyCategory" className:@"MyClass"];
    GBCategoryData *extension = [GBCategoryData categoryDataWithName:nil className:@"MyClass"];
    // execute
    [store registerCategory:category];
    [store registerCategory:extension];
    // execute & verify
    XCTAssertTrue([store.categories containsObject:category]);
    XCTAssertTrue([store.categories containsObject:extension]);
}

- (void)testCategoryByName_shouldReturnProperInstanceOrNil {
    // setup
    GBStore *store = [[GBStore alloc] init];
    GBCategoryData *category1 = [GBCategoryData categoryDataWithName:@"Category1" className:@"Class"];
    GBCategoryData *category2 = [GBCategoryData categoryDataWithName:@"Category2" className:@"Class"];
    GBCategoryData *extension = [GBCategoryData categoryDataWithName:nil className:@"Class"];
    [store registerCategory:category1];
    [store registerCategory:category2];
    [store registerCategory:extension];
    // execute & verify
    XCTAssertEqualObjects([store categoryWithName:@"Class(Category1)"], category1);
    XCTAssertEqualObjects([store categoryWithName:@"Class(Category2)"], category2);
    XCTAssertEqualObjects([store categoryWithName:@"Class()"], extension);
    XCTAssertNil([store categoryWithName:@"Class(Category3)"]);
    XCTAssertNil([store categoryWithName:@"Class1()"]);
    XCTAssertNil([store categoryWithName:@"()"]);
    XCTAssertNil([store categoryWithName:nil]);
}

#pragma mark Protocol registration testing

- (void)testRegisterProtocol_shouldAddProtocolToList {
    // setup
    GBStore *store = [[GBStore alloc] init];
    GBProtocolData *protocol = [GBProtocolData protocolDataWithName:@"MyProtocol"];
    // execute
    [store registerProtocol:protocol];
    // verify
    XCTAssertTrue([store.protocols containsObject:protocol]);
    XCTAssertEqual([[store.protocols allObjects] count], 1);
    XCTAssertEqualObjects([store.protocols allObjects][0], protocol);
}

- (void)testRegisterProtocol_shouldIgnoreSameInstance {
    // setup
    GBStore *store = [[GBStore alloc] init];
    GBProtocolData *protocol = [GBProtocolData protocolDataWithName:@"MyProtocol"];
    // execute
    [store registerProtocol:protocol];
    [store registerProtocol:protocol];
    // verify
    XCTAssertEqual([[store.protocols allObjects] count], 1);
}

- (void)testRegisterProtocol_shouldPreventAddingDifferentInstanceWithSameName {
    // setup
    GBStore *store = [[GBStore alloc] init];
    GBProtocolData *protocol2 = [GBProtocolData protocolDataWithName:@"MyProtocol"];
    OCMockObject *protocol1 = [OCMockObject niceMockForClass:[GBProtocolData class]];
    [[[protocol1 stub] andReturn:@"MyProtocol"] nameOfProtocol];
    [[protocol1 expect] mergeDataFromObject:protocol2];
    // execute
    [store registerProtocol:(GBProtocolData *)protocol1];
    [store registerProtocol:protocol2];
    // verify
    XCTAssertEqual([store.protocols count], 1);
    [protocol1 verify];
}

- (void)testProtocolByName_shouldReturnProperInstanceOrNil {
    // setup
    GBStore *store = [[GBStore alloc] init];
    GBProtocolData *protocol1 = [GBProtocolData protocolDataWithName:@"Protocol1"];
    GBProtocolData *protocol2 = [GBProtocolData protocolDataWithName:@"Protocol2"];
    [store registerProtocol:protocol1];
    [store registerProtocol:protocol2];
    // execute & verify
    XCTAssertEqualObjects([store protocolWithName:@"Protocol1"], protocol1);
    XCTAssertEqualObjects([store protocolWithName:@"Protocol2"], protocol2);
    XCTAssertNil([store protocolWithName:@"Protocol3"]);
    XCTAssertNil([store protocolWithName:@""]);
    XCTAssertNil([store protocolWithName:nil]);
}

#pragma mark Document registration testing

- (void)testRegisterDocument_shouldAddDocumentToList {
    // setup
    GBStore *store = [[GBStore alloc] init];
    GBDocumentData *document = [GBDocumentData documentDataWithContents:@"contents" path:@"path"];
    // execute
    [store registerDocument:document];
    // verify
    XCTAssertTrue([store.documents containsObject:document]);
    XCTAssertEqual([[store.documents allObjects] count], 1);
    XCTAssertEqualObjects([store.documents allObjects][0], document);
}

- (void)testRegisterDocument_shouldIgnoreSameInstance {
    // setup
    GBStore *store = [[GBStore alloc] init];
    GBDocumentData *document = [GBDocumentData documentDataWithContents:@"contents" path:@"path"];
    // execute
    [store registerDocument:document];
    [store registerDocument:document];
    // verify
    XCTAssertEqual([[store.documents allObjects] count], 1);
}

- (void)testDocumentWithName_shouldReturnProperInstanceOrNil {
    // setup
    GBStore *store = [[GBStore alloc] init];
    GBDocumentData *document1 = [GBDocumentData documentDataWithContents:@"contents" path:@"path1/document1.txt"];
    GBDocumentData *document2 = [GBDocumentData documentDataWithContents:@"contents" path:@"path2/document-template.txt"];
    [store registerDocument:document1];
    [store registerDocument:document2];
    // execute & verify
    XCTAssertEqualObjects([store documentWithName:@"document1"], document1);
    XCTAssertEqualObjects([store documentWithName:@"document-template"], document2);
    XCTAssertEqualObjects([store documentWithName:@"document"], document2);
    XCTAssertNil([store documentWithName:@"something"]);
    XCTAssertNil([store documentWithName:@""]);
    XCTAssertNil([store documentWithName:nil]);
}

#pragma mark Custom documents handling

- (void)testRegisterCustomDocumentWithKey_shouldAddDocumentToList {
    // setup
    GBStore *store = [[GBStore alloc] init];
    GBDocumentData *document = [GBDocumentData documentDataWithContents:@"contents" path:@"path"];
    // execute
    [store registerCustomDocument:document withKey:@"a"];
    // verify
    XCTAssertEqual([store.customDocuments count], 1);
    XCTAssertEqualObjects([store.customDocuments anyObject], document);
    XCTAssertEqualObjects([store customDocumentWithKey:@"a"], document);
}

- (void)testRegisterCustomDocumentWithKey_shouldOverwriteSameKey {
    // setup
    GBStore *store = [[GBStore alloc] init];
    GBDocumentData *document1 = [GBDocumentData documentDataWithContents:@"contents" path:@"path"];
    GBDocumentData *document2 = [GBDocumentData documentDataWithContents:@"contents" path:@"path"];
    [store registerCustomDocument:document1 withKey:@"a"];
    // execute
    [store registerCustomDocument:document2 withKey:@"a"];
    // verify
    XCTAssertEqualObjects([store customDocumentWithKey:@"a"], document2);
}

- (void)testRegisterCustomDocumentWithKey_shouldReturnProperInstanceOrNil {
    // setup
    GBStore *store = [[GBStore alloc] init];
    GBDocumentData *document1 = [GBDocumentData documentDataWithContents:@"contents" path:@"path"];
    GBDocumentData *document2 = [GBDocumentData documentDataWithContents:@"contents" path:@"path"];
    // execute
    [store registerCustomDocument:document1 withKey:@"a"];
    [store registerCustomDocument:document2 withKey:@"b"];
    // verify
    XCTAssertEqualObjects([store customDocumentWithKey:@"a"], document1);
    XCTAssertEqualObjects([store customDocumentWithKey:@"b"], document2);
    XCTAssertNil([store customDocumentWithKey:@"c"]);
}

#pragma mark Unregistration testing

- (void)testUnregisterTopLevelObject_shouldRemoveClass {
    // setup
    GBStore *store = [[GBStore alloc] init];
    [store registerCategory:[GBCategoryData categoryDataWithName:@"Category" className:@"Class"]];
    [store registerProtocol:[GBProtocolData protocolDataWithName:@"Protocol"]];
    GBClassData *class = [GBClassData classDataWithName:@"Class"];
    [store registerClass:class];
    // execute
    [store unregisterTopLevelObject:class];
    // verify
    XCTAssertEqual([store.classes count], 0);
    XCTAssertEqual([store.categories count], 1);
    XCTAssertEqual([store.protocols count], 1);
}

- (void)testUnregisterTopLevelObject_shouldRemoveCategory {
    // setup
    GBStore *store = [[GBStore alloc] init];
    [store registerClass:[GBClassData classDataWithName:@"Class"]];
    [store registerProtocol:[GBProtocolData protocolDataWithName:@"Protocol"]];
    GBCategoryData *category = [GBCategoryData categoryDataWithName:@"Category" className:@"Class"];
    [store registerCategory:category];
    // execute
    [store unregisterTopLevelObject:category];
    // verify
    XCTAssertEqual([store.categories count], 0);
    XCTAssertEqual([store.classes count], 1);
    XCTAssertEqual([store.protocols count], 1);
}

- (void)testUnregisterTopLevelObject_shouldRemoveProtocol {
    // setup
    GBStore *store = [[GBStore alloc] init];
    [store registerClass:[GBClassData classDataWithName:@"Class"]];
    [store registerCategory:[GBCategoryData categoryDataWithName:@"Category" className:@"Class"]];
    GBProtocolData *protocol = [GBProtocolData protocolDataWithName:@"Protocol"];
    [store registerProtocol:protocol];
    // execute
    [store unregisterTopLevelObject:protocol];
    // verify
    XCTAssertEqual([store.protocols count], 0);
    XCTAssertEqual([store.categories count], 1);
    XCTAssertEqual([store.classes count], 1);
}

- (void)testUnregisterTopLevelObject_shouldRemoveClassFromDictionary {
    // setup
    GBStore *store = [[GBStore alloc] init];
    GBClassData *class = [GBClassData classDataWithName:@"Class"];
    [store registerClass:class];
    // execute
    [store unregisterTopLevelObject:class];
    // verify
    XCTAssertNil([store classWithName:class.nameOfClass]);
}

- (void)testUnregisterTopLevelObject_shouldRemoveCategoryFromDictionary {
    // setup
    GBStore *store = [[GBStore alloc] init];
    GBCategoryData *category = [GBCategoryData categoryDataWithName:@"Category" className:@"Class"];
    [store registerCategory:category];
    // execute
    [store unregisterTopLevelObject:category];
    // verify
    XCTAssertNil([store categoryWithName:category.idOfCategory]);
}

- (void)testUnregisterTopLevelObject_shouldRemoveProtocolFromDictionary {
    // setup
    GBStore *store = [[GBStore alloc] init];
    GBProtocolData *protocol = [GBProtocolData protocolDataWithName:@"Protocol"];
    [store registerProtocol:protocol];
    // execute
    [store unregisterTopLevelObject:protocol];
    // verify
    XCTAssertNil([store protocolWithName:protocol.nameOfProtocol]);
}


@end
