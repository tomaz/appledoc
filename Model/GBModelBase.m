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
		_sourceInfos = [[NSMutableSet alloc] init];
		_sourceInfosByFilenames = [[NSMutableDictionary alloc] init];
	}
	return self;
}

#pragma mark Merging handling

- (void)mergeDataFromObject:(id)source {
	NSParameterAssert([source isKindOfClass:[self class]]);
	
	// Merge declared files.
	NSArray *sourceFiles = [[source sourceInfos] allObjects];
	for (GBSourceInfo *filedata in sourceFiles) {
		GBSourceInfo *ourfiledata = [_sourceInfosByFilenames objectForKey:filedata.filename];
		if (ourfiledata) {
			if (ourfiledata.lineNumber < filedata.lineNumber) {
				[_sourceInfosByFilenames setObject:filedata forKey:filedata.filename];
				[_sourceInfos removeObject:ourfiledata];
				[_sourceInfos addObject:filedata];
			}
			continue;
		}
		[_sourceInfosByFilenames setObject:filedata forKey:filedata.filename];
		[_sourceInfos addObject:filedata];
	}
	
	// Merge comment.
	GBComment *comment = [(GBModelBase *)source comment];
	if (self.comment && comment) {
		GBLogWarn(@"%@: Comment string found in definition and declaration!", self);
		return;
	}
	if (!self.comment && comment) self.comment = comment;
}

#pragma mark Declared files handling

- (void)registerSourceInfo:(GBSourceInfo *)data {
	NSParameterAssert(data != nil);
	
	// Ignore already registered objects.
	if ([_sourceInfos member:data]) return;
	
	// Replace data with same filename.
	GBSourceInfo *existing = [_sourceInfosByFilenames objectForKey:data.filename];
	if (existing) [_sourceInfos removeObject:existing];
	
	// Add object.
	[_sourceInfosByFilenames setObject:data forKey:data.filename];
	[_sourceInfos addObject:data];
}

- (NSArray *)sourceInfosSortedByName {
	return [[self.sourceInfos allObjects] sortedArrayUsingSelector:@selector(compare:)];
}

#pragma mark Properties

@synthesize comment;
@synthesize sourceInfos = _sourceInfos;
@synthesize parentObject;

@end
