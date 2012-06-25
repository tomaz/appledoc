//
//  ObjectiveCFileState.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectiveCConstantState.h"
#import "ObjectiveCFileState.h"

@interface ObjectiveCFileState ()
- (BOOL)parseClassExtension:(ObjectiveCParseData *)data;
- (BOOL)parseClassCategory:(ObjectiveCParseData *)data;
- (BOOL)parseDerivedClass:(ObjectiveCParseData *)data;
- (BOOL)parseRootClass:(ObjectiveCParseData *)data;
- (BOOL)parseProtocol:(ObjectiveCParseData *)data;
- (BOOL)parseEnum:(ObjectiveCParseData *)data;
- (BOOL)parseStruct:(ObjectiveCParseData *)data;
- (BOOL)parseConstant:(ObjectiveCParseData *)data;
@end

#pragma mark - 

@implementation ObjectiveCFileState

- (NSUInteger)parseWithData:(ObjectiveCParseData *)data {
	// Note that some of these methods must be invoked in proper order to avoid confusing data starting with similar tokens.
	if ([self parseClassExtension:data]) return GBResultOk;
	if ([self parseClassCategory:data]) return GBResultOk;
	if ([self parseClassCategory:data]) return GBResultOk;
	if ([self parseDerivedClass:data]) return GBResultOk;
	if ([self parseRootClass:data]) return GBResultOk;
	if ([self parseProtocol:data]) return GBResultOk;
	if ([self parseEnum:data]) return GBResultOk;
	if ([self parseStruct:data]) return GBResultOk;
	if ([self parseConstant:data]) return GBResultOk;
	[data.stream consume:1];
	return GBResultOk;
}

- (BOOL)parseClassExtension:(ObjectiveCParseData *)data {
	if (![data.stream matches:@"@", @"interface", GBTokens.any, @"(", @")", nil]) return NO;
	LogParDebug(@"Matched class extension interface.");
	PKToken *name = [data.stream la:2];
	[data.store setCurrentSourceInfo:data.stream.current];
	[data.store beginExtensionForClassWithName:name.stringValue];
	[data.stream consume:5];
	[data.parser pushState:data.parser.interfaceState];
	return YES;
}

- (BOOL)parseClassCategory:(ObjectiveCParseData *)data {
	if (![data.stream matches:@"@", @[@"interface", @"implementation"], GBTokens.any, @"(", GBTokens.any, @")", nil]) return NO;
	LogParDebug(@"Matched category interface or implementation.");
	PKToken *name = [data.stream la:2];
	PKToken *category = [data.stream la:4];
	[data.store setCurrentSourceInfo:data.stream.current];
	[data.store beginCategoryWithName:category.stringValue forClassWithName:name.stringValue];
	[data.stream consume:6];
	[data.parser pushState:data.parser.interfaceState];
	return YES;
}

- (BOOL)parseDerivedClass:(ObjectiveCParseData *)data {
	if (![data.stream matches:@"@", @[@"interface", @"implementation"], GBTokens.any, @":", GBTokens.any, nil]) return NO;
	LogParDebug(@"Matched class interface or implementation.");
	PKToken *name = [data.stream la:2];
	PKToken *derived = [data.stream la:4];
	[data.store setCurrentSourceInfo:data.stream.current];
	[data.store beginClassWithName:name.stringValue derivedFromClassWithName:derived.stringValue];
	[data.stream consume:3];
	[data.parser pushState:data.parser.interfaceState];
	return YES;
}

- (BOOL)parseRootClass:(ObjectiveCParseData *)data {
	if (![data.stream matches:@"@", @[@"interface", @"implementation"], GBTokens.any, nil]) return NO;
	LogParDebug(@"Matched root class interface or implementation.");
	PKToken *name = [data.stream la:2];
	[data.store setCurrentSourceInfo:data.stream.current];
	[data.store beginClassWithName:name.stringValue derivedFromClassWithName:nil];
	[data.stream consume:3];
	[data.parser pushState:data.parser.interfaceState];
	return YES;
}

- (BOOL)parseProtocol:(ObjectiveCParseData *)data {
	if (![data.stream matches:@"@", @"protocol", GBTokens.any, nil]) return NO;
	LogParDebug(@"Matched protocol definition.");
	PKToken *name = [data.stream la:2];
	[data.store setCurrentSourceInfo:data.stream.current];
	[data.store beginProtocolWithName:name.stringValue];
	[data.stream consume:3];
	[data.parser pushState:data.parser.interfaceState];
	return YES;
}

- (BOOL)parseEnum:(ObjectiveCParseData *)data {
	if (![data.stream matches:@"enum", nil]) return NO;
	LogParDebug(@"Matched %@, testing for enumeration.", data.stream.current);
	[data.parser pushState:data.parser.enumState];
	return YES;
}

- (BOOL)parseStruct:(ObjectiveCParseData *)data {
	if (![data.stream matches:@"struct", nil]) return NO;
	LogParDebug(@"Matched %@, testing for struct.", data.stream.current);
	[data.parser pushState:data.parser.structState];
	return YES;
}

- (BOOL)parseConstant:(ObjectiveCParseData *)data {
	if (![(id)data.parser.constantState doesDataContainConstant:data]) return NO;
	LogParDebug(@"Matched %@, testing for constant.", data.stream.current);
	[data.parser pushState:data.parser.constantState];
	return YES;
}

@end
