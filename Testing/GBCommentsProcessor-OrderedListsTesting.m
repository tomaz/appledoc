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

- (void)testProcessCommentWithStore_shouldAttachListToPreviousParagraph {
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

- (void)testProcessCommentWithStore_shouldDetectMultipleLinesLists {
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

- (void)testProcessCommentWithStore_shouldDetectMultipleLinesListsRegardlessOfLineNumbers {
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

- (void)testProcessCommentWithStore_shouldDetectItemsSpanningMutlipleLines {
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

- (void)testProcessCommentWithStore_shouldCreateParagraphIfNoneSpecifiedBefore {
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

#pragma mark Nested lists testing

- (void)testProcessCommentWithStore_shouldDetectNestedOrderedList {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"1. p\n\t1. c1\n\t2. c2"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	GBCommentParagraph *paragraph = comment.firstParagraph;
	[self assertList:[paragraph.items objectAtIndex:0] describesHierarchy:@"p",YES,1, @"c1",YES,2, @"c2",YES,2, nil];
}

- (void)testProcessCommentWithStore_shouldDetectNestedUnorderedList {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"1. p\n\t- c1\n\t- c2"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	GBCommentParagraph *paragraph = comment.firstParagraph;
	[self assertList:[paragraph.items objectAtIndex:0] describesHierarchy:@"p",YES,1, @"c1",NO,2, @"c2",NO,2, nil];
}

- (void)testProcessCommentWithStore_shouldJumpBackLevels {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"1. i1\n\t1. i11\n\t\t1. i111\n2. i2"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	GBCommentParagraph *paragraph = comment.firstParagraph;
	[self assertList:[paragraph.items objectAtIndex:0] describesHierarchy:@"i1",YES,1, @"i11",YES,2, @"i111",YES,3, @"i2",YES,1, nil];
}

- (void)testProcessCommentWithStore_shouldManageComplexLists {
	// setup - note that we use spaces instead of tabs, doesn't matter as long as same ammount is applied for each level!
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:
						  @"1. a\n"
						  @"  1. a1\n"
						  @"    - a11\n"
						  @"    - a12\n"
						  @"2. b\n"
						  @"3. c\n"
						  @"  1. c1\n"
						  @"    1. c11\n"
						  @"    2. c12\n"
						  @"  2. c2\n"
						  @"4. d\n"
						  @"5. e"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	GBCommentParagraph *paragraph = comment.firstParagraph;
	[self assertList:[paragraph.items objectAtIndex:0] describesHierarchy:
	 @"a",YES,1, @"a1",YES,2, @"a11",NO,3, @"a12",NO,3, 
	 @"b",YES,1, 
	 @"c",YES,1, @"c1",YES,2, @"c11",YES,3, @"c12",YES,3, @"c2",YES,2, 
	 @"d",YES,1, 
	 @"e",YES,1, nil];
}

#pragma mark Requirements testing

- (void)testProcessCommentWithStore_requiresWhitespaceBetweenMarkerAndDescription {
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

- (void)testProcessCommentWithStore_requiresEmptyLineAfterPreviousParagraph {
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

- (void)testProcessCommentWithStore_requiresEmptyLineBeforeNextParagraphItem {
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
