//
//  GBComment.m
//  appledoc
//
//  Created by Tomaz Kragelj on 27.8.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBCommentParagraph.h"
#import "GBCommentArgument.h"
#import "GBParagraphLinkItem.h"
#import "GBComment.h"

@interface GBComment ()

- (BOOL)replaceArgumentWithSameNameInList:(NSMutableArray *)list withArgument:(GBCommentArgument *)argument;
@property (readwrite,retain) GBCommentParagraph *result;

@end

#pragma mark -

@implementation GBComment

#pragma mark Initialization & disposal

+ (id)commentWithStringValue:(NSString *)value {
	return [self commentWithStringValue:value sourceInfo:nil];
}

+ (id)commentWithStringValue:(NSString *)value sourceInfo:(GBSourceInfo *)info {
	GBComment *result = [[[self alloc] init] autorelease];
	result.stringValue = value;
	result.sourceInfo = info;
	return result;
}

#pragma mark Registration handling

- (void)registerParagraph:(GBCommentParagraph *)paragraph {
	NSParameterAssert(paragraph != nil);
	if ([self.paragraphs count] > 0)
		GBLogDebug(@"%@: Registering paragraph %@...", self, paragraph);
	else
		GBLogDebug(@"Registering first paragraph %@...", paragraph);
	if (!_paragraphs) {
		_paragraphs = [[NSMutableArray alloc] init];
		self.firstParagraph = paragraph;
	}
	[_paragraphs addObject:paragraph];
}

- (void)registerParameter:(GBCommentArgument *)parameter {
	NSParameterAssert(parameter != nil);
	NSParameterAssert([parameter.argumentName length] > 0);	
	GBLogDebug(@"%@: Registering parameter %@...", self, parameter);
	if (!_parameters) _parameters = [[NSMutableArray alloc] init];
	if ([self replaceArgumentWithSameNameInList:_parameters withArgument:parameter]) {
		GBLogWarn(@"%@: Parameter with name %@ is already registered, replacing existing!", self, parameter.argumentName);
		return;
	}
	[_parameters addObject:parameter];
}

- (void)replaceParametersWithParametersFromArray:(NSArray *)array {
	GBLogDebug(@"%@: Replacing parameters with %ld objects...", [array count]);
	[_parameters removeAllObjects];
	[array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		[self registerParameter:obj];
	}];
}

- (void)registerResult:(GBCommentParagraph *)value {
	NSParameterAssert(value != nil);
	GBLogDebug(@"%@: Registering result %@...", self, value);
	if (self.result) GBLogWarn(@"%@: Result is already registered, replacing existing!", self);
	self.result = value;
}

- (void)registerException:(GBCommentArgument *)exception {
	NSParameterAssert(exception != nil);
	GBLogDebug(@"%@: Registering exception %@...", self, exception);
	if (!_exceptions) _exceptions = [[NSMutableArray alloc] init];
	if ([self replaceArgumentWithSameNameInList:_exceptions withArgument:exception]) {
		GBLogWarn(@"%@: Exception with name %@ is already registered, replacing existing!", self, exception.argumentName);
		return;
	}
	[_exceptions addObject:exception];
}

- (void)registerCrossReference:(GBParagraphLinkItem *)ref {
	NSParameterAssert(ref != nil);
	GBLogDebug(@"%@: Registering cross referece %@...", self, ref);
	if (!_crossrefs) _crossrefs = [[NSMutableArray alloc] init];
	for (NSUInteger i=0; i<[_crossrefs count]; i++) {
		GBParagraphLinkItem *existing = [_crossrefs objectAtIndex:i];
		if ([existing.stringValue isEqualToString:ref.stringValue]) {
			GBLogWarn(@"%@: Cross reference %@ is already registered, ignoring!", self, ref.stringValue);
			return;
		}
	}
	[_crossrefs addObject:ref];
}

#pragma mark Helper methods

- (BOOL)replaceArgumentWithSameNameInList:(NSMutableArray *)list withArgument:(GBCommentArgument *)argument {
	__block BOOL result = NO;
	[list enumerateObjectsUsingBlock:^(GBCommentArgument *existing, NSUInteger idx, BOOL *stop) {
		if ([existing.argumentName isEqualToString:argument.argumentName]) {
			[list replaceObjectAtIndex:idx withObject:argument];
			result = YES;
			*stop = YES;
		}
	}];
	return result;
}

#pragma mark Overriden methods

- (NSString *)description {
	return [NSString stringWithFormat:@"'%@'", [self.stringValue normalizedDescription]];
}

- (NSString *)debugDescription {
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
@synthesize sourceInfo;
@synthesize stringValue;

@end
