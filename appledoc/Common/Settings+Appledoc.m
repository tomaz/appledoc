//
//  Settings+Appledoc.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/13/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//
#import "DDCliUtil.h"
#import "Extensions.h"
#import "AppledocInfo.h"
#import "GBCommandLineParser.h"
#import "Settings+Appledoc.h"

@interface GBSettings (HelpersPrivate)
- (BOOL)validateTemplatesAtPath:(NSString *)path error:(NSError **)error;
- (NSString *)standardizeCurrentDirectoryForPath:(NSString *)path;
@property (nonatomic, readonly) NSString *globalSettingsFilename;
@property (nonatomic, readonly) NSString *projectSettingsFilename;
@end

#pragma mark -

@implementation GBSettings (Appledoc)

#pragma mark - Initialization & disposal

+ (id)appledocSettingsWithName:(NSString *)name parent:(GBSettings *)parent {
	id result = [self settingsWithName:name parent:parent];
	if (result) {
		[result registerArrayForKey:GBOptions.inputPaths];
	}
	return result;
}

#pragma mark - Project information

GB_SYNTHESIZE_COPY(NSString *, projectVersion, setProjectVersion, GBOptions.projectVersion)
GB_SYNTHESIZE_COPY(NSString *, projectName, setProjectName, GBOptions.projectName) // Required!
GB_SYNTHESIZE_COPY(NSString *, companyName, setCompanyName, GBOptions.companyName) // Required!
GB_SYNTHESIZE_COPY(NSString *, companyIdentifier, setCompanyIdentifier, GBOptions.companyIdentifier) // Required!

#pragma mark - Paths

GB_SYNTHESIZE_OBJECT(NSArray *, inputPaths, setInputPaths, GBOptions.inputPaths)
GB_SYNTHESIZE_COPY(NSString *, templatesPath, setTemplatesPath, GBOptions.templatesPath)

#pragma mark - Debugging aid

GB_SYNTHESIZE_BOOL(printSettings, setPrintSettings, GBOptions.printSettings)
GB_SYNTHESIZE_BOOL(printVersion, setPrintVersion, GBOptions.printVersion)
GB_SYNTHESIZE_BOOL(printHelp, setPrintHelp, GBOptions.printHelp)

@end

#pragma mark -

@implementation GBSettings (Helpers)

- (void)applyFactoryDefaults {
	self.projectVersion = @"1.0";
}

- (BOOL)applyGlobalSettingsFromCmdLineSettings:(GBSettings *)settings {
	__block NSError *error = nil;

	// First try the templates path from command line, if given.
	NSString *pathFromCmdLine = settings.templatesPath;
	if (pathFromCmdLine.length > 0) {
		if ([self validateTemplatesAtPath:pathFromCmdLine error:&error]) {
			return YES;
		}
	}
	
	// Second try applicaton support directory. Note that we assign path to factory defaults...
	__block BOOL found = NO;
	NSArray *appSupportPaths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, NO);
	[appSupportPaths enumerateObjectsUsingBlock:^(NSString *appSupportPath, NSUInteger idx, BOOL *stop) {
		NSString *path = [appSupportPath stringByAppendingPathComponent:@"appledoc"];
		if ([self validateTemplatesAtPath:path error:&error]) {
			NSString *filename = [[path stringByAppendingPathComponent:self.globalSettingsFilename] stringByStandardizingPath];
			if ([self loadSettingsFromPlist:filename error:&error]) {			
				self.parent.templatesPath = path;
				found = YES;
				*stop = YES;
			}
		}
	}];
	if (found) return YES;
	
	// Lastly try ~/.appledoc directory. Note that we assign path to factory defaults...
	NSString *homePath = @"~/.appledoc";
	if ([self validateTemplatesAtPath:homePath error:&error]) {
		NSString *filename = [[homePath stringByAppendingPathComponent:self.globalSettingsFilename] stringByStandardizingPath];
		if ([self loadSettingsFromPlist:filename error:&error]) {
			self.parent.templatesPath = homePath;
			return YES;
		}
	}
	
	// If there was an error with any of the attempts show it now! If no error was detected, exit due to not finding global templates!
	if (error) {
		ddprintf(@"Applying global templates failed:\n");
		if (error.localizedDescription) ddprintf(@"Error: %@\n", error.localizedDescription);
		if (error.localizedFailureReason) ddprintf(@"Reason: %@\n", error.localizedFailureReason);
	} else {
		ddprintf(@"No predefined templates path exists and no template path specified from command line!\n");
	}
	return NO;
}

- (BOOL)applyProjectSettingsFromCmdLineSettings:(GBSettings *)settings {
	// We don't do recursive search - just check all arguments. Do it reverse, so that the last one wins in case settings file is included in more than a single path. If any path is a directory, see if it contains project settings file in it. Otherwise, if the file is project settings, just use it. Note that we always return YES, even if file not found - we may still have enough data on the cmd line to continue.
	NSFileManager *manager = [NSFileManager defaultManager];
	[settings.arguments enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSString *path, NSUInteger idx, BOOL *stop) {
		// Prepare the filename (if it's a dir, test for a project file inside. If not found, continue.
		NSString *filename = [[self standardizeCurrentDirectoryForPath:path] stringByStandardizingPath];
		if (![manager fileExistsAndIsDirectoryAtPath:filename]) return;
		if ([manager fileExistsAndIsDirectoryAtPath:filename]) {
			filename = [filename stringByAppendingPathComponent:self.projectSettingsFilename];
			if (![manager fileExistsAtPath:filename]) return;
		}
		
		// If filename doesn't match, continue. If it matches, but doesn't exist, warn and continue with next file.
		if (![filename hasSuffix:self.projectSettingsFilename]) return;
		if (![manager fileExistsAtPath:filename]) {
			ddprintf(@"Project file '%@' given on cmd line, but doesn't exist!", path);
			return;
		}
		
		// If filename matches, load settings from it. If that fails, log error and continue with next file.
		NSError *error = nil;
		if (![self loadSettingsFromPlist:filename error:&error]) {
			ddprintf(@"Loading project settings from %@ failed:\n", path);
			if (error.localizedDescription) ddprintf(@"Error: %@\n", error.localizedDescription);
			if (error.localizedFailureReason) ddprintf(@"Reason: %@\n", error.localizedFailureReason);
			return;
		}
		
		// So everything is fine, settings were loaded, exit...
		*stop = YES;
	}];
	return YES;
}

@end

#pragma mark - 

@implementation GBSettings (HelpersPrivate)

- (BOOL)validateTemplatesAtPath:(NSString *)path error:(NSError **)error {
	NSFileManager *manager = [NSFileManager defaultManager];
	NSString *standardized = [[self standardizeCurrentDirectoryForPath:path] stringByStandardizingPath];
	
	// If path doesn't exist, exit.
	if (![manager fileExistsAtPath:standardized]) {
		if (*error) {
			NSString *description = [NSString stringWithFormat:@"Template path doesn't exist at '%@'!", path];
			*error = [NSError errorWithCode:GBErrorCodeTemplatePathNotFound description:description reason:nil];
		}
		return NO;
	}
	
	// If path isn't a directory, exit.
	if (![manager fileExistsAndIsDirectoryAtPath:standardized]) {
		if (*error) {
			NSString *description = [NSString stringWithFormat:@"Template path '%@' exists, but is not directory!", path];
			*error = [NSError errorWithCode:GBErrorCodeTemplatePathNotDirectory description:description reason:nil];
		}
		return NO;
	}
	
	return YES;
}

- (NSString *)standardizeCurrentDirectoryForPath:(NSString *)path {
	// Converts . to actual working directory.
	if (![path hasPrefix:@"."] || [path hasPrefix:@".."]) return path;
	NSFileManager *manager = [NSFileManager defaultManager];
	NSString *suffix = [path substringFromIndex:1];
	NSString *currentDir = [manager currentDirectoryPath];
	return [currentDir stringByAppendingPathComponent:suffix];
}

- (NSString *)globalSettingsFilename {
	return @"GlobalSettings.plist";
}

- (NSString *)projectSettingsFilename {
	return @"AppledocSettings.plist";
}

@end

#pragma mark - 

const struct GBOptions GBOptions = {
	.projectVersion = @"project-version",
	.projectName = @"project-name",
	.companyName = @"project-company",
	.companyIdentifier = @"company-id",
	
	.inputPaths = @"input",
	.templatesPath = @"templates",
	
	.printSettings = @"print-settings",
	.printVersion = @"version",
	.printHelp = @"help",
};