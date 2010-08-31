//
//  GBCommentsProcessorTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 30.8.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBComment.h"
#import "GBCommentsProcessor.h"

@interface GBCommentsProcessorTesting : GHTestCase
@end

#pragma mark -

@implementation GBCommentsProcessorTesting

#pragma mark Paragraph text items testing

- (void)testProcessCommentWithStore_textItems_shouldGenerateSingleParagraph {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"Paragraph"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([comment.paragraphs count], equalToInteger(1));
	GBCommentParagraph *paragraph = [comment.paragraphs objectAtIndex:0];
	assertThatInteger([paragraph.items count], equalToInteger(1));
	assertThat([[paragraph.items objectAtIndex:0] class], is([GBParagraphTextItem class]));
	assertThat([[paragraph.items objectAtIndex:0] stringValue], is(@"Paragraph"));
}

- (void)testProcessCommentWithStore_textItems_shouldGenerateAllParagraphs {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"Paragraph1\n\nParagraph2"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([[comment paragraphs] count], equalToInteger(2));
	GBCommentParagraph *paragraph1 = [comment.paragraphs objectAtIndex:0];
	assertThatInteger([paragraph1.items count], equalToInteger(1));
	assertThat([[paragraph1.items objectAtIndex:0] class], is([GBParagraphTextItem class]));
	assertThat([[paragraph1.items objectAtIndex:0] stringValue], is(@"Paragraph1"));
	GBCommentParagraph *paragraph2 = [comment.paragraphs objectAtIndex:1];
	assertThatInteger([paragraph2.items count], equalToInteger(1));
	assertThat([[paragraph2.items objectAtIndex:0] class], is([GBParagraphTextItem class]));
	assertThat([[paragraph2.items objectAtIndex:0] stringValue], is(@"Paragraph2"));
}

- (void)testProcessCommentWithStore_textItems_shouldCombineAllParagraphLinesIntoOne {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"First line\nSecond line"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([[comment paragraphs] count], equalToInteger(1));
	GBCommentParagraph *paragraph = [comment.paragraphs objectAtIndex:0];
	assertThatInteger([paragraph.items count], equalToInteger(1));
	assertThat([[paragraph.items objectAtIndex:0] class], is([GBParagraphTextItem class]));
	assertThat([[paragraph.items objectAtIndex:0] stringValue], is(@"First line Second line"));
}

- (void)testProcessCommentWithStore_textItems_shouldTrimAllParagraphSpaces {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"   First line Second line    "];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([[comment paragraphs] count], equalToInteger(1));
	GBCommentParagraph *paragraph = [comment.paragraphs objectAtIndex:0];
	assertThatInteger([paragraph.items count], equalToInteger(1));
	assertThat([[paragraph.items objectAtIndex:0] class], is([GBParagraphTextItem class]));
	assertThat([[paragraph.items objectAtIndex:0] stringValue], is(@"First line Second line"));
}

//#pragma mark Unordered lists testing
//
//- (void)testProcessCommentWithStore_ul_shouldAttachListToPreviousParagraph {
//	// setup
//	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
//	GBComment *comment = [GBComment commentWithStringValue:@"Paragraph\n- Item"];
//	// execute
//	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
//	// verify
//	assertThatInteger([[comment paragraphs] count], equalToInteger(1));
//	assertThatInteger([comment.firstParagraph.items count], equalToInteger(2));
//	assertThat([[comment.firstParagraph.items objectAtIndex:0] className], is(@"GBParagraphTextItem"));
//	assertThat([comment.firstParagraph stringValue], is(@"Paragraph\n- Item"));
//}
//
//- (void)testProcessCommentWithStore_ul_shouldDetectMultipleLinesLists {
//	// setup
//	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
//	GBComment *comment = [GBComment commentWithStringValue:@"Paragraph\n- Item1\n-Item2"];
//	// execute
//	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
//	// verify
//	assertThatInteger([[comment paragraphs] count], equalToInteger(1));
//	assertThat([comment.firstParagraph stringValue], is(@"Paragraph\n- Item1\n- Item2"));
//}
//
//- (void)testProcessCommentWithStore_ul_shouldCreateParagraph {
//	// setup
//	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
//	GBComment *comment = [GBComment commentWithStringValue:@"- Item"];
//	// execute
//	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
//	// verify
//	assertThatInteger([[comment paragraphs] count], equalToInteger(1));
//	assertThat([comment.firstParagraph stringValue], is(@"- Item"));
//}
//
//#pragma mark Complex processing tests
//
//- (void)testProcessCommentWithStore_shouldProcessAllItems {
//	// setup
//	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
//	GBComment *comment = [GBComment commentWithStringValue:[GBRealLifeDataProvider fullMethodComment]];
//	// execute
//	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
//	// verify
//	assertThatInteger([comment.paragraphs count], equalToInteger(3));
//	assertThat([[comment.paragraphs objectAtIndex:0] stringValue], is(@"Short description."));
//	assertThat([[comment.paragraphs objectAtIndex:1] stringValue], is(@"Second paragraph with lot's of text split into two lines."));
//	assertThat([[comment.paragraphs objectAtIndex:2] stringValue], is(@"Third paragraph."));
//}
//
@end
