//
//  Extensions.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/17/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Extensions.h"

@implementation NSError (GBError)

+ (NSError *)errorWithCode:(NSInteger)code description:(NSString *)description reason:(NSString *)reason {
	NSMutableDictionary *info = nil;
	if ([description length] > 0 || [reason length] > 0) {
		info = [NSMutableDictionary dictionaryWithCapacity:2];
		if ([description length] > 0) [info setObject:description forKey:NSLocalizedDescriptionKey];
		if ([reason length] > 0) [info setObject:reason forKey:NSLocalizedFailureReasonErrorKey];
	}
	return [self errorWithDomain:@"appledoc" code:code userInfo:info];
}

@end

#pragma mark - 

@implementation NSFileManager (Appledoc)

- (BOOL)fileExistsAndIsDirectoryAtPath:(NSString *)path {
	BOOL isDirectory = NO;
	BOOL exists = [self fileExistsAtPath:path isDirectory:&isDirectory];
	return (exists && isDirectory);
}
	
@end