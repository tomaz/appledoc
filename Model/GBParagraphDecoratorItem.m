//
//  GBParagraphDecoratorItem.m
//  appledoc
//
//  Created by Tomaz Kragelj on 2.9.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBParagraphDecoratorItem.h"

@implementation GBParagraphDecoratorItem

#pragma mark Initialization & disposal

- (id)init {
	self = [super init];
	if (self) {
		_decoratedItems = [NSMutableArray array];
	}
	return self;
}

#pragma mark Registrations handling

- (void)registerItem:(GBParagraphItem *)item {
	NSParameterAssert(item != nil);
	GBLogDebug(@"Registering item %@...", item);
	[_decoratedItems addObject:item];
}

- (void)replaceItemsByRegisteringItemsFromArray:(NSArray *)items {
	GBLogDebug(@"Registering %ld items...", [items count]);
	if (!items || [items count] == 0) return;
	[_decoratedItems removeAllObjects];
	[items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		[self registerItem:obj];
	}];
}

#pragma mark Overriden methods

- (NSString *)descriptionStringValue {
	NSMutableString *result = [NSMutableString stringWithFormat:@"%@{", [super descriptionStringValue]];
	if ([self.decoratedItems count] > 1) [result appendString:@"\n"];
	[self.decoratedItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		[result appendString:[obj description]];
		if (idx < [self.decoratedItems count]-1) [result appendString:@",\n"];
	}];
	[result appendString:([self.decoratedItems count] > 1) ? @"\n}" : @" }"];
	return result;
}

#pragma mark Properties

@synthesize decoratedItems = _decoratedItems;
@synthesize decorationType;

@end
