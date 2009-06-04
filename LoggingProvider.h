//
//  LoggingProvider.h
//  appledoc
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

Logging providers are objects that provider methods that implement logging support fot
the application.
*/
@protocol LoggingProvider

/** Logs an error.

@param message The message to log.
*/
- (void) logError:(NSString*) message;

/** Logs a normal message.

@param message The message to log.
*/
- (void) logNormal:(NSString*) message;

/** Logs a normal message.
 
Info messages are only logged if info level is used.
 
param message The message to log.
*/
- (void) logInfo:(NSString*) message;

/** Logs a verbosed message.

Verbosed messages are only logged if verbosed level is used.

@param message The message to log.
*/
- (void) logVerbose:(NSString*) message;

/** Logs a debug message.

Debug messages are only logged if verbosed level is used.

@param message The message to log.
*/
- (void) logDebug:(NSString*) message;

/** Determines if normal logging is enabled or not.
 
@return Returns @c YES if normal logging is enabled, @c NO otherwise.
*/
- (BOOL) isNormalEnabled;

/** Determines if info logging is enabled or not.
 
@return Returns @c YES if info logging is enabled, @c NO otherwise.
*/
- (BOOL) isInfoEnabled;

/** Determines if verbosed logging is enabled or not.

@return Returns @c YES if verbosed logging is enabled, @c NO otherwise.
*/
- (BOOL) isVerboseEnabled;

/** Determines if debug logging is enabled or not.
 
@return Returns @c YES if debug logging is enabled, @c NO otherwise.
*/
- (BOOL) isDebugEnabled;

@end

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Default logger implementation
//////////////////////////////////////////////////////////////////////////////////////////

/** Defines the basic application logger.

This class implements the application wide logger. It is implemented as a singleton, so
that it is easily accessible for all other classes. Note that this class is closely
coupled with @c CommandLineParser from which it takes the verbose and debug logging
levels.
*/
@interface Logger : NSObject <LoggingProvider>

/** Returns the default shared instance of the class.
*/
+ (Logger*) sharedInstance;

/** Logs the given message to the output.

@param message The message to log.
@param type The type of the message.
*/
- (void) logMessage:(NSString*) message type:(NSString*) type;

@end

//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////

/** This is only used for testing double protocols handling. */
@protocol Blabla1
@optional
- (void) doNothing1;
@end

/** This is only used for testing double protocols handling. */
@protocol Blabla2
@optional
- (void) doNothing2;
@end

/* This is not documented on purpose so that link is not created. */
@protocol Blabla3
@optional
- (void) doNothing3;
@end

/** A super class declaration.
 
This class is not used anywhere in the application. It's just here so we can test
derived classes documentation handling... And yes, we also use the object for
testing links to external objects such as @c Systemator and their members
like @c Systemator::runTask:(). We even support linking to external categories
like this: @c NSObject(Logging) and their members like: @c NSObject(Logging)::logger()
(for these we need to fix doxygen output since it's confused with categories). See
that we can also correctly spell non-documented category or class members such as:
@c NSObject(Nonexistent)::methodWithParameter1:andParameter2:() or
@c NSObject::description(). However notice that for unknown objects the prefix is not 
used since we don't have the required information.
*/
@interface SuperLogger : Logger <Blabla1, Blabla2, Blabla3>

/** This method does nothing.￼

Except it uses warning keyword so that we can test it easily in the generated output. 
It also shows how to use code segments. Well because of all these features, bells and 
whistles, the generated output looks kind of... well... see for yourself:
 
@verbatim
BOOL result = [SuperLogger thisMethodUsesWarningAndExample:0 withValue:45];
if (result)
{
    NSLog(@"What a beautiful life!");
}
@endverbatim
 
The code section is followed by another standard paragraph. Aha, forgot to mention - the
paragraph text is just being entered so that the paragraph will contain more than a single
line of text. At least with current browser width. And yea, because I'm not online at
the moment, I cannot use lorem ipsum for that. And I also don't know it from the memory.
There's much more important stuff to remember than that... Except for the cases like this
where the text is actually needed. Well, looks like my imagination is still working...

@param param The parameter.
@param value The value.
@return Returns some value.
@exception NSException Thrown if something goes wrong.
@warning @b Important: Use this method only for doing nothing. Because that's what it 
	does... And it's actually pretty good at that too! Probably it's easy to miss, but
	take a closer look at the important word which is actually emphasized in the generated
	XHTML documentation!
@see someOtherMethod:
*/
+ (BOOL) thisMethodUsesWarningAndExample:(int) param withValue:(int) value;

/** And this is where our bug is described.￼

This method does nothing except for the mentioned bug.
@bug @b ID104: There's a strange bug in this method. And that is - it misses all the code! To
	reproduce it, just follow these instructions: write another method in the class
	interface and ommit the definition in the class implementation section.
*/
+ (void) someOtherMethod;

@end

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Logging macros and functions
//////////////////////////////////////////////////////////////////////////////////////////

NSString* FormatLogMessage(char* file, const char* method, int line, NSString* message, ...);

#define logargs(m) __FILE__, __PRETTY_FUNCTION__, __LINE__, m

#define logError(m, ...) [[self logger] logError:FormatLogMessage(logargs(m), ##__VA_ARGS__)]

#define logNormal(m, ...) if ([[self logger] isNormalEnabled]) [[self logger] logNormal:FormatLogMessage(logargs(m), ##__VA_ARGS__)]

#define logInfo(m, ...) if ([[self logger] isInfoEnabled]) [[self logger] logInfo:FormatLogMessage(logargs(m), ##__VA_ARGS__)]

#define logVerbose(m, ...) if ([[self logger] isVerboseEnabled]) [[self logger] logVerbose:FormatLogMessage(logargs(m), ##__VA_ARGS__)]

#define logDebug(m, ...) if ([[self logger] isDebugEnabled]) [[self logger] logDebug:FormatLogMessage(logargs(m), ##__VA_ARGS__)]
