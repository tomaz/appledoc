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
		[result registerArrayForKey:GBOptions.ignoredPaths];
		[result setLoggingLevel:0];
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
GB_SYNTHESIZE_OBJECT(NSArray *, ignoredPaths, setIgnoredPaths, GBOptions.ignoredPaths)
GB_SYNTHESIZE_COPY(NSString *, templatesPath, setTemplatesPath, GBOptions.templatesPath)

#pragma mark - Comments

GB_SYNTHESIZE_COPY(NSString *, crossRefsFormat, setCrossRefsFormat, GBOptions.crossRefsFormat)

#pragma mark - Debugging aid

GB_SYNTHESIZE_BOOL(printSettings, setPrintSettings, GBOptions.printSettings)
GB_SYNTHESIZE_BOOL(printVersion, setPrintVersion, GBOptions.printVersion)
GB_SYNTHESIZE_BOOL(printHelp, setPrintHelp, GBOptions.printHelp)

GB_SYNTHESIZE_UINT(loggingFormat, setLoggingFormat, GBOptions.loggingFormat)
GB_SYNTHESIZE_UINT(loggingLevel, setLoggingLevel, GBOptions.loggingLevel)
GB_SYNTHESIZE_BOOL(loggingInternalEnabled, setLoggingInternalEnabled, GBOptions.loggingInternalEnabled)
GB_SYNTHESIZE_BOOL(loggingCommonEnabled, setLoggingCommonEnabled, GBOptions.loggingCommonEnabled)
GB_SYNTHESIZE_BOOL(loggingStoreEnabled, setLoggingStoreEnabled, GBOptions.loggingStoreEnabled)
GB_SYNTHESIZE_BOOL(loggingParsingEnabled, setLoggingParsingEnabled, GBOptions.loggingParsingEnabled)
GB_SYNTHESIZE_BOOL(loggingProcessingEnabled, setLoggingProcessingEnabled, GBOptions.loggingProcessingEnabled)

@end

#pragma mark - 

const struct GBOptions GBOptions = {
	.projectVersion = @"project-version",
	.projectName = @"project-name",
	.companyName = @"project-company",
	.companyIdentifier = @"company-id",
	
	.inputPaths = @"input",
	.templatesPath = @"templates",
	.ignoredPaths = @"ignore",
	
	.crossRefsFormat = @"crossrefs",
	
	.printSettings = @"print-settings",
	.printVersion = @"version",
	.printHelp = @"help",
	
	.loggingLevel = @"verbose",
	.loggingFormat = @"log-format",
	.loggingInternalEnabled = @"log-internal",
	.loggingCommonEnabled = @"log-common",
	.loggingStoreEnabled = @"log-store",
	.loggingParsingEnabled = @"log-parsing",
	.loggingProcessingEnabled = @"log-processing",
};