//
//  ObjectiveCEnumState.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectiveCEnumState.h"

@interface ObjectiveCEnumItemState : NSObject
- (void)parseToken:(PKToken *)token withData:(ObjectiveCParseData *)data;
- (void)initializeWithData:(ObjectiveCParseData *)data;
- (void)finalizeWithData:(ObjectiveCParseData *)data;
@property (nonatomic, strong) PKToken *startToken;
@property (nonatomic, strong) PKToken *endToken;
@end

@interface ObjectiveCEnumItemItemState : ObjectiveCEnumItemState
@end

@interface ObjectiveCEnumValueItemState : ObjectiveCEnumItemState
@end

#pragma mark - 

@interface ObjectiveCEnumState ()
- (BOOL)consumeEnumStartTokens:(ObjectiveCParseData *)data;
- (BOOL)parseEnumBody:(ObjectiveCParseData *)data;
- (BOOL)finalizeEnum:(ObjectiveCParseData *)data;
- (void)changeItemStateTo:(ObjectiveCEnumItemState *)state withData:(ObjectiveCParseData *)data;
@property (nonatomic, strong) ObjectiveCEnumItemState *enumState;
@property (nonatomic, strong) ObjectiveCEnumItemState *enumItemState;
@property (nonatomic, strong) ObjectiveCEnumItemState *enumValueState;
@property (nonatomic, strong) NSArray *enumItemDelimiters;
@end

#pragma mark - 

@implementation ObjectiveCEnumState

@synthesize enumState = _enumState;
@synthesize enumItemState = _enumItemState;
@synthesize enumValueState = _enumValueState;
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
	self.enumState = self.enumItemState;
	[self.enumItemState initializeWithData:data];
	[self.enumValueState initializeWithData:data];
	NSUInteger result = [data.stream matchUntil:@"}" block:^(PKToken *token, NSUInteger lookahead, BOOL *stop) {
		if ([token matches:self.enumItemDelimiters]) {
			LogParDebug(@"Matched %@, ending item.", token);
			[self changeItemStateTo:self.enumItemState withData:data];
		} else if ([token matches:@"="]) {
			LogParDebug(@"Matched %@, registering value.", token);
			[self changeItemStateTo:self.enumValueState withData:data];
		} else {
			LogParDebug(@"Matching %@.", token);
			[self.enumState parseToken:token withData:data];
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

- (void)changeItemStateTo:(ObjectiveCEnumItemState *)state withData:(ObjectiveCParseData *)data {
	LogParDebug(@"Changing enum state to %@...", state);
	[self.enumState finalizeWithData:data];
	self.enumState = state;
	[self.enumState initializeWithData:data];
}

- (ObjectiveCEnumItemState *)enumItemState {
	if (_enumItemState) return _enumItemState;
	LogParDebug(@"Initializing enum item state due to first access...");
	_enumItemState = [[ObjectiveCEnumItemItemState alloc] init];
	return _enumItemState;
}

- (ObjectiveCEnumItemState *)enumValueState {
	if (_enumValueState) return _enumValueState;
	LogParDebug(@"Initializing enum value state due to first access...");
	_enumValueState = [[ObjectiveCEnumValueItemState alloc] init];
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

- (void)initializeWithData:(ObjectiveCParseData *)data {
	self.startToken = nil;
	self.endToken = nil;
}

- (void)finalizeWithData:(ObjectiveCParseData *)data {
}

- (void)parseToken:(PKToken *)token withData:(ObjectiveCParseData *)data {
	LogParDebug(@"Matched %@.", token);
	if (!self.startToken) self.startToken = token;
	self.endToken = token;
}

@end

@implementation ObjectiveCEnumItemItemState

- (void)finalizeWithData:(ObjectiveCParseData *)data {
	NSString *value = [data.stream stringStartingWith:self.startToken endingWith:self.endToken];
	if (value.length == 0) return;
	[data.store appendEnumerationItem:value];
}

@end

@implementation ObjectiveCEnumValueItemState

- (void)finalizeWithData:(ObjectiveCParseData *)data {
	NSString *value = [data.stream stringStartingWith:self.startToken endingWith:self.endToken];
	if (value.length == 0) return;
	[data.store appendEnumerationValue:value];
}

@end
