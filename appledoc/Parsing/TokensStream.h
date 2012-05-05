//
//  TokensStream.h
//  appledoc
//
//  Created by Tomaž Kragelj on 3/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

@class PKTokenizer;
@class PKToken;

typedef void(^GBMatchBlock)(PKToken *token, NSUInteger lookahead, BOOL *stop);

/** Helper class that simplifies tokenizing an input string.
 
 It works on top of PKToken and PKTokenizer by loading all tokens from a given string into an array thus allowing clients inspecting and rewinding the stream to their will. Here's an example of usage:
 
 ```
 // Initialize tokens stream.
 NSString *input = ...
 PKTokenizer *tokenizer = [PKTokenizer tokenizerWithString:input];
 // setup tokenizer rules as needed
 TokensStream *stream = [TokensStream tokensStreamFromTokenizer:tokenizer];
 
 // Parse tokens from stream:
 while (![stream eof]) {
	if ([stream matches:@"@", @"interface", GBTokens.any, @"(", GBTokens.any, @")", nil]) {
 		// found category
		[stream consume:6];
	} else if (...) {
	}
	[stream cosume:1];
 }
 ```
 */
@interface TokensStream : NSObject

+ (id)tokensStreamWithTokenizer:(PKTokenizer *)tokenizer;
- (id)initWithTokenizer:(PKTokenizer *)tokenizer;

- (BOOL)matches:(id)first, ... NS_REQUIRES_NIL_TERMINATION;
- (BOOL)eof;
- (PKToken *)la:(NSUInteger)count;
- (PKToken *)la:(PKToken *)token offset:(NSInteger)offset;
- (PKToken *)current;
- (void)consume:(NSUInteger)count;
- (void)rewind:(NSUInteger)count;

- (NSUInteger)lookAheadWithBlock:(GBMatchBlock)handler;
- (NSUInteger)matchUntil:(id)end block:(GBMatchBlock)handler;
- (NSUInteger)matchStart:(id)start end:(id)end block:(GBMatchBlock)handler;

@property (nonatomic, strong, readonly) NSString *string;
@property (nonatomic, strong, readonly) NSArray *tokens;
@property (nonatomic, assign, readonly) NSUInteger position;

@end

#pragma mark - 

/** Definitions of special tokens.
 */
extern const struct GBTokens {
	__unsafe_unretained NSString *any; ///< Match any token.
} GBTokens;
