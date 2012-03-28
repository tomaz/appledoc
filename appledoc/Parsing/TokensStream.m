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
- (void)assignLocationInformationToTokens:(NSArray *)tokens fromString:(NSString *)string;
@property (nonatomic, strong, readwrite) NSArray *tokens;
@property (nonatomic, assign, readwrite) NSUInteger position;
@end

#pragma mark - 

@implementation TokensStream

@synthesize tokens = _tokens;
@synthesize position = _position;

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
			PKToken *token = [tokens objectAtIndex:tokenIndex];
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
		id expected = [expectedMatches objectAtIndex:i];
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
	// Look ahead for next token in stream.
	return [self.tokens objectAtIndex:self.position + count];
}

- (PKToken *)la:(PKToken *)token offset:(NSInteger)offset {
	// Look ahead for given number of tokens, starting at the given one.
	NSUInteger index = [self.tokens indexOfObjectIdenticalTo:token];
	return [self.tokens objectAtIndex:index + offset];
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

@end

#pragma mark - 

const struct GBTokens GBTokens = {
	.any = @"ANY-TOKEN",
};