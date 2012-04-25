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

- (NSUInteger)parseStream:(TokensStream *)stream forParser:(ObjectiveCParser *)parser store:(Store *)store {
	// Match method definition or declaration (skipping body in later case), then return to previous stream. If current stream position doesn't start a method, consume one token and return.
	LogParDebug(@"Matched %@, testing for method.", stream.current);
	BOOL isInstanceMethod = [stream.current matches:@"-"];
	[store setCurrentSourceInfo:stream.current];
	[store beginMethodDefinitionWithType:isInstanceMethod ? GBStoreTypes.instanceMethod : GBStoreTypes.classMethod];
	[stream consume:1];

	NSArray *delimiters = self.methodTypeDelimiters;
	
	// Parse return types.
	if ([stream.current matches:@"("]) {
		LogParDebug(@"Matching method result...");
		[store beginMethodResults];
		NSUInteger resultEndTokenIndex = [stream matchStart:@"(" end:delimiters block:^(PKToken *token, NSUInteger lookahead, BOOL *stop) {
			LogParDebug(@"Matched %@.", token);
			if ([token matches:delimiters]) return;
			[store appendType:token.stringValue];
		}];
		if (resultEndTokenIndex != 0) { 
			LogParDebug(@"Failed matching method result, bailing out!");
			[store cancelCurrentObject]; // result types
			[store cancelCurrentObject]; // method definition
			[parser popState];
			return GBResultFailedMatch;
		}
		[store endCurrentObject];
	}
	
	// Parse all arguments.
	LogParDebug(@"Matching method arguments.");
	BOOL isMatchingMethodBody = NO;
	while (!stream.eof) {
		LogParDebug(@"Matching method argument %@.", stream.current);
		
		// Parse selector name for the argument and skip colon.
		[store beginMethodArgument];
		[store appendMethodArgumentSelector:stream.current.stringValue];
		[stream consume:1];
		if ([stream.current matches:@":"]) {
			// If colon is found, try match variable types and name.
			LogParDebug(@"Matched colon, expecting types and variable name.");
			[stream consume:1];
		
			// Parse optional argument variable types.
			if ([stream.current matches:@"("]) {
				LogParDebug(@"Matching method argument variable types.");
				[store beginMethodArgumentTypes];
				NSUInteger endTokenIndex = [stream matchStart:@"(" end:delimiters block:^(PKToken *token, NSUInteger lookahead, BOOL *stop) {
					LogParDebug(@"Matched %@.", token);
					if ([token matches:delimiters]) return;
					[store appendType:token.stringValue];
				}];
				if (endTokenIndex != 0) {
					LogParDebug(@"Failed matching method argument variable types, bailing out!");
					[store cancelCurrentObject]; // type definitions
					[store cancelCurrentObject]; // method argument.
					[store cancelCurrentObject]; // method definition
					[parser popState];
					return GBResultFailedMatch;
				}
				[store endCurrentObject]; // type definitions
			}
			
			// Parse argument variable name.
			LogParDebug(@"Matching method argument variable name.");
			[store appendMethodArgumentVariable:stream.current.stringValue];
			[stream consume:1];
		}
		[store endCurrentObject]; // method argument;
		
		// Continue with next argument unless we reached end of definition.
		NSArray *end = self.methodEndDelimiters;
		NSUInteger endTokenIndex = [stream.current matchResult:end];
		if (endTokenIndex == NSNotFound) continue;
		if (endTokenIndex == 1) isMatchingMethodBody = YES;			
		break;
	}
	
	// Skip method code block.
	if (isMatchingMethodBody) {
		LogParDebug(@"Skipping method code block...");
		__block NSUInteger blockLevel = 1;
		NSUInteger tokensCount = [stream lookAheadWithBlock:^(PKToken *token, NSUInteger lookahead, BOOL *stop) {
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
		[stream consume:tokensCount];
	} else {
		LogParDebug(@"Skipping semicolon...");
		[stream consume:1];
	}
	
	LogParDebug(@"Ending method.");
	[store endCurrentObject]; // method definition
	[parser popState];
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
