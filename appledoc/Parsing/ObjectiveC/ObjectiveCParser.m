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
#import "ObjectiveCPropertyState.h"
#import "ObjectiveCMethodState.h"
#import "ObjectiveCPragmaMarkState.h"
#import "ObjectiveCEnumState.h"
#import "ObjectiveCStructState.h"
#import "ObjectiveCParser.h"

#pragma mark - 

@interface ObjectiveCParser ()
- (BOOL)isParseResultFailure:(GBResult)result;
@property (nonatomic, strong) TokensStream *tokensStream;
@property (nonatomic, strong) NSMutableArray *statesStack;
@property (nonatomic, strong) ObjectiveCParserState *currentState;
@property (nonatomic, strong) ObjectiveCParserState *fileState;
@property (nonatomic, strong) ObjectiveCParserState *interfaceState;
@property (nonatomic, strong) ObjectiveCParserState *propertyState;
@property (nonatomic, strong) ObjectiveCParserState *methodState;
@property (nonatomic, strong) ObjectiveCParserState *pragmaMarkState;
@property (nonatomic, strong) ObjectiveCParserState *enumState;
@property (nonatomic, strong) ObjectiveCParserState *structState;
@end

#pragma mark - 

@implementation ObjectiveCParser

@synthesize tokenizer = _tokenizer;
@synthesize tokensStream = _tokensStream;
@synthesize statesStack = _statesStack;
@synthesize currentState = _currentState;
@synthesize fileState = _fileState;
@synthesize interfaceState = _interfaceState;
@synthesize propertyState = _propertyState;
@synthesize methodState = _methodState;
@synthesize pragmaMarkState = _pragmaMarkState;
@synthesize enumState = _enumState;
@synthesize structState = _structState;

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
	self.tokenizer.string = string;
	self.tokensStream = [TokensStream tokensStreamWithTokenizer:self.tokenizer];
	
	// Start parsing on the "file" level.
	[self.statesStack removeAllObjects];
	[self pushState:self.fileState];
	
	// Parse all tokens.
	GBResult result = GBResultOk;
	while (!self.tokensStream.eof) {
		LogParDebug(@"Parsing token '%@'...", self.tokensStream.current.stringValue);
		GBResult pr = [self.currentState parseStream:self.tokensStream forParser:self store:self.store];
		if ([self isParseResultFailure:result]) {
			LogParDebug(@"State %@ reported error code %ld, bailing out!", self.currentState, pr);
			result = pr;
			break;
		}
	}
	
	LogParDebug(@"Finished parsing '%@'.", [self.filename lastPathComponent]);
	return result;
}

- (BOOL)isParseResultFailure:(GBResult)result {
	if (result == GBResultOk) return NO;
	if (result == GBResultFailedMatch) return NO;
	return YES;
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

- (ObjectiveCParserState *)propertyState {
	if (_propertyState) return _propertyState;
	LogParDebug(@"Initializing property state due to first access...");
	_propertyState = [[ObjectiveCPropertyState alloc] init];
	return _propertyState;
}

- (ObjectiveCParserState *)methodState {
	if (_methodState) return _methodState;
	LogParDebug(@"Initializing method state due to first access...");
	_methodState = [[ObjectiveCMethodState alloc] init];
	return _methodState;
}

- (ObjectiveCParserState *)pragmaMarkState {
	if (_pragmaMarkState) return _pragmaMarkState;
	LogParDebug(@"Initializing pragma mark state due to first access...");
	_pragmaMarkState = [[ObjectiveCPragmaMarkState alloc] init];
	return _pragmaMarkState;
}

- (ObjectiveCParserState *)enumState {
	if (_enumState) return _enumState;
	LogParDebug(@"Initializing enum state due to first access...");
	_enumState = [[ObjectiveCEnumState alloc] init];
	return _enumState;
}

- (ObjectiveCParserState *)structState {
	if (_structState) return _structState;
	LogParDebug(@"Initializing struct state due to first access...");
	_structState = [[ObjectiveCStructState alloc] init];
	return _structState;
}

#pragma mark - Properties

- (PKTokenizer *)tokenizer {
	if (_tokenizer) return _tokenizer;
	LogParDebug(@"Initializing tokenizer due to first access...");
	_tokenizer = [PKTokenizer tokenizer];
	[_tokenizer setTokenizerState:_tokenizer.wordState from:'_' to:'_'];	// Allow words to start with _
	[_tokenizer.symbolState add:@"..."];	// Allow ... as single token
	//_tokenizer.commentState.reportsCommentTokens = YES;
	return _tokenizer;
}

@end