//
//  GBIvarsProvider.m
//  appledoc
//
//  Created by Tomaz Kragelj on 26.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBIvarsProvider.h"

@implementation GBIvarsProvider

#pragma mark Initialization & disposal

- (id)init {
	self = [super init];
	if (self) {
		_ivars = [[NSMutableArray alloc] init];
		_ivarsByName = [[NSMutableDictionary alloc] init];
	}
	return self;
}

#pragma mark Helper methods

- (void)registerIvar:(GBIvarData *)ivar {
	NSParameterAssert(ivar != nil);
	GBLogDebug(@"Registering ivar %@...", ivar);
	if ([_ivars containsObject:ivar]) return;
	GBIvarData *existingIvar = [_ivarsByName objectForKey:ivar.nameOfIvar];
	if (existingIvar) {
		[existingIvar mergeDataFromObject:ivar];
		return;
	}
	[_ivars addObject:ivar];
	[_ivarsByName setObject:ivar forKey:ivar.nameOfIvar];
}

- (void)mergeDataFromIvarsProvider:(GBIvarsProvider *)source {
	if (!source || source == self) return;
	GBLogDebug(@"Merging data from %@...", source);
	for (GBIvarData *sourceIvar in source.ivars) {
		GBIvarData *existingIvar = [_ivarsByName objectForKey:sourceIvar.nameOfIvar];
		if (existingIvar) {
			[existingIvar mergeDataFromObject:sourceIvar];
			continue;
		}
		[self registerIvar:sourceIvar];
	}
}

#pragma mark Properties

@synthesize ivars = _ivars;

@end
