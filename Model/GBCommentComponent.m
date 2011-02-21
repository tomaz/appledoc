//
//  GBCommentComponent.m
//  appledoc
//
//  Created by Tomaz Kragelj on 14.2.11.
//  Copyright 2011 Gentle Bytes. All rights reserved.
//

#import "GBCommentComponent.h"

@implementation GBCommentComponent

#pragma mark Initialization & disposal

+ (id)componentWithStringValue:(NSString *)value {
	return [self componentWithStringValue:value sourceInfo:nil];
}

+ (id)componentWithStringValue:(NSString *)value sourceInfo:(GBSourceInfo *)info {
	GBCommentComponent *result = [[[self alloc] init] autorelease];
	result.stringValue = value;
	result.sourceInfo = info;
	return result;
}

#pragma mark HTML processing

- (NSString *)htmlValue {
	if (!self.settings) return self.markdownValue;
	if (_htmlValue) return _htmlValue;
	_htmlValue = self.markdownValue;
	return _htmlValue;
}

#pragma mark Properties

@synthesize stringValue;
@synthesize markdownValue;
@synthesize sourceInfo;
@synthesize settings;

@end
