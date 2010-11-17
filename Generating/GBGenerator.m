//
//  GBGenerator.m
//  appledoc
//
//  Created by Tomaz Kragelj on 29.9.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBApplicationSettingsProviding.h"
#import "GBStoreProviding.h"
#import "GBDataObjects.h"
#import "GBTemplateVariablesProvider.h"
#import "GBGenerator.h"

@interface GBGenerator ()

- (void)processClasses;
- (void)processCategories;
- (void)processProtocols;
- (void)writeString:(NSString *)string toFile:(NSString *)path;
@property (readonly) GBTemplateVariablesProvider *variablesProvider;
@property (retain) id<GBApplicationSettingsProviding> settings;
@property (retain) id<GBStoreProviding> store;

@end

#pragma mark -

@implementation GBGenerator

#pragma mark Initialization & disposal

+ (id)generatorWithSettingsProvider:(id)settingsProvider {
	return [[[self alloc] initWithSettingsProvider:settingsProvider] autorelease];
}

- (id)initWithSettingsProvider:(id)settingsProvider {
	NSParameterAssert(settingsProvider != nil);
	NSParameterAssert([settingsProvider conformsToProtocol:@protocol(GBApplicationSettingsProviding)]);
	GBLogDebug(@"Initializing generator with settings provider %@...", settingsProvider);
	self = [super init];
	if (self) {
		self.settings = settingsProvider;
	}
	return self;
}

#pragma mark Generation handling

- (void)generateOutputFromStore:(id<GBStoreProviding>)store {
	NSParameterAssert(store != nil);
	GBLogVerbose(@"Generating output from parsed objects...");	
	self.store = store;
	[self processClasses];
	[self processCategories];
	[self processProtocols];
}

- (void)processClasses {
	for (GBClassData *class in self.store.classes) {
		GBLogInfo(@"Generating output for class %@...", class);
//		NSDictionary *vars = [self.variablesProvider variablesForClass:class withStore:self.store];
//		NSString *output = [self.templateWriter outputStringWithReader:self.objectTemplateReader variables:vars];
//		NSString *path = [self.settings htmlOutputPathForObject:class];
//		[self writeString:output toFile:path];
		GBLogDebug(@"Finished generating output for class %@.", class);
	}
}

- (void)processCategories {
	for (GBCategoryData *category in self.store.categories) {
		GBLogInfo(@"Generating output for category %@...", category);
//		NSDictionary *vars = [self.variablesProvider variablesForCategory:category withStore:self.store];
//		NSString *output = [self.templateWriter outputStringWithReader:self.objectTemplateReader variables:vars];
//		NSString *path = [self.settings htmlOutputPathForObject:category];
//		[self writeString:output toFile:path];
		GBLogDebug(@"Finished generating output for category %@.", category);
	}
}

- (void)processProtocols {
	for (GBProtocolData *protocol in self.store.protocols) {
		GBLogInfo(@"Generating output for protocol %@...", protocol);
//		NSDictionary *vars = [self.variablesProvider variablesForProtocol:protocol withStore:self.store];
//		NSString *output = [self.templateWriter outputStringWithReader:self.objectTemplateReader variables:vars];
//		NSString *path = [self.settings htmlOutputPathForObject:protocol];
//		[self writeString:output toFile:path];
		GBLogDebug(@"Finished generating output for protocol %@.", protocol);
	}
}

#pragma mark Template files handling

- (GBTemplateVariablesProvider *)variablesProvider {
	static GBTemplateVariablesProvider *result = nil;
	if (!result) result = [[GBTemplateVariablesProvider alloc] initWithSettingsProvider:self.settings];
	return result;
}

#pragma mark Helper methods

- (void)writeString:(NSString *)string toFile:(NSString *)path {
	// Writes the given string to the given path, creating all folders if they don't exist.
	NSError *error = nil;
	
	NSString *standardized = [path stringByStandardizingPath];
	NSString *directory = [standardized stringByDeletingLastPathComponent];
	[self.fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&error];
	if (error) {
		GBLogNSError(error, @"Failed creating directory while writting %@!", path);
		return;
	}
	
	[string writeToFile:standardized atomically:YES encoding:NSUTF8StringEncoding error:&error];
	if (error) GBLogNSError(error, @"Failed writing %@!", path);
}

#pragma mark Properties

@synthesize settings;
@synthesize store;

@end
