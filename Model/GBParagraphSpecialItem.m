//
//  GBParagraphSpecialItem.m
//  appledoc
//
//  Created by Tomaz Kragelj on 1.9.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBCommentParagraph.h"
#import "GBParagraphSpecialItem.h"

@implementation GBParagraphSpecialItem

#pragma mark Initialization & disposal

+ (id)specialItemWithType:(GBSpecialItemType)type {
	return [self specialItemWithType:type stringValue:nil];
}

+ (id)specialItemWithType:(GBSpecialItemType)type stringValue:(NSString *)value {
	GBParagraphSpecialItem *result = [[[self alloc] init] autorelease];
	result.specialItemType = type;
	result.stringValue = value;
	return result;
}

#pragma mark Helper methods

- (void)registerParagraph:(GBCommentParagraph *)paragraph {
	_description = [paragraph retain];
}

#pragma mark Properties

@synthesize description = _description;
@synthesize specialItemType;

@end
