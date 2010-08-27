//
//  GBProcessor.m
//  appledoc
//
//  Created by Tomaz Kragelj on 27.8.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBApplicationSettingsProviding.h"
#import "GBStoreProviding.h"
#import "GBProcessor.h"

@interface GBProcessor ()

@property (retain) id<GBApplicationSettingsProviding> settings;
@property (retain) id<GBStoreProviding> store;

@end

#pragma mark -

@implementation GBProcessor

#pragma mark Initialization & disposal

- (id)initWithSettingsProvider:(id<GBApplicationSettingsProviding>)settingsProvider {
	NSParameterAssert(settingsProvider != nil);
	GBLogDebug(@"Initializing processor with settings provider %@...", settingsProvider);
	self = [super init];
	if (self) {
		self.settings = settingsProvider;
	}
	return self;
}
#pragma mark Processing handling

- (void)processObjectsFromStore:(id<GBStoreProviding>)store {
	NSParameterAssert(store != nil);
	GBLogVerbose(@"Processing objects from %@...", store);
	self.store = store;
}

#pragma mark Properties

@synthesize settings;
@synthesize store;

@end
