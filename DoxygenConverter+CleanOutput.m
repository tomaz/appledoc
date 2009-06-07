//
//  DoxygenConverter+CleanOutput.m
//  appledoc
//
//  Created by Tomaz Kragelj on 17.4.09.
//  Copyright 2009 Tomaz Kragelj. All rights reserved.
//

#import "DoxygenConverter+CleanOutput.h"
#import "DoxygenConverter+Helpers.h"
#import "CommandLineParser.h"
#import "LoggingProvider.h"
#import "Systemator.h"
#import "XHTMLOutputGenerator.h"

@implementation DoxygenConverter (CleanOutput)

//----------------------------------------------------------------------------------------
- (void) createCleanOutputDocumentation
{
	logNormal(@"Creating clean XHTML documentation...");
	NSAutoreleasePool* loopAutoreleasePool = nil;
	
	// Prepare the argument values.
	NSCalendarDate* now = [NSCalendarDate date];
	NSString* lastUpdatedString = [now descriptionWithCalendarFormat:@"%Y-%B-%d"];
	
	// Prepare the output generators, send them default data and notify them generation 
	// is about to begin.
	XHTMLOutputGenerator* generator = [[XHTMLOutputGenerator alloc] init];
	generator.lastUpdated = lastUpdatedString;
	generator.projectName = cmd.projectName;
	[generator generationStarting];
	
	@try
	{
		// Convert the index and hierarchy files.
		[generator generateOutputForIndex:database];
		[generator generateOutputForHierarchy:database];

		// Convert the object files.
		NSDictionary* objects = [database objectForKey:kTKDataMainObjectsKey];
		for (NSString* objectName in objects)
		{
			[loopAutoreleasePool drain];
			loopAutoreleasePool = [[NSAutoreleasePool alloc] init];
			
			NSDictionary* objectData = [objects objectForKey:objectName];
			[generator generateOutputForObject:objectData];
		}
		
		// If cleantemp is used, remove clean XML temporary files.
		if (cmd.cleanTempFilesAfterBuild && [manager fileExistsAtPath:cmd.outputCleanXMLPath])
		{
			logInfo(@"Removing temporary clean XML files at '%@'...", cmd.outputCleanXMLPath);
			NSError* error = nil;
			if (![manager removeItemAtPath:cmd.outputCleanXMLPath error:&error])
			{
				logError(@"Failed removing temporary clean XML files at '%@'!", cmd.outputCleanXMLPath);
				[Systemator throwExceptionWithName:kTKConverterException basedOnError:error];
			}
		}
	}
	@finally
	{
		[generator generationFinished];
		[generator release];
		[loopAutoreleasePool drain];
	}
	
	logInfo(@"Finished creating clean XHTML documentation.");
}

@end
