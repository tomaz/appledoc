//
//  GBProcessor-CommentsTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 27.8.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBApplicationSettingsProvider.h"
#import "GBDataObjects.h"
#import "GBStore.h"
#import "GBProcessor.h"

@interface GBProcessorCommentsTesting : GHTestCase

- (OCMockObject *)mockSettingsProviderKeepObject:(BOOL)objects members:(BOOL)members;
- (OCMockObject *)mockSettingsProviderRepeatFirst:(BOOL)repeat;
- (OCMockObject *)niceCommentMockExpectingRegisterParagraph;
- (GBStore *)storeWithMethodWithComment:(GBComment *)comment;

@end

#pragma mark -

@implementation GBProcessorCommentsTesting

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
	GBStore *store = [GBTestObjectsRegistry storeByPerformingSelector:@selector(registerClass:) withObject:class];
	// execute
	[processor processObjectsFromStore:store];
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
	assertThat([[store.classes anyObject] comment], is(nil));
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
	GBStore *store = [GBTestObjectsRegistry storeByPerformingSelector:@selector(registerCategory:) withObject:category];
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
	assertThat([[store.categories anyObject] comment], is(nil));
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
	GBStore *store = [GBTestObjectsRegistry storeByPerformingSelector:@selector(registerProtocol:) withObject:protocol];
	// execute
	[processor processObjectsFromStore:store];
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
	assertThat([[store.protocols anyObject] comment], is(nil));
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
	assertThat([[store.documents anyObject] comment], is(nil));
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
	GBStore *store = [GBTestObjectsRegistry storeByPerformingSelector:@selector(registerClass:) withObject:class];
	// execute
	[processor processObjectsFromStore:store];
	// verify
	assertThat(method.comment, is(nil));
}

#pragma mark Creation methods

- (OCMockObject *)mockSettingsProviderKeepObject:(BOOL)objects members:(BOOL)members {
	OCMockObject *result = [GBTestObjectsRegistry mockSettingsProvider];
	[GBTestObjectsRegistry settingsProvider:result keepObjects:objects keepMembers:members];
	return result;
}

- (OCMockObject *)mockSettingsProviderRepeatFirst:(BOOL)repeat {
	OCMockObject *result = [GBTestObjectsRegistry mockSettingsProvider];
	[[[result stub] andReturnValue:[NSNumber numberWithBool:repeat]] repeatFirstParagraphForMemberDescription];
	return result;
}

- (OCMockObject *)niceCommentMockExpectingRegisterParagraph {
	OCMockObject *result = [OCMockObject niceMockForClass:[GBComment class]];
	[[[result stub] andReturn:@"Paragraph"] stringValue];
	//	[[result expect] registerParagraph:OCMOCK_ANY];
	return result;
}

- (GBStore *)storeWithMethodWithComment:(GBComment *)comment {
	GBClassData *class = [GBClassData classDataWithName:@"Class"];
	GBMethodData *method = [GBTestObjectsRegistry propertyMethodWithArgument:@"val"];
	[method setComment:comment];
	[class.methods registerMethod:method];
	GBStore *result = [GBTestObjectsRegistry storeByPerformingSelector:@selector(registerClass:) withObject:class];
	return result;
}

@end
