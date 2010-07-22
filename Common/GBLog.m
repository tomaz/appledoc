//
//  GBLog.m
//  appledoc
//
//  Created by Tomaz Kragelj on 22.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBLog.h"

#pragma mark Log level handling

@implementation GBLog

NSUInteger kGBLogLevel = LOG_LEVEL_NORMAL;

+ (void)setLogLevel:(NSUInteger)value {
	kGBLogLevel = value;
}

+ (void)setLogLevelFromVerbose:(NSString *)verbosity {
	NSInteger value = [verbosity integerValue];
	if (value < 0) value = 0;
	if (value > 6) value = 6;
	switch (value) {
		case 0:
			[self setLogLevel:LOG_LEVEL_FATAL];
			break;
		case 1:
			[self setLogLevel:LOG_LEVEL_ERROR];
			break;
		case 2:
			[self setLogLevel:LOG_LEVEL_WARN];
			break;
		case 3:
			[self setLogLevel:LOG_LEVEL_NORMAL];
			break;
		case 4:
			[self setLogLevel:LOG_LEVEL_INFO];
			break;
		case 5:
			[self setLogLevel:LOG_LEVEL_VERBOSE];
			break;
		default:
			[self setLogLevel:LOG_LEVEL_DEBUG];
			break;
	}
}

@end

#pragma mark Log formatting handling

static NSString *GBLogLevel(DDLogMessage *msg) {
	switch (msg->logFlag) {
		case LOG_FLAG_FATAL:	return @"FATAL";
		case LOG_FLAG_ERROR:	return @"ERROR";
		case LOG_FLAG_WARN:		return @"WARN";
		case LOG_FLAG_NORMAL:	return @"NORMAL";
		case LOG_FLAG_INFO:		return @"INFO";
		case LOG_FLAG_VERBOSE:	return @"VERBOSE";
		case LOG_FLAG_DEBUG:	return @"DEBUG";
	}
	return @"UNKNOWN";
}

#define GBLogFile(msg) [msg fileName]
#define GBLogFileExt(msg) [msg fileNameExt]
#define GBLogMessage(msg) msg->logMsg
#define GBLogFunction(msg) msg->function
#define GBLogSource(msg) msg->object ? [msg->object className] : GBLogFile(msg)
#define GBLogLine(msg) msg->lineNumber

@implementation GBStandardLogFormatter

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {
	return [NSString stringWithFormat:@"-%@- %@ %@", GBLogSource(logMessage), GBLogLevel(logMessage), GBLogMessage(logMessage)];
}

@end

@implementation GBDebugLogFormatter

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {
	return [NSString stringWithFormat:@"%@ %@  [%@ %s] @ %@:%i", GBLogLevel(logMessage), GBLogMessage(logMessage), GBLogSource(logMessage), GBLogFunction(logMessage), GBLogFileExt(logMessage), GBLogLine(logMessage)];
}

@end
