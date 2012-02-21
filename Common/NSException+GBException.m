//
//  NSException+GBException.m
//  appledoc
//
//  Created by Tomaz Kragelj on 23.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "NSException+GBException.h"

@interface NSException (GBExceptionPrivate)

+ (NSString *)reasonWithError:(NSString *)name message:(NSString *)message;

@end

#pragma mark -

@implementation NSException (GBException)

+ (void)raise:(NSString *)format, ... {
	va_list args;
	va_start(args, format);
	[self raise:@"AppledocException" format:format arguments:args];
	va_end(args);
}

+ (void)raise:(NSString *)name format:(NSString *)format, ... {
	NSString *message = nil;
	if (format) {
		va_list args;
		va_start(args, format);
		message = [[[NSString alloc] initWithFormat:format arguments:args] autorelease];
		va_end(args);
	}
	
	NSString *reason = [self reasonWithError:name message:message];
	[self raise:reason];
}

+ (NSString *)reasonWithError:(NSString *)name message:(NSString *)message {
	NSMutableString *result = [NSMutableString string];
	if (message) [result appendFormat:@"%@\n", message];
	[result appendFormat:@"Error: %@\n", name];
	return result;
}

@end
