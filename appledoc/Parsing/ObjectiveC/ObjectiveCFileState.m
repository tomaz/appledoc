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
		LogParDebug(@"Matched class extension interface.");
		PKToken *name = [stream la:2];
		[store setCurrentSourceInfo:stream.current];
		[store beginExtensionForClassWithName:name.stringValue];
		[stream consume:5];
		[parser pushState:parser.interfaceState];
	} else if ([stream matches:@"@", [NSArray arrayWithObjects:@"interface", @"implementation", nil], GBTokens.any, @"(", GBTokens.any, @")", nil]) {
		// Match category interface or implementation.
		LogParDebug(@"Matched category interface or implementation.");
		PKToken *name = [stream la:2];
		PKToken *category = [stream la:4];
		[store setCurrentSourceInfo:stream.current];
		[store beginCategoryWithName:category.stringValue forClassWithName:name.stringValue];
		[stream consume:6];
		[parser pushState:parser.interfaceState];
	} else if ([stream matches:@"@", [NSArray arrayWithObjects:@"interface", @"implementation", nil], GBTokens.any, @":", GBTokens.any, nil]) {
		// Match class interface or implementation.
		LogParDebug(@"Matched class interface or implementation.");
		PKToken *name = [stream la:2];
		PKToken *derived = [stream la:4];
		[store setCurrentSourceInfo:stream.current];
		[store beginClassWithName:name.stringValue derivedFromClassWithName:derived.stringValue];
		[stream consume:3];
		[parser pushState:parser.interfaceState];
	} else if ([stream matches:@"@", [NSArray arrayWithObjects:@"interface", @"implementation", nil], GBTokens.any, nil]) {
		// Match root class interface or implementation.
		LogParDebug(@"Matched root class interface or implementation.");
		PKToken *name = [stream la:2];
		[store setCurrentSourceInfo:stream.current];
		[store beginClassWithName:name.stringValue derivedFromClassWithName:nil];
		[stream consume:3];
		[parser pushState:parser.interfaceState];
	} else if ([stream matches:@"@", @"protocol", GBTokens.any, nil]) {
		// Match protocol interface.
		LogParDebug(@"Matched protocol definition.");
		PKToken *name = [stream la:2];
		[store setCurrentSourceInfo:stream.current];
		[store beginProtocolWithName:name.stringValue];
		[stream consume:3];
		[parser pushState:parser.interfaceState];
	} else if ([stream matches:@"enum", nil]) {
		// Match enum for constants.
		LogParDebug(@"Matched %@, testing for enumeration.", stream.current);
		[parser pushState:parser.enumState];
	} else if ([stream matches:@"struct", nil]) {
		// Match struct for namespaced constants.
		LogParDebug(@"Matched %@, testing for struct.", stream.current);
		[parser pushState:parser.structState];
	} else {
		[stream consume:1];
	}
	return GBResultOk;
}

@end
