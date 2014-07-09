//
//  GBParser.m
//  appledoc
//
//  Created by Tomaz Kragelj on 23.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBStore.h"
#import "GBDataObjects.h"
#import "GBApplicationSettingsProvider.h"
#import "GBObjectiveCParser.h"
#import "GBParser.h"

@interface GBParser ()

- (void)parsePath:(NSString *)input usingBlock:(void (^)(NSString *path))block;
- (void)parseDirectory:(NSString *)input usingBlock:(void (^)(NSString *path))block;
- (void)parseFile:(NSString *)input usingBlock:(void (^)(NSString *path))block;
- (BOOL)isPathIgnored:(NSString *)path;
- (BOOL)isFileIgnored:(NSString *)filename;
- (BOOL)isDirectoryIgnored:(NSString *)filename;
- (BOOL)isSourceCodeFile:(NSString *)path;
- (BOOL)isDocumentFile:(NSString *)path;
@property (assign) NSUInteger numberOfParsedFiles;
@property (assign) NSUInteger numberOfParsedDocuments;
@property (strong) GBObjectiveCParser *objectiveCParser;
@property (strong) GBStore *store;
@property (strong) GBApplicationSettingsProvider *settings;

@end

#pragma mark -

@implementation GBParser

#pragma mark Initialization & disposal

+ (id)parserWithSettingsProvider:(id)settingsProvider {
	return [[self alloc] initWithSettingsProvider:settingsProvider];
}

- (id)initWithSettingsProvider:(id)settingsProvider {
	NSParameterAssert(settingsProvider != nil);
	GBLogDebug(@"Initializing parser with settings provider %@...", settingsProvider);
	self = [super init];
	if (self) {
		self.settings = settingsProvider;
		self.objectiveCParser = [GBObjectiveCParser parserWithSettingsProvider:self.settings];
	}
	return self;
}

#pragma mark File system parsing handling

- (void)parseObjectsFromPaths:(NSArray *)paths toStore:(id)aStore {
	NSParameterAssert(paths != nil);
	NSParameterAssert(aStore != nil);
	GBLogVerbose(@"Parsing objects from %lu paths...", [paths count]);
	self.store = aStore;
	self.numberOfParsedFiles = 0;
	for (NSString *input in paths) {
		[self parsePath:input usingBlock:^(NSString *path) {
			if (![self isSourceCodeFile:path]) return;	
			
			GBLogInfo(@"Parsing source code from '%@'...", path);
			NSError *error = nil;
			NSString *contents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
			if (error) {
				GBLogNSError(error, @"Failed reading contents of source file '%@'!", path);
				return;
			}
			
			[self.objectiveCParser parseObjectsFromString:contents sourceFile:path toStore:self.store];
			self.numberOfParsedFiles++;
		}];
	}
	GBLogVerbose(@"Parsed %lu source files.", self.numberOfParsedFiles);
}

- (void)parseDocumentsFromPaths:(NSArray *)paths toStore:(id)aStore {
	NSParameterAssert(paths != nil);
	NSParameterAssert(aStore != nil);
	GBLogVerbose(@"Parsing static documents from %lu paths...", (unsigned long) [paths count]);
	self.store = aStore;
	self.numberOfParsedDocuments = 0;
	for (NSString *input in paths) {
		[self parsePath:input usingBlock:^(NSString *path) {
			if (![self isDocumentFile:path]) return;
			
			GBLogInfo(@"Parsing static document from '%@'...", path);
			NSError *error = nil;
			NSString *contents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
			if (error) {
				GBLogNSError(error, @"Failed reading contents of static document '%@'...", path);
				return;
			}		
			if ([contents length] == 0) GBLogWarn(@"Empty static document found at '%@'!", path);
			
			GBDocumentData *document = [GBDocumentData documentDataWithContents:contents path:path];
			document.basePathOfDocument = [input stringByStandardizingPath];
			[self.store registerDocument:document];
			
			self.numberOfParsedDocuments++;
		}];
	}
	GBLogVerbose(@"Parsed %lu static document files.", self.numberOfParsedDocuments);
}

- (void)parseCustomDocumentFromPath:(NSString *)path outputSubpath:(NSString *)subpath key:(id)key toStore:(id)aStore {
	if (!path || [path length] == 0) return;
	NSParameterAssert(key != nil);
	NSParameterAssert(aStore != nil);
	self.store = aStore;
	GBLogInfo(@"Parsing custom document from '%@'...", path);

	NSError *error = nil;
	NSString *contents = [NSString stringWithContentsOfFile:[path stringByStandardizingPath] encoding:NSUTF8StringEncoding error:&error];
	if (error) {
		GBLogNSError(error, @"Failed reading contents of custom document '%@'...", path);
		return;
	}		
	if ([contents length] == 0) {
		GBLogWarn(@"Empty custom document found at '%@'!", path);
		return;
	}
	
	GBDocumentData *document = [GBDocumentData documentDataWithContents:contents path:path];
	document.isCustomDocument = YES;
	document.basePathOfDocument = subpath;
	[self.store registerCustomDocument:document withKey:key];
}

#pragma mark Parsing helpers

- (void)parsePath:(NSString *)input usingBlock:(void (^)(NSString *path))block {
	GBLogDebug(@"Parsing '%@'...", input);
	NSString *standardized = [input stringByStandardizingPath];
	if ([self.fileManager isPathDirectory:[standardized stringByStandardizingPath]])
		[self parseDirectory:standardized usingBlock:block];
	else
		[self parseFile:standardized usingBlock:block];
}

- (void)parseDirectory:(NSString *)input usingBlock:(void (^)(NSString *path))block {
	GBLogDebug(@"Parsing path '%@'...", input);
	
	// Skip directory if found in --ignore paths.
	if ([self isPathIgnored:input]) {
		GBLogNormal(@"Ignoring path '%@'...", input);
		return;
	}

	// Enumerate directory contents (non-recursive).
	NSError *error = nil;
	NSArray *contents = [self.fileManager contentsOfDirectoryAtPath:input error:&error];
	if (error) {
		GBLogNSError(error, @"Failed fetching contents of '%@'!", input);
		return;
	}
	
	// First process files. Skip system files such as .DS_Store and similar.
	for (NSString *subpath in contents) {
		NSString *fullPath = [input stringByAppendingPathComponent:subpath];
		if ([self.fileManager isPathDirectory:fullPath]) continue;
		if ([self isFileIgnored:subpath]) continue;
		[self parseFile:fullPath usingBlock:block];
	}
	
	// Now process all subdirectories. Skip directories such as .git, .svn, .hg and similar.
	for (NSString *subpath in contents) {
		NSString *fullPath = [input stringByAppendingPathComponent:subpath];
		if (![self.fileManager isPathDirectory:fullPath]) continue;
		if ([self isDirectoryIgnored:subpath]) continue;
		[self parseDirectory:fullPath usingBlock:block];
	}
}

- (void)parseFile:(NSString *)input usingBlock:(void (^)(NSString *path))block {
	GBLogDebug(@"Parsing file '%@'...", input);

	// Skip file if found in --ignore paths.
	if ([self isPathIgnored:input]) {
		GBLogNormal(@"Ignoring file '%@'...", input);
		return;
	}
	
	// Pass the path to the client via the block.
	block(input);
}

#pragma mark Helper methods

- (BOOL)isPathIgnored:(NSString *)path {
	for (NSString *ignored in self.settings.ignoredPaths) {
		if ([path hasSuffix:ignored]) return YES;
	}
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

- (BOOL)isDocumentFile:(NSString *)path {
	return [self.settings isPathRepresentingTemplateFile:path];
}

#pragma mark Properties

@synthesize numberOfParsedFiles;
@synthesize numberOfParsedDocuments;
@synthesize objectiveCParser;
@synthesize settings;
@synthesize store;

@end
