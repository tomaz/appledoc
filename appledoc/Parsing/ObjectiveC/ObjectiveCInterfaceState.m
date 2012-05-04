//
//  ObjectiveCInterfaceState.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectiveCInterfaceState.h"

@interface ObjectiveCInterfaceState ()
@property (nonatomic, strong) NSArray *interfaceAdoptedProtocolDelimiters;
@end

#pragma mark - 

@implementation ObjectiveCInterfaceState

@synthesize interfaceAdoptedProtocolDelimiters = _interfaceAdoptedProtocolDelimiters;

#pragma mark - Stream parsing

- (NSUInteger)parseWithData:(ObjectiveCParseData *)data {
	if ([data.stream matches:@"<", nil]) {
		// Match adopted protocol(s).
		LogParDebug(@"Matching adopted protocols.");
		NSArray *delimiters = self.interfaceAdoptedProtocolDelimiters;
		NSUInteger result = [data.stream matchUntil:@">" block:^(PKToken *token, NSUInteger lookahead, BOOL *stop) {
			if ([token matches:delimiters]) return;
			LogParDebug(@"Matched adopted protocol %@", token);
			[data.store setCurrentSourceInfo:token];
			[data.store appendAdoptedProtocolWithName:token.stringValue];
		}];
		if (result == GBResultFailedMatch) [data.stream consume:1];
	} else if ([data.stream matches:@"-", nil] || [data.stream matches:@"+", nil]) {
		// Match method declaration or implementation. Must not consume otherwise we can't distinguish between instance and class method!
		LogParDebug(@"Matched %@, testing for method.", data.stream.current);
		[data.parser pushState:data.parser.methodState];
	} else if ([data.stream matches:@"@", @"property", nil]) {
		// Match property declaration. Although we could consume, we don't to keep compatible with methods above...
		LogParDebug(@"Matched property definition.");
		[data.parser pushState:data.parser.propertyState];
	} else if ([data.stream matches:@"@", @"end", nil]) {
		// Match end of interface or implementation.
		LogParDebug(@"Matched @end.");
		LogParVerbose(@"\n%@", data.store.currentRegistrationObject);
		[data.store setCurrentSourceInfo:data.stream.current];
		[data.store endCurrentObject];
		[data.stream consume:2];
		[data.parser popState];
	} else if ([data.stream matches:@"#", @"pragma", @"mark", nil]) {
		// Match #pragma mark. Must not consume here otherwise it makes it very hard to determine whether '-' following #pragma mark is part of #pragma or start of instance method!
		LogParDebug(@"Matched #pragma mark.");
		[data.parser pushState:data.parser.pragmaMarkState];
	} else {
		[data.stream consume:1];
	}
	return GBResultOk;
}

#pragma mark - Properties

- (NSArray *)interfaceAdoptedProtocolDelimiters {
	if (_interfaceAdoptedProtocolDelimiters) return _interfaceAdoptedProtocolDelimiters;
	_interfaceAdoptedProtocolDelimiters = [NSArray arrayWithObjects:@"<", @",", @">", nil];
	return _interfaceAdoptedProtocolDelimiters;
}

@end
