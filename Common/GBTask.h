//
//  GBTask.h
//  appledoc
//
//  Created by Tomaz Kragelj on 30.11.10.
//  Copyright 2010 Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^GBTaskReportBlock)(NSString *output, NSString *error);

/** Implements a simpler interface to `NSTask`.
 
 The class is designed to be completely reusable - it doesn't depend on any project specific object or external library, so you can simply copy the .h and .m files to another project and use it. To run a command instantiate the class and send `runCommand:` message. You can pass in optional arguments if needed:
 
	GBTask *task = [GBTask task];
	[task runCommand:@"/bin/ls", nil]; 
	[task runCommand:@"/bin/ls", @"-l", @"-a", nil];
 
 If you want to be continuously notified when output or error is reported by the command (for example when you're running lenghtier commands and want to update user interface so the user is aware something is happening), use block method `runCommand:arguments:block`:
 
	GBTask *task = [GBTask task];
	[task runCommand:@"/bin/ls" arguments:nil block:^(NSString *output, NSString *error) {
		// do something with output and error here...
	}];

 You can affect how the output and error is reported through by changing the value of `reportIndividualLines`.
 
 You can reuse the same instance for any number of commands. After the command is finished, you can examine it's results through `lastStandardOutput` and `lastStandardError` properties. You can also check the actual command line string used for running the command through `lastCommandLine`; this value includes the command and all parameters in a single string. If any parameter contains whitespace, it is embedded into quotes. All these properties work the same regardless of the way you run the command.
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
 
 Internally, sending this message is equivalent to sending `runCommand:arguments:block:` with wrapping all the arguments into an `NSArray` and passing `nil` for block!
 
 @param command Full path to the command to run.
 @param ... A comma separated list of arguments to substitute into the format.
 @return Returns `YES` if command succedded, `NO` otherwise.
 @exception NSException Thrown if the given command is invalid or cannot be started.
 @see runCommand:arguments:block:
 @see lastCommandLine
 @see lastStandardOutput
 @see lastStandardError
 */
- (BOOL)runCommand:(NSString *)command, ... NS_REQUIRES_NIL_TERMINATION;

/** Runs the given command and optional arguments using the given block to continuously report back any output or error received from the command while it's running.
 
 In contrast to `runCommand:`, this method uses the given block to report any string received on standard output or error, immediately when the command emits it. The block reports only the type of input received - if output is received only, error is `nil` and vice versa. In addition, all strings are concatenated and copied into `lastStandardOutput` and `lastStandardError` respectively. However these properties are only useful after the method returns. To change the way reporting is handled, use `reportIndividualLines` property. Note that if `nil` is passed for block, the method simply reverts to normal handling and doesn't use block.
 
 The command is run synchronously; the application is halted until the command completes. All standard output and error from the command is copied to `lastStandardOutput` and `lastStandardError` properties. The result of the method is determined from `lastStandardError` value - if it contains non-empty string, error is reported, otherwise success. This should work for most commands, but if you use it on a command that emits errors to standard output, you should not rely solely on method results to determine success - you should instea parse the output string for indications of errors!
 
 @param command Full path to the command to run.
 @param arguments Array of arguments or `nil` if no arguments are used.
 @param block Block to use for continuous reporting or `nil` to not use block.
 @return Returns `YES` if command succedded, `NO` otherwise.
 @exception NSException Thrown if the given command is invalid or cannot be started.
 @see runCommand:
 @see lastCommandLine
 @see lastStandardOutput
 @see lastStandardError
 */
- (BOOL)runCommand:(NSString *)command arguments:(NSArray *)arguments block:(GBTaskReportBlock)block;

/** Specifies whether output reported while the command is running is split to individual lines or not.
 
 If set to `YES`, any output from standard output and error is first split to individual lines, then each line is reported separately. This can be useful in cases where multiple lines are reported in one block call, but we want to handle them line by line. Turning the option on does reduce runtime performance, so be sure to measure it. Defaults to `NO`.
 */
@property (assign) BOOL reportIndividualLines;

///---------------------------------------------------------------------------------------
/// @name Last results
///---------------------------------------------------------------------------------------

/** Returns last command line including all arguments as passed to `runCommand:` the last it was sent.
 
 @see runCommand:
 @see runCommand:arguments:block:
 @see lastStandardOutput
 @see lastStandardError
 */
@property (readonly, strong) NSString *lastCommandLine;

/** Returns string emited to standard output pipe the last time `runCommand:` was sent. 
 
 @see runCommand:
 @see runCommand:arguments:block:
 @see lastStandardError
 */
@property (readonly, strong) NSString *lastStandardOutput;

/** Returns string emited to standard error pipe the last time `runCommand:` was sent. 
 
 @see runCommand:
 @see runCommand:arguments:block:
 @see lastStandardOutput
 */
@property (readonly, strong) NSString *lastStandardError;

@end
