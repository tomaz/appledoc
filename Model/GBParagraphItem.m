//
//  GBParagraphItem.m
//  appledoc
//
//  Created by Tomaz Kragelj on 30.8.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

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
	NSUInteger length = [self.stringValue length];
	NSString *extract = (length > 0) ? [self.stringValue substringToIndex:MIN(15,length)] : @"";
	BOOL missing = ([extract length] < length);
	return [NSString stringWithFormat:@"%@: %@%@%@", [self className], self.descriptionPrefix, extract, missing ? @"..." : @""];
}

- (NSString *)descriptionPrefix {
	return @"";
}

#pragma mark Properties

@synthesize stringValue;

@end
