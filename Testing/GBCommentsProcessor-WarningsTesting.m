//
//  GBCommentsProcessor-WarningsTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 1.9.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBComment.h"
#import "GBCommentsProcessor.h"

@interface GBCommentsProcessorWarningsTesting : GBObjectsAssertor
@end

#pragma mark -

@implementation GBCommentsProcessorWarningsTesting

#pragma mark Description processing testing

- (void)testProcessCommentWithStore_shouldAttachWarningToPreviousParagraph {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"Paragraph\n\n@warning Description"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([comment.paragraphs count], equalToInteger(1));
	GBCommentParagraph *paragraph = comment.firstParagraph;
	[self assertParagraph:paragraph containsItems:[GBParagraphTextItem class], @"Paragraph", [GBParagraphSpecialItem class], GBNULL, nil];
	GBParagraphSpecialItem *item = [paragraph.paragraphItems objectAtIndex:1];
	assertThatInteger(item.specialItemType, equalToInteger(GBSpecialItemTypeWarning));
	[self assertParagraph:item.specialItemDescription containsItems:[GBParagraphTextItem class], @"Description", nil];
}

- (void)testProcessCommentWithStore_shouldDetectMultipleLinesDescriptions {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"Paragraph\n\n@warning Line1\nLine2"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([[comment paragraphs] count], equalToInteger(1));
	GBCommentParagraph *paragraph = comment.firstParagraph;
	[self assertParagraph:paragraph containsItems:[GBParagraphTextItem class], @"Paragraph", [GBParagraphSpecialItem class], GBNULL, nil];
	GBParagraphSpecialItem *item = [paragraph.paragraphItems objectAtIndex:1];
	assertThatInteger(item.specialItemType, equalToInteger(GBSpecialItemTypeWarning));
	[self assertParagraph:item.specialItemDescription containsItems:[GBParagraphTextItem class], @"Line1\nLine2", nil];
}

- (void)testProcessCommentWithStore_shouldCreateParagraphIfNoneSpecifiedBefore {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"@warning Description"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([[comment paragraphs] count], equalToInteger(1));
	GBCommentParagraph *paragraph = comment.firstParagraph;
	[self assertParagraph:paragraph containsItems:[GBParagraphSpecialItem class], GBNULL, nil];
	GBParagraphSpecialItem *item = [paragraph.paragraphItems objectAtIndex:0];
	assertThatInteger(item.specialItemType, equalToInteger(GBSpecialItemTypeWarning));
	[self assertParagraph:item.specialItemDescription containsItems:[GBParagraphTextItem class], @"Description", nil];
}

#pragma mark Requirements before/after testing

- (void)testProcessCommentWithStore_requiresEmptyLineAfterPreviousParagraphItem {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"Paragraph\n@warning Line"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([[comment paragraphs] count], equalToInteger(1));
	GBCommentParagraph *paragraph1 = [comment.paragraphs objectAtIndex:0];
	[self assertParagraph:paragraph1 containsItems:[GBParagraphTextItem class], @"Paragraph\n@warning Line", nil];
}

- (void)testProcessCommentWithStore_requiresEmptyLineBeforeNextParagraphItem {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment1 = [GBComment commentWithStringValue:@"@warning Description\nNext"];
	GBComment *comment2 = [GBComment commentWithStringValue:@"@warning Description\n\nNext"];
	// execute
	[processor processComment:comment1 withStore:[GBTestObjectsRegistry store]];
	[processor processComment:comment2 withStore:[GBTestObjectsRegistry store]];
	// verify - comment1 should continue warning
	assertThatInteger([[comment1 paragraphs] count], equalToInteger(1));
	[self assertParagraph:[comment1.paragraphs objectAtIndex:0] containsItems:[GBParagraphSpecialItem class], @"@warning Description\nNext", nil];
	// verify - comment2 should start new paragraph
	assertThatInteger([[comment2 paragraphs] count], equalToInteger(2));
	[self assertParagraph:[comment2.paragraphs objectAtIndex:0] containsItems:[GBParagraphSpecialItem class], @"@warning Description", nil];
	[self assertParagraph:[comment2.paragraphs objectAtIndex:1] containsItems:[GBParagraphTextItem class], @"Next", nil];
}

@end
