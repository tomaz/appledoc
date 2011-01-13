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

- (void)processCommentBlockInLines:(NSArray *)lines blockRange:(NSRange)range;
- (BOOL)registerBugBlockFromLines:(NSArray *)lines;
- (void)registerTextFromStringToCurrentParagraph:(NSString *)string;
- (NSArray *)arrayOfTextAndLinkItemsFromString:(NSString *)string;
- (void)registerParagraphItemToCurrentParagraph:(GBParagraphItem *)item;
- (BOOL)findCommentBlockInLines:(NSArray *)lines blockRange:(NSRange *)range;

@property (retain) NSMutableArray *paragraphsStack;
@property (retain) GBComment *currentComment;
@property (retain) id<GBObjectDataProviding> currentContext;

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
	self.paragraphsStack = [NSMutableArray array];
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

- (void)processCommentBlockInLines:(NSArray *)lines blockRange:(NSRange)range {
	// The given range is guaranteed to point to actual block within the lines array, so we only need to determine the kind of block and how to handle it.
	NSArray *block = [lines subarrayWithRange:range];
	self.currentStartLine = self.currentComment.sourceInfo.lineNumber + range.location;
	if ([self registerBugBlockFromLines:block]) return;
}

#pragma mark Comment blocks processing

- (BOOL)registerBugBlockFromLines:(NSArray *)lines {
	// Bug block is a GBParagraphSpecialItem containing one or more GBParagraph items.
	if (![[lines firstObject] isMatchedByRegex:self.components.bugSectionRegex]) return NO;
	
	// Get the description and warn if empty text was found (we still return YES as the block was properly detected as @bug.
	NSString *string = [NSString stringByCombiningLines:lines delimitWith:@"\n"];
	NSString *description = [string stringByMatching:self.components.bugSectionRegex capture:1];
	if ([description length] == 0) {
 		GBLogWarn(@"Empty @bug block found in %@!", self.sourceFileInfo);
		return YES;
	}
	
	// Prepare paragraph item by setting up it's description paragraph, split the string into items and register all items to paragraph. Note that this code effectively ends block paragraph here, so any subsequent block will be added to current paragraph instead. This allows @bug blocks being written anywhere in the documentation, but prevents having more than one paragraph within.
	GBParagraphSpecialItem *item = [GBParagraphSpecialItem specialItemWithType:GBSpecialItemTypeBug stringValue:description];
	[self.paragraphsStack push:[GBCommentParagraph paragraph]];	
	[self registerTextFromStringToCurrentParagraph:string];
	[item registerParagraph:[self.paragraphsStack peek]];
	[self.paragraphsStack pop];
	
	// Register block item to current paragraph; create new one if necessary.
	[self registerParagraphItemToCurrentParagraph:item];
	return YES;
}

#pragma mark Comment text processing

- (void)registerTextFromStringToCurrentParagraph:(NSString *)string {
	// Registers the text from the given string to last paragraph. Text is converted to an array of GBParagraphTextItem, GBParagraphLinkItem and GBParagraphDecoratorItem objects. WARNING: The client is responsible for adding proper paragraph to the stack!
	NSString *simplified = [string stringByReplacingOccurrencesOfRegex:@"(\\*_|_\\*)" withString:@"=!="];
	NSArray *components = [simplified arrayOfDictionariesByMatchingRegex:@"(?s:(\\*|_|=!=|`)(.*?)\\1)" withKeysAndCaptures:@"type", 1, @"value", 2, nil];
	GBCommentParagraph *paragraph = [self.paragraphsStack peek];
	__block NSRange search = NSMakeRange(0, [simplified length]);
	[components enumerateObjectsUsingBlock:^(NSDictionary *component, NSUInteger idx, BOOL *stop) {
		// Get range of next formatted section. If not found, exit (we'll deal with remaining text after the loop).
		NSString *type = [component objectForKey:@"type"];
		NSRange range = [simplified rangeOfString:type options:0 range:search];
		if (range.location == NSNotFound) return;
		
		// If we skipped some text, add it before handling formatted part!
		if (range.location > search.location) {
			NSRange skippedRange = NSMakeRange(search.location, range.location - search.location);
			NSString *skippedText = [simplified substringWithRange:skippedRange];
			NSArray *skippedItems = [self arrayOfTextAndLinkItemsFromString:skippedText];
			[skippedItems enumerateObjectsUsingBlock:^(GBParagraphItem *item, NSUInteger idx, BOOL *stop) {
				[paragraph registerItem:item];
			}];
		}

		// Get formatted text and prepare properly decorated component. Note that we warn the user if we find unknown decorator type (this probably just means we changed some decorator value by forgot to change this part, so it's some sort of "exception" catching).
		NSString *text = [component valueForKey:@"value"];
		if ([text length] > 0) {
			GBParagraphDecoratorItem *decorator = [GBParagraphDecoratorItem paragraphItemWithStringValue:text];
			if ([type isEqualToString:@"*"]) {
				GBLogDebug(@"  - Found '%@' formatted as bold at %@...", [text normalizedDescription], self.sourceFileInfo);
				decorator.decorationType = GBDecorationTypeBold;
			} else if ([type isEqualToString:@"_"]) {
				GBLogDebug(@"  - Found '%@' formatted as italics at %@...", [text normalizedDescription], self.sourceFileInfo);
				decorator.decorationType = GBDecorationTypeItalics;
			} else if ([type isEqualToString:@"`"]) {
				GBLogDebug(@"  - Found '%@' formatted as code at %@...", [text normalizedDescription], self.sourceFileInfo);
				decorator.decorationType = GBDecorationTypeCode;
			} else if ([type isEqualToString:@"=!="]) {
				GBLogDebug(@"  - Found '%@' formatted as bold-italics at %@...", [text normalizedDescription], self.sourceFileInfo);
				GBParagraphDecoratorItem *inner = [GBParagraphDecoratorItem paragraphItemWithStringValue:text];
				decorator.decorationType = GBDecorationTypeBold;
				[decorator registerItem:inner];
				inner.decorationType = GBDecorationTypeItalics;
				decorator = inner;
			} else {
				GBLogWarn(@"Unknown text decorator type %@ detected at %@!", type, self.sourceFileInfo);
				decorator = nil;
			}
			
			if (decorator) {
				NSArray *children = [self arrayOfTextAndLinkItemsFromString:text];
				[children enumerateObjectsUsingBlock:^(GBParagraphItem *child, NSUInteger idx, BOOL *stop) {
					[decorator registerItem:child];
				}];
				[paragraph registerItem:decorator];
			}
		}

		// Prepare next search range.
		NSUInteger location = range.location + range.length * 2 + [text length];
		search = NSMakeRange(location, [simplified length] - location);
	}];

	// If we have some remaining text, append it now.
	if ([simplified length] > search.location) {
		NSString *remainingText = [simplified substringWithRange:search];
		NSArray *remainingItems = [self arrayOfTextAndLinkItemsFromString:remainingText];
		[remainingItems enumerateObjectsUsingBlock:^(GBParagraphItem *item, NSUInteger idx, BOOL *stop) {
			[paragraph registerItem:item];
		}];
	}
//	return result;
}

- (NSArray *)arrayOfTextAndLinkItemsFromString:(NSString *)string {
	// Scans the given string, searching for links and converts it to an array of GBParagraphTextItem and GBParagraphLinkItem objects.
	return nil;
}

#pragma mark Helper methods

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
	NSUInteger end = start;
	if (start < [lines count]) {
		while (end < [lines count]) {
			NSString *line = [lines objectAtIndex:end];
			if ([line length] == 0) break;
			end++;
		}
	}
	
	// Pass results back to client through parameters.
	range->location = start;
	range->length = end - start;
	return (start < [lines count]);
}

- (void)registerParagraphItemToCurrentParagraph:(GBParagraphItem *)item {
	// Registers the given paragraph item to current paragraph. If there is no current paragraph, new one is created.
	if ([self.paragraphsStack isEmpty]) [self.paragraphsStack push:[GBCommentParagraph paragraph]];
	[[self.paragraphsStack peek] registerItem:item];
}

#pragma mark Properties

- (NSString *)sourceFileInfo {
	// Helper method for simplifiying logging of current line and source file information.
	return [NSString stringWithFormat:@"%@@%lu", self.currentComment.sourceInfo.filename, self.currentStartLine];
}

- (GBCommentComponentsProvider *)components {
	return self.settings.commentComponents;
}

@synthesize paragraphsStack;
@synthesize currentStartLine;
@synthesize currentComment;
@synthesize currentContext;
@synthesize settings;
@synthesize store;

@end
