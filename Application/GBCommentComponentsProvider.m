//
//  GBCommentKeywordsProvider.m
//  appledoc
//
//  Created by Tomaz Kragelj on 30.8.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "RegexKitLite.h"
#import "GBCommentComponentsProvider.h"

@interface GBCommentComponentsProvider ()

- (BOOL)string:(NSString *)string startsWithKeyword:(NSString *)keyword;
- (BOOL)string:(NSString *)string matchesRegex:(NSString *)regex;
@property (retain) NSCharacterSet *delimitersSet;

@end

#pragma mark -

@implementation GBCommentComponentsProvider

#pragma mark Initialization & disposal

+ (id)provider {
	return [[[self alloc] init] autorelease];
}

- (id)init {
	self = [super init];
	if (self) {
		self.delimitersSet = [NSCharacterSet whitespaceCharacterSet];
	}
	return self;
}

#pragma mark Public interface

- (BOOL)stringDefinesOrderedList:(NSString *)string {
	NSString *regex = @"^\\s*[0-9]+\\.\\s+";	// optional WS, followed by list delimiter and dot, followed by at least one WS
	return [self string:string matchesRegex:regex];
}

- (BOOL)stringDefinesUnorderedList:(NSString *)string {
	NSString *regex = @"^\\s*[-+*o]\\s+";	// optional WS, followed by list delimiter, followed by at least one WS
	return [self string:string matchesRegex:regex];
}

- (BOOL)stringDefinesWarning:(NSString *)string {
	return [self string:string startsWithKeyword:@"warning"];
}

- (BOOL)stringDefinesBug:(NSString *)string {
	return [self string:string startsWithKeyword:@"bug"];
}

- (BOOL)stringDefinesParameter:(NSString *)string {
	return [self string:string startsWithKeyword:@"param"];
}

- (BOOL)stringDefinesReturn:(NSString *)string {
	return [self string:string startsWithKeyword:@"return"];
}

- (BOOL)stringDefinesException:(NSString *)string {
	return [self string:string startsWithKeyword:@"exception"];
}

- (BOOL)stringDefinesCrossReference:(NSString *)string {
	NSString *regex = @"^\\s*.(sa|see)";
	return [self string:string matchesRegex:regex];
}

#pragma mark Helper methods

- (BOOL)string:(NSString *)string startsWithKeyword:(NSString *)keyword {
	// Note that this method doesn't require special keyword prefix - it would take any character as long as it's followed by the given keyword and at least one delimiter char! This method is only valid for testing keywords that are followed by some text!
	if ([keyword length] == 0) return NO;
	if ([string length] < [keyword length] + 2) return NO;
	NSString *regex = [NSString stringWithFormat:@"^\\s*.%@", keyword];
	return [self string:string matchesRegex:regex];
}

- (BOOL)string:(NSString *)string matchesRegex:(NSString *)regex {
	return [string isMatchedByRegex:regex];
}

#pragma mark Properties

@synthesize delimitersSet;

@end
