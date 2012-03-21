//
//  ObjectiveCMethodState.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectiveCMethodState.h"

@implementation ObjectiveCMethodState

- (NSUInteger)parseStream:(TokensStream *)stream forParser:(ObjectiveCParser *)parser store:(Store *)store {
	// Match method definition or declaration (skipping body in later case), then return to previous stream. If current stream position doesn't start a method, consume one token and return.
	if ([stream matches:@"-", nil] || [stream matches:@"+", nil]) {
		LogParDebug(@"Matched %@, testing for method.", stream.current);
		NSMutableString *declaration = [NSMutableString stringWithString:stream.current.stringValue];
		NSUInteger matchedEndTokenIndex;
		[stream consume:1];
		
		// Parse return types.
		LogParDebug(@"Matching method result...");
		matchedEndTokenIndex = [self matchStream:stream start:@"(" end:@")" block:^(PKToken *token) {
			LogParDebug(@"Matched %@.", token);
			[declaration appendFormat:@"%@ ", token.stringValue];
		}];
		if (matchedEndTokenIndex == NSNotFound) { 
			LogParDebug(@"Failed matching method result, bailing out!");
			[parser popState];
			return GBResultFailedMatch;
		}
		
		// Parse components.
		LogParDebug(@"Matching method arguments.");
		NSArray *end = [NSArray arrayWithObjects:@";", @"{", nil];
		matchedEndTokenIndex = [self skipStream:stream until:end block:^(PKToken *token) {
			LogParDebug(@"Matched %@.", token);
			[declaration appendFormat:@"%@ ", token.stringValue];
		}];
		if (matchedEndTokenIndex == NSNotFound) {
			LogParDebug(@"Failed matching method arguments, bailing out!");
			[parser popState];
			return GBResultFailedMatch;
		}
		
		// Skip method code block.
		if (matchedEndTokenIndex == 1) {
			LogParDebug(@"Skipping method code block...");
			__block NSUInteger blockLevel = 1;
			NSUInteger tokensCount = [self lookAheadStream:stream block:^(PKToken *token, BOOL *stop) {
				if ([token matches:@"{"]) {
					LogParDebug(@"Matched open brace at block level %lu", blockLevel);
					blockLevel++;
				} else if ([token matches:@"}"]) {
					if (blockLevel == 1) {
						LogParDebug(@"Matched method close brace");
						*stop = YES;
					} else {
						LogParDebug(@"Matched close brace at block level %lu", blockLevel);
						blockLevel--;
					}
				}
			}];
			[stream consume:tokensCount];
			[declaration appendString:@"}"];
		}
		
		LogParVerbose(@"%@", declaration);
		[parser popState];
	} else {
		[stream consume:1];
		[parser popState];
		return GBResultFailedMatch;
	}
	return GBResultOk;
}

@end
