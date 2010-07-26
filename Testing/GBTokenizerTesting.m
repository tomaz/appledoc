//
//  GBTokenizerTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 26.7.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBTokenizer.h"

@interface GBTokenizerTesting : SenTestCase

- (PKTokenizer *)defaultTokenizer;

@end

@implementation GBTokenizerTesting

- (void)testInitWithTokenizer_shouldInitializeToFirstToken {
	// setup
	GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[self defaultTokenizer]];
	// execute & verify
	assertThat([tokenizer.currentToken stringValue], is(@"one"));
}

- (void)testConsume_shouldMoveToNextToken {
	// setup
	GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[self defaultTokenizer]];
	// execute & verify
	[tokenizer consume:1];
	assertThat([tokenizer.currentToken stringValue], is(@"two"));
	[tokenizer consume:1];
	assertThat([tokenizer.currentToken stringValue], is(@"three"));
}

- (void)testConsume_shouldReturnEOF {
	// setup
	GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[self defaultTokenizer]];
	// execute
	[tokenizer consume:1];
	[tokenizer consume:1];
	[tokenizer consume:1];
	// verify
	assertThat([tokenizer.currentToken stringValue], equalTo([[PKToken EOFToken] stringValue]));
	assertThatBool([tokenizer eof], equalToBool(YES));
}

- (void)testLookahead_shouldReturnNextToken {
	// setup
	GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[self defaultTokenizer]];
	// execute & verify
	assertThat([[tokenizer lookahead:0] stringValue], is(@"one"));
	assertThat([[tokenizer lookahead:1] stringValue], is(@"two"));
	assertThat([[tokenizer lookahead:2] stringValue], is(@"three"));
}

- (void)testLookahead_shouldReturnEOFToken {
	// setup
	GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[self defaultTokenizer]];
	// execute & verify
	assertThat([[tokenizer lookahead:3] stringValue], is([[PKToken EOFToken] stringValue]));
	assertThat([[tokenizer lookahead:4] stringValue], is([[PKToken EOFToken] stringValue]));
	assertThat([[tokenizer lookahead:999999999] stringValue], is([[PKToken EOFToken] stringValue]));
}

- (void)testLookahead_shouldNotMovePosition {
	// setup
	GBTokenizer *tokenizer = [GBTokenizer tokenizerWithSource:[self defaultTokenizer]];
	// execute & verify
	[tokenizer lookahead:1];
	assertThat([[tokenizer currentToken] stringValue], is(@"one"));
	[tokenizer lookahead:2];
	assertThat([[tokenizer currentToken] stringValue], is(@"one"));
	[tokenizer lookahead:3];
	assertThat([[tokenizer currentToken] stringValue], is(@"one"));
	[tokenizer lookahead:99999];
	assertThat([[tokenizer currentToken] stringValue], is(@"one"));
}

#pragma mark Creation methods

- (PKTokenizer *)defaultTokenizer {
	return [PKTokenizer tokenizerWithString:@"one two three"];
}

@end
