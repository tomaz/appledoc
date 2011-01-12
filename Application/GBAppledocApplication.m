//
//  GBAppledocApplication.m
//  appledoc
//
//  Created by Tomaz Kragelj on 22.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "timing.h"
#import "DDCliUtil.h"
#import "DDGetoptLongParser.h"
#import "GBStore.h"
#import "GBParser.h"
#import "GBProcessor.h"
#import "GBGenerator.h"
#import "GBApplicationSettingsProvider.h"
#import "GBAppledocApplication.h"

static NSString *kGBArgOutputPath = @"output";
static NSString *kGBArgTemplatesPath = @"templates";
static NSString *kGBArgDocSetInstallPath = @"docset-install-path";
static NSString *kGBArgDocSetUtilPath = @"docsetutil-path";
static NSString *kGBArgIgnorePath = @"ignore";

static NSString *kGBArgProjectName = @"project-name";
static NSString *kGBArgProjectVersion = @"project-version";
static NSString *kGBArgProjectCompany = @"project-company";
static NSString *kGBArgCompanyIdentifier = @"company-id";

static NSString *kGBArgCreateHTML = @"create-html";
static NSString *kGBArgCreateDocSet = @"create-docset";
static NSString *kGBArgInstallDocSet = @"install-docset";
static NSString *kGBArgPublishDocSet = @"publish-docset";
static NSString *kGBArgKeepIntermediateFiles = @"keep-intermediate-files";

static NSString *kGBArgRepeatFirstParagraph = @"repeat-first-par";
static NSString *kGBArgKeepUndocumentedObjects = @"keep-undocumented-objects";
static NSString *kGBArgKeepUndocumentedMembers = @"keep-undocumented-members";
static NSString *kGBArgFindUndocumentedMembersDocumentation = @"search-undocumented-doc";
static NSString *kGBArgMergeCategoriesToClasses = @"merge-categories";
static NSString *kGBArgKeepMergedCategoriesSections = @"keep-merged-sections";
static NSString *kGBArgPrefixMergedCategoriesSectionsWithCategoryName = @"prefix-merged-sections";

static NSString *kGBArgWarnOnMissingOutputPath = @"warn-missing-output-path";
static NSString *kGBArgWarnOnMissingCompanyIdentifier = @"warn-missing-company-id";
static NSString *kGBArgWarnOnUndocumentedObject = @"warn-undocumented-object";
static NSString *kGBArgWarnOnUndocumentedMember = @"warn-undocumented-member";
static NSString *kGBArgWarnOnInvalidCrossReference = @"warn-invalid-crossref";
static NSString *kGBArgWarnOnMissingMethodArgument = @"warn-missing-arg";

static NSString *kGBArgDocSetBundleIdentifier = @"docset-bundle-id";
static NSString *kGBArgDocSetBundleName = @"docset-bundle-name";
static NSString *kGBArgDocSetDescription = @"docset-desc";
static NSString *kGBArgDocSetCopyrightMessage = @"docset-copyright";
static NSString *kGBArgDocSetFeedName = @"docset-feed-name";
static NSString *kGBArgDocSetFeedURL = @"docset-feed-url";
static NSString *kGBArgDocSetPackageURL = @"docset-package-url";
static NSString *kGBArgDocSetFallbackURL = @"docset-fallback-url";
static NSString *kGBArgDocSetPublisherIdentifier = @"docset-publisher-id";
static NSString *kGBArgDocSetPublisherName = @"docset-publisher-name";
static NSString *kGBArgDocSetMinimumXcodeVersion = @"docset-min-xcode-version";
static NSString *kGBArgDocSetPlatformFamily = @"docset-platform-family";
static NSString *kGBArgDocSetCertificateIssuer = @"docset-cert-issuer";
static NSString *kGBArgDocSetCertificateSigner = @"docset-cert-signer";

static NSString *kGBArgDocSetBundleFilename = @"docset-bundle-filename";
static NSString *kGBArgDocSetAtomFilename = @"docset-atom-filename";
static NSString *kGBArgDocSetPackageFilename = @"docset-package-filename";

static NSString *kGBArgLogFormat = @"logformat";
static NSString *kGBArgVerbose = @"verbose";
static NSString *kGBArgPrintSettings = @"print-settings";
static NSString *kGBArgVersion = @"version";
static NSString *kGBArgHelp = @"help";

#define GBNoArg(arg) [NSString stringWithFormat:@"no-%@", arg]

#pragma mark -

@interface GBAppledocApplication ()

- (void)initializeLoggingSystem;
- (void)initializeGlobalSettingsAndValidateTemplates;
- (void)validateSettingsAndArguments:(NSArray *)arguments;
- (void)overrideSettingsWithGlobalSettingsFromPath:(NSString *)path;
- (BOOL)validateTemplatesPath:(NSString *)path error:(NSError **)error;
- (NSString *)standardizeCurrentDirectoryForPath:(NSString *)path;
@property (readwrite, retain) GBApplicationSettingsProvider *settings;
@property (assign) NSString *logformat;
@property (assign) NSString *verbose;
@property (assign) BOOL templatesFound;
@property (assign) BOOL printSettings;
@property (assign) BOOL version;
@property (assign) BOOL help;

@end

#pragma mark -

@interface GBAppledocApplication (UsagePrintout)

- (void)printSettingsAndArguments:(NSArray *)arguments;
- (void)printVersion;
- (void)printHelp;
- (void)printHelpForShortOption:(NSString *)aShort longOption:(NSString *)aLong argument:(NSString *)argument description:(NSString *)description;

@end

#pragma mark -

@implementation GBAppledocApplication

#pragma mark Initialization & disposal

- (id)init {
	self = [super init];
	if (self) {
		self.settings = [GBApplicationSettingsProvider provider];
		self.templatesFound = NO;
		self.printSettings = NO;
		self.logformat = @"1";
		self.verbose = @"2";
	}
	return self;
}

#pragma mark DDCliApplicationDelegate implementation

- (int)application:(DDCliApplication *)app runWithArguments:(NSArray *)arguments {
	if (self.help) {
		[self printHelp];
		return EXIT_SUCCESS;
	}
	if (self.version) {
		[self printVersion];
		return EXIT_SUCCESS;
	}
	
	[self printVersion];
	[self validateSettingsAndArguments:arguments];
	[self.settings replaceAllOccurencesOfPlaceholderStringsInSettingsValues];
	if (self.printSettings) [self printSettingsAndArguments:arguments];

	@try {		
		[self initializeLoggingSystem];
		
		GBLogNormal(@"Initializing...");
		GBStore *store = [[GBStore alloc] init];		
		GBAbsoluteTime startTime = GetCurrentTime();
		
		GBLogNormal(@"Parsing source files...");
		GBParser *parser = [GBParser parserWithSettingsProvider:self.settings];
		[parser parseObjectsFromPaths:arguments toStore:store];
		GBAbsoluteTime parseTime = GetCurrentTime();
		NSUInteger timeForParsing = SubtractTime(parseTime, startTime) * 1000.0;
		GBLogInfo(@"Finished parsing in %ldms.\n", timeForParsing);
		
		GBLogNormal(@"Processing parsed data...");
		GBProcessor *processor = [GBProcessor processorWithSettingsProvider:self.settings];
		[processor processObjectsFromStore:store];
		GBAbsoluteTime processTime = GetCurrentTime();
		NSUInteger timeForProcessing = SubtractTime(processTime, parseTime) * 1000.0;
		GBLogInfo(@"Finished processing in %ldms.\n", timeForProcessing);
		
		GBLogNormal(@"Generating output...");
		GBGenerator *generator = [GBGenerator generatorWithSettingsProvider:self.settings];
		[generator generateOutputFromStore:store];
		GBAbsoluteTime generateTime = GetCurrentTime();
		NSUInteger timeForGeneration = SubtractTime(generateTime, processTime) * 1000.0;
		GBLogInfo(@"Finished generating in %ldms.\n", timeForGeneration);
		
		NSUInteger timeForEverything = timeForParsing + timeForProcessing + timeForGeneration;		
		GBLogNormal(@"Finished in %ldms.", timeForEverything);
		GBLogInfo(@"Parsing:    %ldms (%ld%%)", timeForParsing, timeForParsing * 100 / timeForEverything);
		GBLogInfo(@"Processing: %ldms (%ld%%)", timeForProcessing, timeForProcessing * 100 / timeForEverything);
		GBLogInfo(@"Generating: %ldms (%ld%%)", timeForGeneration, timeForGeneration * 100 / timeForEverything);
	}
	@catch (NSException *e) {
		GBLogException(e, @"Oops, something went wrong...");
		return EXIT_FAILURE;
	}
	
	return EXIT_SUCCESS;
}

- (void)application:(DDCliApplication *)app willParseOptions:(DDGetoptLongParser *)optionParser {
	DDGetoptOption options[] = {
		{ kGBArgOutputPath,													'o',	DDGetoptRequiredArgument },
		{ kGBArgTemplatesPath,												't',	DDGetoptRequiredArgument },
		{ kGBArgIgnorePath,													'i',	DDGetoptRequiredArgument },
		{ kGBArgDocSetInstallPath,											0,		DDGetoptRequiredArgument },
		{ kGBArgDocSetUtilPath,												0,		DDGetoptRequiredArgument },
		
		{ kGBArgProjectName,												'p',	DDGetoptRequiredArgument },
		{ kGBArgProjectVersion,												'v',	DDGetoptRequiredArgument },
		{ kGBArgProjectCompany,												'c',	DDGetoptRequiredArgument },
		{ kGBArgCompanyIdentifier,											0,		DDGetoptRequiredArgument },
		
		{ kGBArgDocSetBundleIdentifier,										0,		DDGetoptRequiredArgument },
		{ kGBArgDocSetBundleName,											0,		DDGetoptRequiredArgument },
		{ kGBArgDocSetCertificateIssuer,									0,		DDGetoptRequiredArgument },
		{ kGBArgDocSetCertificateSigner,									0,		DDGetoptRequiredArgument },
		{ kGBArgDocSetDescription,											0,		DDGetoptRequiredArgument },
		{ kGBArgDocSetFallbackURL,											0,		DDGetoptRequiredArgument },
		{ kGBArgDocSetFeedName,												0,		DDGetoptRequiredArgument },
		{ kGBArgDocSetFeedURL,												0,		DDGetoptRequiredArgument },
		{ kGBArgDocSetPackageURL,											0,		DDGetoptRequiredArgument },
		{ kGBArgDocSetMinimumXcodeVersion,									0,		DDGetoptRequiredArgument },
		{ kGBArgDocSetPlatformFamily,										0,		DDGetoptRequiredArgument },
		{ kGBArgDocSetPublisherIdentifier,									0,		DDGetoptRequiredArgument },
		{ kGBArgDocSetPublisherName,										0,		DDGetoptRequiredArgument },
		{ kGBArgDocSetCopyrightMessage,										0,		DDGetoptRequiredArgument },
		
		{ kGBArgDocSetBundleFilename,										0,		DDGetoptRequiredArgument },
		{ kGBArgDocSetAtomFilename,											0,		DDGetoptRequiredArgument },
		{ kGBArgDocSetPackageFilename,										0,		DDGetoptRequiredArgument },
		
		{ kGBArgCreateHTML,													'h',	DDGetoptNoArgument },
		{ kGBArgCreateDocSet,												'd',	DDGetoptNoArgument },
		{ kGBArgInstallDocSet,												'n',	DDGetoptNoArgument },
		{ kGBArgPublishDocSet,												'u',	DDGetoptNoArgument },
		{ GBNoArg(kGBArgCreateHTML),										0,		DDGetoptNoArgument },
		{ GBNoArg(kGBArgCreateDocSet),										0,		DDGetoptNoArgument },
		{ GBNoArg(kGBArgInstallDocSet),										0,		DDGetoptNoArgument },
		{ GBNoArg(kGBArgPublishDocSet),										0,		DDGetoptNoArgument },
		
		{ kGBArgKeepIntermediateFiles,										0,		DDGetoptNoArgument },
		{ kGBArgKeepUndocumentedObjects,									0,		DDGetoptNoArgument },
		{ kGBArgKeepUndocumentedMembers,									0,		DDGetoptNoArgument },
		{ kGBArgFindUndocumentedMembersDocumentation,						0,		DDGetoptNoArgument },
		{ kGBArgRepeatFirstParagraph,										0,		DDGetoptNoArgument },
		{ kGBArgMergeCategoriesToClasses,									0,		DDGetoptNoArgument },
		{ kGBArgKeepMergedCategoriesSections,								0,		DDGetoptNoArgument },
		{ kGBArgPrefixMergedCategoriesSectionsWithCategoryName,				0,		DDGetoptNoArgument },
		{ GBNoArg(kGBArgKeepIntermediateFiles),								0,		DDGetoptNoArgument },
		{ GBNoArg(kGBArgKeepUndocumentedObjects),							0,		DDGetoptNoArgument },
		{ GBNoArg(kGBArgKeepUndocumentedMembers),							0,		DDGetoptNoArgument },
		{ GBNoArg(kGBArgFindUndocumentedMembersDocumentation),				0,		DDGetoptNoArgument },
		{ GBNoArg(kGBArgRepeatFirstParagraph),								0,		DDGetoptNoArgument },
		{ GBNoArg(kGBArgMergeCategoriesToClasses),							0,		DDGetoptNoArgument },
		{ GBNoArg(kGBArgKeepMergedCategoriesSections),						0,		DDGetoptNoArgument },
		{ GBNoArg(kGBArgPrefixMergedCategoriesSectionsWithCategoryName),	0,		DDGetoptNoArgument },
		
		{ kGBArgWarnOnMissingOutputPath,									0,		DDGetoptNoArgument },
		{ kGBArgWarnOnMissingCompanyIdentifier,								0,		DDGetoptNoArgument },
		{ kGBArgWarnOnUndocumentedObject,									0,		DDGetoptNoArgument },
		{ kGBArgWarnOnUndocumentedMember,									0,		DDGetoptNoArgument },
		{ kGBArgWarnOnInvalidCrossReference,								0,		DDGetoptNoArgument },
		{ kGBArgWarnOnMissingMethodArgument,								0,		DDGetoptNoArgument },
		{ GBNoArg(kGBArgWarnOnMissingOutputPath),							0,		DDGetoptNoArgument },
		{ GBNoArg(kGBArgWarnOnMissingCompanyIdentifier),					0,		DDGetoptNoArgument },
		{ GBNoArg(kGBArgWarnOnUndocumentedObject),							0,		DDGetoptNoArgument },
		{ GBNoArg(kGBArgWarnOnUndocumentedMember),							0,		DDGetoptNoArgument },
		{ GBNoArg(kGBArgWarnOnInvalidCrossReference),						0,		DDGetoptNoArgument },
		{ GBNoArg(kGBArgWarnOnMissingMethodArgument),						0,		DDGetoptNoArgument },
		
		{ kGBArgLogFormat,													0,		DDGetoptRequiredArgument },
		{ kGBArgVerbose,													0,		DDGetoptRequiredArgument },
		{ kGBArgPrintSettings,												0,		DDGetoptNoArgument },
		{ kGBArgVersion,													0,		DDGetoptNoArgument },
		{ kGBArgHelp,														0,		DDGetoptNoArgument },
		{ nil,																0,		0 },
	};
	[self initializeGlobalSettingsAndValidateTemplates];
	[optionParser addOptionsFromTable:options];
}

#pragma mark Application handling

- (void)initializeLoggingSystem {
	id formatter = [GBLog logFormatterForLogFormat:self.logformat];
	[[DDTTYLogger sharedInstance] setLogFormatter:formatter];
	[DDLog addLogger:[DDTTYLogger sharedInstance]];
	[GBLog setLogLevelFromVerbose:self.verbose];
	[formatter release];
}

- (void)initializeGlobalSettingsAndValidateTemplates {
	// This is where we override factory defaults (factory defaults with global templates. This needs to be sent before giving DDCli a chance to go through parameters! DDCli will "take care" (or more correct: it's KVC messages will) of overriding with command line arguments. Note that we scan the arguments backwards to get the latest template value - this is what we'll get with DDCli later on anyway. If no template path is given, check predefined paths.
	NSArray *arguments = [[NSProcessInfo processInfo] arguments];
	self.templatesFound = NO;
	__block NSString *path = nil;
	[arguments enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSString *option, NSUInteger idx, BOOL *stop) {
		NSString *opt = [option copy];
		while ([opt hasPrefix:@"-"]) opt = [opt substringFromIndex:1];
		if ([opt isEqualToString:@"t"] || [opt isEqualToString:kGBArgTemplatesPath]) {
			NSError *error = nil;
			if (![self validateTemplatesPath:path error:&error]) [NSException raise:error format:@"Path '%@' from %@ is not valid!", path, option];			
			[self overrideSettingsWithGlobalSettingsFromPath:path];
			self.templatesFound = YES;
			*stop = YES;
			return;
		}
		path = option;
	}];
	
	// If no templates path is provided through command line, test predefined ones. Note that we don't raise exception here if validation fails on any path, but we do raise it if no template path is found at all as we can't run the application!
	if (!self.templatesFound) {
		NSArray *appSupportPaths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
		for (NSString *appSupportPath in appSupportPaths)
		{
			path = [appSupportPath stringByAppendingPathComponent:@"appledoc"];
			if ([self validateTemplatesPath:path error:nil]) {
				[self overrideSettingsWithGlobalSettingsFromPath:path];
				self.settings.templatesPath = path;
				self.templatesFound = YES;
				return;
			}		
		}
		
		path = @"~/.appledoc";
		if ([self validateTemplatesPath:path error:nil]) {
			[self overrideSettingsWithGlobalSettingsFromPath:path];
			self.settings.templatesPath = path;
			self.templatesFound = YES;
			return;
		}		
	}
}

- (void)overrideSettingsWithGlobalSettingsFromPath:(NSString *)path {
	// Checks if global settings file exists at the given path and if so, overrides current settings with values from the file. To keep code as simple as possible, we're reusing DDCli KVC here: global templates file simply uses keys which are equal to command line arguments. Then, by reusing DDCli method for converting switch to KVC key, we're simply sending appropriate KVC messages to receiver. From object's point of view, this is no different than getting KVC messages sent from DDCli. If we time this message correctly, it's sent after factory defaults are established and before DDCli parses command line! Note that this may cause some KVC messages beeing sent twice or more. The only code added is handling boolean settings (i.e. adding "--no" prefix) and settings that may be entered multiple times (--ignore for example). To even further simplify handling, we're only allowing long command line arguments names in global templates for now!
	NSString *userPath = [path stringByAppendingPathComponent:@"GlobalSettings.plist"];
	NSString *filename = [userPath stringByStandardizingPath];
	if (![self.fileManager fileExistsAtPath:filename]) return;
	
	NSError* error = nil;
	NSData* data = [NSData dataWithContentsOfFile:filename options:0 error:&error];
	if (!data) [NSException raise:@"Failed reading global templates from '%@'!", userPath];	
	NSDictionary *globals = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:NULL error:&error];
	if (!globals) [NSException raise:error format:@"Failed reaing global templates plist from '%@'!", userPath];
	
	[globals enumerateKeysAndObjectsUsingBlock:^(NSString *option, id value, BOOL *stop) {
		while ([option hasPrefix:@"-"]) option = [option substringFromIndex:1];
		NSString *key = [DDGetoptLongParser keyFromOption:option];
		
		// Warn if templates option is passed - we're already handling templates and pointing to another template wouldn't make much sense.
		if ([option isEqualToString:kGBArgTemplatesPath]) {
			ddprintf(@"WARN: Found --%@ option in global setting, this is ignored for globals!\n", option);
			return;
		}
		
		// If the value is an array, send as many messages as there are values.
		if ([value isKindOfClass:[NSArray class]]) {
			for (NSString *item in value) {
				[self setValue:item forKey:key];
			}
			return;
		}
		
		// For all other values, just send the KVC message. Note that this works for booleans as well - if the plist has NO value, the value reported is going to be [NSNumber numberWithBool:NO] and our KVC mutator would properly assign the value, so therefore we don't have to prefix with "no"...
		[self setValue:value forKey:key];
	}];
}

- (BOOL)validateTemplatesPath:(NSString *)path error:(NSError **)error {
	// Validates the given templates path contains all required template files. If not, it returns the reason through the error argument and returns NO. Note that we only do simple "path exist and is directory" tests here, each object that requires templates at the given path will do it's own validation later on and will report errors if it finds something missing.
	BOOL isDirectory = NO;
	if (![self.fileManager fileExistsAtPath:[path stringByStandardizingPath] isDirectory:&isDirectory]) {
		if (error) {
			NSString *desc = [NSString stringWithFormat:@"Template path doesn't exist at '%@'!", path];
			*error = [NSError errorWithCode:GBErrorTemplatePathDoesntExist description:desc reason:nil];
		}
		return NO;
	}	
	if (!isDirectory) {
		if (error) {
			NSString *desc = [NSString stringWithFormat:@"Template path '%@' is not directory!", path];
			*error = [NSError errorWithCode:GBErrorTemplatePathNotDirectory description:desc reason:nil];
		}
		return NO;
	}
	return YES;
}

- (void)validateSettingsAndArguments:(NSArray *)arguments {
	// Validate we have valid templates path - we use the value of the templatesFound set within initializeGlobalSettingsAndValidateTemplates. We can't simply raise exception there because that message is sent before handling help or version; so we would be required to provide valid templates path even if we just wanted "appledoc --help". As this message is sent afterwards, we can raise exception here. Not as elegant, but needed.
	if (!self.templatesFound) {
		[NSException raise:@"No predefined templates path exists and no template path specified from command line!"];
	}

	// Validate we have at least one argument specifying the path to the files to handle. Also validate all given paths are valid.
	if ([arguments count] == 0) [NSException raise:@"At least one directory or file name path is required, use 'appledoc --help'"];
	for (NSString *path in arguments) {
		if (![self.fileManager fileExistsAtPath:path]) {
			[NSException raise:@"Path or file '%@' doesn't exist!", path];
		}
	}
	
	// Now validate we have all required settings specified.
	if ([self.settings.projectName length] == 0) [NSException raise:@"--%@ argument or global setting is required!", kGBArgProjectName];
	if ([self.settings.projectCompany length] == 0) [NSException raise:@"--%@ argument or global setting is required!", kGBArgProjectCompany];
	
	// If output path is not given, revert to current path, but do warn the user.
	if ([self.settings.outputPath length] == 0) {
		self.settings.outputPath = [self.fileManager currentDirectoryPath];
		if (self.settings.warnOnMissingOutputPathArgument) {
			ddprintf(@"WARN: --%@ argument or global setting not given, will output to current dir '%@'!\n", kGBArgOutputPath, self.settings.outputPath);
		}
	}
	
	// If company identifier is not given and we have docset enabled, prepare one from company name, but do warn the user.
	if (self.settings.createDocSet && [self.settings.companyIdentifier length] == 0) {
		NSString *value = [NSString stringWithFormat:@"com.%@.%@", self.settings.projectCompany, self.settings.projectName];
		value = [value stringByReplacingOccurrencesOfString:@" " withString:@""];
		value = [value lowercaseString];
		self.settings.companyIdentifier = value;
		if (self.settings.warnOnMissingCompanyIdentifier) {
			ddprintf(@"WARN: --%@ argument or global setting not given, but creating DocSet is enabled, will use '%@'!\n", kGBArgCompanyIdentifier, self.settings.companyIdentifier);
		}
	}
}

- (NSString *)standardizeCurrentDirectoryForPath:(NSString *)path {
	// Converts . to actual working directory.
	if (![path hasPrefix:@"."] || [path hasPrefix:@".."]) return path;
	NSString *suffix = [path substringFromIndex:1];
	return [[self.fileManager currentDirectoryPath] stringByAppendingPathComponent:suffix];
}

#pragma mark Overriden methods

- (NSString *)description {
	return [self className];
}

#pragma mark Callbacks API for DDCliApplication

- (void)setOutput:(NSString *)path { self.settings.outputPath = [self standardizeCurrentDirectoryForPath:path]; }
- (void)setTemplates:(NSString *)path { self.settings.templatesPath = [self standardizeCurrentDirectoryForPath:path]; }
- (void)setDocsetInstallPath:(NSString *)path { self.settings.docsetInstallPath = [self standardizeCurrentDirectoryForPath:path]; }
- (void)setDocsetutilPath:(NSString *)path { self.settings.docsetUtilPath = [self standardizeCurrentDirectoryForPath:path]; }
- (void)setIgnore:(NSString *)path {
	if ([path hasPrefix:@"*"]) path = [path substringFromIndex:1];
	[self.settings.ignoredPaths addObject:path];
}

- (void)setProjectName:(NSString *)value { self.settings.projectName = value; }
- (void)setProjectVersion:(NSString *)value { self.settings.projectVersion = value; }
- (void)setProjectCompany:(NSString *)value { self.settings.projectCompany = value; }
- (void)setCompanyId:(NSString *)value { self.settings.companyIdentifier = value; }

- (void)setCreateHtml:(BOOL)value { self.settings.createHTML = value; }
- (void)setCreateDocset:(BOOL)value { self.settings.createDocSet = value; }
- (void)setInstallDocset:(BOOL)value { self.settings.installDocSet = value; }
- (void)setPublishDocset:(BOOL)value { self.settings.publishDocSet = value; }
- (void)setNoCreateHtml:(BOOL)value { self.settings.createHTML = !value; }
- (void)setNoCreateDocset:(BOOL)value { self.settings.createDocSet = !value; }
- (void)setNoInstallDocset:(BOOL)value { self.settings.installDocSet = !value; }
- (void)setNoPublishDocset:(BOOL)value { self.settings.publishDocSet = !value; }

- (void)setKeepIntermediateFiles:(BOOL)value { self.settings.keepIntermediateFiles = value;}
- (void)setKeepUndocumentedObjects:(BOOL)value { self.settings.keepUndocumentedObjects = value; }
- (void)setKeepUndocumentedMembers:(BOOL)value { self.settings.keepUndocumentedMembers = value; }
- (void)setSearchUndocumentedDoc:(BOOL)value { self.settings.findUndocumentedMembersDocumentation = value; }
- (void)setRepeatFirstPar:(BOOL)value { self.settings.repeatFirstParagraphForMemberDescription = value; }
- (void)setMergeCategories:(BOOL)value { self.settings.mergeCategoriesToClasses = value; }
- (void)setKeepMergedSections:(BOOL)value { self.settings.keepMergedCategoriesSections = value; }
- (void)setPrefixMergedSections:(BOOL)value { self.settings.prefixMergedCategoriesSectionsWithCategoryName = value; }
- (void)setNoKeepIntermediateFiles:(BOOL)value { self.settings.keepIntermediateFiles = !value;}
- (void)setNoKeepUndocumentedObjects:(BOOL)value { self.settings.keepUndocumentedObjects = !value; }
- (void)setNoKeepUndocumentedMembers:(BOOL)value { self.settings.keepUndocumentedMembers = !value; }
- (void)setNoSearchUndocumentedDoc:(BOOL)value { self.settings.findUndocumentedMembersDocumentation = !value; }
- (void)setNoRepeatFirstPar:(BOOL)value { self.settings.repeatFirstParagraphForMemberDescription = !value; }
- (void)setNoMergeCategories:(BOOL)value { self.settings.mergeCategoriesToClasses = !value; }
- (void)setNoKeepMergedSections:(BOOL)value { self.settings.keepMergedCategoriesSections = !value; }
- (void)setNoPrefixMergedSections:(BOOL)value { self.settings.prefixMergedCategoriesSectionsWithCategoryName = !value; }

- (void)setWarnMissingOutputPath:(BOOL)value { self.settings.warnOnMissingOutputPathArgument = value; }
- (void)setWarnMissingCompanyId:(BOOL)value { self.settings.warnOnMissingCompanyIdentifier = value; }
- (void)setWarnUndocumentedObject:(BOOL)value { self.settings.warnOnUndocumentedObject = value; }
- (void)setWarnUndocumentedMember:(BOOL)value { self.settings.warnOnUndocumentedMember = value; }
- (void)setWarnInvalidCrossref:(BOOL)value { self.settings.warnOnInvalidCrossReference = value; }
- (void)setWarnMissingArg:(BOOL)value { self.settings.warnOnMissingMethodArgument = value; }
- (void)setNoWarnMissingOutputPath:(BOOL)value { self.settings.warnOnMissingOutputPathArgument = !value; }
- (void)setNoWarnMissingCompanyId:(BOOL)value { self.settings.warnOnMissingCompanyIdentifier = !value; }
- (void)setNoWarnUndocumentedObject:(BOOL)value { self.settings.warnOnUndocumentedObject = !value; }
- (void)setNoWarnUndocumentedMember:(BOOL)value { self.settings.warnOnUndocumentedMember = !value; }
- (void)setNoWarnInvalidCrossref:(BOOL)value { self.settings.warnOnInvalidCrossReference = !value; }
- (void)setNoWarnMissingArg:(BOOL)value { self.settings.warnOnMissingMethodArgument = !value; }

- (void)setDocsetBundleId:(NSString *)value { self.settings.docsetBundleIdentifier = value; }
- (void)setDocsetBundleName:(NSString *)value { self.settings.docsetBundleName = value; }
- (void)setDocsetDesc:(NSString *)value { self.settings.docsetDescription = value; }
- (void)setDocsetCopyright:(NSString *)value { self.settings.docsetCopyrightMessage = value; }
- (void)setDocsetFeedName:(NSString *)value { self.settings.docsetFeedName = value; }
- (void)setDocsetFeedUrl:(NSString *)value { self.settings.docsetFeedURL = value; }
- (void)setDocsetPackageUrl:(NSString *)value { self.settings.docsetPackageURL = value; }
- (void)setDocsetFallbackUrl:(NSString *)value { self.settings.docsetFallbackURL = value; }
- (void)setDocsetPublisherId:(NSString *)value { self.settings.docsetPublisherIdentifier = value; }
- (void)setDocsetPublisherName:(NSString *)value { self.settings.docsetPublisherName = value; }
- (void)setDocsetMinXcodeVersion:(NSString *)value { self.settings.docsetMinimumXcodeVersion = value; }
- (void)setDocsetPlatformFamily:(NSString *)value { self.settings.docsetPlatformFamily = value; }
- (void)setDocsetCertIssuer:(NSString *)value { self.settings.docsetCertificateIssuer = value; }
- (void)setDocsetCertSigner:(NSString *)value { self.settings.docsetCertificateSigner = value; }

- (void)setDocsetBundleFilename:(NSString *)value { self.settings.docsetBundleFilename = value; }
- (void)setDocsetAtomFilename:(NSString *)value { self.settings.docsetAtomFilename = value; }
- (void)setDocsetPackageFilename:(NSString *)value { self.settings.docsetPackageFilename = value; }

@synthesize logformat;
@synthesize verbose;
@synthesize printSettings;
@synthesize templatesFound;
@synthesize version;
@synthesize help;

#pragma mark Properties

@synthesize settings;

@end

#pragma mark -

@implementation GBAppledocApplication (UsagePrintout)

- (void)printSettingsAndArguments:(NSArray *)arguments {
#define PRINT_BOOL(v) (v ? @"YES" : @"NO")
	// This is useful for debugging to see exact set of setting values that are going to be used for this session. Note that this is coupling command line switches to actual settings. Here it's just the opposite than DDCli callbacks.
	ddprintf(@"Running for files in locations:\n");
	for (NSString *path in arguments) ddprintf(@"- %@\n", path);
	ddprintf(@"\n");
	
	ddprintf(@"Settings used for this run:\n");
	ddprintf(@"--%@ = %@\n", kGBArgProjectName, self.settings.projectName);
	ddprintf(@"--%@ = %@\n", kGBArgProjectVersion, self.settings.projectVersion);
	ddprintf(@"--%@ = %@\n", kGBArgProjectCompany, self.settings.projectCompany);
	ddprintf(@"--%@ = %@\n", kGBArgCompanyIdentifier, self.settings.companyIdentifier);
	ddprintf(@"\n");
	
	ddprintf(@"--%@ = %@\n", kGBArgTemplatesPath, self.settings.templatesPath);
	ddprintf(@"--%@ = %@\n", kGBArgOutputPath, self.settings.outputPath);
	for (NSString *path in self.settings.ignoredPaths) ddprintf(@"--%@ = %@\n", kGBArgIgnorePath, path);
	ddprintf(@"--%@ = %@\n", kGBArgDocSetInstallPath, self.settings.docsetInstallPath);
	ddprintf(@"--%@ = %@\n", kGBArgDocSetUtilPath, self.settings.docsetUtilPath);
	ddprintf(@"\n");
	
	ddprintf(@"--%@ = %@\n", kGBArgDocSetBundleIdentifier, self.settings.docsetBundleIdentifier);
	ddprintf(@"--%@ = %@\n", kGBArgDocSetBundleName, self.settings.docsetBundleName);
	ddprintf(@"--%@ = %@\n", kGBArgDocSetDescription, self.settings.docsetDescription);
	ddprintf(@"--%@ = %@\n", kGBArgDocSetCopyrightMessage, self.settings.docsetCopyrightMessage);
	ddprintf(@"--%@ = %@\n", kGBArgDocSetFeedName, self.settings.docsetFeedName);
	ddprintf(@"--%@ = %@\n", kGBArgDocSetFeedURL, self.settings.docsetFeedURL);
	ddprintf(@"--%@ = %@\n", kGBArgDocSetPackageURL, self.settings.docsetPackageURL);
	ddprintf(@"--%@ = %@\n", kGBArgDocSetFallbackURL, self.settings.docsetFallbackURL);
	ddprintf(@"--%@ = %@\n", kGBArgDocSetPublisherIdentifier, self.settings.docsetPublisherIdentifier);
	ddprintf(@"--%@ = %@\n", kGBArgDocSetPublisherName, self.settings.docsetPublisherName);
	ddprintf(@"--%@ = %@\n", kGBArgDocSetMinimumXcodeVersion, self.settings.docsetMinimumXcodeVersion);
	ddprintf(@"--%@ = %@\n", kGBArgDocSetPlatformFamily, self.settings.docsetPlatformFamily);
	ddprintf(@"--%@ = %@\n", kGBArgDocSetCertificateIssuer, self.settings.docsetCertificateIssuer);
	ddprintf(@"--%@ = %@\n", kGBArgDocSetCertificateSigner, self.settings.docsetCertificateSigner);
	ddprintf(@"--%@ = %@\n", kGBArgDocSetBundleFilename, self.settings.docsetBundleFilename);
	ddprintf(@"--%@ = %@\n", kGBArgDocSetAtomFilename, self.settings.docsetAtomFilename);
	ddprintf(@"--%@ = %@\n", kGBArgDocSetPackageFilename, self.settings.docsetPackageFilename);
	ddprintf(@"\n");
	
	ddprintf(@"--%@ = %@\n", kGBArgCreateHTML, PRINT_BOOL(self.settings.createHTML));
	ddprintf(@"--%@ = %@\n", kGBArgCreateDocSet, PRINT_BOOL(self.settings.createDocSet));
	ddprintf(@"--%@ = %@\n", kGBArgInstallDocSet, PRINT_BOOL(self.settings.installDocSet));
	ddprintf(@"--%@ = %@\n", kGBArgPublishDocSet, PRINT_BOOL(self.settings.publishDocSet));
	ddprintf(@"--%@ = %@\n", kGBArgKeepIntermediateFiles, PRINT_BOOL(self.settings.keepIntermediateFiles));
	ddprintf(@"--%@ = %@\n", kGBArgKeepUndocumentedObjects, PRINT_BOOL(self.settings.keepUndocumentedObjects));
	ddprintf(@"--%@ = %@\n", kGBArgKeepUndocumentedMembers, PRINT_BOOL(self.settings.keepUndocumentedMembers));
	ddprintf(@"--%@ = %@\n", kGBArgFindUndocumentedMembersDocumentation, PRINT_BOOL(self.settings.findUndocumentedMembersDocumentation));
	ddprintf(@"--%@ = %@\n", kGBArgRepeatFirstParagraph, PRINT_BOOL(self.settings.repeatFirstParagraphForMemberDescription));
	ddprintf(@"--%@ = %@\n", kGBArgMergeCategoriesToClasses, PRINT_BOOL(self.settings.mergeCategoriesToClasses));
	ddprintf(@"--%@ = %@\n", kGBArgKeepMergedCategoriesSections, PRINT_BOOL(self.settings.keepMergedCategoriesSections));
	ddprintf(@"--%@ = %@\n", kGBArgPrefixMergedCategoriesSectionsWithCategoryName, PRINT_BOOL(self.settings.prefixMergedCategoriesSectionsWithCategoryName));
	ddprintf(@"\n");
	
	ddprintf(@"--%@ = %@\n", kGBArgWarnOnMissingOutputPath, PRINT_BOOL(self.settings.warnOnMissingOutputPathArgument));
	ddprintf(@"--%@ = %@\n", kGBArgWarnOnMissingCompanyIdentifier, PRINT_BOOL(self.settings.warnOnMissingCompanyIdentifier));
	ddprintf(@"--%@ = %@\n", kGBArgWarnOnUndocumentedObject, PRINT_BOOL(self.settings.warnOnUndocumentedObject));
	ddprintf(@"--%@ = %@\n", kGBArgWarnOnUndocumentedMember, PRINT_BOOL(self.settings.warnOnUndocumentedMember));
	ddprintf(@"\n");
	
	ddprintf(@"--%@ = %@\n", kGBArgLogFormat, self.logformat);
	ddprintf(@"--%@ = %@\n", kGBArgVerbose, self.verbose);
	ddprintf(@"\n");
}

- (void)printVersion {
	NSString *appledocName = [self.settings.stringTemplates.appledocData objectForKey:@"tool"];
	NSString *appledocVersion = [self.settings.stringTemplates.appledocData objectForKey:@"version"];
	ddprintf(@"%@ version: %@\n", appledocName, appledocVersion);
	ddprintf(@"\n");
}

- (void)printHelp {
#define PRINT_USAGE(short,long,arg,desc) [self printHelpForShortOption:short longOption:long argument:arg description:desc]
	NSString *name = [self.settings.stringTemplates.appledocData objectForKey:@"tool"];
	ddprintf(@"Usage: %@ [OPTIONS] <paths to source dirs or files>\n", name);
	ddprintf(@"\n");
	ddprintf(@"PATHS\n");
	PRINT_USAGE(@"-o,", kGBArgOutputPath, @"<path>", @"Output path");
	PRINT_USAGE(@"-t,", kGBArgTemplatesPath, @"<path>", @"Template files path");
	PRINT_USAGE(@"   ", kGBArgDocSetInstallPath, @"<path>", @"DocSet installation path");
	PRINT_USAGE(@"-i,", kGBArgIgnorePath, @"<path>", @"Ignore given path");
	ddprintf(@"\n");
	ddprintf(@"PROJECT INFO\n");
	PRINT_USAGE(@"-p,", kGBArgProjectName, @"<string>", @"Project name");
	PRINT_USAGE(@"-v,", kGBArgProjectVersion, @"<string>", @"Project version");
	PRINT_USAGE(@"-c,", kGBArgProjectCompany, @"<string>", @"Project company");
	PRINT_USAGE(@"   ", kGBArgCompanyIdentifier, @"<string>", @"Company UTI (i.e. reverse DNS name)");
	ddprintf(@"\n");
	ddprintf(@"OUTPUT GENERATION\n");
	PRINT_USAGE(@"-h,", kGBArgCreateHTML, @"", @"[b] Create HTML");
	PRINT_USAGE(@"-d,", kGBArgCreateDocSet, @"", @"[b] Create documentation set");
	PRINT_USAGE(@"-n,", kGBArgInstallDocSet, @"", @"[b] Install documentation set to Xcode");
	PRINT_USAGE(@"-u,", kGBArgPublishDocSet, @"", @"[b] Prepare DocSet for publishing");
	ddprintf(@"\n");
	ddprintf(@"OPTIONS\n");
	PRINT_USAGE(@"   ", kGBArgKeepIntermediateFiles, @"", @"[b] Keep intermediate files in output path");
	PRINT_USAGE(@"   ", kGBArgKeepUndocumentedObjects, @"", @"[b] Keep undocumented objects");
	PRINT_USAGE(@"   ", kGBArgKeepUndocumentedMembers, @"", @"[b] Keep undocumented members");
	PRINT_USAGE(@"   ", kGBArgFindUndocumentedMembersDocumentation, @"", @"[b] Search undocumented members documentation");
	PRINT_USAGE(@"   ", kGBArgRepeatFirstParagraph, @"", @"[b] Repeat first paragraph in member documentation");
	PRINT_USAGE(@"   ", kGBArgMergeCategoriesToClasses, @"", @"[b] Merge categories to classes");
	PRINT_USAGE(@"   ", kGBArgKeepMergedCategoriesSections, @"", @"[b] Keep merged categories sections");
	PRINT_USAGE(@"   ", kGBArgPrefixMergedCategoriesSectionsWithCategoryName, @"", @"[b] Prefix merged sections with category name");
	ddprintf(@"\n");
	ddprintf(@"WARNINGS\n");
	PRINT_USAGE(@"   ", kGBArgWarnOnMissingOutputPath, @"", @"[b] Warn if output path is not given");
	PRINT_USAGE(@"   ", kGBArgWarnOnMissingCompanyIdentifier, @"", @"[b] Warn if company ID is not given");
	PRINT_USAGE(@"   ", kGBArgWarnOnUndocumentedObject, @"", @"[b] Warn on undocumented object");
	PRINT_USAGE(@"   ", kGBArgWarnOnUndocumentedMember, @"", @"[b] Warn on undocumented member");
	PRINT_USAGE(@"   ", kGBArgWarnOnInvalidCrossReference, @"", @"[b] Warn on invalid cross reference");
	PRINT_USAGE(@"   ", kGBArgWarnOnMissingMethodArgument, @"", @"[b] Warn on missing method argument documentation");
	ddprintf(@"\n");
	ddprintf(@"DOCUMENTATION SET INFO\n");
	PRINT_USAGE(@"   ", kGBArgDocSetBundleIdentifier, @"<string>", @"[*] DocSet bundle identifier");
	PRINT_USAGE(@"   ", kGBArgDocSetBundleName, @"<string>", @"[*] DocSet bundle name");
	PRINT_USAGE(@"   ", kGBArgDocSetDescription, @"<string>", @"[*] DocSet description");
	PRINT_USAGE(@"   ", kGBArgDocSetCopyrightMessage, @"<string>", @"[*] DocSet copyright message");
	PRINT_USAGE(@"   ", kGBArgDocSetFeedName, @"<string>", @"[*] DocSet feed name");
	PRINT_USAGE(@"   ", kGBArgDocSetFeedURL, @"<string>", @"[*] DocSet feed URL");
	PRINT_USAGE(@"   ", kGBArgDocSetPackageURL, @"<string>", @"[*] DocSet package (.xar) URL");
	PRINT_USAGE(@"   ", kGBArgDocSetFallbackURL, @"<string>", @"[*] DocSet fallback URL");
	PRINT_USAGE(@"   ", kGBArgDocSetPublisherIdentifier, @"<string>", @"[*] DocSet publisher identifier");
	PRINT_USAGE(@"   ", kGBArgDocSetPublisherName, @"<string>", @"[*] DocSet publisher name");
	PRINT_USAGE(@"   ", kGBArgDocSetMinimumXcodeVersion, @"<string>", @"[*] DocSet min. Xcode version");
	PRINT_USAGE(@"   ", kGBArgDocSetPlatformFamily, @"<string>", @"[*] DocSet platform familiy");
	PRINT_USAGE(@"   ", kGBArgDocSetCertificateIssuer, @"<string>", @"[*] DocSet certificate issuer");
	PRINT_USAGE(@"   ", kGBArgDocSetCertificateSigner, @"<string>", @"[*] DocSet certificate signer");
	PRINT_USAGE(@"   ", kGBArgDocSetBundleFilename, @"<string>", @"[*] DocSet bundle filename");
	PRINT_USAGE(@"   ", kGBArgDocSetAtomFilename, @"<string>", @"[*] DocSet atom feed filename");
	PRINT_USAGE(@"   ", kGBArgDocSetPackageFilename, @"<string>", @"[*] DocSet package (.xar) filename");
	ddprintf(@"\n");
	ddprintf(@"MISCELLANEOUS\n");
	PRINT_USAGE(@"   ", kGBArgLogFormat, @"<number>", @"Log format [0-3]");
	PRINT_USAGE(@"   ", kGBArgVerbose, @"<number>", @"Log verbosity level [0-6]");
	PRINT_USAGE(@"   ", kGBArgVersion, @"", @"Display version and exit");
	PRINT_USAGE(@"   ", kGBArgHelp, @"", @"Display this help and exit");
	ddprintf(@"\n");
	ddprintf(@"==================================================================\n");
	ddprintf(@"[b] boolean parameter, uses no value, use --no- prefix to negate.\n");
	ddprintf(@"\n");
	ddprintf(@"[*] indicates parameters accepting placeholder strings:\n");
	ddprintf(@"- %%PROJECT replaced with --project-name\n");
	ddprintf(@"- %%PROJECTID replaced with normalized --project-name\n");
	ddprintf(@"- %%VERSION replaced with --project-version\n");
	ddprintf(@"- %%VERSIONID replaced with normalized --project-version\n");
	ddprintf(@"- %%COMPANY replaced with --project-company\n");
	ddprintf(@"- %%COMPANYID replaced with --company-id\n");
	ddprintf(@"- %%YEAR replaced with current year (format yyyy)\n");
	ddprintf(@"- %%UPDATEDATE replaced with current date (format yyyy-MM-dd)\n");
	ddprintf(@"- %%DOCSETBUNDLEFILENAME replaced with --docset-bundle-filename\n");
	ddprintf(@"- %%DOCSETATOMFILENAME replaced with --docset-atom-filename\n");
	ddprintf(@"- %%DOCSETPACKAGEFILENAME replaced with --docset-package-filename\n");	
	ddprintf(@"\n");
	ddprintf(@"==================================================================\n");
	ddprintf(@"Find more help and tips online:\n");
	ddprintf(@"- http://appledoc.gentlebytes.com/\n");
	ddprintf(@"- http://tomaz.github.com/appledoc/\n");
	ddprintf(@"\n");
	ddprintf(@"==================================================================\n");
	ddprintf(@"%@ uses the following open source components, fully or partially:\n", name);
	ddprintf(@"\n");
	ddprintf(@"- DDCli by Dave Dribin\n");
	ddprintf(@"- CocoaLumberjack by Robbie Hanson\n");
	ddprintf(@"- ParseKit by Todd Ditchendorf\n");
	ddprintf(@"- RegexKitLite by John Engelhart\n");
	ddprintf(@"- GRMustache by Gwendal Roué\n");
	ddprintf(@"- Timing functions from Apple examples\n");
	ddprintf(@"\n");
	ddprintf(@"We'd like to thank all authors for their contribution!\n");
}

- (void)printHelpForShortOption:(NSString *)aShort longOption:(NSString *)aLong argument:(NSString *)argument description:(NSString *)description {
	while([aLong length] + [argument length] < 32) argument = [argument stringByAppendingString:@" "];
	ddprintf(@"  %@ --%@ %@ %@\n", aShort, aLong, argument, description);
}

@end

