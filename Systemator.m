//
//  Systemator.m
//  appledoc
//
//  Created by Tomaz Kragelj on 14.4.09.
//  Copyright 2009 Tomaz Kragelj. All rights reserved.
//

#import "Systemator.h"
#import "LoggingProvider.h"
#import "CommandLineParser.h"

#define kTKSystemError @"TKSystemError"

//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
/** Declares methods private for the @c Systemator class.
*/
@interface Systemator (ClassPrivateAPI)

/** Determines the system's shell path.￼

This method will first determine the kind of shell that is used by the user. Then it will
get the path from the shell.

@return ￼￼￼￼Returns the shell path.
@exception ￼￼￼￼￼NSException Thrown if shell path cannot be determined.
*/
+ (NSString*) systemShellPath;

/** Returns the array of all lines from the given string.￼

@param string ￼￼￼￼￼￼The string to get the lines from.
@return ￼￼￼￼Returns the array containing strings representing all lines from the @c string.
*/
+ (NSMutableArray*) linesFromString:(NSString*) string;

@end

@implementation Systemator

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Public interface methods
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
+ (void) runTask:(NSString*) command, ...
{
	NSParameterAssert(command != nil);
	
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	BOOL isDebugLevelOn = [[self logger] isDebugEnabled];
	NSMutableString* argumentsString = isDebugLevelOn ? [[NSMutableString alloc] init] : nil;
	
	// Convert the variable list into the array.
	NSMutableArray* arguments = [[NSMutableArray alloc] init];
	
	va_list args;
	va_start(args, command);
	id arg = command;
	while (arg)
	{
		id argument = va_arg(args, id);
		if (!argument) break;
		[arguments addObject:argument];
		if (isDebugLevelOn) [argumentsString appendFormat:@"%@ ", argument];
		arg++;
	}
	va_end(args);
	
	logDebug(@"Running task '%@ %@'...", command, argumentsString);

	// If debug output is desired, we should show task output, otherwise we should
	// redirect it to a temporary pipe so that it doesn't "garbage" the output.
	BOOL showOutput = [[CommandLineParser sharedInstance] emitUtilityOutput];
	NSPipe* outputPipe = showOutput ? nil : [[NSPipe alloc] init];
	
	// Setup and run the task.
	NSTask* task = [[NSTask alloc] init];
	if (outputPipe) [task setStandardOutput:outputPipe];
	[task setLaunchPath:command];
	[task setArguments:arguments];
	[task launch];
	[task waitUntilExit];
	
	// Release temporary objects.
	[outputPipe release];
	[task release];
	[arguments release];
	[argumentsString release];
	[pool drain];
}

//----------------------------------------------------------------------------------------
+ (void) createDirectory:(NSString*) path
{
	if (![[NSFileManager defaultManager] fileExistsAtPath:path])
	{
		logDebug(@"Creating directory '%@'...", path);
		NSError* error = nil;
		if (![[NSFileManager defaultManager] createDirectoryAtPath:path
									   withIntermediateDirectories:YES
														attributes:nil
															 error:&error])
		{
			[self throwExceptionWithName:kTKSystemError basedOnError:error];
		}
	}
}

//----------------------------------------------------------------------------------------
+ (NSMutableArray*) linesFromContentsOfFile:(NSString*) filename
{
	// Read the data from the file into the string.
	NSError* error = nil;
	NSString* contents = [[NSString alloc] initWithContentsOfFile:filename
														 encoding:NSASCIIStringEncoding
															error:&error];
	if (!contents) [self throwExceptionWithName:kTKSystemError basedOnError:error];
	return [self linesFromString:contents];
}

//----------------------------------------------------------------------------------------
+ (void) writeLines:(NSArray*) lines toFile:(NSString*) filename
{
	// Generate the string containing all lines.
	NSMutableString* string = [[NSMutableString alloc] init];
	for (NSString* line in lines)
	{
		[string appendString:line];
		[string appendString:@"\n"];
	}
	
	// Write the file.
	NSError* error = nil;
	if (![string writeToFile:filename
				  atomically:NO
					encoding:NSASCIIStringEncoding
					   error:&error])
	{
		[self throwExceptionWithName:kTKSystemError basedOnError:error];
	}
}

//----------------------------------------------------------------------------------------
+ (void) throwExceptionWithName:(NSString*) name basedOnError:(NSError*) error;
{
	@throw [NSException exceptionWithName:name
								   reason:[error localizedDescription]
								 userInfo:[error userInfo]];
}

//----------------------------------------------------------------------------------------
+ (void) throwExceptionWithName:(NSString*) name withDescription:(NSString*) description
{
	@throw [NSException exceptionWithName:name
								   reason:description
								 userInfo:nil];
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Class private methods
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
+ (NSString*) systemShellPath
{
	NSTask* task = nil;
	NSPipe* outputPipe = nil;
	NSString* outputString = nil;
	
	@try
	{
		// First we must determine the kind of shell that is used, then create a process that 
		// asks the shell about the path.
		NSDictionary* environment = [[NSProcessInfo processInfo] environment];
		NSString* shell = [environment objectForKey:@"SHELL"];
		
		// Setup the pipe which will capture output from the task.
		outputPipe = [[NSPipe alloc] init];
			
		// Now create the task which will ask the shell for all environment variables.
		task = [[NSTask alloc] init];
		[task setLaunchPath:shell];
		[task setArguments:[NSArray arrayWithObjects:@"-c", @"env", nil]];
		[task setStandardOutput:outputPipe];	
		[task launch];

		// Read the output from the task into a string.
		NSData* data = [[outputPipe fileHandleForReading] readDataToEndOfFile];
		outputString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
		
		// Convert the string into individual lines. Then scan through the lines and extract
		NSArray* lines = [self linesFromString:outputString];
		for (NSString* line in lines)
		{
			NSRange pathRange = [line rangeOfString:@"PATH"];
			NSRange separatorRange = [line rangeOfString:@"="];
			if (pathRange.location != NSNotFound && separatorRange.location != NSNotFound)
			{
				return [line substringFromIndex:separatorRange.location + separatorRange.length];
			}
		}
	}
	@catch (NSException* e)
	{
		@throw;
	}
	@finally
	{
		[outputString release];
		[outputPipe release];
		[task release];
	}
	
	return nil;
}

//----------------------------------------------------------------------------------------
+ (NSMutableArray*) linesFromString:(NSString*) string
{
	NSMutableArray *result = [NSMutableArray array];
	
	unsigned paragraphStart = 0;
	unsigned paragraphEnd = 0;
	unsigned contentsEnd = 0;
	unsigned length = [string length];
	
	NSRange currentRange;
	while (paragraphEnd < length)
	{
		[string getParagraphStart:&paragraphStart 
							  end:&paragraphEnd
					  contentsEnd:&contentsEnd 
						 forRange:NSMakeRange(paragraphEnd, 0)];
		currentRange = NSMakeRange(paragraphStart, contentsEnd - paragraphStart);
		[result addObject:[string substringWithRange:currentRange]];
	}
	
	return result;
}

@end
