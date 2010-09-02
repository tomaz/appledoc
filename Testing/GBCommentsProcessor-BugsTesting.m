//
//  GBCommentsProcessor-BugsTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 1.9.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBComment.h"
#import "GBCommentsProcessor.h"

@interface GBCommentsProcessorBugsTesting : GBObjectsAssertor
@end

#pragma mark -

@implementation GBCommentsProcessorBugsTesting

- (void)testProcessCommentWithStore_bugs_shouldAttachBugToPreviousParagraph {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"Paragraph\n\n@bug Description"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([comment.paragraphs count], equalToInteger(1));
	GBCommentParagraph *paragraph = comment.firstParagraph;
	[self assertParagraph:paragraph containsItems:[GBParagraphTextItem class], @"Paragraph", [GBParagraphSpecialItem class], [NSNull null], nil];
	GBParagraphSpecialItem *item = [paragraph.items objectAtIndex:1];
	assertThatInteger(item.specialItemType, equalToInteger(GBSpecialItemTypeBug));
	[self assertParagraph:item.description containsItems:[GBParagraphTextItem class], @"Description", nil];
}

- (void)testProcessCommentWithStore_bugs_shouldDetectMultipleLinesDescriptions {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"Paragraph\n\n@bug Line1\nLine2"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([[comment paragraphs] count], equalToInteger(1));
	GBCommentParagraph *paragraph = comment.firstParagraph;
	[self assertParagraph:paragraph containsItems:[GBParagraphTextItem class], @"Paragraph", [GBParagraphSpecialItem class], [NSNull null], nil];
	GBParagraphSpecialItem *item = [paragraph.items objectAtIndex:1];
	assertThatInteger(item.specialItemType, equalToInteger(GBSpecialItemTypeBug));
	[self assertParagraph:item.description containsItems:[GBParagraphTextItem class], @"Line1 Line2", nil];
}

- (void)testProcessCommentWithStore_bugs_shouldCreateParagraphIfNoneSpecifiedBefore {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"@bug Description"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([[comment paragraphs] count], equalToInteger(1));
	GBCommentParagraph *paragraph = comment.firstParagraph;
	[self assertParagraph:paragraph containsItems:[GBParagraphSpecialItem class], [NSNull null], nil];
	GBParagraphSpecialItem *item = [paragraph.items objectAtIndex:0];
	assertThatInteger(item.specialItemType, equalToInteger(GBSpecialItemTypeBug));
	[self assertParagraph:item.description containsItems:[GBParagraphTextItem class], @"Description", nil];
}

@end
