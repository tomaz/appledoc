//
//  Parser.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/19/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "Store.h"
#import "ObjectiveCParser.h"
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

@synthesize objectiveCParser = _objectiveCParser;

#pragma mark - Task invocation

- (NSInteger)runTask {
	LogParNormal(@"Starting parsing...");
	__weak Parser *blockSelf = self;
	__block NSInteger result = 0;
	[self.settings.arguments enumerateObjectsUsingBlock:^(NSString *path, NSUInteger idx, BOOL *stop) {
		[blockSelf parsePath:path withBlock:^(NSString *path) {
			if (![blockSelf isSourceCodeFile:path]) return;
			LogParInfo(@"Parsing source file '%@'...", path);
			NSInteger parseResult = [self.objectiveCParser parseFile:path withSettings:self.settings store:self.store];
			if (parseResult > result) result = parseResult;
		}];
	}];
	LogParInfo(@"Parsing finished.");
	return result;
}

#pragma mark - Parsing helpers

- (void)parsePath:(NSString *)path withBlock:(ParserPathBlock)handler {
	LogParVerbose(@"Parsing '%@'...", path);
	NSString *standardized = [path gb_stringByStandardizingCurrentDirAndPath];
	
	if (![self.fileManager fileExistsAtPath:standardized]) {
		LogParWarn(@"'%@' doesn't exist, skipping!", path);
		return;
	}
	
	if ([self.fileManager gb_fileExistsAndIsDirectoryAtPath:standardized]) {
		[self parseDirectory:standardized withBlock:handler];
		return;
	}
	
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
	NSArray *contents = [self.fileManager contentsOfDirectoryAtPath:path error:&error];
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
	__block BOOL result = NO;
	[self.settings.ignoredPaths enumerateObjectsUsingBlock:^(NSString *ignored, NSUInteger idx, BOOL *stop) {
		if ([path hasSuffix:ignored]) {
			result = YES;
			*stop = YES;
		}
	}];
	return result;
}

- (BOOL)isFileIgnored:(NSString *)filename {
	if ([filename isEqualToString:@".DS_Store"]) return YES;
	return NO;
}

- (BOOL)isDirectoryIgnored:(NSString *)filename {
	if ([filename isEqualToString:@".git"]) return YES;
	if ([filename isEqualToString:@".svn"]) return YES;
	if ([filename isEqualToString:@".hg"]) return YES;
	if ([filename hasSuffix:@".xcodeproj"]) return YES;
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

#pragma mark - Properties

- (ParserTask *)objectiveCParser {
	if (_objectiveCParser) return _objectiveCParser;
	_objectiveCParser = [[ObjectiveCParser alloc] init];
	return _objectiveCParser;
}

@end
