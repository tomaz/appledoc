//
//  main.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/12/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "DDCliUtil.h"
#import "Logging.h"
#import "AppledocInfo.h"
#import "GBSettings+Appledoc.h"
#import "GBSettings+Helpers.h"
#import "GBCommandLineParser.h"
#import "GBOptionsHelper.h"
#import "Appledoc.h"

static void registerOptionDefinitions(GBOptionsHelper *options) {
	GBOptionDefinition definitions[] = {
		{ 0,	nil,								@"PROJECT INFO",												GBOptionSeparator },
		{ 'p',	GBOptions.projectName,				@"Project name",												GBValueRequired },
		{ 'v',	GBOptions.projectVersion,			@"Project version",												GBValueRequired },
		{ 'c',	GBOptions.companyName,				@"Company name",												GBValueRequired },
		{ 'u',	GBOptions.companyIdentifier,		@"Company UTI (i.e. reverse DNS name)",							GBValueRequired },
		
		{ 0,	nil,								@"PATHS",														GBOptionSeparator },
		{ 0,	GBOptions.inputPaths,				@"[a] Array of input paths for global and project settings",	GBValueRequired|GBOptionNoCmdLine|GBOptionInvisible },
		{ 't',	GBOptions.templatesPath,			@"Template files path",											GBValueRequired },
		{ 'i',	GBOptions.ignoredPaths,				@"[a] Ignore given path",										GBValueRequired },
		
		{ 0,	nil,								@"LOGGING",														GBOptionSeparator },
		{ 0,	GBOptions.loggingLevel,				@"Log verbosity (0-5)",											GBValueRequired },
		{ 0,	GBOptions.loggingFormat,			@"Log format (0-3)",											GBValueRequired },
		{ 0,	GBOptions.loggingCommonEnabled,		@"[D] Enable common logging",									GBValueNone|GBOptionNoHelp },
		{ 0,	GBOptions.loggingParsingEnabled,	@"[D] Enable parser logging",									GBValueNone|GBOptionNoHelp },

		{ 0,	nil,								@"MISCELLANEOUS",												GBOptionSeparator },
		{ 0,	GBOptions.printSettings,			@"[b] Print settings for current run",							GBValueNone },
		{ 0,	GBOptions.printVersion,				@"Display version and exit",									GBValueNone|GBOptionNoPrint },
		{ '?',	GBOptions.printHelp,				@"Display this help and exit",									GBValueNone|GBOptionNoPrint },
		
		{ 0,	nil, nil, 0 }
	};
	[options registerOptionsFromDefinitions:definitions];
}

int main(int argc, char *argv[]) {
	@autoreleasepool {
		// Initialize the settings stack.
		GBSettings *factoryDefaults = [GBSettings appledocSettingsWithName:@"Factory" parent:nil];
		GBSettings *globalSettings = [GBSettings appledocSettingsWithName:@"Global" parent:factoryDefaults];
		GBSettings *projectSettings = [GBSettings appledocSettingsWithName:@"Project" parent:globalSettings];
		GBSettings *settings = [GBSettings appledocSettingsWithName:@"CmdLine" parent:projectSettings];
		
		// Initialize options helper class.
		GBOptionsHelper *options = [[GBOptionsHelper alloc] init];
		options.applicationVersion = ^{ return GB_APPLEDOC_VERSION; };
		options.applicationBuild = ^{ return GB_APPLEDOC_BUILD; };
		options.printValuesArgumentsHeader = ^{ return @"Running with paths:\n"; };
		options.printValuesOptionsHeader = ^{ return @"Running with options:\n"; };
		options.printHelpHeader = ^{ return @"Usage %APPNAME [OPTIONS] <input paths separated by space>"; };
		options.printHelpFooter = ^{ 
			NSMutableString *result = [NSMutableString string];
			[result appendString:@"\n"];
			[result appendString:@"------------------------------------------------------------------\n"];
			[result appendString:@"[a] array parameter, can repeat, values are accumulated.\n"];
			[result appendString:@"[b] boolean parameter, uses no value, use --no- prefix to negate.\n"];
//			[result appendString:@"\n"];
//			[result appendString:@"[*] indicates parameters accepting placeholder strings:\n"];
//			[result appendString:@"- %@ replaced with --project-name\n", kGBTemplatePlaceholderProject];
//			[result appendString:@"- %@ replaced with normalized --project-name\n", kGBTemplatePlaceholderProjectID];
//			[result appendString:@"- %@ replaced with --project-version\n", kGBTemplatePlaceholderVersion];
//			[result appendString:@"- %@ replaced with normalized --project-version\n", kGBTemplatePlaceholderVersionID];
//			[result appendString:@"- %@ replaced with --project-company\n", kGBTemplatePlaceholderCompany];
//			[result appendString:@"- %@ replaced with --company-id\n", kGBTemplatePlaceholderCompanyID];
//			[result appendString:@"- %@ replaced with current year (format yyyy)\n", kGBTemplatePlaceholderYear];
//			[result appendString:@"- %@ replaced with current date (format yyyy-MM-dd)\n", kGBTemplatePlaceholderUpdateDate];
//			[result appendString:@"- %@ replaced with --docset-bundle-filename\n", kGBTemplatePlaceholderDocSetBundleFilename];
//			[result appendString:@"- %@ replaced with --docset-atom-filename\n", kGBTemplatePlaceholderDocSetAtomFilename];
//			[result appendString:@"- %@ replaced with --docset-package-filename\n", kGBTemplatePlaceholderDocSetPackageFilename];
			[result appendString:@"\n"];
			[result appendString:@"------------------------------------------------------------------\n"];
			[result appendString:@"Find more help and tips online:\n"];
			[result appendString:@"- http://gentlebytes.com/appledoc\n"];
			[result appendString:@"\n"];
			[result appendString:@"------------------------------------------------------------------\n"];
			[result appendString:@"%APPNAME uses the following open source components, fully or partially:\n"];
			[result appendString:@"\n"];
			[result appendString:@"- DDCli by Dave Dribin\n"];
			[result appendFormat:@"- ParseKiy by Todd Ditchendorf\n"];
			[result appendFormat:@"- OCHamcrest by Jon Reid\n"];
			[result appendFormat:@"- OCMock by Mulle Kybernetik\n"];
			[result appendString:@"\n"];
			[result appendString:@"We'd like to thank all authors for their contribution!\n"];
			return result;
		};
		registerOptionDefinitions(options);
		
		// Initialize command line parser and parse cmd line.
		GBCommandLineParser *parser = [[GBCommandLineParser alloc] init];
		[options registerOptionsToCommandLineParser:parser];		
		__block BOOL commandLineValid = YES;
		[parser parseOptionsWithArguments:argv count:argc block:^(GBParseFlags flags, NSString *option, id value, BOOL *stop) {
			switch (flags) {
				case GBParseFlagUnknownOption:
					ddprintf(@"Unknown command line option %@, try --help!\n", option);
					commandLineValid = NO;
					break;
				case GBParseFlagMissingValue:
					ddprintf(@"Missing value for command line option %@, try --help!\n", option);
					commandLineValid = NO;
					break;
				case GBParseFlagOption:
					[settings setObject:value forKey:option];
					break;
				case GBParseFlagArgument:
					[settings addArgument:value];
					break;
			}
		}];
		if (!commandLineValid) return 1;
		
		// Show version or help if needed.
		if (settings.printVersion) {
			[options printVersion];
			return 0;
		}
		if (settings.printHelp) {
			[options printHelp];
			return 0;
		}
		
		// We always print version so we can simplify debugging to a degree.
		[options printVersion];
		
		// Apply factory defaults, global and project settings, then consolidate.
		[factoryDefaults applyFactoryDefaults];
		if (![globalSettings applyGlobalSettingsFromCmdLineSettings:settings]) return 1;
		if (![projectSettings applyProjectSettingsFromCmdLineSettings:settings]) return 1;
		[settings consolidateSettings];

		// Print settings if necessary, then validate.
		if (settings.printSettings) [options printValuesFromSettings:settings];
		if (![settings validateSettings]) return 1;

		// Initialize and run the application.
		initialize_logging_from_settings(settings);
		Appledoc *appledoc = [[Appledoc alloc] init];
		return [appledoc runWithSettings:settings];
	}
    return 0;
}
