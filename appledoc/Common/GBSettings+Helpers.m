//
//  GBSettings+Helpers.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/19/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "DDCliUtil.h"
#import "Extensions.h"
#import "AppledocInfo.h"
#import "GBCommandLineParser.h"
#import "GBSettings+Appledoc.h"
#import "GBSettings+Helpers.h"

@interface GBSettings (HelpersPrivate)
- (BOOL)validateTemplatesAtPath:(NSString *)path error:(NSError **)error;
@property (nonatomic, readonly) NSString *globalSettingsFilename;
@property (nonatomic, readonly) NSString *projectSettingsFilename;
@end

#pragma mark -

#pragma mark -

@implementation GBSettings (Helpers)

- (void)applyFactoryDefaults {
	self.projectVersion = @"1.0";
	self.crossRefsFormat = @"plain";
	self.loggingFormat = 0;
	self.loggingCommonEnabled = YES;
	self.loggingStoreEnabled = NO;
	self.loggingParsingEnabled = NO;
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
		NSString *filename = [path gb_stringByStandardizingCurrentDirAndPath];
		if (![manager gb_fileExistsAndIsDirectoryAtPath:filename]) return;
		if ([manager gb_fileExistsAndIsDirectoryAtPath:filename]) {
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

- (void)consolidateSettings {
	// Add all input path cmd line switch values to arguments so we can handle them uniformly from here on (we need to support input switches so users can add paths from global and project settings).
	[self enumerateSettings:^(GBSettings *settings, BOOL *stop) {
		NSArray *inputPaths = [settings objectForLocalKey:GBOptions.inputPaths];
		[inputPaths enumerateObjectsUsingBlock:^(NSString *path, NSUInteger idx, BOOL *stop) {
			[settings addArgument:path];
		}];
	}];
}

- (BOOL)validateSettings {
	NSFileManager *manager = [NSFileManager defaultManager];
	__block BOOL result = YES;
	
	// Verify we have all required values.
	if (self.projectName.length == 0) {
		ddprintf(@"ERROR: Missing project name (--%@)!\n", GBOptions.projectName);
		result = NO;
	}
	if (self.companyName.length == 0) {
		ddprintf(@"ERROR: Missing company name (--%@)!\n", GBOptions.companyName);
		result = NO;
	}
	
	// We must have at least one valid path.
	__block BOOL atLeastOneValidPath = NO;
	[self.arguments enumerateObjectsUsingBlock:^(NSString *path, NSUInteger idx, BOOL *stop) {
		NSString *standardized = [path gb_stringByStandardizingCurrentDirAndPath];
		if (![manager fileExistsAtPath:standardized]) {
			ddprintf(@"WARN: Input path '%@' doesn't exist, ignoring!\n", path);
			return;
		}
		atLeastOneValidPath = YES;
	}];
	if (!atLeastOneValidPath) {
		ddprintf(@"ERROR: No");
		if (self.arguments.count > 0) ddprintf(@" valid");
		ddprintf(@" input path given, aborting!\n");
		result = NO;
	}
	
	// Add a new line and return validation result.
	ddprintf(@"\n");
	return result;
}

@end

#pragma mark - 

@implementation GBSettings (HelpersPrivate)

- (BOOL)validateTemplatesAtPath:(NSString *)path error:(NSError **)error {
	NSFileManager *manager = [NSFileManager defaultManager];
	NSString *standardized = [path gb_stringByStandardizingCurrentDirAndPath];
	
	// If path doesn't exist, exit.
	if (![manager fileExistsAtPath:standardized]) {
		if (*error) {
			NSString *description = [NSString gb_format:@"Template path doesn't exist at '%@'!", path];
			*error = [NSError gb_errorWithCode:GBErrorCodeTemplatePathNotFound description:description reason:nil];
		}
		return NO;
	}
	
	// If path isn't a directory, exit.
	if (![manager gb_fileExistsAndIsDirectoryAtPath:standardized]) {
		if (*error) {
			NSString *description = [NSString gb_format:@"Template path '%@' exists, but is not directory!", path];
			*error = [NSError gb_errorWithCode:GBErrorCodeTemplatePathNotDirectory description:description reason:nil];
		}
		return NO;
	}
	
	return YES;
}

- (NSString *)globalSettingsFilename {
	return @"GlobalSettings.plist";
}

- (NSString *)projectSettingsFilename {
	return @"AppledocSettings.plist";
}

@end
