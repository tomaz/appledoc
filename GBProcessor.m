//
//  GBProcessor.m
//  appledoc
//
//  Created by Tomaz Kragelj on 27.8.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBApplicationSettingsProviding.h"
#import "GBStoreProviding.h"
#import "GBDataObjects.h"
#import "GBCommentsProcessor.h"
#import "GBProcessor.h"

@interface GBProcessor ()

- (void)processClasses;
- (void)processCategories;
- (void)processProtocols;
- (void)processDataProvider:(id<GBObjectDataProviding>)provider withComment:(GBComment *)comment;
- (void)processAdoptedProtocolsFromProvider:(GBAdoptedProtocolsProvider *)provider;
- (void)processMethodsFromProvider:(GBMethodsProvider *)provider;
- (void)processComment:(GBComment *)comment;
@property (retain) GBCommentsProcessor *commentsProcessor;
@property (retain) id<GBObjectDataProviding> currentContext;
@property (retain) id<GBApplicationSettingsProviding> settings;
@property (retain) id<GBStoreProviding> store;

@end

#pragma mark -

@implementation GBProcessor

#pragma mark Initialization & disposal

+ (id)processorWithSettingsProvider:(id)settingsProvider {
	return [[self alloc] initWithSettingsProvider:settingsProvider];
}

- (id)initWithSettingsProvider:(id)settingsProvider {
	NSParameterAssert(settingsProvider != nil);
	NSParameterAssert([settingsProvider conformsToProtocol:@protocol(GBApplicationSettingsProviding)]);
	GBLogDebug(@"Initializing processor with settings provider %@...", settingsProvider);
	self = [super init];
	if (self) {
		self.settings = settingsProvider;
		self.commentsProcessor = [GBCommentsProcessor processorWithSettingsProvider:self.settings];
	}
	return self;
}

#pragma mark Processing handling

- (void)processObjectsFromStore:(id<GBStoreProviding>)store {
	NSParameterAssert(store != nil);
	GBLogVerbose(@"Processing objects from %@...", store);
	self.currentContext = nil;
	self.store = store;
	[self processClasses];
	[self processCategories];
	[self processProtocols];
}

- (void)processClasses {
	// No need to process ivars as they are not used for output.
	for (GBClassData *class in self.store.classes) {
		GBLogInfo(@"Processing class %@...", class);
		[self processDataProvider:class withComment:class.comment];
	}
}

- (void)processCategories {
	for (GBCategoryData *category in self.store.categories) {
		GBLogInfo(@"Processing category %@...", category);
		[self processDataProvider:category withComment:category.comment];
	}
}

- (void)processProtocols {
	for (GBProtocolData *protocol in self.store.protocols) {
		GBLogInfo(@"Processing protocol %@...", protocol);
		[self processDataProvider:protocol withComment:protocol.comment];
	}
}

#pragma mark Common data processing

- (void)processDataProvider:(id<GBObjectDataProviding>)provider withComment:(GBComment *)comment {
	// Set current context then process all data. Note that processing order is only important for nicer logging messages.
	self.currentContext = provider;
	[self processAdoptedProtocolsFromProvider:provider.adoptedProtocols];
	[self processComment:comment];
	[self processMethodsFromProvider:provider.methods];
	self.currentContext = nil;
}

- (void)processAdoptedProtocolsFromProvider:(GBAdoptedProtocolsProvider *)provider {
	// This replaces known adopted protocols with real ones from the assigned store.
	NSArray *registeredProtocols = [self.store.protocols allObjects];
	for (GBProtocolData *adopted in [provider.protocols allObjects]) {
		for (GBProtocolData *registered in registeredProtocols) {
			if ([registered.nameOfProtocol isEqualToString:adopted.nameOfProtocol]) {
				GBLogDebug(@"Replacing adopted protocol %@ with data from store...", registered);
				[provider replaceProtocol:adopted withProtocol:registered];
				break;
			}
		}
	}
}

- (void)processMethodsFromProvider:(GBMethodsProvider *)provider {
	for (GBMethodData *method in provider.methods) {
		GBLogVerbose(@"Processing method %@...", method);
		[self processComment:method.comment];
	}
}

#pragma mark Comments processing

- (void)processComment:(GBComment *)comment {
	if (!comment) return;
	GBLogDebug(@"Processing comment...");
	[self.commentsProcessor processComment:comment withContext:self.currentContext store:self.store];
}

#pragma mark Properties

@synthesize commentsProcessor;
@synthesize currentContext;
@synthesize settings;
@synthesize store;

@end
