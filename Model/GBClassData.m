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

#pragma mark Helper methods

- (void)mergeDataFromClass:(GBClassData *)source {
	if (!source || source == self) return;
	NSParameterAssert([source.nameOfClass isEqualToString:self.nameOfClass]);
	GBLogDebug(@"Merging data from %@...", source);
	
	// Merge superclass data.
	if (!self.nameOfSuperclass) {
		self.nameOfSuperclass = source.nameOfSuperclass;
	} else if (![self.nameOfSuperclass isEqualToString:source.nameOfSuperclass]) {
		GBLogWarn(@"Merged class's superclass %@ is different from ours %@!", source.nameOfSuperclass, self.nameOfSuperclass);
	}
	
	// Forward merging request to components.
	[self.adoptedProtocols mergeDataFromProtocolsProvider:source.adoptedProtocols];
	[self.ivars mergeDataFromIvarsProvider:source.ivars];
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
