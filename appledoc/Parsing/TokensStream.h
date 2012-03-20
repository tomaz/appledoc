//
//  TokensStream.h
//  appledoc
//
//  Created by Tomaž Kragelj on 3/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

@class PKTokenizer;

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

@property (nonatomic, strong, readonly) NSArray *tokens;
@property (nonatomic, assign, readonly) NSUInteger position;

@end

#pragma mark - 

/** Definitions of special tokens.
 */
const struct GBTokens {
	__unsafe_unretained NSString *any; ///< Match any token.
} GBTokens;
