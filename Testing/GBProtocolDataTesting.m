//
//  GBProtocolDataTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 28.7.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBProtocolData.h"

@interface GBProtocolDataTesting : SenTestCase
@end

@implementation GBProtocolDataTesting

- (void)testMergeDataFromObject_shouldMergeImplementationDetails {
	// setup - protocols don't merge any data, except they need to send base class merging message!
	GBProtocolData *original = [GBProtocolData protocolDataWithName:@"MyProtocol"];
	GBProtocolData *source = [GBProtocolData protocolDataWithName:@"MyProtocol"];
	[source registerDeclaredFile:@"file"];
	// execute
	[original mergeDataFromObject:source];
	// verify - simple testing here, fully tested in GBModelBaseTesting!
	assertThatInteger([original.declaredFiles count], equalToInteger(1));
}

- (void)testMergeDataFromObject_shouldMergeAdoptedProtocolsAndPreserveSourceData {
	//setup - only basic handling is done here; details are tested within GBAdoptedProtocolsProviderTesting!
	GBProtocolData *original = [GBProtocolData protocolDataWithName:@"MyProtocol"];
	[original.adoptedProtocols registerProtocol:[GBProtocolData protocolDataWithName:@"P1"]];
	[original.adoptedProtocols registerProtocol:[GBProtocolData protocolDataWithName:@"P2"]];
	GBProtocolData *source = [GBProtocolData protocolDataWithName:@"MyProtocol"];
	[source.adoptedProtocols registerProtocol:[GBProtocolData protocolDataWithName:@"P1"]];
	[source.adoptedProtocols registerProtocol:[GBProtocolData protocolDataWithName:@"P3"]];
	// execute
	[original mergeDataFromObject:source];
	// verify
	assertThatInteger([[original.adoptedProtocols protocols] count], equalToInteger(3));
	assertThatInteger([[source.adoptedProtocols protocols] count], equalToInteger(2));
}

- (void)testMergeDataFromObject_shouldRaiseExceptionOnDifferentProtocolName {
	//setup
	GBProtocolData *original = [GBProtocolData protocolDataWithName:@"MyProtocol"];
	GBProtocolData *source = [GBProtocolData protocolDataWithName:@"AnotherProtocol"];
	// execute & verify
	STAssertThrows([original mergeDataFromObject:source], nil);
}

@end
