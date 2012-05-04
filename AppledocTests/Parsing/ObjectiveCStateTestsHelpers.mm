//
//  ObjectiveCStateTestsHelpers.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/28/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import <ParseKit/ParseKit.h>
#import <OCMock/OCMock.h>
#import "TestStrings.h"
#import "ObjectiveCStateTestsHelpers.h"

void runWithString(NSString *string, GBStateMockBlock handler) {
	// Note that we can't use partial mock for TokensStream - get EXC_BAD_ACCESS...
	ObjectiveCParser *parser = [ObjectiveCParser new];
	parser.tokenizer.string = string;
	id parserMock = [OCMockObject partialMockForObject:parser];
	TokensStream *tokens = [TokensStream tokensStreamWithTokenizer:parser.tokenizer];
	handler(parserMock, tokens);
}

void runWithFile(NSString *file, GBStateMockBlock handler) {
	NSString *string = [TestStrings stringFromResourceFile:file];
	runWithString(string, handler);
}
