//
//  GBStore.m
//  appledoc
//
//  Created by Tomaz Kragelj on 25.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBStore.h"

@implementation GBStore

#pragma mark Initialization & disposal

- (id)init {
	self = [super init];
	if (self) {
		_classes = [[NSMutableSet alloc] init];
		_classesByName = [[NSMutableDictionary alloc] init];
	}
	return self;
}

#pragma mark Helper methods

- (NSArray *)classesSortedByName {
	NSArray *descriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"className" ascending:YES]];
	return [[self.classes allObjects] sortedArrayUsingDescriptors:descriptors];
}

#pragma mark GBStoreProviding implementation

- (void)registerClass:(GBClassData *)class {
	NSParameterAssert(class != nil);
	GBLogDebug(@"Registering class %@...", class);
	if ([_classes containsObject:class]) return;
	if ([_classesByName objectForKey:class.className]) [NSException raise:@"Class with name %@ is already registered!", class.className];
	[_classes addObject:class];
	[_classesByName setObject:class forKey:class.className];
}

@synthesize classes = _classes;

@end
