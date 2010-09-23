//
//  GBModelBase.m
//  appledoc
//
//  Created by Tomaz Kragelj on 28.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBComment.h"
#import "GBModelBase.h"

@implementation GBModelBase

#pragma mark Initialization & disposal

- (id)init {
	self = [super init];
	if (self) {
		_declaredFiles = [[NSMutableSet alloc] init];
		_declaredFilesByFilenames = [[NSMutableDictionary alloc] init];
	}
	return self;
}

#pragma mark Merging handling

- (void)mergeDataFromObject:(id)source {
	NSParameterAssert([source isKindOfClass:[self class]]);
	
	// Merge declared files.
	NSArray *sourceFiles = [[source declaredFiles] allObjects];
	for (GBDeclaredFileData *filedata in sourceFiles) {
		GBDeclaredFileData *ourfiledata = [_declaredFilesByFilenames objectForKey:filedata.filename];
		if (ourfiledata) {
			if (ourfiledata.lineNumber < filedata.lineNumber) {
				[_declaredFilesByFilenames setObject:filedata forKey:filedata.filename];
				[_declaredFiles removeObject:ourfiledata];
				[_declaredFiles addObject:filedata];
			}
			continue;
		}
		[_declaredFilesByFilenames setObject:filedata forKey:filedata.filename];
		[_declaredFiles addObject:filedata];
	}
	
	// Merge comment.
	GBComment *comment = [(GBModelBase *)source comment];
	if (self.comment && comment) {
		GBLogWarn(@"%@: Comment string found in definition and declaration!", self);
		return;
	}
	if (!self.comment && comment) _comment = [comment retain];
}

#pragma mark Declared files handling

- (void)registerDeclaredFile:(GBDeclaredFileData *)data {
	NSParameterAssert(data != nil);
	
	// Ignore already registered objects.
	if ([_declaredFiles member:data]) return;
	
	// Replace data with same filename.
	GBDeclaredFileData *existing = [_declaredFilesByFilenames objectForKey:data.filename];
	if (existing) [_declaredFiles removeObject:existing];
	
	// Add object.
	[_declaredFilesByFilenames setObject:data forKey:data.filename];
	[_declaredFiles addObject:data];
}

- (NSArray *)declaredFilesSortedByName {
	return [[self.declaredFiles allObjects] sortedArrayUsingSelector:@selector(compare:)];
}

#pragma mark Comments handling

- (void)registerCommentString:(NSString *)value {
	if (value) {
		if (!_comment) _comment = [[GBComment alloc] init];
		[self.comment setStringValue:value];
	}
	else if (_comment) {
		[_comment release], _comment = nil;
	}
}

#pragma mark Properties

@synthesize comment = _comment;
@synthesize declaredFiles = _declaredFiles;
@synthesize parentObject;

@end
