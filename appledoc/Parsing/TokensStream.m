//
//  TokensStream.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "TokensStream.h"

@interface TokensStream ()
@property (nonatomic, strong, readwrite) NSString *string;
@property (nonatomic, strong, readwrite) NSArray *tokens;
@property (nonatomic, assign, readwrite) NSUInteger position;
@end

#pragma mark - 

@implementation TokensStream

#pragma mark - Initialization & disposal

+ (id)tokensStreamWithTokenizer:(PKTokenizer *)tokenizer {
	return [[self alloc] initWithTokenizer:tokenizer];
}

- (id)initWithTokenizer:(PKTokenizer *)tokenizer {
	self = [super init];
	if (self) {
		NSMutableArray *tokens = [NSMutableArray array];
		[tokenizer enumerateTokensUsingBlock:^(PKToken *token, BOOL *stop) { [tokens addObject:token]; }];
		[self assignLocationInformationToTokens:tokens fromString:tokenizer.string];
		self.string = tokenizer.string;
		self.tokens = tokens;
		self.position = 0;
	}
	return self;
}

#pragma mark - Preparing token information

- (void)assignLocationInformationToTokens:(NSArray *)tokens fromString:(NSString *)string {
	__block NSUInteger offset = 0;
	__block NSUInteger lineNumber = 1;
	__block NSUInteger tokenIndex = 0;
	NSCharacterSet *newlines = [NSCharacterSet newlineCharacterSet];
	[string enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
		// Prepare location for all tokens on this line.
		while (tokenIndex < tokens.count) {
			PKToken *token = tokens[tokenIndex];
			if (token.offset >= offset + line.length) break;
			token.location = NSMakePoint(token.offset - offset, lineNumber);
			tokenIndex++;
		}
		
		// If we're out of tokens end, otherwise update offset (don't forget to skip all new lines!)
		if (tokenIndex >= tokens.count) *stop = YES;
		offset += line.length;
		while (offset < string.length) {
			unichar ch = [string characterAtIndex:offset];
			if (![newlines characterIsMember:ch]) break;
			offset++;
		}
		
		// Continue with next line.
		lineNumber++;
	}];
}

#pragma mark - Stream handling

- (BOOL)matches:(id)first, ... {
	if (self.eof) return NO;
	
	// Get the array of all expected matches.
	NSMutableArray *expectedMatches = [NSMutableArray array];
	va_list args;
	va_start(args, first);
	for (id arg = first; arg != nil; arg = va_arg(args, id)) {
		[expectedMatches addObject:arg];
	}
	va_end(args);
	
	// Scan tokens from current position and match expected.
	for (NSUInteger i=0; i<expectedMatches.count; i++) {
		// We're out of tokens => no match!
		if (i >= self.tokens.count) return NO;
		
		// Matching any token, assume match and continue with next? Note that we're using pointer comparison for speed and collision prevention.
		id expected = expectedMatches[i];
		if (expected == GBTokens.any) continue;
		
		// Matching concrete token or one of possible tokens. For array match one of the given tokens. For single token, match that token exactly.
		PKToken *token = [self la:i];
		if (![token matches:expected]) return NO;
	}
	return YES;
}

- (BOOL)eof {
	// Are we already at the end of stream?
	return (self.position >= self.tokens.count);
}

- (PKToken *)la:(NSUInteger)count {
	// Look ahead for next token(s) in stream.
	if (self.position + count >= self.tokens.count) return nil;
	return (self.tokens)[self.position + count];
}

- (PKToken *)la:(PKToken *)token offset:(NSInteger)offset {
	// Look ahead for given number of tokens, starting at the given one.
	NSUInteger index = [self.tokens indexOfObjectIdenticalTo:token];
	return (self.tokens)[index + offset];
}

- (PKToken *)current {
	// Return current token.
	return [self la:0];
}

- (void)consume:(NSUInteger)count {
	// Consume given number of tokens by advancing index position.
	self.position += count;
}

- (void)rewind:(NSUInteger)count {
	// Rewind given number of tokens by decrementing index position.
	if (count > self.position) {
		self.position = 0;
		return;
	}
	self.position -= count;
}

#pragma mark - Higher level matching helpers

- (NSUInteger)lookAheadWithBlock:(GBMatchBlock)handler {
	// Looks ahead given stream until stopped or EOF. Each encountered token is passed to given block. Result is number of look ahead tokens until stopped or EOF.
	NSUInteger offset = 0;
	while (self.position + offset < self.tokens.count) {
		BOOL stop = NO;
		PKToken *token = [self la:offset];
		handler(token, offset, &stop);
		if (stop) break;
		offset++;
	}
	return offset + 1;
}

- (NSUInteger)matchUntil:(id)end block:(GBMatchBlock)handler {
	// Matches all token until the given one (or any of the given ones in case end is array) is encountered or EOF reached. Each token is passed to given block. Result is index of the matched end token if end token is an array or 0 for single token. If no match was found, NSNotFound is returned.
	__block NSUInteger result = NSNotFound;
	__block BOOL stop = NO;
	NSUInteger count = [self lookAheadWithBlock:^(PKToken *token, NSUInteger lookahead, BOOL *stopParsing) {
		handler(token, lookahead, &stop);
		if (stop) {
			result = NSNotFound;
			return;
		}
		result = [token matchResult:end];
		if (result == NSNotFound) return;
		*stopParsing = YES;
	}];
	if (result != NSNotFound) [self consume:count];
	return result;
}

- (NSUInteger)matchStart:(id)start end:(id)end block:(GBMatchBlock)handler {
	// Matches given start token (or any of the given ones if start is array) at current stream position and continues until the given end token (or any of the given end tokens in case end is array) is encountered. Each token, including start and end is passed to given block. If current stream position doesn't match start, no parsing is done and NSNotFound is returned. Result is index of the matched end token if end token is an array or 0 for single token. If no match was found, NSNotFound is returned.
	if (start) {
		if (![self.current matches:start]) return NSNotFound;
		[self consume:1];
	}
	return [self matchUntil:end block:handler];
}

#pragma mark - Helper methods

- (NSString *)stringStartingWith:(PKToken *)start endingWith:(PKToken *)end {
	NSUInteger startOffset = start.offset;
	NSUInteger endOffset = end.offset + end.stringValue.length;
	NSRange range = NSMakeRange(startOffset, endOffset - startOffset);
	return [self.string substringWithRange:range];
}

@end

#pragma mark - 

const struct GBTokens GBTokens = {
	.any = @"ANY-TOKEN",
};