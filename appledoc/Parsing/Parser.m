//
//  Parser.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/19/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "Store.h"
#import "Parser.h"

typedef void(^ParserPathBlock)(NSString *path);

#pragma mark - 

@interface Parser ()
- (void)parsePath:(NSString *)path withBlock:(ParserPathBlock)handler;
- (void)parseDirectory:(NSString *)path withBlock:(ParserPathBlock)handler;
- (void)parseFile:(NSString *)path withBlock:(ParserPathBlock)handler;
- (BOOL)isPathIgnored:(NSString *)path;
- (BOOL)isFileIgnored:(NSString *)filename;
- (BOOL)isDirectoryIgnored:(NSString *)filename;
- (BOOL)isSourceCodeFile:(NSString *)path;
@end

#pragma mark -

@implementation Parser

#pragma mark - Task invocation

- (NSInteger)runTask {
	LogParNormal(@"Starting parsing...");
	[self.settings.arguments enumerateObjectsUsingBlock:^(NSString *path, NSUInteger idx, BOOL *stop) {
		[self parsePath:path withBlock:^(NSString *path) {
			//LogParDebug(@"Parsing contents of file '%@'...", path);
		}];
	}];
	LogParInfo(@"Parsing finished.");
	return 0;
}

#pragma mark - Parsing helpers

- (void)parsePath:(NSString *)path withBlock:(ParserPathBlock)handler {
	LogParInfo(@"Parsing '%@'...", path);
	NSString *standardized = [path gb_stringByStandardizingCurrentDirAndPath];
	
	if (![self.fileManager fileExistsAtPath:standardized]) {
		LogParWarn(@"'%@' doesn't exist, skipping!", path);
		return;
	}
	
	if ([self.fileManager gb_fileExistsAndIsDirectoryAtPath:standardized])
		[self parseDirectory:standardized withBlock:handler];
	else
		[self parseFile:standardized withBlock:handler];
}

- (void)parseDirectory:(NSString *)path withBlock:(ParserPathBlock)handler {
	if ([self isPathIgnored:path]) {
		LogParNormal(@"Path '%@' ignored, skipping...", path);
		return;
	}	
	LogParVerbose(@"Parsing directory '%@'...", path);

	// Get contents of the directory.
	NSError *error = nil;
	NSArray *contents = [self.fileManager subpathsOfDirectoryAtPath:path error:&error];
	if (error) {
		LogParNSError(error, @"Failed fetching contents of '%@'!", path);
		return;
	}
	
	// First files...
	[contents enumerateObjectsUsingBlock:^(NSString *subpath, NSUInteger idx, BOOL *stop) {
		NSString *fullPath = [path stringByAppendingPathComponent:subpath];
		if (![self.fileManager gb_fileExistsAndIsFileAtPath:fullPath]) return;
		if ([self isFileIgnored:subpath]) return;
		[self parseFile:fullPath withBlock:handler];
	}];
	
	// ...then directories.
	[contents enumerateObjectsUsingBlock:^(NSString *subpath, NSUInteger idx, BOOL *stop) {
		NSString *fullPath = [path stringByAppendingPathComponent:subpath];
		if (![self.fileManager gb_fileExistsAndIsDirectoryAtPath:fullPath]) return;
		if ([self isDirectoryIgnored:subpath]) return;
		[self parseDirectory:fullPath withBlock:handler];
	}];
}

- (void)parseFile:(NSString *)path withBlock:(ParserPathBlock)handler {
	if ([self isPathIgnored:path]) {
		LogParNormal(@"Path '%@' ignored, skipping...", path);
		return;
	}
	LogParVerbose(@"Parsing file '%@'...", path);
	handler(path);
}

#pragma mark - Helper methods

- (BOOL)isPathIgnored:(NSString *)path {
//	for (NSString *ignored in self.settings.ignoredPaths) {
//		if ([path hasSuffix:ignored]) return YES;
//	}
	return NO;
}

- (BOOL)isFileIgnored:(NSString *)filename {
	if ([filename isEqualToString:@".DS_Store"]) return YES;
	return NO;
}

- (BOOL)isDirectoryIgnored:(NSString *)filename {
	if ([filename isEqualToString:@".git"]) return YES;
	if ([filename isEqualToString:@".svn"]) return YES;
	if ([filename isEqualToString:@".hg"]) return YES;
	return NO;
}

- (BOOL)isSourceCodeFile:(NSString *)path {
	NSString *extension = [path pathExtension];
	if ([extension isEqualToString:@"h"]) return YES;
	if ([extension isEqualToString:@"hh"]) return YES;
	if ([extension isEqualToString:@"m"]) return YES;
	if ([extension isEqualToString:@"mm"]) return YES;
	return NO;
}

@end
