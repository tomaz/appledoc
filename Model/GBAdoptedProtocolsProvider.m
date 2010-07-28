//
//  GBAdoptedProtocolsProvider.m
//  appledoc
//
//  Created by Tomaz Kragelj on 26.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBAdoptedProtocolsProvider.h"

@implementation GBAdoptedProtocolsProvider

#pragma mark Initialization & disposal

- (id)init {
	self = [super init];
	if (self) {
		_protocols = [[NSMutableSet alloc] init];
		_protocolsByName = [[NSMutableDictionary alloc] init];
	}
	return self;
}

#pragma mark Helper methods

- (void)registerProtocol:(GBProtocolData *)protocol {
	NSParameterAssert(protocol != nil);
	GBLogDebug(@"Registering protocol %@...", protocol);
	if ([_protocols containsObject:protocol]) return;
	GBProtocolData *existingProtocol = [_protocolsByName objectForKey:protocol.nameOfProtocol];
	if (existingProtocol) {
		[existingProtocol mergeDataFromProtocol:protocol];
		return;
	}
	if ([_protocolsByName objectForKey:protocol.nameOfProtocol]) [NSException raise:@"Protocol with name %@ is already registered!", protocol.nameOfProtocol];
	[_protocols addObject:protocol];
	[_protocolsByName setObject:protocol forKey:protocol.nameOfProtocol];
}

- (void)mergeDataFromProtocolsProvider:(GBAdoptedProtocolsProvider *)source {
	if (!source || source == self) return;
	GBLogDebug(@"Merging data from %@...", source);
	for (GBProtocolData *sourceProtocol in source.protocols) {
		GBProtocolData *existingProtocol = [_protocolsByName objectForKey:sourceProtocol.nameOfProtocol];
		if (existingProtocol) {
			[existingProtocol mergeDataFromProtocol:sourceProtocol];
			continue;
		}
		[self registerProtocol:sourceProtocol];
	}
}

- (NSArray *)protocolsSortedByName {
	NSArray *descriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"protocolName" ascending:YES]];
	return [[self.protocols allObjects] sortedArrayUsingDescriptors:descriptors];
}

#pragma mark Properties

@synthesize protocols = _protocols;

@end
