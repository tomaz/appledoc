//
//  CommandLineParser.m
//  appledoc
//
//  Created by Tomaz Kragelj on 12.4.09.
//  Copyright 2009 Tomaz Kragelj. All rights reserved.
//

#import "CommandLineParser.h"
#import "LoggingProvider.h"
#import "Systemator.h"

#define kTKCommandLineException					@"TKCommandLineException"

#define kTKCmdGlobalTemplatesPathKey			@"GlobalTemplatesPath"			// NSString
#define kTKCmdTemplatesPathKey					@"TemplatesPath"				// NSString
#define kTKCmdCommandLineKey					@"CommandLine"					// NSString
#define kTKCmdProjectNameKey					@"ProjectName"					// NSString

#define kTKCmdInputPathKey						@"InputPath"					// NSString
#define kTKCmdOutputPathKey						@"OutputPath"					// NSString

#define kTKCmdDoxygenCommandLineKey				@"DoxygenCommandLine"			// NSString
#define kTKCmdDoxygenConfigFileKey				@"DoxygenConfigFile"			// NSString

#define kTKCmdCreateCleanXHTMLKey				@"CreateXHTML"					// NSNumber / BOOL
#define kTKCmdCreateDocSetKey					@"CreateDocSet"					// NSNumber / BOOL
#define kTKCmdCreateMarkdownKey					@"CreateMarkdown"				// NSNumber / BOOL

#define kTKCmdXHTMLBorderedExamplesKey			@"XHTMLUseBorderedExamples"		// NSNumber / BOOL
#define kTKCmdXHTMLBorderedWarningsKey			@"XHTMLUseBorderedWarnings"		// NSNumber / BOOL
#define kTKCmdXHTMLBorderedBugsKey				@"XHTMLUseBorderedBugs"			// NSNumber / BOOL

#define kTKCmdDocSetBundleIDKey					@"DocSetBundleID"				// NSString
#define kTKCmdDocSetBundleFeedKey				@"DocSetBundleFeed"				// NSString
#define kTKCmdDocSetSourcePlistKey				@"DocSetSourcePlist"			// NSString
#define kTKCmdDocSetUtilCommandLinKey			@"DocSetUtilCommandLine"		// NSString
#define kTKCmdDocSetInstallPathKey				@"DocSetInstallPath"			// NSString

#define kTKCmdMarkdownRefStyleLinksKey			@"MarkdownReferenceStyleLinks"	// NSNumber / BOOL
#define kTKCmdMarkdownLineLengthKey				@"MarkdownLineLength"			// NSNumber / int
#define kTKCmdMarkdownLineThresholdKey			@"MarkdownLineWrapThreshold"	// NSNumber / int
#define kTKCmdMarkdownLineMarginKey				@"MarkdownLineWrapMargin"		// NSNumber / int

#define kTKCmdFixClassLocationsKey				@"FixClassLocations"			// NSNumber / BOOL
#define kTKCmdRemoveEmptyParaKey				@"RemoveEmptyParagraphs"		// NSNumber / BOOL
#define kTKCmdMergeCategoriesKey				@"MergeCategories"				// NSNumber / BOOL
#define kTKCmdKeepMergedCategoriesSectionsKey	@"KeepMergedSections"			// NSNumber / BOOL

#define kTKCmdObjectRefTemplate					@"ObjectReferenceTemplate"		// NSString
#define kTKCmdMemberRefTemplate					@"MemberReferenceTemplate"		// NSString
#define kTKCmdDateTimeTemplate					@"DateTimeTemplate"				// NSString
#define kTKCmdCleanTempFilesKey					@"CleanTemporaryFilesAfterBuild"// NSNumber / BOOL
#define kTKCmdCleanBeforeBuildKey				@"CleanOutputFilesBeforeBuild"	// NSNumber / BOOL
#define kTKCmdVerboseLevelKey					@"VerboseLevel"					// NSNumber / int

#define kTKCmdEmitUtilityOutputKey				@"EmitUtilityOutput"			// NSNumber / BOOL

//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
/** Defines the methods private for the @c CommandLineParser class.
*/
@interface CommandLineParser (ClassPrivateAPI)

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Global templates handling
//////////////////////////////////////////////////////////////////////////////////////////

/** Setups the templates path.

This method checks if template files are found on one of the known locations. It searches
the following paths in this order:
- <tt>~/.appledoc/</tt>
- <tt>~/Library/Application Support/appledoc/</tt>
If all required template files are found in one of these paths, the template path is
automatically set to it.
 
This will send @c parseTemplatesPath:() message for each known location.
*/
- (void) setupGlobalTemplates;

/** Determines if the given path is a valid templates path or not.

A path is considered valid templates path if it exists and contains all required
template files. If the detected templates path also contains global parameters file 
@c Globals.plist, the file defaults are automatically read. These are all overriden by 
command line as expected. 
 
If parsing global parameters fails, error is logged but the execution continues.

@param path The path to test.
@return Returns @c YES if the given path is valid templates path, @c NO otherwise.
*/
- (BOOL) parseTemplatesPath:(NSString*) path;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Command line parsing
//////////////////////////////////////////////////////////////////////////////////////////

/** Validates command line arguments after parsing.

This function will make sure all required arguments and their values were correctly
passed to the utility through the command line. This message is automatically sent from 
@c CommandLineParser::parseCommandLineArguments:ofCount:() immediately after parsing
the command line.
 
@exception NSException Thrown if validation fails.
*/
- (void) validateCommandLineArguments;

/** Post-processes command line arguments.

This message is sent after parsing the command line is finished. It will replace all
template parameters (either from factory defaults or from globals plist) with the actual
values and will prepare all dependent values. The message is automatically sent from 
@c CommandLineParser::parseCommandLineArguments:ofCount:().
 
@see replaceTemplatePlaceholdersForKey:
@see validateCommandLineArguments
@see setupFactoryDefaults
@see setupGlobalTemplates
*/
- (void) postProcessCommandLineArguments;

/** Resets all parsed properties and variables required for parsing.
*/
- (void) setupFactoryDefaults;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Helper methods
//////////////////////////////////////////////////////////////////////////////////////////

/** Replaces template placeholders for the given @c parameters key.

This is where template placeholders from globals plist or factory defaults are replaced
with the actual values from command line. Allowed placeholders are:
- @c $PROJECT is replaced by the value from the @c --project switch.
- @c $INPUT is replaced by the value from the @c --input switch.
- @c $OUTPUT is replaced by the value from the @c --output switch.

@param key The parameters key to update.
*/
- (void) replaceTemplatePlaceholdersForKey:(NSString*) key;

/** Standardizes the path for the given @c parameters key.

This will simply replace the @c NSString value of the given key with the existing value
to which it will send @c stringByStandardizingPath message. It is just a
convenience method that makes paths handling code simpler.

@param key The parameters key to update.
*/
- (void) standardizePathForKey:(NSString*) key;

/** Parses the assigned command line for the string with the given name or shortcut.

If the argument is found, it's value is set to the @c parameters dictionary to the given
@c key. If the argument is found, but value is missing, exception is thrown. For each 
argument, only one value is possible. The value should be separated by a whitespace. The
argument may either consist of a long name (ussually started with double minus), shortcut
(ussually started with a single minus) or both. However, at least one must be passed;
the method will thrown exception if both, name and shortcut, are @c nil.
 
@param shortcut Optional shortcut of the argument ir @c nil if not used.
@param name Optional long name of the argument or @c nil if not used.
@param key The key for which to set the value if found.
@return Returns @c YES if the given option was found, @c NO otherwise.
@exception NSException Thrown if both @c name and @c shortcut are @c nil or the
	argument is found, but it doesn't have a value associated. Also thrown if the given
	@c key is @c nil.
@see parseIntegerWithShortcut:andName:forKey:
@see parseBooleanWithShortcut:andName:withValue:forKey:
*/
- (BOOL) parseStringWithShortcut:(NSString*) shortcut 
						 andName:(NSString*) name
						  forKey:(NSString*) key;

/** Parses the assigned command line for the integer with the given name or shortcut.

If the argument is found, it's value is set to the @c parameters dictionary to the given
key. If the argument is found, but value is missing, exception is thrown. For each 
argument, only one value is possible. The value should be separated by a whitespace. The 
argument may either consist of a long name (ussually started with double minus), shortcut
(ussually started with a single minus) or both. However, at least one must be passed;
the method will thrown exception if both, name and shortcut, are @c nil.
 
@param shortcut Optional shortcut of the argument ir @c nil if not used.
@param name Optional long name of the argument or @c nil if not used.
@param key The key for which to set the value if found.
@return Returns @c YES if the given option was found, @c NO otherwise.
@exception NSException Thrown if both @c name and @c shortcut are @c nil or the
	argument is found, but it doesn't have a value associated. Also thrown if the given
	@c key is @c nil.
@see parseStringWithShortcut:andName:forKey:
@see parseBooleanWithShortcut:andName:withValue:forKey:
*/
- (BOOL) parseIntegerWithShortcut:(NSString*) shortcut
						  andName:(NSString*) name
						   forKey:(NSString*) key;

/** Parses the assigned command line for the switch with the given name or shortcut.

If the switch is found, the given @c value is set to the @c parameters dictionary for the
given key. The switch may either consist of a long name (ussually started with double minus), 
shortcut (ussually started with a single minus) or both. However, at least one must be 
passed; the method will thrown exception if both, name and shortcut, are @c nil.
 
Note that in case @c name is specified, the method will automatically check if the
negative form of the option is found and will use the negated @c value in such case.
This is useful for overriding global parameters for example. If the @c name is @c --option,
the method assumes the negative form is @c --no-option. If both forms are found in the
command line, the last one encountered is used. Note that this only works properly for
option names starting with a @c -- prefix.
 
@param shortcut Optional shortcut of the switch ir @c nil if not used.
@param name Optional long name of the switch or @c nil if not used.
@param key The key for which to set the value if found.
@param value The desired value to set for the given @c key if the switch is found.
@return Returns @c YES if the given option was found, @c NO otherwise.
@exception NSException Thrown if both @c name and @c shortcut are @c nil or @c key is @c nil.
@see parseStringWithShortcut:andName:forKey:
@see parseIntegerWithShortcut:andName:forKey:
*/
- (BOOL) parseBooleanWithShortcut:(NSString*) shortcut 
						  andName:(NSString*) name
						withValue:(BOOL) value
						   forKey:(NSString*) key;

/** Logs the given command line switch usage as debug log entry.

Note that the method automatically outputs shortcut and/or name and automatically
handles the value if passed. If any of the parameters are not applicable, pass @c nil
instead.

@param shortcut Options shortcut of the switch or @c nil if not used.
@param name Optional name of the switch or @c nil if not used.
@param value Optional value of the switch or @c nil if this is boolean switch.
*/
- (void) logCmdLineSwitch:(NSString*) shortcut
				  andName:(NSString*) name
				 andValue:(NSString*) value;

@end

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////////

@implementation CommandLineParser

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Initialization & disposal
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
+ (CommandLineParser*) sharedInstance
{
	static CommandLineParser* result = nil;
	if (result == nil)
	{
		result = [[CommandLineParser alloc] init];
		
	}
	return result;
}

//----------------------------------------------------------------------------------------
- (id)init
{
	self = [super init];
	if (self)
	{
		commandLineArguments = [[NSMutableArray alloc] init];
		parameters = [[NSMutableDictionary alloc] init];
	}
	return self;
}

//----------------------------------------------------------------------------------------
- (void) dealloc
{
	[globalTemplatesPath release], globalTemplatesPath = nil;
	[commandLineArguments release], commandLineArguments = nil;
	[parameters release], parameters = nil;
	[super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Command line parsing
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) parseCommandLineArguments:(const char**) argv 
						   ofCount:(int) argc
{
	NSParameterAssert(argv != nil);
	NSParameterAssert(argc > 0);
	
	logNormal(@"Parsing command line arguments...");
	
	// Copy the command line arguments to internal array. Note that since the array
	// will retain all strings, we don't have to retain for each option separately.
	[commandLineArguments removeAllObjects];
	for (int i=0; i<argc; i++)
	{
		NSString* arg = [NSString stringWithCString:argv[i]];
		[commandLineArguments addObject:arg];
	}

	// Parse the verbose level first, so that we will correctly log as soon as possible.
	// Then log the utility command line.
	[self parseIntegerWithShortcut:@"-v" andName:@"--verbose" forKey:kTKCmdVerboseLevelKey];
	logVerbose([commandLineArguments objectAtIndex:0]);
	
	// Reset the parsing data and read the data from the global templates. This has to
	// be done after handling verbose switch, so that everything is correctly logged.
	[self setupFactoryDefaults];
	[self setupGlobalTemplates];
	
	// After factory defaults and globals are set, setup the command line (this would be
	// removed during factory defaults handling if set before) and again parse the verbose
	// switch so that it also gets properly logged...
	[parameters setObject:[commandLineArguments objectAtIndex:0] forKey:kTKCmdCommandLineKey];	
	[self parseIntegerWithShortcut:@"-v" andName:@"--verbose" forKey:kTKCmdVerboseLevelKey];
	
	// Parse custom templates path parameters, then make sure all required files are found
	// there if specified. Note that this will override global parameters if globals.plist
	// is found on the custom path...
	if ([self parseStringWithShortcut:@"-t" andName:@"--templates" forKey:kTKCmdTemplatesPathKey])
	{
		if (![self parseTemplatesPath:self.templatesPath])
		{
			NSString* message = [NSString stringWithFormat:
								 @"Custom templates path '%@' doesn't contain all required files!",
								 self.templatesPath];
			logError(@"Failed parsing custom templates path at '%@'!", self.templatesPath);
			[Systemator throwExceptionWithName:kTKCommandLineException withDescription:message];
		}
	}

	// Parse the rest of the parameters.
	[self parseStringWithShortcut:@"-p" andName:@"--project" forKey:kTKCmdProjectNameKey];
	[self parseStringWithShortcut:@"-i" andName:@"--input" forKey:kTKCmdInputPathKey];
	[self parseStringWithShortcut:@"-o" andName:@"--output" forKey:kTKCmdOutputPathKey];
	
	[self parseStringWithShortcut:@"-d" andName:@"--doxygen" forKey:kTKCmdDoxygenCommandLineKey];
	[self parseStringWithShortcut:@"-c" andName:@"--doxyfile" forKey:kTKCmdDoxygenConfigFileKey];	

	[self parseBooleanWithShortcut:nil andName:@"--xhtml" withValue:YES forKey:kTKCmdCreateCleanXHTMLKey];
	[self parseBooleanWithShortcut:nil andName:@"--docset" withValue:YES forKey:kTKCmdCreateDocSetKey];
	[self parseBooleanWithShortcut:nil andName:@"--markdown" withValue:YES forKey:kTKCmdCreateMarkdownKey];

	[self parseBooleanWithShortcut:nil andName:@"--xhtml-bordered-issues" withValue:YES forKey:kTKCmdXHTMLBorderedExamplesKey];
	[self parseBooleanWithShortcut:nil andName:@"--xhtml-bordered-issues" withValue:YES forKey:kTKCmdXHTMLBorderedWarningsKey];
	[self parseBooleanWithShortcut:nil andName:@"--xhtml-bordered-issues" withValue:YES forKey:kTKCmdXHTMLBorderedBugsKey];

	[self parseStringWithShortcut:nil andName:@"--docid" forKey:kTKCmdDocSetBundleIDKey];
	[self parseStringWithShortcut:nil andName:@"--docfeed" forKey:kTKCmdDocSetBundleFeedKey];
	[self parseStringWithShortcut:nil andName:@"--docplist" forKey:kTKCmdDocSetSourcePlistKey];
	[self parseStringWithShortcut:nil andName:@"--docutil" forKey:kTKCmdDocSetUtilCommandLinKey];

	[self parseBooleanWithShortcut:nil andName:@"--markdown-refstyle-links" withValue:YES forKey:kTKCmdMarkdownRefStyleLinksKey];
	[self parseIntegerWithShortcut:nil andName:@"--markdown-line-length" forKey:kTKCmdMarkdownLineLengthKey];
	[self parseIntegerWithShortcut:nil andName:@"--markdown-line-threshold" forKey:kTKCmdMarkdownLineThresholdKey];
	[self parseIntegerWithShortcut:nil andName:@"--markdown-line-margin" forKey:kTKCmdMarkdownLineMarginKey];

	[self parseStringWithShortcut:nil andName:@"--object-reference-template" forKey:kTKCmdObjectRefTemplate];
	[self parseStringWithShortcut:nil andName:@"--member-reference-template" forKey:kTKCmdMemberRefTemplate];
	[self parseStringWithShortcut:nil andName:@"--date-time-template" forKey:kTKCmdDateTimeTemplate];

	[self parseBooleanWithShortcut:nil andName:@"--fix-class-locations" withValue:YES forKey:kTKCmdFixClassLocationsKey];
	[self parseBooleanWithShortcut:nil andName:@"--merge-categories" withValue:YES forKey:kTKCmdMergeCategoriesKey];
	[self parseBooleanWithShortcut:nil andName:@"--keep-merged-sections" withValue:YES forKey:kTKCmdKeepMergedCategoriesSectionsKey];
	[self parseBooleanWithShortcut:nil andName:@"--remove-empty-paragraphs" withValue:YES forKey:kTKCmdRemoveEmptyParaKey];
	[self parseBooleanWithShortcut:nil andName:@"--clean-temp-files" withValue:YES forKey:kTKCmdCleanTempFilesKey];
	[self parseBooleanWithShortcut:nil andName:@"--clean-before-build" withValue:YES forKey:kTKCmdCleanBeforeBuildKey];
	
	// Parse undocumented options. These are used to debug the script.
	[self parseBooleanWithShortcut:nil andName:@"--no-utility-output" withValue:NO forKey:kTKCmdEmitUtilityOutputKey];
	
	// Validate and post process the command line arguments.
	[self validateCommandLineArguments];
	[self postProcessCommandLineArguments];

	// Log finish, write all used parameter values and make a gap if verbose settings 
	// are desired.
	logInfo(@"Finished parsing command line arguments.");
	if ([[self logger] isDebugEnabled])
	{
		logDebug(@"Settings that will be used for this run are:");
		for (NSString* key in parameters)
		{
			logDebug(@"- '%@' = '%@'", key, [parameters objectForKey:key]);
		}
	}
	logVerbose(@"");
}

//----------------------------------------------------------------------------------------
- (void) postProcessCommandLineArguments
{	
	// Standardize all paths.
	[self standardizePathForKey:kTKCmdInputPathKey];
	[self standardizePathForKey:kTKCmdOutputPathKey];
	[self standardizePathForKey:kTKCmdTemplatesPathKey];
	[self standardizePathForKey:kTKCmdDoxygenCommandLineKey];
	[self standardizePathForKey:kTKCmdDoxygenConfigFileKey];
	[self standardizePathForKey:kTKCmdDocSetSourcePlistKey];
	[self standardizePathForKey:kTKCmdDocSetUtilCommandLinKey];

	// Replace template placeholders for all possible parameters.
	[self replaceTemplatePlaceholdersForKey:kTKCmdDoxygenConfigFileKey];
	[self replaceTemplatePlaceholdersForKey:kTKCmdDocSetBundleIDKey];
	[self replaceTemplatePlaceholdersForKey:kTKCmdDocSetBundleFeedKey];
	[self replaceTemplatePlaceholdersForKey:kTKCmdDocSetSourcePlistKey];
	
	// Make sure the documentation set bundle ID ends with .docset.
	if (![self.docsetBundleID hasSuffix:@".docset"])
	{
		NSString* docsetBundleID = [self.docsetBundleID stringByAppendingPathExtension:@"docset"];
		[parameters setObject:docsetBundleID forKey:kTKCmdDocSetBundleIDKey];
	}
		
	// If documentation set output is enabled, enable also XHTML generation.
	if (self.createDocSet && !self.createCleanXHTML)
	{
		logNormal(@"Enablind XHTML creation because --docset is used!");
		[parameters setObject:[NSNumber numberWithBool:YES] forKey:kTKCmdCreateCleanXHTMLKey];
	}
	
	// Make sure remove output files is reset if output path is the same as input.
	if (self.cleanOutputFilesBeforeBuild && [self.outputPath isEqualToString:self.inputPath])
	{
		logNormal(@"Disabling --cleanbuild because output path is equal to input path!");
		[parameters setObject:[NSNumber numberWithBool:NO] forKey:kTKCmdCleanBeforeBuildKey];
	}
}

//----------------------------------------------------------------------------------------
- (void) validateCommandLineArguments
{
	// Make sure all required parameters are there.
	if (!self.projectName)
		[Systemator throwExceptionWithName:kTKCmdCommandLineKey 
						   withDescription:@"Project name is required parameter"];
	if (!self.inputPath)
		[Systemator throwExceptionWithName:kTKCmdCommandLineKey 
						   withDescription:@"Input path is required parameter"];
	if (!self.outputPath)
		[Systemator throwExceptionWithName:kTKCmdCommandLineKey 
						   withDescription:@"Output path is required parameter"];
}

//----------------------------------------------------------------------------------------
- (void) printUsage
{
	printf("USAGE: appledoc [options]\n");
	printf("VERSION: 1.0\n");
	printf("\n");
	printf("OPTIONS - required\n");
	printf("-p --project <name>\n");
	printf("-i --input <path>\n");
	printf("-o --output <path>\n");
	printf("\n");
	printf("OPTIONS - doxygen\n");
	printf("-c --doxyfile <path>\n");
	printf("-d --doxygen <path>\n");
	printf("\n");
	printf("OPTIONS - clean XML creation\n");
	printf("   --fix-class-locations\n");
	printf("   --remove-empty-paragraphs\n");
	printf("   --merge-categories\n");
	printf("   --keep-merged-sections\n");
	printf("\n");
	printf("OPTIONS - clean output creation\n");
	printf("   --xhtml\n");
	printf("   --docset\n");
	printf("   --markdown\n");
	printf("\n");
	printf("OPTIONS - XHTML output creation\n");
	printf("   --xhtml-bordered-issues\n");
	printf("\n");
	printf("OPTIONS - documentation set\n");
	printf("   --docid <id>\n");
	printf("   --docfeed <name>\n");
	printf("   --docplist <path>\n");
	printf("   --docutil <path>\n");
	printf("\n");
	printf("OPTIONS - Markdown output creation\n");
	printf("   --markdown-line-length <number>\n");
	printf("   --markdown-line-threshold <number>\n");
	printf("   --markdown-line-margin <number>\n");
	printf("   --markdown-refstyle-links\n");
	printf("\n");
	printf("OPTIONS - miscellaneous\n");
	printf("   --object-reference-template\n");
	printf("   --member-reference-template\n");
	printf("   --clean-temp-files\n");
	printf("   --clean-before-build\n");
	printf("-t --templates <path>\n");
	printf("-v --verbose <level>\n");
	printf("\n");
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Global templates handling
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) setupFactoryDefaults
{
	// Remove all parameters.
	[parameters removeAllObjects];
	
	// Setup the default documentation set installation path.
	[parameters setObject:[NSHomeDirectory() 
						   stringByAppendingPathComponent:@"Library/Developer/Shared/Documentation/DocSets"] 
				   forKey:kTKCmdDocSetInstallPathKey];
	
	// Setup default doxygen parameters.
	[parameters setObject:@"/opt/local/bin/doxygen" forKey:kTKCmdDoxygenCommandLineKey];
	[parameters setObject:@"$INPUT/Doxyfile" forKey:kTKCmdDoxygenConfigFileKey];
	
	// Setup default documentation set parameters.
	[parameters setObject:@"com.custom.$PROJECT.docset" forKey:kTKCmdDocSetBundleIDKey];
	[parameters setObject:@"Custom documentation" forKey:kTKCmdDocSetBundleFeedKey];
	[parameters setObject:@"$INPUT/DocSet-Info.plist" forKey:kTKCmdDocSetSourcePlistKey];
	[parameters setObject:@"/Developer/usr/bin/docsetutil" forKey:kTKCmdDocSetUtilCommandLinKey];
	[parameters setObject:[NSNumber numberWithBool:YES] forKey:kTKCmdCreateDocSetKey];
		
	// Setup the default verbose level and switches. Note that we would only need to
	// initialize those which default value is YES since NO is returned by default if
	// a boolValue is sent to nil object, but to make future changes more meaningful, 
	// all are included.
	[parameters setObject:[NSNumber numberWithInt:kTKVerboseLevelError] forKey:kTKCmdVerboseLevelKey];	
	[parameters setObject:[NSNumber numberWithBool:NO] forKey:kTKCmdFixClassLocationsKey];
	[parameters setObject:[NSNumber numberWithBool:NO] forKey:kTKCmdMergeCategoriesKey];
	[parameters setObject:[NSNumber numberWithBool:NO] forKey:kTKCmdKeepMergedCategoriesSectionsKey];
	[parameters setObject:[NSNumber numberWithBool:NO] forKey:kTKCmdRemoveEmptyParaKey];
	
	[parameters setObject:[NSNumber numberWithBool:NO] forKey:kTKCmdCreateCleanXHTMLKey];
	[parameters setObject:[NSNumber numberWithBool:NO] forKey:kTKCmdCreateDocSetKey];
	[parameters setObject:[NSNumber numberWithBool:NO] forKey:kTKCmdCreateMarkdownKey];
	
	[parameters setObject:[NSNumber numberWithBool:NO] forKey:kTKCmdMarkdownRefStyleLinksKey];
	[parameters setObject:[NSNumber numberWithInt:80] forKey:kTKCmdMarkdownLineLengthKey];
	[parameters setObject:[NSNumber numberWithInt:7] forKey:kTKCmdMarkdownLineThresholdKey];
	[parameters setObject:[NSNumber numberWithInt:12] forKey:kTKCmdMarkdownLineMarginKey];
	
	[parameters setObject:[NSNumber numberWithBool:NO] forKey:kTKCmdCleanTempFilesKey];
	[parameters setObject:[NSNumber numberWithBool:NO] forKey:kTKCmdCleanBeforeBuildKey];
	
	// Setup other properties.
	[parameters setObject:@"$PREFIX[$OBJECT $MEMBER]" forKey:kTKCmdObjectRefTemplate];
	[parameters setObject:@"$PREFIX $MEMBER" forKey:kTKCmdMemberRefTemplate];
	[parameters setObject:@"(Last updated: %Y-%m-%d)" forKey:kTKCmdDateTimeTemplate];
	[parameters setObject:[NSNumber numberWithBool:YES] forKey:kTKCmdEmitUtilityOutputKey];
}

//----------------------------------------------------------------------------------------
- (void) setupGlobalTemplates
{
	// Check user's root.
	globalTemplatesPath = [NSHomeDirectory() stringByAppendingPathComponent:@".appledoc"];
	logVerbose(@"Testing '%@' for templates...", globalTemplatesPath);
	if ([self parseTemplatesPath:globalTemplatesPath])
	{
		[globalTemplatesPath retain];
		return;
	}
	
	// Check application support.
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
	for (NSString* path in paths)
	{
		globalTemplatesPath = [path stringByAppendingPathComponent:@"appledoc"];
		logVerbose(@"Testing '%@' for templates...", globalTemplatesPath);
		if ([self parseTemplatesPath:globalTemplatesPath])
		{
			[globalTemplatesPath retain];
			return;
		}		
	}
	
	// Set the global templates to nil if neither location is valid.
	globalTemplatesPath = nil;
}

//----------------------------------------------------------------------------------------
- (BOOL) parseTemplatesPath:(NSString*) path
{
	NSFileManager* manager = [NSFileManager defaultManager];
	
	// First make sure the given path exists. Then check for all the required templates.
	if ([manager fileExistsAtPath:path] &&
		[manager fileExistsAtPath:[path stringByAppendingPathComponent:@"object.xslt"]] &&
		[manager fileExistsAtPath:[path stringByAppendingPathComponent:@"screen.css"]])
	{
		// If the path contains all required template files, check if it also contains
		// global parameters. If so, read them into the program.
		NSString* globalParametersFile = [path stringByAppendingPathComponent:@"Globals.plist"];
		if ([manager fileExistsAtPath:globalParametersFile])
		{
			logVerbose(@"Reading global parameters from '%@'...", globalParametersFile);
			
			@try
			{
				// Copy the global parameters into the parameters dictionary. Note that this
				// will override factory settings. Then set the path to the templates folder.
				NSDictionary* globals = [Systemator readPropertyListFromFile:globalParametersFile];
				[parameters addEntriesFromDictionary:globals];
				[parameters setObject:path forKey:kTKCmdTemplatesPathKey];
			}
			@catch (NSException* e)
			{
				logError(@"Failed reading global templates, error was %@!", [e reason]);
				return NO;
			}
		}
		return YES;
	}
	
	return NO;
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Helper methods
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) replaceTemplatePlaceholdersForKey:(NSString*) key
{
	NSString* value = [parameters objectForKey:key];
	
	value = [value stringByReplacingOccurrencesOfString:@"$PROJECT" 
											 withString:[parameters objectForKey:kTKCmdProjectNameKey]];
	value = [value stringByReplacingOccurrencesOfString:@"$INPUT" 
											 withString:[parameters objectForKey:kTKCmdInputPathKey]];
	value = [value stringByReplacingOccurrencesOfString:@"$OUTPUT" 
											 withString:[parameters objectForKey:kTKCmdOutputPathKey]];
	
	[parameters setObject:value forKey:key];
}

//----------------------------------------------------------------------------------------
- (void) standardizePathForKey:(NSString*) key
{
	NSString* value = [parameters objectForKey:key];
	[parameters setObject:[value stringByStandardizingPath] forKey:key];
}

//----------------------------------------------------------------------------------------
- (BOOL) parseStringWithShortcut:(NSString*) shortcut 
						 andName:(NSString*) name
						  forKey:(NSString*) key
{
	NSParameterAssert(name != nil || shortcut != nil);
	NSParameterAssert(key != nil);
	for (int i=1; i<[commandLineArguments count]; i++)
	{
		NSString* arg = [commandLineArguments objectAtIndex:i];
		if ([arg isEqualToString:name] || [arg isEqualToString:shortcut])
		{
			if (i == [commandLineArguments count] - 1)
			{
				NSString* reason = [NSString stringWithFormat:@"Missing parameter value for %@ / %@ switch!", 
									shortcut, 
									name];
				@throw [NSException exceptionWithName:kTKCommandLineException
											   reason:reason
											 userInfo:nil];
			}
			
			NSString* value = [commandLineArguments objectAtIndex:i+1];
			[self logCmdLineSwitch:shortcut andName:name andValue:value];
			[parameters setObject:value forKey:key];
			return YES;
		}
	}
	return NO;
}

//----------------------------------------------------------------------------------------
- (BOOL) parseIntegerWithShortcut:(NSString*) shortcut 
						  andName:(NSString*) name
						   forKey:(NSString*) key
{
	NSParameterAssert(name != nil || shortcut != nil);
	NSParameterAssert(key != nil);
	for (int i=1; i<[commandLineArguments count]; i++)
	{
		NSString* arg = [commandLineArguments objectAtIndex:i];
		if ([arg isEqualToString:name] || [arg isEqualToString:shortcut])
		{
			if (i == [commandLineArguments count] - 1)
			{
				NSString* reason = [NSString stringWithFormat:@"Missing parameter value for %@ / %@ switch!", 
									shortcut, 
									name];
				@throw [NSException exceptionWithName:kTKCommandLineException
											   reason:reason
											 userInfo:nil];
			}
			
			NSString* value = [commandLineArguments objectAtIndex:i+1];			
			[self logCmdLineSwitch:shortcut andName:name andValue:value];
			[parameters setObject:[NSNumber numberWithInt:[value intValue]] forKey:key];
			return YES;
		}
	}
	return NO;
}

//----------------------------------------------------------------------------------------
- (BOOL) parseBooleanWithShortcut:(NSString*) shortcut 
						  andName:(NSString*) name
						withValue:(BOOL) value
						   forKey:(NSString*) key
{
	NSParameterAssert(name != nil || shortcut != nil);	
	NSParameterAssert(key != nil);
	
	// Prepare the negative form of the long name.
	NSString* negative = nil;
	if (name)
	{
		negative = [name substringFromIndex:2];
		negative = [NSString stringWithFormat:@"--no-%@", negative];
	}
	
	BOOL result = NO;
	for (NSString* arg in commandLineArguments)
	{
		if ([arg isEqualToString:name] || [arg isEqualToString:shortcut])
		{
			[self logCmdLineSwitch:shortcut andName:name andValue:nil];
			[parameters setObject:[NSNumber numberWithBool:value] forKey:key];
			result = YES;
		}
		else if (negative && [arg isEqualToString:negative])
		{
			[self logCmdLineSwitch:nil andName:negative andValue:nil];
			[parameters setObject:[NSNumber numberWithBool:!value] forKey:key];
			result = YES;
		}
	}
	return result;
}

//----------------------------------------------------------------------------------------
- (void) logCmdLineSwitch:(NSString*) shortcut
				  andName:(NSString*) name
				 andValue:(NSString*) value
{
	if (self.verboseLevel >= kTKVerboseLevelInfo)
	{
		NSMutableString* output = [[NSMutableString alloc] init];
		
		// Append shortcut. If not used, use spacer.
		if (shortcut)
		{
			[output appendFormat:@"%@ ", shortcut];
			if (name) [output appendString:@"/ "];
		}
		else
		{
			[output appendString:@"     "];
		}

		
		// Append name.
		if (name)
		{
			[output appendString:name];
		}
		
		// Append value or usage.
		if (value)
			[output appendFormat:@": %@.", value];
		else
			[output appendString:@": used."];
		
		// Log the string.
		logVerbose(@"%@", output);
		[output release];
	}
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Properties - required
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (NSString*) commandLine
{
	return [parameters objectForKey:kTKCmdCommandLineKey];
}

//----------------------------------------------------------------------------------------
- (NSString*) projectName
{
	return [parameters objectForKey:kTKCmdProjectNameKey];
}

//----------------------------------------------------------------------------------------
- (NSString*) inputPath
{
	return [parameters objectForKey:kTKCmdInputPathKey];
}

//----------------------------------------------------------------------------------------
- (NSString*) outputPath
{
	return [parameters objectForKey:kTKCmdOutputPathKey];
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Properties - doxygen
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (NSString*) doxygenCommandLine
{
	return [parameters objectForKey:kTKCmdDoxygenCommandLineKey];
}

//----------------------------------------------------------------------------------------
- (NSString*) doxygenConfigFilename
{
	return [parameters objectForKey:kTKCmdDoxygenConfigFileKey];
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Properties - clean XML creation
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (BOOL) fixClassLocations
{
	return [[parameters objectForKey:kTKCmdFixClassLocationsKey] boolValue];
}

//----------------------------------------------------------------------------------------
- (BOOL) removeEmptyParagraphs
{
	return [[parameters objectForKey:kTKCmdRemoveEmptyParaKey] boolValue];
}

//----------------------------------------------------------------------------------------
- (BOOL) mergeKnownCategoriesToClasses
{
	return [[parameters objectForKey:kTKCmdMergeCategoriesKey] boolValue];
}

//----------------------------------------------------------------------------------------
- (BOOL) keepMergedCategorySections
{
	return [[parameters objectForKey:kTKCmdKeepMergedCategoriesSectionsKey] boolValue];
}

//----------------------------------------------------------------------------------------
- (NSString*) objectReferenceTemplate
{
	return [parameters objectForKey:kTKCmdObjectRefTemplate];
}

//----------------------------------------------------------------------------------------
- (NSString*) memberReferenceTemplate
{
	return [parameters objectForKey:kTKCmdMemberRefTemplate];
}

//----------------------------------------------------------------------------------------
- (NSString*) dateTimeTemplate
{
	return [parameters objectForKey:kTKCmdDateTimeTemplate];
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Properties - clean output creation
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (BOOL) createCleanXHTML
{
	return [[parameters objectForKey:kTKCmdCreateCleanXHTMLKey] boolValue];
}

//----------------------------------------------------------------------------------------
- (BOOL) createDocSet
{
	return [[parameters objectForKey:kTKCmdCreateDocSetKey] boolValue];
}

//----------------------------------------------------------------------------------------
- (BOOL) createMarkdown
{
	return [[parameters objectForKey:kTKCmdCreateMarkdownKey] boolValue];
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Properties - XHTML creation
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (BOOL) xhtmlUseBorderedExamples
{
	return [[parameters objectForKey:kTKCmdXHTMLBorderedExamplesKey] boolValue];
}

//----------------------------------------------------------------------------------------
- (BOOL) xhtmlUseBorderedWarnings
{
	return [[parameters objectForKey:kTKCmdXHTMLBorderedWarningsKey] boolValue];
}

//----------------------------------------------------------------------------------------
- (BOOL) xhtmlUseBorderedBugs
{
	return [[parameters objectForKey:kTKCmdXHTMLBorderedBugsKey] boolValue];
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Properties - documentation set creation
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (NSString*) docsetBundleID
{
	return [parameters objectForKey:kTKCmdDocSetBundleIDKey];
}
- (void) setDocsetBundleID:(NSString*) value
{
	[parameters setObject:value forKey:kTKCmdDocSetBundleIDKey];
}

//----------------------------------------------------------------------------------------
- (NSString*) docsetBundleFeed
{
	return [parameters objectForKey:kTKCmdDocSetBundleFeedKey];
}
- (void) setDocsetBundleFeed:(NSString*) value
{
	[parameters setObject:value forKey:kTKCmdDocSetBundleFeedKey];
}

//----------------------------------------------------------------------------------------
- (NSString*) docsetSourcePlistPath
{
	return [parameters objectForKey:kTKCmdDocSetSourcePlistKey];
}

//----------------------------------------------------------------------------------------
- (NSString*) docsetutilCommandLine
{
	return [parameters objectForKey:kTKCmdDocSetUtilCommandLinKey];
}

//----------------------------------------------------------------------------------------
- (NSString*) docsetInstallPath
{
	return [parameters objectForKey:kTKCmdDocSetInstallPathKey];
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Properties - Markdown creation
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (BOOL) markdownReferenceStyleLinks
{
	return [[parameters objectForKey:kTKCmdMarkdownRefStyleLinksKey] boolValue];
}

//----------------------------------------------------------------------------------------
- (int) markdownLineLength
{
	return [[parameters objectForKey:kTKCmdMarkdownLineLengthKey] intValue];
}

//----------------------------------------------------------------------------------------
- (int) markdownLineWrapThreshold
{
	return [[parameters objectForKey:kTKCmdMarkdownLineThresholdKey] intValue];
}

//----------------------------------------------------------------------------------------
- (int) markdownLineWrapMargin
{
	return [[parameters objectForKey:kTKCmdMarkdownLineMarginKey] intValue];
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Properties - miscellaneous
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (NSString*) templatesPath
{
	return [parameters objectForKey:kTKCmdTemplatesPathKey];
}

//----------------------------------------------------------------------------------------
- (BOOL) cleanTempFilesAfterBuild
{
	return [[parameters objectForKey:kTKCmdCleanTempFilesKey] boolValue];
}

//----------------------------------------------------------------------------------------
- (BOOL) cleanOutputFilesBeforeBuild
{
	return [[parameters objectForKey:kTKCmdCleanBeforeBuildKey] boolValue];
}

//----------------------------------------------------------------------------------------
- (int) verboseLevel
{
	return [[parameters objectForKey:kTKCmdVerboseLevelKey] intValue];
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Properties - undocumented
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (BOOL) emitUtilityOutput
{
	return [[parameters objectForKey:kTKCmdEmitUtilityOutputKey] boolValue];
}

@end
