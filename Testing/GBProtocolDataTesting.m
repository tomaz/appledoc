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

@end
