//
//  Appledoc.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/12/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "Appledoc.h"

@interface Appledoc ()
@end

#pragma mark -

@implementation Appledoc

@synthesize settings = _settings;

#pragma mark - Initialization & disposal

- (id)init {
	self = [super init];
	return self;
}

@end
