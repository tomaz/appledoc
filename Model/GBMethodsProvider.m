//
//  GBMethodsProvider.m
//  appledoc
//
//  Created by Tomaz Kragelj on 26.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBMethodData.h"
#import "GBMethodsProvider.h"

@implementation GBMethodsProvider

#pragma mark Initialization & disposal

- (id)initWithParentObject:(id)parent {
	NSParameterAssert(parent != nil);
	GBLogDebug(@"Initializing for %@...", parent);
	self = [super init];
	if (self) {
		_parent = [parent retain];
		_methods = [[NSMutableArray alloc] init];
		_methodsBySelectors = [[NSMutableDictionary alloc] init];
	}
	return self;
}

#pragma mark Helper methods

- (void)registerMethod:(GBMethodData *)method {
	NSParameterAssert(method != nil);
	GBLogDebug(@"Registering method %@...", method);
	if ([_methods containsObject:method]) return;
	GBMethodData *existingMethod = [_methodsBySelectors objectForKey:method.methodSelector];
	if (existingMethod) {
		[existingMethod mergeDataFromObject:method];
		return;
	}
	method.parentObject = _parent;
	[_methods addObject:method];
	[_methodsBySelectors setObject:method forKey:method.methodSelector];
}

- (void)mergeDataFromMethodsProvider:(GBMethodsProvider *)source {
	// If a method with the same selector is found while merging from source, we should check if the type also matches. If so, we can
	// merge the data from the source's method. However if the type doesn't match, we should ignore the method alltogether (ussually this
	// is due to custom property implementation). We should probably deal with this scenario more inteligently, but it seems it works...
	if (!source || source == self) return;
	GBLogDebug(@"Merging data from %@...", source);
	for (GBMethodData *sourceMethod in source.methods) {
		GBMethodData *existingMethod = [_methodsBySelectors objectForKey:sourceMethod.methodSelector];
		if (existingMethod) {
			if (existingMethod.methodType == sourceMethod.methodType) [existingMethod mergeDataFromObject:sourceMethod];
			continue;
		}
		[self registerMethod:sourceMethod];
	}
}

#pragma mark Properties

@synthesize methods = _methods;

@end
