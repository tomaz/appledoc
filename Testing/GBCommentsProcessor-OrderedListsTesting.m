//
//  GBCommentsProcessor-OrderedListsTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 1.9.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBComment.h"
#import "GBCommentsProcessor.h"

@interface GBCommentsProcessorOrderedListsTesting : GBObjectsAssertor
@end

#pragma mark -

@implementation GBCommentsProcessorOrderedListsTesting

#pragma mark List processing testing

- (void)testProcessCommentWithStore_orderedLists_shouldAttachListToPreviousParagraph {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"Paragraph\n\n1. Item"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([comment.paragraphs count], equalToInteger(1));
	GBCommentParagraph *paragraph = comment.firstParagraph;
	[self assertParagraph:paragraph containsItems:[GBParagraphTextItem class], @"Paragraph", [GBParagraphListItem class], GBNULL, nil];
	[self assertList:[paragraph.items objectAtIndex:1] isOrdered:YES containsParagraphs:@"Item", nil];
}

- (void)testProcessCommentWithStore_orderedLists_shouldDetectMultipleLinesLists {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"Paragraph\n\n1. Item1\n2. Item2"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([[comment paragraphs] count], equalToInteger(1));
	GBCommentParagraph *paragraph = comment.firstParagraph;
	[self assertParagraph:paragraph containsItems:[GBParagraphTextItem class], @"Paragraph", [GBParagraphListItem class], GBNULL, nil];
	[self assertList:[paragraph.items objectAtIndex:1] isOrdered:YES containsParagraphs:@"Item1", @"Item2", nil];
}

- (void)testProcessCommentWithStore_orderedLists_shouldDetectMultipleLinesListsRegardlessOfLineNumbers {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"Paragraph\n\n999. Item1\n12. Item2"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([[comment paragraphs] count], equalToInteger(1));
	GBCommentParagraph *paragraph = comment.firstParagraph;
	[self assertParagraph:paragraph containsItems:[GBParagraphTextItem class], @"Paragraph", [GBParagraphListItem class], GBNULL, nil];
	[self assertList:[paragraph.items objectAtIndex:1] isOrdered:YES containsParagraphs:@"Item1", @"Item2", nil];
}

- (void)testProcessCommentWithStore_orderedLists_shouldDetectItemsSpanningMutlipleLines {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"Paragraph\n\n1. Item1\nContinued\n2. Item2"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([[comment paragraphs] count], equalToInteger(1));
	GBCommentParagraph *paragraph = comment.firstParagraph;
	[self assertParagraph:paragraph containsItems:[GBParagraphTextItem class], @"Paragraph", [GBParagraphListItem class], GBNULL, nil];
	[self assertList:[paragraph.items objectAtIndex:1] isOrdered:YES containsParagraphs:@"Item1 Continued", @"Item2", nil];
}

- (void)testProcessCommentWithStore_orderedLists_shouldCreateParagraphIfNoneSpecifiedBefore {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"1. Item"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([[comment paragraphs] count], equalToInteger(1));
	GBCommentParagraph *paragraph = comment.firstParagraph;
	[self assertParagraph:paragraph containsItems:[GBParagraphListItem class], GBNULL, nil];
	[self assertList:[paragraph.items objectAtIndex:0] isOrdered:YES containsParagraphs:@"Item", nil];
}

#pragma mark Requirements testing

- (void)testProcessCommentWithStore_orderedLists_requiresWhitespaceBetweenMarkerAndDescription {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"1.Line"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([[comment paragraphs] count], equalToInteger(1));
	GBCommentParagraph *paragraph1 = [comment.paragraphs objectAtIndex:0];
	[self assertParagraph:paragraph1 containsItems:[GBParagraphTextItem class], @"1.Line", nil];
}

- (void)testProcessCommentWithStore_orderedLists_requiresEmptyLineAfterPreviousParagraph {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"Paragraph\n1. Line"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([[comment paragraphs] count], equalToInteger(1));
	GBCommentParagraph *paragraph1 = [comment.paragraphs objectAtIndex:0];
	[self assertParagraph:paragraph1 containsItems:[GBParagraphTextItem class], @"Paragraph 1. Line", nil];
}

- (void)testProcessCommentWithStore_orderedLists_requiresEmptyLineBeforeNextParagraphItem {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment1 = [GBComment commentWithStringValue:@"1. Description\nNext"];
	GBComment *comment2 = [GBComment commentWithStringValue:@"1. Description\n\nNext"];
	// execute
	[processor processComment:comment1 withStore:[GBTestObjectsRegistry store]];
	[processor processComment:comment2 withStore:[GBTestObjectsRegistry store]];
	// verify - comment1 should continue warning
	assertThatInteger([[comment1 paragraphs] count], equalToInteger(1));
	[self assertParagraph:[comment1.paragraphs objectAtIndex:0] containsItems:[GBParagraphListItem class], @"1. Description\nNext", nil];
	// verify - comment2 should start new paragraph
	assertThatInteger([[comment2 paragraphs] count], equalToInteger(2));
	[self assertParagraph:[comment2.paragraphs objectAtIndex:0] containsItems:[GBParagraphListItem class], @"1. Description", nil];
	[self assertParagraph:[comment2.paragraphs objectAtIndex:1] containsItems:[GBParagraphTextItem class], @"Next", nil];
}

@end
