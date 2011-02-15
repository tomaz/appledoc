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
- (BOOL)findCommentBlockInLines:(NSArray *)lines blockRange:(NSRange *)range shortRange:(NSRange *)shortRange;
- (void)processCommentBlockInLines:(NSArray *)lines blockRange:(NSRange)range shortRange:(NSRange *)shortRange;

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

- (void)processComment:(GBComment *)comment withContext:(id)context store:(id)store {
	NSParameterAssert(comment != nil);
	NSParameterAssert(store != nil);
	GBLogDebug(@"Processing %@ found in %@...", comment, comment.sourceInfo.filename);
	self.currentComment = comment;
	self.currentContext = context;
	self.store = store;	
	NSArray *lines = [comment.stringValue arrayOfLines];
	NSUInteger line = comment.sourceInfo.lineNumber;
	NSRange range = NSMakeRange(0, 0);
	NSRange shortRange = NSMakeRange(0, 0);
	GBLogDebug(@"- Comment has %lu lines.", [lines count]);
	while ([self findCommentBlockInLines:lines blockRange:&range shortRange:&shortRange]) {
		GBLogDebug(@"- Found comment block in lines %lu..%lu...", line + range.location, line + range.location + range.length);
		[self processCommentBlockInLines:lines blockRange:range];
		range.location += range.length;
	}
}

- (BOOL)findCommentBlockInLines:(NSArray *)lines blockRange:(NSRange *)blockRange shortRange:(NSRange *)shortRange {
	// Searches the given array of lines starting at line index from the given range until first @ directive is found. Returns YES if block was found, NO otherwise. If block was found, the given range contains the block range of the block within the given array and short range contains the range of first part up to the first empty line.
	NSParameterAssert(blockRange != NULL);
	NSParameterAssert(shortRange != NULL);
	
	// First skip all starting empty lines.
	NSUInteger start = blockRange->location;
	while (start < [lines count]) {
		NSString *line = [lines objectAtIndex:start];
		if ([line length] > 0) break;
		start++;
	}
	
	// Find the end of block, which is at the first @ directive; note that we handle each @ directive separately.
	NSUInteger blockEnd = start;
	NSUInteger shortEnd = NSNotFound;
	while (blockEnd < [lines count]) {
		NSString *line = [lines objectAtIndex:blockEnd];
		if (blockEnd > start && [self isLineMatchingDirectiveStatement:line]) break;
		if ([line length] == 0 && shortEnd == NSNotFound) shortEnd = blockEnd;
		blockEnd++;
	}
	if (shortEnd == NSNotFound) shortEnd = blockEnd;
	
	// Pass results back to client through parameters.
	blockRange->location = start;
	blockRange->length = blockEnd - start;
	shortRange->location = start;
	shortRange->length = shortEnd - start;
	return (start < [lines count]);
}

- (void)processCommentBlockInLines:(NSArray *)lines blockRange:(NSRange)blockRange shortRange:(NSRange *)shortRange {
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
	if ([string isMatchedByRegex:self.components.warningSectionRegex]) return YES;
	if ([string isMatchedByRegex:self.components.bugSectionRegex]) return YES;
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
