//
//  GBCommentComponent.m
//  appledoc
//
//  Created by Tomaz Kragelj on 14.2.11.
//  Copyright 2011 Gentle Bytes. All rights reserved.
//

#import "GBApplicationSettingsProvider.h"
#import "GBCommentComponent.h"

@implementation GBCommentComponent

#pragma mark Initialization & disposal

+ (id)componentWithStringValue:(NSString *)value {
	return [self componentWithStringValue:value sourceInfo:nil];
}

+ (id)componentWithStringValue:(NSString *)value sourceInfo:(GBSourceInfo *)info {
	GBCommentComponent *result = [[self alloc] init];
	result.stringValue = value;
	result.sourceInfo = info;
	return result;
}

#pragma mark Derived values

- (NSString *)htmlValue {
	if (!self.settings) return self.markdownValue;
	if (_htmlValue) return _htmlValue;
	_htmlValue = [self.settings stringByConvertingMarkdownToHTML:self.markdownValue];
	return _htmlValue;
}

- (NSString *)textValue {
	if (!self.settings) return self.markdownValue;
	if (_textValue) return _textValue;
	_textValue = [self.settings stringByConvertingMarkdownToText:self.markdownValue];
	return _textValue;
}

#pragma mark Properties

@synthesize relatedItem;
@synthesize stringValue;
@synthesize markdownValue;
@synthesize sourceInfo;
@synthesize settings;

@end
