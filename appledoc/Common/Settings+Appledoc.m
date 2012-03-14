//
//  Settings+Appledoc.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/13/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "CommandLineArgumentsParser.h"
#import "Settings+Appledoc.h"

@implementation Settings (Appledoc)

#pragma mark - Initialization & disposal

+ (id)appledocSettingsWithName:(NSString *)name parent:(Settings *)parent {
	id result = [self settingsWithName:name parent:parent];
	if (result) {
		[result registerArrayForKey:GBSettingsKeys.inputPaths];
	}
	return result;
}

#pragma mark - Helper methods

- (void)applyFactoryDefaults {
	self.projectVersion = @"1.0";
}

- (void)applyGlobalSettingsFromCmdLineSettings:(Settings *)settings {
}

- (void)applyProjectSettingsFromCmdLineSettings:(Settings *)settings {
}

- (void)registerOptionsToCommandLineParser:(CommandLineArgumentsParser *)parser {
	[parser registerOption:GBSettingsKeys.projectName shortcut:'p' requirement:GBCommandLineValueRequired];
	[parser registerOption:GBSettingsKeys.projectVersion shortcut:'v' requirement:GBCommandLineValueRequired];
	[parser registerOption:GBSettingsKeys.companyName shortcut:'c' requirement:GBCommandLineValueRequired];
	[parser registerOption:GBSettingsKeys.companyIdentifier requirement:GBCommandLineValueRequired];
}

#pragma mark - Project information

GB_SYNTHESIZE_COPY(NSString *, projectVersion, setProjectVersion)
GB_SYNTHESIZE_COPY(NSString *, projectName, setProjectName) // Required!
GB_SYNTHESIZE_COPY(NSString *, companyName, setCompanyName) // Required!
GB_SYNTHESIZE_COPY(NSString *, companyIdentifier, setCompanyIdentifier) // Required!

#pragma mark - Paths

GB_SYNTHESIZE_OBJECT(NSArray *, inputPaths, setInputPaths)

@end

#pragma mark - Settings keys

const struct GBSettingsKeys GBSettingsKeys = {
	.projectName = @"project-name",
	.projectVersion = @"project-version",
	.companyName = @"company-name",
	.companyIdentifier = @"company-id",
	
	.inputPaths = @"input",
};