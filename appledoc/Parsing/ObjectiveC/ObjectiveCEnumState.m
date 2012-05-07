//
//  ObjectiveCEnumState.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "StateBase.h"
#import "ObjectiveCEnumState.h"

@interface ObjectiveCEnumItemState : BlockStateBase
- (void)parseToken:(PKToken *)token;
@property (nonatomic, strong) PKToken *startToken;
@property (nonatomic, strong) PKToken *endToken;
@property (nonatomic, strong) ObjectiveCParseData *data;
@end

#pragma mark - 

@interface ObjectiveCEnumState ()
- (BOOL)consumeEnumStartTokens:(ObjectiveCParseData *)data;
- (BOOL)parseEnumBody:(ObjectiveCParseData *)data;
- (BOOL)finalizeEnum:(ObjectiveCParseData *)data;
@property (nonatomic, strong) ObjectiveCEnumItemState *enumItemState;
@property (nonatomic, strong) ObjectiveCEnumItemState *enumValueState;
@property (nonatomic, strong) ContextBase *enumItemContext;
@property (nonatomic, strong) NSArray *enumItemDelimiters;
@end

#pragma mark - 

@implementation ObjectiveCEnumState

@synthesize enumItemState = _enumItemState;
@synthesize enumValueState = _enumValueState;
@synthesize enumItemContext = _enumItemContext;
@synthesize enumItemDelimiters = _enumItemDelimiters;

#pragma mark - Parsing

- (NSUInteger)parseWithData:(ObjectiveCParseData *)data {
	if (![self consumeEnumStartTokens:data]) return GBResultFailedMatch;
	if (![self parseEnumBody:data]) return GBResultFailedMatch;
	if (![self finalizeEnum:data]) return GBResultFailedMatch;
	return GBResultOk;
}

- (BOOL)consumeEnumStartTokens:(ObjectiveCParseData *)data {
	// Enumeration can optionally have a name, we're only interested in values, so skip everything until {
	LogParDebug(@"Matched enum.");
	[data.store setCurrentSourceInfo:data.stream.current];
	[data.store beginEnumeration];
	LogParDebug(@"Matching enum body start.");
	NSUInteger result = [data.stream matchUntil:@"{" block:^(PKToken *token, NSUInteger lookahead, BOOL *stop) { }];
	if (result == NSNotFound) {
		LogParDebug(@"Failed matching enum body start, bailing out.");
		[data.stream consume:1];
		[data.store cancelCurrentObject]; // enum
		[data.parser popState];
		return NO;
	}
	return YES;
}

- (BOOL)parseEnumBody:(ObjectiveCParseData *)data {
	LogParDebug(@"Matching enum body.");
	self.enumItemContext.currentState = self.enumItemState;
	self.enumItemState.data = data;
	self.enumValueState.data = data;
	NSUInteger result = [data.stream matchUntil:@"}" block:^(PKToken *token, NSUInteger lookahead, BOOL *stop) {
		if ([token matches:self.enumItemDelimiters]) {
			LogParDebug(@"Matched %@, ending item.", token);
			[self.enumItemContext changeStateTo:self.enumItemState];
		} else if ([token matches:@"="]) {
			LogParDebug(@"Matched %@, registering value.", token);
			[self.enumItemContext changeStateTo:self.enumValueState];
		} else {
			LogParDebug(@"Matching %@.", token);
			[self.enumItemContext.currentState parseToken:token];
		}		
	}];
	if (result == NSNotFound) {
		LogParDebug(@"Failed matching end of enum body, bailing out.");
		[data.stream consume:1];
		[data.store cancelCurrentObject]; // enum
		[data.parser popState];
		return NO;
	}
	return YES;
}

- (BOOL)finalizeEnum:(ObjectiveCParseData *)data {
	LogParDebug(@"Ending enum.");
	LogParVerbose(@"\n%@", data.store.currentRegistrationObject);
	[data.store endCurrentObject]; // enum
	[data.parser popState];
	return YES;
}

#pragma mark - Item state handling

- (ContextBase *)enumItemContext {
	if (_enumItemContext) return _enumItemContext;
	LogParDebug(@"Initializing enum item context due to first access...");
	_enumItemContext = [[ContextBase alloc] init];
	return _enumItemContext;
}

- (ObjectiveCEnumItemState *)enumItemState {
	if (_enumItemState) return _enumItemState;
	LogParDebug(@"Initializing enum item state due to first access...");
	_enumItemState = [[ObjectiveCEnumItemState alloc] init];
	_enumItemState.willResignCurrentStateBlock = ^(ObjectiveCEnumItemState *state, id context){
		NSString *value = [state.data.stream stringStartingWith:state.startToken endingWith:state.endToken];
		if (value.length == 0) return;
		[state.data.store appendEnumerationItem:value];
	};
	return _enumItemState;
}

- (ObjectiveCEnumItemState *)enumValueState {
	if (_enumValueState) return _enumValueState;
	LogParDebug(@"Initializing enum value state due to first access...");
	_enumValueState = [[ObjectiveCEnumItemState alloc] init];
	_enumValueState.willResignCurrentStateBlock = ^(ObjectiveCEnumItemState *state, id context){
		NSString *value = [state.data.stream stringStartingWith:state.startToken endingWith:state.endToken];
		if (value.length == 0) return;
		[state.data.store appendEnumerationValue:value];
	};
	return _enumValueState;
}

#pragma mark - Properties

- (NSArray *)enumItemDelimiters {
	if (_enumItemDelimiters) return _enumItemDelimiters;
	LogParDebug(@"Initializing enum item delimiters due to first access...");
	_enumItemDelimiters = [NSArray arrayWithObjects:@",", @"}", @";", nil];
	return _enumItemDelimiters;
}

@end

#pragma mark - 

@implementation ObjectiveCEnumItemState

@synthesize startToken;
@synthesize endToken;
@synthesize data;

- (void)didBecomeCurrentStateForContext:(id)context {
	[super didBecomeCurrentStateForContext:context];
	self.startToken = nil;
	self.endToken = nil;
}

- (void)parseToken:(PKToken *)token {
	LogParDebug(@"Matched %@.", token);
	if (!self.startToken) self.startToken = token;
	self.endToken = token;
}

@end
