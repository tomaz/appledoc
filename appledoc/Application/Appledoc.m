//
//  Appledoc.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/12/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "Store.h"
#import "Appledoc.h"

@implementation Appledoc

@synthesize store = _store;

#pragma mark - Initialization & disposal

- (id)init {
	self = [super init];
	return self;
}

#pragma mark - Running

- (void)runWithSettings:(GBSettings *)settings {
	LogNormal(@"Starting appledoc...");
	LogNormal(@"Appledoc is finished.");
}

#pragma mark - Properties

- (Store *)store {
	if (_store) return _store;
	LogDebug(@"Initializing store due to first access...");
	_store = [[Store alloc] init];
	return _store;
}

@end
