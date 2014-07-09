//
//  GBCommentComponentsList.m
//  appledoc
//
//  Created by Tomaz Kragelj on 14.2.11.
//  Copyright 2011 Gentle Bytes. All rights reserved.
//

#import "GBCommentComponentsList.h"

@implementation GBCommentComponentsList

#pragma mark Initialization & disposal

+ (id)componentsList {
	return [[self alloc] init];
}

- (id)init {
    self = [super init];
    if (self) {
		_components = [[NSMutableArray alloc] init];
    }    
    return self;
}

#pragma mark Data handling

- (void)registerComponent:(id)component {
	NSParameterAssert(component != nil);
	GBLogDebug(@"Registering component %@...", component);
	[_components addObject:component];
}

#pragma mark Properties

@synthesize components = _components;

@end
