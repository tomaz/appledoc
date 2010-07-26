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
	if ([_ivarsByName objectForKey:ivar.ivarName]) [NSException raise:@"Ivar with name %@ is already registered!", ivar.ivarName];
	[_ivars addObject:ivar];
	[_ivarsByName setObject:ivar forKey:ivar.ivarName];
}

#pragma mark Properties

@synthesize ivars = _ivars;

@end
