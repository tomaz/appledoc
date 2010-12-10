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
static NSString *kGBArgIgnorePath = @"ignore";

static NSString *kGBArgProjectName = @"project-name";
static NSString *kGBArgProjectVersion = @"project-version";
static NSString *kGBArgProjectCompany = @"project-company";

static NSString *kGBArgCreateHTML = @"create-html";
static NSString *kGBArgCreateDocSet = @"create-docset";
static NSString *kGBArgInstallDocSet = @"install-docset";
static NSString *kGBArgKeepUndocumentedObjects = @"keep-undocumented-objects";
static NSString *kGBArgKeepUndocumentedMembers = @"keep-undocumented-members";
static NSString *kGBArgFindUndocumentedMembersDocumentation = @"search-undocumented-doc";
static NSString *kGBArgMergeCategoriesToClasses = @"merge-categories";
static NSString *kGBArgKeepMergedCategoriesSections = @"keep-merged-sections";
static NSString *kGBArgPrefixMergedCategoriesSectionsWithCategoryName = @"prefix-merged-sections";

static NSString *kGBArgWarnOnUndocumentedObject = @"warn-undocumented-object";
static NSString *kGBArgWarnOnUndocumentedMember = @"warn-undocumented-member";

static NSString *kGBArgDocSetBundleIdentifier = @"docset-bundle-id";
static NSString *kGBArgDocSetBundleName = @"docset-bundle-name";
static NSString *kGBArgDocSetDescription = @"docset-desc";
static NSString *kGBArgDocSetCopyrightMessage = @"docset-copyright";
static NSString *kGBArgDocSetFeedName = @"docset-feed-name";
static NSString *kGBArgDocSetFeedURL = @"docset-feed-url";
static NSString *kGBArgDocSetFallbackURL = @"docset-fallback-url";
static NSString *kGBArgDocSetPublisherIdentifier = @"docset-publisher-id";
static NSString *kGBArgDocSetPublisherName = @"docset-publisher-name";
static NSString *kGBArgDocSetMinimumXcodeVersion = @"docset-min-xcode-version";
static NSString *kGBArgDocSetPlatformFamily = @"docset-platform-family";
static NSString *kGBArgDocSetCertificateIssuer = @"docset-cert-issuer";
static NSString *kGBArgDocSetCertificateSigner = @"docset-cert-signer";

static NSString *kGBArgLogFormat = @"logformat";
static NSString *kGBArgVerbose = @"verbose";
static NSString *kGBArgVersion = @"version";
static NSString *kGBArgHelp = @"help";

#define GBNoArg(arg) [NSString stringWithFormat:@"no-%@", arg]

#pragma mark -

@interface GBAppledocApplication ()

- (void)initializeLoggingSystem;
- (void)validateArguments:(NSArray *)arguments;
@property (readwrite, retain) GBApplicationSettingsProvider *settings;
@property (assign) NSString *logformat;
@property (assign) NSString *verbose;
@property (assign) BOOL version;
@property (assign) BOOL help;
@property (assign) BOOL testargs;

@end

#pragma mark -

@interface GBAppledocApplication (UsagePrintout)

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
	
	@try {		
		[self validateArguments:arguments];
		[self.settings replaceAllOccurencesOfPlaceholderStringsInSettingsValues];
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
		
		{ kGBArgProjectName,												'p',	DDGetoptRequiredArgument },
		{ kGBArgProjectVersion,												'v',	DDGetoptRequiredArgument },
		{ kGBArgProjectCompany,												'c',	DDGetoptRequiredArgument },
		
		{ kGBArgDocSetBundleIdentifier,										0,		DDGetoptRequiredArgument },
		{ kGBArgDocSetBundleName,											0,		DDGetoptRequiredArgument },
		{ kGBArgDocSetCertificateIssuer,									0,		DDGetoptRequiredArgument },
		{ kGBArgDocSetCertificateSigner,									0,		DDGetoptRequiredArgument },
		{ kGBArgDocSetDescription,											0,		DDGetoptRequiredArgument },
		{ kGBArgDocSetFallbackURL,											0,		DDGetoptRequiredArgument },
		{ kGBArgDocSetFeedName,												0,		DDGetoptRequiredArgument },
		{ kGBArgDocSetFeedURL,												0,		DDGetoptRequiredArgument },
		{ kGBArgDocSetMinimumXcodeVersion,									0,		DDGetoptRequiredArgument },
		{ kGBArgDocSetPlatformFamily,										0,		DDGetoptRequiredArgument },
		{ kGBArgDocSetPublisherIdentifier,									0,		DDGetoptRequiredArgument },
		{ kGBArgDocSetPublisherName,										0,		DDGetoptRequiredArgument },
		{ kGBArgDocSetCopyrightMessage,										0,		DDGetoptRequiredArgument },
		
		{ kGBArgCreateHTML,													'h',	DDGetoptNoArgument },
		{ kGBArgCreateDocSet,												'd',	DDGetoptNoArgument },
		{ kGBArgInstallDocSet,												'n',	DDGetoptNoArgument },
		{ GBNoArg(kGBArgCreateHTML),										0,		DDGetoptNoArgument },
		{ GBNoArg(kGBArgCreateDocSet),										0,		DDGetoptNoArgument },
		{ GBNoArg(kGBArgInstallDocSet),										0,		DDGetoptNoArgument },
		
		{ kGBArgKeepUndocumentedObjects,									0,		DDGetoptNoArgument },
		{ kGBArgKeepUndocumentedMembers,									0,		DDGetoptNoArgument },
		{ kGBArgFindUndocumentedMembersDocumentation,						0,		DDGetoptNoArgument },
		{ kGBArgMergeCategoriesToClasses,									0,		DDGetoptNoArgument },
		{ kGBArgKeepMergedCategoriesSections,								0,		DDGetoptNoArgument },
		{ kGBArgPrefixMergedCategoriesSectionsWithCategoryName,				0,		DDGetoptNoArgument },
		{ GBNoArg(kGBArgKeepUndocumentedObjects),							0,		DDGetoptNoArgument },
		{ GBNoArg(kGBArgKeepUndocumentedMembers),							0,		DDGetoptNoArgument },
		{ GBNoArg(kGBArgFindUndocumentedMembersDocumentation),				0,		DDGetoptNoArgument },
		{ GBNoArg(kGBArgMergeCategoriesToClasses),							0,		DDGetoptNoArgument },
		{ GBNoArg(kGBArgKeepMergedCategoriesSections),						0,		DDGetoptNoArgument },
		{ GBNoArg(kGBArgPrefixMergedCategoriesSectionsWithCategoryName),	0,		DDGetoptNoArgument },
		
		{ kGBArgWarnOnUndocumentedObject,									0,		DDGetoptNoArgument },
		{ kGBArgWarnOnUndocumentedMember,									0,		DDGetoptNoArgument },
		{ GBNoArg(kGBArgWarnOnUndocumentedObject),							0,		DDGetoptNoArgument },
		{ GBNoArg(kGBArgWarnOnUndocumentedMember),							0,		DDGetoptNoArgument },
		
		{ kGBArgLogFormat,													0,		DDGetoptRequiredArgument },
		{ kGBArgVerbose,													0,		DDGetoptRequiredArgument },
		{ kGBArgVersion,													0,		DDGetoptNoArgument },
		{ kGBArgHelp,														0,		DDGetoptNoArgument },
		{ nil,																0,		0 },
	};
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

- (void)validateArguments:(NSArray *)arguments {
	if ([arguments count] == 0) [NSException raise:@"At least one argument is required"];
	for (NSString *path in arguments) {
		if (![self.fileManager fileExistsAtPath:path]) {
			[NSException raise:@"Path or file '%@' doesn't exist!", path];
		}
	}
}

#pragma mark Overriden methods

- (NSString *)description {
	return [self className];
}

#pragma mark Callbacks API for DDCliApplication

- (void)setOutput:(NSString *)path { self.settings.outputPath = path; }
- (void)setTemplates:(NSString *)path { self.settings.templatesPath = path; }
- (void)setDocsetInstallPath:(NSString *)path { self.settings.docsetInstallPath = path; }
- (void)setIgnore:(NSString *)path {
	if ([path hasPrefix:@"*"]) path = [path substringFromIndex:1];
	[self.settings.ignoredPaths addObject:path];
}

- (void)setProjectName:(NSString *)value { self.settings.projectName = value; }
- (void)setProjectVersion:(NSString *)value { self.settings.projectVersion = value; }
- (void)setProjectCompany:(NSString *)value { self.settings.projectCompany  =value; }

- (void)setCreateHtml:(BOOL)value { self.settings.createHTML = value; }
- (void)setCreateDocset:(BOOL)value { self.settings.createDocSet = value; }
- (void)setInstallDocset:(BOOL)value { self.settings.installDocSet = value; }
- (void)setNoCreateHtml:(BOOL)value { self.settings.createHTML = !value; }
- (void)setNoCreateDocset:(BOOL)value { self.settings.createDocSet = !value; }
- (void)setNoInstallDocset:(BOOL)value { self.settings.installDocSet = !value; }

- (void)setKeepUndocumentedObjects:(BOOL)value { self.settings.keepUndocumentedObjects = value; }
- (void)setKeepUndocumentedMembers:(BOOL)value { self.settings.keepUndocumentedMembers = value; }
- (void)setSearchUndocumentedDoc:(BOOL)value { self.settings.findUndocumentedMembersDocumentation = value; }
- (void)setMergeCategories:(BOOL)value { self.settings.mergeCategoriesToClasses = value; }
- (void)setKeepMergedSections:(BOOL)value { self.settings.keepMergedCategoriesSections = value; }
- (void)setPrefixMergedSections:(BOOL)value { self.settings.prefixMergedCategoriesSectionsWithCategoryName = value; }
- (void)setNoKeepUndocumentedObjects:(BOOL)value { self.settings.keepUndocumentedObjects = !value; }
- (void)setNoKeepUndocumentedMembers:(BOOL)value { self.settings.keepUndocumentedMembers = !value; }
- (void)setNoSearchUndocumentedDoc:(BOOL)value { self.settings.findUndocumentedMembersDocumentation = !value; }
- (void)setNoMergeCategories:(BOOL)value { self.settings.mergeCategoriesToClasses = !value; }
- (void)setNoKeepMergedSections:(BOOL)value { self.settings.keepMergedCategoriesSections = !value; }
- (void)setNoPrefixMergedSections:(BOOL)value { self.settings.prefixMergedCategoriesSectionsWithCategoryName = !value; }

- (void)setWarnUndocumentedObject:(BOOL)value { self.settings.warnOnUndocumentedObject = value; }
- (void)setWarnUndocumentedMember:(BOOL)value { self.settings.warnOnUndocumentedMember = value; }
- (void)setNoWarnUndocumentedObject:(BOOL)value { self.settings.warnOnUndocumentedObject = !value; }
- (void)setNoWarnUndocumentedMember:(BOOL)value { self.settings.warnOnUndocumentedMember = !value; }

- (void)setDocsetBundleId:(NSString *)value { self.settings.docsetBundleIdentifier = value; }
- (void)setDocsetBundleName:(NSString *)value { self.settings.docsetBundleName = value; }
- (void)setDocsetDesc:(NSString *)value { self.settings.docsetDescription = value; }
- (void)setDocsetCopyright:(NSString *)value { self.settings.docsetCopyrightMessage = value; }
- (void)setDocsetFeedName:(NSString *)value { self.settings.docsetFeedName = value; }
- (void)setDocsetFeedUrl:(NSString *)value { self.settings.docsetFeedURL = value; }
- (void)setDocsetFallbackUrl:(NSString *)value { self.settings.docsetFallbackURL = value; }
- (void)setDocsetPublisherId:(NSString *)value { self.settings.docsetPublisherIdentifier = value; }
- (void)setDocsetPublisherName:(NSString *)value { self.settings.docsetPublisherName = value; }
- (void)setDocsetMinXcodeVersion:(NSString *)value { self.settings.docsetMinimumXcodeVersion = value; }
- (void)setDocsetPlatformFamily:(NSString *)value { self.settings.docsetPlatformFamily = value; }
- (void)setDocsetCertIssuer:(NSString *)value { self.settings.docsetCertificateIssuer = value; }
- (void)setDocsetCertSigner:(NSString *)value { self.settings.docsetCertificateSigner = value; }

@synthesize logformat;
@synthesize verbose;
@synthesize version;
@synthesize help;

#pragma mark Properties

@synthesize settings;

@end

#pragma mark -

@implementation GBAppledocApplication (UsagePrintout)

- (void)printVersion {
	ddprintf(@"%@ version: %@\n", DDCliApp, @"2.0 pre-alpha");
}

- (void)printHelp {
#define PRINT_USAGE(short,long,arg,desc) [self printHelpForShortOption:short longOption:long argument:arg description:desc]
	ddprintf(@"Usage: %@ [OPTIONS] <paths to source dirs or files>\n", DDCliApp);
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
	ddprintf(@"\n");
	ddprintf(@"OUTPUT GENERATION\n");
	PRINT_USAGE(@"-h,", kGBArgCreateHTML, @"<bool>", @"Create HTML");
	PRINT_USAGE(@"-d,", kGBArgCreateDocSet, @"<bool>", @"Create HTML and documentation set");
	PRINT_USAGE(@"-n,", kGBArgInstallDocSet, @"<bool>", @"Create HTML & DocSet and install DocSet to Xcode");
	ddprintf(@"\n");
	ddprintf(@"OPTIONS\n");
	PRINT_USAGE(@"   ", kGBArgKeepUndocumentedObjects, @"<bool>", @"Keep undocumented objects");
	PRINT_USAGE(@"   ", kGBArgKeepUndocumentedMembers, @"<bool>", @"Keep undocumented members");
	PRINT_USAGE(@"   ", kGBArgFindUndocumentedMembersDocumentation, @"<bool>", @"Search undocumented members documentation");
	PRINT_USAGE(@"   ", kGBArgMergeCategoriesToClasses, @"<bool>", @"Merge categories to classes");
	PRINT_USAGE(@"   ", kGBArgKeepMergedCategoriesSections, @"<bool>", @"Keep merged categories sections");
	PRINT_USAGE(@"   ", kGBArgPrefixMergedCategoriesSectionsWithCategoryName, @"<bool>", @"Prefix merged sections with category name");
	ddprintf(@"\n");
	ddprintf(@"WARNINGS\n");
	PRINT_USAGE(@"   ", kGBArgWarnOnUndocumentedObject, @"<bool>", @"Warn on undocumented object");
	PRINT_USAGE(@"   ", kGBArgWarnOnUndocumentedMember, @"<bool>", @"Warn on undocumented member");
	ddprintf(@"\n");
	ddprintf(@"DOCUMENTATION SET INFO\n");
	PRINT_USAGE(@"   ", kGBArgDocSetBundleIdentifier, @"<string>", @"DocSet bundle identifier");
	PRINT_USAGE(@"   ", kGBArgDocSetBundleName, @"<string>", @"DocSet bundle name");
	PRINT_USAGE(@"   ", kGBArgDocSetDescription, @"<string>", @"DocSet description");
	PRINT_USAGE(@"   ", kGBArgDocSetCopyrightMessage, @"<string>", @"DocSet copyright message");
	PRINT_USAGE(@"   ", kGBArgDocSetFeedName, @"<string>", @"DocSet feed name");
	PRINT_USAGE(@"   ", kGBArgDocSetFeedURL, @"<string>", @"DocSet feed URL");
	PRINT_USAGE(@"   ", kGBArgDocSetFallbackURL, @"<string>", @"DocSet fallback URL");
	PRINT_USAGE(@"   ", kGBArgDocSetPublisherIdentifier, @"<string>", @"DocSet publisher identifier");
	PRINT_USAGE(@"   ", kGBArgDocSetPublisherName, @"<string>", @"DocSet publisher name");
	PRINT_USAGE(@"   ", kGBArgDocSetMinimumXcodeVersion, @"<string>", @"DocSet min. Xcode version");
	PRINT_USAGE(@"   ", kGBArgDocSetPlatformFamily, @"<string>", @"DocSet platform familiy");
	PRINT_USAGE(@"   ", kGBArgDocSetCertificateIssuer, @"<string>", @"DocSet certificate issuer");
	PRINT_USAGE(@"   ", kGBArgDocSetCertificateSigner, @"<string>", @"DocSet certificate signer");
	ddprintf(@"\n");
	ddprintf(@"MISCELLANEOUS\n");
	PRINT_USAGE(@"   ", kGBArgLogFormat, @"<format>", @"Log format [0-3]");
	PRINT_USAGE(@"   ", kGBArgVerbose, @"<level>", @"Log verbosity level [0-6]");
	PRINT_USAGE(@"   ", kGBArgVersion, @"", @"Display version and exit");
	PRINT_USAGE(@"   ", kGBArgHelp, @"", @"Display this help and exit");
	ddprintf(@"\n");
	ddprintf(@"appledoc uses the following open source components, fully or partially:\n");
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

