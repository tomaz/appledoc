//
//  GBTokenizer.m
//  appledoc
//
//  Created by Tomaz Kragelj on 25.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBTokenizer.h"

@interface GBTokenizer ()

- (NSArray *)allTokensFromTokenizer:(PKTokenizer *)tokenizer;
@property (retain) NSArray *tokens;
@property (assign) NSUInteger tokenIndex;

@end

#pragma mark -

@implementation GBTokenizer

#pragma mark Initialization & disposal

+ (id)tokenizerWithSource:(PKTokenizer *)tokenizer {
	return [[[self alloc] initWithSourceTokenizer:tokenizer] autorelease];
}

- (id)initWithSourceTokenizer:(PKTokenizer *)tokenizer {
	NSParameterAssert(tokenizer != nil);
	GBLogDebug(@"Initializing with tokenizer %@...", tokenizer);
	self = [super init];
	if (self) {
		self.tokens = [self allTokensFromTokenizer:tokenizer];
		self.tokenIndex = 0;
	}
	return self;
}

#pragma mark Tokenizing handling

- (PKToken *)lookahead:(NSUInteger)offset {
	if (self.tokenIndex + offset >= [self.tokens count]) return [PKToken EOFToken];
	return [self.tokens objectAtIndex:self.tokenIndex + offset];
}

- (PKToken *)currentToken {
	return [self lookahead:0];
}

- (void)consume:(NSUInteger)count {
	self.tokenIndex += count;
}

- (BOOL)eof {
	return (self.tokenIndex >= [self.tokens count]);
}

#pragma mark Helper methods

- (NSArray *)allTokensFromTokenizer:(PKTokenizer *)tokenizer {
	PKToken *token;
	NSMutableArray *result = [NSMutableArray array];
	while ((token = [tokenizer nextToken]) != [PKToken EOFToken]) {
		[result addObject:token];
	}
	return result;
}

#pragma mark Properties

@synthesize tokens;
@synthesize tokenIndex;

@end
