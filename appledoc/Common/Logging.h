//
//  Logging.h
//  appledoc
//
//  Created by Tomaž Kragelj on 3/12/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

@class GBSettings;

#pragma mark - Logger setup

typedef void(*logger_function_t)(int flag, const char *file, const char *function, int line, NSString *message);
extern void initialize_logging_from_settings(GBSettings *settings);
extern logger_function_t log_function;
extern NSUInteger log_level;

#pragma mark - Low level logging flags

#define LOG_FLAG_ERROR		(1 << 0)	// 0b0000000001
#define LOG_FLAG_WARN		(1 << 1)	// 0b0000000010
#define LOG_FLAG_NORMAL		(1 << 2)	// 0b0000000100
#define LOG_FLAG_INFO		(1 << 3)	// 0b0000001000
#define LOG_FLAG_VERBOSE	(1 << 4)	// 0b0000010000
#define LOG_FLAG_DEBUG		(1 << 5)	// 0b0000100000

#define LOG_FLAG_INTERNAL	(1 << 6)	// 0x0001000000
#define LOG_FLAG_COMMON		(1 << 7)	// 0b0010000000
#define LOG_FLAG_STORE		(1 << 8)	// 0b0100000000
#define LOG_FLAG_PARSING	(1 << 9)	// 0b1000000000

#define LOG_LEVEL_ERROR		(LOG_FLAG_ERROR)						// 0b000001
#define LOG_LEVEL_WARN		(LOG_FLAG_WARN    | LOG_LEVEL_ERROR)	// 0b000011
#define LOG_LEVEL_NORMAL	(LOG_FLAG_NORMAL  | LOG_LEVEL_WARN)		// 0b000111
#define LOG_LEVEL_INFO		(LOG_FLAG_INFO    | LOG_LEVEL_NORMAL)	// 0b001111
#define LOG_LEVEL_VERBOSE	(LOG_FLAG_VERBOSE | LOG_LEVEL_INFO)		// 0b011111
#define LOG_LEVEL_DEBUG		(LOG_FLAG_DEBUG   | LOG_LEVEL_VERBOSE)	// 0b111111

#pragma mark - Determine whether certain log levels are enabled

#define LOG_ERROR_ENABLED   (log_level & LOG_FLAG_ERROR)
#define LOG_WARN_ENABLED    (log_level & LOG_FLAG_WARN)
#define LOG_NORMAL_ENABLED  (log_level & LOG_FLAG_NORMAL)
#define LOG_INFO_ENABLED    (log_level & LOG_FLAG_INFO)
#define LOG_VERBOSE_ENABLED (log_level & LOG_FLAG_VERBOSE)
#define LOG_DEBUG_ENABLED   (log_level & LOG_FLAG_DEBUG)

#pragma mark - Logging macros & functions

#define LOG_MACRO(flg, frmt, ...) { \
	NSString *message = [NSString stringWithFormat:frmt, ##__VA_ARGS__]; \
	log_function(flg, __FILE__, __PRETTY_FUNCTION__, __LINE__, message); \
}

#define LOG_MAYBE(lvl, flg, frmt, ...) do { if ((lvl & (flg)) == (flg)) LOG_MACRO(flg, frmt, ##__VA_ARGS__); } while(0)

#define LOG_NS_ERROR(lvl, flg, error, frmt, ...) do { \
	if ((lvl & (flg)) == (flg)) { \
		LOG_MACRO(flg, frmt, ##__VA_ARGS__); \
		LOG_MACRO(flg, @"- %@ (%lu): %@", error.domain, error.code, error.localizedDescription); \
		if (error.localizedFailureReason) LOG_MACRO(flg, @"- %@", error.localizedFailureReason); \
	} \
} while(0)

// Common logging macros - for use in most cases (used by default)

#define LogError(frmt, ...)		LOG_MAYBE(log_level, LOG_FLAG_ERROR | LOG_FLAG_COMMON, frmt, ##__VA_ARGS__)
#define LogWarn(frmt, ...)		LOG_MAYBE(log_level, LOG_FLAG_WARN | LOG_FLAG_COMMON, frmt, ##__VA_ARGS__)
#define LogNormal(frmt, ...)	LOG_MAYBE(log_level, LOG_FLAG_NORMAL | LOG_FLAG_COMMON, frmt, ##__VA_ARGS__)
#define LogInfo(frmt, ...)		LOG_MAYBE(log_level, LOG_FLAG_INFO | LOG_FLAG_COMMON, frmt, ##__VA_ARGS__)
#define LogVerbose(frmt, ...)	LOG_MAYBE(log_level, LOG_FLAG_VERBOSE | LOG_FLAG_COMMON, frmt, ##__VA_ARGS__)
#define LogDebug(frmt, ...)		LOG_MAYBE(log_level, LOG_FLAG_DEBUG | LOG_FLAG_COMMON, frmt, ##__VA_ARGS__)
#define LogNSError(error, frmt, ...)	LOG_NS_ERROR(log_level, LOG_FLAG_ERROR | LOG_FLAG_COMMON, error, frmt, ##__VA_ARGS__)

// Internal logging macros - for logging low level stuff like init/dealloc

#define LogIntDebug(frmt, ...)		LOG_MAYBE(log_level, LOG_FLAG_INTERNAL, frmt, ##__VA_ARGS__)

// Store logging macros - for logging store specific cases (excluded by default)

#define LogStoError(frmt, ...)		LOG_MAYBE(log_level, LOG_FLAG_ERROR | LOG_FLAG_STORE, frmt, ##__VA_ARGS__)
#define LogStoWarn(frmt, ...)		LOG_MAYBE(log_level, LOG_FLAG_WARN | LOG_FLAG_STORE, frmt, ##__VA_ARGS__)
#define LogStoNormal(frmt, ...)		LOG_MAYBE(log_level, LOG_FLAG_NORMAL | LOG_FLAG_STORE, frmt, ##__VA_ARGS__)
#define LogStoInfo(frmt, ...)		LOG_MAYBE(log_level, LOG_FLAG_INFO | LOG_FLAG_STORE, frmt, ##__VA_ARGS__)
#define LogStoVerbose(frmt, ...)	LOG_MAYBE(log_level, LOG_FLAG_VERBOSE | LOG_FLAG_STORE, frmt, ##__VA_ARGS__)
#define LogStoDebug(frmt, ...)		LOG_MAYBE(log_level, LOG_FLAG_DEBUG | LOG_FLAG_STORE, frmt, ##__VA_ARGS__)
#define LogStoNSError(error, frmt, ...)	LOG_NS_ERROR(log_level, LOG_FLAG_ERROR | LOG_FLAG_STORE, error, frmt, ##__VA_ARGS__)

// Parser logging macros - for logging parser specific cases (excluded by default)

#define LogParError(frmt, ...)		LOG_MAYBE(log_level, LOG_FLAG_ERROR | LOG_FLAG_PARSING, frmt, ##__VA_ARGS__)
#define LogParWarn(frmt, ...)		LOG_MAYBE(log_level, LOG_FLAG_WARN | LOG_FLAG_PARSING, frmt, ##__VA_ARGS__)
#define LogParNormal(frmt, ...)		LOG_MAYBE(log_level, LOG_FLAG_NORMAL | LOG_FLAG_PARSING, frmt, ##__VA_ARGS__)
#define LogParInfo(frmt, ...)		LOG_MAYBE(log_level, LOG_FLAG_INFO | LOG_FLAG_PARSING, frmt, ##__VA_ARGS__)
#define LogParVerbose(frmt, ...)	LOG_MAYBE(log_level, LOG_FLAG_VERBOSE | LOG_FLAG_PARSING, frmt, ##__VA_ARGS__)
#define LogParDebug(frmt, ...)		LOG_MAYBE(log_level, LOG_FLAG_DEBUG | LOG_FLAG_PARSING, frmt, ##__VA_ARGS__)
#define LogParNSError(error, frmt, ...)	LOG_NS_ERROR(log_level, LOG_FLAG_ERROR | LOG_FLAG_PARSING, error, frmt, ##__VA_ARGS__)

#pragma mark - Main logging classes & functions

