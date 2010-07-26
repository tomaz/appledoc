//
//  GBTokenizer.h
//  appledoc
//
//  Created by Tomaz Kragelj on 25.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ParseKit.h"

/** Provides common methods for tokenizing input source strings.
 
 Main responsibilities of the class are to split the given source string into tokens and provide simple methods for iterating over
 the tokens stream. It works upon ParseKit framework's `PKTokenizer`. As different parsers require different tokenizers and setups,
 the class itself doesn't create a tokenizer, but instead requires the client to provide one. Here's an example of simple usage:
 
	NSString *input = ...
	PKTokenizer *worker = [PKTokenizer tokenizerWithString:input];
	GBTokenizer *tokenizer = [[GBTokenizer allow] initWithTokenizer:worker];
	while (![tokenizer eof]) {
		NSLog(@"%@", [tokenizer currentToken]);
		[tokenizer consume:1];
	}
 
 This example simply iterates over all tokens and prints each one to the log.
 */
@interface GBTokenizer : NSObject

///---------------------------------------------------------------------------------------
/// @name Initialization & disposal
///---------------------------------------------------------------------------------------

/** Returns initialized autoreleased instance using the given source `PKTokenizer`.
 
 @param tokenizer The underlying (worker) tokenizer to use for actual splitting.
 @return Returns initialized instance or `nil` if failed.
 @exception NSException Thrown if the given tokenizer is `nil`.
 */
+ (id)tokenizerWithSource:(PKTokenizer *)tokenizer;

/** Initializes tokenizer with the given source `PKTokenizer`.
 
 This is designated initializer.
 
 @param tokenizer The underlying (worker) tokenizer to use for actual splitting.
 @return Returns initialized instance or `nil` if failed.
 @exception NSException Thrown if the given tokenizer is `nil`.
 */
- (id)initWithSourceTokenizer:(PKTokenizer *)tokenizer;

///---------------------------------------------------------------------------------------
/// @name Tokenizing handling
///---------------------------------------------------------------------------------------

/** Returns the current token.
 */
- (PKToken *)currentToken;

/** Returns the token by looking ahead the given number of tokens from current position.
 
 If offset "points" within a valid token, the token is returned, otherwise EOF token is	returned.
 
 @param offset The offset from the current position.
 @return Returns the token at the given offset or EOF token if offset point after EOF.
 */
- (PKToken *)lookahead:(NSUInteger)offset;

/** Consumes the given ammoun of tokens, starting at the current position.
 
 This effectively "moves" `currentToken` to the new position. If EOF is reached before consuming the given ammount of tokens, 
 consuming stops at the end of stream and `currentToken` returns EOF token.
 
 @param count The number of tokens to consume.
 */
- (void)consume:(NSUInteger)count;

/** Enumerates and consumes all tokens starting at current token up until the given end token is detected.
 
 For each token, the given block is called which gives client a chance to inspect and handle tokens. End token is not reported and 
 is automatically consumed after all previous tokens are reported. Sending this message is equivalent to sending
 `consumeFrom:to:usingBlock:` and passing `nil` for start token.
 
 @param end Ending token.
 @param block The blck to be called for each token.
 @exception NSException Thrown if the given end token is `nil`.
 */
- (void)consumeTo:(NSString *)end usingBlock:(void (^)(PKToken *token, BOOL *consume))block;

/** Enumerates and consumes all tokens starting at current token up until the given end token is detected.
 
 For each token, the given block is called which gives client a chance to inspect and handle tokens. If start token is given
 and current token matches it, the token is consumed without reporting it to block. However if the token doesn't match, the
 method returns immediately without doint anything. End token is also not reported and is also automatically consumed after
 all previous tokens are reported.
 
 @param start Optional starting token or `nil`.
 @param end Ending token.
 @param block The blck to be called for each token.
 @exception NSException Thrown if the given end token is `nil`.
 */
- (void)consumeFrom:(NSString *)start to:(NSString *)end usingBlock:(void (^)(PKToken *token, BOOL *consume))block;

/** Specifies whether we're at EOF.
 
 @return Returns `YES` if we're at EOF, `NO` otherwise.
 */
- (BOOL)eof;

@end
