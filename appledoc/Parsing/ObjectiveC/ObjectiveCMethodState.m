//
//  ObjectiveCMethodState.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectiveCMethodState.h"

@interface ObjectiveCMethodState ()
@property (nonatomic, strong) NSArray *methodTypeDelimiters;
@property (nonatomic, strong) NSArray *methodEndDelimiters;
@end

#pragma mark - 

@implementation ObjectiveCMethodState

#pragma mark - Parsing

- (NSUInteger)parseWithData:(ObjectiveCParseData *)data {
	if (![self consumeMethodStartTokens:data]) return GBResultFailedMatch;
	if (![self parseMethodReturnTypes:data]) return GBResultFailedMatch;
	if (![self parseMethodArguments:data]) return GBResultFailedMatch;
	if (![self parseMethodDescriptors:data]) return GBResultFailedMatch;
	if (![self skipMethodBody:data]) return GBResultFailedMatch;
	if (![self finalizeMethod:data]) return GBResultFailedMatch;
	return GBResultOk;
}

- (BOOL)consumeMethodStartTokens:(ObjectiveCParseData *)data {
	LogParDebug(@"Matched '%@', testing for method.", data.stream.current);
	BOOL isInstanceMethod = [data.stream.current matches:@"-"];
	[data.store setCurrentSourceInfo:data.stream.current];
	[data.store beginMethodDefinitionWithType:isInstanceMethod ? GBStoreTypes.instanceMethod : GBStoreTypes.classMethod];
	[data.stream consume:1];
	return YES;
}

- (BOOL)parseMethodReturnTypes:(ObjectiveCParseData *)data {
	NSArray *delimiters = self.methodTypeDelimiters;
	if ([data.stream.current matches:@"("]) {
		LogParDebug(@"Matching method result...");
		[data.store beginMethodResults];
		NSUInteger resultEndTokenIndex = [data.stream matchStart:@"(" end:delimiters block:^(PKToken *token, NSUInteger lookahead, BOOL *stop) {
			LogParDebug(@"Matched '%@'.", token);
			if ([token matches:delimiters]) return;
			[data.store appendType:token.stringValue];
		}];
		if (resultEndTokenIndex != 0) { 
			LogParDebug(@"Failed matching method result, bailing out!");
			[data.store cancelCurrentObject]; // result types
			[data.store cancelCurrentObject]; // method definition
			[data.parser popState];
			return NO;
		}
		[data.store endCurrentObject];
	}
	return YES;
}

- (BOOL)parseMethodArguments:(ObjectiveCParseData *)data {
	LogParDebug(@"Matching method arguments.");
	while (!data.stream.eof) {
		LogParDebug(@"Matching method argument %@.", data.stream.current);
		[data.store beginMethodArgument];
		if (![self parseMethodArgumentSelector:data]) return NO;
		if ([data.stream.current matches:@":"]) {
			LogParDebug(@"Matched colon, expecting types and variable name.");
			[data.stream consume:1];
			if (![self parseMethodArgumentTypes:data]) return NO;
			if (![self parseMethodArgumentVariable:data]) return NO;
		}
		[data.store endCurrentObject]; // method argument;
		if ([self isMethodDefinitionFinished:data]) break;
	}
	return YES;
}

- (BOOL)parseMethodArgumentSelector:(ObjectiveCParseData *)data {
	[data.store appendMethodArgumentSelector:data.stream.current.stringValue];
	[data.stream consume:1];
	return YES;
}

- (BOOL)parseMethodArgumentTypes:(ObjectiveCParseData *)data {
	if ([data.stream.current matches:@"("]) {
		LogParDebug(@"Matching method argument variable types.");
		NSArray *delimiters = self.methodTypeDelimiters;
		[data.store beginMethodArgumentTypes];
		NSUInteger endTokenIndex = [data.stream matchStart:@"(" end:delimiters block:^(PKToken *token, NSUInteger lookahead, BOOL *stop) {
			LogParDebug(@"Matched '%@'.", token);
			if ([token matches:delimiters]) return;
			[data.store appendType:token.stringValue];
		}];
		if (endTokenIndex != 0) {
			LogParDebug(@"Failed matching method argument variable types, bailing out!");
			[data.store cancelCurrentObject]; // type definitions
			[data.store cancelCurrentObject]; // method argument
			[data.store cancelCurrentObject]; // method definition
			[data.parser popState];
			return NO;
		}
		[data.store endCurrentObject]; // type definitions
	}
	return YES;
}

- (BOOL)parseMethodArgumentVariable:(ObjectiveCParseData *)data {
	// Argument variable is required!
	if ([data.stream.current matches:self.methodTypeDelimiters]) {
		LogParDebug(@"Failed matching method argument variable name, bailing out!");
		[data.store cancelCurrentObject]; // method argument
		[data.store cancelCurrentObject]; // method definition
		[data.parser popState];
		return NO;
	}
	LogParDebug(@"Matching method argument variable name.");
	[data.store appendMethodArgumentVariable:data.stream.current.stringValue];
	[data.stream consume:1];
	return YES;
}

- (BOOL)parseMethodDescriptors:(ObjectiveCParseData *)data {
	if ([data.stream.current matches:self.methodEndDelimiters]) return YES;
	if (![data doesStringLookLikeDescriptor:data.stream.current.stringValue]) return YES;
	LogParDebug(@"Parsing method descriptors.");
	[data.store beginMethodDescriptors];
	GBResult result = [data.stream matchUntil:self.methodEndDelimiters block:^(PKToken *token, NSUInteger lookahead, BOOL *stop) {
		LogParDebug(@"Matched '%@'.", token);
		if ([token matches:self.methodEndDelimiters]) return;
		[data.store appendDescriptor:token.stringValue];
	}];
	if (result == NSNotFound) {
		[data.store cancelCurrentObject]; // method descriptors
		[data.store cancelCurrentObject]; // method definition
		[data.parser popState];
		return NO;
	}
	[data.store endCurrentObject]; // method descriptors
	[data.stream rewind:1]; // we need to keep ; or { for further parsing!
	return YES;
}

- (BOOL)skipMethodBody:(ObjectiveCParseData *)data {
	if ([data.stream.current matches:@"{"]) {
		LogParDebug(@"Skipping method code block...");
		__block NSUInteger blockLevel = 1;
		NSUInteger tokensCount = [data.stream lookAheadWithBlock:^(PKToken *token, NSUInteger lookahead, BOOL *stop) {
			if ([token matches:@"{"]) {
				LogParDebug(@"Matched open brace at block level %lu", blockLevel);
				blockLevel++;
			} else if ([token matches:@"}"]) {
				LogParDebug(@"Matched close brace at block level %lu", blockLevel);
				if (--blockLevel == 1) {
					LogParDebug(@"Matched method close brace");
					*stop = YES;
				}
			}
		}];
		[data.stream consume:tokensCount];
	} else {
		LogParDebug(@"Skipping semicolon...");
		[data.stream consume:1];
	}
	return YES;
}

- (BOOL)finalizeMethod:(ObjectiveCParseData *)data {	
	LogParDebug(@"Ending method.");
	[data.store endCurrentObject]; // method definition
	[data.parser popState];
	return YES;
}

- (BOOL)isMethodDefinitionFinished:(ObjectiveCParseData *)data {
	if ([data.stream.current matchResult:self.methodEndDelimiters] != NSNotFound) return YES;
	if ([data doesStringLookLikeDescriptor:data.stream.current.stringValue]) return YES;
	return NO;
}

#pragma mark - Properties

- (NSArray *)methodTypeDelimiters {
	if (_methodTypeDelimiters) return _methodTypeDelimiters;
	LogIntDebug(@"Initializing type delimiters due to first access...");
	_methodTypeDelimiters = @[@")", @"(", @";", @"{"];
	return _methodTypeDelimiters;
}

- (NSArray *)methodEndDelimiters {
	if (_methodEndDelimiters) return _methodEndDelimiters;
	LogIntDebug(@"Initializing end delimiters due to first access...");
	_methodEndDelimiters = @[@";", @"{"];
	return _methodEndDelimiters;
}

@end
