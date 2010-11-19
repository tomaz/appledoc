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
	result.isOrdered = ordered;
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
	GBLogDebug(@"%@: Registering %@...", self, item);
	[_items addObject:item];
}

- (BOOL)isOrderedListItem {
	return self.isOrdered;
}

- (BOOL)isUnorderedListItem {
	return !self.isOrdered;
}

#pragma mark Overriden methods

- (NSString *)stringValue {
	NSMutableString *description = [NSMutableString stringWithCapacity:1000];	
	[self.listItems enumerateObjectsUsingBlock:^(GBCommentParagraph *paragraph, NSUInteger idx, BOOL *stop) {
		[description appendFormat:@"%@ %@ ", self.isOrdered ? @"#" : @"-", [paragraph stringValue]];
	}];
	NSString *trimmed = [description stringByReplacingOccurrencesOfString:@"  " withString:@" "];
	return [trimmed normalizedDescription];
}

- (NSString *)descriptionStringValue {
	NSMutableString *result = [NSMutableString stringWithFormat:@"%@{ ", [super descriptionStringValue]];
	if ([self.listItems count] > 1) [result appendString:@"\n"];
	[self.listItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		[result appendString:[obj description]];
		if (idx < [self.listItems count]-1) [result appendString:@",\n"];
	}];
	[result appendString:([self.listItems count] > 1) ? @"\n}" : @" }"];
	return result;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"List '%@'", [super description]];
}

#pragma mark Properties

@synthesize listItems = _items;
@synthesize isOrdered;

@end
