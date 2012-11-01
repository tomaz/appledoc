//
//  NSFileManager+Appledoc.m
//  appledoc
//
//  Created by Tomaz Kragelj on 1.11.12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "NSFileManager+Appledoc.h"

@implementation NSFileManager (Appledoc)

- (BOOL)gb_fileExistsAndIsFileAtPath:(NSString *)path {
	BOOL isDirectory = NO;
	BOOL exists = [self fileExistsAtPath:path isDirectory:&isDirectory];
	return (exists && !isDirectory);
}

- (BOOL)gb_fileExistsAndIsDirectoryAtPath:(NSString *)path {
	BOOL isDirectory = NO;
	BOOL exists = [self fileExistsAtPath:path isDirectory:&isDirectory];
	return (exists && isDirectory);
}

@end
