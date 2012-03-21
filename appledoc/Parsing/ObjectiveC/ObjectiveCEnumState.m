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
		[self skipStream:stream until:@"{" block:^(PKToken *token) { }];
		[self skipStream:stream until:@"}" block:^(PKToken *token) {
			if ([token matches:@","]) return;
			if ([token matches:@"}"]) return;
			if ([token matches:@"="]) {
				[stream consume:1];
				return;
			}
			LogParDebug(@"Matched enum constant %@", token);
			[declaration appendFormat:@"%@,\n", token.stringValue];
		}];
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
