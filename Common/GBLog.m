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
		case 6:
			[self setLogLevel:LOG_LEVEL_DEBUG];
			break;
	}
}

+ (id<DDLogFormatter>)logFormatterForLogFormat:(NSString *)level {
	NSInteger value = [level integerValue];
	if (value < 0) value = 0;
	if (value > 4) value = 4;
	switch (value) {
		case 0: return [[[GBLogFormat0Formatter alloc] init] autorelease];
		case 1: return [[[GBLogFormat1Formatter alloc] init] autorelease];
		case 2: return [[[GBLogFormat2Formatter alloc] init] autorelease];
		case 3: return [[[GBLogFormat3Formatter alloc] init] autorelease];
		case 4: return [[[GBLogFormat4Formatter alloc] init] autorelease];
	}
	return nil;
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

@implementation GBLogFormat0Formatter
- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {
	return GBLogMessage(logMessage);
}
@end

@implementation GBLogFormat1Formatter
- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {
	return [NSString stringWithFormat:@"%@ | %@", GBLogSource(logMessage), GBLogMessage(logMessage)];
}
@end

@implementation GBLogFormat2Formatter
- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {
	return [NSString stringWithFormat:@"%@ | %@ @ %@:%i", GBLogSource(logMessage), GBLogMessage(logMessage), GBLogFileExt(logMessage), GBLogLine(logMessage)];
}
@end

@implementation GBLogFormat3Formatter
- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {
	return [NSString stringWithFormat:@"[%@ %s] | %@", GBLogSource(logMessage), GBLogFunction(logMessage), GBLogMessage(logMessage)];
}
@end

@implementation GBLogFormat4Formatter
- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {
	return [NSString stringWithFormat:@"[%@ %s] | %@ @ %@:%i", GBLogSource(logMessage), GBLogFunction(logMessage), GBLogMessage(logMessage), GBLogFileExt(logMessage), GBLogLine(logMessage)];
}
@end
