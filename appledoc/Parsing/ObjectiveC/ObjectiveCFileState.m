//
//  ObjectiveCFileState.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectiveCFileState.h"

@implementation ObjectiveCFileState

- (NSUInteger)parseStream:(TokensStream *)stream forParser:(ObjectiveCParser *)parser store:(Store *)store {
	if ([stream matches:@"@", @"interface", GBTokens.any, @"(", @")", nil]) {
		// Match class extension.
		NSString *className = [[stream la:2] stringValue];
		LogParVerbose(@"@interface %@ ()", className);
		[stream consume:5];
		[parser pushState:parser.interfaceState];
	} else if ([stream matches:@"@", [NSArray arrayWithObjects:@"interface", @"implementation", nil], GBTokens.any, @"(", GBTokens.any, @")", nil]) {
		// Match category interface or implementation.
		NSString *type = [[stream la:1] stringValue];
		NSString *className = [[stream la:2] stringValue];
		NSString *categoryName = [[stream la:4] stringValue];
		LogParVerbose(@"@%@ %@ (%@)", type, className, categoryName);
		[stream consume:6];
		[parser pushState:parser.interfaceState];
	} else if ([stream matches:@"@", [NSArray arrayWithObjects:@"interface", @"implementation", nil], GBTokens.any, nil]) {
		// Match class interface or implementation.
		NSString *type = [[stream la:1] stringValue];
		NSString *className = [[stream la:2] stringValue];
		LogParVerbose(@"@%@ %@", type, className);
		[stream consume:3];
		[parser pushState:parser.interfaceState];
	} else if ([stream matches:@"@", @"protocol", GBTokens.any, nil]) {
		// Match protocol interface.
		NSString *protocolName = [[stream la:2] stringValue];
		LogParVerbose(@"@protocol %@", protocolName);
		[stream consume:3];
		[parser pushState:parser.interfaceState];
	} else if ([stream matches:@"enum", nil]) {
		// Match enum for constants.
		[parser pushState:parser.enumState];
	} else if ([stream matches:@"struct", nil]) {
		// Match struct for namespaced constants.
		[parser pushState:parser.structState];
	} else {
		[stream consume:1];
	}
	return GBResultOk;
}

@end
