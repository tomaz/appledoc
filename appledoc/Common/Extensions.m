//
//  Extensions.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/17/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import <objc/runtime.h>
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

#pragma mark - 

static const void *GBLocationKey = @"GBLocation";

@implementation PKToken (Appledoc)

- (BOOL)matches:(id)expected {
	NSUInteger result = [self matchResult:expected];
	return (result != NSNotFound);
}

- (NSUInteger)matchResult:(id)expected {
	// If expected is an array, allow if any of the objects matches. Otherwise we require exact match.
	if ([expected isKindOfClass:[NSArray class]]) {
		__block NSUInteger result = NSNotFound;
		[expected enumerateObjectsUsingBlock:^(NSString *expectedToken, NSUInteger idx, BOOL *stop) {
			if ([self.stringValue isEqual:expectedToken]) {
				result = idx;
				*stop = YES;
				return;
			}
		}];
		return result;
	} else {
		if ([self.stringValue isEqual:expected]) return 0;
	}
	return NSNotFound;
}

- (NSPoint)location {
	NSValue *storage = objc_getAssociatedObject(self, GBLocationKey);
	return [storage pointValue];
}
- (void)setLocation:(NSPoint)val {
	NSValue *storage = [NSValue valueWithPoint:val];
	objc_setAssociatedObject(self, GBLocationKey, storage, OBJC_ASSOCIATION_RETAIN);
}

@end