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

@interface GBCrossRefData : NSObject

@property (assign) NSRange range;
@property (strong) NSString *address;
@property (strong) NSString *description;
@property (strong) NSString *markdown;

@property (assign, readonly) BOOL isValid;

@end

@implementation GBCrossRefData
@synthesize description; // Explicitly required to override -[NSObject description](readonly)

+ (instancetype) crossRefData {
    GBCrossRefData *result = [[self alloc] init];
    result.range = NSMakeRange(NSNotFound, 0);
    return result;
}

- (BOOL) isInsideCrossRef:(GBCrossRefData *) outer {
    if (outer == nil) return NO;
	return NSEqualRanges(outer.range, NSUnionRange(self.range, outer.range));
}

- (BOOL) matchesObject:(id) object {
    if ([object isKindOfClass:[GBClassData class]])
        return [self.description isEqualToString:[object nameOfClass]];
    else if ([object isKindOfClass:[GBCategoryData class]])
        return [self.description isEqualToString:[object idOfCategory]];
    else if ([object isKindOfClass:[GBProtocolData class]])
        return [self.description isEqualToString:[object nameOfProtocol]];
	else if ([object isKindOfClass:[GBTypedefEnumData class]])
        return [self.description isEqualToString:[object nameOfEnum]];
    else if ([object isKindOfClass:[GBTypedefBlockData class]])
        return [self.description isEqualToString:[object nameOfBlock]];
	else if ([object isKindOfClass:[GBDocumentData class]])
        return NO;
    else
		return [[object methodSelector] isEqualToString:self.description];
}

- (NSComparisonResult) compareLocation:(GBCrossRefData *) object {
    if (!object) [NSException raise:NSInvalidArgumentException format:@"Nil parameter"];
    if (self.range.location < object.range.location)
        return NSOrderedAscending;
    else if (self.range.location == object.range.location)
        return NSOrderedSame;
    else
        return NSOrderedDescending;
}

@end

#pragma mark -

/** Defines different processing flags. */
enum {
	/** Specifies we're processing cross references for related items block. */
	GBProcessingFlagRelatedItem = 0x1,
	/** Specifies that we're processing cross references inside Markdown formatted link. */
	GBProcessingFlagMarkdownLink = 0x2,
	/** Specifies that we should NOT embed generated Markdown links for later post-processing of code spans. */
	GBProcessingFlagEmbedMarkdownLink = 0x4,
};
typedef NSUInteger GBProcessingFlag;

#pragma mark -

@interface GBCommentsProcessor ()

- (void)processCommentBlockInLines:(NSArray *)lines blockRange:(NSRange)blockRange shortRange:(NSRange)shortRange;
- (void)registerShortDescriptionFromLines:(NSArray *)lines range:(NSRange)range removePrefix:(NSString *)remove;
- (void)reserveShortDescriptionFromLines:(NSArray *)lines range:(NSRange)range removePrefix:(NSString *)remove;
- (void)registerReservedShortDescriptionIfNecessary;
- (BOOL)findCommentBlockInLines:(NSArray *)lines blockRange:(NSRange *)blockRange shortRange:(NSRange *)shortRange;

- (BOOL)processWarningBlockInString:(NSString *)string lines:(NSArray *)lines blockRange:(NSRange)blockRange shortRange:(NSRange)shortRange;
- (BOOL)processBugBlockInString:(NSString *)string lines:(NSArray *)lines blockRange:(NSRange)blockRange shortRange:(NSRange)shortRange;
- (BOOL)processDeprecatedBlockInString:(NSString *)string lines:(NSArray *)lines blockRange:(NSRange)blockRange shortRange:(NSRange)shortRange;
- (BOOL)processParamBlockInString:(NSString *)string lines:(NSArray *)lines blockRange:(NSRange)blockRange shortRange:(NSRange)shortRange;
- (BOOL)processExceptionBlockInString:(NSString *)string lines:(NSArray *)lines blockRange:(NSRange)blockRange shortRange:(NSRange)shortRange;
- (BOOL)processReturnBlockInString:(NSString *)string lines:(NSArray *)lines blockRange:(NSRange)blockRange shortRange:(NSRange)shortRange;
- (BOOL)processRelatedBlockInString:(NSString *)string lines:(NSArray *)lines blockRange:(NSRange)blockRange shortRange:(NSRange)shortRange;
- (BOOL)processAvailabilityBlockInString:(NSString *)string lines:(NSArray *)lines blockRange:(NSRange)blockRange shortRange:(NSRange)shortRange;
- (BOOL)isLineMatchingDirectiveStatement:(NSString *)string;

- (GBCommentComponent *)commentComponentByPreprocessingString:(NSString *)string withFlags:(GBProcessingFlag)flags;
- (GBCommentComponent *)commentComponentWithStringValue:(NSString *)string;
- (NSString *)stringByPreprocessingString:(NSString *)string withFlags:(GBProcessingFlag)flags;
- (NSString *)stringByPreprocessingNonLinkString:(NSString *)string withFlags:(GBProcessingFlag)flags;
- (NSString *)stringByConvertingCrossReferencesInString:(NSString *)string withFlags:(GBProcessingFlag)flags;
- (NSString *)stringByConvertingSimpleCrossReferencesInString:(NSString *)string searchRange:(NSRange)searchRange flags:(GBProcessingFlag)flags;
- (NSString *)markdownLinkWithDescription:(NSString *)description address:(NSString *)address flags:(GBProcessingFlag)flags;

- (GBCrossRefData *)dataForClassOrProtocolLinkInString:(NSString *)string searchRange:(NSRange)searchRange flags:(GBProcessingFlag)flags;
- (GBCrossRefData *)dataForCategoryLinkInString:(NSString *)string searchRange:(NSRange)searchRange flags:(GBProcessingFlag)flags;
- (GBCrossRefData *)dataForLocalMemberLinkInString:(NSString *)string searchRange:(NSRange)searchRange flags:(GBProcessingFlag)flags;
- (GBCrossRefData *)dataForRemoteMemberLinkInString:(NSString *)string searchRange:(NSRange)searchRange flags:(GBProcessingFlag)flags;
- (GBCrossRefData *)dataForDocumentLinkInString:(NSString *)string searchRange:(NSRange)searchRange flags:(GBProcessingFlag)flags;
- (GBCrossRefData *)dataForURLLinkInString:(NSString *)string searchRange:(NSRange)searchRange flags:(GBProcessingFlag)flags;
- (GBCrossRefData *)dataForFirstMarkdownInlineLinkInString:(NSString *)string searchRange:(NSRange)searchRange flags:(GBProcessingFlag)flags;
- (GBCrossRefData *)dataForFirstMarkdownReferenceLinkInString:(NSString *)string searchRange:(NSRange)searchRange flags:(GBProcessingFlag)flags;

- (NSString *)stringByConvertingLinesToBlockquoteFromString:(NSString *)string class:(NSString *)className;
- (NSString *)stringByCombiningTrimmedLines:(NSArray *)lines;

@property (strong) id currentContext;
@property (strong) id currentObject;
@property (strong) GBComment *currentComment;
@property (strong) GBStore *store;
@property (strong) GBApplicationSettingsProvider *settings;
@property (readonly) GBCommentComponentsProvider *components;

@property (strong) NSMutableDictionary *reservedShortDescriptionData;
@property (strong) GBSourceInfo *currentSourceInfo;
@property (strong) id lastReferencedObject;

@end

#pragma mark -

@implementation GBCommentsProcessor

#pragma mark Initialization & disposal

+ (id)processorWithSettingsProvider:(id)settingsProvider {
	return [[self alloc] initWithSettingsProvider:settingsProvider];
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

- (void)processCommentForObject:(GBModelBase *)object withContext:(id)context store:(id)aStore {
	NSParameterAssert(object != nil);
	self.currentObject = object;
	[self processComment:object.comment withContext:context store:aStore];
	self.currentObject = nil;
}

- (void)processComment:(GBComment *)comment withContext:(id)context store:(id)aStore {
	NSParameterAssert(comment != nil);
	NSParameterAssert(aStore != nil);
	if (comment.originalContext != nil && comment.originalContext != context) return;
	if (comment.isProcessed) return;
	GBLogDebug(@"Processing %@ found in %@...", comment, comment.sourceInfo.filename);
	self.reservedShortDescriptionData = nil;
	self.currentComment = comment;
	self.currentContext = context;
	self.store = aStore;	
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
	[self registerReservedShortDescriptionIfNecessary];
	self.currentComment.isProcessed = YES;
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
	NSString *filename = self.currentComment.sourceInfo.fullpath;
	NSUInteger lineNumber = self.currentComment.sourceInfo.lineNumber + blockRange.location;
	self.currentSourceInfo = [GBSourceInfo infoWithFilename:filename ? filename : @"unknownfile" lineNumber:lineNumber];
	
	// If the block is a directive, we should handle only it's description text for the main block. If this is the first block in the comment, we should take the first part of the directive for short description.
	NSArray *block = [lines subarrayWithRange:blockRange];
	if ([self isLineMatchingDirectiveStatement:[block firstObject]]) {
		NSString *string = [self stringByCombiningTrimmedLines:block];
		if ([self processDiscussionBlockInString:string lines:lines blockRange:blockRange shortRange:shortRange]) return;
		if ([self processAbstractBlockInString:string lines:lines blockRange:blockRange shortRange:shortRange]) return;
		if ([self processNoteBlockInString:string lines:lines blockRange:blockRange shortRange:shortRange]) return;
		if ([self processWarningBlockInString:string lines:lines blockRange:blockRange shortRange:shortRange]) return;
		if ([self processBugBlockInString:string lines:lines blockRange:blockRange shortRange:shortRange]) return;
		if ([self processDeprecatedBlockInString:string lines:lines blockRange:blockRange shortRange:shortRange]) return;
		if ([self processParamBlockInString:string lines:lines blockRange:blockRange shortRange:shortRange]) return;
		if ([self processExceptionBlockInString:string lines:lines blockRange:blockRange shortRange:shortRange]) return;
		if ([self processReturnBlockInString:string lines:lines blockRange:blockRange shortRange:shortRange]) return;
		if ([self processAvailabilityBlockInString:string lines:lines blockRange:blockRange shortRange:shortRange]) return;
		if ([self processRelatedBlockInString:string lines:lines blockRange:blockRange shortRange:shortRange]) return;
		
		
		GBLogXWarn(self.currentSourceInfo, @"Unknown directive block %@ encountered at %@, processing as standard text!", [[lines firstObject] normalizedDescription], self.currentSourceInfo);
	}
		
	// Handle short description and update block range if we're not repeating first paragraph.
	if (!self.currentComment.shortDescription) {
		[self registerShortDescriptionFromLines:lines range:shortRange removePrefix:nil];
		if (!self.settings.repeatFirstParagraphForMemberDescription && !self.alwaysRepeatFirstParagraph) {
			blockRange.location += shortRange.length;
			blockRange.length -= shortRange.length;
		}
	}
	
	// Register main block. Note that we skip this if block is empty (this can happen when removing short description above).
	if (blockRange.length == 0) return;
	NSArray *blockLines = blockRange.length == [block count] ? block : [lines subarrayWithRange:blockRange];
	NSString *blockString = [self stringByCombiningTrimmedLines:blockLines];
	if ([blockString length] == 0) return;
	
	// Process the string and register long description component.
	// **IMPORTANT CONTRIBUTORS NOTE:** do NOT comment or change following two lines. Doing so will brake overview section being created for classes, categories and protocols! Most often this happens with folks wanting to bring in better HeaderDoc support, but it brakes "standard" appledoc way of dealing comments. While I symphatize with ideas of supporting as wide audience as possible, native appledoc users are still larger audience than HeaderDoc, so please find another way. My suggestion would be via cmd line switch that would change behavior from appledoc to HeaderDoc, then opt out with an if statement.
	GBCommentComponent *component = [self commentComponentByPreprocessingString:blockString withFlags:0];
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
	GBCommentComponent *component = [self commentComponentByPreprocessingString:stringValue withFlags:0];
	self.currentComment.shortDescription = component;
}

- (void)reserveShortDescriptionFromLines:(NSArray *)lines range:(NSRange)range removePrefix:(NSString *)remove {
	// Reserves the given short description data for later registration. This is used so that we can properly handle method directives - we only create short description from these if there is no other directive in the comment. So we want to postpone registration until the whole comment text is processed; if another description block is found later on, we'll be registering short description directly from it, so any registered data will not be used. But if after processing the whole block there is still no short description, we'll use registered data. This only registers the data the first time, so the first directive text found in comment is used for short description.
	if (self.reservedShortDescriptionData) return;
	self.reservedShortDescriptionData = [NSMutableDictionary dictionaryWithCapacity:3];
	[self.reservedShortDescriptionData setObject:lines forKey:@"lines"];
	[self.reservedShortDescriptionData setObject:[NSValue valueWithRange:range] forKey:@"range"];
	[self.reservedShortDescriptionData setObject:remove forKey:@"remove"];
}

- (void)registerReservedShortDescriptionIfNecessary {
	// If current comment doens't have short description assigned, this method registers it from registered data.
	if (self.currentComment.shortDescription) return;
	if (!self.reservedShortDescriptionData) return;
	GBLogDebug(@"- Registering reserved short description...");
	NSArray *lines = [self.reservedShortDescriptionData objectForKey:@"lines"];
	NSRange range = [[self.reservedShortDescriptionData objectForKey:@"range"] rangeValue];
	NSString *remove = [self.reservedShortDescriptionData objectForKey:@"remove"];
	[self registerShortDescriptionFromLines:lines range:range removePrefix:remove];
}

#pragma mark Directives matching

- (BOOL)processNoteBlockInString:(NSString *)string lines:(NSArray *)lines blockRange:(NSRange)blockRange shortRange:(NSRange)shortRange {
	NSArray *components = [string captureComponentsMatchedByRegex:self.components.noteSectionRegex];
	if ([components count] == 0) return NO;
	
	// Get data from captures. Index 1 is directive, index 2 description text.
	NSString *directive = [components objectAtIndex:1];
	NSString *description = [components objectAtIndex:2];
	GBLogDebug(@"- Registering note block %@ at %@...", [description normalizedDescription], self.currentSourceInfo);
	[self registerShortDescriptionFromLines:lines range:shortRange removePrefix:directive];
	
	// Convert to markdown and register everything. We always use the whole text for directive.
	GBCommentComponent *component = [self commentComponentByPreprocessingString:description withFlags:0];
	component.stringValue = string;
	component.markdownValue = [self stringByConvertingLinesToBlockquoteFromString:component.markdownValue class:@"note"];
	[self.currentComment.longDescription registerComponent:component];
	return YES;
}

- (BOOL)processWarningBlockInString:(NSString *)string lines:(NSArray *)lines blockRange:(NSRange)blockRange shortRange:(NSRange)shortRange {
	NSArray *components = [string captureComponentsMatchedByRegex:self.components.warningSectionRegex];
	if ([components count] == 0) return NO;
	
	// Get data from captures. Index 1 is directive, index 2 description text.
	NSString *directive = [components objectAtIndex:1];
	NSString *description = [components objectAtIndex:2];
	GBLogDebug(@"- Registering warning block %@ at %@...", [description normalizedDescription], self.currentSourceInfo);
	[self registerShortDescriptionFromLines:lines range:shortRange removePrefix:directive];
	
	// Convert to markdown and register everything. We always use the whole text for directive.
	GBCommentComponent *component = [self commentComponentByPreprocessingString:description withFlags:0];
	component.stringValue = string;
	component.markdownValue = [self stringByConvertingLinesToBlockquoteFromString:component.markdownValue class:@"warning"];
	[self.currentComment.longDescription registerComponent:component];
	return YES;
}

- (BOOL)processDeprecatedBlockInString:(NSString *)string lines:(NSArray *)lines blockRange:(NSRange)blockRange shortRange:(NSRange)shortRange {
	NSArray *components = [string captureComponentsMatchedByRegex:self.components.deprecatedSectionRegex];
	if ([components count] == 0) return NO;
	
	// Get data from captures. Index 1 is directive, index 2 description text.
	NSString *directive = [components objectAtIndex:1];
	NSString *description = [components objectAtIndex:2];
	GBLogDebug(@"- Registering DEPRECATED block %@ at %@...", [description normalizedDescription], self.currentSourceInfo);
	[self registerShortDescriptionFromLines:lines range:shortRange removePrefix:directive];
	
	// Convert to markdown and register everything. We always use the whole text for directive.
	GBCommentComponent *component = [self commentComponentByPreprocessingString:description withFlags:0];
	component.stringValue = [self.currentComment.shortDescription.stringValue stringByAppendingFormat:@" (%@)", string];
	component.markdownValue = [self.currentComment.shortDescription.markdownValue stringByAppendingFormat:@" (<b class=\"deprecated\">Deprecated:</b><span class=\"deprecated\"> %@</span>)", description];
	self.currentComment.shortDescription = component;
	return YES;
}

- (BOOL)processBugBlockInString:(NSString *)string lines:(NSArray *)lines blockRange:(NSRange)blockRange shortRange:(NSRange)shortRange {
	NSArray *components = [string captureComponentsMatchedByRegex:self.components.bugSectionRegex];
	if ([components count] == 0) return NO;
	
	// Get data from captures. Index 1 is directive, index 2 description text.
	NSString *directive = [components objectAtIndex:1];
	NSString *description = [components objectAtIndex:2];
	GBLogDebug(@"- Registering bug block %@ at %@...", [description normalizedDescription], self.currentSourceInfo);
	[self registerShortDescriptionFromLines:lines range:shortRange removePrefix:directive];
	
	// Convert to markdown and register everything. We always use the whole text for directive.
	GBCommentComponent *component = [self commentComponentByPreprocessingString:description withFlags:0];
	component.stringValue = string;
	component.markdownValue = [self stringByConvertingLinesToBlockquoteFromString:component.markdownValue class:@"bug"];
	[self.currentComment.longDescription registerComponent:component];
	return YES;
}

- (BOOL)processParamBlockInString:(NSString *)string lines:(NSArray *)lines blockRange:(NSRange)blockRange shortRange:(NSRange)shortRange {
	NSArray *components = [string captureComponentsMatchedByRegex:self.components.parameterDescriptionRegex];
	if ([components count] == 0) return NO;
	
	// Get data from captures. Index 1 is directive, index 2 name, index 3 description text.
	NSString *name = [components objectAtIndex:2];
	NSString *description = [components objectAtIndex:3];
	NSRange range = [string rangeOfString:description];
	NSString *prefix = nil;
	if (range.location < [string length]) {
		prefix = [string substringToIndex:range.location];
	} else {
		prefix = @"";
	}
	
	GBLogDebug(@"- Registering parameter %@ description %@ at %@...", name, [description normalizedDescription], self.currentSourceInfo);
	[self reserveShortDescriptionFromLines:lines range:shortRange removePrefix:prefix];
	
	// Prepare object representation from the description and register the parameter to the comment.
	GBCommentArgument *argument = [GBCommentArgument argumentWithName:name sourceInfo:self.currentSourceInfo];
	GBCommentComponent *component = [self commentComponentByPreprocessingString:description withFlags:0];
	[argument.argumentDescription registerComponent:component];
	[self.currentComment.methodParameters addObject:argument];
	return YES;
}

- (BOOL)processExceptionBlockInString:(NSString *)string lines:(NSArray *)lines blockRange:(NSRange)blockRange shortRange:(NSRange)shortRange {
	NSArray *components = [string captureComponentsMatchedByRegex:self.components.exceptionDescriptionRegex];
	if ([components count] == 0) return NO;
	
	// Get data from captures. Index 1 is directive, index 2 name, index 3 description text.
	NSString *name = [components objectAtIndex:2];
	NSString *description = [components objectAtIndex:3];
	NSRange range = [string rangeOfString:description];
	NSString *prefix = nil;
	if (range.location < [string length]) {
		prefix = [string substringToIndex:range.location];
	} else {
		prefix = @"";
	}

	GBLogDebug(@"- Registering exception %@ description %@ at %@...", name, [description normalizedDescription], self.currentSourceInfo);
	[self reserveShortDescriptionFromLines:lines range:shortRange removePrefix:prefix];
	
	// Prepare object representation from the description and register the exception to the comment.
	GBCommentArgument *argument = [GBCommentArgument argumentWithName:name sourceInfo:self.currentSourceInfo];
	GBCommentComponent *component = [self commentComponentByPreprocessingString:description withFlags:0];
	[argument.argumentDescription registerComponent:component];
	[self.currentComment.methodExceptions addObject:argument];
	return YES;
}

- (BOOL)processAvailabilityBlockInString:(NSString *)string lines:(NSArray *)lines blockRange:(NSRange)blockRange shortRange:(NSRange)shortRange {
	NSArray *components = [string captureComponentsMatchedByRegex:self.components.availabilityRegex];
	if ([components count] == 0) return NO;
	
	// Get data from captures. Index 1 is directive, index 2 description text.
	NSString *description = [components count] >= 3 ? [components objectAtIndex:2] : @"";
	NSRange range = [string rangeOfString:description];
	NSString *prefix = nil;
	if (range.location < [string length]) {
		prefix = [string substringToIndex:range.location];
	} else {
		prefix = @"";
	}

	GBLogDebug(@"- Registering availability description %@ at %@...", [description normalizedDescription], self.currentSourceInfo);
	[self reserveShortDescriptionFromLines:lines range:shortRange removePrefix:prefix];
	
	// Prepare object representation from the description and register the result to the comment.
	GBCommentComponent *component = [self commentComponentByPreprocessingString:description withFlags:0];
	[self.currentComment.availability registerComponent:component];
	return YES;
}

- (BOOL)processDiscussionBlockInString:(NSString *)string lines:(NSArray *)lines blockRange:(NSRange)blockRange shortRange:(NSRange)shortRange {
	NSArray *components = [string captureComponentsMatchedByRegex:self.components.discussionRegex];
	if ([components count] == 0) return NO;
	
	// Get data from captures. Index 1 is directive, index 2 description text.
	NSString *description = [components objectAtIndex:3];
	NSRange range = [string rangeOfString:description];
	NSString *prefix = nil;
	if (range.location < [string length]) {
		prefix = [string substringToIndex:range.location];
	} else {
		prefix = @"";
	}
	
	GBLogDebug(@"- Registering discussion description %@ at %@...", [description normalizedDescription], self.currentSourceInfo);
	[self reserveShortDescriptionFromLines:lines range:shortRange removePrefix:prefix];
	
	// Prepare object representation from the description and register the result to the comment.
	GBCommentComponent *component = [self commentComponentByPreprocessingString:description withFlags:0];
	[self.currentComment.longDescription registerComponent:component];
	return YES;
}

- (BOOL)processAbstractBlockInString:(NSString *)string lines:(NSArray *)lines blockRange:(NSRange)blockRange shortRange:(NSRange)shortRange {
	NSArray *components = [string captureComponentsMatchedByRegex:self.components.abstractRegex];
	if ([components count] == 0) return NO;
	
	// Get data from captures. Index 1 is directive, index 2 description text.
	NSString *description = [components objectAtIndex:3];
	NSRange index;
	index = [description rangeOfString:@"@discussion"];
	
	if (index.location == NSNotFound) {
		index = [description rangeOfString:@"\\s+"];
	}
	
	NSRange range;
	@try {
		description = [description substringToIndex:index.location];
	}
	@catch (NSException *exception) {
		
	}
	@finally {
		range = [string rangeOfString:description];
	}
	NSString *prefix = nil;
	if (range.location < [string length]) {
		prefix = [string substringToIndex:range.location];
	} else {
		prefix = @"";
	}
	
	GBLogDebug(@"- Registering abstract description %@ at %@...", [description normalizedDescription], self.currentSourceInfo);
	[self reserveShortDescriptionFromLines:lines range:shortRange removePrefix:prefix];
	
	// Prepare object representation from the description and register the result to the comment.
	GBCommentComponent *component = [self commentComponentByPreprocessingString:description withFlags:0];
	self.currentComment.shortDescription = component;
	return YES;
}

- (BOOL)processReturnBlockInString:(NSString *)string lines:(NSArray *)lines blockRange:(NSRange)blockRange shortRange:(NSRange)shortRange {
	NSArray *components = [string captureComponentsMatchedByRegex:self.components.returnDescriptionRegex];
	if ([components count] == 0) return NO;
	
	// Get data from captures. Index 1 is directive, index 2 description text.
	NSString *description = [components objectAtIndex:2];
	NSRange range = [string rangeOfString:description];
	NSString *prefix = nil;
	if (range.location < [string length]) {
		prefix = [string substringToIndex:range.location];
	} else {
		prefix = @"";
	}

	GBLogDebug(@"- Registering return description %@ at %@...", [description normalizedDescription], self.currentSourceInfo);
	[self reserveShortDescriptionFromLines:lines range:shortRange removePrefix:prefix];
	
	// Prepare object representation from the description and register the result to the comment.
	GBCommentComponent *component = [self commentComponentByPreprocessingString:description withFlags:0];
	[self.currentComment.methodResult registerComponent:component];
	return YES;
}

- (BOOL)processRelatedBlockInString:(NSString *)string lines:(NSArray *)lines blockRange:(NSRange)blockRange shortRange:(NSRange)shortRange {
	NSArray *components = [string captureComponentsMatchedByRegex:self.components.relatedSymbolRegex];
	if ([components count] == 0) return NO;
	
	// Get data from captures. Index 1 is directive, index 2 reference.
	NSString *reference = [components objectAtIndex:2];
	NSRange range = [string rangeOfString:reference];
	NSString *prefix = nil;
	if (range.location < [string length]) {
		prefix = [string substringToIndex:range.location];
	} else {
		prefix = @"";
	}

	GBLogDebug(@"- Registering related symbol %@ at %@...", reference, self.currentSourceInfo);
	[self reserveShortDescriptionFromLines:lines range:shortRange removePrefix:prefix];
	
	// Convert to markdown and register everything. We use strict links mode. If the link is note recognized, warn and exit.
	NSString *markdown = [self stringByConvertingCrossReferencesInString:reference withFlags:GBProcessingFlagRelatedItem];
	if ([markdown isEqualToString:reference]) {
		GBLogXWarn(self.currentSourceInfo, @"Unknown cross reference %@ found at %@!", reference, self.currentSourceInfo);
		return YES;
	}
	
	// If known link is found, register component, otherwise warn and exit.
	GBCommentComponent *component = [self commentComponentWithStringValue:reference];
	component.markdownValue = markdown;
	component.relatedItem = self.lastReferencedObject;
	[self.currentComment.relatedItems registerComponent:component];
	return YES;
}

- (BOOL)isLineMatchingDirectiveStatement:(NSString *)string {
	if ([string isMatchedByRegex:self.components.discussionRegex]) return YES;
	if ([string isMatchedByRegex:self.components.abstractRegex]) return YES;
	if ([string isMatchedByRegex:self.components.noteSectionRegex]) return YES;
	if ([string isMatchedByRegex:self.components.warningSectionRegex]) return YES;
	if ([string isMatchedByRegex:self.components.bugSectionRegex]) return YES;
	if ([string isMatchedByRegex:self.components.deprecatedSectionRegex]) return YES;
	if ([string isMatchedByRegex:self.components.parameterDescriptionRegex]) return YES;
	if ([string isMatchedByRegex:self.components.exceptionDescriptionRegex]) return YES;
	if ([string isMatchedByRegex:self.components.returnDescriptionRegex]) return YES;
	if ([string isMatchedByRegex:self.components.availabilityRegex]) return YES;
	if ([string isMatchedByRegex:self.components.relatedSymbolRegex]) return YES;
	return NO;
}

#pragma mark Text processing methods

- (GBCommentComponent *)commentComponentByPreprocessingString:(NSString *)string withFlags:(GBProcessingFlag)flags {
	// Preprocesses the given string to markdown representation, and returns a new GBCommentComponent registered with both values. Flags specify various processing directives that affect how processing is handled.
	GBLogDebug(@"- Registering text block %@ at %@...", [string normalizedDescription], self.currentSourceInfo);
	GBCommentComponent *result = [self commentComponentWithStringValue:string];
	result.markdownValue = [self stringByPreprocessingString:string withFlags:flags];
	return result;
}

- (GBCommentComponent *)commentComponentWithStringValue:(NSString *)string {
	// Creates a new GBCommentComponents, assigns the given string as it's string value and assigns settings and currentSourceInfo. This is an entry point for all comment components creations; it makes sure all data is registered. But it doesn't do any processing!
	GBCommentComponent *result = [GBCommentComponent componentWithStringValue:string sourceInfo:self.currentSourceInfo];
	result.settings = self.settings;
	return result;
}

- (NSString *)stringByPreprocessingString:(NSString *)string withFlags:(GBProcessingFlag)flags {
	// Converts all appledoc formatting and cross refs to proper Markdown text suitable for passing to Markdown generator.
	if ([string length] == 0) return string;
	
	// Process all links separately, so that they won't be cut off if the contain _'s (which is a formatting marker)
	NSString *pattern = @"(\\[.+?\\]\\(.+?\\))";
	NSArray *components = [string arrayOfDictionariesByMatchingRegex:pattern withKeysAndCaptures:@"link", 1, nil];
	NSRange searchRange = NSMakeRange(0, [string length]);
	NSMutableString *result = [NSMutableString stringWithCapacity:[string length]];
	for (NSDictionary *component in components) {
		NSString *componentLink = [component objectForKey:@"link"];
		NSRange componentRange = [string rangeOfString:componentLink options:0 range:searchRange];

		if (componentRange.location > searchRange.location) {
			NSRange skippedRange = NSMakeRange(searchRange.location, componentRange.location - searchRange.location);
			NSString *skippedText = [string substringWithRange:skippedRange];
			NSString *preprocessedText = [self stringByPreprocessingNonLinkString:skippedText withFlags:flags];
			[result appendString:preprocessedText];
		}

		// Don't process the link using the formatting markers, might contain formatting markers
		NSString *convertedLink = [self stringByConvertingCrossReferencesInString:componentLink withFlags:flags];
		[result appendString:convertedLink];

		NSUInteger location = componentRange.location + [componentLink length];
		searchRange = NSMakeRange(location, [string length] - location);
	}

	// If there is some remaining text, preprocess it as well.
	if ([string length] > searchRange.location) {
		NSString *remainingText = [string substringWithRange:searchRange];
		NSString *preprocessedText = [self stringByPreprocessingNonLinkString:remainingText withFlags:flags];
		[result appendString:preprocessedText];
	}

	// Finally replace all embedded code span Markdown links to proper ones. Embedded links look like: `[`desc`](address)`.
	NSString *regex = [NSString stringWithFormat:@"`((?:%@)?\\[`[^`]*`\\]\\(.+?\\)(?:%@)?)`", self.components.codeSpanStartMarker, self.components.codeSpanEndMarker];
	NSString *clean = [result stringByReplacingOccurrencesOfRegex:regex usingBlock:^NSString *(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
		return capturedStrings[1];
	}];
	return clean;
}

- (NSString *)stringByPreprocessingNonLinkString:(NSString *)string withFlags:(GBProcessingFlag)flags {
	// Converts all appledoc formatting and cross refs to proper Markdown text suitable for passing to Markdown generator.
	if ([string length] == 0) return string;

	// Formatting markers are fine, except *, which should be converted to **. To simplify cross refs detection, we handle all possible formatting markers though so we can search for cross refs within "clean" formatted text, without worrying about markers interfering with search. Note that we also handle "standard" Markdown nested formats and bold markers here, so that we properly handle cross references within.
	NSString *pattern = @"(?s:(\\*__|__\\*|\\*\\*_|_\\*\\*|\\*\\*\\*|___|\\*_|_\\*|\\*\\*|__|\\*|_|==!!==|`)(.+?)\\1)";
	NSArray *components = [string arrayOfDictionariesByMatchingRegex:pattern withKeysAndCaptures:@"marker", 1, @"value", 2, nil];
	NSRange searchRange = NSMakeRange(0, [string length]);
	NSMutableString *result = [NSMutableString stringWithCapacity:[string length]];
	for (NSDictionary *component in components) {
		// Find marker range within the remaining text. Note that we don't test for marker not found, as this shouldn't happen...
		NSString *componentMarker = [component objectForKey:@"marker"];
		NSString *componentText = [component objectForKey:@"value"];
		NSRange markerRange = [string rangeOfString:componentMarker options:0 range:searchRange];
		
		// If we skipped some text, convert all cross refs in it and append to the result.
		if (markerRange.location > searchRange.location) {
			NSRange skippedRange = NSMakeRange(searchRange.location, markerRange.location - searchRange.location);
			NSString *skippedText = [string substringWithRange:skippedRange];
			NSString *convertedText = [self stringByConvertingCrossReferencesInString:skippedText withFlags:flags];
			[result appendString:convertedText];
		}
		
		// Convert the marker to proper Markdown style. Warn if unknown marker is found. This is just a precaution in case we change something above, but forget to update this part, shouldn't happen in released versions as it should get caught by unit tests...
		GBProcessingFlag linkFlags = flags;
		NSString *markdownStartMarker = @"";
		NSString *markdownEndMarker = nil;
		if ([componentMarker isEqualToString:@"*"]) {
			if (self.settings.useSingleStarForBold) {
				GBLogDebug(@"  - Found '%@' formatted as bold at %@...", [componentText normalizedDescription], self.currentSourceInfo);
				markdownStartMarker = [NSString stringWithFormat:@"**%@", self.components.appledocBoldStartMarker];
				markdownEndMarker = [NSString stringWithFormat:@"%@**", self.components.appledocBoldEndMarker];
			} else {
				markdownStartMarker = componentMarker;
			}
		}
		else if ([componentMarker isEqualToString:@"_"]) {
			GBLogDebug(@"  - Found '%@' formatted as italics at %@...", [componentText normalizedDescription], self.currentSourceInfo);
			markdownStartMarker = @"_";
		}
		else if ([componentMarker isEqualToString:@"`"]) {
			GBLogDebug(@"  - Found '%@' formatted as code at %@...", [componentText normalizedDescription], self.currentSourceInfo);
			markdownStartMarker = @"`";
			linkFlags |= GBProcessingFlagEmbedMarkdownLink;
		}
		else if ([componentMarker isEqualToString:@"**"] || [componentMarker isEqualToString:@"__"] || [componentMarker isEqualToString:@"*_"] || [componentMarker isEqualToString:@"_*"]) {
			GBLogDebug(@"  - Found '%@' formatted as bold at %@...", [componentText normalizedDescription], self.currentSourceInfo);
			markdownStartMarker = componentMarker;
		}
		else if ([componentMarker isEqualToString:@"*__"] || [componentMarker isEqualToString:@"__*"] || [componentMarker isEqualToString:@"**_"] || [componentMarker isEqualToString:@"_**"] || [componentMarker isEqualToString:@"***"] || [componentMarker isEqualToString:@"___"]) {
			GBLogDebug(@"  - Found '%@' formatted as italics/bold at %@...", [componentText normalizedDescription], self.currentSourceInfo);
			markdownStartMarker = componentMarker;
		}
		else if (self.settings.warnOnUnknownDirective) {
			GBLogXWarn(self.currentSourceInfo, @"Unknown format marker %@ detected at %@!", componentMarker, self.currentSourceInfo);
		}
		if (!markdownEndMarker) markdownEndMarker = markdownStartMarker;
		
		// Get formatted text, convert it's cross references and append proper format markers and string to result.
		NSString *convertedText = [self stringByConvertingCrossReferencesInString:componentText withFlags:linkFlags];
		[result appendString:markdownStartMarker];
		[result appendString:convertedText];
		[result appendString:markdownEndMarker];
		
		// Prepare next search range.
		NSUInteger location = markerRange.location + markerRange.length * 2 + [componentText length];
		searchRange = NSMakeRange(location, [string length] - location);
	}
	
	// If there is some remaining text, process it for cross references and append to result.
	if ([string length] > searchRange.location) {
		NSString *remainingText = [string substringWithRange:searchRange];
		NSString *convertedText = [self stringByConvertingCrossReferencesInString:remainingText withFlags:flags];
		[result appendString:convertedText];
	}
	
	return result;
}

- (NSString *)stringByConvertingCrossReferencesInString:(NSString *)string withFlags:(GBProcessingFlag)flags {
	// Preprocesses the given string and converts all cross references and URLs to Markdown style - [](). This is the high level method for cross references processing; it works by first detecting existing Markdown sytax links, then processing the string before and after them separately for "simple", Appledoc, cross references. Existing Markdown addresses are also processed for cross refs to registered entities. This is continues until end of string is reached.
	GBLogDebug(@"  - Converting cross references in '%@'...", [string normalizedDescription]);
	NSMutableString *result = [NSMutableString stringWithCapacity:[string length]];
	NSRange searchRange = NSMakeRange(0, [string length]);
	self.lastReferencedObject = nil;
	while (YES) {
		// Find next Markdown style link, and use the first one found or exit if none found - we'll process remaining text later on.
		GBCrossRefData *markdownLinkData = [self dataForFirstMarkdownInlineLinkInString:string searchRange:searchRange flags:flags];
		GBCrossRefData *markdownRefData = [self dataForFirstMarkdownReferenceLinkInString:string searchRange:searchRange flags:flags];
		GBCrossRefData *markdownData = nil;
        if (markdownLinkData && markdownRefData) {
            if ([markdownLinkData compareLocation:markdownRefData] == NSOrderedAscending)
                markdownData = markdownLinkData;
            else
                markdownData = markdownRefData;
        } else if (markdownLinkData)
            markdownData = markdownLinkData;
        else if (markdownRefData)
            markdownData = markdownRefData;
        else
            break;
		
		// Now that we have Markdown syntax link, preprocess the string from the last position to the start of Markdown link.
		if (markdownData.range.location > searchRange.location) {
			NSRange convertRange = NSMakeRange(searchRange.location, markdownData.range.location - searchRange.location);
			NSString *skipped = [self stringByConvertingSimpleCrossReferencesInString:string searchRange:convertRange flags:flags];
			[result appendString:skipped];
		}
		
		// Process Markdown link's address if it's a known object.
		NSRange addressRange = NSMakeRange(0, [markdownData.address length]);
		GBProcessingFlag markdownFlags = flags | GBProcessingFlagMarkdownLink;
		NSString *markdownAddress = [self stringByConvertingSimpleCrossReferencesInString:markdownData.address searchRange:addressRange flags:markdownFlags];
		[result appendFormat:markdownData.description, markdownAddress];
		
		// Process the remaining string or exit if we're done.
		searchRange.location = markdownData.range.location + markdownData.range.length;
		searchRange.length = [string length] - searchRange.location;
		if (searchRange.location >= [string length]) break;
	}
	
	// Process remaining text for simple links if necessary.
	if (searchRange.location < [string length]) {
		NSString *remaining = [self stringByConvertingSimpleCrossReferencesInString:string searchRange:searchRange flags:flags];
		[result appendString:remaining];
	}
	return result;
}

- (NSString *)stringByConvertingSimpleCrossReferencesInString:(NSString *)string searchRange:(NSRange)searchRange flags:(GBProcessingFlag)flags {
	// Processes the given range of the given string for any "simple", Appledoc, cross reference and returns new string with all cross references converted to Markdown syntax. GBInsideMarkdownLink flag specifies whether we're handling string inside existing Markdown link; in such case we only test for link at the start of the string and return address only instead of the Markdown syntax.
	NSMutableString *result = [NSMutableString stringWithCapacity:[string length]];
    NSMutableArray *links = [NSMutableArray array];
	NSUInteger lastUsedLocation = searchRange.location;
	NSUInteger searchEndLocation = searchRange.location + searchRange.length;
	BOOL isInsideMarkdown = (flags & GBProcessingFlagMarkdownLink) > 0;
	while (YES) {
		// Find all cross references
		GBCrossRefData *urlData = [self dataForURLLinkInString:string searchRange:searchRange flags:flags];
		GBCrossRefData *objectData = [self dataForClassOrProtocolLinkInString:string searchRange:searchRange flags:flags];
		GBCrossRefData *categoryData = [self dataForCategoryLinkInString:string searchRange:searchRange flags:flags];
		GBCrossRefData *localMemberData = [self dataForLocalMemberLinkInString:string searchRange:searchRange flags:flags];
		GBCrossRefData *remoteMemberData = [self dataForRemoteMemberLinkInString:string searchRange:searchRange flags:flags];
        GBCrossRefData *constantData = [self dataForConstantLinkInString:string searchRange:searchRange flags:flags];
        GBCrossRefData *blockData = [self dataForBlockLinkInString:string searchRange:searchRange flags:flags];
		GBCrossRefData *documentData = [self dataForDocumentLinkInString:string searchRange:searchRange flags:flags];
		
		// If we find class or protocol link at the same location as category, ignore class/protocol. This prevents marking text up to open parenthesis being converted to a class/protocol where in fact it's category. The same goes for remote member data!
		if ([objectData isInsideCrossRef:categoryData]) objectData = nil;
        if ([objectData isInsideCrossRef:remoteMemberData]) objectData = nil;
		if ([categoryData isInsideCrossRef:remoteMemberData]) categoryData = nil;
        
        // Do the same for a URL inside a method call
        if ([urlData isInsideCrossRef:localMemberData]) urlData = nil;
        if ([urlData isInsideCrossRef:remoteMemberData]) urlData = nil;
		
		// Prevent forming cross reference to current top-level object. Also prevent forming cross reference to current member.
		if ([objectData matchesObject:self.currentContext]) objectData = nil;
		if ([categoryData matchesObject:self.currentContext]) categoryData = nil;
		if ([localMemberData matchesObject:self.currentObject]) localMemberData = nil;
		if ([constantData matchesObject:self.currentObject]) constantData = nil;
        if ([blockData matchesObject:self.currentObject]) blockData = nil;
        
		// Add objects to handler array. Note that we don't add class/protocol if category is found on the same index! If no link was found, proceed with next char. If there's no other word, exit (we'll deal with remaining text later on).
		if (urlData) [links addObject:urlData];
		if (objectData) [links addObject:objectData];
		if (categoryData) [links addObject:categoryData];
		if (localMemberData) [links addObject:localMemberData];
		if (remoteMemberData) [links addObject:remoteMemberData];
        if (constantData) [links addObject:constantData];
        if (blockData) [links addObject:blockData];
		if (documentData) [links addObject:documentData];
		if ([links count] == 0) {
			if (isInsideMarkdown) return string;
			if (searchRange.location >= [string length] - 1) break;
			searchRange.location++;
			searchRange.length--;
			if (searchRange.length == 0) break;
			continue;
		}
        
		// Handle all the links starting at the lowest one, adding proper Markdown syntax for each.
		while ([links count] > 0) {
			// Find the lowest index.
			GBCrossRefData *linkData = nil;
			NSUInteger index = NSNotFound;
			for (NSUInteger i=0; i<[links count]; i++) {
				GBCrossRefData *data = [links objectAtIndex:i];
				if (!linkData || linkData.range.location > data.range.location) {
					linkData = data;
					index = i;
				}
			}
            			
			// If there is some text skipped after previous link (or search range), append it to output first.
			if (linkData && linkData.range.location > lastUsedLocation) {
				NSRange skippedRange = NSMakeRange(lastUsedLocation, linkData.range.location - lastUsedLocation);
				NSString *skippedText = [string substringWithRange:skippedRange];
                //NSLog(@"adding skipped text to result : %@", skippedText);
				[result appendString:skippedText];
			}
			
			// Convert the raw link to Markdown syntax and append to output.
            if(linkData) {
                NSString *markdownLink = isInsideMarkdown ? linkData.address : linkData.markdown;
                [result appendString:markdownLink];
            }
            
			// Update range and remove the link from the temporary array.
			NSUInteger location = linkData ? linkData.range.location + linkData.range.length : 0;
			searchRange.location = location;
			searchRange.length = searchEndLocation - location;
			lastUsedLocation = location;
			[links removeObjectAtIndex:index];
		}
		
		// Exit if there's nothing more to process.
		if (searchRange.location >= searchEndLocation) break;
	}

	// If there's some text remaining after all links, append it.
	if (!isInsideMarkdown && lastUsedLocation < searchEndLocation) {
		NSRange remainingRange = NSMakeRange(lastUsedLocation, searchEndLocation - lastUsedLocation);
		NSString *remainingText = [string substringWithRange:remainingRange];
		[result appendString:remainingText];
	}
	return result;
}

- (NSString *)markdownLinkWithDescription:(NSString *)description address:(NSString *)address flags:(GBProcessingFlag)flags {
	// Creates Markdown inline style link using the given components. This should be used when converting text to Markdown links as it will prepare special format so that we can later properly format links embedded in code spans!
	NSString *result = nil;
	if ((flags & GBProcessingFlagEmbedMarkdownLink) > 0)
		result = [NSString stringWithFormat:@"[`%@`](%@)", description, address];
	else
		result = [NSString stringWithFormat:@"[%@](%@)", description, address];
	return [self.settings stringByEmbeddingCrossReference:result];
}

- (NSString *)stringByConvertingLinesToBlockquoteFromString:(NSString *)string class:(NSString *)className {
	// Converts the given string into blockquote and optionally adds class name to convert to <div>.
	NSMutableString *result = [NSMutableString stringWithCapacity:[string length]];
	if ([className length] > 0) [result appendFormat:@"> %%%@%%\n", className];
	NSArray *lines = [string arrayOfLines];
	[lines enumerateObjectsUsingBlock:^(NSString *line, NSUInteger idx, BOOL *stop) {
		NSString *class = @"";
		if (self.settings.printInformationBlockTitles && 0 == idx && [className length] > 0) {
			class = [NSString stringWithFormat:@"**%@:** ", [className capitalizedString]];
		}
		[result appendFormat:@"> %@%@", class, line];
		if (idx < [lines count] - 1) [result appendString:@"\n"];
	}];
	return result;
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

#pragma mark Cross references detection

- (GBCrossRefData *)dataForClassOrProtocolLinkInString:(NSString *)string searchRange:(NSRange)searchRange flags:(GBProcessingFlag)flags {
	// Matches the first class or protocol cross reference in the given search range of the given string. if found, link data otherwise empty data is returned.
	BOOL templated = (flags & GBProcessingFlagRelatedItem) == 0;
	NSString *regex = [self.components objectCrossReferenceRegex:templated];
	NSArray *components = [string captureComponentsMatchedByRegex:regex range:searchRange];
	if ([components count] == 0) return nil;
    
	// Get link components. Index 0 contains full text, including optional template prefix/suffix, index 1 just the object name.
	NSString *linkText = [components objectAtIndex:0];
	NSString *objectName = [components objectAtIndex:1];
	
	// Validate object name with a class or protocol.
	id referencedObject = [self.store classWithName:objectName];
	if (!referencedObject) referencedObject = [self.store protocolWithName:objectName];
	if (!referencedObject) return nil;
	self.lastReferencedObject = referencedObject;
	
	// Create link data and return.
    GBCrossRefData *result = [GBCrossRefData crossRefData];
	result.range = [string rangeOfString:linkText options:0 range:searchRange];
	result.address = [self.settings htmlReferenceForObject:referencedObject fromSource:self.currentContext];
	result.description = objectName;
	result.markdown = [self markdownLinkWithDescription:result.description address:result.address flags:flags];
	return result;
}

- (GBCrossRefData *)dataForCategoryLinkInString:(NSString *)string searchRange:(NSRange)searchRange flags:(GBProcessingFlag)flags {
	// Matches the first category cross reference in the given search range of the given string. if found, link data otherwise empty data is returned.
	BOOL templated = (flags & GBProcessingFlagRelatedItem) == 0;
	NSString *regex = [self.components categoryCrossReferenceRegex:templated];
	NSArray *components = [string captureComponentsMatchedByRegex:regex range:searchRange];
	if ([components count] == 0) return nil;

	// Get link components. Index 0 contains full text, including optional template prefix/suffix, index 1 just the object name.
	NSString *linkText = [[components objectAtIndex:0] stringByTrimmingWhitespaceAndNewLine];
	NSString *objectName = [[components objectAtIndex:1] stringByTrimmingWhitespaceAndNewLine];
	
	// Validate object name with a class or protocol.
	id referencedObject = [self.store categoryWithName:objectName];
	if (!referencedObject) return nil;
	self.lastReferencedObject = referencedObject;

	// Create link data and return.
    GBCrossRefData *result = [GBCrossRefData crossRefData];
	result.range = [string rangeOfString:linkText options:0 range:searchRange];
	result.address = [self.settings htmlReferenceForObject:referencedObject fromSource:self.currentContext];
	result.description = objectName;
	result.markdown = [self markdownLinkWithDescription:result.description address:result.address flags:flags];
	return result;
}

- (GBCrossRefData *)dataForConstantLinkInString:(NSString *)string searchRange:(NSRange)searchRange flags:(GBProcessingFlag)flags {
    BOOL templated = (flags & GBProcessingFlagRelatedItem) == 0;
	NSString *regex = [self.components objectCrossReferenceRegex:templated];
	NSArray *components = [string captureComponentsMatchedByRegex:regex range:searchRange];
	if ([components count] == 0) return nil;
    
	// Get link components. Index 0 contains full text, including optional template prefix/suffix, index 1 just the object name.
	NSString *linkText = [components objectAtIndex:0];
	NSString *objectName = [components objectAtIndex:1];
	
	// Validate object name with a class or protocol.
	id referencedObject = [self.store typedefEnumWithName:objectName];
	if (!referencedObject) return nil;
	self.lastReferencedObject = referencedObject;
	
	// Create link data and return.
    GBCrossRefData *result = [GBCrossRefData crossRefData];
	result.range = [string rangeOfString:linkText options:0 range:searchRange];
	result.address = [self.settings htmlReferenceForObject:referencedObject fromSource:self.currentContext];
	result.description = objectName;
	result.markdown = [self markdownLinkWithDescription:result.description address:result.address flags:flags];
	return result;
}

- (GBCrossRefData *)dataForBlockLinkInString:(NSString *)string searchRange:(NSRange)searchRange flags:(GBProcessingFlag)flags {
    BOOL templated = (flags & GBProcessingFlagRelatedItem) == 0;
    NSString *regex = [self.components objectCrossReferenceRegex:templated];
    NSArray *components = [string captureComponentsMatchedByRegex:regex range:searchRange];
    if ([components count] == 0) return nil;
    
    // Get link components. Index 0 contains full text, including optional template prefix/suffix, index 1 just the object name.
    NSString *linkText = [components objectAtIndex:0];
    NSString *objectName = [components objectAtIndex:1];
    
    // Validate object name with a class or protocol.
    id referencedObject = [self.store typedefBlockWithName:objectName];
    if (!referencedObject) return nil;
    self.lastReferencedObject = referencedObject;
    
    // Create link data and return.
    GBCrossRefData *result = [GBCrossRefData crossRefData];
    result.range = [string rangeOfString:linkText options:0 range:searchRange];
    result.address = [self.settings htmlReferenceForObject:referencedObject fromSource:self.currentContext];
    result.description = objectName;
    result.markdown = [self markdownLinkWithDescription:result.description address:result.address flags:flags];
    return result;
}

- (GBCrossRefData *)dataForLocalMemberLinkInString:(NSString *)string searchRange:(NSRange)searchRange flags:(GBProcessingFlag)flags {
	// Matches the first local member cross reference in the given search range of the given string. if found, link data otherwise empty data is returned.
	if (!self.currentContext) return nil;

	BOOL templated = (flags & GBProcessingFlagRelatedItem) == 0;
	NSString *regex = [self.components localMemberCrossReferenceRegex:templated];
	NSArray *components = [string captureComponentsMatchedByRegex:regex range:searchRange];
	if ([components count] == 0) return nil;
		
	// Get link components. Index 0 contains full text, including optional template prefix/suffix, index 1 optional prefix, index 2 selector.
	NSString *linkText = [components objectAtIndex:0];
	NSString *selector = [components objectAtIndex:2];
	
	// Validate selected within current context.
    // can we grab method data?
    if(! [[self currentContext] respondsToSelector:@selector(methods)])
    {
        return nil;
    }
	GBMethodData *referencedObject = [[[self currentContext] methods] methodBySelector:selector];
	if (!referencedObject) return nil;
	self.lastReferencedObject = referencedObject;
	
	// If we're creating link for related item, we should use method prefix.	
	if ((flags & GBProcessingFlagRelatedItem) > 0 && self.settings.prefixLocalMembersInRelatedItemsList) selector = referencedObject.prefixedMethodSelector;
	
	// If this is copied comment, we need to prepare "universal" relative path even if used in local object. As the comment was copied to other objects, we don't know where it will point to, so we need to make it equally usable in the secondary object(s). Note that this code assumes copied comments can only be used for top-level objects so we simplify stuff a bit.
	NSString *address = [self.settings htmlReferenceForObject:referencedObject fromSource:referencedObject.parentObject];
	if (self.currentComment.isCopied) {
		NSString *descendPath = [self.settings htmlRelativePathToIndexFromObject:referencedObject.parentObject];
		NSString *path = [self.settings htmlReferenceForObjectFromIndex:referencedObject.parentObject];
		NSString *prefix = [descendPath stringByAppendingPathComponent:path];
		address = [prefix stringByAppendingString:address];
	}

	// Create link data and return.
    GBCrossRefData *result = [GBCrossRefData crossRefData];
	result.range = [string rangeOfString:linkText options:0 range:searchRange];
	result.address = address;
	result.description = selector;
	result.markdown = [self markdownLinkWithDescription:result.description address:result.address flags:flags];
	return result;
}

- (GBCrossRefData *)dataForRemoteMemberLinkInString:(NSString *)string searchRange:(NSRange)searchRange flags:(GBProcessingFlag)flags {
	// Matches the first remote member cross reference in the given search range of the given string. if found, link data otherwise empty data is returned.
	BOOL templated = (flags & GBProcessingFlagRelatedItem) == 0;
	NSString *regex = [self.components remoteMemberCrossReferenceRegex:templated];
	NSArray *components = [string captureComponentsMatchedByRegex:regex range:searchRange];
	if ([components count] == 0) return nil;
	
	// Get link components. Index 0 contains full text, including optional template prefix/suffix, index 1 optional prefix, index 2 object name, index 3 selector.
	NSString *linkText = [components objectAtIndex:0];
    NSString *linkDisplayText = [components objectAtIndex:1];
	NSString *objectName = [components objectAtIndex:2];
	NSString *selector = [components objectAtIndex:3];
    if( [components count] > 5 ) {
        if( [linkDisplayText length] < 2 ) {
            linkDisplayText = [components objectAtIndex:4];
        }
        if( [objectName length] == 0 ) {
            objectName = [components objectAtIndex:5];
        }
        if( [selector length] == 0 ) {
            selector = [components objectAtIndex:6];
        }
    }
    
    GBCrossRefData *result = [GBCrossRefData crossRefData];
	
	// Match object name with one of the known objects. Warn if not found. Note that we mark the result so that we won't be searching the range for other links.
	id referencedObject = [self.store classWithName:objectName];
	if (!referencedObject) {
		referencedObject = [self.store categoryWithName:objectName];
		if (!referencedObject) {
			referencedObject = [self.store protocolWithName:objectName];
			if (!referencedObject) {
				if (self.settings.warnOnInvalidCrossReference) GBLogXWarn(self.currentSourceInfo, @"Invalid %@ reference found near %@, unknown object : %@ !", linkText, self.currentSourceInfo, objectName);
				result.range = [string rangeOfString:linkText options:0 range:searchRange];
				result.markdown = [NSString stringWithFormat:@"[%@ %@]", objectName, selector];
				return result;
			}
		}
	}
	
	// Ok, so we've found a reference to an object, now search for the member. If not found, warn and return. Note that we mark the result so that we won't be searching the range for other links.
	id referencedMember = [[referencedObject methods] methodBySelector:selector];
	if (!referencedMember) {
		if (self.settings.warnOnInvalidCrossReference) GBLogXWarn(self.currentSourceInfo, @"Invalid %@ reference found near %@, unknown method!", linkText, self.currentSourceInfo);
		result.range = [string rangeOfString:linkText options:0 range:searchRange];
		result.markdown = [NSString stringWithFormat:@"[%@ %@]", objectName, selector];
		return result;
	}
	self.lastReferencedObject = referencedMember;
	
	// Create link data and return.
	result.range = [string rangeOfString:linkText options:0 range:searchRange];
	result.address = [self.settings htmlReferenceForObject:referencedMember fromSource:self.currentContext];
    if( [linkDisplayText length] > 1 )
    {
        result.description = linkDisplayText;
    }
    else
    {
        result.description = [NSString stringWithFormat:@"[%@ %@]", objectName, selector];
    }
	result.markdown = [self markdownLinkWithDescription:result.description address:result.address flags:flags];
	return result;
}

- (GBCrossRefData *)dataForDocumentLinkInString:(NSString *)string searchRange:(NSRange)searchRange flags:(GBProcessingFlag)flags {
	// Matches the first document cross reference in the given search range of the given string. if found, link data otherwise empty data is returned.
	BOOL templated = (flags & GBProcessingFlagRelatedItem) == 0;
	NSString *regex = [self.components documentCrossReferenceRegex:templated];
	NSArray *components = [string captureComponentsMatchedByRegex:regex range:searchRange];
	if ([components count] == 0) return nil;
	
	// Get link components. Index 0 contains full text, index 1 document name.
	NSString *linkText = [components objectAtIndex:0];
	NSString *documentName = [components objectAtIndex:1];
	
	// Validate selected within current context.
	GBDocumentData *referencedDocument = [self.store documentWithName:documentName];
	if (!referencedDocument) return nil;
	self.lastReferencedObject = referencedDocument;
	
	// Create link data and return.
    GBCrossRefData *result = [GBCrossRefData crossRefData];
	result.range = [string rangeOfString:linkText options:0 range:searchRange];
	result.address = [self.settings htmlReferenceForObject:referencedDocument fromSource:self.currentContext];
	result.description = documentName;
	result.markdown = [self markdownLinkWithDescription:result.description address:result.address flags:flags];
	return result;
}

- (GBCrossRefData *)dataForURLLinkInString:(NSString *)string searchRange:(NSRange)searchRange flags:(GBProcessingFlag)flags {
	// Matches the first URL cross reference in the given search range of the given string. if found, link data otherwise empty data is returned.
	BOOL templated = (flags & GBProcessingFlagRelatedItem) == 0;
	NSString *regex = [self.components urlCrossReferenceRegex:templated];
	NSArray *components = [string captureComponentsMatchedByRegex:regex range:searchRange];
	if ([components count] == 0) return nil;
	
	// Get link components. Index 0 contains full text, including optional template prefix/suffix, index 1 just the URL address. Remove mailto from description.
	NSString *linkText = [components objectAtIndex:0];
	NSString *address = [components objectAtIndex:1];
	NSString *description = [address hasPrefix:@"mailto:"] ? [address substringFromIndex:7] : address;
	
	// Create link item, prepare range and return.
    GBCrossRefData *result = [GBCrossRefData crossRefData];
	result.range = [string rangeOfString:linkText options:0 range:searchRange];
	result.address = address;
	result.description = description;
	result.markdown = [self markdownLinkWithDescription:result.description address:result.address flags:flags];
	return result;
}

- (GBCrossRefData *)dataForFirstMarkdownInlineLinkInString:(NSString *)string searchRange:(NSRange)searchRange flags:(GBProcessingFlag)flags {
	// Matches the first markdown inline link in the given range of the given string. if found, link data otherwise empty data is returned.
	NSArray *components = [string captureComponentsMatchedByRegex:self.components.markdownInlineLinkRegex range:searchRange];
	if ([components count] == 0) return nil;
	
	// Get link components. Index 0 contains full text, index 1 description without brackets, index 2 the address, index 3 optional title.
	NSString *linkText = [components objectAtIndex:0];
	NSString *description = [components objectAtIndex:1];
	NSString *address = [components objectAtIndex:2];
	NSString *title = [components objectAtIndex:3];
	if ([title length] > 0) title = [NSString stringWithFormat:@" \"%@\"", title];
	
	// Create link item, prepare range and return.
    GBCrossRefData *result = [GBCrossRefData crossRefData];
	result.range = [string rangeOfString:linkText options:0 range:searchRange];
	result.address = address;
	result.description = [self markdownLinkWithDescription:description address:[NSString stringWithFormat:@"%%@%@", title] flags:flags];
	result.markdown = linkText;
	return result;
}

- (GBCrossRefData *)dataForFirstMarkdownReferenceLinkInString:(NSString *)string searchRange:(NSRange)searchRange flags:(GBProcessingFlag)flags {
	// Matches the first markdown reference link in the given range of the given string. If found, link data otherwise empty data is returned.
	NSArray *components = [string captureComponentsMatchedByRegex:self.components.markdownReferenceLinkRegex range:searchRange];
	if ([components count] == 0) return nil;
	
	// Get link components. Index 0 contains full text, index 1 reference ID, index 2 address, index 3 optional title.
	NSString *linkText = [components objectAtIndex:0];
	NSString *reference = [components objectAtIndex:1];
	NSString *address = [components objectAtIndex:2];
	NSString *title = [components objectAtIndex:3];
	if ([title length] > 0) title = [NSString stringWithFormat:@" \"%@\"", title];

	// Create link item, prepare range and return.
    GBCrossRefData *result = [GBCrossRefData crossRefData];
	result.range = [string rangeOfString:linkText options:0 range:searchRange];
	result.address = address;
	result.description = [NSString stringWithFormat:@"[%@]: %%@%@", reference, title];
	result.markdown = linkText;
	return result;
}

#pragma mark Properties

- (GBCommentComponentsProvider *)components {
	return self.settings.commentComponents;
}

@synthesize lastReferencedObject;
@synthesize reservedShortDescriptionData;
@synthesize alwaysRepeatFirstParagraph;
@synthesize currentSourceInfo;
@synthesize currentComment;
@synthesize currentObject;
@synthesize currentContext;
@synthesize settings;
@synthesize store;

@end
