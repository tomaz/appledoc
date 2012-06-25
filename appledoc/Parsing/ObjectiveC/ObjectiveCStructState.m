//
//  ObjectiveCStructState.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectiveCStructState.h"

@interface ObjectiveCStructState ()
@property (nonatomic, assign) BOOL wasStructNameParsed;
@property (nonatomic, strong) NSArray *structItemDelimiters;
@end

@interface ObjectiveCStructState (TopLevelParsing)
- (BOOL)parseConstant:(ObjectiveCParseData *)data;
- (BOOL)parseStartOfStruct:(ObjectiveCParseData *)data;
- (BOOL)parseEndOfStruct:(ObjectiveCParseData *)data;
@end

@interface ObjectiveCParserState (StructDataParsing)
- (BOOL)consumeItemDeclaration:(ObjectiveCParseData *)data;
- (BOOL)consumeStructStartTokens:(ObjectiveCParseData *)data;
- (BOOL)parseStructNameBeforeBody:(ObjectiveCParseData *)data;
- (BOOL)parseStructNameAfterBody:(ObjectiveCParseData *)data;
- (BOOL)parseStructName:(ObjectiveCParseData *)data endDelimiters:(id)delimiters delimitersRequired:(BOOL)required;
@end

#pragma mark - 

@implementation ObjectiveCStructState

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
	LogIntDebug(@"Initializing struct item delimiters array due to first access...");
	_structItemDelimiters = @[@",", @";", @"}"];
	return _structItemDelimiters;
}

@end

#pragma mark - 

@implementation ObjectiveCStructState (TopLevelParsing)

- (BOOL)parseConstant:(ObjectiveCParseData *)data {
	LogParDebug(@"Matching constant definition.");
	[data.parser pushState:data.parser.constantState];
	return YES;
}

- (BOOL)parseStartOfStruct:(ObjectiveCParseData *)data {
	if (![data.stream matches:@"struct", nil]) return NO;
	if (![self consumeStructStartTokens:data]) return NO;
	if (![self parseStructNameBeforeBody:data]) return NO;
	return YES;
}

- (BOOL)parseEndOfStruct:(ObjectiveCParseData *)data {	
	if (![data.stream matches:@"}", nil]) return NO;
	LogParDebug(@"Matched struct end.");
	if (![self parseStructNameAfterBody:data]) return NO;
	LogParVerbose(@"\n%@", data.store.currentRegistrationObject);
	[data.store endCurrentObject];
	[data.parser popState];
	return YES;
}

@end

#pragma mark - 

@implementation ObjectiveCStructState (StructDataParsing)

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

- (BOOL)consumeStructStartTokens:(ObjectiveCParseData *)data {
	LogParDebug(@"Matched struct definition.");
	[data.store setCurrentSourceInfo:data.stream.current];
	[data.store beginStruct];
	[data.stream consume:1];
	return YES;
}

- (BOOL)parseStructNameBeforeBody:(ObjectiveCParseData *)data {
	self.wasStructNameParsed = NO;
	return [self parseStructName:data endDelimiters:@"{" delimitersRequired:YES];
}

- (BOOL)parseStructNameAfterBody:(ObjectiveCParseData *)data {
	return [self parseStructName:data endDelimiters:@";" delimitersRequired:NO];
}

- (BOOL)parseStructName:(ObjectiveCParseData *)data endDelimiters:(id)delimiters delimitersRequired:(BOOL)required {
	__block PKToken *nameToken = nil;
	LogParDebug(@"Matching struct body start.");
	NSUInteger matchResult = [data.stream matchUntil:delimiters block:^(PKToken *token, NSUInteger lookahead, BOOL *stop) {
		LogParDebug(@"Matched %@", token);
		if ([token matches:delimiters]) return;
		if ([token matches:@"}"]) return;
		if (!nameToken) nameToken = token;
	}];
	if (matchResult == NSNotFound) {
		if (required) {
			LogParDebug(@"Failed matching %@, bailing out.", delimiters);
			[data.store cancelCurrentObject];
			[data.parser popState];
			return NO;
		}
		return YES;
	}
	
	if (!nameToken) {
		self.wasStructNameParsed = NO;
		return YES;
	}
	
	LogParDebug(@"Matched %@ for struct name.", nameToken);
	if (!self.wasStructNameParsed) {
		[data.store appendStructName:nameToken.stringValue];
		self.wasStructNameParsed = YES;
	}
	return YES;
}

@end
