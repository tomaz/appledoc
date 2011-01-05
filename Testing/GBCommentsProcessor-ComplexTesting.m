//
//  GBCommentsProcessor-ComplexTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 22.9.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBComment.h"
#import "GBCommentsProcessor.h"

@interface GBCommentsProcessorComplexTesting : GBObjectsAssertor

- (void)assertFirstParagraph:(GBCommentParagraph *)paragraph;
- (void)assertSecondParagraph:(GBCommentParagraph *)paragraph;
- (void)assertThirdParagraph:(GBCommentParagraph *)paragraph;

@end

#pragma mark -

@implementation GBCommentsProcessorComplexTesting

#pragma mark Bug fix test cases

- (void)testProcessCommentWithStore_shouldProperlyHandleLinkPrefixAndSuffix {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBClassData *class = [GBClassData classDataWithName:@"Class"];
	[class.methods registerMethod:[GBTestObjectsRegistry propertyMethodWithArgument:@"member"]];
	GBStore *store = [GBTestObjectsRegistry storeByPerformingSelector:@selector(registerClass:) withObject:class];
	GBComment *comment = [GBComment commentWithStringValue:@"Prefix [Class member] suffix."];
	// execute
	[processor processComment:comment withStore:store];
	// verify
	[self assertParagraph:comment.firstParagraph containsItems:
	 [GBParagraphTextItem class], @"Prefix", 
	 [GBParagraphLinkItem class], @"[Class member]",
	 [GBParagraphTextItem class], @"suffix.",
	 nil];
}

#pragma mark Common comment processing testing

- (void)testProcesCommentWithStore_shouldProcessTrickyComment {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBClassData *class = [GBClassData classDataWithName:@"Second"];
	GBStore *store = [GBTestObjectsRegistry storeByPerformingSelector:@selector(registerClass:) withObject:class];
	NSString *value = [GBRealLifeDataProvider trickyMethodComment];
	GBComment *comment = [GBComment commentWithStringValue:value];
	// execute
	[processor processComment:comment withStore:store];
	// verify
	assertThatInteger([comment.paragraphs count], equalToInteger(3));
	[self assertFirstParagraph:[comment.paragraphs objectAtIndex:0]];
	[self assertSecondParagraph:[comment.paragraphs objectAtIndex:1]];
	[self assertThirdParagraph:[comment.paragraphs objectAtIndex:2]];
}

- (void)assertFirstParagraph:(GBCommentParagraph *)paragraph {
	[self assertParagraph:paragraph containsTexts:@"Short description.", nil];
}

- (void)assertSecondParagraph:(GBCommentParagraph *)paragraph {
	[self assertParagraph:paragraph containsItems:
	 [GBParagraphLinkItem class], @"Second", 
	 [GBParagraphTextItem class], @"paragraph with lot's of text split into two lines.", 
	 [GBParagraphListItem class], [NSNull null],
	 [GBParagraphSpecialItem class], @"Source line 1\n\n\tSource line with tab",
	 nil];
	[self assertList:[paragraph.paragraphItems objectAtIndex:2] describesHierarchy:
	 @"Nested 1", NO, 1,
	 @"Nested 1.1", NO, 2,
	 @"Nested 2", NO, 1,
	 @"Nested 2.1", YES, 2,
	 @"Nested 2.1.1", YES, 3,
	 @"Nested 2.2", YES, 2,
	 nil];
}

- (void)assertThirdParagraph:(GBCommentParagraph *)paragraph {
	[self assertParagraph:paragraph containsItems:
	 [GBParagraphTextItem class], @"Third paragraph.",
	 [GBParagraphSpecialItem class], [NSNull null],
	 [GBParagraphSpecialItem class], [NSNull null],
	 nil];
	
	GBParagraphSpecialItem *warning = [paragraph.paragraphItems objectAtIndex:1];
	assertThatInteger(warning.specialItemType, equalToInteger(GBSpecialItemTypeWarning));
	[self assertParagraph:warning.specialItemDescription containsItems:
	 [GBParagraphDecoratorItem class], @"Important:", 
	 [GBParagraphTextItem class], @"There is something important about this! We even write it in two lines!",
	 nil];
	
	GBParagraphSpecialItem *bug = [paragraph.paragraphItems objectAtIndex:2];
	assertThatInteger(bug.specialItemType, equalToInteger(GBSpecialItemTypeBug));
	[self assertParagraph:bug.specialItemDescription containsItems:
	 [GBParagraphDecoratorItem class], @"ID215:", 
	 [GBParagraphTextItem class], @"Khm, still not working...",
	 nil];
}

@end
