//
//  GBCommentsProcessor.m
//  appledoc
//
//  Created by Tomaz Kragelj on 27.8.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "RegexKitLite.h"
#import "GBApplicationSettingsProvider.h"
#import "GBStore.h"
#import "GBDataObjects.h"
#import "GBCommentsProcessor.h"

@interface GBCommentsProcessor ()

- (BOOL)isLineMatchingDirectiveStatement:(NSString *)string;
- (BOOL)findCommentBlockInLines:(NSArray *)lines blockRange:(NSRange *)range;
- (void)processCommentBlockInLines:(NSArray *)lines blockRange:(NSRange)range;

@property (retain) id currentContext;
@property (retain) GBComment *currentComment;
@property (retain) GBStore *store;
@property (retain) GBApplicationSettingsProvider *settings;
@property (readonly) GBCommentComponentsProvider *components;

@property (readonly) NSString *sourceFileInfo;
@property (assign) NSUInteger currentStartLine;

@end

#pragma mark -

@implementation GBCommentsProcessor

#pragma mark Initialization & disposal

+ (id)processorWithSettingsProvider:(id)settingsProvider {
	return [[[self alloc] initWithSettingsProvider:settingsProvider] autorelease];
}

- (id)initWithSettingsProvider:(id)settingsProvider {
	NSParameterAssert(settingsProvider != nil);
	GBLogDebug(@"Initializing comments processor with settings provider %@...", settingsProvider);
	self = [super init];
	if (self) {
		self.settings = settingsProvider;
	}
	return self;
}

#pragma mark Processing handling

- (void)processComment:(GBComment *)comment withStore:(id)store {
	[self processComment:comment withContext:nil store:store];
}

- (void)processComment:(GBComment *)comment withContext:(id<GBObjectDataProviding>)context store:(id)store {
	NSParameterAssert(comment != nil);
	NSParameterAssert(store != nil);
	GBLogDebug(@"Processing %@ found in %@...", comment, comment.sourceInfo.filename);
	self.currentComment = comment;
	self.currentContext = context;
	self.store = store;	
	NSArray *lines = [comment.stringValue arrayOfLines];
	NSUInteger line = comment.sourceInfo.lineNumber;
	NSRange range = NSMakeRange(0, 0);
	GBLogDebug(@"- Comment has %lu lines.", [lines count]);
	while ([self findCommentBlockInLines:lines blockRange:&range]) {
		GBLogDebug(@"- Found comment block in lines %lu..%lu...", line + range.location, line + range.location + range.length);
		[self processCommentBlockInLines:lines blockRange:range];
		range.location += range.length;
	}
}

- (BOOL)findCommentBlockInLines:(NSArray *)lines blockRange:(NSRange *)range {
	// Searches the given array of lines for the index of ending line of the block starting at the given index. Effectively this groups all lines that belong to a single block where block is a paragraph text or one of it's items delimited by empty line. The index returned is the index of the last line of the block, so may be the same as the start index, the method takes care to skip empty starting lines if needed and updates start index to point to first block line (but properly detects empty lines belonging to example block). Note that the code is straightforward except for the fact that we need to handle example blocks properly (i.e. can't just trim all whitespace of a line to determine if it's empty or not, instead we need to validate the line is not part of example block).
	NSParameterAssert(range != NULL);
	
	// First skip all starting empty lines.
	NSUInteger start = range->location;
	while (start < [lines count]) {
		NSString *line = [lines objectAtIndex:start];
		if ([line length] > 0) break;
		start++;
	}
	
	// Find the end of block.
	BOOL matchingDirectivesBlock = YES;
	NSUInteger end = start;
	if (start < [lines count]) {
		while (end < [lines count]) {
			NSString *line = [lines objectAtIndex:end];
			if ([line length] == 0) break;
			BOOL isDirective = [self isLineMatchingDirectiveStatement:line];
			if (isDirective && !matchingDirectivesBlock) break;
			if (!isDirective) matchingDirectivesBlock = NO;
			end++;
		}
	}
	
	// Pass results back to client through parameters.
	range->location = start;
	range->length = end - start;
	return (start < [lines count]);
}

- (void)processCommentBlockInLines:(NSArray *)lines blockRange:(NSRange)range {
//	// The given range is guaranteed to point to actual block within the lines array, so we only need to determine the kind of block and how to handle it.
//	NSArray *block = [lines subarrayWithRange:range];
//	self.currentStartLine = self.currentComment.sourceInfo.lineNumber + range.location;
//	
//	// If the block defines one of the known paragraph items, register it and return. Note that paragraph items are simply added to previous paragraph, however if no paragraph exists yet, this will automatically create one.
//	if ([self registerExampleBlockFromLines:block]) return;
//	if ([self registerBugBlockFromLines:block]) return;
//	if ([self registerWarningBlockFromlines:block]) return;
//	if ([self registerListBlockFromLines:block]) return;
//	if ([self registerDirectivesBlockFromLines:block]) return;
//	
//	// If nothing else is matched, the block is standard text. For that we need to start a new paragraph and process the text. Note that we first need to close all open paragraphs - even if the paragraph was started by a known paragraph item block, new text block always starts a new paragraph at this point. But we must keep the new paragraph open in case next block defines an item.
//	[self popAllParagraphs];
//	[self registerTextBlockFromLines:block];
}

- (BOOL)isLineMatchingDirectiveStatement:(NSString *)string {
	if ([string isMatchedByRegex:self.components.parameterDescriptionRegex]) return YES;
	if ([string isMatchedByRegex:self.components.exceptionDescriptionRegex]) return YES;
	if ([string isMatchedByRegex:self.components.returnDescriptionRegex]) return YES;
	if ([string isMatchedByRegex:self.components.crossReferenceRegex]) return YES;
	return NO;
}

#pragma mark Properties

- (NSString *)sourceFileInfo {
	// Helper method for simplifiying logging of current line and source file information.
	return [NSString stringWithFormat:@"%@@%lu", self.currentComment.sourceInfo.filename, self.currentStartLine];
}

- (GBCommentComponentsProvider *)components {
	return self.settings.commentComponents;
}

@synthesize currentStartLine;
@synthesize currentComment;
@synthesize currentContext;
@synthesize settings;
@synthesize store;

@end
