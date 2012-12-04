//
//  NSRegularExpression+Appledoc.m
//  appledoc
//
//  Created by Tomaz Kragelj on 1.11.12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "NSRegularExpression+Appledoc.h"

#define GBPattern(p,o) \
	static dispatch_once_t onceToken; \
	static NSRegularExpression *result; \
	dispatch_once(&onceToken, ^{ \
		result = [self regularExpressionWithPattern:p options:o error:nil]; \
	}); \
	return result; \

#pragma mark -

@implementation NSRegularExpression (Appledoc)

#pragma mark - Specific patterns

+ (NSRegularExpression *)gb_emptyLineMatchingExpression {
	GBPattern(@"\\n?^\\s*$\\n?", NSRegularExpressionAnchorsMatchLines)
}

+ (NSRegularExpression *)gb_wordMatchingExpression {
	GBPattern(@"[\\s.,;!?]+", 0)
}

+ (NSRegularExpression *)gb_remoteMemberMatchingExpression {
	GBPattern(@"([+-]?)\\[([^\\s]+)[ \\t]+([^\\s\\]]+)\\]", 0);
}

+ (NSRegularExpression *)gb_paramMatchingExpression {
	GBPattern(@"^(@param)\\s+(\\S+)\\s+", 0) // only at start of string!
}

+ (NSRegularExpression *)gb_exceptionMatchingExpression {
	GBPattern(@"^(@exception)\\s+(\\S+)\\s+", 0) // only at start of string!
}

+ (NSRegularExpression *)gb_returnMatchingExpression {
	GBPattern(@"^(@return)\\s+", 0) // only at start of string!
}

+ (NSRegularExpression *)gb_styledSectionDelimiterMatchingExpression {
	GBPattern(@"^(@warning|@bug)", NSRegularExpressionAnchorsMatchLines)
}

+ (NSRegularExpression *)gb_methodSectionDelimiterMatchingExpression {
	GBPattern(@"^(@param|@exception|@return)", NSRegularExpressionAnchorsMatchLines)
}

#pragma mark - First match handling

- (BOOL)gb_firstMatchIn:(NSString *)string match:(GBRegexMatchBlock)matchBlock {
	return [self gb_firstMatchIn:string options:0 match:matchBlock];
}

- (BOOL)gb_firstMatchIn:(NSString *)string options:(NSRegularExpressionOptions)options match:(GBRegexMatchBlock)matchBlock {
	return [self gb_firstMatchIn:string options:0 range:NSMakeRange(0, string.length) match:matchBlock];
}

- (BOOL)gb_firstMatchIn:(NSString *)string options:(NSRegularExpressionOptions)options range:(NSRange)range match:(GBRegexMatchBlock)matchBlock {
	NSTextCheckingResult *match = [self firstMatchInString:string options:options range:range];
	if (!match) return NO;
	matchBlock(match);
	return YES;
	
}

- (NSTextCheckingResult *)gb_firstMatchIn:(NSString *)string {
	return [self firstMatchInString:string options:0 range:NSMakeRange(0, string.length)];
}

#pragma mark - All matches handling

- (BOOL)gb_allMatchesIn:(NSString *)string match:(GBRegexAllMatchBlock)matchBlock {
	NSArray *matches = [self gb_allMatchesIn:string];
	[matches enumerateObjectsUsingBlock:^(NSTextCheckingResult *match, NSUInteger idx, BOOL *stop) {
		matchBlock(match, idx, stop);
	}];
	return (matches.count > 0);
}

- (NSArray *)gb_allMatchesIn:(NSString *)string {
	return [self matchesInString:string options:0 range:NSMakeRange(0, string.length)];
}

@end

#pragma mark - 

@implementation NSTextCheckingResult (Appledoc)

- (NSString *)gb_stringAtIndex:(NSUInteger)index in:(NSString *)string {
	NSRange range = [self rangeAtIndex:index];
	return [string substringWithRange:range];
}

- (NSString *)gb_prefixFromIndex:(NSUInteger)index in:(NSString *)string {
	NSUInteger location = self.range.location;
	NSRange range = NSMakeRange(index, location - index);
	return [string substringWithRange:range];
}

- (NSString *)gb_remainingStringIn:(NSString *)string {
	return [string substringFromIndex:self.range.location + self.range.length];
}

- (NSRange)gb_remainingRangeIn:(NSString *)string {
	NSRange result;
	result.location = self.range.location + self.range.length;
	result.length = string.length - result.location;
	return result;
}

- (BOOL)gb_isMatchedAtStart {
	return (self.range.location == 0);
}

@end
