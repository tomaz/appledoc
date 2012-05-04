//
//  ObjectiveCPragmaMarkState.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectiveCPragmaMarkState.h"

@implementation ObjectiveCPragmaMarkState

- (NSUInteger)parseWithData:(ObjectiveCParseData *)data {
	LogParDebug(@"Matched #pragma mark.");
	NSUInteger line = data.stream.current.location.y;
	[data.store setCurrentSourceInfo:data.stream.current];
	
	// Consume #pragma mark [-], exit if nothing else is found afterwards.
	[data.stream consume:3];
	if ([data.stream matches:@"-", nil]) {
		LogParDebug(@"Matched - (part of #pragma mark -)");
		[data.stream consume:1];
	}
	if (data.stream.eof) {
		LogParDebug(@"End of line reached, bailing out.");
		[data.parser popState];
		return GBResultOk;
	}
	
	// Get all words until the end of line. Note that last description token will only be non-nil if at least one word is found on the same line!
	PKToken *firstDescriptionToken = data.stream.current;
	PKToken *lastDescriptionToken = nil;
	while (!data.stream.eof && data.stream.current.location.y == line) {
		LogParDebug(@"Matched %@.", data.stream.current);
		lastDescriptionToken = data.stream.current;
		[data.stream consume:1];
	}
	
	// If we didn't find a description, exit.
	if (!lastDescriptionToken) {
		LogParDebug(@"No pragma mark description, bailing out!");
		[data.parser popState];
		return GBResultOk;
	}
	
	// Get the description and trim it. Exit if trimmed text is empty.
	NSUInteger startIndex = firstDescriptionToken.offset;
	NSUInteger endIndex = lastDescriptionToken.offset + lastDescriptionToken.stringValue.length;
	NSRange range = NSMakeRange(startIndex, endIndex - startIndex);
	NSString *description = [data.stream.string substringWithRange:range];
	NSString *trimmed = [description stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if (trimmed.length == 0) {
		LogParDebug(@"Empty pragma mark description, bailing out!");
		[data.parser popState];
		return GBResultOk;
	}
	
	// Found description, so register.
	LogParDebug(@"Ending #pragma mark.");
	[data.store appendMethodGroupWithDescription:trimmed];
	[data.parser popState];
	return GBResultOk;
}

@end
