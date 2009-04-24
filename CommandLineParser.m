//
//  CommandLineParser.m
//  objcdoc
//
//  Created by Tomaz Kragelj on 12.4.09.
//  Copyright 2009 Tomaz Kragelj. All rights reserved.
//

#import "CommandLineParser.h"
#import "LoggingProvider.h"

#define kTKCommandLineException @"TKCommandLineException"

//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
/** Defines the methods private for the @c CommandLineParser class.
*/
@interface CommandLineParser (ClassPrivateAPI)

/** Post-processes command line arguments.￼

This message is sent after parsing the command line is finished. It will assign default
values to optional parameters if not specified by the command line and will prepare
all dependent values. The message is automatically sent from 
@c CommandLineParser::parseCommandLineArguments:ofCount:() before @c validateCommandLineArguments().
*/
- (void) postProcessCommandLineArguments;

/** Validates command line arguments after parsing.￼

This function will make sure all required arguments and their values were correctly
passed to the utility through the command line. This message should be sent after the
whole parsing is finished. If invalid arguments are detected and exception is thrown.
This message is automatically sent from @c CommandLineParser::parseCommandLineArguments:ofCount:()
immediately after postProcessCommandLineArguments().
 
@exception ￼￼￼￼￼NSException Thrown if validation fails.
*/
- (void) validateCommandLineArguments;

/** Resets all parsed properties and variables required for parsing.￼
*/
- (void) resetParsingData;

/** Parses the assigned command line for the string￼ with the given name or shortcut.

If the argument is found, it's value is returned, otherwise @c nil is returned. If
the argument is found, but value is missing, exception is thrown. For each argument,
only one value is possible. The value should be separated by a whitespace. The argument 
may either consist of a long name (ussually started with double minus), shortcut
(ussually started with a single minus) or both. However, at least one must be passed;
the method will thrown exception if both, name and shortcut, are @c nil.
 
See also @c parseIntegerWithShortcut:andName:() and @c parseBooleanWithShortcut:andName:().
 
@param shortcut ￼￼￼￼￼￼Optional shortcut of the argument ir @c nil if not found.
@param name ￼￼￼￼￼￼Optional long name of the argument or @c nil if not found.
@return ￼￼￼￼Returns the value of the given argument, @c nil if not found.
@exception ￼￼￼￼￼NSException Thrown if both @c name and @c shortcut are @c nil or the
	argument is found, but it doesn't have a value associated.
*/
- (NSString*) parseStringWithShortcut:(NSString*) shortcut 
							  andName:(NSString*) name;

/** Parses the assigned command line for the integer￼ with the given name or shortcut.

If the argument is found, it's value is returned, otherwise @c -1 is returned. If
the argument is found, but value is missing, exception is thrown. For each argument,
only one value is possible. The value should be separated by a whitespace. The argument 
may either consist of a long name (ussually started with double minus), shortcut
(ussually started with a single minus) or both. However, at least one must be passed;
the method will thrown exception if both, name and shortcut, are @c nil.
 
See also @c parseStringWithShortcut:andName:() and @c parseBooleanWithShortcut:andName:().

@param shortcut ￼￼￼￼￼￼Optional shortcut of the argument ir @c nil if not found.
@param name ￼￼￼￼￼￼Optional long name of the argument or @c nil if not found.
@return ￼￼￼￼Returns the value of the given argument, @c -1 if not found.
@exception ￼￼￼￼￼NSException Thrown if both @c name and @c shortcut are @c nil or the
	argument is found, but it doesn't have a value associated.
*/
- (int) parseIntegerWithShortcut:(NSString*) shortcut
						 andName:(NSString*) name;

/** Parses the assigned command line for the switch￼ with the given name or shortcut.

If the switch is found, @c YES is returned, otherwise @c NO is returned. The switch
may either consist of a long name (ussually started with double minus), shortcut
(ussually started with a single minus) or both. However, at least one must be passed;
the method will thrown exception if both, name and shortcut, are @c nil.
 
See also @c parseStringWithShortcut:andName:() and @c parseIntegerWithShortcut:andName:().

@param shortcut ￼￼￼￼￼￼Optional shortcut of the switch ir @c nil if not used.
@param name ￼￼￼￼￼￼Optional long name of the switch or @c nil if not used.
@return ￼￼￼￼Returns @c YES if the given switch is found, @c NO otherwise.
@exception ￼￼￼￼￼NSException Thrown if both @c name and @c shortcut are @c nil.
*/
- (BOOL) parseBooleanWithShortcut:(NSString*) shortcut 
						  andName:(NSString*) name;

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

/** Determines if the given path is a valid templates path or not.￼

A path is considered valid templates path if it exists and contains all required
template files.

@param path ￼￼￼￼￼￼The path to test.
@return ￼￼￼￼Returns @c YES if the given path is valid templates path, @c NO otherwise.
*/
- (BOOL) testTemplatesPath:(NSString*) path;

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
		docsetInstallPath = [[NSHomeDirectory() 
							  stringByAppendingPathComponent:@"Library/Developer/Shared/Documentation/DocSets"] 
							 retain];
	}
	return self;
}

//----------------------------------------------------------------------------------------
- (void) dealloc
{
	[self resetParsingData];
	[commandLineArguments release], commandLineArguments = nil;
	[docsetInstallPath release], docsetInstallPath = nil;
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
	
	// Reset the parsing data.
	[self resetParsingData];
	
	// Copy the command line arguments to internal array. Note that since the array
	// will retain all strings, we don't have to retain for each option separately.
	for (int i=0; i<argc; i++)
	{
		NSString* arg = [NSString stringWithCString:argv[i]];
		[commandLineArguments addObject:arg];
	}
	
	// Parse the verbose level first, so that we will correctly log as soon as possible.
	// Note that we parse the level two times, so that we output the correct level for
	// this setting too.
	verboseLevel =			[self parseIntegerWithShortcut:@"-v" andName:@"--verbose"];
	
	// The first argument is always the command line.
	commandLine = [commandLineArguments objectAtIndex:0];
	logVerbose(commandLine);
	
	// Parse the rest of the parameters.
	verboseLevel =			[self parseIntegerWithShortcut:@"-v" andName:@"--verbose"];
	projectName =			[self parseStringWithShortcut:@"-p" andName:@"--project"];
	inputPath =				[self parseStringWithShortcut:@"-i" andName:@"--input"];
	outputPath =			[self parseStringWithShortcut:@"-o" andName:@"--output"];
	templatesPath =			[self parseStringWithShortcut:@"-t" andName:@"--templates"];
	doxygenCommandLine =	[self parseStringWithShortcut:@"-d" andName:@"--doxygen"];
	doxygenConfigFilename =	[self parseStringWithShortcut:@"-c" andName:@"--doxyfile"];	
	docsetBundleID =		[self parseStringWithShortcut:nil andName:@"--docid"];
	docsetBundleFeed =		[self parseStringWithShortcut:nil andName:@"--docfeed"];
	docsetSourcePlistPath = [self parseStringWithShortcut:nil andName:@"--docplist"];
	docsetutilCommandLine = [self parseStringWithShortcut:nil andName:@"--docutil"];
	removeEmptyParagraphs = ![self parseBooleanWithShortcut:nil andName:@"--no-empty-para"];
	createCleanXHTML =		![self parseBooleanWithShortcut:nil andName:@"--no-xhtml"];
	createDocSet =			![self parseBooleanWithShortcut:nil andName:@"--no-docset"];
	removeOutputFiles =		[self parseBooleanWithShortcut:nil andName:@"--cleanoutput"];
	
	// Post process and validate the command line arguments.
	[self postProcessCommandLineArguments];
	[self validateCommandLineArguments];

	// Make a gap in the logger.
	logInfo(@"Finished parsing command line arguments.");
	logVerbose(@"");
}

//----------------------------------------------------------------------------------------
- (void) postProcessCommandLineArguments
{
	// Use default values if not supplied from the command line.
	if (!doxygenConfigFilename) doxygenConfigFilename = [inputPath stringByAppendingPathComponent:@"Doxyfile"];
	if (!doxygenCommandLine) doxygenCommandLine = @"/opt/local/bin/doxygen";
	if (!docsetutilCommandLine) docsetutilCommandLine = @"/Developer/usr/bin/docsetutil";

	// Standardize all paths.
	inputPath = [inputPath stringByStandardizingPath];
	outputPath = [outputPath stringByStandardizingPath];
	templatesPath = [templatesPath stringByStandardizingPath];
	doxygenConfigFilename = [doxygenConfigFilename stringByStandardizingPath];
	doxygenCommandLine = [doxygenCommandLine stringByStandardizingPath];
	docsetutilCommandLine = [docsetutilCommandLine stringByStandardizingPath];
	docsetSourcePlistPath = [docsetSourcePlistPath stringByStandardizingPath];
	
	// Setup all dependent objects.
	outputCleanXMLPath = [[outputPath stringByAppendingPathComponent:@"cxml"] retain];
	outputCleanXHTMLPath = [[outputPath stringByAppendingPathComponent:@"cxhtml"] retain];
	outputDocSetPath = [[outputPath stringByAppendingPathComponent:@"docset"] retain];
	outputDocSetContentsPath = [[outputDocSetPath stringByAppendingPathComponent:@"Contents"] retain];
	outputDocSetResourcesPath = [[outputDocSetContentsPath stringByAppendingPathComponent:@"Resources"] retain];
	outputDocSetDocumentsPath = [[outputDocSetResourcesPath stringByAppendingPathComponent:@"Documents"] retain];
	
	// Setup DocSet related parameters.
	if (!docsetBundleID) docsetBundleID = [NSString stringWithFormat:@"com.customdocset.%@.docset", projectName];
	if (!docsetBundleFeed) docsetBundleFeed = @"Custom documentation";
	if (!docsetSourcePlistPath) docsetSourcePlistPath = [inputPath stringByAppendingPathComponent:@"DocSet-Info.plist"];
	if (![docsetBundleID hasSuffix:@".docset"]) docsetBundleID = [docsetBundleID stringByAppendingString:@".docset"];
	if (createDocSet && !createCleanXHTML)
	{
		logNormal(@"Disabling DocSet creation because --no-xhtml is used!");
		createDocSet = NO;		
	}
	
	// Make sure remove output files is reset if output path is the same as input.
	if (removeOutputFiles && [outputPath isEqualToString:inputPath])
	{
		logNormal(@"Disabling --clearoutput because output path is equal to input path!");
		removeOutputFiles = NO;
	}
}

//----------------------------------------------------------------------------------------
- (void) validateCommandLineArguments
{
	// Make sure all required parameters are there.
	if (!self.projectName)
		@throw [NSException exceptionWithName:kTKCommandLineException
									   reason:@"Project name is missing" 
									 userInfo:nil];
	if (!self.inputPath)
		@throw [NSException exceptionWithName:kTKCommandLineException
									   reason:@"Input path is missing" 
									 userInfo:nil];
	if (!self.outputPath)
		@throw [NSException exceptionWithName:kTKCommandLineException
									   reason:@"Output path is missing" 
									 userInfo:nil];
	
	// If templates path is not provided through command line, check default locations.
	// First check the user home then application support directory. If neither exists, 
	// report error.
	if (!self.templatesPath) 
	{
		templatesPath = [NSHomeDirectory() stringByAppendingPathComponent:@".objcdoc"];
		logVerbose(@"Testing '%@' for templates...", templatesPath);
		if ([self testTemplatesPath:templatesPath]) return;
		
		NSArray* paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
		for (NSString* path in paths)
		{
			templatesPath = [path stringByAppendingPathComponent:@"objcdoc"];
			logVerbose(@"Testing '%@' for templates...", templatesPath);
			if ([self testTemplatesPath:templatesPath]) return;
		}
		
		logError(@"Templates not found on standard paths and custom path was not provided!");
		@throw [NSException exceptionWithName:kTKCommandLineException 
									   reason:@"Templates path not found"
									 userInfo:nil];
	}	
}

//----------------------------------------------------------------------------------------
- (void) resetParsingData
{
	// Cleanup the command line arguments array and nil-lify the links.
	[commandLineArguments removeAllObjects];
	commandLine = nil;
	projectName = nil;
	inputPath = nil;
	outputPath = nil;
	templatesPath = nil;
	doxygenCommandLine = nil;
	doxygenConfigFilename = nil;
	docsetBundleID = nil;
	docsetBundleFeed = nil;
	docsetSourcePlistPath = nil;
	docsetutilCommandLine = nil;
	verboseLevel = kTKVerboseLevelNormal;
	removeOutputFiles = NO;
	removeEmptyParagraphs = YES;
	createCleanXHTML = YES;
	createDocSet = YES;
	
	// Cleanup all composed objects.
	[outputCleanXMLPath release], outputCleanXMLPath = nil;
	[outputCleanXHTMLPath release], outputCleanXHTMLPath = nil;
	[outputDocSetPath release], outputDocSetPath = nil;
	[outputDocSetContentsPath release], outputDocSetContentsPath = nil;
	[outputDocSetResourcesPath release], outputDocSetResourcesPath = nil;
	[outputDocSetDocumentsPath release], outputDocSetDocumentsPath = nil;
}

//----------------------------------------------------------------------------------------
- (void) printUsage
{
	printf("USAGE: objcdoc [options]\n");
	printf("\n");
	printf("OPTIONS - Required\n");
	printf("-p --project <name>  The project name.\n");
	printf("-i --input <path>    Source files path.\n");
	printf("-o --output <path>   Path in which to create documentation.\n");
	printf("\n");
	printf("OPTIONS - Input and output paths\n");
	printf("-t --templates <path>Full path to template files. If not provided, templates are'.\n");
	printf("                     searched in ~/.objcdoc or ~/Library/Application Support/objcdoc\n");
	printf("                     directories in the given order.\n");
	printf("   --no-xhtml        Don't create clean XHTML files (this will also disable DocSet!).\n");
	printf("\n");
	printf("OPTIONS - Doxygen\n");
	printf("-c --doxyfile <path> Name of the doxgen config file. Defaults to '<input>/Doxyfile'.\n");
	printf("-d --doxygen <path>  Full path to doxgen command. Defaults to '/opt/local/bin/doxygen'.\n");
	printf("\n");
	printf("OPTIONS - Documentation set\n");
	printf("To create the DocSet, XHTML and DocSet creation must not be disabled (don't\n");
	printf("use --no-xhtml or --no-docset options).\n");
	printf("   --docid <id>      DocSet bundle id. Defaults to 'com.customdocset.<project>.docset'.\n");
	printf("   --docfeed <name>  DocSet feed name. Defaults to 'Custom documentation'.\n");
	printf("   --docplist <path> Full path to DocSet plist file. Defaults to '<input>/DocSet-Info.plist'.\n");
	printf("   --docutil <path>  Full path to docsetutils. Defaults to '/Developer/usr/bin/docsetutils'.\n");
	printf("   --no-docset       Don't create DocSet.\n");
	printf("\n");
	printf("OPTIONS - Miscellaneous\n");
	printf("-v --verbose <level> The verbose level (1-4). Defaults to 2.\n");
	printf("   --no-empty-para   Do not delete empty paragraphs.\n");
	printf("   --cleanoutput     Remove output files before starting. This option should\n");
	printf("                     only be used if output is generated in a separate directory.\n");
	printf("                     It will remove the whole directory structure starting with\n");
	printf("                     the <output> path! BE CAREFUL!!! Note that this option is automatically\n");
	printf("                     disabled if --output directory is not specified or is set to.\n");
	printf("                     current directory.\n");
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
	printf("objcdoc\n");
	printf("--project \"$PROJECT_NAME\"\n");
	printf("--input \"$SRCROOT\"\n");
	printf("--output \"$BUILD_DIR/Help/$PROJECT_NAME\"\n");
	printf("--cleanoutput\n");
	printf("\n");
	printf("This command line is useful as the script within custom Xcode run script phase\n");
	printf("in cases where the 'Place Build Products In' option is set to 'Project directory'.\n");
	printf("It will create a directory named 'Help' inside the project source directory in\n");
	printf("which all documentation files will be created:\n");
	printf("objcdoc\n");
	printf("--project \"$PROJECT_NAME\"\n");
	printf("--input \"$SRCROOT\"\n");
	printf("--output \"$SRCROOT/Help\"\n");
	printf("--cleanoutput\n");
	printf("\n");
	printf("Note that in both examples --cleanoutput is used. It is safe to remove documentation.\n");
	printf("files in these two cases sicer the --output path is different from source files.\n");
}

//----------------------------------------------------------------------------------------
- (NSString*) parseStringWithShortcut:(NSString*) shortcut 
							  andName:(NSString*) name
{
	NSParameterAssert(name != nil || shortcut != nil);
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
			return value;
		}
	}
	return nil;
}

//----------------------------------------------------------------------------------------
- (int) parseIntegerWithShortcut:(NSString*) shortcut
						 andName:(NSString*) name
{
	NSParameterAssert(name != nil || shortcut != nil);
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
			return [value intValue];
		}
	}
	return -1;
}

//----------------------------------------------------------------------------------------
- (BOOL) parseBooleanWithShortcut:(NSString*) shortcut 
						  andName:(NSString*) name
{
	NSParameterAssert(name != nil || shortcut != nil);	
	for (NSString* arg in commandLineArguments)
	{
		if ([arg isEqualToString:name] || [arg isEqualToString:shortcut])
		{
			[self logCmdLineSwitch:shortcut andName:name andValue:nil];
			return YES;
		}
	}
	return NO;
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

//----------------------------------------------------------------------------------------
- (BOOL) testTemplatesPath:(NSString*) path
{
	NSFileManager* manager = [NSFileManager defaultManager];
	
	// First make sure the given path exists. Then check for all the required templates.
	if ([manager fileExistsAtPath:path] &&
		[manager fileExistsAtPath:[path stringByAppendingPathComponent:@"object.xslt"]] &&
		[manager fileExistsAtPath:[path stringByAppendingPathComponent:@"object2xhtml.xslt"]] &&
		[manager fileExistsAtPath:[path stringByAppendingPathComponent:@"index2xhtml.xslt"]] &&
		[manager fileExistsAtPath:[path stringByAppendingPathComponent:@"screen.css"]])
	{
		return YES;
	}
	
	return NO;
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Properties
//////////////////////////////////////////////////////////////////////////////////////////

@synthesize commandLine;
@synthesize projectName;
@synthesize inputPath;
@synthesize outputPath;
@synthesize templatesPath;
@synthesize outputCleanXMLPath;
@synthesize outputCleanXHTMLPath;
@synthesize outputDocSetPath;
@synthesize outputDocSetContentsPath;
@synthesize outputDocSetResourcesPath;
@synthesize outputDocSetDocumentsPath;
@synthesize doxygenCommandLine;
@synthesize doxygenConfigFilename;
@synthesize docsetBundleID;
@synthesize docsetBundleFeed;
@synthesize docsetInstallPath;
@synthesize docsetSourcePlistPath;
@synthesize docsetutilCommandLine;
@synthesize verboseLevel;
@synthesize removeOutputFiles;
@synthesize removeEmptyParagraphs;
@synthesize createCleanXHTML;
@synthesize createDocSet;

@end
