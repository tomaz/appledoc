//
//  GBProtocolData.m
//  appledoc
//
//  Created by Tomaz Kragelj on 26.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBAdoptedProtocolsProvider.h"
#import "GBProtocolData.h"

@implementation GBProtocolData

#pragma mark Initialization & disposal

+ (id)protocolDataWithName:(NSString *)name {
	return [[[self alloc] initWithName:name] autorelease];
}

- (id)initWithName:(NSString *)name {
	NSParameterAssert(name != nil && [name length] > 0);
	GBLogDebug(@"Initializing protocol with name %@...", name);
	self = [super init];
	if (self) {
		_protocolName = [name copy];
		_adoptedProtocols = [[GBAdoptedProtocolsProvider alloc] init];
	}
	return self;
}

#pragma mark Helper methods

- (void)mergeDataFromProtocol:(GBProtocolData *)source {
	// TODO: implement source files merging!
}

#pragma mark Overriden methods

- (NSString *)description {
	return self.nameOfProtocol;
}

#pragma mark Properties

@synthesize nameOfProtocol = _protocolName;
@synthesize adoptedProtocols = _adoptedProtocols;

@end
