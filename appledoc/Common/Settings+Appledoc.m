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
			NSString *filename = [[path stringByAppendingPathComponent:@"GlobalSettings.plist"] stringByStandardizingPath];
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
		NSString *filename = [[homePath stringByAppendingPathComponent:@"GlobalSettings.plist"] stringByStandardizingPath];
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
	return YES;
}

@end

#pragma mark - 

@implementation GBSettings (HelpersPrivate)

- (BOOL)validateTemplatesAtPath:(NSString *)path error:(NSError **)error {
	BOOL isDirectory = NO;
	NSFileManager *manager = [NSFileManager defaultManager];
	NSString *standardized = [path stringByStandardizingPath];
	
	// If path doesn't exist, exit.
	if (![manager fileExistsAtPath:standardized isDirectory:&isDirectory]) {
		if (*error) {
			NSString *description = [NSString stringWithFormat:@"Template path doesn't exist at '%@'!", path];
			*error = [NSError errorWithCode:GBTemplatePathNotFound description:description reason:nil];
		}
		return NO;
	}
	
	// If path isn't a directory, exit.
	if (!isDirectory) {
		if (*error) {
			NSString *description = [NSString stringWithFormat:@"Template path '%@' exists, but is not directory!", path];
			*error = [NSError errorWithCode:GBTemplatePathNotDirectory description:description reason:nil];
		}
		return NO;
	}
	
	return YES;
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