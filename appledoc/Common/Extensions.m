//
//  Extensions.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/17/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Extensions.h"

@implementation NSError (GBError)

+ (NSError *)gb_errorWithCode:(NSInteger)code description:(NSString *)description reason:(NSString *)reason {
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

- (BOOL)gb_fileExistsAndIsDirectoryAtPath:(NSString *)path {
	BOOL isDirectory = NO;
	BOOL exists = [self fileExistsAtPath:path isDirectory:&isDirectory];
	return (exists && isDirectory);
}
	
@end

#pragma mark - 

@implementation NSString (Appledoc)

- (NSString *)gb_stringByStandardizingCurrentDir {
	// Converts . to actual working directory.
	if (![self hasPrefix:@"."] || [self hasPrefix:@".."]) return self;
	NSFileManager *manager = [NSFileManager defaultManager];
	NSString *suffix = [self substringFromIndex:1];
	NSString *currentDir = [manager currentDirectoryPath];
	return [currentDir stringByAppendingPathComponent:suffix];
}

- (NSString *)gb_stringByStandardizingCurrentDirAndPath {
	NSString *result = [self gb_stringByStandardizingCurrentDir];
	result = [result stringByStandardizingPath];
	return result;
}

@end
