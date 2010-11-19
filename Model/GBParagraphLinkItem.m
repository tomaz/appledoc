//
//  GBParagraphLinkItem.m
//  appledoc
//
//  Created by Tomaz Kragelj on 7.9.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBParagraphLinkItem.h"

@implementation GBParagraphLinkItem

#pragma mark Overriden methods

- (NSString *)description {
	return [NSString stringWithFormat:@"Link '%@'", [super description]];
}

#pragma mark Helper methods

- (BOOL)isLinkItem {
	return YES;
}

#pragma mark Properties

@synthesize href;
@synthesize context;
@synthesize member;
@synthesize isLocal;

@end
