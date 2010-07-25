//
//  NSException+GBException.m
//  appledoc
//
//  Created by Tomaz Kragelj on 23.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "NSException+GBException.h"

@implementation NSException (GBException)

+ (void)raise:(NSString *)format, ... {
	va_list args;
	va_start(args, format);
	[self raise:@"AppledocException" format:format arguments:args];
	va_end(args);
}

+ (void)raise:(NSError *)error format:(NSString *)format, ... {
	NSString *message = nil;
	if (format) {
		va_list args;
		va_start(args, format);
		message = [[[NSString alloc] initWithFormat:format arguments:args] autorelease];
		va_end(args);
	}
	
	NSInteger code = [error code];
	NSString *domain = [error domain];
	NSString *description = [error localizedDescription];
	NSString *reason = [error localizedFailureReason];
	
	NSMutableString *output = [NSMutableString string];
	if (message) [output appendFormat:@"%@\n", message];
	[output appendFormat:@"Error: %@, code %i: %@\n", domain, code, description];
	if (reason) [output appendFormat:@"Reason: %@", reason];
	
	[self raise:output];
}

@end
