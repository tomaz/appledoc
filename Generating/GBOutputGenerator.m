//
//  GBOutputGenerator.m
//  appledoc
//
//  Created by Tomaz Kragelj on 28.11.10.
//  Copyright 2010 Gentle Bytes. All rights reserved.
//

#import "GBStore.h"
#import "GBApplicationSettingsProvider.h"
#import "GBTemplateHandler.h"
#import "GBOutputGenerator.h"

@interface GBOutputGenerator ()

@property (readwrite, strong) GBStore *store;

@end

#pragma mark -

@implementation GBOutputGenerator

#pragma mark Initialization & disposal

+ (id)generatorWithSettingsProvider:(id)settingsProvider {
	return [[self alloc] initWithSettingsProvider:settingsProvider];
}

- (id)initWithSettingsProvider:(id)settingsProvider {
	NSParameterAssert(settingsProvider != nil);
	GBLogDebug(@"Initializing output generator with settings provider %@...", settingsProvider);
	self = [super init];
	if (self) {
		self.settings = settingsProvider;
	}
	return self;
}

#pragma mark Generation handling

- (BOOL)generateOutputWithStore:(id)aStore error:(NSError **)error {
	GBLogVerbose(@"%@ is generating output...", [self className]);
	self.store = aStore;
	return YES;
}

- (BOOL)initializeDirectoryAtPath:(NSString *)path error:(NSError **)error {
	return [self initializeDirectoryAtPath:path preserve:nil error:error];
}

- (BOOL)initializeDirectoryAtPath:(NSString *)path preserve:(NSArray *)preserve error:(NSError **)error {
	GBLogVerbose(@"Initializing directory at '%@'...", path);
	NSString *standardized = [path stringByStandardizingPath];
	
	// If no path is to be preserved, just use simple approach of removing path and recreating it later on... Otherwise delete all content except given one.
	BOOL exists = [self.fileManager fileExistsAtPath:standardized];
	if ([preserve count] == 0) {
		if (exists) {
			GBLogDebug(@"Removing existing directory...");
			if (![self.fileManager removeItemAtPath:standardized error:error]) return NO;
		}
	} else if (exists) {
		GBLogDebug(@"Enumerating directory contents...");
		NSArray *contents = [self.fileManager contentsOfDirectoryAtPath:standardized error:error];
		if (!contents && error && *error) return NO;
		for (NSString *subpath in contents) {
			if (![preserve containsObject:subpath]) {
				GBLogDebug(@"Removing '%@'...", subpath);
				if (![self.fileManager removeItemAtPath:[path stringByAppendingPathComponent:subpath] error:error]) return NO;
			}
		}
	}
	
	// Create the directory if it doesn't yet exist. Note that we rely on system to actually check if the directory exists, instead of the cached value from above. The cached value may change if we remove the directory. Although we could change the value too, it makes tool safer this way.
	if (![self.fileManager fileExistsAtPath:standardized]) {
		GBLogDebug(@"Creating directory...");
		return [self.fileManager createDirectoryAtPath:standardized withIntermediateDirectories:YES attributes:nil error:error];
	}
	return YES;
}

- (BOOL)copyOrMoveItemFromPath:(NSString *)source toPath:(NSString *)destination error:(NSError **)error {
	BOOL copy = self.settings.keepIntermediateFiles;
	GBLogDebug(@"%@ '%@' to '%@'...", copy ? @"Copying" : @"Moving", source, destination);
	
	NSString *standardSource = [source stringByStandardizingPath];
	NSString *standardDest = [destination stringByStandardizingPath];
	
	// We must first delete destination path if it exists. Otherwise copy or move will fail!
	if ([self.fileManager fileExistsAtPath:standardDest]) {
		GBLogDebug(@"Removing '%@'...", destination);
		if (![self.fileManager removeItemAtPath:standardDest error:error]) {
			GBLogWarn(@"Failed removing '%@'!", destination);
			return NO;
		}
	}
	
	// Now either copy or move.
	if (copy) return [self.fileManager copyItemAtPath:standardSource toPath:standardDest error:error];
	return [self.fileManager moveItemAtPath:standardSource toPath:standardDest error:error];
}

#pragma mark Helper methods

- (BOOL)writeString:(NSString *)string toFile:(NSString *)path error:(NSError **)error {
	NSString *standardized = [path stringByStandardizingPath];
	NSString *directory = [standardized stringByDeletingLastPathComponent];
	if (![self.fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:error]) {
		GBLogWarn(@"Failed creating directory while writing '%@'!", path);
		return NO;
	}
	
	if (![string writeToFile:standardized atomically:YES encoding:NSUTF8StringEncoding error:error]) {
		GBLogWarn(@"Failed writing '%@'!", path);
		return NO;
	}
	
	return YES;
}

#pragma mark Subclass helpers

- (NSString *)templateUserPath {
	// Overriden to simplify handling.
	return [self.settings.templatesPath stringByAppendingPathComponent:self.outputSubpath];
}

- (NSString *)outputUserPath {
	// Overriden to simplify handling.
	return [self.settings.outputPath stringByAppendingPathComponent:self.outputSubpath];
}

- (NSString *)inputUserPath {
	if (!self.previousGenerator) return nil;
	return self.previousGenerator.outputUserPath;
}

#pragma mark Generation parameters

- (NSString *)outputSubpath {
	return @"";
}

#pragma mark Properties

@synthesize previousGenerator;
@synthesize settings;
@synthesize store;

@end
