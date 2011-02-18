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

#pragma mark Cross reference matchers processing

- (void)testProcessObjectsFromStore_shouldAssignClassCrossRefsMatchers {
	// setup
	GBApplicationSettingsProvider *settings = [GBTestObjectsRegistry realSettingsProvider];
	GBProcessor *processor = [GBProcessor processorWithSettingsProvider:settings];
	GBMethodData *method1 = [GBTestObjectsRegistry instanceMethodWithNames:@"instMethod", nil];
	GBMethodData *method2 = [GBTestObjectsRegistry classMethodWithNames:@"clsMethod", nil];
	GBMethodData *method3 = [GBTestObjectsRegistry propertyMethodWithArgument:@"propMethod"];
	GBClassData *class = [GBTestObjectsRegistry classWithName:@"Class" methods:method1, method2, method3, nil];
	GBStore *store = [GBTestObjectsRegistry storeWithObjects:class, nil];
	// execute
	[processor processObjectsFromStore:store];
	// verify
	assertThat(class.localSimpleCrossRefRegex, is(@"(Class)"));
	assertThat(class.localTemplatedCrossRefRegex, is(@"<?(Class)>?"));
	assertThat(class.remoteSimpleCrossRefRegex, is(class.localSimpleCrossRefRegex));
	assertThat(class.remoteTemplatedCrossRefRegex, is(class.localTemplatedCrossRefRegex));
	assertThat(method1.localSimpleCrossRefRegex, is(@"([+-]?)(instMethod:)"));
	assertThat(method1.localTemplatedCrossRefRegex, is(@"<?([+-]?)(instMethod:)>?"));
	assertThat(method1.remoteSimpleCrossRefRegex, is(@"([+-]?)\\[(Class)\\s+(instMethod:)\\]"));
	assertThat(method1.remoteTemplatedCrossRefRegex, is(@"<?([+-]?)\\[(Class)\\s+(instMethod:)\\]>?"));
	assertThat(method2.localSimpleCrossRefRegex, is(@"([+-]?)(clsMethod:)"));
	assertThat(method2.localTemplatedCrossRefRegex, is(@"<?([+-]?)(clsMethod:)>?"));
	assertThat(method2.remoteSimpleCrossRefRegex, is(@"([+-]?)\\[(Class)\\s+(clsMethod:)\\]"));
	assertThat(method2.remoteTemplatedCrossRefRegex, is(@"<?([+-]?)\\[(Class)\\s+(clsMethod:)\\]>?"));
	assertThat(method3.localSimpleCrossRefRegex, is(@"([+-]?)(propMethod)"));
	assertThat(method3.localTemplatedCrossRefRegex, is(@"<?([+-]?)(propMethod)>?"));
	assertThat(method3.remoteSimpleCrossRefRegex, is(@"([+-]?)\\[(Class)\\s+(propMethod)\\]"));
	assertThat(method3.remoteTemplatedCrossRefRegex, is(@"<?([+-]?)\\[(Class)\\s+(propMethod)\\]>?"));
}

- (void)testProcessObjectsFromStore_shouldAssignCategoryCrossRefsMatchers {
	// setup
	GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBMethodData *method1 = [GBTestObjectsRegistry instanceMethodWithNames:@"instMethod", nil];
	GBMethodData *method2 = [GBTestObjectsRegistry classMethodWithNames:@"clsMethod", nil];
	GBMethodData *method3 = [GBTestObjectsRegistry propertyMethodWithArgument:@"propMethod"];
	GBCategoryData *category = [GBTestObjectsRegistry categoryWithName:@"Category" className:@"Class" methods:method1, method2, method3, nil];
	GBStore *store = [GBTestObjectsRegistry storeWithObjects:category, nil];
	// execute
	[processor processObjectsFromStore:store];
	// verify
	assertThat(category.localSimpleCrossRefRegex, is(@"(Class\\(Category\\))"));
	assertThat(category.localTemplatedCrossRefRegex, is(@"<?(Class\\(Category\\))>?"));
	assertThat(category.remoteSimpleCrossRefRegex, is(category.localSimpleCrossRefRegex));
	assertThat(category.remoteTemplatedCrossRefRegex, is(category.localTemplatedCrossRefRegex));
	assertThat(method1.localSimpleCrossRefRegex, is(@"([+-]?)(instMethod:)"));
	assertThat(method1.localTemplatedCrossRefRegex, is(@"<?([+-]?)(instMethod:)>?"));
	assertThat(method1.remoteSimpleCrossRefRegex, is(@"([+-]?)\\[(Class\\(Category\\))\\s+(instMethod:)\\]"));
	assertThat(method1.remoteTemplatedCrossRefRegex, is(@"<?([+-]?)\\[(Class\\(Category\\))\\s+(instMethod:)\\]>?"));
	assertThat(method2.localSimpleCrossRefRegex, is(@"([+-]?)(clsMethod:)"));
	assertThat(method2.localTemplatedCrossRefRegex, is(@"<?([+-]?)(clsMethod:)>?"));
	assertThat(method2.remoteSimpleCrossRefRegex, is(@"([+-]?)\\[(Class\\(Category\\))\\s+(clsMethod:)\\]"));
	assertThat(method2.remoteTemplatedCrossRefRegex, is(@"<?([+-]?)\\[(Class\\(Category\\))\\s+(clsMethod:)\\]>?"));
	assertThat(method3.localSimpleCrossRefRegex, is(@"([+-]?)(propMethod)"));
	assertThat(method3.localTemplatedCrossRefRegex, is(@"<?([+-]?)(propMethod)>?"));
	assertThat(method3.remoteSimpleCrossRefRegex, is(@"([+-]?)\\[(Class\\(Category\\))\\s+(propMethod)\\]"));
	assertThat(method3.remoteTemplatedCrossRefRegex, is(@"<?([+-]?)\\[(Class\\(Category\\))\\s+(propMethod)\\]>?"));
}

- (void)testProcessObjectsFromStore_shouldAssignProtocolCrossRefsMatchers {
	// setup
	GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBMethodData *method1 = [GBTestObjectsRegistry instanceMethodWithNames:@"instMethod", nil];
	GBMethodData *method2 = [GBTestObjectsRegistry classMethodWithNames:@"clsMethod", nil];
	GBMethodData *method3 = [GBTestObjectsRegistry propertyMethodWithArgument:@"propMethod"];
	GBProtocolData *protocol = [GBTestObjectsRegistry protocolWithName:@"Protocol" methods:method1, method2, method3, nil];
	GBStore *store = [GBTestObjectsRegistry storeWithObjects:protocol, nil];
	// execute
	[processor processObjectsFromStore:store];
	// verify
	assertThat(protocol.localSimpleCrossRefRegex, is(@"(Protocol)"));
	assertThat(protocol.localTemplatedCrossRefRegex, is(@"<?(Protocol)>?"));
	assertThat(protocol.remoteSimpleCrossRefRegex, is(protocol.localSimpleCrossRefRegex));
	assertThat(protocol.remoteTemplatedCrossRefRegex, is(protocol.localTemplatedCrossRefRegex));
	assertThat(method1.localSimpleCrossRefRegex, is(@"([+-]?)(instMethod:)"));
	assertThat(method1.localTemplatedCrossRefRegex, is(@"<?([+-]?)(instMethod:)>?"));
	assertThat(method1.remoteSimpleCrossRefRegex, is(@"([+-]?)\\[(Protocol)\\s+(instMethod:)\\]"));
	assertThat(method1.remoteTemplatedCrossRefRegex, is(@"<?([+-]?)\\[(Protocol)\\s+(instMethod:)\\]>?"));
	assertThat(method2.localSimpleCrossRefRegex, is(@"([+-]?)(clsMethod:)"));
	assertThat(method2.localTemplatedCrossRefRegex, is(@"<?([+-]?)(clsMethod:)>?"));
	assertThat(method2.remoteSimpleCrossRefRegex, is(@"([+-]?)\\[(Protocol)\\s+(clsMethod:)\\]"));
	assertThat(method2.remoteTemplatedCrossRefRegex, is(@"<?([+-]?)\\[(Protocol)\\s+(clsMethod:)\\]>?"));
	assertThat(method3.localSimpleCrossRefRegex, is(@"([+-]?)(propMethod)"));
	assertThat(method3.localTemplatedCrossRefRegex, is(@"<?([+-]?)(propMethod)>?"));
	assertThat(method3.remoteSimpleCrossRefRegex, is(@"([+-]?)\\[(Protocol)\\s+(propMethod)\\]"));
	assertThat(method3.remoteTemplatedCrossRefRegex, is(@"<?([+-]?)\\[(Protocol)\\s+(propMethod)\\]>?"));
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
