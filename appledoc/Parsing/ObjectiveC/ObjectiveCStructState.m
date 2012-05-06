//
//  ObjectiveCStructState.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectiveCStructState.h"

@interface ObjectiveCStructState ()
- (BOOL)consumeStructStartTokens:(ObjectiveCParseData *)data;
- (BOOL)parseStructName:(ObjectiveCParseData *)data;
- (BOOL)parseStructBody:(ObjectiveCParseData *)data;
- (BOOL)finalizeStruct:(ObjectiveCParseData *)data;
@property (nonatomic, strong) NSArray *structBodyStartDelimiters;
@property (nonatomic, strong) NSArray *structItemDelimiters;
@end

@implementation ObjectiveCStructState

@synthesize structBodyStartDelimiters = _structBodyStartDelimiters;
@synthesize structItemDelimiters = _structItemDelimiters;

#pragma mark - Parsing

- (NSUInteger)parseWithData:(ObjectiveCParseData *)data {
	if (![self consumeStructStartTokens:data]) return GBResultFailedMatch;
	if (![self parseStructName:data]) return GBResultFailedMatch;
	if (![self parseStructBody:data]) return GBResultFailedMatch;
	if (![self finalizeStruct:data]) return GBResultFailedMatch;
	return GBResultOk;
}

- (BOOL)consumeStructStartTokens:(ObjectiveCParseData *)data {
	LogParDebug(@"Matched struct.");
	[data.store setCurrentSourceInfo:data.stream.current];
	[data.store beginStruct];
	return YES;
}

- (BOOL)parseStructName:(ObjectiveCParseData *)data {
	__block PKToken *nameToken = nil;
	LogParDebug(@"Matching struct body start.");
	NSUInteger result = [data.stream matchUntil:@"{" block:^(PKToken *token, NSUInteger lookahead, BOOL *stop) {
		LogParDebug(@"Matched %@", token);
		if ([token matches:self.structBodyStartDelimiters]) return;
		nameToken = token;
	}];
	if (result == NSNotFound) {
		LogParDebug(@"Failed matching struct body start, bailing out.");
		[data.stream consume:1];
		[data.store cancelCurrentObject];
		[data.parser popState];
		return NO;
	}
	if (nameToken) LogParDebug(@"Matched %@ for struct name.", nameToken);
	// TODO register struct name - must add registration method and its handling in Store hierarchy!
	return YES;
}

- (BOOL)parseStructBody:(ObjectiveCParseData *)data {
	LogParDebug(@"Matching struct body.");
	NSMutableArray *itemTokens = [NSMutableArray array];
	NSUInteger result = [data.stream matchUntil:@"}" block:^(PKToken *token, NSUInteger lookahead, BOOL *stop) {
		LogParDebug(@"Matched %@.", token);
		if ([token matches:self.structItemDelimiters]) {
			if (itemTokens.count == 0) return;
			__block BOOL isTypeCommandNeeded = YES;
			__block BOOL wasTypeCommandIssues = NO;
			[data.store beginConstant];
			[itemTokens enumerateObjectsUsingBlock:^(PKToken *token, NSUInteger idx, BOOL *stop) {
				if (idx == itemTokens.count - 1) {
					if (wasTypeCommandIssues) [data.store endCurrentObject]; // types
					[data.store appendConstantName:token.stringValue];
					return;
				}
				if (isTypeCommandNeeded) {
					[data.store beginConstantTypes];
					wasTypeCommandIssues = YES;
					isTypeCommandNeeded = NO;
				}
				[data.store appendType:token.stringValue];
			}];
			[data.store endCurrentObject]; // constant
			[itemTokens removeAllObjects];
		} else {
			[itemTokens addObject:token];
		}
	}];
	if (result == NSNotFound) {
		LogParDebug(@"Failed matching end of enum body, bailing out.");
		[data.stream consume:1];
		[data.store cancelCurrentObject]; // struct
		[data.parser popState];
		return NO;
	}
	return YES;
}

- (BOOL)finalizeStruct:(ObjectiveCParseData *)data {	
	LogParDebug(@"Ending struct.");
	LogParVerbose(@"\n%@", data.store.currentRegistrationObject);
	[data.store endCurrentObject];
	[data.parser popState];
	return YES;
}

#pragma mark - Properties

- (NSArray *)structBodyStartDelimiters {
	if (_structBodyStartDelimiters) return _structBodyStartDelimiters;
	_structBodyStartDelimiters = [NSArray arrayWithObjects:@"{", @"struct", nil];
	return _structBodyStartDelimiters;
}

- (NSArray *)structItemDelimiters {
	if (_structItemDelimiters) return _structItemDelimiters;
	_structItemDelimiters = [NSArray arrayWithObjects:@",", @"}", @";", nil];
	return _structItemDelimiters;
}

@end
