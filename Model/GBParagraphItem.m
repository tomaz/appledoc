//
//  GBParagraphItem.m
//  appledoc
//
//  Created by Tomaz Kragelj on 30.8.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "RegexKitLite.h"
#import "GBParagraphItem.h"

@implementation GBParagraphItem

#pragma mark Initialization & disposal

+ (id)paragraphItem {
	return [[[self alloc] init] autorelease];
}

+ (id)paragraphItemWithStringValue:(NSString *)value {
	GBParagraphItem *result = [self paragraphItem];
	result.stringValue = value;
	return result;
}

#pragma mark Overriden methods

- (NSString *)description {
	if (!self.stringValue) return @"";
	return [self.stringValue normalizedDescription];
}

- (NSString *)debugDescription {
	return [NSString stringWithFormat:@"%@ '%@'", [self className], [self descriptionStringValue]];
}

- (NSString *)descriptionStringValue {
	return [NSString stringWithFormat:@"%@", [self.stringValue normalizedDescription]];
}

#pragma mark Output generator helpers

- (BOOL)isTextItem {
	return NO;
}

- (BOOL)isOrderedListItem {
	return NO;
}

- (BOOL)isUnorderedListItem {
	return NO;
}

- (BOOL)isWarningSpecialItem {
	return NO;
}

- (BOOL)isBugSpecialItem {
	return NO;
}

- (BOOL)isExampleSpecialItem {
	return NO;
}

- (BOOL)isBoldDecoratorItem {
	return NO;
}

- (BOOL)isItalicsDecoratorItem {
	return NO;
}

- (BOOL)isCodeDecoratorItem {
	return NO;
}

- (BOOL)isLinkItem {
	return NO;
}

#pragma mark Properties

@synthesize stringValue;

@end
