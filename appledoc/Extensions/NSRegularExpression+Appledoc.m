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

+ (NSRegularExpression *)gb_paramMatchingRegularExpression {
	GBPattern(@"^@param\\s+(\\S+)\\s+", NSRegularExpressionAnchorsMatchLines)
}

+ (NSRegularExpression *)gb_argumentMatchingRegularExpression {
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

#pragma mark - All matches handling

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

- (NSString *)gb_remainingStringIn:(NSString *)string {
	return [string substringFromIndex:self.range.location + self.range.length];
}

@end
