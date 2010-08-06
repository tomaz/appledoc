//
//  GBModelBase.m
//  appledoc
//
//  Created by Tomaz Kragelj on 28.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

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
	GBLogDebug(@"Merging data from %@...", source);
	[_declaredFiles unionSet:[source declaredFiles]];
	NSString *comment = [source commentString];
	if (self.commentString && comment) {
		GBLogWarn(@"Comment string for %@ found in definition and declaration!", self);
		return;
	}
	if (!self.commentString && comment) [self registerCommentString:comment];
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
	_commentString = [value copy];
}

#pragma mark Properties

@synthesize declaredFiles = _declaredFiles;
@synthesize commentString = _commentString;

@end
