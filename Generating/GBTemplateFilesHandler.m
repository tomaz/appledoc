//
//  GBTemplateFilesHandler.m
//  appledoc
//
//  Created by Tomaz Kragelj on 10.2.11.
//  Copyright 2011 Gentle Bytes. All rights reserved.
//

#import "GBTemplateHandler.h"
#import "GBTemplateFilesHandler.h"

@interface GBTemplateFilesHandler ()

- (BOOL)isPathRepresentingTemplateFile:(NSString *)path;
- (BOOL)isPathRepresentingIgnoredFile:(NSString *)path;
- (GBTemplateHandler *)templateHandlerFromTemplateFile:(NSString *)filename error:(NSError **)error;

@end

#pragma mark -

@implementation GBTemplateFilesHandler

#pragma mark Initialization & disposal

- (id)init {
	self = [super init];
	if (self) {
		self.templateFiles = [NSMutableDictionary dictionary];
	}
	return self;
}

#pragma mark Template files handling

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
	
	// Create directory hierarchy minus the last one. This is necessary if more than one component is missing at destination path; copyItemAtPath:toPath:error would fail in such case. Note that we can't create the last directory as mentioned method request is that the destination doesn't exist!
	NSString *createDestPath = [destPath stringByDeletingLastPathComponent];
	if (![self.fileManager createDirectoryAtPath:createDestPath withIntermediateDirectories:YES attributes:nil error:error]) {
		GBLogWarn(@"Failed creating directory '%@'!", createDestPath);
		return NO;
	}
	
	// If there's no source file, there also no need to copy anything, so exit. In fact, copying would probably just result in errors.
	if (![self.fileManager fileExistsAtPath:sourcePath]) {
		GBLogDebug(@"No template file found at '%@', no need to copy.", sourceUserPath);
		return YES;
	}
	
	// Copy the whole source directory over to output. Exit if we fail.
	GBLogDebug(@"Copying template files from '%@' to '%@'...", sourceUserPath, destUserPath);
	if (![self.fileManager copyItemAtPath:sourcePath toPath:destPath error:error]) {
		GBLogWarn(@"Failed copying templates from '%@' to '%@'!", sourceUserPath, destUserPath);
		return NO;
	}
	
	// Remove all ignored files and special template items from output. First enumerate all files. If this fails, report success; this step is only used to verscleanup the destination, we should still have valid output if these files are kept there. Note that we need to test for existing file before removing as it could happen file's parent dir was removed already in previous iterations so the file or subdir doesn't exist anymore - see https://github.com/tomaz/appledoc/issues#issue/59 for details.
	GBLogDebug(@"Removing temporary files from '%@'...", destUserPath);
	NSArray *items = [self.fileManager subpathsOfDirectoryAtPath:destPath error:error];
	if (!items) {
		GBLogWarn(@"Failed enumerating template files at '%@'!", destUserPath);
		return YES;
	}	
	for (NSString *path in items) {
		BOOL delete = NO;
		if ([self isPathRepresentingIgnoredFile:path]) {
			GBLogDebug(@"Removing ignored file '%@' from output...", path);
			delete = YES;
		} else if ([self isPathRepresentingTemplateFile:path]) {
			GBTemplateHandler *handler = [self templateHandlerFromTemplateFile:path error:error];
			if (!handler) return NO;
			GBLogDebug(@"Removing template file '%@' from output...", path);
			[self.templateFiles setObject:handler forKey:path];
			delete = YES;
		}
		
		if (delete) {
			NSString *fullpath = [destPath stringByAppendingPathComponent:path];
			if ([self.fileManager fileExistsAtPath:fullpath] && ![self.fileManager removeItemAtPath:fullpath error:error]) {
				GBLogWarn(@"Can't clean leftover '%@' from '%@'.", path, destUserPath);
			}
		}
	}
	
	return YES;
}

- (NSString *)templatePathForTemplateEndingWith:(NSString *)suffix {
	for (NSString *template in [self.templateFiles allKeys]) {
		if ([template hasSuffix:suffix]) return template;
	}
	return nil;
}

- (NSString *)outputPathToTemplateEndingWith:(NSString *)suffix {
	NSString *template = [self templatePathForTemplateEndingWith:suffix];
	if (template) {
		NSString *path = [template substringToIndex:[template length] - [suffix length]];
		return [self.outputUserPath stringByAppendingPathComponent:path];
	}
	return nil;
}

#pragma mark Helper methods

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

#pragma mark Properties

@synthesize templateFiles;
@synthesize templateUserPath;
@synthesize outputUserPath;

@end
