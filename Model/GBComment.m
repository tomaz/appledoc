//
//  GBComment.m
//  appledoc
//
//  Created by Tomaz Kragelj on 27.8.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBStoreProviding.h"
#import "GBComment.h"

@implementation GBComment

#pragma mark Initialization & disposal

+ (id)commentWithStringValue:(NSString *)value {
	GBComment *result = [[[self alloc] init] autorelease];
	result.stringValue = value;
	return result;
}

#pragma mark Processing handling

- (void)processCommentWithStore:(id<GBStoreProviding>)store {
}

#pragma mark Properties

@synthesize paragraphs;
@synthesize stringValue;

@end
