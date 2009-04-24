//
//  LoggingProvider.h
//  objcdoc
//
//  Created by Tomaz Kragelj on 12.4.09.
//  Copyright 2009 Tomaz Kragelj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+Logging.h"

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark LoggingProvider protocol
//////////////////////////////////////////////////////////////////////////////////////////

/** Defines the requirements for logging providers.

￼￼Logging providers are objects that provider methods that implement logging support fot
the application.
*/
@protocol LoggingProvider

/** Logs an error.￼

@param message ￼￼￼￼￼￼The message to log.
*/
- (void) logError:(NSString*) message;

/** Logs a normal message.￼

@param message ￼￼￼￼￼￼The message to log.
*/
- (void) logNormal:(NSString*) message;

/** Logs a normal message.￼
 
Info messages are only logged if info level is used.
 
param message ￼￼￼￼￼￼The message to log.
*/
- (void) logInfo:(NSString*) message;

/** Logs a verbosed message.￼

Verbosed messages are only logged if verbosed level is used.

@param message ￼￼￼￼￼￼The message to log.
*/
- (void) logVerbose:(NSString*) message;

/** Logs a debug message.￼

Debug messages are only logged if verbosed level is used.

@param message ￼￼￼￼￼￼The message to log.
*/
- (void) logDebug:(NSString*) message;

/** Determines if info logging is enabled or not.￼
 
@return ￼￼￼￼Returns @c YES if info logging is enabled, @c NO otherwise.
*/
- (BOOL) isInfoEnabled;

/** Determines if verbosed logging is enabled or not.￼

@return ￼￼￼￼Returns @c YES if verbosed logging is enabled, @c NO otherwise.
*/
- (BOOL) isVerboseEnabled;

/** Determines if debug logging is enabled or not.￼
 
@return ￼￼￼￼Returns @c YES if debug logging is enabled, @c NO otherwise.
*/
- (BOOL) isDebugEnabled;

@end

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Default logger implementation
//////////////////////////////////////////////////////////////////////////////////////////

/** Defines the basic application logger.

￼￼This class implements the application wide logger. It is implemented as a singleton, so
that it is easily accessible for all other classes. Note that this class is closely
coupled with @c CommandLineParser from which it takes the verbose and debug logging
levels.
*/
@interface Logger : NSObject <LoggingProvider>

/** Returns the default shared instance of the class.￼
*/
+ (Logger*) sharedInstance;

/** Logs the given message to the output.￼

@param message ￼￼￼￼￼￼The message to log.
@param type The type of the message.
*/
- (void) logMessage:(NSString*) message type:(NSString*) type;

@end

//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////

/** This is only used for testing double protocols handling... */
@protocol Blabla1
@optional
- (void) doNothing1;
@end

/** This is only used for testing double protocols handling... */
@protocol Blabla2
@optional
- (void) doNothing2;
@end

/* This is not documented on purpose so that link is not created... */
@protocol Blabla3
@optional
- (void) doNothing3;
@end

/** A super class declaration.
 
This class is not used anywhere in the application. It's just here so we can test
derived classes documentation handling...
*/
@interface SuperLogger : Logger <Blabla1, Blabla2, Blabla3>

@end

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Logging macros and functions
//////////////////////////////////////////////////////////////////////////////////////////

NSString* FormatLogMessage(char* file, const char* method, int line, NSString* message, ...);

#define logargs(m) __FILE__, __PRETTY_FUNCTION__, __LINE__, m

#define logError(m, ...) [[self logger] logError:FormatLogMessage(logargs(m), ##__VA_ARGS__)]

#define logNormal(m, ...) [[self logger] logNormal:FormatLogMessage(logargs(m), ##__VA_ARGS__)]

#define logInfo(m, ...) if ([[self logger] isInfoEnabled]) [[self logger] logInfo:FormatLogMessage(logargs(m), ##__VA_ARGS__)]

#define logVerbose(m, ...) if ([[self logger] isVerboseEnabled]) [[self logger] logVerbose:FormatLogMessage(logargs(m), ##__VA_ARGS__)]

#define logDebug(m, ...) if ([[self logger] isDebugEnabled]) [[self logger] logDebug:FormatLogMessage(logargs(m), ##__VA_ARGS__)]
