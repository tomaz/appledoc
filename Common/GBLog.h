//
//  GBLog.h
//  appledoc
//
//  Created by Tomaz Kragelj on 22.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "DDLog.h"
#import "DDTTYLogger.h"
#import "DDFileLogger.h"
#import "DDCliUtil.h"

// Undefine defaults

#undef LOG_FLAG_ERROR
#undef LOG_FLAG_WARN 
#undef LOG_FLAG_INFO
#undef LOG_FLAG_VERBOSE

#undef LOG_LEVEL_ERROR
#undef LOG_LEVEL_WARN
#undef LOG_LEVEL_INFO
#undef LOG_LEVEL_VERBOSE

#undef LOG_ERROR
#undef LOG_WARN
#undef LOG_INFO
#undef LOG_VERBOSE

#undef DDLogError
#undef DDLogWarn
#undef DDLogInfo
#undef DDLogVerbose

#undef DDLogCError
#undef DDLogCWarn
#undef DDLogCInfo
#undef DDLogCVerbose

#undef SYNC_LOG_OBJC_MAYBE

// Now define everything the way we want it...

extern NSUInteger kGBLogLevel;
extern NSInteger kGBLogBasedResult;
void GBLogUpdateResult(NSInteger result);

#define LOG_FLAG_FATAL		(1 << 0) // 0...0000001
#define LOG_FLAG_ERROR		(1 << 1) // 0...0000010
#define LOG_FLAG_WARN		(1 << 2) // 0...0000100
#define LOG_FLAG_NORMAL		(1 << 3) // 0...0001000
#define LOG_FLAG_INFO		(1 << 4) // 0...0010000
#define LOG_FLAG_VERBOSE    (1 << 5) // 0...0100000
#define LOG_FLAG_DEBUG		(1 << 6) // 0...1000000

#define LOG_LEVEL_FATAL		(LOG_FLAG_FATAL)						// 0...0000001
#define LOG_LEVEL_ERROR		(LOG_FLAG_ERROR   | LOG_LEVEL_FATAL)	// 0...0000011
#define LOG_LEVEL_WARN		(LOG_FLAG_WARN    | LOG_LEVEL_ERROR)	// 0...0000111
#define LOG_LEVEL_NORMAL	(LOG_FLAG_NORMAL  | LOG_LEVEL_WARN)		// 0...0001111
#define LOG_LEVEL_INFO		(LOG_FLAG_INFO    | LOG_LEVEL_NORMAL)	// 0...0011111
#define LOG_LEVEL_VERBOSE	(LOG_FLAG_VERBOSE | LOG_LEVEL_INFO)		// 0...0111111
#define LOG_LEVEL_DEBUG		(LOG_FLAG_DEBUG   | LOG_LEVEL_VERBOSE)	// 0...1111111

#define  SYNC_LOG_OBJC_MAYBE(lvl, flg, frmt, ...) LOG_MAYBE(YES, lvl, flg, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

#define GBLogFatal(frmt, ...)	{ GBLogUpdateResult(GBEXIT_LOG_FATAL); SYNC_LOG_OBJC_MAYBE(kGBLogLevel, LOG_FLAG_FATAL, frmt, ##__VA_ARGS__); }
#define GBLogError(frmt, ...)	{ GBLogUpdateResult(GBEXIT_LOG_ERROR); SYNC_LOG_OBJC_MAYBE(kGBLogLevel, LOG_FLAG_ERROR, frmt, ##__VA_ARGS__); }
#define GBLogWarn(frmt, ...)	{ GBLogUpdateResult(GBEXIT_LOG_WARNING); SYNC_LOG_OBJC_MAYBE(kGBLogLevel, LOG_FLAG_WARN, frmt, ##__VA_ARGS__); }
#define GBLogNormal(frmt, ...)	SYNC_LOG_OBJC_MAYBE(kGBLogLevel, LOG_FLAG_NORMAL, frmt, ##__VA_ARGS__)
#define GBLogInfo(frmt, ...)	SYNC_LOG_OBJC_MAYBE(kGBLogLevel, LOG_FLAG_INFO, frmt, ##__VA_ARGS__)
#define GBLogVerbose(frmt, ...)	SYNC_LOG_OBJC_MAYBE(kGBLogLevel, LOG_FLAG_VERBOSE, frmt, ##__VA_ARGS__)
#define GBLogDebug(frmt, ...)	SYNC_LOG_OBJC_MAYBE(kGBLogLevel, LOG_FLAG_DEBUG, frmt, ##__VA_ARGS__)
#define GBLogIsEnabled(level)	((kGBLogLevel & level) > 0)

// Macros that store given file/line info. Mostly used for better Xcode integration!
#define GBLogXError(source,frmt,...) { [DDLog storeFilename:[source fullpath] line:[source lineNumber]]; GBLogError(frmt, ##__VA_ARGS__); }
#define GBLogXWarn(source,frmt,...) { [DDLog storeFilename:[source fullpath] line:[source lineNumber]]; GBLogWarn(frmt, ##__VA_ARGS__); }
#define GBLogXInfo(source,frmt,...) { [DDLog storeFilename:[source fullpath] line:[source lineNumber]]; GBLogInfo(frmt, ##__VA_ARGS__); }

// Helper macros for logging exceptions. Note that we don't use formatting here as it would make the output unreadable
// in higher level log formats. The information is already verbose enough!
#define GBLogExceptionLine(frmt,...) { ddprintf(frmt, ##__VA_ARGS__); ddprintf(@"\n"); }
#define GBLogExceptionNoStack(exception,frmt,...) { \
	if (frmt) GBLogExceptionLine(frmt, ##__VA_ARGS__); \
	GBLogExceptionLine(@"%@: %@", [exception name], [exception reason]); \
}
#define GBLogException(exception,frmt,...) { \
	GBLogExceptionNoStack(exception,frmt,##__VA_ARGS__); \
	NSArray *symbols = [exception callStackSymbols]; \
	for (NSString *symbol in symbols) { \
		GBLogExceptionLine(@"  @ %@", symbol); \
	} \
}
#define GBLogNSError(error,frmt,...) { \
	if (frmt) GBLogExceptionLine(frmt, ##__VA_ARGS__); \
	if ([error localizedDescription]) GBLogExceptionLine(@"%@", [error localizedDescription]); \
	if ([error localizedFailureReason]) GBLogExceptionLine(@"%@", [error localizedFailureReason]); \
}

#pragma mark Application wide logging helpers

/** Logging helper class with common log-related functionality.
 */
@interface GBLog : NSObject

/** Sets logging level to the given value.
 
 Sending this message has the same effect as setting the value of `kGBLogLevel` directly.
 
 @param value The new application-wide log level.
 @see setLogLevelFromVerbose:
 */
+ (void)setLogLevel:(NSUInteger)value;

/** Sets logging level from the given verbose command line argument value.
 
 The method converts the given command line argument value to a proper log level and sends it to @c setLogLevel: 
 method. The value is forced into a valid range beforehand.
 
 @param verbosity Verbose command line argument value to use.
 */
+ (void)setLogLevelFromVerbose:(NSString *)verbosity;

/** Returns proper log formatter based on the given log format command line argument value.
 
 The method returns `GBLogFormat0Formatter`, `GBLogFormat1Formatter`, `GBLogFormat2Formatter`, `GBLogFormat3Formatter` 
 or `GBLogFormat4Formatter` instance, based on the given value. The value is forced into a valid range beforehand.
 
 @param level Log format command line argument value to use.
 @return Returns the log formatter corresponding to the given value.
 */
+ (id<DDLogFormatter>)logFormatterForLogFormat:(NSString *)level;

@end

#pragma mark Our custom loggers

@interface GBConsoleLogger : DDAbstractLogger <DDLogger>

+ (GBConsoleLogger *)sharedInstance;

@end

#pragma mark Log formatters

@interface GBLogFormat0Formatter : NSObject <DDLogFormatter>
@end

@interface GBLogFormat1Formatter : NSObject <DDLogFormatter>
@end

@interface GBLogFormat2Formatter : NSObject <DDLogFormatter>
@end

@interface GBLogFormat3Formatter : NSObject <DDLogFormatter>
@end

@interface GBLogFormatXcodeFormatter : NSObject <DDLogFormatter>
@end
