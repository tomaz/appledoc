//
//  NSError+Appledoc.m
//  appledoc
//
//  Created by Tomaz Kragelj on 1.11.12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "NSError+Appledoc.h"

@implementation NSError (GBError)

+ (NSError *)gb_errorWithCode:(NSInteger)code description:(NSString *)description reason:(NSString *)reason {
	NSMutableDictionary *info = nil;
	if ([description length] > 0 || [reason length] > 0) {
		info = [NSMutableDictionary dictionaryWithCapacity:2];
		if ([description length] > 0) info[NSLocalizedDescriptionKey] = description;
		if ([reason length] > 0) info[NSLocalizedFailureReasonErrorKey] = reason;
	}
	return [self errorWithDomain:@"appledoc" code:code userInfo:info];
}

@end
