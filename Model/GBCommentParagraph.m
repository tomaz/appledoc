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
	GBLogDebug(@"%@: Registering %@...", self, item);
	[_items addObject:item];
}

#pragma mark Overriden methods

- (NSString *)description {
	NSString *desc = [self.stringValue length] > 0 ? [self.stringValue normalizedDescription] : @"";
	return [NSString stringWithFormat:@"Paragraph '%@'", desc];
}

- (NSString *)debugDescription {
	NSMutableString *result = [NSMutableString stringWithFormat:@"%@{ ", [self className]];
	if ([self.paragraphItems count] > 1) [result appendString:@"\n"];
	[self.paragraphItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		[result appendString:[obj debugDescription]];
		if (idx < [self.paragraphItems count]-1) [result appendString:@",\n"];
	}];
	[result appendString:([self.paragraphItems count] > 1) ? @"\n}" : @" }"];
	return result;
}

#pragma mark Properties

- (NSString *)stringValue {
	NSMutableString *result = [NSMutableString stringWithCapacity:1000];
	for (GBParagraphItem *item in self.paragraphItems) {
		NSString *string = [item stringValue];
		if (item != [self.paragraphItems lastObject] && ![string hasSuffix:@"\n"]) string = [string stringByAppendingString:@"\n"];
		[result appendString:string];
	}
	return result;
}

@synthesize paragraphItems = _items;

@end
