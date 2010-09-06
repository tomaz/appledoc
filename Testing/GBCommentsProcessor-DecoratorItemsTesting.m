//
//  GBCommentsProcessor-DecoratorItemsTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 2.9.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBComment.h"
#import "GBCommentsProcessor.h"

@interface GBCommentsProcessorDecoratorItemsTesting : GBObjectsAssertor
@end

#pragma mark -

@implementation GBCommentsProcessorDecoratorItemsTesting

#pragma mark Bold text testing

- (void)testProcesCommentWithStore_bold_shouldGenerateParagraphIfNoneSpecifiedBefore {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"*text*"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([comment.paragraphs count], equalToInteger(1));
	[self assertParagraph:[comment.paragraphs objectAtIndex:0] containsItems:[GBParagraphDecoratorItem class], @"text", nil];
	GBParagraphDecoratorItem *item = [[[comment.paragraphs objectAtIndex:0] items] objectAtIndex:0];
	assertThatInteger(item.decorationType, equalToInteger(GBDecorationTypeBold));
	assertThat([item.decoratedItem class], is([GBParagraphTextItem class]));
	assertThat([item.decoratedItem stringValue], is(@"text"));
}

- (void)testProcesCommentWithStore_bold_shouldDetectAtTheStartOfParagraph {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"*text* normal"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([comment.paragraphs count], equalToInteger(1));
	[self assertParagraph:[comment.paragraphs objectAtIndex:0] containsItems:[GBParagraphDecoratorItem class], @"text", [GBParagraphTextItem class], @"normal", nil];
	GBParagraphDecoratorItem *formatted = [[[comment.paragraphs objectAtIndex:0] items] objectAtIndex:0];
	assertThatInteger(formatted.decorationType, equalToInteger(GBDecorationTypeBold));
	assertThat([formatted.decoratedItem class], is([GBParagraphTextItem class]));
	assertThat([formatted.decoratedItem stringValue], is(@"text"));
}

- (void)testProcesCommentWithStore_bold_shouldDetectAtTheEndOfParagraph {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"normal *text*"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([comment.paragraphs count], equalToInteger(1));
	[self assertParagraph:[comment.paragraphs objectAtIndex:0] containsItems:[GBParagraphTextItem class], @"normal", [GBParagraphDecoratorItem class], @"text", nil];
	GBParagraphDecoratorItem *formatted = [[[comment.paragraphs objectAtIndex:0] items] objectAtIndex:1];
	assertThatInteger(formatted.decorationType, equalToInteger(GBDecorationTypeBold));
	assertThat([formatted.decoratedItem class], is([GBParagraphTextItem class]));
	assertThat([formatted.decoratedItem stringValue], is(@"text"));
}

- (void)testProcesCommentWithStore_bold_shouldDetectInTheMiddleOfParagraph {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"prefix *text* suffix"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([comment.paragraphs count], equalToInteger(1));
	[self assertParagraph:[comment.paragraphs objectAtIndex:0] containsItems:[GBParagraphTextItem class], @"prefix", [GBParagraphDecoratorItem class], @"text", [GBParagraphTextItem class], @"suffix", nil];
	GBParagraphDecoratorItem *formatted = [[[comment.paragraphs objectAtIndex:0] items] objectAtIndex:1];
	assertThatInteger(formatted.decorationType, equalToInteger(GBDecorationTypeBold));
	assertThat([formatted.decoratedItem class], is([GBParagraphTextItem class]));
	assertThat([formatted.decoratedItem stringValue], is(@"text"));
}

- (void)testProcesCommentWithStore_bold_shouldDetectWhitespaceSeparatedWords {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"*bla word\ttab\nline*"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([comment.paragraphs count], equalToInteger(1));
	[self assertParagraph:[comment.paragraphs objectAtIndex:0] containsItems:[GBParagraphDecoratorItem class], @"bla word tab line", nil];
	GBParagraphDecoratorItem *item = [[[comment.paragraphs objectAtIndex:0] items] objectAtIndex:0];
	assertThatInteger(item.decorationType, equalToInteger(GBDecorationTypeBold));
	assertThat([item.decoratedItem class], is([GBParagraphTextItem class]));
	assertThat([item.decoratedItem stringValue], is(@"bla word tab line"));
}

#pragma mark Italics text testing

- (void)testProcesCommentWithStore_italics_shouldGenerateParagraphIfNoneSpecifiedBefore {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"_text_"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([comment.paragraphs count], equalToInteger(1));
	[self assertParagraph:[comment.paragraphs objectAtIndex:0] containsItems:[GBParagraphDecoratorItem class], @"text", nil];
	GBParagraphDecoratorItem *item = [[[comment.paragraphs objectAtIndex:0] items] objectAtIndex:0];
	assertThatInteger(item.decorationType, equalToInteger(GBDecorationTypeItalics));
	assertThat([item.decoratedItem class], is([GBParagraphTextItem class]));
	assertThat([item.decoratedItem stringValue], is(@"text"));
}

- (void)testProcesCommentWithStore_italics_shouldDetectAtTheStartOfParagraph {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"_text_ normal"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([comment.paragraphs count], equalToInteger(1));
	[self assertParagraph:[comment.paragraphs objectAtIndex:0] containsItems:[GBParagraphDecoratorItem class], @"text", [GBParagraphTextItem class], @"normal", nil];
	GBParagraphDecoratorItem *formatted = [[[comment.paragraphs objectAtIndex:0] items] objectAtIndex:0];
	assertThatInteger(formatted.decorationType, equalToInteger(GBDecorationTypeItalics));
	assertThat([formatted.decoratedItem class], is([GBParagraphTextItem class]));
	assertThat([formatted.decoratedItem stringValue], is(@"text"));
}

- (void)testProcesCommentWithStore_italics_shouldDetectAtTheEndOfParagraph {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"normal _text_"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([comment.paragraphs count], equalToInteger(1));
	[self assertParagraph:[comment.paragraphs objectAtIndex:0] containsItems:[GBParagraphTextItem class], @"normal", [GBParagraphDecoratorItem class], @"text", nil];
	GBParagraphDecoratorItem *formatted = [[[comment.paragraphs objectAtIndex:0] items] objectAtIndex:1];
	assertThatInteger(formatted.decorationType, equalToInteger(GBDecorationTypeItalics));
	assertThat([formatted.decoratedItem class], is([GBParagraphTextItem class]));
	assertThat([formatted.decoratedItem stringValue], is(@"text"));
}

- (void)testProcesCommentWithStore_italics_shouldDetectInTheMiddleOfParagraph {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"prefix _text_ suffix"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([comment.paragraphs count], equalToInteger(1));
	[self assertParagraph:[comment.paragraphs objectAtIndex:0] containsItems:[GBParagraphTextItem class], @"prefix", [GBParagraphDecoratorItem class], @"text", [GBParagraphTextItem class], @"suffix", nil];
	GBParagraphDecoratorItem *formatted = [[[comment.paragraphs objectAtIndex:0] items] objectAtIndex:1];
	assertThatInteger(formatted.decorationType, equalToInteger(GBDecorationTypeItalics));
	assertThat([formatted.decoratedItem class], is([GBParagraphTextItem class]));
	assertThat([formatted.decoratedItem stringValue], is(@"text"));
}

- (void)testProcesCommentWithStore_italics_shouldDetectWhitespaceSeparatedWords {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"_bla word\ttab\nline_"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([comment.paragraphs count], equalToInteger(1));
	[self assertParagraph:[comment.paragraphs objectAtIndex:0] containsItems:[GBParagraphDecoratorItem class], @"bla word tab line", nil];
	GBParagraphDecoratorItem *item = [[[comment.paragraphs objectAtIndex:0] items] objectAtIndex:0];
	assertThatInteger(item.decorationType, equalToInteger(GBDecorationTypeItalics));
	assertThat([item.decoratedItem class], is([GBParagraphTextItem class]));
	assertThat([item.decoratedItem stringValue], is(@"bla word tab line"));
}

#pragma mark Code text testing

- (void)testProcesCommentWithStore_code_shouldGenerateParagraphIfNoneSpecifiedBefore {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"`text`"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([comment.paragraphs count], equalToInteger(1));
	[self assertParagraph:[comment.paragraphs objectAtIndex:0] containsItems:[GBParagraphDecoratorItem class], @"text", nil];
	GBParagraphDecoratorItem *item = [[[comment.paragraphs objectAtIndex:0] items] objectAtIndex:0];
	assertThatInteger(item.decorationType, equalToInteger(GBDecorationTypeCode));
	assertThat([item.decoratedItem class], is([GBParagraphTextItem class]));
	assertThat([item.decoratedItem stringValue], is(@"text"));
}

- (void)testProcesCommentWithStore_code_shouldDetectAtTheStartOfParagraph {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"`text` normal"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([comment.paragraphs count], equalToInteger(1));
	[self assertParagraph:[comment.paragraphs objectAtIndex:0] containsItems:[GBParagraphDecoratorItem class], @"text", [GBParagraphTextItem class], @"normal", nil];
	GBParagraphDecoratorItem *formatted = [[[comment.paragraphs objectAtIndex:0] items] objectAtIndex:0];
	assertThatInteger(formatted.decorationType, equalToInteger(GBDecorationTypeCode));
	assertThat([formatted.decoratedItem class], is([GBParagraphTextItem class]));
	assertThat([formatted.decoratedItem stringValue], is(@"text"));
}

- (void)testProcesCommentWithStore_code_shouldDetectAtTheEndOfParagraph {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"normal `text`"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([comment.paragraphs count], equalToInteger(1));
	[self assertParagraph:[comment.paragraphs objectAtIndex:0] containsItems:[GBParagraphTextItem class], @"normal", [GBParagraphDecoratorItem class], @"text", nil];
	GBParagraphDecoratorItem *formatted = [[[comment.paragraphs objectAtIndex:0] items] objectAtIndex:1];
	assertThatInteger(formatted.decorationType, equalToInteger(GBDecorationTypeCode));
	assertThat([formatted.decoratedItem class], is([GBParagraphTextItem class]));
	assertThat([formatted.decoratedItem stringValue], is(@"text"));
}

- (void)testProcesCommentWithStore_code_shouldDetectInTheMiddleOfParagraph {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"prefix `text` suffix"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([comment.paragraphs count], equalToInteger(1));
	[self assertParagraph:[comment.paragraphs objectAtIndex:0] containsItems:[GBParagraphTextItem class], @"prefix", [GBParagraphDecoratorItem class], @"text", [GBParagraphTextItem class], @"suffix", nil];
	GBParagraphDecoratorItem *formatted = [[[comment.paragraphs objectAtIndex:0] items] objectAtIndex:1];
	assertThatInteger(formatted.decorationType, equalToInteger(GBDecorationTypeCode));
	assertThat([formatted.decoratedItem class], is([GBParagraphTextItem class]));
	assertThat([formatted.decoratedItem stringValue], is(@"text"));
}

- (void)testProcesCommentWithStore_code_shouldDetectWhitespaceSeparatedWords {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"`bla word\ttab\nline`"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([comment.paragraphs count], equalToInteger(1));
	[self assertParagraph:[comment.paragraphs objectAtIndex:0] containsItems:[GBParagraphDecoratorItem class], @"bla word tab line", nil];
	GBParagraphDecoratorItem *item = [[[comment.paragraphs objectAtIndex:0] items] objectAtIndex:0];
	assertThatInteger(item.decorationType, equalToInteger(GBDecorationTypeCode));
	assertThat([item.decoratedItem class], is([GBParagraphTextItem class]));
	assertThat([item.decoratedItem stringValue], is(@"bla word tab line"));
}

@end
