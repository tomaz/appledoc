//
//  GBProcessor-CommentsTesting.m
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

@interface GBProcessor_CommentsTesting : XCTestCase

- (OCMockObject *)mockSettingsProviderKeepObject:(BOOL)objects members:(BOOL)members;
- (OCMockObject *)mockSettingsProviderRepeatFirst:(BOOL)repeat;
- (OCMockObject *)niceCommentMockExpectingRegisterParagraph;
- (GBStore *)storeWithMethodWithComment:(GBComment *)comment;

@end

#pragma mark -

@implementation GBProcessor_CommentsTesting

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

#pragma mark Classes comments processing

- (void)testProcessObjectsFromStore_shouldProcessClassComments {
    // setup
    GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    OCMockObject *comment = [self niceCommentMockExpectingRegisterParagraph];
    GBStore *store = [GBTestObjectsRegistry storeWithClassWithComment:comment];
    // execute
    [processor processObjectsFromStore:store];
    // verify - we just want to make sure we invoke comments processing!
    [comment verify];
}

- (void)testProcessObjectsFromStore_shouldProcessClassMethodComments {
    // setup
    GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    OCMockObject *comment1 = [self niceCommentMockExpectingRegisterParagraph];
    OCMockObject *comment2 = [self niceCommentMockExpectingRegisterParagraph];
    GBClassData *class = [GBClassData classDataWithName:@"Class"];
    [class.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithName:@"method1" comment:comment1]];
    [class.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithName:@"method2" comment:comment2]];
    GBStore *store = [GBTestObjectsRegistry store];
    [store registerClass:class];
    // execute
    [processor processObjectsFromStore:store]; // TODO: FIXIT.
    // verify - we just want to make sure we invoke comments processing!
    [comment1 verify];
    [comment2 verify];
}

- (void)testProcessObjectsFromStore_shouldSetEmptyClassCommentToNil {
    // setup
    GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[self mockSettingsProviderKeepObject:YES members:YES]];
    GBComment *comment = [GBComment commentWithStringValue:nil];
    GBStore *store = [GBTestObjectsRegistry storeWithClassWithComment:comment];
    // execute
    [processor processObjectsFromStore:store];
    // verify
    XCTAssertNil([[store.classes anyObject] comment]);
}

#pragma mark Categories comments processing

- (void)testProcessObjectsFromStore_shouldProcessCategoryComments {
    // setup
    GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    OCMockObject *comment = [self niceCommentMockExpectingRegisterParagraph];
    GBStore *store = [GBTestObjectsRegistry storeWithCategoryWithComment:comment];
    // execute
    [processor processObjectsFromStore:store];
    // verify - we just want to make sure we invoke comments processing!
    [comment verify];
}

- (void)testProcessObjectsFromStore_shouldProcessCategoryMethodComments {
    // setup
    GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    OCMockObject *comment1 = [self niceCommentMockExpectingRegisterParagraph];
    OCMockObject *comment2 = [self niceCommentMockExpectingRegisterParagraph];
    GBCategoryData *category = [GBCategoryData categoryDataWithName:@"Category" className:@"Class"];
    [category.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithName:@"method1" comment:comment1]];
    [category.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithName:@"method2" comment:comment2]];
    GBStore *store = [GBTestObjectsRegistry store];
    [store registerCategory:category];
    // execute
    [processor processObjectsFromStore:store];
    // verify - we just want to make sure we invoke comments processing!
    [comment1 verify];
    [comment2 verify];
}

- (void)testProcessObjectsFromStore_shouldSetEmptyCategoryCommentToNil {
    // setup
    GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[self mockSettingsProviderKeepObject:YES members:YES]];
    GBComment *comment = [GBComment commentWithStringValue:nil];
    GBStore *store = [GBTestObjectsRegistry storeWithCategoryWithComment:comment];
    // execute
    [processor processObjectsFromStore:store];
    // verify
    XCTAssertNil([[store.categories anyObject] comment]);
}

#pragma mark Protocols comments processing

- (void)testProcessObjectsFromStore_shouldProcessProtocolComments {
    // setup
    GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    OCMockObject *comment = [self niceCommentMockExpectingRegisterParagraph];
    GBStore *store = [GBTestObjectsRegistry storeWithProtocolWithComment:comment];
    // execute
    [processor processObjectsFromStore:store];
    // verify - we just want to make sure we invoke comments processing!
    [comment verify];
}

- (void)testProcessObjectsFromStore_shouldProcessProtocolMethodComments {
    // setup
    GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    OCMockObject *comment1 = [self niceCommentMockExpectingRegisterParagraph];
    OCMockObject *comment2 = [self niceCommentMockExpectingRegisterParagraph];
    GBProtocolData *protocol = [GBProtocolData protocolDataWithName:@"Protocol"];
    [protocol.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithName:@"method1" comment:comment1]];
    [protocol.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithName:@"method2" comment:comment2]];
    GBStore *store = [GBTestObjectsRegistry store];
    [store registerProtocol:protocol];
    // execute
    [processor processObjectsFromStore:store]; // TODO: FIXIT.
    // verify - we just want to make sure we invoke comments processing!
    [comment1 verify];
    [comment2 verify];
}

- (void)testProcessObjectsFromStore_shouldSetEmptyProtocolCommentToNil {
    // setup
    GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[self mockSettingsProviderKeepObject:YES members:YES]];
    GBComment *comment = [GBComment commentWithStringValue:nil];
    GBStore *store = [GBTestObjectsRegistry storeWithProtocolWithComment:comment];
    // execute
    [processor processObjectsFromStore:store];
    // verify
    XCTAssertNil([[store.protocols anyObject] comment]);
}

#pragma mark Document comments processing

- (void)testProcessObjectsFromStore_shouldProcessDocumentComments {
    // setup
    GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    OCMockObject *comment = [self niceCommentMockExpectingRegisterParagraph];
    GBStore *store = [GBTestObjectsRegistry storeWithDocumentWithComment:comment];
    // execute
    [processor processObjectsFromStore:store];
    // verify - we just want to make sure we invoke comments processing!
    [comment verify];
}

- (void)testProcessObjectsFromStore_shouldSetEmptyDocumentCommentToNil {
    // setup
    GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[self mockSettingsProviderKeepObject:YES members:YES]];
    GBComment *comment = [GBComment commentWithStringValue:nil];
    GBStore *store = [GBTestObjectsRegistry storeWithDocumentWithComment:comment];
    // execute
    [processor processObjectsFromStore:store];
    // verify
    XCTAssertNil([[store.documents anyObject] comment]);
}

#pragma mark Method comment processing

- (void)testProcessObjectsFromStore_shouldSetEmptyMethodCommentToNil {
    // setup
    GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[self mockSettingsProviderKeepObject:YES members:YES]];
    GBComment *comment = [GBComment commentWithStringValue:nil];
    GBClassData *class = [GBClassData classDataWithName:@"Class"];
    GBMethodData *method = [GBTestObjectsRegistry instanceMethodWithNames:@"arg1", @"arg2", @"arg3", nil];
    [method setComment:comment];
    [class.methods registerMethod:method];
    GBStore *store = [GBTestObjectsRegistry store];
    [store registerClass:class];
    // execute
    [processor processObjectsFromStore:store];
    // verify
    XCTAssertNil(method.comment);
}

#pragma mark Creation methods

- (OCMockObject *)mockSettingsProviderKeepObject:(BOOL)objects members:(BOOL)members {
    OCMockObject *result = [GBTestObjectsRegistry mockSettingsProvider];
    [GBTestObjectsRegistry settingsProvider:result keepObjects:objects keepMembers:members];
    return result;
}

- (OCMockObject *)mockSettingsProviderRepeatFirst:(BOOL)repeat {
    OCMockObject *result = [GBTestObjectsRegistry mockSettingsProvider];
    [[[result stub] andReturnValue:@(repeat)] repeatFirstParagraphForMemberDescription];
    return result;
}

- (OCMockObject *)niceCommentMockExpectingRegisterParagraph {
    OCMockObject *result = [OCMockObject niceMockForClass:[GBComment class]];
    [[[result stub] andReturn:@"Paragraph"] stringValue];
//        [[result expect] registerParagraph:OCMOCK_ANY];
    return result;
}

- (GBStore *)storeWithMethodWithComment:(GBComment *)comment {
    GBClassData *class = [GBClassData classDataWithName:@"Class"];
    GBMethodData *method = [GBTestObjectsRegistry propertyMethodWithArgument:@"val"];
    [method setComment:comment];
    [class.methods registerMethod:method];
    GBStore *store = [GBTestObjectsRegistry store];
    [store registerClass:class];
    return store;
}

@end
