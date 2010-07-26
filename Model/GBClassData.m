//
//  GBClassData.m
//  appledoc
//
//  Created by Tomaz Kragelj on 25.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBClassData.h"

@interface GBClassData ()

@property (readwrite, copy) NSString *className;
@property (readwrite, copy) NSString *superclassName;

@end

#pragma mark -

@implementation GBClassData

#pragma mark Initialization & disposal

- (id)initWithName:(NSString *)name {
	NSParameterAssert(name != nil && [name length] > 0);
	GBLogDebug(@"Initializing class with name %@...", name);
	self = [super init];
	if (self) {
		self.className = name;
	}
	return self;
}

#pragma mark Overriden methods

- (NSString *)description {
	return self.className;
}

#pragma mark Properties

@synthesize className;
@synthesize superclassName;

@end
