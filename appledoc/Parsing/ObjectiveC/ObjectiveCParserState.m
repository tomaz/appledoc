//
//  ObjectiveCParserState.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectiveCParserState.h"

@implementation ObjectiveCParserState

#pragma mark - Parsing entry point

- (NSUInteger)parseStream:(TokensStream *)stream forParser:(ObjectiveCParser *)parser store:(Store *)store {
	return GBResultOk;
}

#pragma mark - Stream helpers

- (NSUInteger)lookAheadStream:(TokensStream *)stream block:(void(^)(PKToken *token, NSUInteger lookahead, BOOL *stop))handler {
	// Looks ahead given stream until stopped or EOF. Each encountered token is passed to given block. Result is number of look ahead tokens until stopped or EOF.
	NSUInteger offset = 0;
	while (stream.position + offset < stream.tokens.count) {
		BOOL stop = NO;
		PKToken *token = [stream la:offset];
		handler(token, offset, &stop);
		if (stop) break;
		offset++;
	}
	return offset + 1;
}

- (NSUInteger)matchStream:(TokensStream *)stream until:(id)end block:(void(^)(PKToken *token, NSUInteger lookahead))handler {
	// Skips all token until the given one (or any of the given ones in case end is array) is encountered or EOF reached. Each token is passed to given block. Result is index of the matched end token if end token is an array or 0 for single token. If no match was found, NSNotFound is returned.
	__block NSUInteger result = NSNotFound;
	NSUInteger count = [self lookAheadStream:stream block:^(PKToken *token, NSUInteger lookahead, BOOL *stopParsing) {
		handler(token, lookahead);
		if ([end isKindOfClass:[NSArray class]]) {
			[end enumerateObjectsUsingBlock:^(NSString *endToken, NSUInteger idx, BOOL *stopEndChecking) {
				if ([token matches:endToken]) {
					result = idx;
					*stopEndChecking = YES;
					*stopParsing = YES;
				}
			}];
		} else {
			if ([token matches:end]) {
				result = 0;
				*stopParsing = YES;
			}
		}
	}];
	if (result != NSNotFound) [stream consume:count];
	return result;
}

- (NSUInteger)matchStream:(TokensStream *)stream start:(NSString *)start end:(NSString *)end block:(void(^)(PKToken *token, NSUInteger lookahead))handler {
	// Matches given start token at current stream position and continues until the given end token (or any of the given end tokens in case end is array) is encountered. Each token, including start and end is passed to given block. If current stream position doesn't match start, no parsing is done and NSNotFound is returned. Result is index of the matched end token if end token is an array or 0 for single token. If no match was found, NSNotFound is returned.
	if (start && ![stream matches:start, nil]) return NSNotFound;
	return [self matchStream:stream until:end block:handler];
}

@end
