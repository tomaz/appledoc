//
//  GBLog.m
//  appledoc
//
//  Created by Tomaz Kragelj on 22.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#include <sys/timeb.h>
#import "GBLog.h"

// NOTE: All functions here are purposely using C interface to keep as little overhead as possible.

#pragma mark - Definitions of external symbols

logger_function_t log_function = NULL;
NSUInteger log_level = LOG_LEVEL_NORMAL;
NSInteger kGBLogBasedResult = GBEXIT_SUCCESS;

#pragma mark - Common formatting functions

static FILE *log_output_for_flag(int flag) {
	switch (flag) {
		case LOG_FLAG_ERROR:
		case LOG_FLAG_WARN:
			return stderr;
	}
	return stdout;
}

static inline char *log_current_time() {
	static char formatted[50];
	static char result[50];
	
	// Get time with milliseconds precision.
	struct timeb now;
	ftime(&now);
	
	// Convert time since epoch to struct and format
	struct tm *tm = localtime(&now.time);
	strftime(formatted, 50, "%H:%M:%S", tm);
	
	// Use formatted time and append milliseconds.
	sprintf(result, "%s.%03d", formatted, now.millitm);
	return result;
}

static char *log_file_name(const char *path) {
	return strrchr(path, '/') ? strrchr(path, '/') + 1 : path;
}

static char *log_flag_description(int flag) {
	switch (flag) {
		case LOG_FLAG_ERROR: return "ERROR";
		case LOG_FLAG_WARN: return "WARN";
		case LOG_FLAG_NORMAL: return "NORMAL";
		case LOG_FLAG_INFO: return "INFO";
		case LOG_FLAG_VERBOSE: return "VERBOSE";
		case LOG_FLAG_DEBUG: return "DEBUG";
	}
	return "UNKNOWN";
}

#pragma mark - Logging implementation

static void log_function_1(int flag, const char *path, const char *function, int line, NSString *message) {
	FILE *output = log_output_for_flag(flag);
	char *time = log_current_time();
	char *level = log_flag_description(flag);
	fprintf(output, "%s %s > %s\n", time, level, [message UTF8String]);
}

static void log_function_2(int flag, const char *path, const char *function, int line, NSString *message) {
	FILE *output = log_output_for_flag(flag);
	char *time = log_current_time();
	char *file = log_file_name(path);
	char *level = log_flag_description(flag);
	fprintf(output, "%s: %s:%d %s > %s\n", time, file, line, level, [message UTF8String]);
}

static void log_function_3(int flag, const char *path, const char *function, int line, NSString *message) {
	FILE *output = log_output_for_flag(flag);
	char *time = log_current_time();
	char *level = log_flag_description(flag);
	fprintf(output, "%s: %s (line %d) %s > %s\n", time, function, line, level, [message UTF8String]);
}

void initialize_logging() {
	log_level = LOG_LEVEL_NORMAL;
	log_function = log_function_2;
}
