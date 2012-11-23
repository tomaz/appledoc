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
#define LOG_FLAG_VERBOSE	(1 << 3)	// 0b0000001000
#define LOG_FLAG_DEBUG		(1 << 4)	// 0b0000010000

#define LOG_LEVEL_ERROR		(LOG_FLAG_ERROR)						// 0b00001
#define LOG_LEVEL_WARN		(LOG_FLAG_WARN    | LOG_LEVEL_ERROR)	// 0b00011
#define LOG_LEVEL_NORMAL	(LOG_FLAG_NORMAL  | LOG_LEVEL_WARN)		// 0b00111
#define LOG_LEVEL_VERBOSE	(LOG_FLAG_VERBOSE | LOG_LEVEL_NORMAL)	// 0b01111
#define LOG_LEVEL_DEBUG		(LOG_FLAG_DEBUG   | LOG_LEVEL_VERBOSE)	// 0b11111

#pragma mark - Determine whether certain log levels are enabled

#define LOG_ERROR_ENABLED   (log_level & LOG_FLAG_ERROR)
#define LOG_WARN_ENABLED    (log_level & LOG_FLAG_WARN)
#define LOG_NORMAL_ENABLED  (log_level & LOG_FLAG_NORMAL)
#define LOG_VERBOSE_ENABLED (log_level & LOG_FLAG_VERBOSE)
#define LOG_DEBUG_ENABLED   (log_level & LOG_FLAG_DEBUG)

#pragma mark - Logging macros & functions

#define LOG_MACRO(flg, frmt, ...) { \
	NSString *message = [NSString gb_format:frmt, ##__VA_ARGS__]; \
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

#define LogError(frmt, ...)		LOG_MAYBE(log_level, LOG_FLAG_ERROR, frmt, ##__VA_ARGS__)
#define LogWarn(frmt, ...)		LOG_MAYBE(log_level, LOG_FLAG_WARN, frmt, ##__VA_ARGS__)
#define LogNormal(frmt, ...)	LOG_MAYBE(log_level, LOG_FLAG_NORMAL, frmt, ##__VA_ARGS__)
#define LogVerbose(frmt, ...)	LOG_MAYBE(log_level, LOG_FLAG_VERBOSE, frmt, ##__VA_ARGS__)
#define LogDebug(frmt, ...)		LOG_MAYBE(log_level, LOG_FLAG_DEBUG, frmt, ##__VA_ARGS__)
#define LogNSError(error, frmt, ...)	LOG_NS_ERROR(log_level, LOG_FLAG_ERROR, error, frmt, ##__VA_ARGS__)
