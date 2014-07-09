//
//  GBClassData.m
//  appledoc
//
//  Created by Tomaz Kragelj on 25.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBDataObjects.h"
#import "GBClassData.h"

@implementation GBClassData

#pragma mark Initialization & disposal

+ (id)classDataWithName:(NSString *)name {
	return [[self alloc] initWithName:name];
}

- (id)initWithName:(NSString *)name {
	NSParameterAssert(name != nil && [name length] > 0);
	GBLogDebug(@"Initializing class with name %@...", name);
	self = [super init];
	if (self) {
		_className = [name copy];
		_adoptedProtocols = [[GBAdoptedProtocolsProvider alloc] initWithParentObject:self];
		_ivars = [[GBIvarsProvider alloc] initWithParentObject:self];
		_methods = [[GBMethodsProvider alloc] initWithParentObject:self];
	}
	return self;
}

#pragma mark Overriden methods

- (void)mergeDataFromObject:(id)source {
	if (!source || source == self) return;
	GBLogDebug(@"%@: Merging data from %@...", self, source);
	NSParameterAssert([[source nameOfClass] isEqualToString:self.nameOfClass]);
	[super mergeDataFromObject:source];
	
	GBClassData *sourceClass = (GBClassData *)source;
	
	// Merge superclass data.
	if (![self nameOfSuperclass]) {
		self.nameOfSuperclass = sourceClass.nameOfSuperclass;
	} else if (sourceClass.nameOfSuperclass && ![self.nameOfSuperclass isEqualToString:sourceClass.nameOfSuperclass]) {
		GBLogXWarn(self.prefferedSourceInfo, @"%@: Merged class's %@ superclass is different from current!", self, sourceClass);
	}
	
	// Forward merging request to components.
	[self.adoptedProtocols mergeDataFromProtocolsProvider:sourceClass.adoptedProtocols];
	[self.ivars mergeDataFromIvarsProvider:sourceClass.ivars];
	[self.methods mergeDataFromMethodsProvider:sourceClass.methods];
}

- (NSString *)description {
	return self.nameOfClass;
}

- (NSString *)debugDescription {
	return [NSString stringWithFormat:@"class %@ %@\n%@", self.nameOfClass, self.adoptedProtocols.debugDescription, self.methods.debugDescription];
}

- (BOOL)isTopLevelObject {
	return YES;
}

#pragma mark Properties

@synthesize nameOfClass = _className;
@synthesize nameOfSuperclass;
@synthesize superclass;
@synthesize adoptedProtocols = _adoptedProtocols;
@synthesize ivars = _ivars;
@synthesize methods = _methods;

@end
