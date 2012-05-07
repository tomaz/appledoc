//
//  ObjectiveCConstantState.m
//  appledoc
//
//  Created by Tomaž Kragelj on 5/7/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectiveCConstantState.h"

@interface ObjectiveCConstantState ()
- (BOOL)consumeConstantStartTokens:(ObjectiveCParseData *)data;
- (BOOL)parseConstantDefinition:(ObjectiveCParseData *)data;
- (BOOL)finalizeConstant:(ObjectiveCParseData *)data;
- (NSUInteger)lookaheadIndexOfFirstPotentialDescriptorToken:(ObjectiveCParseData *)data;
- (NSUInteger)lookaheadIndexOfConstantEndToken:(ObjectiveCParseData *)data;
@end

#pragma mark - 

@implementation ObjectiveCConstantState

- (NSUInteger)parseWithData:(ObjectiveCParseData *)data {
	if (![self consumeConstantStartTokens:data]) return GBResultFailedMatch;
	if (![self parseConstantDefinition:data]) return GBResultFailedMatch;
	if (![self finalizeConstant:data]) return GBResultFailedMatch;
	return GBResultOk;
}

- (BOOL)consumeConstantStartTokens:(ObjectiveCParseData *)data {
	LogParDebug(@"Matching start of constant.");
	[data.store setCurrentSourceInfo:data.stream.current];
	[data.store beginConstant];
	return YES;
}

- (BOOL)parseConstantDefinition:(ObjectiveCParseData *)data {
	NSUInteger indexOfDescriptorToken = [self lookaheadIndexOfFirstPotentialDescriptorToken:data];
	NSUInteger indexOfEndToken = [self lookaheadIndexOfConstantEndToken:data];
	NSUInteger indexOfNameToken = MIN(indexOfDescriptorToken, indexOfEndToken) - 1;
	BOOL hasDescriptors = (indexOfEndToken > indexOfDescriptorToken);
	LogParDebug(@"Matching constant types and name.");
	[data.store beginConstantTypes];
	NSUInteger found = [data.stream matchUntil:@";" block:^(PKToken *token, NSUInteger lookahead, BOOL *stop) {
		LogParDebug(@"Matched %@.", token);
		if (lookahead < indexOfNameToken) {
			[data.store appendType:token.stringValue];
		} else if (lookahead == indexOfNameToken) {
			[data.store endCurrentObject]; // types
			[data.store appendConstantName:token.stringValue];
			if (hasDescriptors) [data.store beginConstantDescriptors];
			return;
		} else if (lookahead < indexOfEndToken) {
			[data.store appendDescriptor:token.stringValue];
		} else if ([token matches:@";"]) {
			if (hasDescriptors) [data.store endCurrentObject]; // descriptors
			return;
		}
	}];
	if (found == NSNotFound) {
		LogParDebug(@"Failed matching type and name, bailing out.");
		[data.store cancelCurrentObject]; // constant types
		[data.store cancelCurrentObject]; // constant definition
		[data.parser popState]; 
		return NO;
	}
	return YES;
}

- (BOOL)finalizeConstant:(ObjectiveCParseData *)data {
	[data.store endCurrentObject]; // constant definition
	[data.parser popState];
	return YES;
}

#pragma mark - Helper methods

- (NSUInteger)lookaheadIndexOfFirstPotentialDescriptorToken:(ObjectiveCParseData *)data {
    LogParDebug(@"Scanning tokens for constant descriptors.");
	__block NSInteger remainingTypeAndNameTokens = 2;
	NSUInteger result = [data lookaheadIndexOfFirstPotentialDescriptorWithEndDelimiters:@";" block:^(PKToken *token, BOOL *allowDescriptor) {
		// require at least 2 tokens, one for type and one for name!
		if (--remainingTypeAndNameTokens >= 0) *allowDescriptor = NO;
	}];
	return result;
}

- (NSUInteger)lookaheadIndexOfConstantEndToken:(ObjectiveCParseData *)data {
	LogParDebug(@"Scanning tokens for property end.");
	return [data lookaheadIndexOfFirstEndDelimiter:@";"];
}


@end
