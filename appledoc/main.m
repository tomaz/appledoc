//
//  main.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/12/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "DDCliUtil.h"
#import "AppledocInfo.h"
#import "Settings+Appledoc.h"
#import "GBCommandLineParser.h"
#import "GBOptionsHelper.h"
#import "Appledoc.h"

static void registerOptionDefinitions(GBOptionsHelper *options) {
	GBOptionDefinition definitions[] = {
		{ 0,	nil,							@"PROJECT INFO",											GBOptionSeparator },
		{ 'p',	GBOptions.projectName,			@"Project name",											GBValueRequired },
		{ 'v',	GBOptions.projectVersion,		@"Project version",											GBValueRequired },
		{ 'c',	GBOptions.companyName,			@"Company name",											GBValueRequired },
		{ 0,	GBOptions.companyIdentifier,	@"Company UTI (i.e. reverse DNS name)",						GBValueRequired },
		
		{ 0,	nil,							@"PATHS",													GBOptionSeparator },
		{ 0,	GBOptions.inputPaths,			@"Array of input paths for global and project settings",	GBOptionNoCmdLine|GBOptionInvisible },
		
		{ 0,	nil,							@"MISCELLANEOUS",											GBOptionSeparator },
		{ 0,	GBOptions.printSettings,		@"[b] Print settings for current run",						GBValueNone },
		{ 0,	GBOptions.printVersion,			@"Display version and exit",								GBValueNone|GBOptionNoPrint },
		{ '?',	GBOptions.printHelp,			@"Display this help and exit",								GBValueNone|GBOptionNoPrint },
		
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
		options.printValuesHeader = ^{ return @"%APPNAME version %APPVERSION (build %APPBUILD)\n"; };
		options.printValuesArgumentsHeader = ^{ return @"Running with paths:\n"; };
		options.printValuesOptionsHeader = ^{ return @"Running with options:\n"; };
		options.printValuesFooter = ^{ return @"\nEnd of values print...\n"; };
		options.printHelpHeader = ^{ return @"Usage %APPNAME [OPTIONS] <input paths separated by space>"; };
		options.printHelpFooter = ^{ 
			NSMutableString *result = [NSMutableString string];
			[result appendString:@"\n"];
			[result appendString:@"------------------------------------------------------------------\n"];
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
		
		// Apply factory defaults, global and project settings, then print settings if necessary.
		[factoryDefaults applyFactoryDefaults];
		[globalSettings applyGlobalSettingsFromCmdLineSettings:settings];
		[projectSettings applyProjectSettingsFromCmdLineSettings:settings];
		if (settings.printSettings) [options printValuesFromSettings:settings];

		// Initialize and run the application.
		Appledoc *appledoc = [[Appledoc alloc] init];
		appledoc.settings = settings;
	}
    return 0;
}
