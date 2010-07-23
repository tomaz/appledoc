#import <Foundation/Foundation.h>

#import "DDLog.h"

@interface DDConsoleLogger : NSObject <DDLogger>
{
	NSDateFormatter *dateFormatter;
	id <DDLogFormatter> formatter;
}

+ (DDConsoleLogger *)sharedInstance;

@end
