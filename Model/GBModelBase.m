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

#pragma mark Declared files handling

- (void)registerDeclaredFile:(NSString *)filename {
	NSParameterAssert(filename != nil && [filename length] > 0);
	if ([_declaredFiles member:filename]) return;
	[_declaredFiles addObject:filename];
}

- (void)mergeDataFromObject:(id)source {
	NSParameterAssert([source isKindOfClass:[self class]]);
	GBLogDebug(@"Merging data from %@...", source);
	[_declaredFiles unionSet:[source declaredFiles]];
}

- (NSArray *)declaredFilesSortedByName {
	return [[self.declaredFiles allObjects] sortedArrayUsingSelector:@selector(compare:)];
}

@synthesize declaredFiles = _declaredFiles;

@end
