//
//  GBLog.h
//  appledoc
//
//  Created by Tomaz Kragelj on 22.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "DDLog.h"
#import "DDConsoleLogger.h"
#import "DDFileLogger.h"

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

// Now define everything the way we want it...

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

#define LOG_FATAL	(ddLogLevel & LOG_FLAG_FATAL)
#define LOG_ERROR	(ddLogLevel & LOG_FLAG_ERROR)
#define LOG_WARN	(ddLogLevel & LOG_FLAG_WARN)
#define LOG_NORMAL	(ddLogLevel & LOG_FLAG_NORMAL)
#define LOG_INFO	(ddLogLevel & LOG_FLAG_INFO)
#define LOG_VERBOSE	(ddLogLevel & LOG_FLAG_VERBOSE)
#define LOG_DEBUG	(ddLogLevel & LOG_FLAG_DEBUG)

#define logFatal(frmt, ...)		SYNC_LOG_OBJC_MAYBE(ddLogLevel, LOG_FLAG_FATAL, frmt, ##__VA_ARGS__)
#define logError(frmt, ...)		SYNC_LOG_OBJC_MAYBE(ddLogLevel, LOG_FLAG_ERROR, frmt, ##__VA_ARGS__)
#define logWarn(frmt, ...)		ASYNC_LOG_OBJC_MAYBE(ddLogLevel, LOG_FLAG_WARN, frmt, ##__VA_ARGS__)
#define logNormal(frmt, ...)	ASYNC_LOG_OBJC_MAYBE(ddLogLevel, LOG_FLAG_NORMAL, frmt, ##__VA_ARGS__)
#define logInfo(frmt, ...)		ASYNC_LOG_OBJC_MAYBE(ddLogLevel, LOG_FLAG_INFO, frmt, ##__VA_ARGS__)
#define logVerbose(frmt, ...)	ASYNC_LOG_OBJC_MAYBE(ddLogLevel, LOG_FLAG_VERBOSE, frmt, ##__VA_ARGS__)
#define logDebug(frmt, ...)		ASYNC_LOG_OBJC_MAYBE(ddLogLevel, LOG_FLAG_DEBUG, frmt, ##__VA_ARGS__)

// Helper macros for higher level logging.
#define LOG_ERROR_LINE(prefix,error) logError(@"%@%@ #%d: %@", prefix, [error domain], [error code], [error localizedDescription]);
#define logNSError(error,frmt,...) if (YES) { \
	if (frmt) logError(frmt, ##__VA_ARGS__); \
	NSError *err = error; \
	while (err) { \
		LOG_ERROR_LINE(@"", err); \
		NSDictionary *info = [err userInfo]; \
		if (info) { \
			for (NSError *detail in [info valueForKey:NSDetailedErrorsKey]) { \
				LOG_ERROR_LINE(@"- ", detail); \
			} \
			err = [info valueForKey:NSUnderlyingErrorKey]; \
			continue; \
		} \
		break; \
	} \
}

// Our dynamic logging helpers

#define DECLARE_DYNAMIC_LOGGING_CLASS \
	static NSInteger ddLogLevel = LOG_LEVEL_INFO; \
	+ (NSInteger)ddLogLevel { \
		return ddLogLevel; \
	} \
	+ (void)ddSetLogLevel:(NSInteger)logLevel { \
		ddLogLevel = logLevel; \
	}

// Our custom formatters.

@interface GBSimpleLogFormatter : NSObject <DDLogFormatter>
@end

@interface GBFullLogFormatter : NSObject <DDLogFormatter>
@end
