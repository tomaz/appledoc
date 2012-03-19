//
//  GBSettings+Appledoc.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/13/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//
#import "GBSettings+Appledoc.h"

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

GB_SYNTHESIZE_UINT(loggingFormat, setLoggingFormat, GBOptions.loggingFormat)
GB_SYNTHESIZE_UINT(loggingLevel, setLoggingLevel, GBOptions.loggingLevel)
GB_SYNTHESIZE_BOOL(loggingCommonEnabled, setLoggingCommonEnabled, GBOptions.loggingCommonEnabled)
GB_SYNTHESIZE_BOOL(loggingParsingEnabled, setLoggingParsingEnabled, GBOptions.loggingParsingEnabled)

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
	
	.loggingLevel = @"verbose",
	.loggingFormat = @"log-format",
	.loggingCommonEnabled = @"log-common",
	.loggingParsingEnabled = @"log-parsing",
};