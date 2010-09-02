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
		GBLogWarn(@"Not all text was processed - '%@' was left, make sure an empty line without tabs is inserted before next paragraph!", [remaining stringByReplacingOccurrencesOfRegex:self.spaceAndNewLineTrimRegex withString:@"");
		return;
	}
	
	// Prepare paragraph item and process the text.
	GBParagraphSpecialItem *item = [GBParagraphSpecialItem specialItemWithType:GBSpecialItemTypeExample stringValue:string];
	GBCommentParagraph *para = [GBCommentParagraph paragraph];
	[para registerItem:[GBParagraphTextItem paragraphItemWithStringValue:example]];
	[item registerParagraph:para];
	
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
	// Strip all whitespace and convert text into a single line with words separated with spaces.
	NSArray *componentParts = [string componentsSeparatedByRegex:@"\\s+"];
	NSMutableString *strippedPartValue = [NSMutableString stringWithCapacity:[string length]];
	[componentParts enumerateObjectsUsingBlock:^(NSString *componentPart, NSUInteger idx, BOOL *stop) {
		if ([componentPart length] == 0) return;
		if ([strippedPartValue length] > 0) [strippedPartValue appendString:@" "];
		[strippedPartValue appendString:componentPart];
	}];
	
	// Register text item to the paragraph.
	GBParagraphTextItem *item = [GBParagraphTextItem paragraphItemWithStringValue:strippedPartValue];
	[paragraph registerItem:item];
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
