//
//  GBLog.m
//  appledoc
//
//  Created by Tomaz Kragelj on 22.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBLog.h"

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

@implementation GBSimpleLogFormatter

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {
	return [NSString stringWithFormat:@"-%@- %@ %@", GBLogSource(logMessage), GBLogLevel(logMessage), GBLogMessage(logMessage)];
}

@end

@implementation GBFullLogFormatter

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {
	return [NSString stringWithFormat:@"%@ %@  [%@ %s] @ %@:%i", GBLogLevel(logMessage), GBLogMessage(logMessage), GBLogSource(logMessage), GBLogFunction(logMessage), GBLogFileExt(logMessage), GBLogLine(logMessage)];
}

@end
