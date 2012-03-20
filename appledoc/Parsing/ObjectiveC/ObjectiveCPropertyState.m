//
//  ObjectiveCPropertyState.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "ObjectiveCPropertyState.h"

@implementation ObjectiveCPropertyState

- (NSUInteger)parseStream:(TokensStream *)stream forParser:(ObjectiveCParser *)parser store:(Store *)store {
	// Match property, then return to previous stream. If current stream position doesn't start a property, consume one token and return.
	if ([stream matches:@"@", @"property", nil]) {
		LogParDebug(@"Matched property definition.");
		NSMutableString *declaration = [NSMutableString stringWithString:@"@property "];
		NSUInteger found;
		[stream consume:2];
		
		// Parse attributes.
		LogParDebug(@"Matching attributes...");
		found = [self matchStream:stream start:@"(" end:@")" block:^(PKToken *token) {
			LogParDebug(@"Matched %@.", token);
			[declaration appendFormat:@"%@ ", token.stringValue];
		}];
		if (found == NSNotFound) {
			LogParDebug(@"Failed matching attributes, bailing out.");
			[parser popState];
			return GBResultFailedMatch;
		}
		
		// Parse declaration.
		LogParDebug(@"Matching types and name.");
		found = [self matchStream:stream start:nil end:@";" block:^(PKToken *token) {
			LogParDebug(@"Matched %@.", token);
			[declaration appendFormat:@"%@ ", token.stringValue];
		}];
		if (found == NSNotFound) {
			LogParDebug(@"Failed matching type and name, bailing out.");
			[parser popState]; 
			return GBResultFailedMatch;
		}
		
		LogParVerbose(@"%@", declaration);
		[parser popState];
	} else {
		[stream consume:1];
		[parser popState];
	}
	return GBResultOk;
}

@end
