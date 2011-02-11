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

- (void)testProcesObjectsFromStore_shouldMatchParameterDirectivesWithActualOrder {
	// setup
	GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"@param arg2 Description2\n@param arg3 Description3\n@param arg1 Description1"];
	GBClassData *class = [GBClassData classDataWithName:@"Class"];
	GBMethodData *method = [GBTestObjectsRegistry instanceMethodWithNames:@"arg1", @"arg2", @"arg3", nil];
	[method setComment:comment];
	[class.methods registerMethod:method];
	GBStore *store = [GBTestObjectsRegistry storeByPerformingSelector:@selector(registerClass:) withObject:class];
	// execute
	[processor processObjectsFromStore:store];
	// verify
	assertThatInteger([comment.parameters count], equalToInteger(3));
	assertThat([[comment.parameters objectAtIndex:0] argumentName], is(@"arg1"));
	assertThat([[comment.parameters objectAtIndex:1] argumentName], is(@"arg2"));
	assertThat([[comment.parameters objectAtIndex:2] argumentName], is(@"arg3"));
	assertThat([[[comment.parameters objectAtIndex:0] argumentDescription] stringValue], is(@"Description1"));
	assertThat([[[comment.parameters objectAtIndex:1] argumentDescription] stringValue], is(@"Description2"));
	assertThat([[[comment.parameters objectAtIndex:2] argumentDescription] stringValue], is(@"Description3"));
}

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

#pragma mark Short description handling

- (void)testProcessObjectsFromStore_shortDescription_shouldUseWholeFirstParagraphIfItContainsTextItemsOnly {
	// setup
	GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"Some text"];
	GBStore *store = [self storeWithMethodWithComment:comment];
	// execute
	[processor processObjectsFromStore:store];
	// verify
	NSArray *items = comment.shortDescription.paragraphItems;
	assertThatInteger([items count], equalToInteger(1));
	assertThat([[items firstObject] stringValue], is(@"Some text"));
}

- (void)testProcessObjectsFromStore_shortDescription_shouldUseTextItemsUpToFirstWarningBlock {
	// setup
	GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"Some text\n\n@warning Warning"];
	GBStore *store = [self storeWithMethodWithComment:comment];
	// execute
	[processor processObjectsFromStore:store];
	// verify
	NSArray *items = comment.shortDescription.paragraphItems;
	assertThatInteger([items count], equalToInteger(1));
	assertThat([[items firstObject] stringValue], is(@"Some text"));
}

- (void)testProcessObjectsFromStore_shortDescription_shouldUseTextItemsUpToFirstBugBlock {
	// setup
	GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"Some text\n\n@bug Bug"];
	GBStore *store = [self storeWithMethodWithComment:comment];
	// execute
	[processor processObjectsFromStore:store];
	// verify
	NSArray *items = comment.shortDescription.paragraphItems;
	assertThatInteger([items count], equalToInteger(1));
	assertThat([[items firstObject] stringValue], is(@"Some text"));
}

- (void)testProcessObjectsFromStore_shortDescription_shouldUseTextItemsUpToFirstExampleBlock {
	// setup
	GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"Some text\n\n\tItem"];
	GBStore *store = [self storeWithMethodWithComment:comment];
	// execute
	[processor processObjectsFromStore:store];
	// verify
	NSArray *items = comment.shortDescription.paragraphItems;
	assertThatInteger([items count], equalToInteger(1));
	assertThat([[items firstObject] stringValue], is(@"Some text"));
}

- (void)testProcessObjectsFromStore_shortDescription_shouldUseTextItemsUpToFirstUnorderedListBlock {
	// setup
	GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"Some text\n\n- Item"];
	GBStore *store = [self storeWithMethodWithComment:comment];
	// execute
	[processor processObjectsFromStore:store];
	// verify
	NSArray *items = comment.shortDescription.paragraphItems;
	assertThatInteger([items count], equalToInteger(1));
	assertThat([[items firstObject] stringValue], is(@"Some text"));
}

- (void)testProcessObjectsFromStore_shortDescription_shouldUseTextItemsUpToFirstOrderedListBlock {
	// setup
	GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"Some text\n\n1. Item"];
	GBStore *store = [self storeWithMethodWithComment:comment];
	// execute
	[processor processObjectsFromStore:store];
	// verify
	NSArray *items = comment.shortDescription.paragraphItems;
	assertThatInteger([items count], equalToInteger(1));
	assertThat([[items firstObject] stringValue], is(@"Some text"));
}

#pragma mark Description paragraphs processing

- (void)testProcessObjectsFromStore_descriptionParagraphs_repeat_shouldUseAllParagraphsIfMultipleParagraphsFound {
	// setup
	GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[self mockSettingsProviderRepeatFirst:YES]];
	GBComment *comment = [GBComment commentWithStringValue:@"Par1\n\nPar2"];
	GBClassData *class = [GBClassData classDataWithName:@"Class"];
	GBMethodData *method = [GBTestObjectsRegistry propertyMethodWithArgument:@"val"];
	[method setComment:comment];
	[class.methods registerMethod:method];
	GBStore *store = [GBTestObjectsRegistry storeByPerformingSelector:@selector(registerClass:) withObject:class];
	// execute
	[processor processObjectsFromStore:store];
	// verify
	assertThatInteger([comment.descriptionParagraphs count], equalToInteger(2));
	assertThat([[comment.descriptionParagraphs objectAtIndex:0] stringValue], is(@"Par1"));
	assertThat([[comment.descriptionParagraphs objectAtIndex:1] stringValue], is(@"Par2"));
}

- (void)testProcessObjectsFromStore_descriptionParagraphs_repeat_shouldUseNoParagraphIfOnlyOneParagraphIsFound {
	// setup
	GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[self mockSettingsProviderRepeatFirst:YES]];
	GBComment *comment = [GBComment commentWithStringValue:@"Par1"];
	GBClassData *class = [GBClassData classDataWithName:@"Class"];
	GBMethodData *method = [GBTestObjectsRegistry propertyMethodWithArgument:@"val"];
	[method setComment:comment];
	[class.methods registerMethod:method];
	GBStore *store = [GBTestObjectsRegistry storeByPerformingSelector:@selector(registerClass:) withObject:class];
	// execute
	[processor processObjectsFromStore:store];
	// verify
	assertThat(comment.descriptionParagraphs, is(nil));
}

- (void)testProcessObjectsFromStore_descriptionParagraphs_noRepeat_shouldIgnoreFirstParIfMultipleParagraphsFound {
	// setup
	GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[self mockSettingsProviderRepeatFirst:NO]];
	GBComment *comment = [GBComment commentWithStringValue:@"Par1\n\nPar2"];
	GBClassData *class = [GBClassData classDataWithName:@"Class"];
	GBMethodData *method = [GBTestObjectsRegistry propertyMethodWithArgument:@"val"];
	[method setComment:comment];
	[class.methods registerMethod:method];
	GBStore *store = [GBTestObjectsRegistry storeByPerformingSelector:@selector(registerClass:) withObject:class];
	// execute
	[processor processObjectsFromStore:store];
	// verify
	assertThatInteger([comment.descriptionParagraphs count], equalToInteger(1));
	assertThat([[comment.descriptionParagraphs objectAtIndex:0] stringValue], is(@"Par2"));
}

- (void)testProcessObjectsFromStore_descriptionParagraphs_noRepeat_shouldUseNoParagraphIfOnlyOneParagraphIsFound {
	// setup
	GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[self mockSettingsProviderRepeatFirst:NO]];
	GBComment *comment = [GBComment commentWithStringValue:@"Par1"];
	GBClassData *class = [GBClassData classDataWithName:@"Class"];
	GBMethodData *method = [GBTestObjectsRegistry propertyMethodWithArgument:@"val"];
	[method setComment:comment];
	[class.methods registerMethod:method];
	GBStore *store = [GBTestObjectsRegistry storeByPerformingSelector:@selector(registerClass:) withObject:class];
	// execute
	[processor processObjectsFromStore:store];
	// verify
	assertThat(comment.descriptionParagraphs, is(nil));
}

- (void)testProcessObjectsFromStore_descriptionParagraphs_noRepeat_shouldRepeatFirstParagraphItemsNotUsedInShortDescription {
	// setup - we just test for a single option; as they are all handled the same, it would just be repeating; we do test all possible short description "delimiters" above, so hopefully these combined should catch most of the cases.
	GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[self mockSettingsProviderRepeatFirst:NO]];
	GBComment *comment = [GBComment commentWithStringValue:@"Some text\n\n@warning Warning"];
	GBStore *store = [self storeWithMethodWithComment:comment];
	// execute
	[processor processObjectsFromStore:store];
	// verify
	assertThatInteger([comment.descriptionParagraphs count], equalToInteger(1));
	assertThat([[comment.descriptionParagraphs objectAtIndex:0] stringValue], is(@"@warning Warning"));
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
	[[result expect] registerParagraph:OCMOCK_ANY];
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
