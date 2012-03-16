//
//  Settings+Appledoc.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/13/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//
#import "DDCliUtil.h"
#import "AppledocInfo.h"
#import "GBCommandLineParser.h"
#import "Settings+Appledoc.h"

@implementation GBSettings (Appledoc)

#pragma mark - Initialization & disposal

+ (id)appledocSettingsWithName:(NSString *)name parent:(GBSettings *)parent {
	id result = [self settingsWithName:name parent:parent];
	if (result) {
		[result registerArrayForKey:@"input"];
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

- (void)applyGlobalSettingsFromCmdLineSettings:(GBSettings *)settings {
}

- (void)applyProjectSettingsFromCmdLineSettings:(GBSettings *)settings {
}

@end

#pragma mark - 

const struct GBOptions GBOptions = {
	.projectVersion = @"project-version",
	.projectName = @"project-name",
	.companyName = @"company-name",
	.companyIdentifier = @"company-id",
	
	.inputPaths = @"input",
	
	.printSettings = @"print-settings",
	.printVersion = @"version",
	.printHelp = @"help",
};