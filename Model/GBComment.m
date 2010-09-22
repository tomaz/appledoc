//
//  GBComment.m
//  appledoc
//
//  Created by Tomaz Kragelj on 27.8.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBCommentParagraph.h"
#import "GBCommentArgument.h"
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

- (void)registerParameter:(GBCommentArgument *)parameter {
	NSParameterAssert(parameter != nil);
	GBLogDebug(@"Registering parameter %@...", parameter);
	if (!_parameters) _parameters = [[NSMutableArray alloc] init];
	[_parameters addObject:parameter];
}

- (void)registerException:(GBCommentArgument *)exception {
	NSParameterAssert(exception != nil);
	GBLogDebug(@"Registering exception %@...", exception);
	if (!_exceptions) _exceptions = [[NSMutableArray alloc] init];
	[_exceptions addObject:exception];
}

- (void)registerCrossReference:(GBParagraphLinkItem *)ref {
	NSParameterAssert(ref != nil);
	GBLogDebug(@"Registering cross referece %@...", ref);
	if (!_crossrefs) _crossrefs = [[NSMutableArray alloc] init];
	[_crossrefs addObject:ref];
}

#pragma mark Overriden methods

- (NSString *)description {
	BOOL multiline = ([self.paragraphs count] + [self.parameters count] + [self.exceptions count] + [self.crossrefs count] + (self.result ? 1 : 0)) > 1;
	NSMutableString *result = [NSMutableString stringWithFormat:@"%@", [self className]];
	
	// Paragraphs.
	if ([self.paragraphs count] > 0) {
		[result appendFormat:@"{p%@", multiline ? @"\n" : @" "];
		[self.paragraphs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			[result appendString:[obj description]];
			if (idx < [self.paragraphs count]-1) [result appendString:@",\n"];
		}];
		[result appendFormat:@"%@}", multiline ? @"\n" : @" "];
	}
	
	// Parameters.
	if ([self.parameters count] > 0) {
		[result appendFormat:@"{par%@", multiline ? @"\n" : @" "];
		[self.parameters enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			[result appendString:[obj description]];
			if (idx < [self.parameters count]-1) [result appendString:@",\n"];
		}];
		[result appendFormat:@"%@}", multiline ? @"\n" : @" "];
	}
	
	// Result.
	if (self.result) {
		[result appendFormat:@"{ret%@", multiline ? @"\n" : @" "];
		[result appendString:[self.result description]];
		[result appendFormat:@"%@}", multiline ? @"\n" : @" "];
	}
	
	// Exceptions.
	if ([self.exceptions count] > 0) {
		[result appendFormat:@"{exc%@", multiline ? @"\n" : @" "];
		[self.exceptions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			[result appendString:[obj description]];
			if (idx < [self.exceptions count]-1) [result appendString:@",\n"];
		}];
		[result appendFormat:@"%@}", multiline ? @"\n" : @" "];
	}
	
	// Cross references.
	if ([self.crossrefs count] > 0) {
		[result appendFormat:@"{ref%@", multiline ? @"\n" : @" "];
		[self.crossrefs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			[result appendString:[obj description]];
			if (idx < [self.crossrefs count]-1) [result appendString:@",\n"];
		}];
		[result appendFormat:@"%@}", multiline ? @"\n" : @" "];
	}
	
	return result;
}

#pragma mark Properties

@synthesize paragraphs = _paragraphs;
@synthesize parameters = _parameters;
@synthesize exceptions = _exceptions;
@synthesize crossrefs = _crossrefs;
@synthesize result;
@synthesize firstParagraph;
@synthesize stringValue;

@end
