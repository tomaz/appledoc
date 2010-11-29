//
//  GBProtocolDataTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 28.7.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBDataObjects.h"

@interface GBProtocolDataTesting : GHTestCase
@end

@implementation GBProtocolDataTesting

- (void)testMergeDataFromObject_shouldMergeImplementationDetails {
	// setup - protocols don't merge any data, except they need to send base class merging message!
	GBProtocolData *original = [GBProtocolData protocolDataWithName:@"MyProtocol"];
	GBProtocolData *source = [GBProtocolData protocolDataWithName:@"MyProtocol"];
	[source registerSourceInfo:[GBSourceInfo infoWithFilename:@"file" lineNumber:1]];
	// execute
	[original mergeDataFromObject:source];
	// verify - simple testing here, fully tested in GBModelBaseTesting!
	assertThatInteger([original.sourceInfos count], equalToInteger(1));
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

- (void)testMergeDataFromObject_shouldMergeMethodsAndPreserveSourceData {
	//setup - only basic handling is done here; details are tested within GBIvarsProviderTesting!
	GBProtocolData *original = [GBProtocolData protocolDataWithName:@"MyProtocol"];
	[original.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"m1", nil]];
	[original.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"m2", nil]];
	GBProtocolData *source = [GBProtocolData protocolDataWithName:@"MyProtocol"];
	[source.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"m1", nil]];
	[source.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"m3", nil]];
	// execute
	[original mergeDataFromObject:source];
	// verify
	assertThatInteger([[original.methods methods] count], equalToInteger(3));
	assertThatInteger([[source.methods methods] count], equalToInteger(2));
}

#pragma mark Helper methods

- (void)testIsTopLevelObject_shouldReturnYES {
	// setup & execute
	GBProtocolData *protocol = [GBProtocolData protocolDataWithName:@"Protocol"];
	// verify
	assertThatBool(protocol.isTopLevelObject, equalToBool(YES));
}

@end
