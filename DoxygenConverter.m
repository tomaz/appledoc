//
//  DoxygenConverter.m
//  appledoc
//
//  Created by Tomaz Kragelj on 11.4.09.
//  Copyright 2009 Tomaz Kragelj. All rights reserved.
//

#import "DoxygenConverter.h"
#import "Constants.h"
#import "Systemator.h"
#import "LoggingProvider.h"
#import "CommandLineParser.h"

#import "DoxygenOutputGenerator.h"
#import "XMLOutputGenerator.h"
#import "XHTMLOutputGenerator.h"
#import "DocSetOutputGenerator.h"

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
		cmd = [CommandLineParser sharedInstance];
		database = [[NSMutableDictionary alloc] init];
		
		// Setup all output generators.
		DoxygenOutputGenerator* doxygenGenerator = [[DoxygenOutputGenerator alloc] initWithDatabase:database];
		XMLOutputGenerator* xmlGenerator = [[XMLOutputGenerator alloc] initWithDatabase:database];
		XHTMLOutputGenerator* xhtmlGenerator = [[XHTMLOutputGenerator alloc] initWithDatabase:database];
		DocSetOutputGenerator* docSetGenerator = [[DocSetOutputGenerator alloc] initWithDatabase:database];
		
		// Setup all dependencies.
		[doxygenGenerator registerDependentGenerator:xmlGenerator];
		[xmlGenerator registerDependentGenerator:xhtmlGenerator];
		[xhtmlGenerator registerDependentGenerator:docSetGenerator];
		xmlGenerator.doxygenInfoProvider = doxygenGenerator;
		docSetGenerator.documentationFilesInfoProvider = xhtmlGenerator;
		
		// Setup top level generators.
		topLevelGenerators = [[NSMutableArray alloc] init];
		[topLevelGenerators addObject:doxygenGenerator];

		// We can now release generators because they are retained by their parents.
		[doxygenGenerator release];
		[xmlGenerator release];
		[xhtmlGenerator release];
		[docSetGenerator release];
	}
	return self;
}

//----------------------------------------------------------------------------------------
- (void) dealloc
{
	cmd = nil;
	[database release], database = nil;
	[topLevelGenerators release], topLevelGenerators = nil;
	[super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Converting handling
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) convert
{
	logNormal(@"Creating documentation...");
	
	NSFileManager* manager = [NSFileManager defaultManager];
	
	// If required, remove output directory to get a fresh start.
	if (cmd.cleanOutputFilesBeforeBuild && [manager fileExistsAtPath:cmd.outputPath])
	{
		logNormal(@"Removing previous output files...");
		[Systemator removeItemAtPath:cmd.outputPath];
		logInfo(@"Finished removing previous output files.");
	}

	// If output directory doesn't yet exist, create it.
	if (![manager fileExistsAtPath:cmd.outputPath])
	{
		logNormal(@"Creating output path...");
		[Systemator createDirectory:cmd.outputPath];
		logInfo(@"Finished creating output path.");		
	}

	// Clear common variables.
	[database removeAllObjects];
	[database setObject:[NSMutableDictionary dictionary] forKey:kTKDataMainObjectsKey];
	[database setObject:[NSMutableDictionary dictionary] forKey:kTKDataMainHierarchiesKey];
	[database setObject:[NSMutableDictionary dictionary] forKey:kTKDataMainDirectoriesKey];

	// Create all top level outputs. Note that this will in turn start all their
	// dependent output generations.
	logNormal(@"Generating output documentation...");
	for (id<OutputProcessing> topLevelGenerator in topLevelGenerators)
	{
		if (topLevelGenerator.isOutputGenerationEnabled)
		{
			[topLevelGenerator generateOutput];
		}
	}
	logInfo(@"Finished generating output documentation.");
	
	// Notify the users that creation was succesful.ß
	logNormal(@"Succesfully created output documentation.");
}

@end
