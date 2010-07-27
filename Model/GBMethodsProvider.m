//
//  GBMethodsProvider.m
//  appledoc
//
//  Created by Tomaz Kragelj on 26.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBMethodsProvider.h"

@implementation GBMethodsProvider

#pragma mark Initialization & disposal

- (id)init {
	self = [super init];
	if (self) {
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
	if ([_methodsBySelectors objectForKey:method.methodSelector]) [NSException raise:@"Method with selector %@ is already registered!", method.methodSelector];
	[_methods addObject:method];
	[_methodsBySelectors setObject:method forKey:method.methodSelector];
}

#pragma mark Properties

@synthesize methods = _methods;

@end
