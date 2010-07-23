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

@end
