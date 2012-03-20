//
//  ObjectiveCParser.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "TokensStream.h"
#import "ObjectiveCFileState.h"
#import "ObjectiveCInterfaceState.h"
#import "ObjectiveCParser.h"

@interface ObjectiveCParser ()
@property (nonatomic, strong) TokensStream *tokensStream;
@property (nonatomic, strong) NSMutableArray *statesStack;
@property (nonatomic, strong) ObjectiveCParserState *currentState;
@property (nonatomic, strong) ObjectiveCParserState *fileState;
@property (nonatomic, strong) ObjectiveCParserState *interfaceState;
@end

#pragma mark - 

@implementation ObjectiveCParser

@synthesize tokensStream = _tokensStream;
@synthesize statesStack = _statesStack;
@synthesize currentState = _currentState;
@synthesize fileState = _fileState;
@synthesize interfaceState = _interfaceState;

#pragma mark - Initialization & disposal

- (id)init {
	self = [super init];
	if (self) {
		self.statesStack = [NSMutableArray array];
	}
	return self;
}

#pragma mark - Parsing

- (NSInteger)parseString:(NSString *)string {
	LogParDebug(@"Parsing '%@' for Objective C data...", [self.filename lastPathComponent]);
	
	// Prepare tokenizer and tokens stream for this session.
	PKTokenizer *tokenizer = [PKTokenizer tokenizerWithString:string];
	[tokenizer setTokenizerState:tokenizer.wordState from:'_' to:'_'];	// Allow words to start with _
	[tokenizer.symbolState add:@"..."];	// Allow ... as single token
	//tokenizer.commentState.reportsCommentTokens = YES;
	self.tokensStream = [TokensStream tokensStreamWithTokenizer:tokenizer];
	
	// Start parsing on the "file" level.
	[self.statesStack removeAllObjects];
	[self pushState:self.fileState];
	
	// Parse all tokens.
	NSInteger result = 0;
	while (!self.tokensStream.eof) {
		LogParDebug(@"Parsing token '%@'...", self.tokensStream.current.stringValue);
		result = [self.currentState parseStream:self.tokensStream forParser:self store:self.store];
		if (result != 0) break;
	}
	
	LogParDebug(@"Finished parsing '%@'.", [self.filename lastPathComponent]);
	return result;
}

#pragma mark - States handling

- (void)pushState:(ObjectiveCParserState *)state {
	LogParDebug(@"Pushing parser state: %@...", state);
	[self.statesStack addObject:state];
	self.currentState = state;
}

- (void)popState {
	LogParDebug(@"Popping parser state...");
	[self.statesStack removeLastObject];
	self.currentState = (self.statesStack.count > 0) ? self.statesStack.lastObject : nil;
}

#pragma mark - Parsing states

- (ObjectiveCParserState *)fileState {
	if (_fileState) return _fileState;
	LogParDebug(@"Initializing file state due to first access...");
	_fileState = [[ObjectiveCFileState alloc] init];
	return _fileState;
}

- (ObjectiveCParserState *)interfaceState {
	if (_interfaceState) return _interfaceState;
	LogParDebug(@"Initializing interface state due to first access...");
	_interfaceState = [[ObjectiveCInterfaceState alloc] init];
	return _interfaceState;
}

@end