//
//  ObjectiveCStateTestsBase.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/28/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import <ParseKit/ParseKit.h>
#import "TestStrings.h"
#import "ObjectiveCStateTestsBase.h"

@implementation ObjectiveCStateTestsBase

- (void)runWithString:(NSString *)string block:(GBStateMockBlock)handler {
	// Note that we can't use partial mock for TokensStream - get EXC_BAD_ACCESS...
	ObjectiveCParser *parser = [ObjectiveCParser new];
	parser.tokenizer.string = string;
	id parserMock = [OCMockObject partialMockForObject:parser];
	TokensStream *tokens = [TokensStream tokensStreamWithTokenizer:parser.tokenizer];
	handler(parserMock, tokens);
}

- (void)runWithFile:(NSString *)file block:(GBStateMockBlock)handler {
	NSString *string = [TestStrings stringFromResourceFile:file];
	[self runWithString:string block:handler];
}

@end
