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
		_categories = [[NSMutableSet alloc] init];
		_categoriesByName = [[NSMutableDictionary alloc] init];
		_protocols = [[NSMutableSet alloc] init];
		_protocolsByName = [[NSMutableDictionary alloc] init];
	}
	return self;
}

#pragma mark Helper methods

- (NSArray *)classesSortedByName {
	NSArray *descriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"className" ascending:YES]];
	return [[self.classes allObjects] sortedArrayUsingDescriptors:descriptors];
}

- (NSArray *)categoriesSortedByName {
	NSSortDescriptor *classNameDescription = [NSSortDescriptor sortDescriptorWithKey:@"className" ascending:YES];
	NSSortDescriptor *categoryNameDescription = [NSSortDescriptor sortDescriptorWithKey:@"categoryName" ascending:YES];
	NSArray *descriptors = [NSArray arrayWithObjects:classNameDescription, categoryNameDescription, nil];
	return [[self.categories allObjects] sortedArrayUsingDescriptors:descriptors];
}

- (NSArray *)protocolsSortedByName {
	NSArray *descriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"protocolName" ascending:YES]];
	return [[self.protocols allObjects] sortedArrayUsingDescriptors:descriptors];
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

- (void)registerCategory:(GBCategoryData *)category {
	NSParameterAssert(category != nil);
	GBLogDebug(@"Registering category %@...", category);
	NSString *categoryID = [NSString stringWithFormat:@"%@(%@)", category.className, category.categoryName];
	if ([_categories containsObject:category]) return;
	if ([_categoriesByName objectForKey:categoryID]) [NSException raise:@"Category with ID %@ is already registered!", categoryID];
	[_categories addObject:category];
	[_categoriesByName setObject:category forKey:categoryID];
}

- (void)registerProtocol:(GBProtocolData *)protocol {
	NSParameterAssert(protocol != nil);
	GBLogDebug(@"Registering class %@...", protocol);
	if ([_protocols containsObject:protocol]) return;
	if ([_protocolsByName objectForKey:protocol.protocolName]) [NSException raise:@"Protocol with name %@ is already registered!", protocol.protocolName];
	[_protocols addObject:protocol];
	[_protocolsByName setObject:protocol forKey:protocol.protocolName];
}

@synthesize classes = _classes;
@synthesize categories = _categories;
@synthesize protocols = _protocols;

@end
