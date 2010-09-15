//
//  GBCommentsProcessor-ExamplesTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 2.9.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBComment.h"
#import "GBCommentsProcessor.h"

@interface GBCommentsProcessorExamplesTesting : GBObjectsAssertor
@end

#pragma mark -

@implementation GBCommentsProcessorExamplesTesting

#pragma mark Description processing testing

- (void)testProcessCommentWithStore_shouldAttachExampleToPreviousParagraph {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"Paragraph\n\n\tDescription"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([comment.paragraphs count], equalToInteger(1));
	GBCommentParagraph *paragraph = comment.firstParagraph;
	[self assertParagraph:paragraph containsItems:[GBParagraphTextItem class], @"Paragraph", [GBParagraphSpecialItem class], GBNULL, nil];
	GBParagraphSpecialItem *item = [paragraph.items objectAtIndex:1];
	assertThatInteger(item.specialItemType, equalToInteger(GBSpecialItemTypeExample));
	[self assertParagraph:item.specialItemDescription containsItems:[GBParagraphTextItem class], @"Description", nil];
}

- (void)testProcessCommentWithStore_shouldDetectMultipleLinesDescriptions {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"Paragraph\n\n\tLine1\n\tLine2"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([[comment paragraphs] count], equalToInteger(1));
	GBCommentParagraph *paragraph = comment.firstParagraph;
	[self assertParagraph:paragraph containsItems:[GBParagraphTextItem class], @"Paragraph", [GBParagraphSpecialItem class], GBNULL, nil];
	GBParagraphSpecialItem *item = [paragraph.items objectAtIndex:1];
	assertThatInteger(item.specialItemType, equalToInteger(GBSpecialItemTypeExample));
	[self assertParagraph:item.specialItemDescription containsItems:[GBParagraphTextItem class], @"Line1\nLine2", nil];
}

- (void)testProcessCommentWithStore_shouldRemovePrefixTabs {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"Paragraph\n\n\tLine"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([[comment paragraphs] count], equalToInteger(1));
	GBCommentParagraph *paragraph = comment.firstParagraph;
	[self assertParagraph:paragraph containsItems:[GBParagraphTextItem class], @"Paragraph", [GBParagraphSpecialItem class], GBNULL, nil];
	GBParagraphSpecialItem *item = [paragraph.items objectAtIndex:1];
	assertThatInteger(item.specialItemType, equalToInteger(GBSpecialItemTypeExample));
	[self assertParagraph:item.specialItemDescription containsItems:[GBParagraphTextItem class], @"Line", nil];
}

- (void)testProcessCommentWithStore_shouldKeepPrefixTabsAfterFirst {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"Paragraph\n\n\t\tLine1\n\t\t\t\tLine2"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([[comment paragraphs] count], equalToInteger(1));
	GBCommentParagraph *paragraph = comment.firstParagraph;
	[self assertParagraph:paragraph containsItems:[GBParagraphTextItem class], @"Paragraph", [GBParagraphSpecialItem class], GBNULL, nil];
	GBParagraphSpecialItem *item = [paragraph.items objectAtIndex:1];
	assertThatInteger(item.specialItemType, equalToInteger(GBSpecialItemTypeExample));
	[self assertParagraph:item.specialItemDescription containsItems:[GBParagraphTextItem class], @"\tLine1\n\t\t\tLine2", nil];
}

- (void)testProcessCommentWithStore_shouldKeepEmptyLinesIfPrefixedWithTab {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"Paragraph\n\n\t\tLine1\n\t\n\tLine3"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([[comment paragraphs] count], equalToInteger(1));
	GBCommentParagraph *paragraph = comment.firstParagraph;
	[self assertParagraph:paragraph containsItems:[GBParagraphTextItem class], @"Paragraph", [GBParagraphSpecialItem class], GBNULL, nil];
	GBParagraphSpecialItem *item = [paragraph.items objectAtIndex:1];
	assertThatInteger(item.specialItemType, equalToInteger(GBSpecialItemTypeExample));
	[self assertParagraph:item.specialItemDescription containsItems:[GBParagraphTextItem class], @"\tLine1\n\nLine3", nil];
}

- (void)testProcessCommentWithStore_shouldCreateParagraphIfNoneSpecifiedBefore {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"\tDescription"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([[comment paragraphs] count], equalToInteger(1));
	GBCommentParagraph *paragraph = comment.firstParagraph;
	[self assertParagraph:paragraph containsItems:[GBParagraphSpecialItem class], GBNULL, nil];
	GBParagraphSpecialItem *item = [paragraph.items objectAtIndex:0];
	assertThatInteger(item.specialItemType, equalToInteger(GBSpecialItemTypeExample));
	[self assertParagraph:item.specialItemDescription containsItems:[GBParagraphTextItem class], @"Description", nil];
}

#pragma mark Requirements before/after testing

- (void)testProcessCommentWithStore_requiresEmptyLineAfterPreviousParagraphItem {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"Paragraph\n\tLine"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([[comment paragraphs] count], equalToInteger(1));
	GBCommentParagraph *paragraph1 = [comment.paragraphs objectAtIndex:0];
	[self assertParagraph:paragraph1 containsItems:[GBParagraphTextItem class], @"Paragraph Line", nil];
}

- (void)testProcessCommentWithStore_requiresEmptyLineBeforeNextParagraphItem {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment1 = [GBComment commentWithStringValue:@"\tLine1\nLine2"];
	GBComment *comment2 = [GBComment commentWithStringValue:@"\tLine1\n\nLine2"];
	// execute
	[processor processComment:comment1 withStore:[GBTestObjectsRegistry store]];
	[processor processComment:comment2 withStore:[GBTestObjectsRegistry store]];
	// verify - comment1 doesn't have Line2, in fact it's ignored but a warning is written to log (can't test it though).
	assertThatInteger([[comment1 paragraphs] count], equalToInteger(1));
	[self assertParagraph:[[comment1 paragraphs] objectAtIndex:0] containsItems:[GBParagraphSpecialItem class], @"Line1", nil];
	assertThatInteger([[comment2 paragraphs] count], equalToInteger(2));
	[self assertParagraph:[[comment2 paragraphs] objectAtIndex:0] containsItems:[GBParagraphSpecialItem class], @"Line1", nil];
	[self assertParagraph:[[comment2 paragraphs] objectAtIndex:1] containsItems:[GBParagraphTextItem class], @"Line2", nil];
}

@end
