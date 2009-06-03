//
//  Systemator.h
//  appledoc
//
//  Created by Tomaz Kragelj on 14.4.09.
//  Copyright 2009 Tomaz Kragelj. All rights reserved.
//

#import <Foundation/Foundation.h>

//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
/** Implements common system related stuff that can be used in all application classes.

Note that this class only contains class methods, so no instance is needed.
*/
@interface Systemator : NSObject

/** Runs the given task.

This is a helper method which facilitates running external commands. It creates a task,
parameterizes it and runs it. After the tasks ends, the method will also return. The
command automatically detects user's default shell and takes path from it.
 
Note that the method accepts variable number of arguments following the command. The
list must end with @c nil otherwise @c SIGSEGV error will be raised.

@param command The command line of the task.
@exception NSException Thrown if running the task fails.
@see runShellTaskWithCommand:
*/
+ (void) runTask:(NSString*) command, ...;

/** Runs the given command with the user's shell.

This will first get the user's default shell and will use it to execute the given command.
The given command will first be saved to the temporary path then it will be executed and
temporary file removed. This command allows the clients to properly handle shell path.

@param command The command to execute.
@exception NSException Thrown if running task fails.
@see runTask:
*/
+ (void) runShellTaskWithCommand:(NSString*) command;

/** Creates the given directory.

If the directory (or file with that name) already exists, nothing happens. Otherwise
the directory is created. If creation fails, exception is thrown.

@param path The directory path to create.
@exception NSException Thrown if creation fails.
*/
+ (void) createDirectory:(NSString*) path;

/** Reads the contents of the given file and returns the array of all lines.

The file is assumed to be in @c NSASCIIStringEncoding. If reading fails, the exception 
explaining the reason is thrown. To write the array of strings into the filename,
you can use @c writeLines:toFile:().

@param filename The name of the file including full path.
@return Returns the array of @c NSString instanced representing individual file lines.
@exception NSException Thrown if reading from the file fails.
*/
+ (NSMutableArray*) linesFromContentsOfFile:(NSString*) filename;

/** Writes the given array of strings to the given file.

If the file already exists, it is truncated before writting. If writting fails, the
exception explaining the reason is thrown. To read the contents of a file into the
array of lines, you can use @c linesFromContentsOfFile:().

@param lines The @c NSArray containing strings to write.
@param filename The name of the file.
@exception NSException Thrown if writting fails.
*/
+ (void) writeLines:(NSArray*) lines toFile:(NSString*) filename;

/** Reads the property list from the given filename.

If the file doesn't exist or reading fails, exception is thrown.

@param filename The name of the plist file.
@return Returns the object that represents the property list data or @c nil if not possible.
@exception NSException Thrown if reading fails.
@see writePropertyList:toFile:
*/
+ (id) readPropertyListFromFile:(NSString*) filename;

/** Writes the given property list to the given filename.

If writting fails, exception is thrown.

@param plist The property list object to be serialized.
@param filename The name of the file to write to.
@exception NSException Thrown if writting fails.
@see readPropertyListFromFile:
*/
+ (void) writePropertyList:(id) plist toFile:(NSString*) filename;

/** Throws an @c NSException with description from the given @c NSError;
 
See also @c throwExceptionWithName:withDescription:().

@param name The exception name.
@param error The @c NSError which description and data to use for exception.
@exception NSException Always thrown...
*/
+ (void) throwExceptionWithName:(NSString*) name basedOnError:(NSError*) error;

/** Throws an @c NSException with the given description
 
See also @c throwExceptionWithName:basedOnError:().

@param name The exception name.
@param description The description of the error.
@exception NSException Always thrown...
*/
+ (void) throwExceptionWithName:(NSString*) name withDescription:(NSString*) description;

@end
