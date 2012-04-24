//
//  ObjectiveCStructState.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectiveCStructState.h"

@interface ObjectiveCStructState ()
@property (nonatomic, strong) NSArray *structBodyStartDelimiters;
@property (nonatomic, strong) NSArray *structItemDelimiters;
@end

@implementation ObjectiveCStructState

@synthesize structBodyStartDelimiters = _structBodyStartDelimiters;
@synthesize structItemDelimiters = _structItemDelimiters;

#pragma mark - Parsing

- (NSUInteger)parseStream:(TokensStream *)stream forParser:(ObjectiveCParser *)parser store:(Store *)store {
	// Name is required, but skip everything else until '{'. Then match all definitions of type `type(s) <def>=value,` or `type(s) <def>;`.
	LogParDebug(@"Matched struct.");
	[store setCurrentSourceInfo:stream.current];
	[store beginStruct];
	
	__block PKToken *nameToken = nil;
	
	// Skip stream until '{', exit if not found. Take the last token before { as struct name.
	LogParDebug(@"Matching struct body start."); {
		NSArray *delimiters = self.structBodyStartDelimiters;
		NSUInteger result = [stream matchUntil:@"{" block:^(PKToken *token, NSUInteger lookahead, BOOL *stop) {
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
		NSArray *delimiters = self.structItemDelimiters;
		NSMutableArray *itemTokens = [NSMutableArray array];
		NSUInteger result = [stream matchUntil:@"}" block:^(PKToken *token, NSUInteger lookahead, BOOL *stop) {
			LogParDebug(@"Matched %@.", token);
			if ([token matches:delimiters]) {
				if (itemTokens.count > 0) {
					__block BOOL isTypeCommandNeeded = YES;
					__block BOOL wasTypeCommandIssues = NO;
					[store beginConstant];
					[itemTokens enumerateObjectsUsingBlock:^(PKToken *token, NSUInteger idx, BOOL *stop) {
						if (idx == itemTokens.count - 1) {
							if (wasTypeCommandIssues) [store endCurrentObject]; // types
							[store appendConstantName:token.stringValue];
							return;
						}
						if (isTypeCommandNeeded) {
							[store beginConstantTypes];
							wasTypeCommandIssues = YES;
							isTypeCommandNeeded = NO;
						}
						[store appendType:token.stringValue];
					}];
					[store endCurrentObject]; // constant
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
	return GBResultOk;
}

#pragma mark - Properties

- (NSArray *)structBodyStartDelimiters {
	if (_structBodyStartDelimiters) return _structBodyStartDelimiters;
	_structBodyStartDelimiters = [NSArray arrayWithObjects:@"{", @"struct", nil];
	return _structBodyStartDelimiters;
}

- (NSArray *)structItemDelimiters {
	if (_structItemDelimiters) return _structItemDelimiters;
	_structItemDelimiters = [NSArray arrayWithObjects:@",", @"}", @";", nil];
	return _structItemDelimiters;
}

@end
