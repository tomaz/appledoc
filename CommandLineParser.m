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

#define kTKCommandLineException @"TKCommandLineException"

#define kTKCmdGlobalTemplatesPathKey		@"GlobalTemplatesPath"			// NSString
#define kTKCmdTemplatesPathKey				@"TemplatesPath"				// NSString
#define kTKCmdCommandLineKey				@"CommandLine"					// NSString
#define kTKCmdProjectNameKey				@"ProjectName"					// NSString

#define kTKCmdInputPathKey					@"InputPath"					// NSString
#define kTKCmdOutputPathKey					@"OutputPath"					// NSString
#define kTKCmdOutputCleanXMLPathKey			@"OutputCleanXMLPath"			// NSString
#define kTKCmdOutputCleanXHTMLPathKey		@"OutputCleanXHTMLPath"			// NSString
#define kTKCmdOutputDocSetPathKey			@"OutputDocSetPath"				// NSString
#define kTKCmdOutputDocSetContentsPathKey	@"OutputDocSetContentsPath"		// NSString
#define kTKCmdOutputDocSetResourcesPathKey	@"OutputDocSetResourcesPath"	// NSString
#define kTKCmdOutputDocSetDocumentsPathKey	@"OutputDocSetDocumentsPath"	// NSString

#define kTKCmdDoxygenCommandLineKey			@"DoxygenCommandLine"			// NSString
#define kTKCmdDoxygenConfigFileKey			@"DoxygenConfigFile"			// NSString

#define kTKCmdDocSetBundleIDKey				@"DocSetBundleID"				// NSString
#define kTKCmdDocSetBundleFeedKey			@"DocSetBundleFeed"				// NSString
#define kTKCmdDocSetSourcePlistKey			@"DocSetSourcePlist"			// NSString
#define kTKCmdDocSetUtilCommandLinKey		@"DocSetUtilCommandLine"		// NSString
#define kTKCmdDocSetInstallPathKey			@"DocSetInstallPath"			// NSString

#define kTKCmdVerboseLevelKey				@"VerboseLevel"					// NSNumber / int
#define kTKCmdRemoveTempFilesKey			@"RemoveTempFiles"				// NSNumber / BOOL
#define kTKCmdRemoveOutputFilesKey			@"RemoveOutputFiles"			// NSNumber / BOOL
#define kTKCmdRemoveEmptyParaKey			@"RemoveEmptyPara"				// NSNumber / BOOL
#define kTKCmdMergeCategoriesKey			@"MergeCategories"				// NSNumber / BOOL
#define kTKCmdKeepCatSectionsKey			@"KeepCatSections"				// NSNumber / BOOL
#define kTKCmdCreateCleanXHTMLKey			@"CreateCleanXHTML"				// NSNumber / BOOL
#define kTKCmdCreateDocSetKey				@"CreateDocSet"					// NSNumber / BOOL

#define kTKCmdEmitUtilityOutputKey			@"EmitUtilityOutput"			// NSNumber / BOOL

//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
/** Defines the methods private for the @c CommandLineParser class.
*/
@interface CommandLineParser (ClassPrivateAPI)

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Global templates handling
//////////////////////////////////////////////////////////////////////////////////////////

/** Setups the templates path.￼

This method checks if template files are found on one of the known locations. It searches
the following paths in this order:
- <tt>~/.appledoc/</tt>
- <tt>~/Library/Application Support/appledoc/</tt>
If all required template files are found in one of these paths, the template path is
automatically set to it.
 
This will send @c parseTemplatesPath:() message for each known location.
*/
- (void) setupGlobalTemplates;

/** Determines if the given path is a valid templates path or not.￼

A path is considered valid templates path if it exists and contains all required
template files. If the detected templates path also contains global parameters file 
@c Globals.plist, the file defaults are automatically read. These are all overriden by 
command line as expected. 
 
If parsing global parameters fails, error is logged but the execution continues.

@param path ￼￼￼￼￼￼The path to test.
@return ￼￼￼￼Returns @c YES if the given path is valid templates path, @c NO otherwise.
*/
- (BOOL) parseTemplatesPath:(NSString*) path;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Command line parsing
//////////////////////////////////////////////////////////////////////////////////////////

/** Validates command line arguments after parsing.￼

This function will make sure all required arguments and their values were correctly
passed to the utility through the command line. This message is automatically sent from 
@c CommandLineParser::parseCommandLineArguments:ofCount:() immediately after parsing
the command line.
 
@exception ￼￼￼￼￼NSException Thrown if validation fails.
*/
- (void) validateCommandLineArguments;

/** Post-processes command line arguments.￼

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

/** Resets all parsed properties and variables required for parsing.￼
*/
- (void) setupFactoryDefaults;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Helper methods
//////////////////////////////////////////////////////////////////////////////////////////

/** Replaces template placeholders for the given @c parameters key.￼

This is where template placeholders from globals plist or factory defaults are replaced
with the actual values from command line. Allowed placeholders are:
- @c $PROJECT is replaced by the value from the @c --project switch.
- @c $INPUT is replaced by the value from the @c --input switch.
- @c $OUTPUT is replaced by the value from the @c --output switch.

@param key ￼￼￼￼￼￼The parameters key to update.
*/
- (void) replaceTemplatePlaceholdersForKey:(NSString*) key;

/** Standardizes the path for the given @c parameters key.￼

This will simply replace the @c NSString value of the given key with the existing value
to which it will send @c NSString::stringByStandardizingPath() message. It is just a
convenience method that makes paths handling code simpler.

@param key ￼￼￼￼￼￼The parameters key to update.
*/
- (void) standardizePathForKey:(NSString*) key;

/** Parses the assigned command line for the string￼ with the given name or shortcut.

If the argument is found, it's value is set to the @c parameters dictionary to the given
@c key. If the argument is found, but value is missing, exception is thrown. For each 
argument, only one value is possible. The value should be separated by a whitespace. The
argument may either consist of a long name (ussually started with double minus), shortcut
(ussually started with a single minus) or both. However, at least one must be passed;
the method will thrown exception if both, name and shortcut, are @c nil.
 
@param shortcut ￼￼￼￼￼￼Optional shortcut of the argument ir @c nil if not used.
@param name ￼￼￼￼￼￼Optional long name of the argument or @c nil if not used.
@param key The key for which to set the value if found.
@exception ￼￼￼￼￼NSException Thrown if both @c name and @c shortcut are @c nil or the
	argument is found, but it doesn't have a value associated. Also thrown if the given
	@c key is @c nil.
@see parseIntegerWithShortcut:andName:forKey:
@see parseBooleanWithShortcut:andName:withValue:forKey:
*/
- (void) parseStringWithShortcut:(NSString*) shortcut 
						 andName:(NSString*) name
						  forKey:(NSString*) key;

/** Parses the assigned command line for the integer￼ with the given name or shortcut.

If the argument is found, it's value is set to the @c parameters dictionary to the given
key. If the argument is found, but value is missing, exception is thrown. For each 
argument, only one value is possible. The value should be separated by a whitespace. The 
argument may either consist of a long name (ussually started with double minus), shortcut
(ussually started with a single minus) or both. However, at least one must be passed;
the method will thrown exception if both, name and shortcut, are @c nil.
 
@param shortcut ￼￼￼￼￼￼Optional shortcut of the argument ir @c nil if not used.
@param name ￼￼￼￼￼￼Optional long name of the argument or @c nil if not used.
@param key The key for which to set the value if found.
@exception ￼￼￼￼￼NSException Thrown if both @c name and @c shortcut are @c nil or the
	argument is found, but it doesn't have a value associated. Also thrown if the given
	@c key is @c nil.
@see parseStringWithShortcut:andName:forKey:
@see parseBooleanWithShortcut:andName:withValue:forKey:
*/
- (void) parseIntegerWithShortcut:(NSString*) shortcut
						  andName:(NSString*) name
						   forKey:(NSString*) key;

/** Parses the assigned command line for the switch￼ with the given name or shortcut.

If the switch is found, the given @c value is set to the @c parameters dictionary for the
given key. The switch may either consist of a long name (ussually started with double minus), 
shortcut (ussually started with a single minus) or both. However, at least one must be 
passed; the method will thrown exception if both, name and shortcut, are @c nil.
 
@param shortcut ￼￼￼￼￼￼Optional shortcut of the switch ir @c nil if not used.
@param name ￼￼￼￼￼￼Optional long name of the switch or @c nil if not used.
@param key The key for which to set the value if found.
@param value The desired value to set for the given @c key if the switch is found.
@exception ￼￼￼￼￼NSException Thrown if both @c name and @c shortcut are @c nil or @c key is @c nil.
@see parseStringWithShortcut:andName:forKey:
@see parseIntegerWithShortcut:andName:forKey:
*/
- (void) parseBooleanWithShortcut:(NSString*) shortcut 
						  andName:(NSString*) name
						withValue:(BOOL) value
						   forKey:(NSString*) key;

/** Logs the given command line switch usage as debug log entry.￼

Note that the method automatically outputs shortcut and/or name and automatically
handles the value if passed. If any of the parameters are not applicable, pass @c nil
instead.

@param shortcut ￼￼￼￼￼￼Options shortcut of the switch or @c nil if not used.
@param name ￼￼￼￼￼￼Optional name of the switch or @c nil if not used.
@param value ￼￼￼￼￼￼Optional value of the switch or @c nil if this is boolean switch.
*/
- (void) logCmdLineSwitch:(NSString*) shortcut
				  andName:(NSString*) name
				 andValue:(NSString*) value;

@end

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
	
	// Parse the rest of the parameters.
	[self parseStringWithShortcut:@"-p" andName:@"--project" forKey:kTKCmdProjectNameKey];
	[self parseStringWithShortcut:@"-i" andName:@"--input" forKey:kTKCmdInputPathKey];
	[self parseStringWithShortcut:@"-o" andName:@"--output" forKey:kTKCmdOutputPathKey];
	[self parseStringWithShortcut:@"-t" andName:@"--templates" forKey:kTKCmdTemplatesPathKey];
	
	[self parseStringWithShortcut:@"-d" andName:@"--doxygen" forKey:kTKCmdDoxygenCommandLineKey];
	[self parseStringWithShortcut:@"-c" andName:@"--doxyfile" forKey:kTKCmdDoxygenConfigFileKey];
	

	[self parseStringWithShortcut:nil andName:@"--docid" forKey:kTKCmdDocSetBundleIDKey];
	[self parseStringWithShortcut:nil andName:@"--docfeed" forKey:kTKCmdDocSetBundleFeedKey];
	[self parseStringWithShortcut:nil andName:@"--docplist" forKey:kTKCmdDocSetSourcePlistKey];
	[self parseStringWithShortcut:nil andName:@"--docutil" forKey:kTKCmdDocSetUtilCommandLinKey];

	[self parseBooleanWithShortcut:nil andName:@"--no-cat-merge" withValue:NO forKey:kTKCmdMergeCategoriesKey];
	[self parseBooleanWithShortcut:nil andName:@"--keep-cat-sec" withValue:YES forKey:kTKCmdKeepCatSectionsKey];
	[self parseBooleanWithShortcut:nil andName:@"--no-xhtml" withValue:NO forKey:kTKCmdCreateCleanXHTMLKey];
	[self parseBooleanWithShortcut:nil andName:@"--no-docset" withValue:NO forKey:kTKCmdCreateDocSetKey];
	[self parseBooleanWithShortcut:nil andName:@"--no-empty-para" withValue:NO forKey:kTKCmdRemoveEmptyParaKey];
	[self parseBooleanWithShortcut:nil andName:@"--cleantemp" withValue:YES forKey:kTKCmdRemoveTempFilesKey];
	[self parseBooleanWithShortcut:nil andName:@"--cleanbuild" withValue:YES forKey:kTKCmdRemoveOutputFilesKey];
	
	// Parse undocumented options. These are used to debug the script.
	[self parseBooleanWithShortcut:nil andName:@"--no-util-output" withValue:NO forKey:kTKCmdEmitUtilityOutputKey];
	
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
	
	// Replace template placeholders for all dependent parameters.
	[self replaceTemplatePlaceholdersForKey:kTKCmdOutputCleanXMLPathKey];
	[self replaceTemplatePlaceholdersForKey:kTKCmdOutputCleanXHTMLPathKey];
	[self replaceTemplatePlaceholdersForKey:kTKCmdOutputDocSetPathKey];
	[self replaceTemplatePlaceholdersForKey:kTKCmdOutputDocSetContentsPathKey];
	[self replaceTemplatePlaceholdersForKey:kTKCmdOutputDocSetResourcesPathKey];
	[self replaceTemplatePlaceholdersForKey:kTKCmdOutputDocSetDocumentsPathKey];
	
	// Make sure the documentation set bundle ID ends with .docset.
	if (![self.docsetBundleID hasSuffix:@".docset"])
	{
		NSString* docsetBundleID = [self.docsetBundleID stringByAppendingPathExtension:@"docset"];
		[parameters setObject:docsetBundleID forKey:kTKCmdDocSetBundleIDKey];
	}
		
	// If html output is disabled, disable also documentation set generation.
	if (self.createDocSet && !self.createCleanXHTML)
	{
		logNormal(@"Disabling DocSet creation because --no-xhtml is used!");
		[parameters setObject:[NSNumber numberWithBool:NO] forKey:kTKCmdCreateDocSetKey];
	}
	
	// Make sure remove output files is reset if output path is the same as input.
	if (self.removeOutputFiles && [self.outputPath isEqualToString:self.inputPath])
	{
		logNormal(@"Disabling --cleanoutput because output path is equal to input path!");
		[parameters setObject:[NSNumber numberWithBool:NO] forKey:kTKCmdRemoveOutputFilesKey];
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
	printf("\n");
	printf("OPTIONS - required\n");
	printf("-p --project <name>  The project name.\n");
	printf("-i --input <path>    Source files path.\n");
	printf("-o --output <path>   Path in which to create documentation.\n");
	printf("\n");
	printf("OPTIONS - doxygen\n");
	printf("-c --doxyfile <path> Name of the doxgen config file. Defaults to '<input>/Doxyfile'.\n");
	printf("-d --doxygen <path>  Full path to doxgen command. Defaults to '/opt/local/bin/doxygen'.\n");
	printf("\n");
	printf("OPTIONS - clean XML creation\n");
	printf("   --no-empty-para   Do not delete empty paragraphs.\n");
	printf("   --no-cat-merge    Do not merge category documentation to their classes.\n");
	printf("   --keep-cat-sec    When merging category documentation preserve all category sections.\n");
	printf("                     By default each category is merged into a since section within the class.\n");
	printf("\n");
	printf("OPTIONS - clean HTML creation\n");
	printf("   --no-xhtml        Don't create clean XHTML files (this will also disable DocSet!).\n");
	printf("\n");
	printf("OPTIONS - documentation set\n");
	printf("   --docid <id>      DocSet bundle id. Defaults to 'com.custom.<project>.docset'.\n");
	printf("   --docfeed <name>  DocSet feed name. Defaults to 'Custom documentation'.\n");
	printf("   --docplist <path> Full path to DocSet plist file. Defaults to '<input>/DocSet-Info.plist'.\n");
	printf("   --docutil <path>  Full path to docsetutils. Defaults to '/Developer/usr/bin/docsetutils'.\n");
	printf("   --no-docset       Don't create DocSet.\n");
	printf("\n");
	printf("OPTIONS - miscellaneous\n");
	printf("   --cleantemp       Remove all temporary build files. Note that this is dynamic and will\n");
	printf("                     delete generated files based on what is build. If html is created, all\n");
	printf("                     doxygen and clean xml is removed. If doc set is installed, the whole\n");
	printf("                     output path is removed.\n");
	printf("   --cleanbuild      Remove output files before build. This option should only be used if\n");
	printf("                     output is generated in a separate directory. It will remove the whole\n");
	printf("                     directory structure starting with the <output> path! BE CAREFUL!!!\n");
	printf("                     Note that this option is automatically disabled if <output> and\n");
	printf("                     <input> directories are the same.\n");
	printf("-t --templates <path>Full path to template files. If not provided, templates are'.\n");
	printf("                     searched in ~/.appledoc or ~/Library/Application Support/appledoc\n");
	printf("                     directories in the given order. The templates path is also checked\n");
	printf("                     for 'globals.plist' file that contains default global parameters.\n");
	printf("                     Global parameters are overriden by command line arguments.\n");
	printf("-v --verbose <level> The verbose level (1-4). Defaults to 0 (only errors).\n");
	printf("\n");
	printf("EXAMPLES:\n");
	printf("Note that the examples below show each option in it's own line to make the\n");
	printf("output more readable. In real usage, the options should only be separated by\n");
	printf("a space!\n");
	printf("\n");
	printf("This command line is useful as the script within custom Xcode run script phase\n");
	printf("in cases where the 'Place Build Products In' option is set to 'Customized location'.\n");
	printf("It will create a directory named 'Help' alongside 'Debug' and 'Release' in the\n");
	printf("specified custom location. Inside it will create a sub directory named after the\n");
	printf("project name in which all documentation files will be created:\n");
	printf("appledoc\n");
	printf("--project \"$PROJECT_NAME\"\n");
	printf("--input \"$SRCROOT\"\n");
	printf("--output \"$BUILD_DIR/Help/$PROJECT_NAME\"\n");
	printf("--cleanoutput\n");
	printf("\n");
	printf("This command line is useful as the script within custom Xcode run script phase\n");
	printf("in cases where the 'Place Build Products In' option is set to 'Project directory'.\n");
	printf("It will create a directory named 'Help' inside the project source directory in\n");
	printf("which all documentation files will be created:\n");
	printf("appledoc\n");
	printf("--project \"$PROJECT_NAME\"\n");
	printf("--input \"$SRCROOT\"\n");
	printf("--output \"$SRCROOT/Help\"\n");
	printf("--cleanoutput\n");
	printf("\n");
	printf("Note that in both examples --cleanoutput is used. It is safe to remove documentation.\n");
	printf("files in these two cases since the --output path is different from source files.\n");
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
	
	// Setup dependencies, note that we use template placeholders...
	[parameters setObject:@"$OUTPUT/cxml" forKey:kTKCmdOutputCleanXMLPathKey];
	[parameters setObject:@"$OUTPUT/cxhtml" forKey:kTKCmdOutputCleanXHTMLPathKey];
	[parameters setObject:@"$OUTPUT/docset" forKey:kTKCmdOutputDocSetPathKey];
	[parameters setObject:@"$OUTPUT/docset/Contents" forKey:kTKCmdOutputDocSetContentsPathKey];
	[parameters setObject:@"$OUTPUT/docset/Contents/Resources" forKey:kTKCmdOutputDocSetResourcesPathKey];
	[parameters setObject:@"$OUTPUT/docset/Contents/Resources/Documents" forKey:kTKCmdOutputDocSetDocumentsPathKey];
	
	// Setup the default verbose level and switches. Note that we would only need to
	// initialize those which default value is YES since NO is returned by default if
	// a boolValue is sent to nil object, but to make future changes more meaningful, 
	// all are included.
	[parameters setObject:[NSNumber numberWithInt:kTKVerboseLevelError] forKey:kTKCmdVerboseLevelKey];	
	[parameters setObject:[NSNumber numberWithBool:YES] forKey:kTKCmdMergeCategoriesKey];
	[parameters setObject:[NSNumber numberWithBool:NO] forKey:kTKCmdKeepCatSectionsKey];
	[parameters setObject:[NSNumber numberWithBool:YES] forKey:kTKCmdCreateCleanXHTMLKey];
	[parameters setObject:[NSNumber numberWithBool:YES] forKey:kTKCmdRemoveEmptyParaKey];
	[parameters setObject:[NSNumber numberWithBool:NO] forKey:kTKCmdRemoveTempFilesKey];
	[parameters setObject:[NSNumber numberWithBool:NO] forKey:kTKCmdRemoveOutputFilesKey];
	
	// Setup undocumented properties.
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
		[manager fileExistsAtPath:[path stringByAppendingPathComponent:@"object2xhtml.xslt"]] &&
		[manager fileExistsAtPath:[path stringByAppendingPathComponent:@"index2xhtml.xslt"]] &&
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
- (void) parseStringWithShortcut:(NSString*) shortcut 
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
			return;
		}
	}
}

//----------------------------------------------------------------------------------------
- (void) parseIntegerWithShortcut:(NSString*) shortcut 
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
			return;
		}
	}
}

//----------------------------------------------------------------------------------------
- (void) parseBooleanWithShortcut:(NSString*) shortcut 
						  andName:(NSString*) name
						withValue:(BOOL) value
						   forKey:(NSString*) key
{
	NSParameterAssert(name != nil || shortcut != nil);	
	NSParameterAssert(key != nil);
	for (NSString* arg in commandLineArguments)
	{
		if ([arg isEqualToString:name] || [arg isEqualToString:shortcut])
		{
			[self logCmdLineSwitch:shortcut andName:name andValue:nil];
			[parameters setObject:[NSNumber numberWithBool:value] forKey:key];
			return;
		}
	}
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
- (BOOL) keepCategorySections
{
	return [[parameters objectForKey:kTKCmdKeepCatSectionsKey] boolValue];
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Properties - clean HTML creation
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (BOOL) createCleanXHTML
{
	return [[parameters objectForKey:kTKCmdCreateCleanXHTMLKey] boolValue];
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

//----------------------------------------------------------------------------------------
- (BOOL) createDocSet
{
	return [[parameters objectForKey:kTKCmdCreateDocSetKey] boolValue];
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
- (BOOL) removeTemporaryFiles
{
	return [[parameters objectForKey:kTKCmdRemoveTempFilesKey] boolValue];
}

//----------------------------------------------------------------------------------------
- (BOOL) removeOutputFiles
{
	return [[parameters objectForKey:kTKCmdRemoveOutputFilesKey] boolValue];
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

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Properties - internal
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (NSString*) outputCleanXMLPath
{
	return [parameters objectForKey:kTKCmdOutputCleanXMLPathKey];
}

//----------------------------------------------------------------------------------------
- (NSString*) outputCleanXHTMLPath
{
	return [parameters objectForKey:kTKCmdOutputCleanXHTMLPathKey];
}

//----------------------------------------------------------------------------------------
- (NSString*) outputDocSetPath
{
	return [parameters objectForKey:kTKCmdOutputDocSetPathKey];
}

//----------------------------------------------------------------------------------------
- (NSString*) outputDocSetContentsPath
{
	return [parameters objectForKey:kTKCmdOutputDocSetContentsPathKey];
}

//----------------------------------------------------------------------------------------
- (NSString*) outputDocSetResourcesPath
{
	return [parameters objectForKey:kTKCmdOutputDocSetResourcesPathKey];
}

//----------------------------------------------------------------------------------------
- (NSString*) outputDocSetDocumentsPath
{
	return [parameters objectForKey:kTKCmdOutputDocSetDocumentsPathKey];
}

@end
