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

- (void)processCommentBlockInLines:(NSArray *)lines blockRange:(NSRange)blockRange shortRange:(NSRange)shortRange;
- (void)registerShortDescriptionFromLines:(NSArray *)lines range:(NSRange)range removePrefix:(NSString *)remove;
- (BOOL)findCommentBlockInLines:(NSArray *)lines blockRange:(NSRange *)blockRange shortRange:(NSRange *)shortRange;
- (BOOL)processWarningBlockInString:(NSString *)string lines:(NSArray *)lines blockRange:(NSRange)blockRange shortRange:(NSRange)shortRange;
- (BOOL)processBugBlockInString:(NSString *)string lines:(NSArray *)lines blockRange:(NSRange)blockRange shortRange:(NSRange)shortRange;
- (BOOL)isLineMatchingDirectiveStatement:(NSString *)string;
- (NSString *)stringByPreprocessingString:(NSString *)string;
- (NSString *)stringByCombiningTrimmedLines:(NSArray *)lines;

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
	NSRange blockRange = NSMakeRange(0, 0);
	NSRange shortRange = NSMakeRange(0, 0);
	GBLogDebug(@"- Comment has %lu lines.", [lines count]);
	while ([self findCommentBlockInLines:lines blockRange:&blockRange shortRange:&shortRange]) {
		GBLogDebug(@"- Found comment block in lines %lu..%lu...", line + blockRange.location, line + blockRange.location + blockRange.length);
		[self processCommentBlockInLines:lines blockRange:blockRange shortRange:shortRange];
		blockRange.location += blockRange.length;
	}
}

- (BOOL)findCommentBlockInLines:(NSArray *)lines blockRange:(NSRange *)blockRange shortRange:(NSRange *)shortRange {
	// Searches the given array of lines starting at line index from the given range until first directive is found. Returns YES if block was found, NO otherwise. If block was found, the given range contains the block range of the block within the given array and short range contains the range of first part up to the first empty line.
	NSParameterAssert(blockRange != NULL);
	NSParameterAssert(shortRange != NULL);
	
	// First skip all starting empty lines.
	NSUInteger start = blockRange->location;
	while (start < [lines count]) {
		NSString *line = [lines objectAtIndex:start];
		if ([line length] > 0) break;
		start++;
	}
	
	// Find the end of block, which is at the first directive; note that we handle each directive separately.
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

- (void)processCommentBlockInLines:(NSArray *)lines blockRange:(NSRange)blockRange shortRange:(NSRange)shortRange {
	// The given range is guaranteed to point to actual block within the lines array, so we only need to determine the kind of block and how to handle it. We only need to handle short description based on settings if this is first block within the comment.
	self.currentStartLine = self.currentComment.sourceInfo.lineNumber + blockRange.location;
	
	// If the block is a directive, we should handle only it's description text for the main block. If this is the first block in the comment, we should take the first part of the directive for short description.
	if ([self isLineMatchingDirectiveStatement:[lines firstObject]]) {
		NSArray *block = [lines subarrayWithRange:blockRange];
		NSString *string = [self stringByCombiningTrimmedLines:block];
		if ([self processWarningBlockInString:string lines:lines blockRange:blockRange shortRange:shortRange]) return;
		if ([self processBugBlockInString:string lines:lines blockRange:blockRange shortRange:shortRange]) return;
		GBLogWarn(@"Unknown directive block %@ encountered at %@, processing as standard text!", [[lines firstObject] normalizedDescription], self.sourceFileInfo);
	}
		
	// Handle short description and update block range if we're not repeating first paragraph.
	if (!self.currentComment.shortDescription) {
		[self registerShortDescriptionFromLines:lines range:shortRange removePrefix:nil];
		if (!self.settings.repeatFirstParagraphForMemberDescription) {
			blockRange.location += shortRange.length;
			blockRange.length -= shortRange.length;
		}
	}
	
	// Register main block. Note that we skip this if block is empty (this can happen when removing short description above).
	if (blockRange.length == 0) return;
	NSArray *block = [lines subarrayWithRange:blockRange];
	NSString *blockString = [self stringByCombiningTrimmedLines:block];
	if ([blockString length] == 0) return;
	
	GBLogDebug(@"- Registering text block %@ at %@...", [blockString normalizedDescription], self.sourceFileInfo);
	GBCommentComponent *component = [GBCommentComponent componentWithStringValue:blockString];
	component.markdownValue = [self stringByPreprocessingString:blockString];
	[self.currentComment.longDescription registerComponent:component];
}

- (void)registerShortDescriptionFromLines:(NSArray *)lines range:(NSRange)range removePrefix:(NSString *)remove {
	// Extracts short description text from the given range within the given array of lines, converts it to string, optionally removes given prefix (this is used to remove directive text) and registers resulting text as current comment's short description. If short description is already registered, nothing happens!
	if (self.currentComment.shortDescription) return;
	
	// Get short description from the lines.
	NSArray *block = [lines subarrayWithRange:range];
	NSString *stringValue = [self stringByCombiningTrimmedLines:block];
	
	// Trim prefix if given.
	if ([remove length] > 0) stringValue = [stringValue substringFromIndex:[remove length]];
	GBLogDebug(@"- Registering short description from %@...", [stringValue normalizedDescription]);
	
	// Convert to markdown and register everything.
	GBCommentComponent *component = [GBCommentComponent componentWithStringValue:stringValue];
	component.markdownValue = [self stringByPreprocessingString:stringValue];
	self.currentComment.shortDescription = component;
}

#pragma mark Directives matching

- (BOOL)processWarningBlockInString:(NSString *)string lines:(NSArray *)lines blockRange:(NSRange)blockRange shortRange:(NSRange)shortRange {
	// Match warning block.
	NSArray *components = [string captureComponentsMatchedByRegex:self.components.warningSectionRegex];
	if ([components count] == 0) return NO;
	
	// Get data from captures. Index 1 is directive, index 2 description text.
	NSString *directive = [components objectAtIndex:1];
	NSString *description = [components objectAtIndex:2];
	NSString *stringValue = [NSString stringWithFormat:@"%@%@", directive, description];
	GBLogDebug(@"- Registering warning block %@ at %@...", [description normalizedDescription], self.sourceFileInfo);
	[self registerShortDescriptionFromLines:lines range:shortRange removePrefix:directive];
	
	// Convert to markdown and register everything. We always use the whole text for warning directive.
	GBCommentComponent *component = [GBCommentComponent componentWithStringValue:stringValue];
	component.markdownValue = [self stringByPreprocessingString:description];
	[self.currentComment.longDescription registerComponent:component];
	return YES;
}

- (BOOL)processBugBlockInString:(NSString *)string lines:(NSArray *)lines blockRange:(NSRange)blockRange shortRange:(NSRange)shortRange {
	// Match bug block.
	NSArray *components = [string captureComponentsMatchedByRegex:self.components.bugSectionRegex];
	if ([components count] == 0) return NO;
	
	// Get data from captures. Index 1 is directive, index 2 description text.
	NSString *directive = [components objectAtIndex:1];
	NSString *description = [components objectAtIndex:2];
	NSString *stringValue = [NSString stringWithFormat:@"%@%@", directive, description];
	GBLogDebug(@"- Registering bug block %@ at %@...", [description normalizedDescription], self.sourceFileInfo);
	[self registerShortDescriptionFromLines:lines range:shortRange removePrefix:directive];
	
	// Convert to markdown and register everything. We always use the whole text for warning directive.
	GBCommentComponent *component = [GBCommentComponent componentWithStringValue:stringValue];
	component.markdownValue = [self stringByPreprocessingString:description];
	[self.currentComment.longDescription registerComponent:component];
	return YES;
}

- (BOOL)isLineMatchingDirectiveStatement:(NSString *)string {
	if ([string isMatchedByRegex:self.components.warningSectionRegex]) return YES;
	if ([string isMatchedByRegex:self.components.bugSectionRegex]) return YES;
	if ([string isMatchedByRegex:self.components.parameterDescriptionRegex]) return YES;
	if ([string isMatchedByRegex:self.components.exceptionDescriptionRegex]) return YES;
	if ([string isMatchedByRegex:self.components.returnDescriptionRegex]) return YES;
	if ([string isMatchedByRegex:self.components.relatedSymbolRegex]) return YES;
	return NO;
}

#pragma mark Preprocessing methods

- (NSString *)stringByPreprocessingString:(NSString *)string {
	return string;
}

- (NSString *)stringByCombiningTrimmedLines:(NSArray *)lines {
	// Combines all lines from given array delimiting them with new line and automatically trimms all empty lines from the start and end of array. If resulting array is empty, empty string is returned. If only one line remains, the line is returned, otherwise all lines delimited by new-line are returned.
	NSMutableArray *array = [NSMutableArray arrayWithArray:lines];
	while ([array count] > 0 && [[array firstObject] length] == 0) [array removeObjectAtIndex:0];
	while ([array count] > 0 && [[array lastObject] length] == 0) [array removeLastObject];
	if ([array count] == 0) return @"";
	if ([array count] == 1) return [array firstObject];
	return [NSString stringByCombiningLines:array delimitWith:@"\n"];
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
