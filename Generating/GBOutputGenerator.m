//
//  GBOutputGenerator.m
//  appledoc
//
//  Created by Tomaz Kragelj on 28.11.10.
//  Copyright 2010 Gentle Bytes. All rights reserved.
//

#import "GBApplicationSettingsProviding.h"
#import "GBTemplateHandler.h"
#import "GBOutputGenerator.h"

@interface GBOutputGenerator ()

- (GBTemplateHandler *)templateHandlerFromTemplateFile:(NSString *)filename error:(NSError **)error;
- (BOOL)isPathRepresentingTemplateFile:(NSString *)path;
- (BOOL)isPathRepresentingIgnoredFile:(NSString *)path;
@property (readwrite, retain) id<GBStoreProviding> store;

@end

#pragma mark -

@implementation GBOutputGenerator

#pragma mark Initialization & disposal

+ (id)generatorWithSettingsProvider:(id)settingsProvider {
	return [[[self alloc] initWithSettingsProvider:settingsProvider] autorelease];
}

- (id)initWithSettingsProvider:(id)settingsProvider {
	NSParameterAssert(settingsProvider != nil);
	NSParameterAssert([settingsProvider conformsToProtocol:@protocol(GBApplicationSettingsProviding)]);
	GBLogDebug(@"Initializing output generator with settings provider %@...", settingsProvider);
	self = [super init];
	if (self) {
		self.settings = settingsProvider;
	}
	return self;
}

#pragma mark Generation handling

- (BOOL)generateOutputWithStore:(id<GBStoreProviding>)store error:(NSError **)error {
	GBLogVerbose(@"%@ is generating output...", [self className]);
	self.store = store;
	return YES;
}

- (BOOL)copyTemplateFilesToOutputPath:(NSError **)error {
	// Remove all previous template files.
	[self.templateFiles removeAllObjects];
	
	// Prepare source and destination paths.
	NSString *sourceUserPath = self.templateUserPath;
	NSString *destUserPath = self.outputUserPath;
	NSString *sourcePath = [sourceUserPath stringByStandardizingPath];
	NSString *destPath = [destUserPath stringByStandardizingPath];
	GBLogVerbose(@"Copying template files from '%@' to '%@'...", sourceUserPath, destUserPath);	
	
	// Remove destination path if it exists. Exit if we fail.
	if ([self.fileManager fileExistsAtPath:destPath]) {
		GBLogDebug(@"Removing output at '%@'...", destUserPath);
		if (![self.fileManager removeItemAtPath:destPath error:error]) {
			GBLogWarn(@"Failed removing output files at '%@'!", destUserPath);
			return NO;	
		}
	}
	
	// Copy the whole source directory over to output. Exit if we fail.
	GBLogDebug(@"Copying template files from '%@' to '%@'...", sourceUserPath, destUserPath);
	if (![self.fileManager copyItemAtPath:sourcePath toPath:destPath error:error]) {
		GBLogWarn(@"Failed copying templates from '%@' to '%@'!", sourceUserPath, destUserPath);
		return NO;
	}
	
	// Remove all ignored files and special template items from output. First enumerate all files. If this fails, report success; this step is only used to verscleanup the destination, we should still have valid output if these files are kept there.
	GBLogDebug(@"Removing leftovers from '%@'...", destUserPath);
	NSArray *items = [self.fileManager subpathsOfDirectoryAtPath:destPath error:error];
	if (!items) {
		GBLogWarn(@"Failed enumerating template files at '%@'!", destUserPath);
		return YES;
	}	
	for (NSString *path in items) {
		BOOL delete = NO;
		if ([self isPathRepresentingIgnoredFile:path]) {
			delete = YES;
		} else if ([self isPathRepresentingTemplateFile:path]) {
			GBTemplateHandler *handler = [self templateHandlerFromTemplateFile:path error:error];
			if (!handler) return NO;
			[self.templateFiles setObject:handler forKey:path];
			delete = YES;
		}
		
		if (delete) {
			GBLogDebug(@"Cleaning leftover '%@' from output...", path);
			NSString *fullpath = [destPath stringByAppendingPathComponent:path];
			if (![self.fileManager removeItemAtPath:fullpath error:error]) {
				GBLogWarn(@"Can't clean leftover '%@' from '%@'.", path, destUserPath);
			}
		}
	}
	
	return YES;
}

- (BOOL)isPathRepresentingTemplateFile:(NSString *)path {
	NSString *filename = [[path lastPathComponent] stringByDeletingPathExtension];
	if ([filename hasSuffix:@"-template"]) return YES;
	return NO;
}

- (BOOL)isPathRepresentingIgnoredFile:(NSString *)path {
	NSString *filename = [path lastPathComponent];
	if ([filename hasPrefix:@"."]) return YES;
	return NO;
}

#pragma mark Helper methods

- (BOOL)writeString:(NSString *)string toFile:(NSString *)path error:(NSError **)error {
	NSString *standardized = [path stringByStandardizingPath];
	NSString *directory = [standardized stringByDeletingLastPathComponent];
	if (![self.fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:error]) {
		GBLogWarn(@"Failed creating directory while writting '%@'!", path);
		return NO;
	}
	
	if (![string writeToFile:standardized atomically:YES encoding:NSUTF8StringEncoding error:error]) {
		GBLogWarn(@"Failed writting '%@'!", path);
		return NO;
	}
	
	return YES;
}

- (GBTemplateHandler *)templateHandlerFromTemplateFile:(NSString *)filename error:(NSError **)error {
	NSString *path = [[self templateUserPath] stringByAppendingPathComponent:filename];
	GBLogDebug(@"Creating template handler for template file '%@'...", path);
	GBTemplateHandler *result = [GBTemplateHandler handler];
	if (![result parseTemplateFromPath:[path stringByStandardizingPath] error:error]) {
		GBLogWarn(@"Failed parsing template '%@'!", filename);
		return nil;
	}
	return result;
}

#pragma mark Subclass helpers

- (NSString *)templateUserPath {
	return [self.settings.templatesPath stringByAppendingPathComponent:self.outputSubpath];
}

- (NSString *)outputUserPath {
	return [self.settings.outputPath stringByAppendingPathComponent:self.outputSubpath];
}

- (NSMutableDictionary *)templateFiles {
	static NSMutableDictionary *result = nil;
	if (!result) result = [[NSMutableDictionary alloc] init];
	return result;
}

#pragma mark Generation parameters

- (NSString *)outputSubpath {
	return @"";
}

#pragma mark Properties

@synthesize settings;

@end
