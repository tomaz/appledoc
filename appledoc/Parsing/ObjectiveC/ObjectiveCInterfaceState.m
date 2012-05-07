//
//  ObjectiveCInterfaceState.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectiveCInterfaceState.h"

@interface ObjectiveCInterfaceState ()
- (BOOL)parseAdoptedProtocols:(ObjectiveCParseData *)data;
- (BOOL)parseMethod:(ObjectiveCParseData *)data;
- (BOOL)parseProperty:(ObjectiveCParseData *)data;
- (BOOL)parsePragmaMark:(ObjectiveCParseData *)data;
- (BOOL)parseEndOfInterface:(ObjectiveCParseData *)data;
@property (nonatomic, strong) NSArray *interfaceAdoptedProtocolDelimiters;
@end

#pragma mark - 

@implementation ObjectiveCInterfaceState

@synthesize interfaceAdoptedProtocolDelimiters = _interfaceAdoptedProtocolDelimiters;

#pragma mark - Stream parsing

- (NSUInteger)parseWithData:(ObjectiveCParseData *)data {
	// Note that some of these methods must be invoked in proper order to avoid confusing data starting with similar tokens.
	if ([self parseAdoptedProtocols:data]) return GBResultOk;
	if ([self parseMethod:data]) return GBResultOk;
	if ([self parseProperty:data]) return GBResultOk;
	if ([self parsePragmaMark:data]) return GBResultOk;
	if ([self parseEndOfInterface:data]) return GBResultOk;
	[data.stream consume:1];
	return GBResultOk;
}

- (BOOL)parseAdoptedProtocols:(ObjectiveCParseData *)data {
	if (![data.stream matches:@"<", nil]) return NO;
	LogParDebug(@"Matching adopted protocols.");
	NSArray *delimiters = self.interfaceAdoptedProtocolDelimiters;
	NSUInteger result = [data.stream matchUntil:@">" block:^(PKToken *token, NSUInteger lookahead, BOOL *stop) {
		if ([token matches:delimiters]) return;
		LogParDebug(@"Matched adopted protocol %@", token);
		[data.store setCurrentSourceInfo:token];
		[data.store appendAdoptedProtocolWithName:token.stringValue];
	}];
	if (result == NSNotFound) [data.stream consume:1];
	return YES;
}

- (BOOL)parseMethod:(ObjectiveCParseData *)data {
	if (![data.stream matches:@"-", nil] && ![data.stream matches:@"+", nil]) return NO;
	// Must not consume otherwise we can't distinguish between instance and class method!
	LogParDebug(@"Matched %@, testing for method.", data.stream.current);
	[data.parser pushState:data.parser.methodState];
	return YES;
}

- (BOOL)parseProperty:(ObjectiveCParseData *)data {
	if (![data.stream matches:@"@", @"property", nil]) return NO;
	// Although we could consume, we don't to keep compatible with other methods...
	LogParDebug(@"Matched property definition.");
	[data.parser pushState:data.parser.propertyState];
	return YES;
}

- (BOOL)parsePragmaMark:(ObjectiveCParseData *)data {
	if (![data.stream matches:@"#", @"pragma", @"mark", nil]) return NO;
	// Must not consume here otherwise it makes it very hard to determine whether '-' following #pragma mark is part of #pragma or start of instance method!
	LogParDebug(@"Matched #pragma mark.");
	[data.parser pushState:data.parser.pragmaMarkState];
	return YES;
}

- (BOOL)parseEndOfInterface:(ObjectiveCParseData *)data {
	if (![data.stream matches:@"@", @"end", nil]) return NO;
	LogParDebug(@"Matched @end.");
	LogParVerbose(@"\n%@", data.store.currentRegistrationObject);
	[data.store endCurrentObject];
	[data.stream consume:2];
	[data.parser popState];
	return YES;
}

#pragma mark - Properties

- (NSArray *)interfaceAdoptedProtocolDelimiters {
	if (_interfaceAdoptedProtocolDelimiters) return _interfaceAdoptedProtocolDelimiters;
	_interfaceAdoptedProtocolDelimiters = [NSArray arrayWithObjects:@"<", @",", @">", nil];
	return _interfaceAdoptedProtocolDelimiters;
}

@end
