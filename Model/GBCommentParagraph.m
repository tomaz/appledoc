//
//  GBCommentParagraph.m
//  appledoc
//
//  Created by Tomaz Kragelj on 27.8.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBCommentParagraph.h"

@implementation GBCommentParagraph

#pragma mark Initialization & disposal

+ (id)paragraph {
	return [[[self alloc] init] autorelease];
}

#pragma mark Properties

@synthesize stringValue;

@end
