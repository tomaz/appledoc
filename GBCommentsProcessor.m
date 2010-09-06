//
//  GBCommentsProcessor.m
//  appledoc
//
//  Created by Tomaz Kragelj on 27.8.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "RegexKitLite.h"
#import "GBApplicationSettingsProviding.h"
#import "GBStoreProviding.h"
#import "GBDataObjects.h"
#import "GBCommentsProcessor.h"

@interface GBCommentsProcessor ()

- (void)registerUnorderedListFromString:(NSString *)string toParagraph:(GBCommentParagraph *)paragraph;
- (void)registerOrderedListFromString:(NSString *)string toParagraph:(GBCommentParagraph *)paragraph;
- (void)registerListFromString:(NSString *)string ordered:(BOOL)ordered usingRegex:(NSString *)regex toParagraph:(GBCommentParagraph *)paragraph;
- (void)registerWarningFromString:(NSString *)string toParagraph:(GBCommentParagraph *)paragraph;
- (void)registerBugFromString:(NSString *)string toParagraph:(GBCommentParagraph *)paragraph;
- (void)registerExampleFromString:(NSString *)string toParagraph:(GBCommentParagraph *)paragraph;
- (void)registerSpecialFromString:(NSString *)string type:(GBSpecialItemType)type usingRegex:(NSString *)regex toParagraph:(GBCommentParagraph *)paragraph;
- (void)registerTextFromString:(NSString *)string toParagraph:(GBCommentParagraph *)paragraph;
- (NSArray *)textComponentsFromString:(NSString *)string;
- (NSString *)strippedTextComponentFromString:(NSString *)string;
- (NSArray *)componentsSeparatedByEmptyLinesFromString:(NSString *)string;
- (NSArray *)componentsSeparatedByNewLinesFromString:(NSString *)string;
@property (retain) NSString *newLinesRegexSymbols;
@property (retain) NSString *spaceAndNewLineTrimRegex;
@property (retain) id<GBApplicationSettingsProviding> settings;
@property (retain) id<GBStoreProviding> store;

@end

#pragma mark -

@implementation GBCommentsProcessor

#pragma mark Initialization & disposal

+ (id)processorWithSettingsProvider:(id)settingsProvider {
	return [[[self alloc] initWithSettingsProvider:settingsProvider] autorelease];
}

- (id)initWithSettingsProvider:(id)settingsProvider {
	NSParameterAssert(settingsProvider != nil);
	NSParameterAssert([settingsProvider conformsToProtocol:@protocol(GBApplicationSettingsProviding)]);
	GBLogDebug(@"Initializing comments processor with settings provider %@...", settingsProvider);
	self = [super init];
	if (self) {
		self.newLinesRegexSymbols = [NSString stringWithUTF8String:"(?:\\r\n|[ \n\\v\\f\\r\302\205\\p{Zl}\\p{Zp}])+"];
		self.spaceAndNewLineTrimRegex = [NSString stringWithFormat:@"^%1$@|%1$@$", self.newLinesRegexSymbols];
		self.settings = settingsProvider;
	}
	return self;
}

#pragma mark Processing handling

- (void)processComment:(GBComment *)comment withStore:(id)store {
#define GBRegister(code) \
	BOOL shouldRegisterParagraph = (currentParagraph == nil); \
	if (shouldRegisterParagraph) currentParagraph = [GBCommentParagraph paragraph]; \
	code; \
	if (shouldRegisterParagraph) [comment registerParagraph:currentParagraph]

	NSParameterAssert(comment != nil);
	NSParameterAssert(store != nil);
	NSParameterAssert([store conformsToProtocol:@protocol(GBStoreProviding)]);
	GBLogDebug(@"Processing comment with store %@...", store);
	self.store = store;	
	GBCommentComponentsProvider *componizer = self.settings.commentComponents;
	NSArray *components = [self componentsSeparatedByEmptyLinesFromString:[comment stringValue]];
	__block GBCommentParagraph *currentParagraph = nil;
	[components enumerateObjectsUsingBlock:^(NSString *component, NSUInteger idx, BOOL *stop) {
		// As most components are given with preceeding new line, we should remove it to get cleaner testing.
		NSString *trimmed = [component stringByReplacingOccurrencesOfRegex:self.spaceAndNewLineTrimRegex withString:@""];

		// Match known parts. Note that order is important for certain items (lists must be processed before examples for example).
		if ([trimmed isMatchedByRegex:componizer.unorderedListRegex]) {
			GBRegister([self registerUnorderedListFromString:trimmed toParagraph:currentParagraph]);
			return;
		}
		if ([trimmed isMatchedByRegex:componizer.orderedListRegex]) {
			GBRegister([self registerOrderedListFromString:trimmed toParagraph:currentParagraph]);
			return;
		}
		if ([trimmed isMatchedByRegex:componizer.warningSectionRegex]) {
			GBRegister([self registerWarningFromString:trimmed toParagraph:currentParagraph]);
			return;
		}
		if ([trimmed isMatchedByRegex:componizer.bugSectionRegex]) {
			GBRegister([self registerBugFromString:trimmed toParagraph:currentParagraph]);
			return;
		}
		if ([trimmed isMatchedByRegex:componizer.exampleSectionRegex]) {
			GBRegister([self registerExampleFromString:trimmed toParagraph:currentParagraph]);
			return;
		}
		
		// If no other match was found, this is simple text, so start new paragraph.
		currentParagraph = [GBCommentParagraph paragraph];
		[self registerTextFromString:trimmed toParagraph:currentParagraph];
		[comment registerParagraph:currentParagraph];
	}];
}

#pragma mark Processing paragraph lists

- (void)registerUnorderedListFromString:(NSString *)string toParagraph:(GBCommentParagraph *)paragraph {
	[self registerListFromString:string ordered:NO usingRegex:self.settings.commentComponents.unorderedListPrefixRegex toParagraph:paragraph];
}

- (void)registerOrderedListFromString:(NSString *)string toParagraph:(GBCommentParagraph *)paragraph {
	[self registerListFromString:string ordered:YES usingRegex:self.settings.commentComponents.orderedListPrefixRegex toParagraph:paragraph];
}

- (void)registerListFromString:(NSString *)string ordered:(BOOL)ordered usingRegex:(NSString *)regex toParagraph:(GBCommentParagraph *)paragraph {
	GBParagraphListItem *item = [GBParagraphListItem paragraphItemWithStringValue:string];
	item.isOrdered = ordered;
	
	// Split the block of all list items to individual items, then process and register each one.
	NSArray *items = [string componentsSeparatedByRegex:regex];
	[items enumerateObjectsUsingBlock:^(NSString *description, NSUInteger idx, BOOL *stop) {
		if ([description length] == 0) {
			GBLogWarn(@"%ld. item has empty description for list:\n%@", idx, string);
			return;
		}
		GBCommentParagraph *paragraph = [GBCommentParagraph paragraph];
		[self registerTextFromString:description toParagraph:paragraph];
		[item registerItem:paragraph];
	}];
	
	// Register list item to paragraph.
	[paragraph registerItem:item];
}

#pragma mark Processing special items

- (void)registerWarningFromString:(NSString *)string toParagraph:(GBCommentParagraph *)paragraph {
	[self registerSpecialFromString:string type:GBSpecialItemTypeWarning usingRegex:self.settings.commentComponents.warningSectionRegex toParagraph:paragraph];
}

- (void)registerBugFromString:(NSString *)string toParagraph:(GBCommentParagraph *)paragraph {
	[self registerSpecialFromString:string type:GBSpecialItemTypeBug usingRegex:self.settings.commentComponents.bugSectionRegex toParagraph:paragraph];
}

- (void)registerExampleFromString:(NSString *)string toParagraph:(GBCommentParagraph *)paragraph {
	// Get the description from the string. If empty, warn and exit.
	NSArray *lines = [string componentsMatchedByRegex:self.settings.commentComponents.exampleLinesRegex capture:1];
	NSMutableString *example = [NSMutableString stringWithCapacity:[string length]];
	[lines enumerateObjectsUsingBlock:^(NSString *line, NSUInteger idx, BOOL *stop) {
		if ([example length] > 0) [example appendString:@"\n"];
		[example appendString:line];
	}];
	
	// Warn if empty example was found or not all text was processed (note that we calculate remaining text by checking source and processed string length and taking into account all leading tabs that were removed!).
	if ([example length] == 0) {
		GBLogWarn(@"Empty example section found!");
		return;
	}
	if ([example length] < [string length] - [lines count]) {
		NSString *remaining = [string substringFromIndex:[example length] + [lines count]];
		GBLogWarn(@"Not all text was processed - '%@' was left, make sure an empty line without tabs is inserted before next paragraph!", [remaining stringByReplacingOccurrencesOfRegex:self.spaceAndNewLineTrimRegex withString:@""]);
	}
	
	// Prepare paragraph item and process the text. Note that we don't use standard text processing here as it would interfere with example formatting.
	GBParagraphSpecialItem *item = [GBParagraphSpecialItem specialItemWithType:GBSpecialItemTypeExample stringValue:example];
	GBCommentParagraph *itemsParagraph = [GBCommentParagraph paragraph];
	[itemsParagraph registerItem:[GBParagraphTextItem paragraphItemWithStringValue:example]];
	[item registerParagraph:itemsParagraph];
	
	// Register special item to paragraph.
	[paragraph registerItem:item];
}

- (void)registerSpecialFromString:(NSString *)string type:(GBSpecialItemType)type usingRegex:(NSString *)regex toParagraph:(GBCommentParagraph *)paragraph {
	// Get the description from the string. If empty, warn and exit.
	NSString *description = [string stringByMatching:regex capture:1];
	if ([description length] == 0) {
		GBLogWarn(@"Empty special section of type %ld found!", type);
		return;
	}
	
	// Prepare paragraph item and process the text.
	GBParagraphSpecialItem *item = [GBParagraphSpecialItem specialItemWithType:type stringValue:string];
	GBCommentParagraph *para = [GBCommentParagraph paragraph];
	[self registerTextFromString:description toParagraph:para];
	[item registerParagraph:para];
	
	// Register special item to paragraph.
	[paragraph registerItem:item];
}

#pragma mark Processing paragraph text

- (void)registerTextFromString:(NSString *)string toParagraph:(GBCommentParagraph *)paragraph {
	// Get and register all components.
	NSArray *components = [self textComponentsFromString:string];
	[components enumerateObjectsUsingBlock:^(GBParagraphItem *component, NSUInteger idx, BOOL *stop) {
		[paragraph registerItem:component];
	}];
}

- (NSArray *)textComponentsFromString:(NSString *)string {
	// Splits given string into un/formatted parts to make further processing simpler. To simplify we first convert nested case markers into something different from single ones, so that we can then handle them all in the same loop.
	NSString *simplified = [string stringByReplacingOccurrencesOfRegex:@"(\\*_|_\\*)" withString:@"=!="];
	
	// Split into all formatted parts. Note that the array doesn't contain any normal text, so we need to account for that!
	NSMutableArray *result = [NSMutableArray array];
	NSRange search = NSMakeRange(0, [simplified length]);
	NSArray *formats = [simplified arrayOfDictionariesByMatchingRegex:@"(?s:(\\*|_|`|=!=)(.*?)\\1)" withKeysAndCaptures:@"type", 1, @"value", 2, nil];
	for (NSDictionary *format in formats) {
		// Get range of next formatted section. If not found, exit (we'll deal with remaining after the loop). If we skipped some part of non-whitespace text, add it before handling formatted part!
		NSString *type = [format objectForKey:@"type"];
		NSRange range = [simplified rangeOfString:type options:0 range:search];
		if (range.location == NSNotFound) continue;
		if (range.location > search.location) {
			NSRange r = NSMakeRange(search.location, range.location - search.location);
			NSString *skipped = [simplified substringWithRange:r];
			NSString *text = [self strippedTextComponentFromString:skipped];
			if (text) [result addObject:[GBParagraphTextItem paragraphItemWithStringValue:text]];
		}
		
		// Get formatted text and prepare properly decorated component. Note that we warn the user if we find unknown decorator type (this probably just means we changed some decorator value by forgot to change this part, so it's some sort of "exception" catching).
		NSString *value = [format valueForKey:@"value"];
		if ([value length] > 0) {
			NSString *text = [self strippedTextComponentFromString:value];
			if (text) {
				GBParagraphDecoratorItem *decorator = [GBParagraphDecoratorItem paragraphItemWithStringValue:text];
				if ([type isEqualToString:@"*"]) {
					decorator.decorationType = GBDecorationTypeBold;
					decorator.decoratedItem = [GBParagraphTextItem paragraphItemWithStringValue:text];
				} else if ([type isEqualToString:@"_"]) {
					decorator.decorationType = GBDecorationTypeItalics;
					decorator.decoratedItem = [GBParagraphTextItem paragraphItemWithStringValue:text];
				} else if ([type isEqualToString:@"`"]) {
					decorator.decorationType = GBDecorationTypeCode;
					decorator.decoratedItem = [GBParagraphTextItem paragraphItemWithStringValue:text];
				} else if ([type isEqualToString:@"=!="]) {
					GBParagraphDecoratorItem *inner = [GBParagraphDecoratorItem paragraphItem];
					decorator.decorationType = GBDecorationTypeBold;
					decorator.decoratedItem = inner;
					inner.decorationType = GBDecorationTypeItalics;
					inner.decoratedItem = [GBParagraphTextItem paragraphItemWithStringValue:text];
				} else {
					GBLogError(@"Unknown text decorator type %@ detected!", type);
					decorator = nil;
				}
				if (decorator) [result addObject:decorator];
			}
		}
		
		// Prepare next search range.
		NSUInteger location = range.location + range.length * 2 + [value length];
		search = NSMakeRange(location, [simplified length] - location);
	}
	
	// If we have some remaining text, append it now.
	if ([simplified length] > search.location) {
		NSString *skipped = [simplified substringWithRange:search];
		NSString *text = [self strippedTextComponentFromString:skipped];
		if (text) [result addObject:[GBParagraphTextItem paragraphItemWithStringValue:text]];
	}
	return result;
}

- (NSString *)strippedTextComponentFromString:(NSString *)string {
	// Returns trimmed and stripped text where all occurences of whitespace are replaced with a single space. If text only contains whitespace, nil is returned.
	NSString *trimmed = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	if ([trimmed length] == 0) return nil;

	// Split all whitespace into single spaces.
	NSMutableString *result = [NSMutableString stringWithCapacity:[trimmed length]];
	NSArray *words = [trimmed componentsSeparatedByRegex:@"\\s+"];
	[words enumerateObjectsUsingBlock:^(NSString *word, NSUInteger idx, BOOL *stop) {
		if ([word length] == 0) return;
		if ([result length] > 0) [result appendString:@" "];
		[result appendString:word];
	}];
	
	// Return proper result based on the length.
	return ([result length] > 0) ? result : nil;
}

#pragma mark Helper methods

- (NSArray *)componentsSeparatedByEmptyLinesFromString:(NSString *)string {
	// We need to allow lines with tabs to properly detect empty example lines!
	return [string componentsSeparatedByRegex:[NSString stringWithFormat:@"(?m:^[ %@]*$)", self.newLinesRegexSymbols]];
}

- (NSArray *)componentsSeparatedByNewLinesFromString:(NSString *)string {
	return [string componentsSeparatedByRegex:[NSString stringWithFormat:@"(?:%@)", self.newLinesRegexSymbols]];
}

#pragma mark Properties

@synthesize newLinesRegexSymbols;
@synthesize spaceAndNewLineTrimRegex;
@synthesize settings;
@synthesize store;

@end
