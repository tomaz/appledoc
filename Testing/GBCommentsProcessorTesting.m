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

#pragma mark Paragraphs processing

- (void)testProcessCommentWithStore_shouldGenerateSingleParagraph {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"Paragraph"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([comment.paragraphs count], equalToInteger(1));
	assertThat([[comment.paragraphs objectAtIndex:0] stringValue], is(@"Paragraph"));
}

- (void)testProcessCommentWithStore_shouldGenerateAllParagraphs {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"Paragraph1\n\nParagraph2"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([[comment paragraphs] count], equalToInteger(2));
	assertThat([[comment.paragraphs objectAtIndex:0] stringValue], is(@"Paragraph1"));
	assertThat([[comment.paragraphs objectAtIndex:1] stringValue], is(@"Paragraph2"));
}

- (void)testProcessCommentWithStore_shouldCombineAllParagraphLinesIntoOne {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"First line\nSecond line"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThat([comment.firstParagraph stringValue], is(@"First line Second line"));
}

- (void)testProcessCommentWithStore_shouldTrimAllParagraphSpaces {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"   First line Second line    "];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThat([comment.firstParagraph stringValue], is(@"First line Second line"));
}

- (void)testProcessCommentWithStore_shouldKeepParagraphTabs {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"  \t First line"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThat([comment.firstParagraph stringValue], is(@"\t First line"));
}

@end
