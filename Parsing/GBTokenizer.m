//
//  GBTokenizer.m
//  appledoc
//
//  Created by Tomaz Kragelj on 25.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "PKToken+GBToken.h"
#import "GBTokenizer.h"

@interface GBTokenizer ()

- (BOOL)consumeComments;
- (NSArray *)allTokensFromTokenizer:(PKTokenizer *)tokenizer;
@property (retain) NSArray *tokens;
@property (assign) NSUInteger tokenIndex;
@property (retain) NSMutableString *lastComment;

@end

#pragma mark -

@implementation GBTokenizer

#pragma mark Initialization & disposal

+ (id)tokenizerWithSource:(PKTokenizer *)tokenizer {
	return [[[self alloc] initWithSourceTokenizer:tokenizer] autorelease];
}

- (id)initWithSourceTokenizer:(PKTokenizer *)tokenizer {
	NSParameterAssert(tokenizer != nil);
	GBLogDebug(@"Initializing tokenizer using %@...", tokenizer);
	self = [super init];
	if (self) {
		self.tokenIndex = 0;
		self.lastComment = [NSMutableString string];
		self.tokens = [self allTokensFromTokenizer:tokenizer];
		[self consumeComments];
	}
	return self;
}

#pragma mark Tokenizing handling

- (PKToken *)lookahead:(NSUInteger)offset {
	NSUInteger delta = 0;
	NSUInteger counter = 0;
	while (counter <= offset) {
		NSUInteger index = self.tokenIndex + delta;
		if (index >= [self.tokens count]) return [PKToken EOFToken];
		if ([[self.tokens objectAtIndex:index] isComment]) {
			delta++;
			continue;
		}
		delta++;
		counter++;
	}
	return [self.tokens objectAtIndex:self.tokenIndex + delta - 1];
}

- (PKToken *)currentToken {
	if ([self eof]) return [PKToken EOFToken];
	return [self.tokens objectAtIndex:self.tokenIndex];
}

- (void)consume:(NSUInteger)count {
	if (count == 0) return;
	while (count > 0 && ![self eof]) {
		self.tokenIndex++;
		if (![self consumeComments]) {
		}
		count--;
	}
}

- (void)consumeTo:(NSString *)end usingBlock:(void (^)(PKToken *token, BOOL *consume, BOOL *stop))block {
	[self consumeFrom:nil to:end usingBlock:block];
}

- (void)consumeFrom:(NSString *)start to:(NSString *)end usingBlock:(void (^)(PKToken *token, BOOL *consume, BOOL *stop))block {
	// Skip starting token.
	if (start) {
		if (![[self currentToken] matches:start]) return;
		[self consume:1];
	}
	
	// Report all tokens until EOF or ending token is found.
	BOOL quit = NO;
	while (![self eof] && ![[self currentToken] matches:end]) {
		BOOL consume = YES;
		block([self currentToken], &consume, &quit);
		if (consume) [self consume:1];
		if (quit) break;
	}
	
	// Skip ending token if found.
	if ([[self currentToken] matches:end]) [self consume:1];
}

- (BOOL)eof {
	return (self.tokenIndex >= [self.tokens count]);
}

#pragma mark Comments handling

- (BOOL)consumeComments {
	// This method checks if current token is a comment and consumes all comments until non-comment token is detected or EOF reached.
	// The result of the method is that current index is positioned on the first non-comment token. If current token is not comment,
	// the method doesn't do anything, but simply returns NO to indicate it didn't find a comment and therefore it didn't move current 
	// token. This is also where we do initial comments handling such as removing starting and ending chars etc.
	[self.lastComment setString:@""];
	if ([self eof]) return NO;
	if (![[self currentToken] isComment]) return NO;
	NSUInteger previousSingleLineEndOffset = 0;
	while (![self eof] && [[self currentToken] isComment]) {
		PKToken *token = [self currentToken];
		NSString *value = [[token stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		
		// Is this continuation of previous single line comment?
		BOOL isSingleLiner = [value hasPrefix:@"///"];
		BOOL isContinuingPreviousSingleLiner = (isSingleLiner && [token offset] == previousSingleLineEndOffset + 1);
		if (!isContinuingPreviousSingleLiner) [self.lastComment setString:@""];

		// Strip comment prefixes and suffixes.
		if ([value hasPrefix:@"/// "]) value = [value substringFromIndex:4];
		if ([value hasPrefix:@"///"]) value = [value substringFromIndex:3];
		if ([value hasPrefix:@"/** "]) value = [value substringFromIndex:4];
		if ([value hasPrefix:@"/**"]) value = [value substringFromIndex:3];
		if ([value hasSuffix:@"*/"]) value = [value substringToIndex:[value length] - 2];
		value = [value stringByTrimmingCharactersInSetFromEnd:[NSCharacterSet whitespaceCharacterSet]];

		// Append comment string and new line if we're continuing previous single line comment.
		if (isContinuingPreviousSingleLiner) [self.lastComment appendString:@"\n"];
		[self.lastComment appendString:value];
		
		// If we have single line comment, we should remember previous single line end offset.
		if (isSingleLiner) previousSingleLineEndOffset = [token offset] + [[token stringValue] length];
		
		// Proceed with next token.
		self.tokenIndex++;
	}
	return YES;
}

- (NSString *)lastCommentString {
	if ([self.lastComment length] == 0) return nil;
	NSMutableString *result = [NSMutableString stringWithCapacity:[self.lastComment length]];
	NSArray *lines = [self.lastComment componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	for (NSString *line in lines) {
		if ([result length] > 0) [result appendFormat:@"\n"];
		[result appendString:line];
	}
	return result;
}

#pragma mark Helper methods

- (NSArray *)allTokensFromTokenizer:(PKTokenizer *)tokenizer {
	// Return all appledoc comments too, but ignore ordinary C comments!
	BOOL reportsComments = tokenizer.commentState.reportsCommentTokens;
	tokenizer.commentState.reportsCommentTokens = YES;
	NSMutableArray *result = [NSMutableArray array];
	PKToken *token;
	while ((token = [tokenizer nextToken]) != [PKToken EOFToken]) {
		if ([token isComment] && ![token isAppledocComment]) continue;
		[result addObject:token];
	}
	tokenizer.commentState.reportsCommentTokens = reportsComments;
	return result;
}

#pragma mark Properties

@synthesize tokens;
@synthesize tokenIndex;
@synthesize lastComment;

@end
