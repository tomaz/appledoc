//
//  DoxygenOutputGenerator.m
//  appledoc
//
//  Created by Tomaz Kragelj on 11.6.09.
//  Copyright (C) 2009, Tomaz Kragelj. All rights reserved.
//

#import "DoxygenOutputGenerator.h"
#import "CommandLineParser.h"
#import "LoggingProvider.h"
#import "Systemator.h"

@implementation DoxygenOutputGenerator

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Doxygen handling
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) createDoxygenConfigFile
{
	if (![manager fileExistsAtPath:cmd.doxygenConfigFilename])
	{
		logNormal(@"Creating doxygen configuration file '%@'...", cmd.doxygenConfigFilename);
		[Systemator runTask:[cmd doxygenCommandLine], @"-g", cmd.doxygenConfigFilename, nil];
		logInfo(@"Finished creating doxygen configuration file.");
	}
}

//----------------------------------------------------------------------------------------
- (void) updateDoxygenConfigFile
{
	logNormal(@"Updating doxygen configuration file '%@'...", cmd.doxygenConfigFilename);
	
	if (![manager fileExistsAtPath:cmd.doxygenConfigFilename])
		@throw [NSException exceptionWithName:kTKConverterException
									   reason:@"Doxygen configuration file doesn't exist"
									 userInfo:nil];

	NSAutoreleasePool* loopAutoreleasePool = nil;
	
	// Prepare commonly used character sets and variables.
	NSCharacterSet* newlineCharSet = [NSCharacterSet newlineCharacterSet];
	NSCharacterSet* equalCharSet = [NSCharacterSet characterSetWithCharactersInString:@"="];
	BOOL updateFileData = YES;
	BOOL dataChanged = NO;

	// Get the lines from the file. Then parse them and replace the options. Note that
	// we skip all comments which are detected by the hash at the start of the line.
	NSMutableArray* lines = [Systemator linesFromContentsOfFile:cmd.doxygenConfigFilename];
	for (int i=0; i<[lines count]; i++)
	{
		// Setup the autorelease pool for this iteration. Note that we are releasing the
		// previous iteration pool here as well. This is because we use continue to 
		// skip certain iterations, so releasing at the end of the loop would not work...
		// Also note that after the loop ends, we are releasing the last iteration loop.
		[loopAutoreleasePool drain];
		loopAutoreleasePool = [[NSAutoreleasePool alloc] init];
		
		NSString* line = [lines objectAtIndex:i];
		
		// Only handle lines which have some chars and don't start with #.
		if ([line length] > 0 && [line characterAtIndex:0] != '#')
		{
			// Get the = char and get the option name and value if found.
			NSRange separatorRange = [line rangeOfString:@"="];
			if (separatorRange.location != NSNotFound)
			{
				NSString* optionName = nil;
				NSString* optionValue = nil;
				BOOL replaceLine = NO;
				
				// Get the option name and value. Note that we require option name and
				// equal sign, but we don't require the option value to contain any 
				// char. Because scanner returns NO if empty string was scanned, we 
				// cannot include it in the if conditions - in some cases value is
				// present, in some not.
				NSScanner* scanner = [NSScanner scannerWithString:line];
				if ([scanner scanUpToCharactersFromSet:equalCharSet intoString:&optionName] &&
					[scanner scanCharactersFromSet:equalCharSet intoString:NULL])
				{
					// Scan the option value.
					[scanner scanUpToCharactersFromSet:newlineCharSet intoString:&optionValue];
					
					// Only handle data updating if so required. This is used to suppress
					// updating if the data is already set. Otherwise we might end clearing
					// user's choices on each run...
					if (updateFileData)
					{
						// If this is project name we should check if the value is already
						// set. If so, we should skip all further updating to avoid interfering
						// with any custom user options. Otherwise we should continue. This
						// works because at the moment PROJECT_NAME is the first option in the 
						// file that we handle...
						if ([optionName rangeOfString:@"PROJECT_NAME"].location != NSNotFound)
						{
							if ([optionValue length] > 0)
							{
								logVerbose(@"PROJECT_NAME already set, skipping further updating...");
								updateFileData = NO;
								continue;
							}

							logInfo(@"Setting PROJECT_NAME to %@...", [cmd projectName]);
							line = [line stringByAppendingFormat:@"\"%@\"", [cmd projectName]];
							replaceLine = YES;
						}
						
						// Replace output directory.
						if ([optionName rangeOfString:@"OUTPUT_DIRECTORY"].location != NSNotFound &&
							[optionValue length] == 0)
						{						
							logInfo(@"Setting OUTPUT_DIRECTORY to %@...", [cmd outputPath]);
							line = [line stringByAppendingFormat:@"\"%@\"", [cmd outputPath]];
							replaceLine = YES;
						}
						
						// Replace input directory. Note that we must only change the input
						// option, not others that start with input!
						if ([optionName rangeOfString:@"INPUT"].location != NSNotFound &&
							[optionName rangeOfString:@"INPUT_"].location == NSNotFound &&
							[optionValue length] == 0)
						{						
							logInfo(@"Setting INPUT to %@...", [cmd inputPath]);
							line = [line stringByAppendingFormat:@"\"%@\"", [cmd inputPath]];
							replaceLine = YES;
						}
						
						// Replace tab size.
						if ([optionName rangeOfString:@"TAB_SIZE"].location != NSNotFound)
						{						
							logInfo(@"Setting TAB_SIZE to 4...");
							line = [line stringByReplacingOccurrencesOfString:@"8" withString:@"4"];
							replaceLine = YES;
						}
						
						// Replace warn if not documented.
						if ([optionName rangeOfString:@"WARN_IF_UNDOCUMENTED"].location != NSNotFound)
						{
							logInfo(@"Setting WARN_IF_UNDOCUMENTED to NO...");
							line = [line stringByReplacingOccurrencesOfString:@"YES" withString:@"NO"];
							replaceLine = YES;
						}
						
						// Replace generate html.
						if ([optionName rangeOfString:@"GENERATE_HTML"].location != NSNotFound)
						{
							logInfo(@"Setting GENERATE_HTML to NO...");
							line = [line stringByReplacingOccurrencesOfString:@"YES" withString:@"NO"];
							replaceLine = YES;
						}
						
						// Replace generate latex.
						if ([optionName rangeOfString:@"GENERATE_LATEX"].location != NSNotFound)
						{
							logInfo(@"Setting GENERATE_LATEX to NO...");
							line = [line stringByReplacingOccurrencesOfString:@"YES" withString:@"NO"];
							replaceLine = YES;
						}
											
						// Replace generate xml.
						if ([optionName rangeOfString:@"GENERATE_XML"].location != NSNotFound)
						{
							logInfo(@"Setting GENERATE_XML to YES...");
							line = [line stringByReplacingOccurrencesOfString:@"NO" withString:@"YES"];
							replaceLine = YES;
						}
						
						// If required, replace the line in the array.
						if (replaceLine)
						{
							[lines replaceObjectAtIndex:i withObject:line];
							dataChanged = YES;
						}
					}
					
					// Remember XML output path.
					if ([optionName rangeOfString:@"XML_OUTPUT"].location != NSNotFound)
					{
						cmd.outputDoxygenXMLPath = [[[cmd outputPath] stringByAppendingPathComponent:optionValue] retain];
						logInfo(@"Found XML_OUTPUT set to %@.", cmd.outputDoxygenXMLPath);
					}
				}
			}
		}
	}
	
	// If the data changes, write the file.
	if (dataChanged)
	{
		logVerbose(@"Writting doxygen configuration file...");
		[Systemator writeLines:lines toFile:cmd.doxygenConfigFilename];
	}
		
	// Release the last iteration pool.
	[loopAutoreleasePool drain];
	logInfo(@"Finished updating doxygen configuration file.");
}

//----------------------------------------------------------------------------------------
- (void) createDoxygenDocumentation
{
	logNormal(@"Creating doxygen documentation...");		

	if (![manager fileExistsAtPath:cmd.doxygenConfigFilename])
		@throw [NSException exceptionWithName:kTKConverterException
									   reason:@"Doxygen configuration file doesn't exist"
									 userInfo:nil];
	
	[Systemator runTask:[cmd doxygenCommandLine], cmd.doxygenConfigFilename, nil];
	
	logInfo(@"Finished creating doxygen documentation.");
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Specific output generation entry points
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) generateSpecificOutput
{
	[self createDoxygenConfigFile];
	[self updateDoxygenConfigFile];
	[self createDoxygenDocumentation];
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Specific output directories handling
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) removeOutputDirectories
{
	[Systemator removeItemAtPath:cmd.outputDoxygenXMLPath];
}

@end
