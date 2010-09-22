//
//  GBMethodSectionData.m
//  appledoc
//
//  Created by Tomaz Kragelj on 22.9.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBMethodSectionData.h"

@implementation GBMethodSectionData

#pragma mark Helper methods

- (void)registerMethod:(GBMethodData *)method {
	NSParameterAssert(method != nil);
	if (!_methods) _methods = [[NSMutableArray alloc] init];
	[_methods addObject:method];
}

#pragma mark Properties

@synthesize sectionName;
@synthesize methods = _methods;

@end
