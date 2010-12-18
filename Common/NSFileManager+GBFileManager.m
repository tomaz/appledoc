//
//  NSFileManager+GBFileManager.m
//  appledoc
//
//  Created by Tomaz Kragelj on 23.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "NSFileManager+GBFileManager.h"

@implementation NSFileManager (GBFileManager)

- (BOOL)isPathDirectory:(NSString *)path {
	BOOL result = NO;
	if ([self fileExistsAtPath:path isDirectory:&result]) return result;
	return NO;
}

@end
