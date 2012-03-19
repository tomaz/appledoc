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

#define LOG_FLAG_ERROR		(1 << 0)	// 0...000001
#define LOG_FLAG_WARN		(1 << 1)	// 0...000010
#define LOG_FLAG_NORMAL		(1 << 2)	// 0...000100
#define LOG_FLAG_INFO		(1 << 3)	// 0...001000
#define LOG_FLAG_VERBOSE	(1 << 4)	// 0...010000
#define LOG_FLAG_DEBUG		(1 << 5)	// 0...100000

#define LOG_LEVEL_ERROR		(LOG_FLAG_ERROR)						// 0...000001
#define LOG_LEVEL_WARN		(LOG_FLAG_WARN    | LOG_LEVEL_ERROR)	// 0...000011
#define LOG_LEVEL_NORMAL	(LOG_FLAG_NORMAL  | LOG_LEVEL_WARN)		// 0...000111
#define LOG_LEVEL_INFO		(LOG_FLAG_INFO    | LOG_LEVEL_NORMAL)	// 0...001111
#define LOG_LEVEL_VERBOSE	(LOG_FLAG_VERBOSE | LOG_LEVEL_INFO)		// 0...011111
#define LOG_LEVEL_DEBUG		(LOG_FLAG_DEBUG   | LOG_LEVEL_VERBOSE)	// 0...111111

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
#define LOG_MAYBE(lvl, flg, frmt, ...) do { if ((lvl & flg)) LOG_MACRO(flg, frmt, ##__VA_ARGS__); } while(0)

#define LogError(frmt, ...)		LOG_MAYBE(log_level, LOG_FLAG_ERROR, frmt, ##__VA_ARGS__)
#define LogWarn(frmt, ...)		LOG_MAYBE(log_level, LOG_FLAG_WARN, frmt, ##__VA_ARGS__)
#define LogNormal(frmt, ...)	LOG_MAYBE(log_level, LOG_FLAG_NORMAL, frmt, ##__VA_ARGS__)
#define LogInfo(frmt, ...)		LOG_MAYBE(log_level, LOG_FLAG_INFO, frmt, ##__VA_ARGS__)
#define LogVerbose(frmt, ...)	LOG_MAYBE(log_level, LOG_FLAG_VERBOSE, frmt, ##__VA_ARGS__)
#define LogDebug(frmt, ...)		LOG_MAYBE(log_level, LOG_FLAG_DEBUG, frmt, ##__VA_ARGS__)

// Custom macros for logging complex objects.
#define LogNSError(error) { \
	LogError(@"- %@: %@", error.domain, error.localizedDescription); \
	if (error.localizedRecoverySuggestion) LogError(@"Recovery suggestion: %@", error.localizedRecoverySuggestion); \
	if (error.userInfo) { \
		id infos = [error.userInfo allValues]; \
		for (id info in infos) { \
			if ([info isKindOfClass:[NSArray class]]) { \
				for (id detail in info) { \
					if ([detail respondsToSelector:@selector(userInfo)]) \
						LogError(@"- %@", [detail userInfo]); \
					else \
						LogError(@"- %@", detail); \
				} \
			} else { \
				LogError(@"- %@", info); \
			} \
		} \
	} \
}


#pragma mark - Main logging classes & functions

