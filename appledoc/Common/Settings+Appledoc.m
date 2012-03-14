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

#pragma mark - Project values

GB_SYNTHESIZE_COPY(NSString *, projectVersion, setProjectVersion)
GB_SYNTHESIZE_COPY(NSString *, projectName, setProjectName) // Required!
GB_SYNTHESIZE_COPY(NSString *, companyName, setCompanyName) // Required!
GB_SYNTHESIZE_COPY(NSString *, companyIdentifier, setCompanyIdentifier) // Required!

#pragma mark - Helper methods

- (void)applyFactoryDefaults {
	self.projectVersion = @"1.0";
}

- (void)registerOptionsToCommandLineParser:(CommandLineArgumentsParser *)parser {
	[parser registerOption:GBSettingsKeys.projectName shortcut:'p' requirement:GBCommandLineValueRequired];
	[parser registerOption:GBSettingsKeys.projectVersion shortcut:'v' requirement:GBCommandLineValueRequired];
	[parser registerOption:GBSettingsKeys.companyName shortcut:'c' requirement:GBCommandLineValueRequired];
	[parser registerOption:GBSettingsKeys.companyIdentifier requirement:GBCommandLineValueRequired];
}

@end

#pragma mark - Settings keys

const struct GBSettingsKeys GBSettingsKeys = {
	.projectName = @"project-name",
	.projectVersion = @"project-version",
	.companyName = @"company-name",
	.companyIdentifier = @"company-id",
};