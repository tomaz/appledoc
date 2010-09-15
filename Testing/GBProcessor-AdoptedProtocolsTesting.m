//
//  GBProcessor-AdoptedProtocolsTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 27.8.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBDataObjects.h"
#import "GBStore.h"
#import "GBProcessor.h"

@interface GBProcessorAdoptedProtocolsTesting : GHTestCase
@end

#pragma mark -

@implementation GBProcessorAdoptedProtocolsTesting

- (void)testProcessObjectsFromStore_shouldReplaceKnownClassAdoptedProtocolsWithProtocolsFromStore {
	// setup
	GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBProtocolData *realProtocol = [GBProtocolData protocolDataWithName:@"P1"];
	GBProtocolData *adoptedProtocol1 = [GBProtocolData protocolDataWithName:@"P1"];
	GBProtocolData *adoptedProtocol2 = [GBProtocolData protocolDataWithName:@"P2"];
	GBClassData *class = [GBClassData classDataWithName:@"Class"];
	[class.adoptedProtocols registerProtocol:adoptedProtocol1];
	[class.adoptedProtocols registerProtocol:adoptedProtocol2];
	GBStore *store = [[GBStore alloc] init];
	[store registerClass:class];
	[store registerProtocol:realProtocol];
	// execute
	[processor processObjectsFromStore:store];
	// verify
	NSArray *protocols = [class.adoptedProtocols protocolsSortedByName];
	assertThatInteger([protocols count], equalToInteger(2));
	assertThat([protocols objectAtIndex:0], is(realProtocol));
	assertThat([protocols objectAtIndex:1], is(adoptedProtocol2));
}

- (void)testProcessObjectsFromStore_shouldReplaceKnownCategoryAdoptedProtocolsWithProtocolsFromStore {
	// setup
	GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBProtocolData *realProtocol = [GBProtocolData protocolDataWithName:@"P1"];
	GBProtocolData *adoptedProtocol1 = [GBProtocolData protocolDataWithName:@"P1"];
	GBProtocolData *adoptedProtocol2 = [GBProtocolData protocolDataWithName:@"P2"];
	GBCategoryData *category = [GBCategoryData categoryDataWithName:@"Category" className:@"Class"];
	[category.adoptedProtocols registerProtocol:adoptedProtocol1];
	[category.adoptedProtocols registerProtocol:adoptedProtocol2];
	GBStore *store = [[GBStore alloc] init];
	[store registerCategory:category];
	[store registerProtocol:realProtocol];
	// execute
	[processor processObjectsFromStore:store];
	// verify
	NSArray *protocols = [category.adoptedProtocols protocolsSortedByName];
	assertThatInteger([protocols count], equalToInteger(2));
	assertThat([protocols objectAtIndex:0], is(realProtocol));
	assertThat([protocols objectAtIndex:1], is(adoptedProtocol2));
}

- (void)testProcessObjectsFromStore_shouldReplaceKnownProtocolAdoptedProtocolsWithProtocolsFromStore {
	// setup
	GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBProtocolData *realProtocol = [GBProtocolData protocolDataWithName:@"P1"];
	GBProtocolData *adoptedProtocol1 = [GBProtocolData protocolDataWithName:@"P1"];
	GBProtocolData *adoptedProtocol2 = [GBProtocolData protocolDataWithName:@"P2"];
	GBProtocolData *protocol = [GBProtocolData protocolDataWithName:@"Protocol"];
	[protocol.adoptedProtocols registerProtocol:adoptedProtocol1];
	[protocol.adoptedProtocols registerProtocol:adoptedProtocol2];
	GBStore *store = [[GBStore alloc] init];
	[store registerProtocol:protocol];
	[store registerProtocol:realProtocol];
	// execute
	[processor processObjectsFromStore:store];
	// verify
	NSArray *protocols = [protocol.adoptedProtocols protocolsSortedByName];
	assertThatInteger([protocols count], equalToInteger(2));
	assertThat([protocols objectAtIndex:0], is(realProtocol));
	assertThat([protocols objectAtIndex:1], is(adoptedProtocol2));
}

@end
