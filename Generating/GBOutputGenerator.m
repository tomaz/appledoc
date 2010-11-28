//
//  GBOutputGenerator.m
//  appledoc
//
//  Created by Tomaz Kragelj on 28.11.10.
//  Copyright 2010 Gentle Bytes. All rights reserved.
//

#import "GBOutputGenerator.h"

@interface GBOutputGenerator ()

- (BOOL)isPathRepresentingTemplateFile:(NSString *)path;
- (BOOL)isPathRepresentingIgnoredFile:(NSString *)path;

@end

#pragma mark -

@implementation GBOutputGenerator

#pragma mark Initialization & disposal

- (id)init {
    if ((self = [super init])) {
    }    
    return self;
}

#pragma mark Templates handling

- (BOOL)copyTemplateFilesFromPath:(NSString *)sourcePath toPath:(NSString *)destPath {
	GBLogVerbose(@"Copying template files from '%@' to '%@'...", sourcePath, destPath);	
	NSError *error = nil;

	// Prepare source and destination paths.
	NSString *sourceUserPath = [sourcePath stringByAppendingPathComponent:self.outputSubpath];
	NSString *destUserPath = [destPath stringByAppendingPathComponent:self.outputSubpath];
	sourcePath = [sourceUserPath stringByStandardizingPath];
	destPath = [destUserPath stringByStandardizingPath];
	
	// Remove destination path if it exists. Exit if we fail.
	if ([self.fileManager fileExistsAtPath:destPath]) {
		GBLogDebug(@"Removing output at '%@'...", destUserPath);
		if (![self.fileManager removeItemAtPath:destPath error:&error]) {
			GBLogNSError(error, @"Failed deleting output path '%@'!", destUserPath);
			return NO;
		}
	}
	
	// Copy the whole source directory over to output. Exit if we fail.
	GBLogDebug(@"Copying template files from '%@' to '%@'...", sourceUserPath, destUserPath);
	if (![self.fileManager copyItemAtPath:sourcePath toPath:destPath error:&error]) {
		GBLogNSError(error, @"Failed copying templates from '%@' to '%@'!", sourceUserPath, destUserPath);
		return NO;
	}
	
	// Remove all ignored files and special template items from output. First enumerate all files. If this fails, report success; this step is only used to verscleanup the destination, we should still have valid output if these files are kept there.
	GBLogDebug(@"Removing leftovers from '%@'...", destUserPath);
	NSArray *items = [self.fileManager subpathsOfDirectoryAtPath:destPath error:&error];
	if (error) {
		GBLogNSError(error, @"Failed enumerating template files at '%@'!", destUserPath);
		return YES;
	}
	
	BOOL result = YES;
	for (NSString *path in items) {
		if (![self isPathRepresentingIgnoredFile:path] && ![self isPathRepresentingTemplateFile:path]) continue;
		GBLogDebug(@"Cleaning leftover '%@' from output...", path);
		NSString *fullpath = [destPath stringByAppendingPathComponent:path];
		if (![self.fileManager removeItemAtPath:fullpath error:&error]) {
			GBLogNSError(error, @"Can't clean lefover '%@' from '%@'.", path, destUserPath);
		}
	}
	
	return result;
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

- (NSString *)outputSubpath {
	return @"";
}

@end
