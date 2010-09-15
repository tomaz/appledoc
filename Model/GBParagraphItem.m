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
	return [NSString stringWithFormat:@"%@ %@", [self className], [self descriptionStringValue]];
}

- (NSString *)descriptionStringValue {
	NSString *extract = [self.stringValue stringByReplacingOccurrencesOfRegex:@"\\s+" withString:@" "];
	extract = [extract substringToIndex:MIN(35,[extract length])];
	extract = [extract stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	BOOL missing = ([extract length] < [self.stringValue length]);
	return [NSString stringWithFormat:@"'%@%@'", extract, missing ? @"*" : @""];
}

#pragma mark Properties

@synthesize stringValue;

@end
