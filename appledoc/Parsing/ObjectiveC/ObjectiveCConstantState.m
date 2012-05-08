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
		} else if (lookahead < indexOfEndToken) {
			[data.store appendDescriptor:token.stringValue];
		} else {
			if (hasDescriptors) [data.store endCurrentObject]; // descriptors
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
	// This one is a bit tricky: we want to leave at least 2 tokens before accepting descriptors: one for type and one for name. But if all tokens look like descriptor from start on, we should take them to be types - this would cover cases like (__unsafe_unretained etc). If all tokens look like descriptors, then just take the last as constant name and all prior as types.
    LogParDebug(@"Scanning tokens for constant descriptors.");
	__block NSUInteger numberOfSuccessiveDescriptorLikeTokens = 0;
	NSUInteger result = [data lookaheadIndexOfFirstPotentialDescriptorWithEndDelimiters:@";" block:^(PKToken *token, NSUInteger lookahead, BOOL *isDescriptor) {
		BOOL looksLikeDescriptor = [data doesStringLookLikeDescriptor:token.stringValue];
		if (looksLikeDescriptor)
			numberOfSuccessiveDescriptorLikeTokens++;
		else
			numberOfSuccessiveDescriptorLikeTokens = 0;
		if (lookahead < 2) return; // require at least 2 tokens from the start
		if (looksLikeDescriptor && numberOfSuccessiveDescriptorLikeTokens <= lookahead) *isDescriptor = YES;
	}];
	return result;
}

- (NSUInteger)lookaheadIndexOfConstantEndToken:(ObjectiveCParseData *)data {
	LogParDebug(@"Scanning tokens for property end.");
	return [data lookaheadIndexOfFirstEndDelimiter:@";"];
}


@end
