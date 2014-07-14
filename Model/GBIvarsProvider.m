//
//  GBIvarsProvider.m
//  appledoc
//
//  Created by Tomaz Kragelj on 26.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBIvarData.h"
#import "GBIvarsProvider.h"

@implementation GBIvarsProvider

#pragma mark Initialization & disposal

- (id)initWithParentObject:(id)parent {
	NSParameterAssert(parent != nil);
	GBLogDebug(@"Initializing ivars provider for %@...", parent);
	self = [super init];
	if (self) {
		_parent = parent;
		_ivars = [[NSMutableArray alloc] init];
		_ivarsByName = [[NSMutableDictionary alloc] init];
	}
	return self;
}

#pragma mark Helper methods

- (void)registerIvar:(GBIvarData *)ivar {
	NSParameterAssert(ivar != nil);
	GBLogDebug(@"%@: Registering ivar %@...", _parent, ivar);
	if ([_ivars containsObject:ivar]) return;
	GBIvarData *existingIvar = [_ivarsByName objectForKey:ivar.nameOfIvar];
	if (existingIvar) {
		[existingIvar mergeDataFromObject:ivar];
		return;
	}
	ivar.parentObject = _parent;
	[_ivars addObject:ivar];
	[_ivarsByName setObject:ivar forKey:ivar.nameOfIvar];
}

- (void)mergeDataFromIvarsProvider:(GBIvarsProvider *)source {
	if (!source || source == self) return;
	GBLogDebug(@"%@: Merging ivars from %@...", _parent, source->_parent);
	for (GBIvarData *sourceIvar in source.ivars) {
		GBIvarData *existingIvar = [_ivarsByName objectForKey:sourceIvar.nameOfIvar];
		if (existingIvar) {
			[existingIvar mergeDataFromObject:sourceIvar];
			continue;
		}
		[self registerIvar:sourceIvar];
	}
}

#pragma mark Overriden methods

- (NSString *)description {
	return [_parent description];
}

#pragma mark Properties

@synthesize ivars = _ivars;

@end
