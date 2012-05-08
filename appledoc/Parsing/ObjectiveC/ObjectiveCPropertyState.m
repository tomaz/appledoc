//
//  ObjectiveCPropertyState.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "ObjectiveCPropertyState.h"

@interface ObjectiveCPropertyState ()
- (BOOL)consumePropertyStartTokens:(ObjectiveCParseData *)data;
- (BOOL)parsePropertyAttributes:(ObjectiveCParseData *)data;
- (BOOL)parsePropertyTypesNameAndDescriptors:(ObjectiveCParseData *)data;
- (BOOL)finalizeProperty:(ObjectiveCParseData *)data;
- (NSUInteger)lookaheadIndexOfFirstPotentialDescriptor:(ObjectiveCParseData *)data;
- (NSUInteger)lookaheadIndexOfPropertyEndToken:(ObjectiveCParseData *)data;
@property (nonatomic, strong) NSArray *propertyAttributeDelimiters;
@end

#pragma mark - 

@implementation ObjectiveCPropertyState

@synthesize propertyAttributeDelimiters = _propertyAttributeDelimiters;

#pragma mark - Parsing

- (NSUInteger)parseWithData:(ObjectiveCParseData *)data {
	if (![self consumePropertyStartTokens:data]) return GBResultFailedMatch;
	if (![self parsePropertyAttributes:data]) return GBResultFailedMatch;
	if (![self parsePropertyTypesNameAndDescriptors:data]) return GBResultFailedMatch;
	if (![self finalizeProperty:data]) return GBResultFailedMatch;
	return GBResultOk;
}

- (BOOL)consumePropertyStartTokens:(ObjectiveCParseData *)data {
    LogParDebug(@"Matched property definition.");
	[data.store setCurrentSourceInfo:data.stream.current];
	[data.store beginPropertyDefinition];
	[data.stream consume:2];
	return YES;
}

- (BOOL)parsePropertyAttributes:(ObjectiveCParseData *)data {
    if ([data.stream matches:@"(", nil]) {
		LogParDebug(@"Matching attributes...");
		[data.store beginPropertyAttributes];
		NSArray *delimiters = self.propertyAttributeDelimiters;
		NSUInteger found = [data.stream matchStart:@"(" end:@")" block:^(PKToken *token, NSUInteger lookahead, BOOL *stop) {
			LogParDebug(@"Matched %@.", token);
			if ([token matches:delimiters]) return;
			[data.store appendAttribute:token.stringValue];
		}];
		if (found == NSNotFound) {
			LogParDebug(@"Failed matching attributes, bailing out.");
			[data.store cancelCurrentObject]; // attribute types
			[data.store cancelCurrentObject]; // property definition
			[data.parser popState];
			return NO;
		}
		[data.store endCurrentObject]; // property attributes
	}
	return YES;
}

- (BOOL)parsePropertyTypesNameAndDescriptors:(ObjectiveCParseData *)data {
	NSUInteger indexOfDescriptorToken = [self lookaheadIndexOfFirstPotentialDescriptor:data];
	NSUInteger indexOfEndToken = [self lookaheadIndexOfPropertyEndToken:data];
	NSUInteger indexOfNameToken = MIN(indexOfDescriptorToken, indexOfEndToken) - 1;
	BOOL hasDescriptors = (indexOfEndToken > indexOfDescriptorToken);
	LogParDebug(@"Matching types and name.");
	[data.store beginPropertyTypes];
	NSUInteger found = [data.stream matchUntil:@";" block:^(PKToken *token, NSUInteger lookahead, BOOL *stop) {
		LogParDebug(@"Matched %@.", token);
		if (lookahead < indexOfNameToken) {
			[data.store appendType:token.stringValue];
		} else if (lookahead == indexOfNameToken) {
			[data.store endCurrentObject]; // types
			[data.store appendPropertyName:token.stringValue];
			if (hasDescriptors) [data.store beginPropertyDescriptors];
			return;
		} else if (lookahead < indexOfEndToken) {
			[data.store appendDescriptor:token.stringValue];
		} else if ([token matches:@";"]) {
			if (hasDescriptors) [data.store endCurrentObject];
			return;
		}
	}];
	if (found == NSNotFound) {
		LogParDebug(@"Failed matching type and name, bailing out.");
		[data.store cancelCurrentObject]; // property types
		[data.store cancelCurrentObject]; // property definition
		[data.parser popState]; 
		return NO;
	}
	return YES;
}

- (BOOL)finalizeProperty:(ObjectiveCParseData *)data {
	LogParDebug(@"Ending property.");
	[data.store endCurrentObject]; // property definition
	[data.parser popState];
	return YES;
}

- (NSUInteger)lookaheadIndexOfFirstPotentialDescriptor:(ObjectiveCParseData *)data {
	// Require at least one token for type and one for name. Note that we should take all asterisks as types while here!
    LogParDebug(@"Scanning tokens for property descriptors.");
	__block BOOL wasPreviousTokenPossiblePropertyName = YES;
	NSUInteger result = [data lookaheadIndexOfFirstPotentialDescriptorWithEndDelimiters:@";" block:^(PKToken *token, NSUInteger lookahead, BOOL *isDescriptor) {
		if ([token matches:@"*"]) {
			wasPreviousTokenPossiblePropertyName = NO;
			return;
		}
		if (lookahead < 2) return;
		if (wasPreviousTokenPossiblePropertyName && [data doesStringLookLikeDescriptor:token.stringValue]) *isDescriptor = YES;
		wasPreviousTokenPossiblePropertyName = YES;
	}];
	return result;
}

- (NSUInteger)lookaheadIndexOfPropertyEndToken:(ObjectiveCParseData *)data {
	LogParDebug(@"Scanning tokens for property end.");
	return [data lookaheadIndexOfFirstToken:@";"];
}

#pragma mark - Properties

- (NSArray *)propertyAttributeDelimiters {
	if (_propertyAttributeDelimiters) return _propertyAttributeDelimiters;
	_propertyAttributeDelimiters = [NSArray arrayWithObjects:@"(", @",", @")", @";", nil];
	return _propertyAttributeDelimiters;
}

@end
