//
//  GBParagraphItem.m
//  appledoc
//
//  Created by Tomaz Kragelj on 30.8.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBParagraphItem.h"

@implementation GBParagraphItem

#pragma mark Initialization & disposal

+ (id)paragraphItem {
	return [[[self alloc] init] autorelease];
}

#pragma mark Properties

@synthesize stringValue;

@end
