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

#pragma mark List processing testing

- (void)testProcessCommentWithStore_shouldAttachListToPreviousParagraph {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"Paragraph\n\n- Item"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([comment.paragraphs count], equalToInteger(1));
	GBCommentParagraph *paragraph = comment.firstParagraph;
	[self assertParagraph:paragraph containsItems:[GBParagraphTextItem class], @"Paragraph", [GBParagraphListItem class], GBNULL, nil];
	[self assertList:[paragraph.items objectAtIndex:1] isOrdered:NO containsParagraphs:@"Item", nil];
}

- (void)testProcessCommentWithStore_shouldDetectMultipleLinesLists {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"Paragraph\n\n- Item1\n- Item2"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([[comment paragraphs] count], equalToInteger(1));
	GBCommentParagraph *paragraph = comment.firstParagraph;
	[self assertParagraph:paragraph containsItems:[GBParagraphTextItem class], @"Paragraph", [GBParagraphListItem class], GBNULL, nil];
	[self assertList:[paragraph.items objectAtIndex:1] isOrdered:NO containsParagraphs:@"Item1", @"Item2", nil];
}

- (void)testProcessCommentWithStore_shouldDetectItemsSpanningMutlipleLines {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"Paragraph\n\n- Item1\nContinued\n- Item2"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([[comment paragraphs] count], equalToInteger(1));
	GBCommentParagraph *paragraph = comment.firstParagraph;
	[self assertParagraph:paragraph containsItems:[GBParagraphTextItem class], @"Paragraph", [GBParagraphListItem class], GBNULL, nil];
	[self assertList:[paragraph.items objectAtIndex:1] isOrdered:NO containsParagraphs:@"Item1 Continued", @"Item2", nil];
}

- (void)testProcessCommentWithStore_shouldCreateParagraphIfNoneSpecifiedBefore {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"- Item"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([[comment paragraphs] count], equalToInteger(1));
	GBCommentParagraph *paragraph = comment.firstParagraph;
	[self assertParagraph:paragraph containsItems:[GBParagraphListItem class], GBNULL, nil];
	[self assertList:[paragraph.items objectAtIndex:0] isOrdered:NO containsParagraphs:@"Item", nil];
}

#pragma mark Nested lists testing

- (void)testProcessCommentWithStore_shouldDetectNestedUnorderedList {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"- p\n\t- c1\n\t- c2"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	GBCommentParagraph *paragraph = comment.firstParagraph;
	[self assertList:[paragraph.items objectAtIndex:0] describesHierarchy:@"p",NO,1, @"c1",NO,2, @"c2",NO,2, nil];
}

- (void)testProcessCommentWithStore_shouldDetectNestedOrderedList {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"- p\n\t1. c1\n\t2. c2"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	GBCommentParagraph *paragraph = comment.firstParagraph;
	[self assertList:[paragraph.items objectAtIndex:0] describesHierarchy:@"p",NO,1, @"c1",YES,2, @"c2",YES,2, nil];
}

- (void)testProcessCommentWithStore_shouldJumpBackLevels {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"- i1\n\t- i11\n\t\t- i111\n- i2"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	GBCommentParagraph *paragraph = comment.firstParagraph;
	[self assertList:[paragraph.items objectAtIndex:0] describesHierarchy:@"i1",NO,1, @"i11",NO,2, @"i111",NO,3, @"i2",NO,1, nil];
}

- (void)testProcessCommentWithStore_shouldManageComplexLists {
	// setup - note that we use spaces instead of tabs, doesn't matter as long as same ammount is applied for each level!
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:
						  @"- a\n"
						  @"  - a1\n"
						  @"    1. a11\n"
						  @"    2. a12\n"
						  @"- b\n"
						  @"- c\n"
						  @"  - c1\n"
						  @"    - c11\n"
						  @"    - c12\n"
						  @"  - c2\n"
						  @"- d\n"
						  @"- e"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	GBCommentParagraph *paragraph = comment.firstParagraph;
	[self assertList:[paragraph.items objectAtIndex:0] describesHierarchy:
	 @"a",NO,1, @"a1",NO,2, @"a11",YES,3, @"a12",YES,3, 
	 @"b",NO,1, 
	 @"c",NO,1, @"c1",NO,2, @"c11",NO,3, @"c12",NO,3, @"c2",NO,2, 
	 @"d",NO,1, 
	 @"e",NO,1, nil];
}

#pragma mark Requirements testing

- (void)testProcessCommentWithStore_requiresWhitespaceBetweenMarkerAndDescription {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"-Line"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([[comment paragraphs] count], equalToInteger(1));
	GBCommentParagraph *paragraph1 = [comment.paragraphs objectAtIndex:0];
	[self assertParagraph:paragraph1 containsItems:[GBParagraphTextItem class], @"-Line", nil];
}

- (void)testProcessCommentWithStore_requiresEmptyLineAfterPreviousParagraph {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"Paragraph\n- Line"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([[comment paragraphs] count], equalToInteger(1));
	GBCommentParagraph *paragraph1 = [comment.paragraphs objectAtIndex:0];
	[self assertParagraph:paragraph1 containsItems:[GBParagraphTextItem class], @"Paragraph - Line", nil];
}

- (void)testProcessCommentWithStore_requiresEmptyLineBeforeNextParagraphItem {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment1 = [GBComment commentWithStringValue:@"- Description\nNext"];
	GBComment *comment2 = [GBComment commentWithStringValue:@"- Description\n\nNext"];
	// execute
	[processor processComment:comment1 withStore:[GBTestObjectsRegistry store]];
	[processor processComment:comment2 withStore:[GBTestObjectsRegistry store]];
	// verify - comment1 should continue warning
	assertThatInteger([[comment1 paragraphs] count], equalToInteger(1));
	[self assertParagraph:[comment1.paragraphs objectAtIndex:0] containsItems:[GBParagraphListItem class], @"- Description\nNext", nil];
	// verify - comment2 should start new paragraph
	assertThatInteger([[comment2 paragraphs] count], equalToInteger(2));
	[self assertParagraph:[comment2.paragraphs objectAtIndex:0] containsItems:[GBParagraphListItem class], @"- Description", nil];
	[self assertParagraph:[comment2.paragraphs objectAtIndex:1] containsItems:[GBParagraphTextItem class], @"Next", nil];
}

@end
