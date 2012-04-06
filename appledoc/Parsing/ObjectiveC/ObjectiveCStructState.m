//
//  ObjectiveCStructState.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectiveCStructState.h"

@implementation ObjectiveCStructState

- (NSUInteger)parseStream:(TokensStream *)stream forParser:(ObjectiveCParser *)parser store:(Store *)store {
	// Name is required, but skip everything else until '{'. Then match all definitions of type `type(s) <def>=value,` or `type(s) <def>;`.
	if ([stream matches:@"struct", nil]) {
		LogParDebug(@"Matched struct.");
		[store setCurrentSourceInfo:stream.current];
		[store beginStruct];
		
		__block PKToken *nameToken = nil;
		
		// Skip stream until '{', exit if not found. Take the last token before { as struct name.
		LogParDebug(@"Matching struct body start."); {
			NSArray *delimiters = [NSArray arrayWithObjects:@"{", @"struct", nil];
			GBResult result = [self matchStream:stream until:@"{" block:^(PKToken *token, NSUInteger lookahead) { 
				LogParDebug(@"Matched %@", token);
				if ([token matches:delimiters]) return;
				nameToken = token;
			}];
			if (result == NSNotFound) {
				LogParDebug(@"Failed matching struct body start, bailing out.");
				[stream consume:1];
				[store cancelCurrentObject];
				[parser popState];
				return GBResultFailedMatch;
			}
			if (nameToken) LogParDebug(@"Matched %@ for struct name.", nameToken);
		}
		
		// Match struct definition until '}', exit if not found.
		LogParDebug(@"Matching struct body."); {
			NSArray *delimiters = [NSArray arrayWithObjects:@",", @"}", @";", nil];
			NSMutableArray *itemTokens = [NSMutableArray array];
			GBResult result = [self matchStream:stream until:@"}" block:^(PKToken *token, NSUInteger lookahead) {
				LogParDebug(@"Matched %@.", token);
				if ([token matches:delimiters]) {
					if (itemTokens.count > 0) {
						[store beginConstant];
						[itemTokens enumerateObjectsUsingBlock:^(PKToken *token, NSUInteger idx, BOOL *stop) {
							if (idx == itemTokens.count - 1) {
								[store appendConstantName:token.stringValue];
								return;
							}
							[store appendConstantType:token.stringValue];
						}];
						[store endCurrentObject];
						[itemTokens removeAllObjects];
					}
					return;
				}
				[itemTokens addObject:token];
			}];
			if (result == NSNotFound) {
				LogParDebug(@"Failed matching end of enum body, bailing out.");
				[stream consume:1];
				[store cancelCurrentObject]; // struct
				[parser popState];
				return GBResultFailedMatch;
			}
		}

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
