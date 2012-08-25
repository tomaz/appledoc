//
//  ObjectiveCParser.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "TokensStream.h"
#import "CommentParser.h"
#import "ObjectiveCParseData.h"
#import "ObjectiveCFileState.h"
#import "ObjectiveCInterfaceState.h"
#import "ObjectiveCPropertyState.h"
#import "ObjectiveCMethodState.h"
#import "ObjectiveCPragmaMarkState.h"
#import "ObjectiveCEnumState.h"
#import "ObjectiveCStructState.h"
#import "ObjectiveCConstantState.h"
#import "ObjectiveCParser.h"

#pragma mark - 

@interface ObjectiveCParser ()
@property (nonatomic, strong) TokensStream *tokensStream;
@property (nonatomic, strong) PKToken *commentStartToken;
@property (nonatomic, strong) CommentParser *commentParser;
@property (nonatomic, strong) NSMutableArray *statesStack;
@property (nonatomic, strong) ObjectiveCParserState *currentState;
@property (nonatomic, strong) ObjectiveCParserState *fileState;
@property (nonatomic, strong) ObjectiveCParserState *interfaceState;
@property (nonatomic, strong) ObjectiveCParserState *propertyState;
@property (nonatomic, strong) ObjectiveCParserState *methodState;
@property (nonatomic, strong) ObjectiveCParserState *pragmaMarkState;
@property (nonatomic, strong) ObjectiveCParserState *enumState;
@property (nonatomic, strong) ObjectiveCParserState *structState;
@property (nonatomic, strong) ObjectiveCParserState *constantState;
@end

#pragma mark - 

@implementation ObjectiveCParser

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
	[self prepareParserForParsingString:string];
	return [self parseTokens];
}

- (void)prepareParserForParsingString:(NSString *)string {
	self.tokenizer.string = string;
	self.tokensStream = [TokensStream tokensStreamWithTokenizer:self.tokenizer];
	[self.statesStack removeAllObjects];
	[self pushState:self.fileState];
}

- (GBResult)parseTokens {
	GBResult result = GBResultOk;
	ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:self.tokensStream parser:self store:self.store];
	while (!self.tokensStream.eof) {
		PKToken *token = self.tokensStream.current;
		LogParDebug(@"Parsing token '%@'...", [token.stringValue gb_description]);
		if ([self parseCommentToken:token]) continue;
		if (![self registerComments]) break;
		if (![self parseTokensWithData:data result:&result]) break;
	}
	[self registerComments];
	return result;
}

- (BOOL)parseTokensWithData:(ObjectiveCParseData *)data result:(GBResult *)result {
	GBResult stateResult = [self.currentState parseWithData:data];
	if ([self isParseResultFailure:stateResult]) {
		LogParDebug(@"State %@ reported error code %ld, bailing out!", self.currentState, stateResult);
		if (result) *result = stateResult;
		return NO;
	}
	return YES;
}

- (BOOL)parseCommentToken:(PKToken *)token {
	if (!token.isComment) return NO;
	LogParDebug(@"Token is comment, testing for appledoc comments...");
	if ([self.commentParser isAppledocComment:token.stringValue]) {
		LogParDebug(@"Token is appledoc comment, parsing...");
		if (!self.commentStartToken) self.commentStartToken = token;
		[self.commentParser parseComment:token.stringValue line:token.location.y];
	}
	LogParDebug(@"Consuming comment...");
	[self.tokensStream consume:1];
	return YES;
}

- (BOOL)registerComments {
	// We're always returning YES; in fact, the only reason for introducing result is to have all lines of main loop code looking the same (kind of nerdy, I know, but that's how I am :)
	[self.commentParser notifyAndReset];
	return YES;
}

#pragma mark - Helper methods

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
	LogIntDebug(@"Initializing file state due to first access...");
	_fileState = [[ObjectiveCFileState alloc] init];
	return _fileState;
}

- (ObjectiveCParserState *)interfaceState {
	if (_interfaceState) return _interfaceState;
	LogIntDebug(@"Initializing interface state due to first access...");
	_interfaceState = [[ObjectiveCInterfaceState alloc] init];
	return _interfaceState;
}

- (ObjectiveCParserState *)propertyState {
	if (_propertyState) return _propertyState;
	LogIntDebug(@"Initializing property state due to first access...");
	_propertyState = [[ObjectiveCPropertyState alloc] init];
	return _propertyState;
}

- (ObjectiveCParserState *)methodState {
	if (_methodState) return _methodState;
	LogIntDebug(@"Initializing method state due to first access...");
	_methodState = [[ObjectiveCMethodState alloc] init];
	return _methodState;
}

- (ObjectiveCParserState *)pragmaMarkState {
	if (_pragmaMarkState) return _pragmaMarkState;
	LogIntDebug(@"Initializing pragma mark state due to first access...");
	_pragmaMarkState = [[ObjectiveCPragmaMarkState alloc] init];
	return _pragmaMarkState;
}

- (ObjectiveCParserState *)enumState {
	if (_enumState) return _enumState;
	LogIntDebug(@"Initializing enum state due to first access...");
	_enumState = [[ObjectiveCEnumState alloc] init];
	return _enumState;
}

- (ObjectiveCParserState *)structState {
	if (_structState) return _structState;
	LogIntDebug(@"Initializing struct state due to first access...");
	_structState = [[ObjectiveCStructState alloc] init];
	return _structState;
}

- (ObjectiveCParserState *)constantState {
	if (_constantState) return _constantState;
	LogIntDebug(@"Initializing constant state due to first access...");
	_constantState = [[ObjectiveCConstantState alloc] init];
	return _constantState;
}

#pragma mark - Properties

- (PKTokenizer *)tokenizer {
	if (_tokenizer) return _tokenizer;
	LogIntDebug(@"Initializing tokenizer due to first access...");
	_tokenizer = [PKTokenizer tokenizer];
	[_tokenizer setTokenizerState:_tokenizer.wordState from:'_' to:'_'];	// Allow words to start with _
	[_tokenizer.symbolState add:@"..."];	// Allow ... as single token
	_tokenizer.commentState.reportsCommentTokens = YES;
	return _tokenizer;
}

- (CommentParser *)commentParser {
	if (_commentParser) return _commentParser;
	LogIntDebug(@"Initializing comment parser due to first access...");
	Store *store = self.store;
	__weak ObjectiveCParser *blockSelf = self;
	_commentParser = [[CommentParser alloc] init];
	_commentParser.groupRegistrator = ^(CommentParser *parser, NSString *group) {
		LogParDebug(@"Registering method group %@...", group);
		[store appendMethodGroupWithDescription:group];
		blockSelf.commentStartToken = nil;
	};
	_commentParser.commentRegistrator = ^(CommentParser *parser, NSString *comment, BOOL isInline) {
		if (isInline) {
			LogParDebug(@"Registering inline comment %@...", [comment gb_description]);
			[store setCurrentSourceInfo:blockSelf.commentStartToken];
			[store appendCommentToPreviousObject:comment];
		} else {
			LogParDebug(@"Registering comment %@...", [comment gb_description]);
			[store setCurrentSourceInfo:blockSelf.commentStartToken];
			[store appendCommentToNextObject:comment];
		}
		blockSelf.commentStartToken = nil;
	};
	return _commentParser;
}

@end