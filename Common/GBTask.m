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
- (NSArray *)linesFromString:(NSString *)string;
@property (copy) GBTaskReportBlock reportBlock;
@property (readwrite, strong) NSString *lastCommandLine;
@property (readwrite, strong) NSString *lastStandardOutput;
@property (readwrite, strong) NSString *lastStandardError;

@end

#pragma mark -

@implementation GBTask

#pragma mark Initialization & disposal

+ (id)task {
	return [[self alloc] init];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma Command handling

- (BOOL)runCommand:(NSString *)command, ... {	
	// Get the arguments and prepare human readable list for logging (only if necessary).
	va_list args;
	va_start(args, command);
	NSArray *arguments = [self commandLineArgumentsFromList:args];
	va_end(args);
	return [self runCommand:command arguments:arguments block:nil];
}

- (BOOL)runCommand:(NSString *)command arguments:(NSArray *)arguments block:(GBTaskReportBlock)block {
	// If nil is passed for arguments, convert it to empty array.
	if (!arguments) arguments = [NSArray array];
	
	// Log the command we're about to run.
	NSMutableString *commandLine = [NSMutableString string];
	for (id argument in arguments) [commandLine appendFormat:@" %@", argument];
	self.lastCommandLine = [NSString stringWithFormat:@"%@%@", command, commandLine];
	GBLogDebug(@"Running command '%@'", self.lastCommandLine);
	
	// Prepare deviation pipes so that we can extract the data from the task. If requested, prepare everything for continuous updating.
	NSPipe *stdOutPipe = [NSPipe pipe];
	NSPipe *stdErrPipe = [NSPipe pipe];
	if (block) {
		NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
		[center addObserver:self selector:@selector(outputHandleDataReceived:) name:NSFileHandleReadCompletionNotification object:[stdOutPipe fileHandleForReading]];
		[center addObserver:self selector:@selector(errorHandleDataReceived:) name:NSFileHandleReadCompletionNotification object:[stdErrPipe fileHandleForReading]];
		self.lastStandardOutput = @"";
		self.lastStandardError = @"";
		self.reportBlock = block;
	}
	
	// Ok, now prepare the NSTask and really run the command... Note that [NSTask launch] raises exception if it can't launch, we just pass it on.
	NSTask *task = [[NSTask alloc] init];
	[task setLaunchPath:command];
	[task setArguments:arguments];
	[task setStandardOutput:stdOutPipe];
	[task setStandardError:stdErrPipe];
	[task launch];
	if (block) {
		[[stdOutPipe fileHandleForReading] readInBackgroundAndNotify];
		[[stdErrPipe fileHandleForReading] readInBackgroundAndNotify];
	} else {
		self.lastStandardOutput = [self stringFromPipe:stdOutPipe];
		self.lastStandardError = [self stringFromPipe:stdErrPipe];
	}
	[task waitUntilExit];
	
	// If we got something on standard error, report error, otherwise success.
	return ([self.lastStandardError length] == 0);
}

#pragma mark Continuous reporting handling

- (void)outputHandleDataReceived:(NSNotification *)note {
	// Report anything received to std out.
	NSData *data = [[note userInfo] objectForKey:NSFileHandleNotificationDataItem];
	NSString *string = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	self.lastStandardOutput = [self.lastStandardOutput stringByAppendingFormat:@"%@\n", string];
	if (self.reportIndividualLines) {
		NSArray *lines = [self linesFromString:string];
		for (NSString *line in lines) self.reportBlock(line, nil);
	} else {
		self.reportBlock(string, nil);
	}
	[[note object] readInBackgroundAndNotify];
}

- (void)errorHandleDataReceived:(NSNotification *)note {
	// Only report if something was received. As notification is posted at least once when the task finishes, we should ignore it at that point!
	NSData *data = [[note userInfo] objectForKey:NSFileHandleNotificationDataItem];
	NSString *string = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	if ([string length] > 0) {
		self.lastStandardError = [self.lastStandardError stringByAppendingFormat:@"%@\n", string];
		if (self.reportIndividualLines) {
			NSArray *lines = [self linesFromString:string];
			for (NSString *line in lines) self.reportBlock(nil, line);
		} else {
			self.reportBlock(nil, string);
		}
	}
	[[note object] readInBackgroundAndNotify];
}

#pragma mark Helper methods

- (NSString *)stringFromPipe:(NSPipe *)pipe {
	NSFileHandle *handle = [pipe fileHandleForReading];
	NSData *data = [handle readDataToEndOfFile];
	NSString *result = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	return result;
}

- (NSArray *)commandLineArgumentsFromList:(va_list)args {
	NSMutableArray *result = [NSMutableArray array];
	id arg;
	while ((arg = va_arg(args, id))) {
		[result addObject:arg];
	}
	return result;
}

- (NSArray *)linesFromString:(NSString *)string {
	// This is copied from Apple documentation.
	NSUInteger length = [string length];
	NSUInteger paraStart = 0, paraEnd = 0, contentsEnd = 0;
	NSMutableArray *result = [NSMutableArray array];
	NSRange currentRange;
	while (paraEnd < length) {
		[string getParagraphStart:&paraStart end:&paraEnd contentsEnd:&contentsEnd forRange:NSMakeRange(paraEnd, 0)];
		currentRange = NSMakeRange(paraStart, contentsEnd - paraStart);
		[result addObject:[string substringWithRange:currentRange]];
	}
	return result;
}

#pragma mark Properties

@synthesize reportBlock;
@synthesize reportIndividualLines;
@synthesize lastCommandLine;
@synthesize lastStandardOutput;
@synthesize lastStandardError;

@end
