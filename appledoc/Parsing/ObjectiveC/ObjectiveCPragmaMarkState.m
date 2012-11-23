//
//  ObjectiveCPragmaMarkState.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectiveCPragmaMarkState.h"

@interface ObjectiveCPragmaMarkState ()
@property (nonatomic, assign) NSUInteger startingLine;
@end

@implementation ObjectiveCPragmaMarkState

#pragma mark - Parsing

- (NSUInteger)parseWithData:(ObjectiveCParseData *)data {
	self.startingLine = data.stream.current.location.y;
	if (![self consumePragmaStartTokens:data]) return GBResultFailedMatch;
	if (![self parsePragmaDescription:data]) return GBResultOk; // we can
	return GBResultOk;
}

- (BOOL)consumePragmaStartTokens:(ObjectiveCParseData *)data {
	LogDebug(@"Matched #pragma mark.");
	[data.store setCurrentSourceInfo:data.stream.current];
	[data.stream consume:3]; // # pragma mark
	if ([data.stream matches:@"-", nil]) {
		LogDebug(@"Matched - (part of #pragma mark -)");
		[data.stream consume:1];
	}
	return YES;
}

- (BOOL)parsePragmaDescription:(ObjectiveCParseData *)data {
	if (![self isCurrentTokenOnStartingLine:data]) return GBResultOk;

	PKToken *firstDescriptionToken = data.stream.current;
	PKToken *lastDescriptionToken = [self consumeUntilLastPragmaDescriptionToken:data];
	if (!lastDescriptionToken) {
		LogDebug(@"No pragma mark description, bailing out!");
		[data.parser popState];
		return NO;
	}
	
	NSString *description = [self pragmaDescriptionFromStartToken:firstDescriptionToken endToken:lastDescriptionToken data:data];
	if (description.length == 0) {
		LogDebug(@"Empty pragma mark description, bailing out!");
		[data.parser popState];
		return NO;
	}
	
	LogDebug(@"Ending #pragma mark.");
	[data.store appendMethodGroupWithDescription:description];
	[data.parser popState];
	return YES;
}

#pragma mark - Helper methods

- (PKToken *)consumeUntilLastPragmaDescriptionToken:(ObjectiveCParseData *)data {
	PKToken *result = nil;
	while (!data.stream.eof && [self isCurrentTokenOnStartingLine:data]) {
		LogDebug(@"Matched '%@'.", data.stream.current);
		result = data.stream.current;
		[data.stream consume:1];
	}
	return result;
}

- (NSString *)pragmaDescriptionFromStartToken:(PKToken *)start endToken:(PKToken *)end data:(ObjectiveCParseData *)data {
	NSUInteger startIndex = start.offset;
	NSUInteger endIndex = end.offset + end.stringValue.length;
	NSRange range = NSMakeRange(startIndex, endIndex - startIndex);
	NSString *description = [data.stream.string substringWithRange:range];
	NSString *trimmed = [description stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	return trimmed;
}

- (BOOL)isCurrentTokenOnStartingLine:(ObjectiveCParseData *)data {
	if (data.stream.eof) {
		LogDebug(@"End of tokens reached, bailing out.");
		[data.parser popState];
		return NO;
	} else if (data.stream.current.location.y != self.startingLine) {
		LogDebug(@"End of line reached, bailing out.");
		[data.parser popState];
		return NO;
	}
	return YES;
}

@end
