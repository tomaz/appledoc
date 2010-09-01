//
//  GBParagraphListItem.m
//  appledoc
//
//  Created by Tomaz Kragelj on 31.8.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBParagraphListItem.h"

@interface GBParagraphListItem ()

+ (id)newParagraphListItemWithOrderedValue:(BOOL)ordered;

@end

#pragma mark -

@implementation GBParagraphListItem

#pragma mark Initialization & disposal

+ (id)orderedParagraphListItem {
	return [self newParagraphListItemWithOrderedValue:YES];
}

+ (id)unorderedParagraphListItem {
	return [self newParagraphListItemWithOrderedValue:NO];
}

+ (id)newParagraphListItemWithOrderedValue:(BOOL)ordered {
	GBParagraphListItem *result = [[[self alloc] init] autorelease];
	result.ordered = ordered;
	return result;
}

- (id)init {
	self = [super init];
	if (self) {
		_items = [[NSMutableArray alloc] init];
	}
	return self;
}

#pragma mark Helper methods

- (void)registerItem:(GBCommentParagraph *)item {
	NSParameterAssert(item != nil);
	[_items addObject:item];
}

#pragma mark Properties

@synthesize items = _items;
@synthesize ordered;

@end
