//
//  ObjectiveCStructState.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectiveCStructState.h"

@implementation ObjectiveCStructState

- (NSUInteger)parseStream:(TokensStream *)stream forParser:(ObjectiveCParser *)parser store:(Store *)store {
	// Name is required, but skip everything else until '{'. Then match all definitions of type `type(s) <def>=value,` or `type(s) <def>;`.
	if ([stream matches:@"struct", nil]) {
		NSString *name = stream.current.stringValue;
		LogParDebug(@"Matched struct %@.", name);
		NSMutableString *declaration = [NSMutableString stringWithFormat:@"struct %@ {\n", name];
		[self skipStream:stream until:@"{" block:^(PKToken *token) { }];
		[self skipStream:stream until:@"}" block:^(PKToken *token) {
			LogParDebug(@"Matched %@", token);
			if ([token matches:@";"] || [token matches:@"="]) {
				PKToken *nameToken = [stream la:token offset:-1];
				[declaration appendFormat:@"%@\n", nameToken.stringValue];
			}
		}];
		[declaration appendString:@"}"];
		LogParVerbose(@"%@", declaration);
		LogParVerbose(@"");
		[parser popState];
	} else {
		[stream consume:1];
		[parser popState];
		return GBResultFailedMatch;
	}
	return GBResultOk;
}

@end
