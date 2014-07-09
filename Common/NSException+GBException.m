//
//  NSException+GBException.m
//  appledoc
//
//  Created by Tomaz Kragelj on 23.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "NSException+GBException.h"

@interface NSException (GBExceptionPrivate)

+ (NSString *)reasonWithError:(NSError *)error message:(NSString *)message;

@end

#pragma mark -

@implementation NSException (GBException)

+ (void)raise:(NSString *)format, ... {
	va_list args;
	va_start(args, format);
	[self raise:@"AppledocException" format:format arguments:args];
	va_end(args);
}

+ (void)raiseWithError:(NSError *)error format:(NSString *)format, ... {
	NSString *message = nil;
	if (format) {
		va_list args;
		va_start(args, format);
		message = [[NSString alloc] initWithFormat:format arguments:args];
		va_end(args);
	}
	
	NSString *reason = [self reasonWithError:error message:message];
	[self raise:reason];
}

+ (NSString *)reasonWithError:(NSError *)error message:(NSString *)message {
	NSInteger code = [error code];
	NSString *domain = [error domain];
	NSString *description = [error localizedDescription];
	NSString *reason = [error localizedFailureReason];
	
	NSMutableString *result = [NSMutableString string];
	if (message) [result appendFormat:@"%@\n", message];
	[result appendFormat:@"Error: %@, code %li: %@\n", domain, code, description];
	if (reason) [result appendFormat:@"Reason: %@", reason];
	return result;
}

@end
