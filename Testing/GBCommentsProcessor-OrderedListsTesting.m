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

- (void)testProcessCommentWithStore_orderedLists_shouldAttachListToPreviousParagraph {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"Paragraph\n\n1. Item"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([comment.paragraphs count], equalToInteger(1));
	GBCommentParagraph *paragraph = comment.firstParagraph;
	[self assertParagraph:paragraph containsItems:[GBParagraphTextItem class], @"Paragraph", [GBParagraphListItem class], [NSNull null], nil];
	[self assertList:[paragraph.items objectAtIndex:1] isOrdered:YES containsParagraphs:@"Item", nil];
}

- (void)testProcessCommentWithStore_orderedLists_shouldDetectMultipleLinesLists {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"Paragraph\n\n1.Item1\n2. Item2"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([[comment paragraphs] count], equalToInteger(1));
	GBCommentParagraph *paragraph = comment.firstParagraph;
	[self assertParagraph:paragraph containsItems:[GBParagraphTextItem class], @"Paragraph", [GBParagraphListItem class], [NSNull null], nil];
	[self assertList:[paragraph.items objectAtIndex:1] isOrdered:YES containsParagraphs:@"Item1", @"Item2", nil];
}

- (void)testProcessCommentWithStore_orderedLists_shouldDetectMultipleLinesListsRegardlessOfLineNumbers {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"Paragraph\n\n999.Item1\n12.Item2"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([[comment paragraphs] count], equalToInteger(1));
	GBCommentParagraph *paragraph = comment.firstParagraph;
	[self assertParagraph:paragraph containsItems:[GBParagraphTextItem class], @"Paragraph", [GBParagraphListItem class], [NSNull null], nil];
	[self assertList:[paragraph.items objectAtIndex:1] isOrdered:YES containsParagraphs:@"Item1", @"Item2", nil];
}

- (void)testProcessCommentWithStore_orderedLists_shouldDetectItemsSpanningMutlipleLines {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"Paragraph\n\n1.Item1\nContinued\n2.Item2"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([[comment paragraphs] count], equalToInteger(1));
	GBCommentParagraph *paragraph = comment.firstParagraph;
	[self assertParagraph:paragraph containsItems:[GBParagraphTextItem class], @"Paragraph", [GBParagraphListItem class], [NSNull null], nil];
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
	[self assertParagraph:paragraph containsItems:[GBParagraphListItem class], [NSNull null], nil];
	[self assertList:[paragraph.items objectAtIndex:0] isOrdered:YES containsParagraphs:@"Item", nil];
}

- (void)testProcessCommentWithStore_orderedLists_requiresEmptyLineBeforeList {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment1 = [GBComment commentWithStringValue:@"Paragraph\n1. Item"];
	GBComment *comment2 = [GBComment commentWithStringValue:@"Paragraph\n   \t\t\t1. Item"];
	// execute
	[processor processComment:comment1 withStore:[GBTestObjectsRegistry store]];
	[processor processComment:comment2 withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([comment1.paragraphs count], equalToInteger(1));
	assertThatInteger([comment2.paragraphs count], equalToInteger(1));
	[self assertParagraph:comment1.firstParagraph containsItems:[GBParagraphTextItem class], @"Paragraph 1. Item", nil];
	[self assertParagraph:comment2.firstParagraph containsItems:[GBParagraphTextItem class], @"Paragraph 1. Item", nil];
}

@end
