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
		
		// Consume #pragma mark [-]
		[stream consume:3];
		if ([stream matches:@"-", nil]) [stream consume:1];
		
		// Get all words until the end of line.
		NSMutableString *description = [NSMutableString string];
		while (stream.current.location.y == line) {
			LogParDebug(@"Matched %@.", stream.current);
			[description appendFormat:@"%@ ", stream.current.stringValue];
			[stream consume:1];
		}
		
		// Trim description and clean up.
		NSString *trimmed = [description stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		if (trimmed.length == 0)
			LogParDebug(@"Empty pragma mark description, bailing out!");
		else
			LogParVerbose(@"#pragma mark %@", trimmed);
		[parser popState];
	} else {
		[stream consume:1];
		[parser popState];
		return GBResultFailedMatch;
	}
	return GBResultOk;
}

@end
