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

@synthesize methodTypeDelimiters = _methodTypeDelimiters;
@synthesize methodEndDelimiters = _methodEndDelimiters;

#pragma mark - Parsing

- (NSUInteger)parseWithData:(ObjectiveCParseData *)data {
	// Match method definition or declaration (skipping body in later case), then return to previous stream. If current stream position doesn't start a method, consume one token and return.
	LogParDebug(@"Matched %@, testing for method.", data.stream.current);
	BOOL isInstanceMethod = [data.stream.current matches:@"-"];
	[data.store setCurrentSourceInfo:data.stream.current];
	[data.store beginMethodDefinitionWithType:isInstanceMethod ? GBStoreTypes.instanceMethod : GBStoreTypes.classMethod];
	[data.stream consume:1];

	NSArray *delimiters = self.methodTypeDelimiters;
	
	// Parse return types.
	if ([data.stream.current matches:@"("]) {
		LogParDebug(@"Matching method result...");
		[data.store beginMethodResults];
		NSUInteger resultEndTokenIndex = [data.stream matchStart:@"(" end:delimiters block:^(PKToken *token, NSUInteger lookahead, BOOL *stop) {
			LogParDebug(@"Matched %@.", token);
			if ([token matches:delimiters]) return;
			[data.store appendType:token.stringValue];
		}];
		if (resultEndTokenIndex != 0) { 
			LogParDebug(@"Failed matching method result, bailing out!");
			[data.store cancelCurrentObject]; // result types
			[data.store cancelCurrentObject]; // method definition
			[data.parser popState];
			return GBResultFailedMatch;
		}
		[data.store endCurrentObject];
	}
	
	// Parse all arguments.
	LogParDebug(@"Matching method arguments.");
	BOOL isMatchingMethodBody = NO;
	while (!data.stream.eof) {
		LogParDebug(@"Matching method argument %@.", data.stream.current);
		
		// Parse selector name for the argument and skip colon.
		[data.store beginMethodArgument];
		[data.store appendMethodArgumentSelector:data.stream.current.stringValue];
		[data.stream consume:1];
		if ([data.stream.current matches:@":"]) {
			// If colon is found, try match variable types and name.
			LogParDebug(@"Matched colon, expecting types and variable name.");
			[data.stream consume:1];
		
			// Parse optional argument variable types.
			if ([data.stream.current matches:@"("]) {
				LogParDebug(@"Matching method argument variable types.");
				[data.store beginMethodArgumentTypes];
				NSUInteger endTokenIndex = [data.stream matchStart:@"(" end:delimiters block:^(PKToken *token, NSUInteger lookahead, BOOL *stop) {
					LogParDebug(@"Matched %@.", token);
					if ([token matches:delimiters]) return;
					[data.store appendType:token.stringValue];
				}];
				if (endTokenIndex != 0) {
					LogParDebug(@"Failed matching method argument variable types, bailing out!");
					[data.store cancelCurrentObject]; // type definitions
					[data.store cancelCurrentObject]; // method argument.
					[data.store cancelCurrentObject]; // method definition
					[data.parser popState];
					return GBResultFailedMatch;
				}
				[data.store endCurrentObject]; // type definitions
			}
			
			// Parse argument variable name.
			LogParDebug(@"Matching method argument variable name.");
			[data.store appendMethodArgumentVariable:data.stream.current.stringValue];
			[data.stream consume:1];
		}
		[data.store endCurrentObject]; // method argument;
		
		// Continue with next argument unless we reached end of definition.
		NSArray *end = self.methodEndDelimiters;
		NSUInteger endTokenIndex = [data.stream.current matchResult:end];
		if (endTokenIndex == NSNotFound) continue;
		if (endTokenIndex == 1) isMatchingMethodBody = YES;			
		break;
	}
	
	// Skip method code block.
	if (isMatchingMethodBody) {
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
	
	LogParDebug(@"Ending method.");
	[data.store endCurrentObject]; // method definition
	[data.parser popState];
	return GBResultOk;
}

#pragma mark - Properties

- (NSArray *)methodTypeDelimiters {
	if (_methodTypeDelimiters) return _methodTypeDelimiters;
	_methodTypeDelimiters = [NSArray arrayWithObjects:@")", @"(", @";", @"{", nil];
	return _methodTypeDelimiters;
}

- (NSArray *)methodEndDelimiters {
	if (_methodEndDelimiters) return _methodEndDelimiters;
	_methodEndDelimiters = [NSArray arrayWithObjects:@";", @"{", nil];
	return _methodEndDelimiters;
}

@end
