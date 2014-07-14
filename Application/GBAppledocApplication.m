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
#import "DDXcodeProjectFile.h"
#import "DDEmbeddedDataReader.h"
#import "DDZipReader.h"

static char *kGBArgInputPath = "input";
static char *kGBArgOutputPath = "output";
static char *kGBArgTemplatesPath = "templates";
static char *kGBArgDocSetInstallPath = "docset-install-path";
static char *kGBArgXcrunPath = "xcrun-path";
static char *kGBArgIndexDescPath = "index-desc";
static char *kGBArgIncludePath = "include";
static char *kGBArgIgnorePath = "ignore";
static char *kGBArgExcludeOutputPath = "exclude-output";

static char *kGBArgProjectName = "project-name";
static char *kGBArgProjectVersion = "project-version";
static char *kGBArgProjectCompany = "project-company";
static char *kGBArgCompanyIdentifier = "company-id";

static char *kGBArgCleanOutput = "clean-output";
static char *kGBArgCreateHTML = "create-html";
static char *kGBArgCreateDocSet = "create-docset";
static char *kGBArgFinalizeDocSet = "finalize-docset";
static char *kGBArgInstallDocSet = "install-docset";
static char *kGBArgPublishDocSet = "publish-docset";
static char *kGBArgHTMLAnchorFormat = "html-anchors";
static char *kGBArgKeepIntermediateFiles = "keep-intermediate-files";
static char *kGBArgExitCodeThreshold = "exit-threshold";

static char *kGBArgRepeatFirstParagraph = "repeat-first-par";
static char *kGBArgPreprocessHeaderDoc = "preprocess-headerdoc";
static char *kGBArgPrintInformationBlockTitles = "print-information-block-titles";
static char *kGBArgUseSingleStar = "use-single-star";
static char *kGBArgKeepUndocumentedObjects = "keep-undocumented-objects";
static char *kGBArgKeepUndocumentedMembers = "keep-undocumented-members";
static char *kGBArgFindUndocumentedMembersDocumentation = "search-undocumented-doc";
static char *kGBArgMergeCategoriesToClasses = "merge-categories";
static char *kGBArgMergeCategoryComment = "merge-category-comment";
static char *kGBArgKeepMergedCategoriesSections = "keep-merged-sections";
static char *kGBArgPrefixMergedCategoriesSectionsWithCategoryName = "prefix-merged-sections";
static char *kGBArgUseCodeOrder = "use-code-order";

static char *kGBArgExplicitCrossRef = "explicit-crossref";
static char *kGBArgCrossRefFormat = "crossref-format";

static char *kGBArgWarnOnMissingOutputPath = "warn-missing-output-path";
static char *kGBArgWarnOnMissingCompanyIdentifier = "warn-missing-company-id";
static char *kGBArgWarnOnUndocumentedObject = "warn-undocumented-object";
static char *kGBArgWarnOnUndocumentedMember = "warn-undocumented-member";
static char *kGBArgWarnOnEmptyDescription = "warn-empty-description";
static char *kGBArgWarnOnUnknownDirective = "warn-unknown-directive";
static char *kGBArgWarnOnInvalidCrossReference = "warn-invalid-crossref";
static char *kGBArgWarnOnMissingMethodArgument = "warn-missing-arg";

static char *kGBArgDocSetBundleIdentifier = "docset-bundle-id";
static char *kGBArgDocSetBundleName = "docset-bundle-name";
static char *kGBArgDocSetDescription = "docset-desc";
static char *kGBArgDocSetCopyrightMessage = "docset-copyright";
static char *kGBArgDocSetFeedName = "docset-feed-name";
static char *kGBArgDocSetFeedURL = "docset-feed-url";
static char *kGBArgDocSetFeedFormats = "docset-feed-formats";
static char *kGBArgDocSetPackageURL = "docset-package-url";
static char *kGBArgDocSetFallbackURL = "docset-fallback-url";
static char *kGBArgDocSetPublisherIdentifier = "docset-publisher-id";
static char *kGBArgDocSetPublisherName = "docset-publisher-name";
static char *kGBArgDocSetMinimumXcodeVersion = "docset-min-xcode-version";
static char *kGBArgDashPlatformFamily = "dash-platform-family";
static char *kGBArgDocSetPlatformFamily = "docset-platform-family";
static char *kGBArgDocSetCertificateIssuer = "docset-cert-issuer";
static char *kGBArgDocSetCertificateSigner = "docset-cert-signer";

static char *kGBArgDocSetBundleFilename = "docset-bundle-filename";
static char *kGBArgDocSetAtomFilename = "docset-atom-filename";
static char *kGBArgDocSetXMLFilename = "docset-xml-filename";
static char *kGBArgDocSetPackageFilename = "docset-package-filename";

static char *kGBArgLogFormat = "logformat";
static char *kGBArgVerbose = "verbose";
static char *kGBArgPrintSettings = "print-settings";
static char *kGBArgVersion = "version";
static char *kGBArgHelp = "help";

#define GBNoArg(arg) (char*)[[NSString stringWithFormat:@"no-%s", arg] UTF8String]
#define GBArgToNSString(arg) [NSString stringWithUTF8String:arg]

#pragma mark -

@interface GBAppledocApplication ()

- (void)initializeLoggingSystem;
- (void)deleteContentsOfOutputPath;
- (void)validateSettingsAndArguments:(NSArray *)arguments;
- (NSString *)standardizeCurrentDirectoryForPath:(NSString *)path;
- (NSString *)combineBasePath:(NSString *)base withRelativePath:(NSString *)path;

- (void)injectXcodeSettingsFromArguments:(NSArray *)arguments;
- (void)injectGlobalSettingsFromArguments:(NSArray *)arguments;
- (void)injectProjectSettingsFromArguments:(NSArray *)arguments;
- (void)overrideSettingsWithGlobalSettingsFromPath:(NSString *)path;
- (void)injectSettingsFromSettingsFile:(NSString *)path usingBlock:(BOOL (^)(NSString *option, id *value, BOOL *stop))block;
- (BOOL)validateTemplatesPath:(NSString *)path error:(NSError **)error;

@property (readwrite, strong) GBApplicationSettingsProvider *settings;
@property (strong) NSMutableArray *additionalInputPaths;
@property (strong) NSMutableArray *ignoredInputPaths;
@property (weak) NSString *logformat;
@property (weak) NSString *verbose;
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
		self.settings = [GBApplicationSettingsProvider sharedApplicationSettingsProvider];
		self.additionalInputPaths = [NSMutableArray array];
		self.ignoredInputPaths = [NSMutableArray array];
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
		return GBEXIT_SUCCESS;
	}
	if (self.version) {
		[self printVersion];
		return GBEXIT_SUCCESS;
	}

	// Prepare actual input paths by adding all paths from project settings and removing all plist paths.
	NSMutableArray *inputs = [NSMutableArray array];
	[inputs addObjectsFromArray:arguments];
	[inputs addObjectsFromArray:self.additionalInputPaths];
	[inputs removeObjectsInArray:self.ignoredInputPaths];
	
	[self printVersion];
	[self validateSettingsAndArguments:inputs];
	[self.settings replaceAllOccurencesOfPlaceholderStringsInSettingsValues];
	if (self.printSettings) [self printSettingsAndArguments:inputs];
	kGBLogBasedResult = GBEXIT_SUCCESS;

	@try {
		[self initializeLoggingSystem];
		[self deleteContentsOfOutputPath];
		
		GBLogNormal(@"Initializing...");
		GBStore *store = [[GBStore alloc] init];
		GBAbsoluteTime startTime = GetCurrentTime();
		
		GBLogNormal(@"Parsing source files...");
		GBParser *parser = [GBParser parserWithSettingsProvider:self.settings];
		[parser parseObjectsFromPaths:inputs toStore:store];
		[parser parseDocumentsFromPaths:[self.settings.includePaths allObjects] toStore:store];
		[parser parseCustomDocumentFromPath:self.settings.indexDescriptionPath outputSubpath:@"" key:kGBCustomDocumentIndexDescKey toStore:store];
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
		return GBEXIT_ASSERT_GENERIC;
	}
	
	int result = (kGBLogBasedResult >= self.settings.exitCodeThreshold) ? kGBLogBasedResult : 0;
	GBLogDebug(@"Exiting with result %d (reported result was %ld - higher than %d)...", result, kGBLogBasedResult, self.settings.exitCodeThreshold);
	return result;
}

- (void)application:(DDCliApplication *)app willParseOptions:(DDGetoptLongParser *)optionParser {
	DDGetoptOption options[] = {
		{ kGBArgOutputPath,													'o',	DDGetoptRequiredArgument },
		{ kGBArgTemplatesPath,												't',	DDGetoptRequiredArgument },
		{ kGBArgIgnorePath,													'i',	DDGetoptRequiredArgument },
		{ kGBArgExcludeOutputPath,											'x',	DDGetoptRequiredArgument },
		{ kGBArgIncludePath,												's',	DDGetoptRequiredArgument },
		{ kGBArgIndexDescPath,												0,		DDGetoptRequiredArgument },
		{ kGBArgDocSetInstallPath,											0,		DDGetoptRequiredArgument },
		{ kGBArgXcrunPath,                                                  0,		DDGetoptRequiredArgument },
		
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
        { kGBArgDocSetFeedFormats,                                          0,      DDGetoptRequiredArgument },
		{ kGBArgDocSetPackageURL,											0,		DDGetoptRequiredArgument },
		{ kGBArgDocSetMinimumXcodeVersion,									0,		DDGetoptRequiredArgument },
		{ kGBArgDocSetPlatformFamily,										0,		DDGetoptRequiredArgument },
		{ kGBArgDocSetPublisherIdentifier,									0,		DDGetoptRequiredArgument },
		{ kGBArgDocSetPublisherName,										0,		DDGetoptRequiredArgument },
		{ kGBArgDocSetCopyrightMessage,										0,		DDGetoptRequiredArgument },
		{ kGBArgDashPlatformFamily,											0,		DDGetoptRequiredArgument },
		
		{ kGBArgDocSetBundleFilename,										0,		DDGetoptRequiredArgument },
		{ kGBArgDocSetAtomFilename,											0,		DDGetoptRequiredArgument },
        { kGBArgDocSetXMLFilename,                                          0,      DDGetoptRequiredArgument },
		{ kGBArgDocSetPackageFilename,										0,		DDGetoptRequiredArgument },
		
		{ kGBArgCleanOutput,												0,		DDGetoptNoArgument },
		{ kGBArgCreateHTML,													'h',	DDGetoptNoArgument },
		{ kGBArgCreateDocSet,												'd',	DDGetoptNoArgument },
		{ kGBArgFinalizeDocSet,												0,	DDGetoptNoArgument },
		{ kGBArgInstallDocSet,												'n',	DDGetoptNoArgument },
		{ kGBArgPublishDocSet,												'u',	DDGetoptNoArgument },
        { kGBArgHTMLAnchorFormat,                                           0,      DDGetoptRequiredArgument },
		{ GBNoArg(kGBArgCreateHTML),										0,		DDGetoptNoArgument },
		{ GBNoArg(kGBArgCreateDocSet),										0,		DDGetoptNoArgument },
		{ GBNoArg(kGBArgInstallDocSet),										0,		DDGetoptNoArgument },
		{ GBNoArg(kGBArgPublishDocSet),										0,		DDGetoptNoArgument },
		
		{ kGBArgCrossRefFormat,												0,		DDGetoptRequiredArgument },
		{ kGBArgExplicitCrossRef,											0,		DDGetoptNoArgument },
		{ GBNoArg(kGBArgExplicitCrossRef),									0,		DDGetoptNoArgument },
		
		{ kGBArgKeepIntermediateFiles,										0,		DDGetoptNoArgument },
		{ kGBArgKeepUndocumentedObjects,									0,		DDGetoptNoArgument },
		{ kGBArgKeepUndocumentedMembers,									0,		DDGetoptNoArgument },
		{ kGBArgFindUndocumentedMembersDocumentation,						0,		DDGetoptNoArgument },
		{ kGBArgRepeatFirstParagraph,										0,		DDGetoptNoArgument },
		{ kGBArgPreprocessHeaderDoc,										0,		DDGetoptNoArgument },
		{ kGBArgPrintInformationBlockTitles,								0,		DDGetoptNoArgument },
		{ GBNoArg(kGBArgPrintInformationBlockTitles),						0,		DDGetoptNoArgument },
		{ kGBArgUseSingleStar,												0,		DDGetoptNoArgument },
		{ kGBArgMergeCategoriesToClasses,									0,		DDGetoptNoArgument },
		{ kGBArgMergeCategoryComment,										0,		DDGetoptNoArgument },
		{ kGBArgKeepMergedCategoriesSections,								0,		DDGetoptNoArgument },
		{ kGBArgPrefixMergedCategoriesSectionsWithCategoryName,				0,		DDGetoptNoArgument },
    	{ kGBArgUseCodeOrder,                                               0,		DDGetoptNoArgument },
		{ kGBArgExitCodeThreshold,											0,		DDGetoptRequiredArgument },
		{ GBNoArg(kGBArgKeepIntermediateFiles),								0,		DDGetoptNoArgument },
		{ GBNoArg(kGBArgKeepUndocumentedObjects),							0,		DDGetoptNoArgument },
		{ GBNoArg(kGBArgKeepUndocumentedMembers),							0,		DDGetoptNoArgument },
		{ GBNoArg(kGBArgFindUndocumentedMembersDocumentation),				0,		DDGetoptNoArgument },
		{ GBNoArg(kGBArgRepeatFirstParagraph),								0,		DDGetoptNoArgument },
		{ GBNoArg(kGBArgMergeCategoriesToClasses),							0,		DDGetoptNoArgument },
		{ GBNoArg(kGBArgMergeCategoryComment),								0,		DDGetoptNoArgument },
		{ GBNoArg(kGBArgKeepMergedCategoriesSections),						0,		DDGetoptNoArgument },
		{ GBNoArg(kGBArgPrefixMergedCategoriesSectionsWithCategoryName),	0,		DDGetoptNoArgument },
        { GBNoArg(kGBArgUseCodeOrder),	                                    0,		DDGetoptNoArgument },
		
		{ kGBArgWarnOnMissingOutputPath,									0,		DDGetoptNoArgument },
		{ kGBArgWarnOnMissingCompanyIdentifier,								0,		DDGetoptNoArgument },
		{ kGBArgWarnOnUndocumentedObject,									0,		DDGetoptNoArgument },
		{ kGBArgWarnOnUndocumentedMember,									0,		DDGetoptNoArgument },
		{ kGBArgWarnOnEmptyDescription,										0,		DDGetoptNoArgument },
		{ kGBArgWarnOnUnknownDirective,										0,		DDGetoptNoArgument },
		{ kGBArgWarnOnInvalidCrossReference,								0,		DDGetoptNoArgument },
		{ kGBArgWarnOnMissingMethodArgument,								0,		DDGetoptNoArgument },
		{ GBNoArg(kGBArgWarnOnMissingOutputPath),							0,		DDGetoptNoArgument },
		{ GBNoArg(kGBArgWarnOnMissingCompanyIdentifier),					0,		DDGetoptNoArgument },
		{ GBNoArg(kGBArgWarnOnUndocumentedObject),							0,		DDGetoptNoArgument },
		{ GBNoArg(kGBArgWarnOnUndocumentedMember),							0,		DDGetoptNoArgument },
		{ GBNoArg(kGBArgWarnOnEmptyDescription),							0,		DDGetoptNoArgument },
		{ GBNoArg(kGBArgWarnOnUnknownDirective),							0,		DDGetoptNoArgument },
		{ GBNoArg(kGBArgWarnOnInvalidCrossReference),						0,		DDGetoptNoArgument },
		{ GBNoArg(kGBArgWarnOnMissingMethodArgument),						0,		DDGetoptNoArgument },
		
		{ kGBArgLogFormat,													0,		DDGetoptRequiredArgument },
		{ kGBArgVerbose,													0,		DDGetoptRequiredArgument },
		{ kGBArgPrintSettings,												0,		DDGetoptNoArgument },
		{ kGBArgVersion,													0,		DDGetoptNoArgument },
		{ kGBArgHelp,														0,		DDGetoptNoArgument },
		{ nil,																0,		0 },
	};
	NSArray *arguments = [[NSProcessInfo processInfo] arguments];
    [self injectXcodeSettingsFromArguments:arguments];
	[self injectGlobalSettingsFromArguments:arguments];
	[self injectProjectSettingsFromArguments:arguments];
	[optionParser addOptionsFromTable:options];
}

#pragma mark Application handling

- (void)initializeLoggingSystem {
	id formatter = [GBLog logFormatterForLogFormat:self.logformat];
	[[GBConsoleLogger sharedInstance] setLogFormatter:formatter];
	[DDLog addLogger:[GBConsoleLogger sharedInstance]];
	[GBLog setLogLevelFromVerbose:self.verbose];
}

- (void)deleteContentsOfOutputPath {
	// Removes all files from output path to have a clean start. Although this is not necessary from functionality point of view, it makes the tool less confusing as output only contains files generated by this run. This is sent after initializing logging system, so we can use logging. Note that in case cleanup fails, we simply warn and continue; it the rest of the steps succeed, we can leave everything.
	if (!self.settings.cleanupOutputPathBeforeRunning) return;
	
	NSString *outputPath = self.settings.outputPath;
	NSString *standardizedOutput = [outputPath stringByStandardizingPath];
	NSError *error = nil;
	
	GBLogInfo(@"Deleting contents of output path '%@'...", outputPath);
	NSArray *contents = [self.fileManager contentsOfDirectoryAtPath:standardizedOutput error:&error];
	if (error) {
		GBLogNSError(error, @"Failed enumerating contents of output path '%@'!, for cleaning up!", outputPath);
		return;
	}
	
	for (NSString *subpath in contents) {
		GBLogDebug(@"- Deleting '%@'...", subpath);
		NSString *filename = [standardizedOutput stringByAppendingPathComponent:subpath];
		if (![self.fileManager removeItemAtPath:filename error:&error] && error) {
			GBLogNSError(error, @"Failed removing '%@' while cleaning up output!", filename);
		}
	}
}

- (void)validateSettingsAndArguments:(NSArray *)arguments {
	// Validate we have valid templates path - we use the value of the templatesFound set within initializeGlobalSettingsAndValidateTemplates. We can't simply raise exception there because that message is sent before handling help or version; so we would be required to provide valid templates path even if we just wanted "appledoc --help". As this message is sent afterwards, we can raise exception here. Not as elegant, but needed.
	if (!self.templatesFound) {
		[NSException raise:@"No predefined templates path exists and no template path specified from command line!"];
	}
    
    if ([[NSScanner scannerWithString:self.verbose] scanInt:NULL] == false)
    {
        [NSException raise:@"--%s argument or global setting must be numeric!", kGBArgVerbose];
    }
	
	// Validate we have at least one argument specifying the path to the files to handle. Also validate all given paths are valid.
	if ([arguments count] == 0) [NSException raise:@"At least one directory or file name path is required, use 'appledoc --help'"];
	for (NSString *path in arguments) {
		if (![self.fileManager fileExistsAtPath:[path stringByStandardizingPath]]) {
			[NSException raise:@"Path or file '%@' doesn't exist!", path];
		}
	}
	
	// Now validate we have all required settings specified.
	if ([self.settings.projectName length] == 0) [NSException raise:@"--%s argument or global setting is required!", kGBArgProjectName];
	if ([self.settings.projectCompany length] == 0) [NSException raise:@"--%s argument or global setting is required!", kGBArgProjectCompany];
	
	// If output path is not given, revert to current path, but do warn the user.
	if ([self.settings.outputPath length] == 0) {
		self.settings.cleanupOutputPathBeforeRunning = NO;
		self.settings.outputPath = [self.fileManager currentDirectoryPath];
		if (self.settings.warnOnMissingOutputPathArgument) {
			ddprintf(@"WARN: --%s argument or global setting not given, will output to current dir '%@'!\n", kGBArgOutputPath, self.settings.outputPath);
		}
	}
	
	// If company identifier is not given and we have docset enabled, prepare one from company name, but do warn the user.
	if (self.settings.createDocSet && [self.settings.companyIdentifier length] == 0) {
		NSString *value = [NSString stringWithFormat:@"com.%@.%@", self.settings.projectCompany, self.settings.projectName];
		value = [value stringByReplacingOccurrencesOfString:@" " withString:@""];
		value = [value lowercaseString];
		self.settings.companyIdentifier = value;
		if (self.settings.warnOnMissingCompanyIdentifier) {
			ddprintf(@"WARN: --%s argument or global setting not given, but creating DocSet is enabled, will use '%@'!\n", kGBArgCompanyIdentifier, self.settings.companyIdentifier);
		}
	}
	
	// If any of the include paths isn't valid, warn.
	[self.settings.includePaths enumerateObjectsUsingBlock:^(NSString *userPath, BOOL *stop) {
		NSString *path = [userPath stringByStandardizingPath];
		if (![self.fileManager fileExistsAtPath:path]) {
			ddprintf(@"WARN: --%s path '%@' doesn't exist, ignoring!\n", kGBArgIncludePath, userPath);
		}
	}];
	
	// If index description path is given but doesn't point to an existing file, warn.
	if ([self.settings.indexDescriptionPath length] > 0) {
		BOOL isDir;
		NSString *path = [self.settings.indexDescriptionPath stringByStandardizingPath];
		if (![self.fileManager fileExistsAtPath:path isDirectory:&isDir])
			ddprintf(@"WARN: --%s path '%@' doesn't exist, ignoring!\n", kGBArgIndexDescPath, self.settings.indexDescriptionPath);
		else if (isDir)
			ddprintf(@"WARN: --%s path '%@' is a directory, file is required, ignoring!\n", kGBArgIndexDescPath, self.settings.indexDescriptionPath);
	}
	
	// If we're using backwards compatibility mode, warn about potential incompatibility with Markdown!
	if (self.settings.useSingleStarForBold) {
		ddprintf(@"WARN: --%s may cause incompatibility with Markdown (* unordered lists etc.)", kGBArgUseSingleStar);
	}
}

- (BOOL)extractShippedTemplatesToPath:(NSString *)path {
    path = [path stringByExpandingTildeInPath];
    
    //read embedded data
    NSData *data = [DDEmbeddedDataReader embeddedDataFromSegment:@"__ZIP" inSection:@"__templates" error:nil];
    if(!data) {
        NSLog( @"Error: extractShippedTemplatesToPath called, but no data embeded" );
        return NO;
    }

    //get a path
    NSString *p = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]];
    
    //write the data
    BOOL br = [data writeToFile:p atomically:NO];
    if(!br) {
        NSLog( @"Error: extractShippedTemplatesToPath failed write data to tmp path %@", p );
        return NO;
    }
    
    //open the zip
    DDZipReader *reader = [[DDZipReader alloc] init];
    br = [reader openZipFile:p];
    if(!br) {
        NSLog( @"Error: extractShippedTemplatesToPath failed to open the zip at %@", p );
        return NO;
    }
    
    //extract
    br = [reader unzipFileTo:path flattenStructure:NO];
    if(!br) {
        NSLog( @"Error: extractShippedTemplatesToPath failed to unzip the zip from %@ TO %@", p, path );
        return NO;
    }
    
    //close and remove the temp
    [reader closeZipFile];
    br = [[NSFileManager defaultManager] removeItemAtPath:p error:nil];
    if(!br) {
        NSLog( @"Error: extractShippedTemplatesToPath failed to rm %@", p );
        return NO;
    }

    return YES;
}

- (BOOL)validateTemplatesPath:(NSString *)path error:(NSError **)error {
	// Validates the given templates path contains all required template files. If not, it returns the reason through the error argument and returns NO. Note that we only do simple "path exist and is directory" tests here, each object that requires templates at the given path will do it's own validation later on and will report errors if it finds something missing.
	BOOL isDirectory = NO;
	NSString *trimmed = [path stringByTrimmingWhitespaceAndNewLine];
	NSString *standardized = [[self standardizeCurrentDirectoryForPath:trimmed] stringByStandardizingPath];
	if (![self.fileManager fileExistsAtPath:standardized isDirectory:&isDirectory]) {
		if (error) {
			NSString *desc = [NSString stringWithFormat:@"Template path doesn't exist at '%@'!", standardized];
			*error = [NSError errorWithCode:GBErrorTemplatePathDoesntExist description:desc reason:nil];
		}
		return NO;
	}
	if (!isDirectory) {
		if (error) {
			NSString *desc = [NSString stringWithFormat:@"Template path '%@' is not directory!", standardized];
			*error = [NSError errorWithCode:GBErrorTemplatePathNotDirectory description:desc reason:nil];
		}
		return NO;
	}
	return YES;
}

- (NSString *)standardizeCurrentDirectoryForPath:(NSString *)path {
	// Converts . to actual working directory.
	if (![path hasPrefix:@"."] || [path hasPrefix:@".."]) return path;
	NSString *suffix = [path substringFromIndex:1];
	return [[self.fileManager currentDirectoryPath] stringByAppendingPathComponent:suffix];
}

- (NSString *)combineBasePath:(NSString *)base withRelativePath:(NSString *)path {
	// Appends the given relative path to the given base path if necessary. If relative path points to an exact location (starts with / or ~), it's simply returned, otherwise it's appended to the base path and result is returned.
	if ([path hasPrefix:@"~"] || [path hasPrefix:@"/"]) return path;
	if ([path hasPrefix:@"."] && ![path hasPrefix:@".."]) path = [path substringFromIndex:1];
	return [base stringByAppendingPathComponent:path];
}

#pragma mark Xcode, Global and project settings handling

- (void)injectXcodeSettingsFromArguments:(NSArray *)arguments {
    //check if even deal with a project
    if([arguments count] < 2)
        return;
    NSString *path = [arguments objectAtIndex:1];
    if(![path.pathExtension isEqualToString:@"xcodeproj"])
        return;

    //parse the file and get a representation of it
    NSError *error = nil;
    DDXcodeProjectFile *file = [DDXcodeProjectFile xcodeProjectFileWithPath:path error:&error];
    if(!file) {
        NSLog(@"Failed to parse pbx at %@: %@", path, error);
        return;
    }
    
    //set basic vars
    [self setProjectName:file.name];
    [self setProjectCompany:file.company];

    //prepare docset
    [self setCreateDocset:YES];
    [self setInstallDocset:YES];
    [self setDocsetBundleName:file.name];
    [self setCompanyId:[file.company stringByAppendingFormat:@".%@", file.name].lowercaseString];

    //set output path to be next to project
    [self.additionalInputPaths addObject:file.projectRoot];
    [self setOutput:file.projectRoot];
}

- (void)injectGlobalSettingsFromArguments:(NSArray *)arguments {
	// This is where we override factory defaults (factory defaults with global templates). This needs to be sent before giving DDCli a chance to go through parameters! DDCli will "take care" (or more correct: it's KVC messages will) of overriding with command line arguments. Note that we scan the arguments backwards to get the latest template value - this is what we'll get with DDCli later on anyway. If no template path is given, check predefined paths.
	self.templatesFound = NO;
	__block NSString *path = nil;
	[arguments enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSString *option, NSUInteger idx, BOOL *stop) {
		NSString *opt = [option copy];
		while ([opt hasPrefix:@"-"]) opt = [opt substringFromIndex:1];
		if ([opt isEqualToString:@"t"] || [opt isEqualToString:GBArgToNSString(kGBArgTemplatesPath)]) {
			NSError *error = nil;
			if (![self validateTemplatesPath:path error:&error]) [NSException raiseWithError:error format:@"Path '%@' from %@ is not valid!", path, option];
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
        
        #ifdef COMPILE_TIME_DEFAULT_TEMPLATE_PATH
		path = COMPILE_TIME_DEFAULT_TEMPLATE_PATH;
		if ([self validateTemplatesPath:path error:nil]) {
			[self overrideSettingsWithGlobalSettingsFromPath:path];
			self.settings.templatesPath = path;
			self.templatesFound = YES;
			return;
		}
        #endif
        
        //if we got here, there is NO templates installed which we can find.
        //IF we have embedded data though, we can get THAT and install it
		path = @"~/.appledoc";
        [self extractShippedTemplatesToPath:path];
		if ([self validateTemplatesPath:path error:nil]) {
			[self overrideSettingsWithGlobalSettingsFromPath:path];
			self.settings.templatesPath = path;
			self.templatesFound = YES;
			return;
		}
                
	}
}

- (void)injectProjectSettingsFromArguments:(NSArray *)arguments {
	// Checks all command line paths for project settings and injects the settings to the application if found. Note that in case more than one path contains settings, all settings are injected with latest having greater priority. Note that we handle arguments very roughly; we start at back and proceed until we find first option name. This means we will also include last option value... Not too smart, but we need to do this before giving DDCli a chance to parse as we want to have command line switches overriding any project settings and we don't want to duplicate the behavior from DDCli.
	[arguments enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSString *argument, NSUInteger idx, BOOL *stop) {
		if ([argument hasPrefix:@"-"]) {
			*stop = YES;
			return;
		}
		
		// Convert the argument to path.
		NSString *path = [[self standardizeCurrentDirectoryForPath:argument] stringByStandardizingPath];
		NSString *filename = path;
		
		// If we have a directory, check if it contains AppledocSettings.plist; ignore it if not. Note that we don't have to check if the file exists or not, that'll be handled for us inside settings injection method.
		BOOL dir;
		if (![self.fileManager fileExistsAtPath:path isDirectory:&dir]) return;
		if (dir) filename = [path stringByAppendingPathComponent:@"AppledocSettings.plist"];
		
		// If we have a plist file, handle it. Note that we need to handle --templates cmd line switch separately so that it's properly accepted by the application!
		if ([[filename pathExtension] isEqualToString:@"plist"]) {
			// Prepare the directory path to the plist file. We'll use it for preparing relative paths.
			if (!dir) [self.ignoredInputPaths addObject:argument];
			NSString *plistPath = [filename stringByDeletingLastPathComponent];

			// In the first pass, we need to handle --templates option. We need to handle these before any other option from the project settings to prevent global settings overriding project settings! Note how we prevent handling of every option except --templates; we leave that option through to get it set to application settings (that's all the KVC setter does).
			[self injectSettingsFromSettingsFile:filename usingBlock:^BOOL(NSString *option, id *value, BOOL *stop) {
				if ([option isEqualToString:GBArgToNSString(kGBArgTemplatesPath)]) {
					NSError *error = nil;
					NSString *templatesPath = [self combineBasePath:plistPath withRelativePath:*value];
					if (![self validateTemplatesPath:templatesPath error:&error]) [NSException raiseWithError:error format:@"Path '%@' from --%@ option in project settings '%@' is not valid!", *value, option, filename];
					[self overrideSettingsWithGlobalSettingsFromPath:templatesPath];
					self.templatesFound = YES;
					*value = templatesPath;
					return YES;
				}
				return NO;
			}];
			
			// In the second pass, we handle all options. Note that we handle --input option manually; there is no KVC setter for it as it's not regular command line option (we get all input paths directly through command line arguments, not via command line switches). Also note that --templates is still allows but it's only going to be passed to application settings this time without being handled.
			[self injectSettingsFromSettingsFile:filename usingBlock:^BOOL(NSString *option, id *value, BOOL *stop) {
				// If option is input path, add it to additional paths. We'll append these to any path found from command line. Note that we must properly handle . paths and paths not starting with / or ~; we assume these are relative paths so we prefix them with the path of the settings file!
				if ([option isEqualToString:GBArgToNSString(kGBArgInputPath)]) {
					for (__strong NSString *inputPath in *value) {
						inputPath = [self combineBasePath:plistPath withRelativePath:inputPath];
						[self.additionalInputPaths addObject:inputPath];
					}
					return NO;
				} else if ([option isEqualToString:GBArgToNSString(kGBArgTemplatesPath)]) {
					return NO;
				}
				return YES;
			}];
		}
	}];
}

- (void)overrideSettingsWithGlobalSettingsFromPath:(NSString *)path {
	// Checks if global settings file exists at the given path and if so, overrides current settings with values from the file.
	NSString *userPath = [path stringByAppendingPathComponent:@"GlobalSettings.plist"];
	NSString *filename = [userPath stringByStandardizingPath];
	[self injectSettingsFromSettingsFile:filename usingBlock:^(NSString *option, id *value, BOOL *stop) {
		if ([option isEqualToString:GBArgToNSString(kGBArgTemplatesPath)]) {
			ddprintf(@"WARN: Found unsupported --%@ option in global settings file '%@'!\n", option, userPath);
			return NO;
		}
		if ([option isEqualToString:GBArgToNSString(kGBArgInputPath)]) {
			ddprintf(@"WARN: Found unsupported --%@ option in global settings '%@'!\n", option, userPath);
			return NO;
		}
		return YES;
	}];
}

- (void)injectSettingsFromSettingsFile:(NSString *)path usingBlock:(BOOL (^)(NSString *option, id *value, BOOL *stop))block {
	// Injects any settings found in the given file to the application settings, overriding current settings with values from the file. To keep code as simple as possible, we're reusing DDCli KVC here: settings file simply uses keys which are equal to command line arguments. Then, by reusing DDCli method for converting switch to KVC key, we're simply sending appropriate KVC messages to receiver. From object's point of view, this is no different than getting KVC messages sent from DDCli. Note that this may cause some KVC messages beeing sent twice or more. The only code added is handling boolean settings (i.e. adding "--no" prefix) and settings that may be entered multiple times (--ignore for example). To even further simplify handling, we're only allowing long command line arguments names in settings files for now!
	if (![self.fileManager fileExistsAtPath:path]) return;

	NSError* error = nil;
	NSData* data = [NSData dataWithContentsOfFile:path options:0 error:&error];
	if (!data) [NSException raise:@"Failed reading settings from '%@'!", path];
	NSDictionary *theSettings = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:NULL error:&error];
	if (!theSettings) [NSException raiseWithError:error format:@"Failed reading settings plist from '%@'!", path];
	
	// We first pass each option and it's value to the block. The block can return YES to allow handling it, NO otherwise. It can also pass back a different value (we're passing a pointer to the value!).
	[theSettings enumerateKeysAndObjectsUsingBlock:^(NSString *option, id value, BOOL *stop) {
		while ([option hasPrefix:@"-"]) option = [option substringFromIndex:1];
		NSString *key = [DDGetoptLongParser optionToKey:option];
		if (!block(option, &value, stop)) return;

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

#pragma mark Overriden methods

- (NSString *)description {
	return [self className];
}

#pragma mark Callbacks API for DDCliApplication

- (void)setOutput:(NSString *)path { self.settings.outputPath = [self standardizeCurrentDirectoryForPath:path]; }
- (void)setDocsetInstallPath:(NSString *)path { self.settings.docsetInstallPath = [self standardizeCurrentDirectoryForPath:path]; }
- (void)setXCRunPath:(NSString *)path { self.settings.xcrunPath = [self standardizeCurrentDirectoryForPath:path]; }
- (void)setInclude:(NSString *)path { [self.settings.includePaths addObject:[self standardizeCurrentDirectoryForPath:path]]; }
- (void)setIndexDesc:(NSString *)path { self.settings.indexDescriptionPath = [self standardizeCurrentDirectoryForPath:path]; }
- (void)setTemplates:(NSString *)path { self.settings.templatesPath = [self standardizeCurrentDirectoryForPath:path]; }
- (void)setIgnore:(NSString *)path {
	if ([path hasPrefix:@"*"]) path = [path substringFromIndex:1];
	[self.settings.ignoredPaths addObject:path];
}
- (void)setExcludeOutput:(NSString *)path {
	[self.settings.excludeOutputPaths addObject:path];
}

- (void)setProjectName:(NSString *)value { self.settings.projectName = value; }
- (void)setProjectVersion:(NSString *)value { self.settings.projectVersion = value; }
- (void)setProjectCompany:(NSString *)value { self.settings.projectCompany = value; }
- (void)setCompanyId:(NSString *)value { self.settings.companyIdentifier = value; }

- (void)setCleanOutput:(BOOL)value { self.settings.cleanupOutputPathBeforeRunning = value; }
- (void)setCreateHtml:(BOOL)value {
	self.settings.createHTML = value;
	if (!value) {
		self.settings.createDocSet = NO;
		self.settings.finalizeDocSet = NO;
		self.settings.installDocSet = NO;
		self.settings.publishDocSet = NO;
	}
}
- (void)setCreateDocset:(BOOL)value {
	self.settings.createDocSet = value;
	if (value) {
		self.settings.createHTML = YES;
	} else {
		self.settings.finalizeDocSet = NO;
		self.settings.installDocSet = NO;
		self.settings.publishDocSet = NO;
	}
}
- (void)setFinalizeDocset:(BOOL)value {
	self.settings.finalizeDocSet = value;
	if (value) {
		self.settings.createHTML = YES;
		self.settings.createDocSet = YES;
		self.settings.installDocSet = NO;

	//	} else {
	//		self.settings.publishDocSet = NO;
	}
}
- (void)setInstallDocset:(BOOL)value {
	self.settings.installDocSet = value;
	if (value) {
		self.settings.createHTML = YES;
		self.settings.createDocSet = YES;
		self.settings.finalizeDocSet = YES;

    //	} else {
    //		self.settings.publishDocSet = NO;
	}
}
- (void)setPublishDocset:(BOOL)value {
	self.settings.publishDocSet = value;
	if (value) {
		self.settings.createHTML = YES;
		self.settings.createDocSet = YES;
	//	self.settings.installDocSet = YES;
	}
}
- (void)setHtmlAnchors:(NSString *)value {
    self.settings.htmlAnchorFormat = GBHTMLAnchorFormatFromNSString(value);
}
- (void)setNoCleanOutput:(BOOL)value { self.settings.cleanupOutputPathBeforeRunning = !value; }
- (void)setNoCreateHtml:(BOOL)value { [self setCreateHtml:!value]; }
- (void)setNoCreateDocset:(BOOL)value { [self setCreateDocset:!value]; }
- (void)setNoFinalizeDocset:(BOOL)value { [self setFinalizeDocset:!value]; }
- (void)setNoInstallDocset:(BOOL)value { [self setInstallDocset:!value]; }
- (void)setNoPublishDocset:(BOOL)value { [self setPublishDocset:!value]; }

- (void)setCrossrefFormat:(NSString *)value { self.settings.commentComponents.crossReferenceMarkersTemplate = value; }
- (void)setExplicitCrossref:(BOOL)value { self.settings.commentComponents.crossReferenceMarkersTemplate = value ? @"<%@>" : @"<?%@>?"; }
- (void)setNoExplicitCrossref:(BOOL)value { [self setExplicitCrossref:!value]; }

- (void)setExitThreshold:(int)value { self.settings.exitCodeThreshold = value; }
- (void)setKeepIntermediateFiles:(BOOL)value { self.settings.keepIntermediateFiles = value;}
- (void)setKeepUndocumentedObjects:(BOOL)value { self.settings.keepUndocumentedObjects = value; }
- (void)setKeepUndocumentedMembers:(BOOL)value { self.settings.keepUndocumentedMembers = value; }
- (void)setSearchUndocumentedDoc:(BOOL)value { self.settings.findUndocumentedMembersDocumentation = value; }
- (void)setRepeatFirstPar:(BOOL)value { self.settings.repeatFirstParagraphForMemberDescription = value; }
- (void)setPreprocessHeaderdoc:(BOOL)value { self.settings.preprocessHeaderDoc = value; }
- (void)setPrintInformationBlockTitles:(BOOL)value { self.settings.printInformationBlockTitles = value; }
- (void)setUseSingleStar:(BOOL)value { self.settings.useSingleStarForBold = value; }
- (void)setMergeCategories:(BOOL)value { self.settings.mergeCategoriesToClasses = value; }
- (void)setMergeCategoryComment:(BOOL)value { self.settings.mergeCategoryCommentToClass = value; }
- (void)setKeepMergedSections:(BOOL)value { self.settings.keepMergedCategoriesSections = value; }
- (void)setPrefixMergedSections:(BOOL)value { self.settings.prefixMergedCategoriesSectionsWithCategoryName = value; }
- (void)setNoKeepIntermediateFiles:(BOOL)value { self.settings.keepIntermediateFiles = !value;}
- (void)setNoKeepUndocumentedObjects:(BOOL)value { self.settings.keepUndocumentedObjects = !value; }
- (void)setNoKeepUndocumentedMembers:(BOOL)value { self.settings.keepUndocumentedMembers = !value; }
- (void)setNoSearchUndocumentedDoc:(BOOL)value { self.settings.findUndocumentedMembersDocumentation = !value; }
- (void)setNoRepeatFirstPar:(BOOL)value { self.settings.repeatFirstParagraphForMemberDescription = !value; }
- (void)setNoUseSingleStar:(BOOL)value { self.settings.useSingleStarForBold = !value; }
- (void)setNoPreprocessHeaderdoc:(BOOL)value { self.settings.preprocessHeaderDoc = !value; }
- (void)setNoPrintInformationBlockTitles:(BOOL)value { self.settings.printInformationBlockTitles = !value; }
- (void)setNoMergeCategories:(BOOL)value { self.settings.mergeCategoriesToClasses = !value; }
- (void)setNoMergeCategoryComment:(BOOL)value { self.settings.mergeCategoryCommentToClass = !value; }
- (void)setNoKeepMergedSections:(BOOL)value { self.settings.keepMergedCategoriesSections = !value; }
- (void)setNoPrefixMergedSections:(BOOL)value { self.settings.prefixMergedCategoriesSectionsWithCategoryName = !value; }
- (void)setUseCodeOrder:(BOOL)value { self.settings.useCodeOrder = value; }
- (void)setNoUseCodeOrder:(BOOL)value { self.settings.useCodeOrder = !value; }

- (void)setWarnMissingOutputPath:(BOOL)value { self.settings.warnOnMissingOutputPathArgument = value; }
- (void)setWarnMissingCompanyId:(BOOL)value { self.settings.warnOnMissingCompanyIdentifier = value; }
- (void)setWarnUndocumentedObject:(BOOL)value { self.settings.warnOnUndocumentedObject = value; }
- (void)setWarnUndocumentedMember:(BOOL)value { self.settings.warnOnUndocumentedMember = value; }
- (void)setWarnEmptyDescription:(BOOL)value { self.settings.warnOnEmptyDescription = value; }
- (void)setWarnUnknownDirective:(BOOL)value { self.settings.warnOnUnknownDirective = value; }
- (void)setWarnInvalidCrossref:(BOOL)value { self.settings.warnOnInvalidCrossReference = value; }
- (void)setWarnMissingArg:(BOOL)value { self.settings.warnOnMissingMethodArgument = value; }
- (void)setNoWarnMissingOutputPath:(BOOL)value { self.settings.warnOnMissingOutputPathArgument = !value; }
- (void)setNoWarnMissingCompanyId:(BOOL)value { self.settings.warnOnMissingCompanyIdentifier = !value; }
- (void)setNoWarnUndocumentedObject:(BOOL)value { self.settings.warnOnUndocumentedObject = !value; }
- (void)setNoWarnUndocumentedMember:(BOOL)value { self.settings.warnOnUndocumentedMember = !value; }
- (void)setNoWarnEmptyDescription:(BOOL)value { self.settings.warnOnEmptyDescription = !value; }
- (void)setNoWarnUnknownDirective:(BOOL)value { self.settings.warnOnUnknownDirective = !value; }
- (void)setNoWarnInvalidCrossref:(BOOL)value { self.settings.warnOnInvalidCrossReference = !value; }
- (void)setNoWarnMissingArg:(BOOL)value { self.settings.warnOnMissingMethodArgument = !value; }

- (void)setDocsetBundleId:(NSString *)value { self.settings.docsetBundleIdentifier = value; }
- (void)setDocsetBundleName:(NSString *)value { self.settings.docsetBundleName = value; }
- (void)setDocsetDesc:(NSString *)value { self.settings.docsetDescription = value; }
- (void)setDocsetCopyright:(NSString *)value { self.settings.docsetCopyrightMessage = value; }
- (void)setDocsetFeedName:(NSString *)value { self.settings.docsetFeedName = value; }
- (void)setDocsetFeedUrl:(NSString *)value { self.settings.docsetFeedURL = value; }
- (void)setDocsetFeedFormats:(NSString *)value {
    self.settings.docsetFeedFormats = GBPublishedFeedFormatsFromNSString(value);
}
- (void)setDocsetPackageUrl:(NSString *)value { self.settings.docsetPackageURL = value; }
- (void)setDocsetFallbackUrl:(NSString *)value { self.settings.docsetFallbackURL = value; }
- (void)setDocsetPublisherId:(NSString *)value { self.settings.docsetPublisherIdentifier = value; }
- (void)setDocsetPublisherName:(NSString *)value { self.settings.docsetPublisherName = value; }
- (void)setDocsetMinXcodeVersion:(NSString *)value { self.settings.docsetMinimumXcodeVersion = value; }
- (void)setDocsetPlatformFamily:(NSString *)value { self.settings.docsetPlatformFamily = value; }
- (void)setDocsetCertIssuer:(NSString *)value { self.settings.docsetCertificateIssuer = value; }
- (void)setDocsetCertSigner:(NSString *)value { self.settings.docsetCertificateSigner = value; }
- (void)setDashPlatformFamily:(NSString *)value { self.settings.dashDocsetPlatformFamily = value; }

- (void)setDocsetBundleFilename:(NSString *)value { self.settings.docsetBundleFilename = value; }
- (void)setDocsetAtomFilename:(NSString *)value { self.settings.docsetAtomFilename = value; }
- (void)setDocsetXMLFilename:(NSString *)value { self.settings.docsetXMLFilename = value; }
- (void)setDocsetPackageFilename:(NSString *)value { self.settings.docsetPackageFilename = value; }

@synthesize additionalInputPaths;
@synthesize ignoredInputPaths;
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
    ddprintf(@"--%s = %@\n", kGBArgProjectName, self.settings.projectName);
    ddprintf(@"--%s = %@\n", kGBArgProjectVersion, self.settings.projectVersion);
    ddprintf(@"--%s = %@\n", kGBArgProjectCompany, self.settings.projectCompany);
    ddprintf(@"--%s = %@\n", kGBArgCompanyIdentifier, self.settings.companyIdentifier);
    ddprintf(@"\n");
    
    ddprintf(@"--%s = %@\n", kGBArgTemplatesPath, self.settings.templatesPath);
    ddprintf(@"--%s = %@\n", kGBArgOutputPath, self.settings.outputPath);
    ddprintf(@"--%s = %@\n", kGBArgIndexDescPath, self.settings.indexDescriptionPath);
    for (NSString *path in self.settings.includePaths) ddprintf(@"--%s = %@\n", kGBArgIncludePath, path);
    for (NSString *path in self.settings.ignoredPaths) ddprintf(@"--%s = %@\n", kGBArgIgnorePath, path);
    for (NSString *path in self.settings.excludeOutputPaths) ddprintf(@"--%s = %@\n", kGBArgExcludeOutputPath, path);
    ddprintf(@"--%s = %@\n", kGBArgDocSetInstallPath, self.settings.docsetInstallPath);
    ddprintf(@"--%s = %@\n", kGBArgXcrunPath, self.settings.xcrunPath);
    ddprintf(@"\n");
    
    ddprintf(@"--%s = %@\n", kGBArgDocSetBundleIdentifier, self.settings.docsetBundleIdentifier);
    ddprintf(@"--%s = %@\n", kGBArgDocSetBundleName, self.settings.docsetBundleName);
    ddprintf(@"--%s = %@\n", kGBArgDocSetDescription, self.settings.docsetDescription);
    ddprintf(@"--%s = %@\n", kGBArgDocSetCopyrightMessage, self.settings.docsetCopyrightMessage);
    ddprintf(@"--%s = %@\n", kGBArgDocSetFeedName, self.settings.docsetFeedName);
    ddprintf(@"--%s = %@\n", kGBArgDocSetFeedURL, self.settings.docsetFeedURL);
    ddprintf(@"--%s = %@\n", kGBArgDocSetFeedFormats, NSStringFromGBPublishedFeedFormats(self.settings.docsetFeedFormats));
    ddprintf(@"--%s = %@\n", kGBArgDocSetPackageURL, self.settings.docsetPackageURL);
    ddprintf(@"--%s = %@\n", kGBArgDocSetFallbackURL, self.settings.docsetFallbackURL);
    ddprintf(@"--%s = %@\n", kGBArgDocSetPublisherIdentifier, self.settings.docsetPublisherIdentifier);
    ddprintf(@"--%s = %@\n", kGBArgDocSetPublisherName, self.settings.docsetPublisherName);
    ddprintf(@"--%s = %@\n", kGBArgDocSetMinimumXcodeVersion, self.settings.docsetMinimumXcodeVersion);
    ddprintf(@"--%s = %@\n", kGBArgDocSetPlatformFamily, self.settings.docsetPlatformFamily);
    ddprintf(@"--%s = %@\n", kGBArgDocSetCertificateIssuer, self.settings.docsetCertificateIssuer);
    ddprintf(@"--%s = %@\n", kGBArgDocSetCertificateSigner, self.settings.docsetCertificateSigner);
    ddprintf(@"--%s = %@\n", kGBArgDocSetBundleFilename, self.settings.docsetBundleFilename);
    ddprintf(@"--%s = %@\n", kGBArgDocSetAtomFilename, self.settings.docsetAtomFilename);
    ddprintf(@"--%s = %@\n", kGBArgDocSetXMLFilename, self.settings.docsetXMLFilename);
    ddprintf(@"--%s = %@\n", kGBArgDocSetPackageFilename, self.settings.docsetPackageFilename);
    ddprintf(@"\n");
    
    ddprintf(@"--%s = %@\n", kGBArgCleanOutput, PRINT_BOOL(self.settings.cleanupOutputPathBeforeRunning));
    ddprintf(@"--%s = %@\n", kGBArgCreateHTML, PRINT_BOOL(self.settings.createHTML));
    ddprintf(@"--%s = %@\n", kGBArgCreateDocSet, PRINT_BOOL(self.settings.createDocSet));
    ddprintf(@"--%s = %@\n", kGBArgInstallDocSet, PRINT_BOOL(self.settings.installDocSet));
    ddprintf(@"--%s = %@\n", kGBArgPublishDocSet, PRINT_BOOL(self.settings.publishDocSet));
    ddprintf(@"--%s = %@\n", kGBArgHTMLAnchorFormat, NSStringFromGBHTMLAnchorFormat(self.settings.htmlAnchorFormat));
    ddprintf(@"--%s = %@\n", kGBArgKeepIntermediateFiles, PRINT_BOOL(self.settings.keepIntermediateFiles));
    ddprintf(@"--%s = %@\n", kGBArgKeepUndocumentedObjects, PRINT_BOOL(self.settings.keepUndocumentedObjects));
    ddprintf(@"--%s = %@\n", kGBArgKeepUndocumentedMembers, PRINT_BOOL(self.settings.keepUndocumentedMembers));
    ddprintf(@"--%s = %@\n", kGBArgFindUndocumentedMembersDocumentation, PRINT_BOOL(self.settings.findUndocumentedMembersDocumentation));
    ddprintf(@"--%s = %@\n", kGBArgRepeatFirstParagraph, PRINT_BOOL(self.settings.repeatFirstParagraphForMemberDescription));
    ddprintf(@"--%s = %@\n", kGBArgPreprocessHeaderDoc, PRINT_BOOL(self.settings.preprocessHeaderDoc));
    ddprintf(@"--%s = %@\n", kGBArgPrintInformationBlockTitles, PRINT_BOOL(self.settings.printInformationBlockTitles));
    ddprintf(@"--%s = %@\n", kGBArgUseSingleStar, PRINT_BOOL(self.settings.useSingleStarForBold));
    ddprintf(@"--%s = %@\n", kGBArgMergeCategoriesToClasses, PRINT_BOOL(self.settings.mergeCategoriesToClasses));
    ddprintf(@"--%s = %@\n", kGBArgMergeCategoryComment, PRINT_BOOL(self.settings.mergeCategoryCommentToClass));
    ddprintf(@"--%s = %@\n", kGBArgKeepMergedCategoriesSections, PRINT_BOOL(self.settings.keepMergedCategoriesSections));
    ddprintf(@"--%s = %@\n", kGBArgPrefixMergedCategoriesSectionsWithCategoryName, PRINT_BOOL(self.settings.prefixMergedCategoriesSectionsWithCategoryName));
    ddprintf(@"--%s = %@\n", kGBArgCrossRefFormat, self.settings.commentComponents.crossReferenceMarkersTemplate);
    ddprintf(@"--%s = %@\n", kGBArgUseCodeOrder, self.settings.useCodeOrder);
    ddprintf(@"--%s = %ld\n", kGBArgExitCodeThreshold, self.settings.exitCodeThreshold);
    ddprintf(@"\n");
    
    ddprintf(@"--%s = %@\n", kGBArgWarnOnMissingOutputPath, PRINT_BOOL(self.settings.warnOnMissingOutputPathArgument));
    ddprintf(@"--%s = %@\n", kGBArgWarnOnMissingCompanyIdentifier, PRINT_BOOL(self.settings.warnOnMissingCompanyIdentifier));
    ddprintf(@"--%s = %@\n", kGBArgWarnOnUndocumentedObject, PRINT_BOOL(self.settings.warnOnUndocumentedObject));
    ddprintf(@"--%s = %@\n", kGBArgWarnOnUndocumentedMember, PRINT_BOOL(self.settings.warnOnUndocumentedMember));
    ddprintf(@"--%s = %@\n", kGBArgWarnOnEmptyDescription, PRINT_BOOL(self.settings.warnOnEmptyDescription));
    ddprintf(@"--%s = %@\n", kGBArgWarnOnUnknownDirective, PRINT_BOOL(self.settings.warnOnUnknownDirective));
    ddprintf(@"--%s = %@\n", kGBArgWarnOnInvalidCrossReference, PRINT_BOOL(self.settings.warnOnInvalidCrossReference));
    ddprintf(@"--%s = %@\n", kGBArgWarnOnMissingMethodArgument, PRINT_BOOL(self.settings.warnOnMissingMethodArgument));
    ddprintf(@"\n");
    
    ddprintf(@"--%s = %@\n", kGBArgLogFormat, self.logformat);
    ddprintf(@"--%s = %@\n", kGBArgVerbose, self.verbose);
    ddprintf(@"\n");
}

- (void)printVersion {
	NSString *appledocName = [self.settings.stringTemplates.appledocData objectForKey:@"tool"];
	NSString *appledocVersion = [self.settings.stringTemplates.appledocData objectForKey:@"version"];
	NSString *appledocBuild = [self.settings.stringTemplates.appledocData objectForKey:@"build"];
	ddprintf(@"%@ version: %@ (build %@)\n", appledocName, appledocVersion, appledocBuild);
	ddprintf(@"\n");
}

- (void)printHelp {
#define PRINT_USAGE(short,long,arg,desc) [self printHelpForShortOption:short longOption:[NSString stringWithUTF8String:long] argument:arg description:desc]
	NSString *name = [self.settings.stringTemplates.appledocData objectForKey:@"tool"];
	ddprintf(@"Usage: %@ [OPTIONS] <paths to source dirs or files>\n", name);
	ddprintf(@"\n");
	ddprintf(@"PATHS\n");
	PRINT_USAGE(@"-o,", kGBArgOutputPath, @"<path>", @"Output path");
	PRINT_USAGE(@"-t,", kGBArgTemplatesPath, @"<path>", @"Template files path");
	PRINT_USAGE(@"   ", kGBArgDocSetInstallPath, @"<path>", @"DocSet installation path");
	PRINT_USAGE(@"-s,", kGBArgIncludePath, @"<path>", @"Include static doc(s) at path");
	PRINT_USAGE(@"-i,", kGBArgIgnorePath, @"<path>", @"Ignore given path");
	PRINT_USAGE(@"-x,", kGBArgExcludeOutputPath, @"<path>", @"Exclude given path from output");
	PRINT_USAGE(@"   ", kGBArgIndexDescPath, @"<path>", @"File including main index description");
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
    PRINT_USAGE(@"   ", kGBArgHTMLAnchorFormat, @"<string>", @"[*] The html anchor format to use in DocSet HTML.");
	PRINT_USAGE(@"   ", kGBArgCleanOutput, @"", @"[b] Remove contents of output path before starting !!CAUTION!!");
	ddprintf(@"\n");
	ddprintf(@"OPTIONS\n");
	PRINT_USAGE(@"   ", kGBArgKeepIntermediateFiles, @"", @"[b] Keep intermediate files in output path");
	PRINT_USAGE(@"   ", kGBArgKeepUndocumentedObjects, @"", @"[b] Keep undocumented objects");
	PRINT_USAGE(@"   ", kGBArgKeepUndocumentedMembers, @"", @"[b] Keep undocumented members");
	PRINT_USAGE(@"   ", kGBArgFindUndocumentedMembersDocumentation, @"", @"[b] Search undocumented members documentation");
	PRINT_USAGE(@"   ", kGBArgRepeatFirstParagraph, @"", @"[b] Repeat first paragraph in member documentation");
	PRINT_USAGE(@"   ", kGBArgPreprocessHeaderDoc, @"", @"[b] Preprocess header doc comments - 10.7 only!");
	PRINT_USAGE(@"   ", kGBArgPrintInformationBlockTitles, @"", @"[b] Print title of information blocks. \"Note:\", \"Warning:\", etc.");
	PRINT_USAGE(@"   ", kGBArgUseSingleStar, @"", @"[b] Use single star for bold marker");
	PRINT_USAGE(@"   ", kGBArgMergeCategoriesToClasses, @"", @"[b] Merge categories to classes");
	PRINT_USAGE(@"   ", kGBArgMergeCategoryComment, @"", @"[b] Merge category comment to class");
	PRINT_USAGE(@"   ", kGBArgKeepMergedCategoriesSections, @"", @"[b] Keep merged categories sections");
	PRINT_USAGE(@"   ", kGBArgPrefixMergedCategoriesSectionsWithCategoryName, @"", @"[b] Prefix merged sections with category name");
    PRINT_USAGE(@"   ", kGBArgExplicitCrossRef, @"", @"[b] Shortcut for explicit default cross ref template");
    PRINT_USAGE(@"   ", kGBArgUseCodeOrder, @"", @"[b] Order sections by the order specified in the input files");
    PRINT_USAGE(@"   ", kGBArgCrossRefFormat, @"<string>", @"Cross reference template regex");
    PRINT_USAGE(@"   ", kGBArgExitCodeThreshold, @"<number>", @"Exit code threshold below which 0 is returned");
	ddprintf(@"\n");
	ddprintf(@"WARNINGS\n");
	PRINT_USAGE(@"   ", kGBArgWarnOnMissingOutputPath, @"", @"[b] Warn if output path is not given");
	PRINT_USAGE(@"   ", kGBArgWarnOnMissingCompanyIdentifier, @"", @"[b] Warn if company ID is not given");
	PRINT_USAGE(@"   ", kGBArgWarnOnUndocumentedObject, @"", @"[b] Warn on undocumented object");
	PRINT_USAGE(@"   ", kGBArgWarnOnUndocumentedMember, @"", @"[b] Warn on undocumented member");
	PRINT_USAGE(@"   ", kGBArgWarnOnEmptyDescription, @"", @"[b] Warn on empty description block");
	PRINT_USAGE(@"   ", kGBArgWarnOnUnknownDirective, @"", @"[b] Warn on unknown directive or format");
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
    PRINT_USAGE(@"   ", kGBArgDocSetFeedFormats, @"<values>", @"DocSet feed formats. Separated by a comma [atom,xml]");
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
    PRINT_USAGE(@"   ", kGBArgDocSetXMLFilename, @"<string>", @"[*] DocSet xml feed filename");
	PRINT_USAGE(@"   ", kGBArgDocSetPackageFilename, @"<string>", @"[*] DocSet package (.xar,.tgz) filename. Leave off the extension. This will be added depending on the generated package.");
	ddprintf(@"\n");
	ddprintf(@"MISCELLANEOUS\n");
	PRINT_USAGE(@"   ", kGBArgLogFormat, @"<number>", @"Log format [0-3]");
	PRINT_USAGE(@"   ", kGBArgVerbose, @"<value>", @"Log verbosity level [0-6,xcode]");
	PRINT_USAGE(@"   ", kGBArgVersion, @"", @"Display version and exit");
	PRINT_USAGE(@"   ", kGBArgHelp, @"", @"Display this help and exit");
	ddprintf(@"\n");
	ddprintf(@"==================================================================\n");
	ddprintf(@"[b] boolean parameter, uses no value, use --no- prefix to negate.\n");
	ddprintf(@"\n");
	ddprintf(@"[*] indicates parameters accepting placeholder strings:\n");
	ddprintf(@"- %@ replaced with --project-name\n", kGBTemplatePlaceholderProject);
	ddprintf(@"- %@ replaced with normalized --project-name\n", kGBTemplatePlaceholderProjectID);
	ddprintf(@"- %@ replaced with --project-version\n", kGBTemplatePlaceholderVersion);
	ddprintf(@"- %@ replaced with normalized --project-version\n", kGBTemplatePlaceholderVersionID);
	ddprintf(@"- %@ replaced with --project-company\n", kGBTemplatePlaceholderCompany);
	ddprintf(@"- %@ replaced with --company-id\n", kGBTemplatePlaceholderCompanyID);
	ddprintf(@"- %@ replaced with current year (format yyyy)\n", kGBTemplatePlaceholderYear);
	ddprintf(@"- %@ replaced with current date (format yyyy-MM-dd)\n", kGBTemplatePlaceholderUpdateDate);
	ddprintf(@"- %@ replaced with --docset-bundle-filename\n", kGBTemplatePlaceholderDocSetBundleFilename);
	ddprintf(@"- %@ replaced with --docset-atom-filename\n", kGBTemplatePlaceholderDocSetAtomFilename);
	ddprintf(@"- %@ replaced with --docset-package-filename\n", kGBTemplatePlaceholderDocSetPackageFilename);
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
	ddprintf(@"- Discount by David Parsons\n");
	ddprintf(@"- Timing functions from Apple examples\n");
	ddprintf(@"\n");
	ddprintf(@"We'd like to thank all authors for their contribution!\n");
}

- (void)printHelpForShortOption:(NSString *)aShort longOption:(NSString *)aLong argument:(NSString *)argument description:(NSString *)description {
	while([aLong length] + [argument length] < 32) argument = [argument stringByAppendingString:@" "];
	ddprintf(@"  %@ --%@ %@ %@\n", aShort, aLong, argument, description);
}

@end
