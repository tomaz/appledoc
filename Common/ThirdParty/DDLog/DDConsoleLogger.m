#import "DDCliUtil.h"
#import "DDConsoleLogger.h"


@implementation DDConsoleLogger

static DDConsoleLogger *sharedInstance;

/**
 * The runtime sends initialize to each class in a program exactly one time just before the class,
 * or any class that inherits from it, is sent its first message from within the program. (Thus the
 * method may never be invoked if the class is not used.) The runtime sends the initialize message to
 * classes in a thread-safe manner. Superclasses receive this message before their subclasses.
 *
 * This method may also be called directly (assumably by accident), hence the safety mechanism.
 **/
+ (void)initialize
{
	static BOOL initialized = NO;
	if (!initialized)
	{
		initialized = YES;
		sharedInstance = [[DDConsoleLogger alloc] init];
	}
}

+ (DDConsoleLogger *)sharedInstance
{
	return sharedInstance;
}

- (id)init
{
	if (sharedInstance != nil)
	{
		[self release];
		return nil;
	}
	
	self = [super init];
	return self;
}

- (void)logMessage:(DDLogMessage *)logMessage
{
	NSString *logMsg = logMessage->logMsg;
	
	if (formatter)
	{
		logMsg = [formatter formatLogMessage:logMessage];
	}
	
	if (logMsg)
	{
		ddprintf(@"%@\n", logMsg);
	}
}

- (id <DDLogFormatter>)logFormatter
{
	return formatter;
}

- (void)setLogFormatter:(id <DDLogFormatter>)logFormatter
{
	if (formatter != logFormatter)
	{
		[formatter release];
		formatter = [logFormatter retain];
	}
}

- (NSString *)loggerName
{
	return @"cocoa.lumberjack.consoleLogger";
}

@end
