//
//  ObjectiveCPragmaMarkState.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectiveCPragmaMarkState.h"

@implementation ObjectiveCPragmaMarkState

- (NSUInteger)parseStream:(TokensStream *)stream forParser:(ObjectiveCParser *)parser store:(Store *)store {
	if ([stream matches:@"#", @"pragma", @"mark", nil]) {
		LogParDebug(@"Matched #pragma mark.");
		NSUInteger line = stream.current.location.y;
		[store setCurrentSourceInfo:stream.current];
		
		// Consume #pragma mark [-], exit if nothing else is found afterwards.
		[stream consume:3];
		if ([stream matches:@"-", nil]) {
			LogParDebug(@"Matched - (part of #pragma mark -)");
			[stream consume:1];
		}
		if (stream.eof) {
			LogParDebug(@"End of line reached, bailing out.");
			[parser popState];
			return GBResultOk;
		}
		
		// Get all words until the end of line. Note that last description token will only be non-nil if at least one word is found on the same line!
		PKToken *firstDescriptionToken = stream.current;
		PKToken *lastDescriptionToken = nil;
		while (!stream.eof && stream.current.location.y == line) {
			LogParDebug(@"Matched %@.", stream.current);
			lastDescriptionToken = stream.current;
			[stream consume:1];
		}
		
		// If we didn't find a description, exit.
		if (!lastDescriptionToken) {
			LogParDebug(@"No pragma mark description, bailing out!");
			[parser popState];
			return GBResultOk;
		}
		
		// Get the description and trim it. Exit if trimmed text is empty.
		NSUInteger startIndex = firstDescriptionToken.offset;
		NSUInteger endIndex = lastDescriptionToken.offset + lastDescriptionToken.stringValue.length;
		NSRange range = NSMakeRange(startIndex, endIndex - startIndex);
		NSString *description = [stream.string substringWithRange:range];
		NSString *trimmed = [description stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		if (trimmed.length == 0) {
			LogParDebug(@"Empty pragma mark description, bailing out!");
			[parser popState];
			return GBResultOk;
		}
		
		// Found description, so register.
		LogParVerbose(@"");
		LogParVerbose(@"#pragma mark %@", trimmed);
		LogParVerbose(@"");
		[store beginMethodGroup];
		[store appendDescription:trimmed];
		[store endCurrentObject];
		[parser popState];
	} else {
		[stream consume:1];
		[parser popState];
		return GBResultFailedMatch;
	}
	return GBResultOk;
}

@end
