//
//  GBParagraphItemsTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 19.11.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBStore.h"

@interface GBParagraphItemsTesting : GHTestCase
@end
	
@implementation GBParagraphItemsTesting

- (void)testParagraphItem_shouldReturnNoForAllOutputHelpers {
	// setup & execute
	GBParagraphItem *item = [GBParagraphItem paragraphItem];
	// verify
	assertThatBool(item.isTextItem, equalToBool(NO));
	assertThatBool(item.isOrderedListItem, equalToBool(NO));
	assertThatBool(item.isUnorderedListItem, equalToBool(NO));
	assertThatBool(item.isWarningSpecialItem, equalToBool(NO));
	assertThatBool(item.isBugSpecialItem, equalToBool(NO));
	assertThatBool(item.isExampleSpecialItem, equalToBool(NO));
	assertThatBool(item.isBoldDecoratorItem, equalToBool(NO));
	assertThatBool(item.isItalicsDecoratorItem, equalToBool(NO));
	assertThatBool(item.isCodeDecoratorItem, equalToBool(NO));
	assertThatBool(item.isLinkItem, equalToBool(NO));
}

- (void)testParagraphTextItem_shouldReturnYesForTextItemOutputHelper {
	// setup & execute
	GBParagraphTextItem *item = [GBParagraphTextItem paragraphItem];
	// verify
	assertThatBool(item.isTextItem, equalToBool(YES));
	assertThatBool(item.isOrderedListItem, equalToBool(NO));
	assertThatBool(item.isUnorderedListItem, equalToBool(NO));
	assertThatBool(item.isWarningSpecialItem, equalToBool(NO));
	assertThatBool(item.isBugSpecialItem, equalToBool(NO));
	assertThatBool(item.isExampleSpecialItem, equalToBool(NO));
	assertThatBool(item.isBoldDecoratorItem, equalToBool(NO));
	assertThatBool(item.isItalicsDecoratorItem, equalToBool(NO));
	assertThatBool(item.isCodeDecoratorItem, equalToBool(NO));
	assertThatBool(item.isLinkItem, equalToBool(NO));
}

- (void)testParagraphListItem_shouldReturnYesForOrderedListOutputHelper {
	// setup & execute
	GBParagraphListItem *item = [GBParagraphListItem orderedParagraphListItem];
	// verify
	assertThatBool(item.isTextItem, equalToBool(NO));
	assertThatBool(item.isOrderedListItem, equalToBool(YES));
	assertThatBool(item.isUnorderedListItem, equalToBool(NO));
	assertThatBool(item.isWarningSpecialItem, equalToBool(NO));
	assertThatBool(item.isBugSpecialItem, equalToBool(NO));
	assertThatBool(item.isExampleSpecialItem, equalToBool(NO));
	assertThatBool(item.isBoldDecoratorItem, equalToBool(NO));
	assertThatBool(item.isItalicsDecoratorItem, equalToBool(NO));
	assertThatBool(item.isCodeDecoratorItem, equalToBool(NO));
	assertThatBool(item.isLinkItem, equalToBool(NO));
}

- (void)testParagraphListItem_shouldReturnYesForUnorderedListOutputHelper {
	// setup & execute
	GBParagraphListItem *item = [GBParagraphListItem unorderedParagraphListItem];
	// verify
	assertThatBool(item.isTextItem, equalToBool(NO));
	assertThatBool(item.isOrderedListItem, equalToBool(NO));
	assertThatBool(item.isUnorderedListItem, equalToBool(YES));
	assertThatBool(item.isWarningSpecialItem, equalToBool(NO));
	assertThatBool(item.isBugSpecialItem, equalToBool(NO));
	assertThatBool(item.isExampleSpecialItem, equalToBool(NO));
	assertThatBool(item.isBoldDecoratorItem, equalToBool(NO));
	assertThatBool(item.isItalicsDecoratorItem, equalToBool(NO));
	assertThatBool(item.isCodeDecoratorItem, equalToBool(NO));
	assertThatBool(item.isLinkItem, equalToBool(NO));
}

- (void)testParagraphSpecialItem_shouldReturnYesForWarningOutputHelpers {
	// setup & execute
	GBParagraphSpecialItem *item = [GBParagraphSpecialItem specialItemWithType:GBSpecialItemTypeWarning];
	// verify
	assertThatBool(item.isTextItem, equalToBool(NO));
	assertThatBool(item.isOrderedListItem, equalToBool(NO));
	assertThatBool(item.isUnorderedListItem, equalToBool(NO));
	assertThatBool(item.isWarningSpecialItem, equalToBool(YES));
	assertThatBool(item.isBugSpecialItem, equalToBool(NO));
	assertThatBool(item.isExampleSpecialItem, equalToBool(NO));
	assertThatBool(item.isBoldDecoratorItem, equalToBool(NO));
	assertThatBool(item.isItalicsDecoratorItem, equalToBool(NO));
	assertThatBool(item.isCodeDecoratorItem, equalToBool(NO));
	assertThatBool(item.isLinkItem, equalToBool(NO));
}

- (void)testParagraphSpecialItem_shouldReturnYesForBugOutputHelpers {
	// setup & execute
	GBParagraphSpecialItem *item = [GBParagraphSpecialItem specialItemWithType:GBSpecialItemTypeBug];
	// verify
	assertThatBool(item.isTextItem, equalToBool(NO));
	assertThatBool(item.isOrderedListItem, equalToBool(NO));
	assertThatBool(item.isUnorderedListItem, equalToBool(NO));
	assertThatBool(item.isWarningSpecialItem, equalToBool(NO));
	assertThatBool(item.isBugSpecialItem, equalToBool(YES));
	assertThatBool(item.isExampleSpecialItem, equalToBool(NO));
	assertThatBool(item.isBoldDecoratorItem, equalToBool(NO));
	assertThatBool(item.isItalicsDecoratorItem, equalToBool(NO));
	assertThatBool(item.isCodeDecoratorItem, equalToBool(NO));
	assertThatBool(item.isLinkItem, equalToBool(NO));
}

- (void)testParagraphSpecialItem_shouldReturnYesForExampleOutputHelpers {
	// setup & execute
	GBParagraphSpecialItem *item = [GBParagraphSpecialItem specialItemWithType:GBSpecialItemTypeExample];
	// verify
	assertThatBool(item.isTextItem, equalToBool(NO));
	assertThatBool(item.isOrderedListItem, equalToBool(NO));
	assertThatBool(item.isUnorderedListItem, equalToBool(NO));
	assertThatBool(item.isWarningSpecialItem, equalToBool(NO));
	assertThatBool(item.isBugSpecialItem, equalToBool(NO));
	assertThatBool(item.isExampleSpecialItem, equalToBool(YES));
	assertThatBool(item.isBoldDecoratorItem, equalToBool(NO));
	assertThatBool(item.isItalicsDecoratorItem, equalToBool(NO));
	assertThatBool(item.isCodeDecoratorItem, equalToBool(NO));
	assertThatBool(item.isLinkItem, equalToBool(NO));
}

- (void)testParagraphItem_shouldReturnYesForBoldOutputHelpers {
	// setup
	GBParagraphDecoratorItem *item = [GBParagraphDecoratorItem paragraphItem];
	// execute
	item.decorationType = GBDecorationTypeBold;
	// verify
	assertThatBool(item.isTextItem, equalToBool(NO));
	assertThatBool(item.isOrderedListItem, equalToBool(NO));
	assertThatBool(item.isUnorderedListItem, equalToBool(NO));
	assertThatBool(item.isWarningSpecialItem, equalToBool(NO));
	assertThatBool(item.isBugSpecialItem, equalToBool(NO));
	assertThatBool(item.isExampleSpecialItem, equalToBool(NO));
	assertThatBool(item.isBoldDecoratorItem, equalToBool(YES));
	assertThatBool(item.isItalicsDecoratorItem, equalToBool(NO));
	assertThatBool(item.isCodeDecoratorItem, equalToBool(NO));
	assertThatBool(item.isLinkItem, equalToBool(NO));
}

- (void)testParagraphItem_shouldReturnYesForItalicsOutputHelpers {
	// setup
	GBParagraphDecoratorItem *item = [GBParagraphDecoratorItem paragraphItem];
	// execute
	item.decorationType = GBDecorationTypeItalics;
	// verify
	assertThatBool(item.isTextItem, equalToBool(NO));
	assertThatBool(item.isOrderedListItem, equalToBool(NO));
	assertThatBool(item.isUnorderedListItem, equalToBool(NO));
	assertThatBool(item.isWarningSpecialItem, equalToBool(NO));
	assertThatBool(item.isBugSpecialItem, equalToBool(NO));
	assertThatBool(item.isExampleSpecialItem, equalToBool(NO));
	assertThatBool(item.isBoldDecoratorItem, equalToBool(NO));
	assertThatBool(item.isItalicsDecoratorItem, equalToBool(YES));
	assertThatBool(item.isCodeDecoratorItem, equalToBool(NO));
	assertThatBool(item.isLinkItem, equalToBool(NO));
}

- (void)testParagraphItem_shouldReturnYesForCodeOutputHelpers {
	// setup
	GBParagraphDecoratorItem *item = [GBParagraphDecoratorItem paragraphItem];
	// execute
	item.decorationType = GBDecorationTypeCode;
	// verify
	assertThatBool(item.isTextItem, equalToBool(NO));
	assertThatBool(item.isOrderedListItem, equalToBool(NO));
	assertThatBool(item.isUnorderedListItem, equalToBool(NO));
	assertThatBool(item.isWarningSpecialItem, equalToBool(NO));
	assertThatBool(item.isBugSpecialItem, equalToBool(NO));
	assertThatBool(item.isExampleSpecialItem, equalToBool(NO));
	assertThatBool(item.isBoldDecoratorItem, equalToBool(NO));
	assertThatBool(item.isItalicsDecoratorItem, equalToBool(NO));
	assertThatBool(item.isCodeDecoratorItem, equalToBool(YES));
	assertThatBool(item.isLinkItem, equalToBool(NO));
}

- (void)testParagraphItem_shouldReturnYesForLinkOutputHelpers {
	// setup & execute
	GBParagraphLinkItem *item = [GBParagraphLinkItem paragraphItem];
	// verify
	assertThatBool(item.isTextItem, equalToBool(NO));
	assertThatBool(item.isOrderedListItem, equalToBool(NO));
	assertThatBool(item.isUnorderedListItem, equalToBool(NO));
	assertThatBool(item.isWarningSpecialItem, equalToBool(NO));
	assertThatBool(item.isBugSpecialItem, equalToBool(NO));
	assertThatBool(item.isExampleSpecialItem, equalToBool(NO));
	assertThatBool(item.isBoldDecoratorItem, equalToBool(NO));
	assertThatBool(item.isItalicsDecoratorItem, equalToBool(NO));
	assertThatBool(item.isCodeDecoratorItem, equalToBool(NO));
	assertThatBool(item.isLinkItem, equalToBool(YES));
}

@end
