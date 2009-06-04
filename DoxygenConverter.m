//
//  DoxygenConverter.m
//  appledoc
//
//  Created by Tomaz Kragelj on 11.4.09.
//  Copyright 2009 Tomaz Kragelj. All rights reserved.
//

#import "DoxygenConverter.h"
#import "Systemator.h"
#import "LoggingProvider.h"
#import "CommandLineParser.h"

#import "DoxygenConverter+Doxygen.h"
#import "DoxygenConverter+CleanXML.h"
#import "DoxygenConverter+CleanOutput.h"
#import "DoxygenConverter+DocSet.h"
#import "DoxygenConverter+Helpers.h"

//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
/** Declares methods private for the @c DoxygenConverter class.
*/
@interface DoxygenConverter (ClassPrivateAPI)

/** Creates all required output directories and optionally removes all existing files.

This makes sure file renames and deletes are properly handled - doxygen doesn't delete 
these. This actually doesn't present any problem if html output is used, because obsolete 
files are simply not linked once the index.html is opened even though the files are
present on the output path. However in case of xml output, this would result in obsolete
files still being handled by the utility.
 
Note that the files are only removed if the remove option was used in command line.
This option should only be used if the output is generated in the special directory.
If the output is created in the same directory as the project source files (should
really not!), this will alse remove all source files, so be careful!

This message is automaticaly sent from @c DoxygenConverter::convert() in the proper order.

@exception NSException Thrown if cleaning fails.
*/
- (void) createOutputDirectoriesAndRemovePreviousOutputFiles;

@end

@implementation DoxygenConverter

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Initialization & disposal
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (id)init
{
	self = [super init];
	if (self)
	{
		database = [[NSMutableDictionary alloc] init];
	}
	return self;
}

//----------------------------------------------------------------------------------------
- (void) dealloc
{
	[doxygenXMLOutputPath release], doxygenXMLOutputPath = nil;
	[database release], database = nil;
	[super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Converting handling
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) convert
{
	logNormal(@"Creating documentation...");
	
	// Prepare common data for the whole run so that the code will be simpler.
	cmd = [CommandLineParser sharedInstance];
	manager = [NSFileManager defaultManager];
	
	// Clear common variables.
	[database removeAllObjects];
	[database setObject:[NSMutableDictionary dictionary] forKey:kTKDataMainObjectsKey];
	[database setObject:[NSMutableDictionary dictionary] forKey:kTKDataMainDirectoriesKey];
	[doxygenXMLOutputPath release], doxygenXMLOutputPath = [[cmd outputPath] retain];

	// Run all the tasks.
	[self createOutputDirectoriesAndRemovePreviousOutputFiles];
	
	[self createDoxygenConfigFile];
	[self updateDoxygenConfigFile];
	[self createDoxygenDocumentation];
	
	[self createCleanObjectDocumentationMarkup];
	[self mergeCleanCategoriesToKnownObjects];
	[self updateCleanObjectsDatabase];
	[self createCleanIndexDocumentationFile];
	[self fixCleanObjectDocumentation];
	[self saveCleanObjectDocumentationFiles];
	
	[self createCleanOutputDocumentation];
	if (cmd.createDocSet)
	{
		[self createDocSetSourcePlistFile];
		[self createDocSetNodesFile];
		[self createDocSetTokesFile];
		[self createDocSetBundle];
	}

	logNormal(@"Succesfully finished documentation creation.");
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Common tasks
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) createOutputDirectoriesAndRemovePreviousOutputFiles
{
	NSError* error = nil;
	
	// If required, remove current directory to get a fresh start.
	if (cmd.cleanOutputFilesBeforeBuild && [manager fileExistsAtPath:cmd.outputPath])
	{
		logNormal(@"Removing previous output files at '%@'...", cmd.outputPath);		
		
		// Remove previous directory.
		if (![manager removeItemAtPath:cmd.outputPath error:&error])
		{
			[Systemator throwExceptionWithName:kTKConverterException basedOnError:error];
		}
		
		logInfo(@"Finished removing previous output files.");
	}
	
	// If the output directories don't exist, create them now. Note that for DocSet we
	// create all different directories. Since they are nested we could only create the
	// deepest one. However using this "non-smart" approach is safer in possible future
	// cases where the directory structure might change. Also note that the documents
	// directory is not created here. This will make it easier to copy the html later on...
	logNormal(@"Creating output directories at '%@'...", cmd.outputPath);
	[Systemator createDirectory:cmd.outputPath];
	[Systemator createDirectory:cmd.outputCleanXMLPath];
	[Systemator createDirectory:[cmd.outputCleanXMLPath stringByAppendingPathComponent:kTKDirClasses]];
	[Systemator createDirectory:[cmd.outputCleanXMLPath stringByAppendingPathComponent:kTKDirCategories]];
	[Systemator createDirectory:[cmd.outputCleanXMLPath stringByAppendingPathComponent:kTKDirProtocols]];
	if (cmd.createCleanXHTML)
	{
		[Systemator createDirectory:cmd.outputCleanXHTMLPath];
		[Systemator createDirectory:[cmd.outputCleanXHTMLPath stringByAppendingPathComponent:kTKDirClasses]];
		[Systemator createDirectory:[cmd.outputCleanXHTMLPath stringByAppendingPathComponent:kTKDirCategories]];
		[Systemator createDirectory:[cmd.outputCleanXHTMLPath stringByAppendingPathComponent:kTKDirProtocols]];
		[Systemator createDirectory:[cmd.outputCleanXHTMLPath stringByAppendingPathComponent:kTKDirCSS]];
	}
	if (cmd.createDocSet)
	{
		[Systemator createDirectory:cmd.outputDocSetPath];
		[Systemator createDirectory:cmd.outputDocSetContentsPath];
		[Systemator createDirectory:cmd.outputDocSetResourcesPath];
	}
	logInfo(@"Finished creating output directories.");
}

@end
