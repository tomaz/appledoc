//
//  ObjectiveCStructState.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectiveCStructState.h"

@interface ObjectiveCStructState (TopLevelParsing)
- (BOOL)parseConstant:(ObjectiveCParseData *)data;
- (BOOL)parseStartOfStruct:(ObjectiveCParseData *)data;
- (BOOL)parseEndOfStruct:(ObjectiveCParseData *)data;
@end

@interface ObjectiveCParserState (StructDataParsing)
- (BOOL)consumeStructStartTokens:(ObjectiveCParseData *)data;
- (BOOL)parseStructName:(ObjectiveCParseData *)data;
@end

#pragma mark - 

@implementation ObjectiveCStructState

- (NSUInteger)parseWithData:(ObjectiveCParseData *)data {
	// Note that order is important - for proper handling constant must be last.
	if ([self parseStartOfStruct:data]) return GBResultOk;
	if ([self parseEndOfStruct:data]) return GBResultOk;
	if ([self parseConstant:data]) return GBResultOk;
	return GBResultFailedMatch;
}

@end

#pragma mark - 

@implementation ObjectiveCParserState (TopLevelParsing)

- (BOOL)parseConstant:(ObjectiveCParseData *)data {
	LogParDebug(@"Matching constant definition.");
	[data.parser pushState:data.parser.constantState];
	return YES;
}

- (BOOL)parseStartOfStruct:(ObjectiveCParseData *)data {
	if (![data.stream matches:@"struct", nil]) return NO;
	if (![self consumeStructStartTokens:data]) return NO;
	if (![self parseStructName:data]) return NO;
	return YES;
}

- (BOOL)parseEndOfStruct:(ObjectiveCParseData *)data {	
	if (![data.stream matches:@"}", nil]) return NO;
	LogParDebug(@"Matched struct end.");
	LogParVerbose(@"\n%@", data.store.currentRegistrationObject);
	[data.store endCurrentObject];
	[data.stream consume:1];
	[data.parser popState];
	return YES;
}

@end

#pragma mark - 

@implementation ObjectiveCParserState (StructDataParsing)

- (BOOL)consumeStructStartTokens:(ObjectiveCParseData *)data {
	LogParDebug(@"Matched struct definition.");
	[data.store setCurrentSourceInfo:data.stream.current];
	[data.store beginStruct];
	[data.stream consume:1];
	return YES;
}

- (BOOL)parseStructName:(ObjectiveCParseData *)data {
	__block PKToken *nameToken = nil;
	LogParDebug(@"Matching struct body start.");
	NSUInteger result = [data.stream matchUntil:@"{" block:^(PKToken *token, NSUInteger lookahead, BOOL *stop) {
		LogParDebug(@"Matched %@", token);
		if ([token matches:@"{"]) return;
		nameToken = token;
	}];
	if (result == NSNotFound) {
		LogParDebug(@"Failed matching struct body start, bailing out.");
		[data.store cancelCurrentObject];
		[data.parser popState];
		return NO;
	}
	if (nameToken) {
		LogParDebug(@"Matched %@ for struct name.", nameToken);
		[data.store appendStructName:nameToken.stringValue];
	}
	return YES;
}

@end
