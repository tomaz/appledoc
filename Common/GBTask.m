//
//  GBTask.m
//  appledoc
//
//  Created by Tomaz Kragelj on 30.11.10.
//  Copyright 2010 Gentle Bytes. All rights reserved.
//

#import "GBTask.h"

@interface GBTask ()

- (NSString *)stringFromPipe:(NSPipe *)pipe;
- (NSArray *)commandLineArgumentsFromList:(va_list)args;
@property (readwrite, retain) NSString *lastStandardOutput;
@property (readwrite, retain) NSString *lastStandardError;

@end

#pragma mark -

@implementation GBTask

#pragma mark Initialization & disposal

+ (id)task {
	return [[[self alloc] init] autorelease];
}

#pragma Command handling

- (BOOL)runCommand:(NSString *)command, ... {	
	// Get the arguments and prepare human readable list for logging (only if necessary).
	va_list args;
	va_start(args, command);
	NSArray *arguments = [self commandLineArgumentsFromList:args];
	va_end(args);
	
	// Log the command we're about to run.
	if (GBLogIsEnabled(LOG_LEVEL_DEBUG)) {
		NSMutableString *string = [NSMutableString string];
		for (id argument in arguments) [string appendFormat:@" %@", argument];
		GBLogDebug(@"Running command '%@%@'", command, string);
	}
	
	// Ok, now prepare the NSTask and really run the command... Note that [NSTask launch] raises exception if it can't launch, we just pass it on.
	NSPipe *stdOutPipe = [NSPipe pipe];
	NSPipe *stdErrPipe = [NSPipe pipe];
	NSTask *task = [[[NSTask alloc] init] autorelease];
	[task setLaunchPath:command];
	[task setArguments:arguments];
	[task setStandardOutput:stdOutPipe];
	[task setStandardError:stdErrPipe];
	[task launch];
	self.lastStandardOutput = [self stringFromPipe:stdOutPipe];
	self.lastStandardError = [self stringFromPipe:stdErrPipe];
	[task waitUntilExit];
	
	// If we got something on standard error, report error, otherwise success.
	return ([self.lastStandardError length] == 0);
}

#pragma mark Helper methods

- (NSString *)stringFromPipe:(NSPipe *)pipe {
	NSFileHandle *handle = [pipe fileHandleForReading];
	NSData *data = [handle readDataToEndOfFile];
	NSString *result = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	return [result autorelease];
}

- (NSArray *)commandLineArgumentsFromList:(va_list)args {
	NSMutableArray *result = [NSMutableArray array];
	id arg;
	while ((arg = va_arg(args, id))) {
		[result addObject:arg];
	}
	return result;
}

#pragma mark Properties

@synthesize lastStandardOutput;
@synthesize lastStandardError;

@end
