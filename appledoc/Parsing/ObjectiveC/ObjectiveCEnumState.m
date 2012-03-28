//
//  ObjectiveCEnumState.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectiveCEnumState.h"

@implementation ObjectiveCEnumState

- (NSUInteger)parseStream:(TokensStream *)stream forParser:(ObjectiveCParser *)parser store:(Store *)store {
	// Enumeration can optionally have a name, we're only interested in values, so skip everything until {
	if ([stream matches:@"enum", nil]) {
		LogParDebug(@"Matched enum.");
		NSMutableString *declaration = [NSMutableString stringWithString:@"enum {\n"];
		NSArray *delimiters = [NSArray arrayWithObjects:@",", @"}", nil];
		
		// Match '{', exit if not found.
		LogParDebug(@"Matching enum body start.");
		GBResult result = [self matchStream:stream until:@"{" block:^(PKToken *token) { }];
		if (result == NSNotFound) {
			LogParDebug(@"Failed matching enum body start, bailing out.");
			[stream consume:1];
			[parser popState];
			return GBResultFailedMatch;
		}
		
		// Match all values up until '}', exit if not found.
		LogParDebug(@"Matching enum body.");
		result = [self matchStream:stream until:@"}" block:^(PKToken *token) {			
			if ([token matches:delimiters]) {
				LogParDebug(@"Matched %@.", token);
				return;
			}
			if ([token matches:@"="]) {
				LogParDebug(@"Matched %@, skipping value.", token);
				[stream consume:1];
				return;
			}
			LogParDebug(@"Matched enum constant %@", token);
			[declaration appendFormat:@"%@,\n", token.stringValue];
		}];
		if (result == NSNotFound) {
			LogParDebug(@"Failed matching }, bailing out.");
			[stream consume:1];
			[parser popState];
			return GBResultFailedMatch;
		}
		
		// Finish off.
		[declaration appendString:@"};"];
		LogParVerbose(@"%@", declaration);
		LogParVerbose(@"");
		[parser popState];
	} else {
		[stream consume:1];
		[parser popState];
		return GBResultFailedMatch;
	}
	return GBResultOk;
}

@end
