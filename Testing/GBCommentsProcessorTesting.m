//
//  GBCommentsProcessorTesting.m
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

@interface GBCommentsProcessorTesting : GBObjectsAssertor

- (OCMockObject *)settingsProviderRepeatFirst:(BOOL)repeat;
- (void)assertFindCommentWithString:(NSString *)string matchesBlockRange:(NSRange)b shortRange:(NSRange)s;

@end

#pragma mark -

@implementation GBCommentsProcessorTesting

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
