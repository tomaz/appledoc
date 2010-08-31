//
//  GBCommentParagraph.m
//  appledoc
//
//  Created by Tomaz Kragelj on 27.8.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBParagraphItem.h"
#import "GBCommentParagraph.h"

@implementation GBCommentParagraph

#pragma mark Initialization & disposal

+ (id)paragraph {
	return [[[self alloc] init] autorelease];
}

- (id)init {
	self = [super init];
	if (self) {
		_items = [[NSMutableArray alloc] init];
	}
	return self;
}

#pragma mark Items handling

- (void)registerItem:(GBParagraphItem *)item {
	NSParameterAssert(item != nil);
	GBLogDebug(@"Registering paragraph item of type %@...", [item className]);
	[_items addObject:item];
}

#pragma mark Properties

- (NSString *)stringValue {
	NSMutableString *result = [NSMutableString stringWithCapacity:1000];
	for (GBParagraphItem *item in self.items) {
		NSString *string = [item stringValue];
		if (item != [self.items lastObject] && ![string hasSuffix:@"\n"]) string = [string stringByAppendingString:@"\n"];
		[result appendString:string];
	}
	return result;
}

@synthesize items = _items;

@end
