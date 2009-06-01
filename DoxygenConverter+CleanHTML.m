//
//  DoxygenConverter+CleanHTML.m
//  appledoc
//
//  Created by Tomaz Kragelj on 17.4.09.
//  Copyright 2009 Tomaz Kragelj. All rights reserved.
//

#import "DoxygenConverter+CleanHTML.h"
#import "DoxygenConverter+Helpers.h"
#import "CommandLineParser.h"
#import "LoggingProvider.h"
#import "Systemator.h"
#import "XHTMLGenerator.h"

@implementation DoxygenConverter (CleanHTML)

//----------------------------------------------------------------------------------------
- (void) createCleanXHTMLDocumentation
{
	logNormal(@"Creating clean XHTML documentation...");
	NSAutoreleasePool* loopAutoreleasePool = nil;
	NSError* error = nil;
	
	// Copy the css files from templates.
	NSArray* templateFiles = [manager directoryContentsAtPath:cmd.templatesPath];
	for (NSString* templateFile in templateFiles)
	{
		if ([[templateFile pathExtension] isEqualToString:@"css"])
		{
			logDebug(@"Copying '%@' css file...", templateFile);
			NSString* source = [cmd.templatesPath stringByAppendingPathComponent:templateFile];
			NSString* dest = [[cmd.outputCleanXHTMLPath stringByAppendingPathComponent:kTKDirCSS] 
							  stringByAppendingPathComponent:templateFile];
			if (![manager copyItemAtPath:source
								  toPath:dest
								   error:&error])
			{
				logError(@"Copying '%@' failed with error %@!", 
						 templateFile, 
						 [error localizedDescription]);
				continue;
			}
		}
	}
	
	// Prepare the arguments for the XSLT.
	NSCalendarDate* now = [NSCalendarDate date];
	NSString* lastUpdatedString = [now descriptionWithCalendarFormat:@"%Y-%B-%d"];
	NSDictionary* xsltArgumentsDict = [NSDictionary dictionaryWithObject:lastUpdatedString forKey:@"lastUdatedDate"];
	
	// Convert the index file.
	NSString* indexFilename = [cmd.outputCleanXHTMLPath stringByAppendingPathComponent:@"index.html"];
	NSString* indexStylsheetFilename = [cmd.templatesPath stringByAppendingPathComponent:@"index2xhtml.xslt"];
	NSXMLDocument* cleanIndexDoc = [self applyXSLTFromFile:indexStylsheetFilename
												toDocument:[database objectForKey:kTKDataMainIndexKey]
												 arguments:xsltArgumentsDict
													 error:&error];
	if (!cleanIndexDoc)
	{
		logError(@"Skipping index because creating clean XHTML index failed with error %@!", 
				 [error localizedDescription]);
	}
	
	logDebug(@"Saving index to '%@'...", indexFilename);
	NSData* indexData = [cleanIndexDoc XMLDataWithOptions:NSXMLDocumentTidyHTML];
	if (![indexData writeToFile:indexFilename atomically:NO])
	{
		@throw [NSException exceptionWithName:kTKConverterException 
									   reason:@"Failed saving index XHTML file to '%@'!"
									 userInfo:nil];
	}

	// Convert the object files.
	NSDictionary* objects = [database objectForKey:kTKDataMainObjectsKey];
	for (NSString* objectName in objects)
	{
		[loopAutoreleasePool drain];
		loopAutoreleasePool = [[NSAutoreleasePool alloc] init];
		
		NSDictionary* objectData = [objects objectForKey:objectName];
		
		// Prepare the file name.
		NSString* relativePath = [objectData objectForKey:kTKDataObjectRelPathKey];
		NSString* filename = [cmd.outputCleanXHTMLPath stringByAppendingPathComponent:relativePath];

		// Generate the object data.
		XHTMLGenerator* generator = [[[XHTMLGenerator alloc] init] autorelease];
		generator.lastUpdated = lastUpdatedString;		
		NSData* data = [generator generateOutputForObject:objectData];
		if (!data)
		{
			logError(@"Skipping '%@' because creating clean XHTML failed!", objectName);
			continue;
		}
		
		// Save the data.
		logDebug(@"Saving '%@' to '%@'...", objectName, filename);
		if (![data writeToFile:filename atomically:NO])
		{
			logError(@"Failed saving '%@' to '%@'!", objectName, filename);
			continue;
		}
	}
	
	// If cleantemp is used, remove clean XML temporary files.
	if (cmd.removeTemporaryFiles && [manager fileExistsAtPath:cmd.outputCleanXMLPath])
	{
		logInfo(@"Removing temporary clean XML files at '%@'...", cmd.outputCleanXMLPath);
		NSError* error = nil;
		if (![manager removeItemAtPath:cmd.outputCleanXMLPath error:&error])
		{
			[Systemator throwExceptionWithName:kTKConverterException basedOnError:error];
		}
	}
	
	[loopAutoreleasePool drain];
	logInfo(@"Finished creating clean XHTML documentation.");
}

@end
