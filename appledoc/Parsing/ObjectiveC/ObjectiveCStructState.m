//
//  ObjectiveCStructState.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectiveCStructState.h"

@interface ObjectiveCStructState ()
@property (nonatomic, strong) NSArray *structItemDelimiters;
@end

@interface ObjectiveCStructState (TopLevelParsing)
- (BOOL)consumeItemDeclaration:(ObjectiveCParseData *)data;
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

@synthesize structItemDelimiters = _structItemDelimiters;

#pragma mark - Parsing

- (NSUInteger)parseWithData:(ObjectiveCParseData *)data {
	// Note that order is important - for proper handling constant must be last.
	if ([self parseStartOfStruct:data]) return GBResultOk;
	if ([self parseEndOfStruct:data]) return GBResultOk;
	if ([self consumeItemDeclaration:data]) return GBResultOk;
	if ([self parseConstant:data]) return GBResultOk;
	return GBResultFailedMatch;
}

#pragma mark - Properties

- (NSArray *)structItemDelimiters {
	if (_structItemDelimiters) return _structItemDelimiters;
	LogParDebug(@"Initializing struct item delimiters array due to first access...");
	_structItemDelimiters = [NSArray arrayWithObjects:@",", @";", @"}", nil];
	return _structItemDelimiters;
}

@end

#pragma mark - 

@implementation ObjectiveCStructState (TopLevelParsing)

- (BOOL)consumeItemDeclaration:(ObjectiveCParseData *)data {
	__block BOOL foundComma = NO;
	NSUInteger numberOfLookaheadTokens = [data.stream lookAheadWithBlock:^(PKToken *token, NSUInteger lookahead, BOOL *stop) {
		NSUInteger matchIndex = [token matchResult:self.structItemDelimiters];
		if (matchIndex == NSNotFound) return;
		if (matchIndex == 0) foundComma = YES;
		*stop = YES;
	}];
	if (!foundComma) return NO;
	LogParDebug(@"Ignoring item as it looks like it's delimited with comma!");
	[data.stream consume:numberOfLookaheadTokens];
	return YES;
}

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

@implementation ObjectiveCStructState (StructDataParsing)

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
