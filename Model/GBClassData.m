//
//  GBClassData.m
//  appledoc
//
//  Created by Tomaz Kragelj on 25.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBClassData.h"

@implementation GBClassData

#pragma mark Initialization & disposal

+ (id)classDataWithName:(NSString *)name {
	return [[[self alloc] initWithName:name] autorelease];
}

- (id)initWithName:(NSString *)name {
	NSParameterAssert(name != nil && [name length] > 0);
	GBLogDebug(@"Initializing class with name %@...", name);
	self = [super init];
	if (self) {
		_className = [name copy];
		_adoptedProtocols = [[GBAdoptedProtocolsProvider alloc] init];
		_ivars = [[GBIvarsProvider alloc] init];
		_methods = [[GBMethodsProvider alloc] init];
	}
	return self;
}

#pragma mark Overriden methods

- (NSString *)description {
	return self.nameOfClass;
}

#pragma mark Properties

@synthesize nameOfClass = _className;
@synthesize nameOfSuperclass;
@synthesize adoptedProtocols = _adoptedProtocols;
@synthesize ivars = _ivars;
@synthesize methods = _methods;

@end
