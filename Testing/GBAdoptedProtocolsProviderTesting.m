//
//  GBAdoptedProtocolsProviderTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 26.7.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBProtocolData.h"
#import "GBAdoptedProtocolsProvider.h"

@interface GBAdoptedProtocolsProviderTesting : GHTestCase
@end

@implementation GBAdoptedProtocolsProviderTesting

#pragma mark Protocol registration testing

- (void)testRegisterProtocol_shouldAddProtocolToList {
	// setup
	GBAdoptedProtocolsProvider *provider = [[GBAdoptedProtocolsProvider alloc] initWithParentObject:self];
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
	GBAdoptedProtocolsProvider *provider = [[GBAdoptedProtocolsProvider alloc] initWithParentObject:self];
	GBProtocolData *protocol = [[GBProtocolData alloc] initWithName:@"MyProtocol"];
	// execute
	[provider registerProtocol:protocol];
	[provider registerProtocol:protocol];
	// verify
	assertThatInteger([[provider.protocols allObjects] count], equalToInteger(1));
}

- (void)testRegisterProtocol_shouldMergeDifferentInstanceWithSameName {
	// setup
	GBAdoptedProtocolsProvider *provider = [[GBAdoptedProtocolsProvider alloc] initWithParentObject:self];
	GBProtocolData *source = [[GBProtocolData alloc] initWithName:@"MyProtocol"];
	OCMockObject *original = [OCMockObject niceMockForClass:[GBProtocolData class]];
	[[[original stub] andReturn:@"MyProtocol"] nameOfProtocol];
	[[original expect] mergeDataFromObject:source];
	[provider registerProtocol:(GBProtocolData *)original];
	// execute
	[provider registerProtocol:source];
	// verify
	[original verify];
}

#pragma mark Protocol merging handling

- (void)testMergeDataFromProtocolProvider_shouldMergeAllDifferentProtocols {
	// setup
	GBAdoptedProtocolsProvider *original = [[GBAdoptedProtocolsProvider alloc] initWithParentObject:self];
	[original registerProtocol:[GBProtocolData protocolDataWithName:@"P1"]];
	[original registerProtocol:[GBProtocolData protocolDataWithName:@"P2"]];
	GBAdoptedProtocolsProvider *source = [[GBAdoptedProtocolsProvider alloc] initWithParentObject:self];
	[source registerProtocol:[GBProtocolData protocolDataWithName:@"P1"]];
	[source registerProtocol:[GBProtocolData protocolDataWithName:@"P3"]];
	// execute
	[original mergeDataFromProtocolsProvider:source];
	// verify - only basic verification here, details within GBProtocolDataTesting!
	NSArray *protocols = [original protocolsSortedByName];
	assertThatInteger([protocols count], equalToInteger(3));
	assertThat([[protocols objectAtIndex:0] nameOfProtocol], is(@"P1"));
	assertThat([[protocols objectAtIndex:1] nameOfProtocol], is(@"P2"));
	assertThat([[protocols objectAtIndex:2] nameOfProtocol], is(@"P3"));
}

- (void)testMergeDataFromProtocolProvider_shouldPreserveSourceData {
	// setup
	GBAdoptedProtocolsProvider *original = [[GBAdoptedProtocolsProvider alloc] initWithParentObject:self];
	[original registerProtocol:[GBProtocolData protocolDataWithName:@"P1"]];
	[original registerProtocol:[GBProtocolData protocolDataWithName:@"P2"]];
	GBAdoptedProtocolsProvider *source = [[GBAdoptedProtocolsProvider alloc] initWithParentObject:self];
	[source registerProtocol:[GBProtocolData protocolDataWithName:@"P1"]];
	[source registerProtocol:[GBProtocolData protocolDataWithName:@"P3"]];
	// execute
	[original mergeDataFromProtocolsProvider:source];
	// verify - only basic verification here, details within GBProtocolDataTesting!
	NSArray *protocols = [source protocolsSortedByName];
	assertThatInteger([protocols count], equalToInteger(2));
	assertThat([[protocols objectAtIndex:0] nameOfProtocol], is(@"P1"));
	assertThat([[protocols objectAtIndex:1] nameOfProtocol], is(@"P3"));
}

#pragma mark Protocols replacing handling

- (void)testReplaceProtocolWithProtocol_shouldReplaceObjects {
	// setup
	GBAdoptedProtocolsProvider *provider = [[GBAdoptedProtocolsProvider alloc] initWithParentObject:self];
	GBProtocolData *protocol1 = [GBProtocolData protocolDataWithName:@"P1"];
	GBProtocolData *protocol2 = [GBProtocolData protocolDataWithName:@"P2"];
	GBProtocolData *protocol3 = [GBProtocolData protocolDataWithName:@"P3"];
	[provider registerProtocol:protocol1];
	[provider registerProtocol:protocol2];
	// execute
	[provider replaceProtocol:protocol1 withProtocol:protocol3];
	// verify
	NSArray *protocols = [provider protocolsSortedByName];
	assertThatInteger([protocols count], equalToInteger(2));
	assertThat([[protocols objectAtIndex:0] nameOfProtocol], is(@"P2"));
	assertThat([[protocols objectAtIndex:1] nameOfProtocol], is(@"P3"));
}

@end
