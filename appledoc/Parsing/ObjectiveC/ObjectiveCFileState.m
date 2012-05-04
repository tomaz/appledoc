//
//  ObjectiveCFileState.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectiveCFileState.h"

@implementation ObjectiveCFileState

- (NSUInteger)parseWithData:(ObjectiveCParseData *)data {
	if ([data.stream matches:@"@", @"interface", GBTokens.any, @"(", @")", nil]) {
		// Match class extension.
		LogParDebug(@"Matched class extension interface.");
		PKToken *name = [data.stream la:2];
		[data.store setCurrentSourceInfo:data.stream.current];
		[data.store beginExtensionForClassWithName:name.stringValue];
		[data.stream consume:5];
		[data.parser pushState:data.parser.interfaceState];
	} else if ([data.stream matches:@"@", [NSArray arrayWithObjects:@"interface", @"implementation", nil], GBTokens.any, @"(", GBTokens.any, @")", nil]) {
		// Match category interface or implementation.
		LogParDebug(@"Matched category interface or implementation.");
		PKToken *name = [data.stream la:2];
		PKToken *category = [data.stream la:4];
		[data.store setCurrentSourceInfo:data.stream.current];
		[data.store beginCategoryWithName:category.stringValue forClassWithName:name.stringValue];
		[data.stream consume:6];
		[data.parser pushState:data.parser.interfaceState];
	} else if ([data.stream matches:@"@", [NSArray arrayWithObjects:@"interface", @"implementation", nil], GBTokens.any, @":", GBTokens.any, nil]) {
		// Match class interface or implementation.
		LogParDebug(@"Matched class interface or implementation.");
		PKToken *name = [data.stream la:2];
		PKToken *derived = [data.stream la:4];
		[data.store setCurrentSourceInfo:data.stream.current];
		[data.store beginClassWithName:name.stringValue derivedFromClassWithName:derived.stringValue];
		[data.stream consume:3];
		[data.parser pushState:data.parser.interfaceState];
	} else if ([data.stream matches:@"@", [NSArray arrayWithObjects:@"interface", @"implementation", nil], GBTokens.any, nil]) {
		// Match root class interface or implementation.
		LogParDebug(@"Matched root class interface or implementation.");
		PKToken *name = [data.stream la:2];
		[data.store setCurrentSourceInfo:data.stream.current];
		[data.store beginClassWithName:name.stringValue derivedFromClassWithName:nil];
		[data.stream consume:3];
		[data.parser pushState:data.parser.interfaceState];
	} else if ([data.stream matches:@"@", @"protocol", GBTokens.any, nil]) {
		// Match protocol interface.
		LogParDebug(@"Matched protocol definition.");
		PKToken *name = [data.stream la:2];
		[data.store setCurrentSourceInfo:data.stream.current];
		[data.store beginProtocolWithName:name.stringValue];
		[data.stream consume:3];
		[data.parser pushState:data.parser.interfaceState];
	} else if ([data.stream matches:@"enum", nil]) {
		// Match enum for constants.
		LogParDebug(@"Matched %@, testing for enumeration.", data.stream.current);
		[data.parser pushState:data.parser.enumState];
	} else if ([data.stream matches:@"struct", nil]) {
		// Match struct for namespaced constants.
		LogParDebug(@"Matched %@, testing for struct.", data.stream.current);
		[data.parser pushState:data.parser.structState];
	} else {
		[data.stream consume:1];
	}
	return GBResultOk;
}

@end
