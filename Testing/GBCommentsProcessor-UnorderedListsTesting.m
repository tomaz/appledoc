//
//  GBCommentsProcessor-UnorderedListsTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 30.8.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBComment.h"
#import "GBCommentsProcessor.h"

@interface GBCommentsProcessorUnorderedListsTesting : GBObjectsAssertor
@end

#pragma mark -

@implementation GBCommentsProcessorUnorderedListsTesting

- (void)testProcessCommentWithStore_unorderedLists_shouldAttachListToPreviousParagraph {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"Paragraph\n\n- Item"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([comment.paragraphs count], equalToInteger(1));
	GBCommentParagraph *paragraph = comment.firstParagraph;
	[self assertParagraph:paragraph containsItems:[GBParagraphTextItem class], @"Paragraph", [GBParagraphListItem class], [NSNull null], nil];
	[self assertList:[paragraph.items objectAtIndex:1] isOrdered:NO containsParagraphs:@"Item", nil];
}

- (void)testProcessCommentWithStore_unorderedLists_shouldDetectMultipleLinesLists {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"Paragraph\n\n-Item1\n-Item2"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([[comment paragraphs] count], equalToInteger(1));
	GBCommentParagraph *paragraph = comment.firstParagraph;
	[self assertParagraph:paragraph containsItems:[GBParagraphTextItem class], @"Paragraph", [GBParagraphListItem class], [NSNull null], nil];
	[self assertList:[paragraph.items objectAtIndex:1] isOrdered:NO containsParagraphs:@"Item1", @"Item2", nil];
}

- (void)testProcessCommentWithStore_unorderedLists_shouldDetectItemsSpanningMutlipleLines {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"Paragraph\n\n-Item1\nContinued\n-Item2"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([[comment paragraphs] count], equalToInteger(1));
	GBCommentParagraph *paragraph = comment.firstParagraph;
	[self assertParagraph:paragraph containsItems:[GBParagraphTextItem class], @"Paragraph", [GBParagraphListItem class], [NSNull null], nil];
	[self assertList:[paragraph.items objectAtIndex:1] isOrdered:NO containsParagraphs:@"Item1 Continued", @"Item2", nil];
}

- (void)testProcessCommentWithStore_uorderedLists_shouldCreateParagraphIfNoneSpecifiedBefore {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"- Item"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([[comment paragraphs] count], equalToInteger(1));
	GBCommentParagraph *paragraph = comment.firstParagraph;
	[self assertParagraph:paragraph containsItems:[GBParagraphListItem class], [NSNull null], nil];
	[self assertList:[paragraph.items objectAtIndex:0] isOrdered:NO containsParagraphs:@"Item", nil];
}

- (void)testProcessCommentWithStore_unorderedLists_requiresEmptyLineBeforeList {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment1 = [GBComment commentWithStringValue:@"Paragraph\n- Item"];
	GBComment *comment2 = [GBComment commentWithStringValue:@"Paragraph\n   \t\t\t- Item"];
	// execute
	[processor processComment:comment1 withStore:[GBTestObjectsRegistry store]];
	[processor processComment:comment2 withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([comment1.paragraphs count], equalToInteger(1));
	assertThatInteger([comment2.paragraphs count], equalToInteger(1));
	[self assertParagraph:comment1.firstParagraph containsItems:[GBParagraphTextItem class], @"Paragraph - Item", nil];
	[self assertParagraph:comment2.firstParagraph containsItems:[GBParagraphTextItem class], @"Paragraph - Item", nil];
}

@end
