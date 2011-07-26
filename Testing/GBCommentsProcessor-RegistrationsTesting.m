//
//  GBCommentsProcessor-RegistrationsTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 14.2.11.
//  Copyright (C) 2011 Gentle Bytes. All rights reserved.
//

#import "GBApplicationSettingsProvider.h"
#import "GBDataObjects.h"
#import "GBStore.h"
#import "GBCommentsProcessor.h"

@interface GBCommentsProcessor (PrivateAPI)
- (BOOL)findCommentBlockInLines:(NSArray *)lines blockRange:(NSRange *)range shortRange:(NSRange *)shortRange;
@end

#pragma mark -

@interface GBCommentsProcessorRegistrationsTesting : GBObjectsAssertor

- (OCMockObject *)settingsProviderRepeatFirst:(BOOL)repeat;
- (void)assertFindCommentWithString:(NSString *)string matchesBlockRange:(NSRange)b shortRange:(NSRange)s;

@end

#pragma mark -

@implementation GBCommentsProcessorRegistrationsTesting

#pragma mark Short & long descriptions testing

- (void)testProcessCommentWithContextStore_descriptions_shouldHandleTextOnlyBasedOnSettings {
	// setup
	GBStore *store = [GBTestObjectsRegistry store];
	GBCommentsProcessor *processor1 = [GBCommentsProcessor processorWithSettingsProvider:[self settingsProviderRepeatFirst:YES]];
	GBCommentsProcessor *processor2 = [GBCommentsProcessor processorWithSettingsProvider:[self settingsProviderRepeatFirst:NO]];
	GBComment *comment1 = [GBComment commentWithStringValue:@"Some text\n\nAnother paragraph"];
	GBComment *comment2 = [GBComment commentWithStringValue:comment1.stringValue];
	// execute
	[processor1 processComment:comment1 withContext:nil store:store];
	[processor2 processComment:comment2 withContext:nil store:store];
	// verify
	[self assertComment:comment1 matchesShortDesc:@"Some text" longDesc:@"Some text\n\nAnother paragraph", nil];
	[self assertComment:comment2 matchesShortDesc:@"Some text" longDesc:@"Another paragraph", nil];
}

- (void)testProcessCommentWithContextStore_descriptions_shouldHandleAllTextAsLongDescBasedOnFlagsRegardlessOnSettingsAndContext {
	// setup
	GBStore *store = [GBTestObjectsRegistry store];
	GBCommentsProcessor *processor1 = [GBCommentsProcessor processorWithSettingsProvider:[self settingsProviderRepeatFirst:YES]];
	GBCommentsProcessor *processor2 = [GBCommentsProcessor processorWithSettingsProvider:[self settingsProviderRepeatFirst:NO]];
	GBComment *comment1 = [GBComment commentWithStringValue:@"Some text\n\nAnother paragraph"];
	GBComment *comment2 = [GBComment commentWithStringValue:comment1.stringValue];
	// execute
	processor1.alwaysRepeatFirstParagraph = YES;
	[processor1 processComment:comment1 withContext:nil store:store];
	processor2.alwaysRepeatFirstParagraph = YES;
	[processor2 processComment:comment2 withContext:nil store:store];
	// verify
	[self assertComment:comment1 matchesShortDesc:@"Some text" longDesc:@"Some text\n\nAnother paragraph", nil];
	[self assertComment:comment2 matchesShortDesc:@"Some text" longDesc:@"Some text\n\nAnother paragraph", nil];
}

- (void)testProcessCommentWithContextStore_descriptions_shouldHandleTextBeforeDirectivesBasedOnSettings {
	// setup
	GBStore *store = [GBTestObjectsRegistry store];
	GBCommentsProcessor *processor1 = [GBCommentsProcessor processorWithSettingsProvider:[self settingsProviderRepeatFirst:YES]];
	GBCommentsProcessor *processor2 = [GBCommentsProcessor processorWithSettingsProvider:[self settingsProviderRepeatFirst:NO]];
	GBComment *comment1 = [GBComment commentWithStringValue:@"Some text\n\nAnother paragraph\n\n@warning Description"];
	GBComment *comment2 = [GBComment commentWithStringValue:comment1.stringValue];
	// execute
	[processor1 processComment:comment1 withContext:nil store:store];
	[processor2 processComment:comment2 withContext:nil store:store];
	// verify
	[self assertComment:comment1 matchesShortDesc:@"Some text" longDesc:@"Some text\n\nAnother paragraph", @"@warning Description", nil];
	[self assertComment:comment2 matchesShortDesc:@"Some text" longDesc:@"Another paragraph", @"@warning Description", nil];
}

- (void)testProcessCommentWithContextStore_descriptions_shouldHandleTextAfterDescriptionDirectiveRegardlessOfSettings {
	// setup
	GBStore *store = [GBTestObjectsRegistry store];
	GBCommentsProcessor *processor1 = [GBCommentsProcessor processorWithSettingsProvider:[self settingsProviderRepeatFirst:YES]];
	GBCommentsProcessor *processor2 = [GBCommentsProcessor processorWithSettingsProvider:[self settingsProviderRepeatFirst:NO]];
	GBComment *comment1 = [GBComment commentWithStringValue:@"@warning Some text\n\nAnother paragraph"];
	GBComment *comment2 = [GBComment commentWithStringValue:comment1.stringValue];
	// execute
	[processor1 processComment:comment1 withContext:nil store:store];
	[processor2 processComment:comment2 withContext:nil store:store];
	// verify - all text after directive is considered part of that directive, but short text is still properly detected.
	[self assertComment:comment1 matchesShortDesc:@"Some text" longDesc:@"@warning Some text\n\nAnother paragraph", nil];
	[self assertComment:comment2 matchesShortDesc:@"Some text" longDesc:@"@warning Some text\n\nAnother paragraph", nil];
}

- (void)testProcessCommentWithContextStore_descriptions_shouldHandleMultipleDescriptionDirectivesProperly {
	// setup
	GBStore *store = [GBTestObjectsRegistry store];
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	GBComment *comment1 = [GBComment commentWithStringValue:@"@warning Paragraph 1.1\n\nParagraph 1.2\n\n@warning Paragraph 2.1\n\nParagraph 2.2"];
	GBComment *comment2 = [GBComment commentWithStringValue:@"@warning Warning\n\n@bug Bug"];
	GBComment *comment3 = [GBComment commentWithStringValue:@"@bug Bug\n\n@warning Warning"];
	// execute
	[processor processComment:comment1 withContext:nil store:store];
	[processor processComment:comment2 withContext:nil store:store];
	[processor processComment:comment3 withContext:nil store:store];
	// verify
	[self assertComment:comment1 matchesShortDesc:@"Paragraph 1.1" longDesc:@"@warning Paragraph 1.1\n\nParagraph 1.2", @"@warning Paragraph 2.1\n\nParagraph 2.2", nil];
	[self assertComment:comment2 matchesShortDesc:@"Warning" longDesc:@"@warning Warning", @"@bug Bug", nil];
	[self assertComment:comment3 matchesShortDesc:@"Bug" longDesc:@"@bug Bug", @"@warning Warning", nil];
}

- (void)testProcessCommentWithContextStore_descriptions_shouldHandleDescriptionForParamDirectiveRegardlessOfSettings {
	// setup
	GBStore *store = [GBTestObjectsRegistry store];
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	GBComment *comment1 = [GBComment commentWithStringValue:@"@param name Description\n\nParagraph"];
	GBComment *comment2 = [GBComment commentWithStringValue:@"@param name Description\n\nParagraph\n\n@warning Warning"];
	GBComment *comment3 = [GBComment commentWithStringValue:@"@param name1 Description1\n@param name2 Description2"];
	GBComment *comment4 = [GBComment commentWithStringValue:@"Prefix\n\n@param name Description\n\nParagraph"];
	// execute
	[processor processComment:comment1 withContext:nil store:store];
	[processor processComment:comment2 withContext:nil store:store];
	[processor processComment:comment3 withContext:nil store:store];
	[processor processComment:comment4 withContext:nil store:store];
	// verify - we only use parameter description if there is nothing else found in the comment.
	[self assertComment:comment1 matchesShortDesc:@"Description" longDesc:nil];
	[self assertComment:comment2 matchesShortDesc:@"Warning" longDesc:@"@warning Warning", nil];
	[self assertComment:comment3 matchesShortDesc:@"Description1" longDesc:nil];
	[self assertComment:comment4 matchesShortDesc:@"Prefix" longDesc:@"Prefix", nil];
}

- (void)testProcessCommentWithContextStore_descriptions_shouldHandleDescriptionForExceptionDirectiveRegardlessOfSettings {
	// setup
	GBStore *store = [GBTestObjectsRegistry store];
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	GBComment *comment1 = [GBComment commentWithStringValue:@"@exception name Description\n\nParagraph"];
	GBComment *comment2 = [GBComment commentWithStringValue:@"@exception name Description\n\nParagraph\n\n@warning Warning"];
	GBComment *comment3 = [GBComment commentWithStringValue:@"@exception name Description1\n@exception name2 Description2"];
	GBComment *comment4 = [GBComment commentWithStringValue:@"Prefix\n\n@exception name Description\n\nParagraph"];
	// execute
	[processor processComment:comment1 withContext:nil store:store];
	[processor processComment:comment2 withContext:nil store:store];
	[processor processComment:comment3 withContext:nil store:store];
	[processor processComment:comment4 withContext:nil store:store];
	// verify - we only use parameter description if there is nothing else found in the comment.
	[self assertComment:comment1 matchesShortDesc:@"Description" longDesc:nil];
	[self assertComment:comment2 matchesShortDesc:@"Warning" longDesc:@"@warning Warning", nil];
	[self assertComment:comment3 matchesShortDesc:@"Description1" longDesc:nil];
	[self assertComment:comment4 matchesShortDesc:@"Prefix" longDesc:@"Prefix", nil];
}

- (void)testProcessCommentWithContextStore_descriptions_shouldHandleDescriptionForReturnDirectiveRegardlessOfSettings {
	// setup
	GBStore *store = [GBTestObjectsRegistry store];
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	GBComment *comment1 = [GBComment commentWithStringValue:@"@return Description\n\nParagraph"];
	GBComment *comment2 = [GBComment commentWithStringValue:@"@return Description\n\nParagraph\n\n@warning Warning"];
	GBComment *comment3 = [GBComment commentWithStringValue:@"Prefix\n\n@return Description\n\nParagraph"];
	// execute
	[processor processComment:comment1 withContext:nil store:store];
	[processor processComment:comment2 withContext:nil store:store];
	[processor processComment:comment3 withContext:nil store:store];
	// verify - we only use parameter description if there is nothing else found in the comment.
	[self assertComment:comment1 matchesShortDesc:@"Description" longDesc:nil];
	[self assertComment:comment2 matchesShortDesc:@"Warning" longDesc:@"@warning Warning", nil];
	[self assertComment:comment3 matchesShortDesc:@"Prefix" longDesc:@"Prefix", nil];
}

- (void)testProcessCommentWithContextStore_descriptions_shouldHandleRelatedSymbolsForReturnDirectiveRegardlessOfSettings {
	// setup
	GBStore *store = [GBTestObjectsRegistry store];
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	GBComment *comment1 = [GBComment commentWithStringValue:@"@see Description\n\nParagraph"];
	GBComment *comment2 = [GBComment commentWithStringValue:@"@see Description\n\nParagraph\n\n@warning Warning"];
	GBComment *comment3 = [GBComment commentWithStringValue:@"Prefix\n\n@see Description\n\nParagraph"];
	// execute
	[processor processComment:comment1 withContext:nil store:store];
	[processor processComment:comment2 withContext:nil store:store];
	[processor processComment:comment3 withContext:nil store:store];
	// verify - we only use parameter description if there is nothing else found in the comment.
	[self assertComment:comment1 matchesShortDesc:@"Description" longDesc:nil];
	[self assertComment:comment2 matchesShortDesc:@"Warning" longDesc:@"@warning Warning", nil];
	[self assertComment:comment3 matchesShortDesc:@"Prefix" longDesc:@"Prefix", nil];
}

- (void)testProcessCommentWithContextStore_descriptions_shouldAssignSettingsToAllCommentComponents {
	// setup
	id settings = [GBTestObjectsRegistry realSettingsProvider];
	GBStore *store = [GBTestObjectsRegistry storeWithObjects:[GBClassData classDataWithName:@"Class"], nil];
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:settings];
	GBComment *comment = [GBComment commentWithStringValue:
						  @"Short\n\n"
						  @"Long\n\n"
						  @"@warning Warning\n\n"
						  @"@bug Bug\n\n"
						  @"@param name Desc\n"
						  @"@exception name Desc\n"
						  @"@return Desc"
						  @"@see Class"
						  @"@since Version 1.0"];
	// execute
	[processor processComment:comment withContext:nil store:store];
	// verify
	assertThat(comment.shortDescription.settings, is(settings));
	assertThat(comment.shortDescription.sourceInfo, isNot(nil));
	for (GBCommentComponent *c in comment.longDescription.components) {
		assertThat(c.settings, is(settings));
		assertThat(c.sourceInfo, isNot(nil));
	}
	for (GBCommentArgument *a in comment.methodParameters) {
		for (GBCommentComponent *c in a.argumentDescription.components) {			
			assertThat(c.settings, is(settings));
			assertThat(c.sourceInfo, isNot(nil));
		}
	}
	for (GBCommentArgument *a in comment.methodExceptions) {
		for (GBCommentComponent *c in a.argumentDescription.components) {
			assertThat(c.settings, is(settings));
			assertThat(c.sourceInfo, isNot(nil));
		}
	}
	for (GBCommentComponent *c in comment.methodResult.components) {
		assertThat(c.settings, is(settings));
		assertThat(c.sourceInfo, isNot(nil));
	}
	for (GBCommentComponent *c in comment.relatedItems.components) {
		assertThat(c.settings, is(settings));
		assertThat(c.sourceInfo, isNot(nil));
	}
	for (GBCommentComponent *c in comment.availability.components) {
		assertThat(c.settings, is(settings));
		assertThat(c.sourceInfo, isNot(nil));
	}
}

#pragma mark Method data testing

- (void)testProcessCommentWithContextStore_methods_shouldRegisterAllParametersDescriptionsProperly {
	// setup
	GBStore *store = [GBTestObjectsRegistry store];
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"@param name1 Description1\nLine2\n\nParagraph2\n@param name2 Description2"];
	// execute
	[processor processComment:comment withContext:nil store:store];
	// verify - we only use parameter description if there is nothing else found in the comment.
	[self assertMethodArguments:comment.methodParameters matches:@"name1", @"Description1\nLine2\n\nParagraph2", GBEND, @"name2", @"Description2", GBEND, nil];
}

- (void)testProcessCommentWithContextStore_methods_shouldRegisterAllParametersRegardlessOfEmptyLinesGaps {
	// setup
	GBStore *store = [GBTestObjectsRegistry store];
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	GBComment *comment1 = [GBComment commentWithStringValue:@"@param name1 Description1\n@param name2 Description2"];
	GBComment *comment2 = [GBComment commentWithStringValue:@"@param name1 Description1\n\n\n\n\n\n@param name2 Description2"];
	// execute
	[processor processComment:comment1 withContext:nil store:store];
	[processor processComment:comment2 withContext:nil store:store];
	// verify - we only use parameter description if there is nothing else found in the comment.
	[self assertMethodArguments:comment1.methodParameters matches:@"name1", @"Description1", GBEND, @"name2", @"Description2", GBEND, nil];
	[self assertMethodArguments:comment2.methodParameters matches:@"name1", @"Description1", GBEND, @"name2", @"Description2", GBEND, nil];
}

- (void)testProcessCommentWithContextStore_methods_shouldRegisterAllExceptionsRegardlessOfEmptyLinesGaps {
	// setup
	GBStore *store = [GBTestObjectsRegistry store];
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	GBComment *comment1 = [GBComment commentWithStringValue:@"@exception name1 Description1\n@exception name2 Description2"];
	GBComment *comment2 = [GBComment commentWithStringValue:@"@exception name1 Description1\n\n\n\n\n\n@exception name2 Description2"];
	// execute
	[processor processComment:comment1 withContext:nil store:store];
	[processor processComment:comment2 withContext:nil store:store];
	// verify - we only use parameter description if there is nothing else found in the comment.
	[self assertMethodArguments:comment1.methodExceptions matches:@"name1", @"Description1", GBEND, @"name2", @"Description2", GBEND, nil];
	[self assertMethodArguments:comment2.methodExceptions matches:@"name1", @"Description1", GBEND, @"name2", @"Description2", GBEND, nil];
}

- (void)testProcessCommentWithContextStore_methods_shouldRegisterResultDescriptionProperly {
	// setup
	GBStore *store = [GBTestObjectsRegistry store];
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	GBComment *comment1 = [GBComment commentWithStringValue:@"@return Description"];
	GBComment *comment2 = [GBComment commentWithStringValue:@"@return Description1\nLine2\n\nParagraph2"];
	// execute
	[processor processComment:comment1 withContext:nil store:store];
	[processor processComment:comment2 withContext:nil store:store];
	// verify - we only use parameter description if there is nothing else found in the comment.
	[self assertCommentComponents:comment1.methodResult matchesStringValues:@"Description", nil];
	[self assertCommentComponents:comment2.methodResult matchesStringValues:@"Description1\nLine2\n\nParagraph2", nil];
}

- (void)testProcessCommentWithContextStore_methods_shouldRegisterAvailabilityDescriptionProperly {
	// setup
	GBStore *store = [GBTestObjectsRegistry store];
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	GBComment *comment1 = [GBComment commentWithStringValue:@"@since Description"];
	GBComment *comment2 = [GBComment commentWithStringValue:@"@available Description1\nLine2\n\nParagraph2"];
	// execute
	[processor processComment:comment1 withContext:nil store:store];
	[processor processComment:comment2 withContext:nil store:store];
	// verify - we only use parameter description if there is nothing else found in the comment.
	[self assertCommentComponents:comment1.availability matchesStringValues:@"Description", nil];
	[self assertCommentComponents:comment2.availability matchesStringValues:@"Description1\nLine2\n\nParagraph2", nil];
}

#pragma mark Common directives testing

- (void)testProcessCommentWithContextStore_directives_shouldRegisterRelatedItemsForKnownTopLevelObjects {
	// setup
	GBClassData *class = [GBClassData classDataWithName:@"Class"];
	GBCategoryData *category = [GBCategoryData categoryDataWithName:@"Category" className:@"Class"];
	GBProtocolData *protocol = [GBProtocolData protocolDataWithName:@"Protocol"];
	GBStore *store = [GBTestObjectsRegistry storeWithObjects:class, category, protocol, nil];
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	GBComment *comment1 = [GBComment commentWithStringValue:@"@see Class"];
	GBComment *comment2 = [GBComment commentWithStringValue:@"@see Class(Category)"];
	GBComment *comment3 = [GBComment commentWithStringValue:@"@see Protocol"];
	GBComment *comment4 = [GBComment commentWithStringValue:@"@see Unknown"];
	// execute
	[processor processComment:comment1 withContext:nil store:store];
	[processor processComment:comment2 withContext:nil store:store];
	[processor processComment:comment3 withContext:nil store:store];
	[processor processComment:comment4 withContext:nil store:store];
	// verify - we only use parameter description if there is nothing else found in the comment.
	[self assertCommentComponents:comment1.relatedItems matchesStringValues:@"Class", nil];
	[self assertCommentComponents:comment2.relatedItems matchesStringValues:@"Class(Category)", nil];
	[self assertCommentComponents:comment3.relatedItems matchesStringValues:@"Protocol", nil];
	[self assertCommentComponents:comment4.relatedItems matchesStringValues:nil];
}

- (void)testProcessCommentWithContextStore_directives_shouldRegisterRelatedItemsForKnownDocuments {
	// setup
	GBDocumentData *document1 = [GBDocumentData documentDataWithContents:@"c" path:@"Document1.html"];
	GBDocumentData *document2 = [GBDocumentData documentDataWithContents:@"c" path:@"Document2.html"];
	GBStore *store = [GBTestObjectsRegistry storeWithObjects:document1, document2, nil];
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	GBComment *comment1 = [GBComment commentWithStringValue:@"@see Document1"];
	GBComment *comment2 = [GBComment commentWithStringValue:@"@see Document2"];
	GBComment *comment3 = [GBComment commentWithStringValue:@"@see Unknown"];
	// execute
	[processor processComment:comment1 withContext:nil store:store];
	[processor processComment:comment2 withContext:nil store:store];
	[processor processComment:comment3 withContext:nil store:store];
	// verify - we only use parameter description if there is nothing else found in the comment.
	[self assertCommentComponents:comment1.relatedItems matchesStringValues:@"Document1", nil];
	[self assertCommentComponents:comment2.relatedItems matchesStringValues:@"Document2", nil];
	[self assertCommentComponents:comment3.relatedItems matchesStringValues:nil];
}

- (void)testProcessCommentWithContextStore_directives_shouldRegisterRelatedItemsForKnownLocalMembers {
	// setup
	GBClassData *class = [GBTestObjectsRegistry classWithName:@"Class" methods:[GBTestObjectsRegistry instanceMethodWithNames:@"method", nil], nil];
	GBStore *store = [GBTestObjectsRegistry storeWithObjects:class, nil];
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	GBComment *comment1 = [GBComment commentWithStringValue:@"@see method:"];
	GBComment *comment2 = [GBComment commentWithStringValue:@"@see unknown:"];
	// execute
	[processor processComment:comment1 withContext:class store:store];
	[processor processComment:comment2 withContext:class store:store];
	// verify - we only use parameter description if there is nothing else found in the comment.
	[self assertCommentComponents:comment1.relatedItems matchesStringValues:@"method:", nil];
	[self assertCommentComponents:comment2.relatedItems matchesStringValues:nil];
}

- (void)testProcessCommentWithContextStore_directives_shouldRegisterRelatedItemsForKnownRemoteMembers {
	// setup
	GBClassData *class = [GBTestObjectsRegistry classWithName:@"Class" methods:[GBTestObjectsRegistry instanceMethodWithNames:@"method", nil], nil];
	GBStore *store = [GBTestObjectsRegistry storeWithObjects:class, nil];
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	GBComment *comment1 = [GBComment commentWithStringValue:@"@see [Class method:]"];
	GBComment *comment2 = [GBComment commentWithStringValue:@"@see [Class unknown:]"];
	GBComment *comment3 = [GBComment commentWithStringValue:@"@see [Unknown method:]"];
	// execute
	[processor processComment:comment1 withContext:nil store:store];
	[processor processComment:comment2 withContext:nil store:store];
	[processor processComment:comment3 withContext:nil store:store];
	// verify - we only use parameter description if there is nothing else found in the comment.
	[self assertCommentComponents:comment1.relatedItems matchesStringValues:@"[Class method:]", nil];
	[self assertCommentComponents:comment2.relatedItems matchesStringValues:nil];
	[self assertCommentComponents:comment3.relatedItems matchesStringValues:nil];
}

#pragma mark Combinations testing

- (void)testProcessCommentWithContextStore_combinations_shouldRegisterMethodDescriptionBlock {
	// setup
	GBStore *store = [GBTestObjectsRegistry store];
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:
						  @"@param name1 Description1\nLine2\n\nParagraph2\n"
						  @"@exception exc Exception\n"
						  @"@param name2 Description2\n"
						  @"@return Return\n"
						  @"@param name3 Description3\n"
						  @"@since Version 1.0\n"];
	// execute
	[processor processComment:comment withContext:nil store:store];
	// verify - we only use parameter description if there is nothing else found in the comment.
	[self assertMethodArguments:comment.methodParameters matches:
	 @"name1", @"Description1\nLine2\n\nParagraph2", GBEND, 
	 @"name2", @"Description2", GBEND, 
	 @"name3", @"Description3", GBEND, nil];
	[self assertMethodArguments:comment.methodExceptions matches:@"exc", @"Exception", GBEND, nil];
	[self assertCommentComponents:comment.methodResult matchesStringValues:@"Return", nil];
	[self assertCommentComponents:comment.availability matchesStringValues:@"Version 1.0", nil];
}

- (void)testProcessCommentWithContextStore_combinations_shouldRegisterWarningAfterMethodBlockAsMainDescription {
	// setup
	GBStore *store = [GBTestObjectsRegistry store];
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	GBComment *comment1 = [GBComment commentWithStringValue:@"@param name Description\n@warning Warning"];
	GBComment *comment2 = [GBComment commentWithStringValue:@"@exception name Description\n@warning Warning"];
	GBComment *comment3 = [GBComment commentWithStringValue:@"@return Description\n@warning Warning"];
	GBComment *comment4 = [GBComment commentWithStringValue:@"@since Description\n@warning Warning"];
	// execute
	[processor processComment:comment1 withContext:nil store:store];
	[processor processComment:comment2 withContext:nil store:store];
	[processor processComment:comment3 withContext:nil store:store];
	[processor processComment:comment4 withContext:nil store:store];
	// verify - we only use parameter description if there is nothing else found in the comment.
	[self assertMethodArguments:comment1.methodParameters matches:@"name", @"Description", GBEND, nil];
	[self assertMethodArguments:comment2.methodExceptions matches:@"name", @"Description", GBEND, nil];
	[self assertCommentComponents:comment3.methodResult matchesStringValues:@"Description", nil];
	[self assertCommentComponents:comment4.availability matchesStringValues:@"Description", nil];
	[self assertComment:comment1 matchesShortDesc:@"Warning" longDesc:@"@warning Warning", nil];
	[self assertComment:comment2 matchesShortDesc:@"Warning" longDesc:@"@warning Warning", nil];
	[self assertComment:comment3 matchesShortDesc:@"Warning" longDesc:@"@warning Warning", nil];
	[self assertComment:comment4 matchesShortDesc:@"Warning" longDesc:@"@warning Warning", nil];
}

#pragma mark Miscellaneous handling

- (void)testProcessCommentWithContextStore_misc_shouldSetIsProcessed {
	// setup
	GBStore *store = [GBTestObjectsRegistry store];
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@""];
	// execute
	[processor processComment:comment withContext:nil store:store];
	// verify
	assertThatBool(comment.isProcessed, equalToBool(YES));
}

#pragma mark Private methods testing

- (void)testFindCommentBlockInLinesBlockRangeShortRange_shouldDetectSingleComponent {
	[self assertFindCommentWithString:@"line" matchesBlockRange:NSMakeRange(0, 1) shortRange:NSMakeRange(0, 1)];
	[self assertFindCommentWithString:@"line1\nline2" matchesBlockRange:NSMakeRange(0, 2) shortRange:NSMakeRange(0, 2)];
	[self assertFindCommentWithString:@"para1\n\npara" matchesBlockRange:NSMakeRange(0, 3) shortRange:NSMakeRange(0, 1)];
	[self assertFindCommentWithString:@"para1\n\npara2\n\npara3" matchesBlockRange:NSMakeRange(0, 5) shortRange:NSMakeRange(0, 1)];
}

- (void)testFindCommentBlockInLinesBlockRangeShortRange_shouldDetectSingleComponentUpToDirective {
	[self assertFindCommentWithString:@"line\n@warning desc" matchesBlockRange:NSMakeRange(0, 1) shortRange:NSMakeRange(0, 1)];
	[self assertFindCommentWithString:@"line\n\n@warning desc" matchesBlockRange:NSMakeRange(0, 2) shortRange:NSMakeRange(0, 1)];
	[self assertFindCommentWithString:@"para1\n\npara2\n@warning desc" matchesBlockRange:NSMakeRange(0, 3) shortRange:NSMakeRange(0, 1)];
	[self assertFindCommentWithString:@"para1\n\npara2\n\n@warning desc" matchesBlockRange:NSMakeRange(0, 4) shortRange:NSMakeRange(0, 1)];
}

- (void)testFindCommentBlockInLinesBlockRangeShortRange_shouldDetectDirectiveComponentUpToEndOfLines {
	[self assertFindCommentWithString:@"@warning desc" matchesBlockRange:NSMakeRange(0, 1) shortRange:NSMakeRange(0, 1)];
	[self assertFindCommentWithString:@"@warning line1\nline2" matchesBlockRange:NSMakeRange(0, 2) shortRange:NSMakeRange(0, 2)];
	[self assertFindCommentWithString:@"@warning para1\n\npara2" matchesBlockRange:NSMakeRange(0, 3) shortRange:NSMakeRange(0, 1)];
}

- (void)testFindCommentBlockInLinesBlockRangeShortRange_shouldDetectDirectiveComponentUpToNextDirective {
	[self assertFindCommentWithString:@"@warning desc\n@warning next" matchesBlockRange:NSMakeRange(0, 1) shortRange:NSMakeRange(0, 1)];
	[self assertFindCommentWithString:@"@warning desc\n\n@warning next" matchesBlockRange:NSMakeRange(0, 2) shortRange:NSMakeRange(0, 1)];
	[self assertFindCommentWithString:@"@warning line1\nline2\n@warning next" matchesBlockRange:NSMakeRange(0, 2) shortRange:NSMakeRange(0, 2)];
	[self assertFindCommentWithString:@"@warning line1\nline2\n\n@warning next" matchesBlockRange:NSMakeRange(0, 3) shortRange:NSMakeRange(0, 2)];
	[self assertFindCommentWithString:@"@warning para1\n\npara2\n@warning next" matchesBlockRange:NSMakeRange(0, 3) shortRange:NSMakeRange(0, 1)];
	[self assertFindCommentWithString:@"@warning para1\n\npara2\n\n@warning next" matchesBlockRange:NSMakeRange(0, 4) shortRange:NSMakeRange(0, 1)];
}

- (void)testFindCommentBlockInLinesBlockRangeShortRange_shouldStopAtAnyDirective {
	NSRange blockRange = NSMakeRange(0, 1);
	NSRange shortRange = NSMakeRange(0, 1);
	[self assertFindCommentWithString:@"line\n@warning desc" matchesBlockRange:blockRange shortRange:shortRange];
	[self assertFindCommentWithString:@"line\n@bug desc" matchesBlockRange:blockRange shortRange:shortRange];
	[self assertFindCommentWithString:@"line\n@param name desc" matchesBlockRange:blockRange shortRange:shortRange];
	[self assertFindCommentWithString:@"line\n@return desc" matchesBlockRange:blockRange shortRange:shortRange];
	[self assertFindCommentWithString:@"line\n@returns desc" matchesBlockRange:blockRange shortRange:shortRange];
	[self assertFindCommentWithString:@"line\n@exception name desc" matchesBlockRange:blockRange shortRange:shortRange];
	[self assertFindCommentWithString:@"line\n@see desc" matchesBlockRange:blockRange shortRange:shortRange];
	[self assertFindCommentWithString:@"line\n@sa desc" matchesBlockRange:blockRange shortRange:shortRange];
}

#pragma Creation & assertion methods

- (OCMockObject *)settingsProviderRepeatFirst:(BOOL)repeat {
	OCMockObject *result = [GBTestObjectsRegistry mockSettingsProvider];
	[[[result stub] andReturnValue:[NSNumber numberWithBool:repeat]] repeatFirstParagraphForMemberDescription];
	return result;
}

- (void)assertFindCommentWithString:(NSString *)string matchesBlockRange:(NSRange)b shortRange:(NSRange)s {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	// execute
	NSRange blockRange = NSMakeRange(0, 0);
	NSRange shortRange = NSMakeRange(0, 0);
	[processor findCommentBlockInLines:[string arrayOfLines] blockRange:&blockRange shortRange:&shortRange];
	// verify
	assertThatInteger(blockRange.location, equalToInteger(b.location));
	assertThatInteger(blockRange.length, equalToInteger(b.length));
	assertThatInteger(shortRange.location, equalToInteger(s.location));
	assertThatInteger(shortRange.length, equalToInteger(s.length));
}

@end
