//
//  GBCommentKeywordsProvider.m
//  appledoc
//
//  Created by Tomaz Kragelj on 30.8.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBCommentComponentsProvider.h"

@interface GBCommentComponentsProvider ()

- (BOOL)string:(NSString *)string startsWithKeyword:(NSString *)keyword;
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
	return ([self string:string startsWithKeyword:@"sa"] || [self string:string startsWithKeyword:@"see"]);
}

#pragma mark Helper methods

- (BOOL)string:(NSString *)string startsWithKeyword:(NSString *)keyword {
	// Note that this method doesn't require special keyword prefix - it would take any character as long as it's followed by the given keyword and at least one delimiter char! This method is only valid for testing keywords that are followed by some text!
	if ([keyword length] == 0) return NO;
	if ([string length] < [keyword length] + 2) return NO;
	
	// Trim the string and prepare the range for testing the keyword after the prefix char.
	string = [string stringByTrimmingCharactersInSet:self.delimitersSet];
	NSRange range = NSMakeRange(1, [keyword length]);

	// Apply all tests: we only allow if we find the keyword after the prefix char followed by a delimiter.
	if (![[string substringWithRange:range] isEqualToString:keyword]) return NO;
	if (![self.delimitersSet characterIsMember:[string characterAtIndex:range.location + range.length]]) return NO;
	return YES;
}

#pragma mark Properties

@synthesize delimitersSet;

@end
