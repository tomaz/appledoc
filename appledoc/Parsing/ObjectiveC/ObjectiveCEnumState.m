//
//  ObjectiveCEnumState.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectiveCEnumState.h"

@interface ObjectiveCEnumState ()
@property (nonatomic, strong) NSArray *enumItemDelimiters;
@end

@implementation ObjectiveCEnumState

@synthesize enumItemDelimiters = _enumItemDelimiters;

#pragma mark - Parsing

- (NSUInteger)parseWithData:(ObjectiveCParseData *)data {
	// Enumeration can optionally have a name, we're only interested in values, so skip everything until {
	LogParDebug(@"Matched enum.");
	[data.store setCurrentSourceInfo:data.stream.current];
	[data.store beginEnumeration];
	
	NSArray *delimiters = self.enumItemDelimiters;
	
	// Skip stream until '{', exit if not found.
	LogParDebug(@"Matching enum body start.");
	NSUInteger result = [data.stream matchUntil:@"{" block:^(PKToken *token, NSUInteger lookahead, BOOL *stop) { }];
	if (result == NSNotFound) {
		LogParDebug(@"Failed matching enum body start, bailing out.");
		[data.stream consume:1];
		[data.store cancelCurrentObject];
		[data.parser popState];
		return GBResultFailedMatch;
	}
	
	// Match all values up until '}', exit if not found.
	LogParDebug(@"Matching enum body.");
	__block BOOL isMatchingValue = NO;
	__block PKToken *valueStartToken = nil;
	__block PKToken *valueEndToken = nil;
	result = [data.stream matchUntil:@"}" block:^(PKToken *token, NSUInteger lookahead, BOOL *stop) {
		// When we match end of item or body, we should stop matching for value and continue with next item.
		if ([token matches:delimiters]) {
			if (isMatchingValue) {
				NSUInteger valueStartIndex = valueStartToken.offset;
				NSUInteger valueEndIndex = valueEndToken.offset + valueEndToken.stringValue.length;
				NSRange range = NSMakeRange(valueStartIndex, valueEndIndex - valueStartIndex);
				NSString *value = [data.stream.string substringWithRange:range];
				[data.store appendEnumerationValue:value];
				valueStartToken = nil;
				isMatchingValue = NO;
			}
			return;
		}
		
		// If we match = we should switch to value matching mode.
		if ([token matches:@"="]) {
			LogParDebug(@"Matched %@, registering value.", token);
			isMatchingValue = YES;
			return;
		}
		
		// If we're matching value, we should simply append current token to the end of value string. Otherwise we should register item.
		if (isMatchingValue) {
			LogParDebug(@"Matched enum value %@.", token);
			if (!valueStartToken) valueStartToken = token;
			valueEndToken = token;
		} else {
			LogParDebug(@"Matched enum constant %@", token);
			[data.store appendEnumerationItem:token.stringValue];
		}
	}];
	if (result == NSNotFound) {
		LogParDebug(@"Failed matching end of enum body, bailing out.");
		[data.stream consume:1];
		[data.store cancelCurrentObject];
		[data.parser popState];
		return GBResultFailedMatch;
	}
	
	// Finish off.
	LogParDebug(@"Ending enum.");
	LogParVerbose(@"\n%@", data.store.currentRegistrationObject);
	[data.store endCurrentObject];
	[data.parser popState];
	return GBResultOk;
}

#pragma mark - Properties

- (NSArray *)enumItemDelimiters {
	if (_enumItemDelimiters) return _enumItemDelimiters;
	_enumItemDelimiters = [NSArray arrayWithObjects:@",", @"}", @";", nil];
	return _enumItemDelimiters;
}

@end
