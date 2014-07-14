//
//  GBAdoptedProtocolsProvider.m
//  appledoc
//
//  Created by Tomaz Kragelj on 26.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBProtocolData.h"
#import "GBAdoptedProtocolsProvider.h"

@implementation GBAdoptedProtocolsProvider

#pragma mark Initialization & disposal

- (id)initWithParentObject:(id)parent {
	NSParameterAssert(parent != nil);
	GBLogDebug(@"Initializing adopted protocols provider for %@...", parent);
	self = [super init];
	if (self) {
		_parent = parent;
		_protocols = [[NSMutableSet alloc] init];
		_protocolsByName = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (id)init {
	[NSException raise:@"Initializer 'init' is not valid, use 'initWithParentObject:' instead!"];
	return nil;
}

#pragma mark Helper methods

- (void)registerProtocol:(GBProtocolData *)protocol {
	NSParameterAssert(protocol != nil);
	GBLogDebug(@"%@: Registering protocol %@...", _parent, protocol);
	if ([_protocols containsObject:protocol]) return;
	GBProtocolData *existingProtocol = [_protocolsByName objectForKey:protocol.nameOfProtocol];
	if (existingProtocol) {
		[existingProtocol mergeDataFromObject:protocol];
		return;
	}
	if ([_protocolsByName objectForKey:protocol.nameOfProtocol]) 
		[NSException raise:@"Protocol with name %@ is already registered!", protocol.nameOfProtocol];
	[_protocols addObject:protocol];
	[_protocolsByName setObject:protocol forKey:protocol.nameOfProtocol];
}

- (void)mergeDataFromProtocolsProvider:(GBAdoptedProtocolsProvider *)source {
	if (!source || source == self) return;
	GBLogDebug(@"%@: Merging adopted protocols from %@...", _parent, source->_parent);
	for (GBProtocolData *sourceProtocol in source.protocols) {
		GBProtocolData *existingProtocol = [_protocolsByName objectForKey:sourceProtocol.nameOfProtocol];
		if (existingProtocol) {
			[existingProtocol mergeDataFromObject:sourceProtocol];
			continue;
		}
		[self registerProtocol:sourceProtocol];
	}
}

- (void)replaceProtocol:(GBProtocolData *)original withProtocol:(GBProtocolData *)protocol {
	NSParameterAssert(protocol != nil);
	NSParameterAssert([self.protocols containsObject:original]);
	[_protocols removeObject:original];
	[_protocols addObject:protocol];
}

- (NSArray *)protocolsSortedByName {
	NSArray *descriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"protocolName" ascending:YES]];
	return [[self.protocols allObjects] sortedArrayUsingDescriptors:descriptors];
}

#pragma mark Overriden methods

- (NSString *)description {
	return [_parent description];
}

- (NSString *)debugDescription {
	NSMutableString *result = [NSMutableString string];
	if ([self.protocols count] > 0) {
		[result appendString:@"<"];
		[[self protocolsSortedByName] enumerateObjectsUsingBlock:^(GBProtocolData *protocol, NSUInteger idx, BOOL *stop) {
			if (idx > 0) [result appendString:@", "];
			[result appendString:protocol.nameOfProtocol];
		}];
		[result appendString:@">"];
	}
	return result;
}

#pragma mark Properties

@synthesize protocols = _protocols;

@end
