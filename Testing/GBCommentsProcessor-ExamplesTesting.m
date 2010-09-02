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

- (void)testProcessCommentWithStore_examples_shouldAttachExampleToPreviousParagraph {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"Paragraph\n\n\tDescription"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([comment.paragraphs count], equalToInteger(1));
	GBCommentParagraph *paragraph = comment.firstParagraph;
	[self assertParagraph:paragraph containsItems:[GBParagraphTextItem class], @"Paragraph", [GBParagraphSpecialItem class], [NSNull null], nil];
	GBParagraphSpecialItem *item = [paragraph.items objectAtIndex:1];
	assertThatInteger(item.specialItemType, equalToInteger(GBSpecialItemTypeExample));
	[self assertParagraph:item.description containsItems:[GBParagraphTextItem class], @"Description", nil];
}

- (void)testProcessCommentWithStore_examples_shouldDetectMultipleLinesDescriptions {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"Paragraph\n\n\tLine1\n\tLine2"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([[comment paragraphs] count], equalToInteger(1));
	GBCommentParagraph *paragraph = comment.firstParagraph;
	[self assertParagraph:paragraph containsItems:[GBParagraphTextItem class], @"Paragraph", [GBParagraphSpecialItem class], [NSNull null], nil];
	GBParagraphSpecialItem *item = [paragraph.items objectAtIndex:1];
	assertThatInteger(item.specialItemType, equalToInteger(GBSpecialItemTypeExample));
	[self assertParagraph:item.description containsItems:[GBParagraphTextItem class], @"Line1\nLine2", nil];
}

- (void)testProcessCommentWithStore_examples_shouldRemovePrefixTabs {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"Paragraph\n\n\tLine"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([[comment paragraphs] count], equalToInteger(1));
	GBCommentParagraph *paragraph = comment.firstParagraph;
	[self assertParagraph:paragraph containsItems:[GBParagraphTextItem class], @"Paragraph", [GBParagraphSpecialItem class], [NSNull null], nil];
	GBParagraphSpecialItem *item = [paragraph.items objectAtIndex:1];
	assertThatInteger(item.specialItemType, equalToInteger(GBSpecialItemTypeExample));
	[self assertParagraph:item.description containsItems:[GBParagraphTextItem class], @"Line", nil];
}

- (void)testProcessCommentWithStore_examples_shouldKeepPrefixTabsAfterFirst {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"Paragraph\n\n\t\tLine1\n\t\t\t\tLine2"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([[comment paragraphs] count], equalToInteger(1));
	GBCommentParagraph *paragraph = comment.firstParagraph;
	[self assertParagraph:paragraph containsItems:[GBParagraphTextItem class], @"Paragraph", [GBParagraphSpecialItem class], [NSNull null], nil];
	GBParagraphSpecialItem *item = [paragraph.items objectAtIndex:1];
	assertThatInteger(item.specialItemType, equalToInteger(GBSpecialItemTypeExample));
	[self assertParagraph:item.description containsItems:[GBParagraphTextItem class], @"\tLine1\n\t\t\tLine2", nil];
}

- (void)testProcessCommentWithStore_examples_shouldKeepEmptyLinesIfPrefixedWithTab {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"Paragraph\n\n\t\tLine1\n\t\n\tLine3"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([[comment paragraphs] count], equalToInteger(1));
	GBCommentParagraph *paragraph = comment.firstParagraph;
	[self assertParagraph:paragraph containsItems:[GBParagraphTextItem class], @"Paragraph", [GBParagraphSpecialItem class], [NSNull null], nil];
	GBParagraphSpecialItem *item = [paragraph.items objectAtIndex:1];
	assertThatInteger(item.specialItemType, equalToInteger(GBSpecialItemTypeExample));
	[self assertParagraph:item.description containsItems:[GBParagraphTextItem class], @"\tLine1\n\nLine3", nil];
}

//- (void)testProcessCommentWithStore_examples_shouldEndExampleIfNoTabIsFoundDescriptions {
//	// setup
//	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
//	GBComment *comment = [GBComment commentWithStringValue:@"Paragraph\n\n\tLine1\nLine2"];
//	// execute
//	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
//	// verify
//	assertThatInteger([[comment paragraphs] count], equalToInteger(2));
//	GBCommentParagraph *paragraph1 = [comment.paragraphs objectAtIndex:0];
//	[self assertParagraph:paragraph1 containsItems:[GBParagraphTextItem class], @"Paragraph", [GBParagraphSpecialItem class], [NSNull null], nil];
//	GBParagraphSpecialItem *item = [paragraph1.items objectAtIndex:1];
//	assertThatInteger(item.specialItemType, equalToInteger(GBSpecialItemTypeExample));
//	[self assertParagraph:item.description containsItems:[GBParagraphTextItem class], @"Line1", nil];
//	GBCommentParagraph *paragraph2 = [comment.paragraphs objectAtIndex:1];
//	[self assertParagraph:paragraph2 containsItems:[GBParagraphTextItem class], @"Line2", nil];
//}

- (void)testProcessCommentWithStore_examples_shouldCreateParagraphIfNoneSpecifiedBefore {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"\tDescription"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([[comment paragraphs] count], equalToInteger(1));
	GBCommentParagraph *paragraph = comment.firstParagraph;
	[self assertParagraph:paragraph containsItems:[GBParagraphSpecialItem class], [NSNull null], nil];
	GBParagraphSpecialItem *item = [paragraph.items objectAtIndex:0];
	assertThatInteger(item.specialItemType, equalToInteger(GBSpecialItemTypeExample));
	[self assertParagraph:item.description containsItems:[GBParagraphTextItem class], @"Description", nil];
}

@end
