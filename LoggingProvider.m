//
//  LoggingProvider.m
//  appledoc
//
//  Created by Tomaz Kragelj on 12.4.09.
//  Copyright 2009 Tomaz Kragelj. All rights reserved.
//

#import "LoggingProvider.h"
#import "CommandLineParser.h"

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Definitions
//////////////////////////////////////////////////////////////////////////////////////////

#define kTKLogMessageLength	60

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Logger implementation
//////////////////////////////////////////////////////////////////////////////////////////

@implementation Logger

//----------------------------------------------------------------------------------------
+ (Logger*) sharedInstance
{
	static Logger* result = nil;
	if (!result) result = [[Logger alloc] init];
	return result;
}

//----------------------------------------------------------------------------------------
- (void) logError:(NSString*) message
{
	[self logMessage:message type:@"ERROR  "];
}

//----------------------------------------------------------------------------------------
- (void) logNormal:(NSString*) message
{
	if ([self isNormalEnabled])
	{
		[self logMessage:message type:@"NORMAL "];
	}
}

//----------------------------------------------------------------------------------------
- (void) logInfo:(NSString*) message
{
	if ([self isInfoEnabled])
	{
		[self logMessage:message type:@"INFO   "];
	}
}

//----------------------------------------------------------------------------------------
- (void) logVerbose:(NSString*) message
{
	if ([self isVerboseEnabled])
	{
		[self logMessage:message type:@"VERBOSE"];
	}
}

//----------------------------------------------------------------------------------------
- (void) logDebug:(NSString*) message
{
	if ([self isDebugEnabled])
	{
		[self logMessage:message type:@"DEBUG  "];
	}
}

//----------------------------------------------------------------------------------------
- (BOOL) isNormalEnabled
{
	return ([CommandLineParser sharedInstance].verboseLevel >= kTKVerboseLevelNormal);
}

//----------------------------------------------------------------------------------------
- (BOOL) isInfoEnabled
{
	return ([CommandLineParser sharedInstance].verboseLevel >= kTKVerboseLevelInfo);
}

//----------------------------------------------------------------------------------------
- (BOOL) isVerboseEnabled
{
	return ([CommandLineParser sharedInstance].verboseLevel >= kTKVerboseLevelVerbose);
}

//----------------------------------------------------------------------------------------
- (BOOL) isDebugEnabled
{
	return ([CommandLineParser sharedInstance].verboseLevel >= kTKVerboseLevelDebug);
}

//----------------------------------------------------------------------------------------
- (void) logMessage:(NSString*) message type:(NSString*) type
{
	printf(
		"%s [%s] | %s", 
		[[[NSCalendarDate date] descriptionWithCalendarFormat:@"%H:%M:%S:%F"] cStringUsingEncoding:NSASCIIStringEncoding],
		[type cStringUsingEncoding:NSASCIIStringEncoding], 
		[message cStringUsingEncoding:NSASCIIStringEncoding]);
}

@end

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Global functions
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
NSString* FormatLogMessage(char* file, const char* method, int line, NSString* message, ...)
{
	// Format all parameters into the message.
	va_list args;
	va_start(args, message);
	NSMutableString* msg = [[[NSMutableString alloc] initWithFormat:message arguments:args] autorelease];
	va_end(args);

	// If debug verbose level is requested, we should include information about the source.
	if ([CommandLineParser sharedInstance].verboseLevel >= kTKVerboseLevelDebug)
	{
		while ([msg length] < kTKLogMessageLength)
		{
			[msg appendString:@" "];
		}		
		return [NSString stringWithFormat:@"%@ | %s @ %d\n", msg, method, line];			
	}
	
	return [NSString stringWithFormat:@"%@\n", msg];
}
