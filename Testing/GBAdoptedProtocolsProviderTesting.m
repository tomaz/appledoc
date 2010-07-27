//
//  GBAdoptedProtocolsProviderTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 26.7.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBAdoptedProtocolsProvider.h"

@interface GBAdoptedProtocolsProviderTesting : SenTestCase
@end

@implementation GBAdoptedProtocolsProviderTesting

#pragma mark Protocol registration testing

- (void)testRegisterProtocol_shouldAddProtocolToList {
	// setup
	GBAdoptedProtocolsProvider *provider = [[GBAdoptedProtocolsProvider alloc] init];
	GBProtocolData *protocol = [[GBProtocolData alloc] initWithName:@"MyProtocol"];
	// execute
	[provider registerProtocol:protocol];
	// verify
	assertThatBool([provider.protocols containsObject:protocol], equalToBool(YES));
	assertThatInteger([[provider.protocols allObjects] count], equalToInteger(1));
	assertThat([[provider.protocols allObjects] objectAtIndex:0], is(protocol));
}

- (void)testRegisterProtocol_shouldIgnoreSameInstance {
	// setup
	GBAdoptedProtocolsProvider *provider = [[GBAdoptedProtocolsProvider alloc] init];
	GBProtocolData *protocol = [[GBProtocolData alloc] initWithName:@"MyProtocol"];
	// execute
	[provider registerProtocol:protocol];
	[provider registerProtocol:protocol];
	// verify
	assertThatInteger([[provider.protocols allObjects] count], equalToInteger(1));
}

- (void)testRegisterProtocol_shouldPreventAddingDifferentInstanceWithSameName {
	// setup
	GBAdoptedProtocolsProvider *provider = [[GBAdoptedProtocolsProvider alloc] init];
	GBProtocolData *protocol1 = [[GBProtocolData alloc] initWithName:@"MyProtocol"];
	GBProtocolData *protocol2 = [[GBProtocolData alloc] initWithName:@"MyProtocol"];
	[provider registerProtocol:protocol1];
	// execute & verify
	STAssertThrows([provider registerProtocol:protocol2], nil);
}

@end
