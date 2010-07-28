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

- (void)testMergeDataFromProtocol_shouldMergeImplementationDetails {
	// setup
	GBProtocolData *original = [GBProtocolData protocolDataWithName:@"MyProtocol"];
	GBProtocolData *source = [GBProtocolData protocolDataWithName:@"MyProtocol"];
	// execute
	[original mergeDataFromProtocol:source];
	// verify
	STFail(@"Implement source files for protocols!");
}

- (void)testMergeDataFromProtocol_shouldPreserveSourceImplementationDetails {
	// setup
	GBProtocolData *original = [GBProtocolData protocolDataWithName:@"MyProtocol"];
	GBProtocolData *source = [GBProtocolData protocolDataWithName:@"MyProtocol"];
	// execute
	[original mergeDataFromProtocol:source];
	// verify
	STFail(@"Implement source files for protocols!");
}

@end
