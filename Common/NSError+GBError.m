//
//  NSError+GBError.m
//  appledoc
//
//  Created by Tomaz Kragelj on 29.11.10.
//  Copyright 2010 Gentle Bytes. All rights reserved.
//

#import "NSError+GBError.h"

@implementation NSError (GBError)

+ (NSError *)errorWithCode:(NSInteger)code description:(NSString *)description reason:(NSString *)reason {
	NSMutableDictionary *info = nil;
	if ([description length] > 0 || [reason length] > 0) {
		info = [NSMutableDictionary dictionaryWithCapacity:2];
		if ([description length] > 0) info[NSLocalizedDescriptionKey] = description;
		if ([reason length] > 0) info[NSLocalizedFailureReasonErrorKey] = reason;
	}
	return [self errorWithDomain:@"appledoc" code:code userInfo:info];
}

@end
