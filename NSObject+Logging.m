//
//  NSObject+Logging.m
//  objcdoc
//
//  Created by Tomaz Kragelj on 12.4.09.
//  Copyright 2009 Tomaz Kragelj. All rights reserved.
//

#import "NSObject+Logging.h"
#import "LoggingProvider.h"
#import "CommandLineParser.h"

@implementation NSObject (Logging)

//----------------------------------------------------------------------------------------
- (id<LoggingProvider>) logger
{
	// We use our shared Logger as the default logger.
	return [Logger sharedInstance];
}

@end
