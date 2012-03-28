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
		PKToken *name = [stream la:2];
		LogParVerbose(@"@interface %@ ()", name.stringValue);
		[store setCurrentSourceInfo:name];
		[store beginExtensionForClassWithName:name.stringValue];
		[stream consume:5];
		[parser pushState:parser.interfaceState];
	} else if ([stream matches:@"@", [NSArray arrayWithObjects:@"interface", @"implementation", nil], GBTokens.any, @"(", GBTokens.any, @")", nil]) {
		// Match category interface or implementation.
		PKToken *name = [stream la:2];
		PKToken *category = [stream la:4];
		LogParVerbose(@"@%@ %@ (%@)", [stream la:1].stringValue, name.stringValue, category.stringValue);
		[store setCurrentSourceInfo:name];
		[store beginCategoryWithName:category.stringValue forClassWithName:name.stringValue];
		[stream consume:6];
		[parser pushState:parser.interfaceState];
	} else if ([stream matches:@"@", [NSArray arrayWithObjects:@"interface", @"implementation", nil], GBTokens.any, @":", GBTokens.any, nil]) {
		// Match class interface or implementation.
		PKToken *name = [stream la:2];
		PKToken *derived = [stream la:4];
		LogParVerbose(@"@%@ %@ : %@", [stream la:1].stringValue, name.stringValue, derived.stringValue);
		[store setCurrentSourceInfo:name];
		[store beginClassWithName:name.stringValue derivedFromClassWithName:derived.stringValue];
		[stream consume:3];
		[parser pushState:parser.interfaceState];
	} else if ([stream matches:@"@", [NSArray arrayWithObjects:@"interface", @"implementation", nil], GBTokens.any, nil]) {
		// Match root class interface or implementation.
		PKToken *name = [stream la:2];
		LogParVerbose(@"@%@ %@", [stream la:1].stringValue, name.stringValue);
		[store setCurrentSourceInfo:name];
		[store beginClassWithName:name.stringValue derivedFromClassWithName:nil];
		[stream consume:3];
		[parser pushState:parser.interfaceState];
	} else if ([stream matches:@"@", @"protocol", GBTokens.any, nil]) {
		// Match protocol interface.
		PKToken *name = [stream la:2];
		LogParVerbose(@"@protocol %@", name.stringValue);
		[store setCurrentSourceInfo:name];
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
