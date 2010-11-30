//
//  GBTask.h
//  appledoc
//
//  Created by Tomaz Kragelj on 30.11.10.
//  Copyright 2010 Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Implements a simpler interface to `NSTask`.
 
 To use, instantiate the class and send `runCommand:` message like this:
 
	GBTask *task = [GBTask task];
	[task runCommand:@"/bin/ls", nil];
 
 You can also pass arguments to the command and read the output:
 
	NSString *result = [task runCommand:@"/bin/ls", @"-l", @"-a", nil];
 
 You can reuse the same instance for any number of commands.
 */
@interface GBTask : NSObject

///---------------------------------------------------------------------------------------
/// @name Initialization & disposal
///---------------------------------------------------------------------------------------

/** Returns autoreleased instance of the class.
 */
+ (id)task;

///---------------------------------------------------------------------------------------
/// @name Running commands
///---------------------------------------------------------------------------------------

/** Runs the given command with optional arguments.
 
 The command is run synchronously; the application is halted until the command completes. All standard output and error from the command is copied to `lastStandardOutput` and `lastStandardError` properties. If you're interested in these values, check the values. The result of the method is determined from `lastStandardError` value - if it contains non-empty string, error is reported, otherwise success. This should work for most commands, but if you use it on a command that emits errors to standard output, you should not rely solely on method result to determine success - you should instead parse the output string for indications of errors!
 
 @param command Full path to the command to run.
 @param ... A comma separated list of arguments to substitute into the format.
 @return Returns `YES` if command succedded, `NO` otherwise.
 @exception NSException Thrown if the given command is invalid or cannot be started.
 @see lastStandardOutput
 @see lastStandardError
 */
- (BOOL)runCommand:(NSString *)command, ... NS_REQUIRES_NIL_TERMINATION;

/** Returns string emited to standard output pipe the last time `runCommand:` was sent. 
 
 @see runCommand:
 @see lastStandardError
 */
@property (readonly, retain) NSString *lastStandardOutput;

/** Returns string emited to standard error pipe the last time `runCommand:` was sent. 
 
 @see runCommand:
 @see lastStandardOutput
 */
@property (readonly, retain) NSString *lastStandardError;

@end
