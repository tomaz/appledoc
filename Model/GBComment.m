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
	NSMutableString *result = [NSMutableString stringWithFormat:@"%@{ ", [self className]];
	if ([self.paragraphs count] > 1) [result appendString:@"\n"];
	[self.paragraphs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		[result appendString:[obj description]];
		if (idx < [self.paragraphs count]-1) [result appendString:@",\n"];
	}];
	[result appendString:([self.paragraphs count] > 1) ? @"\n}" : @" }"];
	return result;
}

#pragma mark Properties

@synthesize paragraphs = _paragraphs;
@synthesize firstParagraph;
@synthesize stringValue;

@end
