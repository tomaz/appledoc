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

- (BOOL)findCommentBlockInLines:(NSArray *)lines blockRange:(NSRange *)range;
- (void)processCommentBlockInLines:(NSArray *)lines blockRange:(NSRange)range;

- (BOOL)registerWarningBlockFromlines:(NSArray *)lines;
- (BOOL)registerBugBlockFromLines:(NSArray *)lines;
- (BOOL)registerExampleBlockFromLines:(NSArray *)lines;
- (BOOL)registerListBlockFromLines:(NSArray *)lines;
- (BOOL)registerDirectivesBlockFromLines:(NSArray *)lines;
- (void)registerTextBlockFromLines:(NSArray *)lines;

- (void)registerTextItemsFromStringToCurrentParagraph:(NSString *)string;
- (void)registerTextAndLinkItemsFromString:(NSString *)string toObject:(id)object;

- (id)linkItemFromString:(NSString *)string range:(NSRange *)range description:(NSString **)description;
- (id)remoteMemberLinkItemFromString:(NSString *)string range:(NSRange *)range;
- (id)localMemberLinkFromString:(NSString *)string range:(NSRange *)range;
- (id)classLinkFromString:(NSString *)string range:(NSRange *)range;
- (id)categoryLinkFromString:(NSString *)string range:(NSRange *)range;
- (id)protocolLinkFromString:(NSString *)string range:(NSRange *)range;
- (id)urlLinkItemFromString:(NSString *)string range:(NSRange *)range;

- (GBCommentParagraph *)pushParagraphIfStackIsEmpty;
- (GBCommentParagraph *)pushParagraph:(BOOL)canAutoRegister;
- (GBCommentParagraph *)peekParagraph;
- (GBCommentParagraph *)popParagraph;
- (void)popAllParagraphs;

@property (retain) NSMutableArray *paragraphsStack;
@property (retain) GBComment *currentComment;
@property (retain) id currentContext;

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
	[self popAllParagraphs];
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

- (void)processCommentBlockInLines:(NSArray *)lines blockRange:(NSRange)range {
	// The given range is guaranteed to point to actual block within the lines array, so we only need to determine the kind of block and how to handle it.
	NSArray *block = [lines subarrayWithRange:range];
	self.currentStartLine = self.currentComment.sourceInfo.lineNumber + range.location;
	
	// If the block defines one of the known paragraph items, register it and return. Note that paragraph items are simply added to previous paragraph, however if no paragraph exists yet, this will automatically create one.
	if ([self registerExampleBlockFromLines:block]) return;
	if ([self registerBugBlockFromLines:block]) return;
	if ([self registerWarningBlockFromlines:block]) return;
	if ([self registerListBlockFromLines:block]) return;
	if ([self registerDirectivesBlockFromLines:block]) return;
	
	// If nothing else is matched, the block is standard text. For that we need to start a new paragraph and process the text. Note that we first need to close all open paragraphs - even if the paragraph was started by a known paragraph item block, new text block always starts a new paragraph at this point. But we must keep the new paragraph open in case next block defines an item.
	[self popAllParagraphs];
	[self registerTextBlockFromLines:block];
}

#pragma mark Comment blocks processing

- (BOOL)registerWarningBlockFromlines:(NSArray *)lines {
	// Warning block is a GBParagraphSpecialItem containing one or more GBParagraph items.
	NSString *regex = self.components.warningSectionRegex;
	if (![[lines firstObject] isMatchedByRegex:regex]) return NO;
	
	// Get the description and warn if empty text was found (we still return YES as the block was properly detected as @warning.
	NSString *string = [NSString stringByCombiningLines:lines delimitWith:@"\n"];
	NSString *description = [string stringByMatching:regex capture:1];
	if ([description length] == 0) {
 		GBLogWarn(@"Empty @warning block found in %@!", self.sourceFileInfo);
		return YES;
	}
	GBLogDebug(@"  - Found warning block '%@' at %@.", [string normalizedDescription], self.sourceFileInfo);
	
	// If there isn't paragraph registered yet, create one now, otherwise we'll just add the block to previous paragraph.
	[self pushParagraphIfStackIsEmpty];
	
	// Prepare paragraph item by setting up it's description paragraph, split the string into items and register all items to paragraph. Note that this code effectively ends block paragraph here, so any subsequent block will be added to current paragraph instead. This allows @bug blocks being written anywhere in the documentation, but prevents having more than one paragraph within.
	GBParagraphSpecialItem *item = [GBParagraphSpecialItem specialItemWithType:GBSpecialItemTypeWarning stringValue:string];
	[self pushParagraph:NO];
	[self registerTextItemsFromStringToCurrentParagraph:description];
	[item registerParagraph:[self peekParagraph]];
	[self popParagraph];
	
	// Register block item to current paragraph.
	[[self peekParagraph] registerItem:item];
	return YES;
}

- (BOOL)registerBugBlockFromLines:(NSArray *)lines {
	// Bug block is a GBParagraphSpecialItem containing one or more GBCommentParagraph items.
	NSString *regex = self.components.bugSectionRegex;
	if (![[lines firstObject] isMatchedByRegex:regex]) return NO;
	
	// Get the description and warn if empty text was found (we still return YES as the block was properly detected as @bug.
	NSString *string = [NSString stringByCombiningLines:lines delimitWith:@"\n"];
	NSString *description = [string stringByMatching:regex capture:1];
	if ([description length] == 0) {
 		GBLogWarn(@"Empty @bug block found in %@!", self.sourceFileInfo);
		return YES;
	}
	GBLogDebug(@"  - Found bug block '%@' at %@.", [string normalizedDescription], self.sourceFileInfo);
	
	// If there isn't paragraph registered yet, create one now, otherwise we'll just add the block to previous paragraph.
	[self pushParagraphIfStackIsEmpty];
	
	// Prepare paragraph item by setting up it's description paragraph, split the string into items and register all items to paragraph. Note that this code effectively ends block paragraph here, so any subsequent block will be added to current paragraph instead. This allows @bug blocks being written anywhere in the documentation, but prevents having more than one paragraph within.
	GBParagraphSpecialItem *item = [GBParagraphSpecialItem specialItemWithType:GBSpecialItemTypeBug stringValue:string];
	[self pushParagraph:NO];	
	[self registerTextItemsFromStringToCurrentParagraph:description];
	[item registerParagraph:[self peekParagraph]];
	[self popParagraph];
	
	// Register block item to current paragraph.
	[[self peekParagraph] registerItem:item];
	return YES;
}

- (BOOL)registerExampleBlockFromLines:(NSArray *)lines {
	// Example block is a GBParagraphSpecialItem containing one or more GBCommentParagraph items. The block is only considered as example if each line is prefixed with a single tab or 4 spaces. That leading whitespace is removed from each line in registered data. Note that we allow having mixed lines where one starts with tab and another with spaces!
	
	// Validate all lines match required prefix. Note that we first used dictionaryByMatchingRegex:withKeysAndCaptures: but it ended with EXC_BAD_ACCESS and I couldn't figure it out, so reverted to captureComponentsMatchedByRegex:
	NSString *regex = self.components.exampleSectionRegex;
	NSMutableArray *linesOfCaptures = [NSMutableArray arrayWithCapacity:[lines count]];
	for (NSString *line in lines) {
		NSArray *match = [line captureComponentsMatchedByRegex:regex];
		if ([match count] == 0) return NO;
		[linesOfCaptures addObject:match];
	}
	
	// So all lines are indeed prefixed with required example whitespace, let's create the item. First prepare string value containing only text without prefix. Note that capture index 0 contains full text, index 1 just the prefix and index 2 just the text.
	NSMutableString *stringValue = [NSMutableString string];
	[linesOfCaptures enumerateObjectsUsingBlock:^(NSArray *captures, NSUInteger idx, BOOL *stop) {
		if ([stringValue length] > 0) [stringValue appendString:@"\n"];
		NSString *lineText = [captures objectAtIndex:2];
		[stringValue appendString:lineText];
	}];	
	GBLogDebug(@"  - Found example block '%@' at %@.", [stringValue normalizedDescription], self.sourceFileInfo);
	
	// If there isn't paragraph registered yet, create one now, otherwise we'll just add the block to previous paragraph.
	[self pushParagraphIfStackIsEmpty];
	
    // Prepare paragraph item. Note that we don't use paragraphs stack as currently we don't process the text for cross refs!
    GBParagraphSpecialItem *item = [GBParagraphSpecialItem specialItemWithType:GBSpecialItemTypeExample stringValue:stringValue];
	GBCommentParagraph *paragraph = [GBCommentParagraph paragraph];
    [paragraph registerItem:[GBParagraphTextItem paragraphItemWithStringValue:stringValue]];
	[item registerParagraph:paragraph];
	
    // Register example block to current paragraph.
    [[self peekParagraph] registerItem:item];
	return YES;
}

- (BOOL)registerListBlockFromLines:(NSArray *)lines {
	// List block contains a hierarhcy of lists, each represented as a GBParagraphListItem, with it's items as GBCommentParagraph. The method handles both, ordered and unordered lists in any depth and any combination. NOTE: list items can be prefixed by tabs or spaces or combination of both, however it's recommended to use single case as depth is calculated simply by testing prefix string length (so single tab is considered same depth as single space).
	
	// If first line doesn't start a list, we should exit.
	NSString *unorderedRegex = self.components.unorderedListRegex;
	NSString *orderedRegex = self.components.orderedListRegex;
	if (![[lines firstObject] isMatchedByRegex:unorderedRegex] && ![[lines firstObject] isMatchedByRegex:orderedRegex]) return NO;
	GBLogDebug(@"  - Found list block at %@.", self.sourceFileInfo);
	
	// In the first pass, convert the array of lines into an array of pre-processed items. Each item is a dictionary containing type of item, indent and full description. The main reason for this step is to combine multiple line item texts into a single string.
	NSMutableArray *items = [NSMutableArray arrayWithCapacity:[lines count]];
	[lines enumerateObjectsUsingBlock:^(NSString *line, NSUInteger idx, BOOL *stop) {
		// If the line doesn't contain list item, treat it as successive line of text that should be appended to previous item. Note that we don't have to test if we have previous item as we already verified the first line contains one above!
		BOOL ordered = NO;
		NSArray *components = [line captureComponentsMatchedByRegex:unorderedRegex];
		if ([components count] == 0) {
			ordered = YES;
			components = [line captureComponentsMatchedByRegex:orderedRegex];
			if ([components count] == 0) {
				NSMutableDictionary *previousItem = [items lastObject];
				NSString *text = [previousItem objectForKey:@"text"];				
				[previousItem setObject:[text stringByAppendingFormat:@"\n%@", line] forKey:@"text"];
				return;
			}
		}
		
		// Create new list item.
		NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:3];
		[data setObject:[NSNumber numberWithBool:ordered] forKey:@"ordered"];
		[data setObject:[components objectAtIndex:1] forKey:@"indent"];
		[data setObject:[components objectAtIndex:2] forKey:@"text"];
		[items addObject:data];
	}];
	
	// If there isn't paragraph registered yet, create one now, otherwise we'll just add the block to previous paragraph.
	[self pushParagraphIfStackIsEmpty];
	NSUInteger paragraphsStackSize = [self.paragraphsStack count];
	
	// Now process all items and register all data. Note that each list is described by GBParagraphListItem while it's individual items are represented by GBCommentParagraph objects, where each item can additionally contain sublists, again in the form of GBParagraphListItem (this might be confusing due to usage of words "list item" in the class, but the "item" refers to "paragraph item", not to the list). Here's a graph to make it more obvious:
	// - GBParagraphListItem (root list, one object created for each list found)
	//		- GBCommentParagraph (item1's description)
	//		- GBCommentParagraph (item2's description)
	//			- GBParagraphListItem (item2's sublist)
	//				- GBCommentParagraph (item2.1's description)
	NSMutableArray *listsStack = [NSMutableArray arrayWithCapacity:[items count]];
	NSMutableArray *indentsStack = [NSMutableArray arrayWithCapacity:[items count]];
	[items enumerateObjectsUsingBlock:^(NSDictionary *itemData, NSUInteger idx, BOOL *stop) {
		// Get item components.
		BOOL ordered = [[itemData objectForKey:@"ordered"] boolValue];
		NSString *indent = [itemData objectForKey:@"indent"];
		NSString *text = [itemData objectForKey:@"text"];
		
		if ([listsStack count] == 0 || [indent length] > [[indentsStack peek] length]) {
			// If lists stack is empty, create root list that will hold all items and push original indent. If we found greater indent, we need to start sublist.
			GBLogDebug(@"    - Starting list at level %lu...", [indentsStack count] + 1);
			GBParagraphListItem *item = ordered ? [GBParagraphListItem orderedParagraphListItem] : [GBParagraphListItem unorderedParagraphListItem];
			[[self peekParagraph] registerItem:item];
			[listsStack push:item];
			[indentsStack push:indent];
		} else if ([indent length] < [[indentsStack peek] length]) {
			// If indent level is smaller, end sublist and pop current indents until we find a match. Note that we also need to close current paragraph belonging to previous item at the same level!
			while ([indentsStack count] > 0 && [indent length] < [[indentsStack lastObject] length]) {
				GBLogDebug(@"    - Ending list at level %lu...", [indentsStack count]);
				[self popParagraph];
				[listsStack pop];
				[indentsStack pop];
			}
			[self popParagraph];
		} else {
			// If indent matches current one, we're adding new item to current list, but we need to close previous item's paragraph!
			[self popParagraph];
		}
		
		// Create GBCommentParagraph representing item's text and process the text. We'll end the paragraph representing item's text and sublists when we find another item at the same level or find items at lower levels...
		GBLogDebug(@"      - Creating list item '%@' at level %lu...", [text normalizedDescription], [indentsStack count]);
		GBParagraphListItem *list = [listsStack peek];
		[list registerItem:[self pushParagraph:NO]];
		[self registerTextItemsFromStringToCurrentParagraph:text];
	}];
	
	// At the end we need to unwind paragraphs stack until we clear all added paragraphs.
	while ([self.paragraphsStack count] > paragraphsStackSize) [self popParagraph];
	return YES;
}

- (BOOL)registerDirectivesBlockFromLines:(NSArray *)lines {
	// Registers a block containing directives (@param, @return etc.).
#define isMatchingDirectiveStatement(theText) \
	([theText isMatchedByRegex:parameterRegex] || [theText isMatchedByRegex:exceptionRegex] || [theText isMatchedByRegex:returnRegex] || [theText isMatchedByRegex:crossRefRegex])
	
	// If the first line doesn't contain directive, exit.
	NSString *parameterRegex = self.components.parameterDescriptionRegex;
	NSString *exceptionRegex = self.components.exceptionDescriptionRegex;
	NSString *returnRegex = self.components.returnDescriptionRegex;
	NSString *crossRefRegex = self.components.crossReferenceRegex;
	if (!isMatchingDirectiveStatement([lines firstObject])) return NO;
	
	// In the first pass, convert the array of lines into an array of pre-processed directive items. Note that we use simplified grouping - if a line matches any directive, we start new directive, otherwise we append text to previous one. The result is an array containing dictionaries with text and line number. Exit if we didn't match any directive.
	NSMutableArray *directives = [NSMutableArray arrayWithCapacity:[lines count]];
	for (NSUInteger i=0; i<[lines count]; i++) {
		NSString *line = [lines objectAtIndex:i];
		if (isMatchingDirectiveStatement(line)) {
			NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:2];
			[data setObject:line forKey:@"text"];
			[data setObject:[NSNumber numberWithInt:self.currentStartLine + i] forKey:@"line"];
			[directives addObject:data];
		} else if (i > 0) {
			NSMutableDictionary *data = [directives lastObject];
			NSString *text = [[data objectForKey:@"text"] stringByAppendingFormat:@"\n%@", line];
			[data setObject:text forKey:@"text"];
		} else {
			return NO;
		}
	};
	GBLogDebug(@"  - Found directives block at %@.", self.sourceFileInfo);
	
	// Process all directives. Note that we must not immediately close paragraphs as we can find additional paragraph blocks belonging to the paragraph later on (i.e. list blocks, example blocks etc.).
	[directives enumerateObjectsUsingBlock:^(NSDictionary *data, NSUInteger idx, BOOL *stop) {
		NSArray *components = nil;
		NSString *directive = [data objectForKey:@"text"];
		NSString *sourceInfo = [NSString stringWithFormat:@"%@%%@", self.currentComment.sourceInfo.filename, [data objectForKey:@"line"]];
		
		// We must close previous directive description paragraph when we encounter another one. Note that this won't register the paragraph to comment as we opened each by specifying them as non-auto registered paragraphs. We leave last directive description paragraph open - we want to add any following paragraph blocks to. The paragraph will be closed either when we end processing or when we encounter another text block.
		if (idx > 0) [self popParagraph];
		
		// Match @param.
		components = [directive captureComponentsMatchedByRegex:parameterRegex];
		if ([components count] > 0) {
			NSString *name = [components objectAtIndex:1];
			NSString *text = [components objectAtIndex:2];
			GBLogDebug(@"    - Found parameter %@ directive with description '%@' at %@...", name, [text normalizedDescription], sourceInfo);
			GBCommentParagraph *paragraph = [self pushParagraph:NO];
			[self registerTextItemsFromStringToCurrentParagraph:text];
			GBCommentArgument *argument = [GBCommentArgument argumentWithName:name description:paragraph];
			[self.currentComment registerParameter:argument];
			return;
		}
		
		// Match @exception.
		components = [directive captureComponentsMatchedByRegex:exceptionRegex];
		if ([components count] > 0) {
			NSString *name = [components objectAtIndex:1];
			NSString *text = [components objectAtIndex:2];
			GBLogDebug(@"    - Found exception %@ directive with description '%@' at %@...", name, [text normalizedDescription], sourceInfo);
			GBCommentParagraph *paragraph = [self pushParagraph:NO];
			[self registerTextItemsFromStringToCurrentParagraph:text];
			GBCommentArgument *argument = [GBCommentArgument argumentWithName:name description:paragraph];
			[self.currentComment registerException:argument];
			return;
		}
		
		// Match @return.
		components = [directive captureComponentsMatchedByRegex:returnRegex];
		if ([components count] > 0) {
			NSString *text = [components objectAtIndex:1];
			GBLogDebug(@"    - Matched result directive with description '%@' at %@...", [text normalizedDescription], sourceInfo);
			GBCommentParagraph *paragraph = [self pushParagraph:NO];
			[self registerTextItemsFromStringToCurrentParagraph:text];
			[self.currentComment registerResult:paragraph];
			return;
		}
		
		// Match @see.
		components = [directive captureComponentsMatchedByRegex:crossRefRegex];
		if ([components count] > 0) {
			NSString *text = [components objectAtIndex:1];
			GBParagraphLinkItem *item = [self linkItemFromString:text range:nil description:nil];
			if (item) {
				GBLogDebug(@"    - Matched cross ref directive %@ at %@...", text, sourceInfo);
				[self.currentComment registerCrossReference:item];
			} else if (self.settings.warnOnInvalidCrossReference) {
				GBLogWarn(@"Invalid cross ref %@ found at %@!", text, sourceInfo);
			}
			return;
		}
		
		// If the line doesn't contain known directive, warn the user.
		GBLogWarn(@"Found unknown directive '%@' at %@!", directive, sourceInfo);
	}];

	return YES;
}

- (void)registerTextBlockFromLines:(NSArray *)lines {
	// Registers standard text from the given block of lines. This always starts a new paragraph. Note that this method is just convenience method for registerTextItemsFromStringToCurrentParagraph:. Also note that we keep paragraph open as we may need to append one of the paragraph item blocks later on.
	NSString *stringValue = [NSString stringByCombiningLines:lines delimitWith:@"\n"];
	GBLogDebug(@"  - Found text block '%@' at %@.", [stringValue normalizedDescription], self.sourceFileInfo);
	[self pushParagraph:YES];
	[self registerTextItemsFromStringToCurrentParagraph:stringValue];
}

#pragma mark Comment text processing

- (void)registerTextItemsFromStringToCurrentParagraph:(NSString *)string {
	// Registers the text from the given string to last paragraph. Text is converted to an array of GBParagraphTextItem, GBParagraphLinkItem and GBParagraphDecoratorItem objects. This is the main entry point for text processing, this is the only message that should be used for processing text from higher level methods. WARNING: The client is responsible for adding proper paragraph to the stack!
	NSString *simplified = [string stringByReplacingOccurrencesOfRegex:@"(\\*_|_\\*)" withString:@"=!="];
	NSArray *components = [simplified arrayOfDictionariesByMatchingRegex:@"(?s:(\\*|_|=!=|`)(.*?)\\1)" withKeysAndCaptures:@"type", 1, @"value", 2, nil];
	GBCommentParagraph *paragraph = [self peekParagraph];
	NSRange search = NSMakeRange(0, [simplified length]);
	for (NSDictionary *component in components) {
		// Get range of next formatted section. If not found, exit (we'll deal with remaining text after the loop).
		NSString *type = [component objectForKey:@"type"];
		NSRange range = [simplified rangeOfString:type options:0 range:search];
		if (range.location == NSNotFound) break;
		
		// If we skipped some text, add it before handling formatted part!
		if (range.location > search.location) {
			NSRange skippedRange = NSMakeRange(search.location, range.location - search.location);
			NSString *skippedText = [simplified substringWithRange:skippedRange];
			GBLogDebug(@"  - Found '%@' text at %@, processing for cross refs...", skippedText, self.sourceFileInfo);
			[self registerTextAndLinkItemsFromString:skippedText toObject:paragraph];
		}

		// Get formatted text and prepare properly decorated component. Note that we warn the user if we find unknown decorator type (this probably just means we changed some decorator value by forgot to change this part, so it's some sort of "exception" catching).
		NSString *text = [component valueForKey:@"value"];
		if ([text length] > 0) {
			GBParagraphDecoratorItem *decorator = [GBParagraphDecoratorItem paragraphItemWithStringValue:text];
			if ([type isEqualToString:@"*"]) {
				GBLogDebug(@"  - Found '%@' formatted as bold at %@, processing for cross refs...", [text normalizedDescription], self.sourceFileInfo);
				decorator.decorationType = GBDecorationTypeBold;
			} else if ([type isEqualToString:@"_"]) {
				GBLogDebug(@"  - Found '%@' formatted as italics at %@, processing for cross refs...", [text normalizedDescription], self.sourceFileInfo);
				decorator.decorationType = GBDecorationTypeItalics;
			} else if ([type isEqualToString:@"`"]) {
				GBLogDebug(@"  - Found '%@' formatted as code at %@, processing for cross refs...", [text normalizedDescription], self.sourceFileInfo);
				decorator.decorationType = GBDecorationTypeCode;
			} else if ([type isEqualToString:@"=!="]) {
				GBLogDebug(@"  - Found '%@' formatted as bold-italics at %@, processing for cross refs...", [text normalizedDescription], self.sourceFileInfo);
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
				[self registerTextAndLinkItemsFromString:text toObject:decorator];
				[paragraph registerItem:decorator];
			}
		}

		// Prepare next search range.
		NSUInteger location = range.location + range.length * 2 + [text length];
		search = NSMakeRange(location, [simplified length] - location);
	};

	// If we have some remaining text, append it now.
	if ([simplified length] > search.location) {
		NSString *remainingText = [simplified substringWithRange:search];
		GBLogDebug(@"  - Found '%@' text at %@, processing for cross refs...", [remainingText normalizedDescription], self.sourceFileInfo);
		[self registerTextAndLinkItemsFromString:remainingText toObject:paragraph];
	}
}

- (void)registerTextAndLinkItemsFromString:(NSString *)string toObject:(id)object {
	// Scans the given string for possible links and converts the text to an array of GBParagraphTextItem and GBParagraphLinkItem objects which are ultimately registered to the given object. NOTE: This message is intended to be sent from registerTextItemsFromStringToCurrentParagraph: and should not be used otherwise! WARNING: The given object must respond to registerItem: message!
#define registerTextItemFromString(theString) \
	if ([theString length] > 0) { \
		GBLogDebug(@"    - Found text '%@'...", [theString normalizedDescription]); \
		GBParagraphTextItem *textItem = [GBParagraphTextItem paragraphItemWithStringValue:theString]; \
		[object registerItem:textItem]; \
		[theString setString:@""]; \
	}
#define registerLinkItem(theItem, theType) { \
	GBLogDebug(@"    - Found %@ %@ cross ref..", theType, theItem.stringValue); \
	[object registerItem:theItem]; \
}
#define skipTextFromString(theString) { \
	if (theString) { \
		[text appendString:theString]; \
		string = [string substringFromIndex:[theString length]]; \
	} \
}
	// Progressively chip away the string and test if it starts with any known cross reference. If so, register link item, otherwise consider the text as normal text item, so skip to the next word.
	NSMutableString *text = [NSMutableString stringWithCapacity:[string length]];
	NSRange range = NSMakeRange(0, 0);
	while ([string length] > 0) {
		// If the string starts with any recognized cross reference, add the link item and skip it's text, otherwise mark the word until next whitespace as text item.
		NSString *description = nil;
		GBParagraphLinkItem *linkItem = [self linkItemFromString:string range:&range description:&description];
		if (linkItem) {
			skipTextFromString([string substringToIndex:range.location]);
			registerTextItemFromString(text);
			registerLinkItem(linkItem, description);
			string = [string substringFromIndex:range.length];
		} else {
			skipTextFromString([string stringByMatching:@"^\\S+"]);
		}
		
		// Skip any leading whitespace until the next word and mark it as text item.
		skipTextFromString([string stringByMatching:@"^\\s+"]);
	}
	
	// Append any remaining text 
	registerTextItemFromString(text);
}

#pragma mark Cross references detection

- (id)linkItemFromString:(NSString *)string range:(NSRange *)range description:(NSString **)description {
	// Matches any cross reference at the start of the given string and creates GBParagraphLinkItem, match range and description suitable for logging if found. If the string doesn't represent any known cross reference, nil is returned and the other parameters are left untouched. Note that the order of testing is somewhat important (for example we should test for category before class or protocol to avoid text up to open parenthesis being recognized as a class where in fact it's category).
	GBParagraphLinkItem *result = nil;
	NSString *desc = nil;
	if ((result = [self categoryLinkFromString:string range:range])) {
		desc = @"category";
	} else if ((result = [self classLinkFromString:string range:range])) {
		desc = @"class";
	} else if ((result = [self protocolLinkFromString:string range:range])) {
		desc = @"protocol";
	} else if ((result = [self remoteMemberLinkItemFromString:string range:range])) {
		desc = @"remote member";
	} else if ((result = [self localMemberLinkFromString:string range:range])) {
		desc = @"local member";
	} else if ((result = [self urlLinkItemFromString:string range:range])) {
		desc = @"url";
	}
	if (result && description) *description = desc;
	return result;
}

- (id)remoteMemberLinkItemFromString:(NSString *)string range:(NSRange *)range {
	// Matches the beginning of the string for remote member cross reference (in the format [Object member]). If found, GBParagraphLinkItem is prepared and returned. NOTE: The range argument is used to return the range of all link text, including optional <> markers.
	// If the string starts with remote link
	NSArray *components = [string captureComponentsMatchedByRegex:self.components.remoteMemberCrossReferenceRegex];
	if ([components count] == 0) return nil;
	
	// Get link components. Index 0 contains full text, including optional <>, index 1 object name, index 2 member name.
	NSString *linkText = [components objectAtIndex:0];
	NSString *objectName = [components objectAtIndex:1];
	NSString *memberName = [components objectAtIndex:2];
	
	// Validate the link to match it to known object. If no known object is matched, warn, update search range and continue with remaining text. This is required so that we treat unknown objects as normal text later on and still catch proper references that may be hiding in the remainder.
	id referencedObject = [self.store classWithName:objectName];
	if (!referencedObject) {
		referencedObject = [self.store categoryWithName:objectName];
		if (!referencedObject) {
			referencedObject = [self.store protocolWithName:objectName];
			if (!referencedObject) {
				if (self.settings.warnOnInvalidCrossReference) GBLogWarn(@"Invalid %@ reference found near %@, unknown object!", linkText, self.sourceFileInfo);
				return nil;
			}
		}
	}
	
	// Ok, so we have found referenced object in store, now search the member. If member isn't recognized, warn, update search range and continue with remaining text. This is required so that we treat unknown members as normal text later on and still catch proper references in remainder.
	id referencedMember = [[referencedObject methods] methodBySelector:memberName];
	if (!referencedMember) {
		if (self.settings.warnOnInvalidCrossReference) GBLogWarn(@"Invalid %@ reference found near %@, unknown method!", linkText, self.sourceFileInfo);
		return nil;
	}
	
	// Right, we have valid reference to known remote member, create the link item, prepare range and return.
	NSString *stringValue = [linkText stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	GBParagraphLinkItem *result = [GBParagraphLinkItem paragraphItemWithStringValue:stringValue];
	result.href = [self.settings htmlReferenceForObject:referencedMember fromSource:self.currentContext];
	result.context = referencedObject;
	result.member = referencedMember;
	result.isLocal = NO;
	if (range) *range = [string rangeOfString:linkText];
	return result;
}

- (id)localMemberLinkFromString:(NSString *)string range:(NSRange *)range {
	// Matches the beginning of the string for local member cross reference. If found, GBParagraphLinkItem is prepared and returned. NOTE: The range argument is used to return the range of all link text, including optional <> markers. NOTE: Note that we can skip local member cross ref testing if no context (i.e. class, category or protocol) is given!
	if (!self.currentContext) return nil;
	NSArray *components = [string captureComponentsMatchedByRegex:self.components.localMemberCrossReferenceRegex];
	if ([components count] == 0) return nil;
	
	// Get link components. Index 0 contains full text, including optional <>, index 1 just the member selector.
	NSString *linkText = [components objectAtIndex:0];
	NSString *selector = [components objectAtIndex:1];
	
	// Validate the selector against the context. If context doesn't implement the method, exit.
	GBMethodData *referencedMethod = [[[self currentContext] methods] methodBySelector:selector];
	if (!referencedMethod) return nil;
	
	// Ok, we have valid method, return the link item.
	GBParagraphLinkItem *result = [GBParagraphLinkItem paragraphItemWithStringValue:selector];
	result.href = [self.settings htmlReferenceForObject:referencedMethod fromSource:self.currentContext];
	result.context = self.currentContext;
	result.member = referencedMethod;
	result.isLocal = YES;
	if (range) *range = [string rangeOfString:linkText];
	return result;
}

- (id)classLinkFromString:(NSString *)string range:(NSRange *)range {
	// Matches the beginning of the string for class cross reference. If found, GBParagraphLinkItem is prepared and returned. NOTE: The range argument is used to return the range of all link text, including optional <> markers.
	NSArray *components = [string captureComponentsMatchedByRegex:self.components.objectCrossReferenceRegex];
	if ([components count] == 0) return nil;
	
	// Get link components. Index 0 contains full text, including optional <>, index 1 just the object name.
	NSString *linkText = [components objectAtIndex:0];
	NSString *objectName = [components objectAtIndex:1];
	
	// Validate the selector against the context. If context doesn't implement the method, exit.
	GBClassData *referencedObject = [self.store classWithName:objectName];
	if (!referencedObject) return nil;
	
	// Ok, we have valid method, return the link item.
	GBParagraphLinkItem *result = [GBParagraphLinkItem paragraphItemWithStringValue:objectName];
	result.href = [self.settings htmlReferenceForObject:referencedObject fromSource:self.currentContext];
	result.context = referencedObject;
	result.isLocal = (referencedObject == self.currentContext);
	if (range) *range = [string rangeOfString:linkText];
	return result;
}

- (id)categoryLinkFromString:(NSString *)string range:(NSRange *)range {
	// Matches the beginning of the string for category cross reference. If found, GBParagraphLinkItem is prepared and returned. NOTE: The range argument is used to return the range of all link text, including optional <> markers.
	NSArray *components = [string captureComponentsMatchedByRegex:self.components.categoryCrossReferenceRegex];
	if ([components count] == 0) return nil;
	
	// Get link components. Index 0 contains full text, including optional <>, index 1 just the object name.
	NSString *linkText = [components objectAtIndex:0];
	NSString *objectName = [components objectAtIndex:1];
	
	// Validate the selector against the context. If context doesn't implement the method, exit.
	GBCategoryData *referencedObject = [self.store categoryWithName:objectName];
	if (!referencedObject) return nil;
	
	// Ok, we have valid method, return the link item.
	GBParagraphLinkItem *result = [GBParagraphLinkItem paragraphItemWithStringValue:objectName];
	result.href = [self.settings htmlReferenceForObject:referencedObject fromSource:self.currentContext];
	result.context = referencedObject;
	result.isLocal = (referencedObject == self.currentContext);
	if (range) *range = [string rangeOfString:linkText];
	return result;
}

- (id)protocolLinkFromString:(NSString *)string range:(NSRange *)range {
	// Matches the beginning of the string for protocol cross reference. If found, GBParagraphLinkItem is prepared and returned. NOTE: The range argument is used to return the range of all link text, including optional <> markers.
	NSArray *components = [string captureComponentsMatchedByRegex:self.components.objectCrossReferenceRegex];
	if ([components count] == 0) return nil;
	
	// Get link components. Index 0 contains full text, including optional <>, index 1 just the object name.
	NSString *linkText = [components objectAtIndex:0];
	NSString *objectName = [components objectAtIndex:1];
	
	// Validate the selector against the context. If context doesn't implement the method, exit.
	GBProtocolData *referencedObject = [self.store protocolWithName:objectName];
	if (!referencedObject) return nil;
	
	// Ok, we have valid method, return the link item.
	GBParagraphLinkItem *result = [GBParagraphLinkItem paragraphItemWithStringValue:objectName];
	result.href = [self.settings htmlReferenceForObject:referencedObject fromSource:self.currentContext];
	result.context = referencedObject;
	result.isLocal = (referencedObject == self.currentContext);
	if (range) *range = [string rangeOfString:linkText];
	return result;
}

- (id)urlLinkItemFromString:(NSString *)string range:(NSRange *)range {
	// Matches the beginning of the string for URL cross reference. If found, GBParagraphLinkItem is prepared and returned. NOTE: The range argument is used to return the range of all link text, including optional <> markers.
	NSArray *components = [string captureComponentsMatchedByRegex:self.components.urlCrossReferenceRegex];
	if ([components count] == 0) return nil;
	
	// Get link components. Index 0 contains full text, including optional <>, index 1 just the URL address.
	NSString *linkText = [components objectAtIndex:0];
	NSString *address = [components objectAtIndex:1];
	
	// Create link item, prepare range and return.
	GBParagraphLinkItem *result = [GBParagraphLinkItem paragraphItemWithStringValue:address];
	result.href = address;
	if (range) *range = [string rangeOfString:linkText];
	return result;
}

#pragma mark Helper methods

- (GBCommentParagraph *)pushParagraphIfStackIsEmpty {
	// Convenience method for creating and pushing paragraph only if paragraphs stack is currently empty. In such case new paragraph is pushed to stack and returned. Otherwise last paragraph on the stack is returned. This is useful for block handling methods for comment paragraphs (it's not suitable for parameters, exceptions and similar which must create non-autoregistering paragraph).
	if ([self.paragraphsStack isEmpty]) return [self pushParagraph:YES];
	return [self peekParagraph];
}

- (GBCommentParagraph *)pushParagraph:(BOOL)canAutoRegister {
	// Convenience method for creating and pushing paragraph. Note that auto register flag specifies whether the paragraph should be automatically registered to comment when popping last paragraph from the stack. For normal comment description paragraphs, this should be YES, however for paragraphs describing list items, example blocks, method directives and similar, this should be NO to prevent registering description paragraphs to comment as well in case there is no opened comment paragraph yet...
	GBCommentParagraph *result = [GBCommentParagraph paragraph];
	NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:result, @"paragraph", [NSNumber numberWithBool:canAutoRegister], @"register", nil];
	[self.paragraphsStack push:data];
	return result;
}

- (GBCommentParagraph *)peekParagraph {
	return [[self.paragraphsStack peek] objectForKey:@"paragraph"];
}

- (GBCommentParagraph *)popParagraph {
	// Pops last paragraph from the stack and returns it. If the stack becomes empty, the paragraph is registered to current comment. This simplifies and automates paragraphs registration.
	NSDictionary *data = [self.paragraphsStack pop];
	GBCommentParagraph *result = [data objectForKey:@"paragraph"];
	BOOL canRegister = [[data objectForKey:@"register"] boolValue];
	if (canRegister && [self.paragraphsStack isEmpty]) [self.currentComment registerParagraph:result];
	return result;
}

- (void)popAllParagraphs {
	while (![self.paragraphsStack isEmpty]) {
		[self popParagraph];
	}
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
