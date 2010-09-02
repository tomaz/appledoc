//
//  GBComment.m
//  appledoc
//
//  Created by Tomaz Kragelj on 27.8.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBCommentParagraph.h"
#import "GBStoreProviding.h"
#import "GBComment.h"

@implementation GBComment

#pragma mark Initialization & disposal

+ (id)commentWithStringValue:(NSString *)value {
	GBComment *result = [[[self alloc] init] autorelease];
	result.stringValue = value;
	return result;
}

#pragma mark Registration handling

- (void)registerParagraph:(GBCommentParagraph *)paragraph {
	NSParameterAssert(paragraph != nil);
	GBLogDebug(@"Registering paragraph %@...", paragraph);
	if (!_paragraphs) {
		_paragraphs = [[NSMutableArray alloc] init];
		self.firstParagraph = paragraph;
	}
	[_paragraphs addObject:paragraph];
}

#pragma mark Overriden methods

- (NSString *)description {
	return [NSString stringWithFormat:@"%@: %ld paragraphs", [self className], [self.paragraphs count]];
}

#pragma mark Properties

@synthesize paragraphs = _paragraphs;
@synthesize firstParagraph;
@synthesize stringValue;

@end
