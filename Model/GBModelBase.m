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
	}
	return self;
}

#pragma mark Merging handling

- (void)mergeDataFromObject:(id)source {
	NSParameterAssert([source isKindOfClass:[self class]]);
	[_declaredFiles unionSet:[source declaredFiles]];
	GBComment *comment = [(GBModelBase *)source comment];
	if (self.comment && comment) {
		GBLogWarn(@"%@: Comment string found in definition and declaration!", self);
		return;
	}
	if (!self.comment && comment) _comment = [comment retain];
}

#pragma mark Declared files handling

- (void)registerDeclaredFile:(NSString *)filename {
	NSParameterAssert(filename != nil && [filename length] > 0);
	if ([_declaredFiles member:filename]) return;
	[_declaredFiles addObject:filename];
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
