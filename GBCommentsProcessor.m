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
- (void)registerSpecialFromString:(NSString *)string type:(GBSpecialItemType)type usingRegex:(NSString *)regex toParagraph:(GBCommentParagraph *)paragraph;
- (void)registerTextFromString:(NSString *)string toParagraph:(GBCommentParagraph *)paragraph;
- (NSArray *)componentsSeparatedByEmptyLinesFromString:(NSString *)string;
- (NSArray *)componentsSeparatedByNewLinesFromString:(NSString *)string;
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
		NSString *spaceAndNewLineRegex = [NSString stringWithUTF8String:"(?:\\r\n|[ \n\\v\\f\\r\302\205\\p{Zl}\\p{Zp}])+"];
		self.spaceAndNewLineTrimRegex = [NSString stringWithFormat:@"^%@|%@$", spaceAndNewLineRegex, spaceAndNewLineRegex];
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
		// Match known parts.
		if ([component isMatchedByRegex:componizer.unorderedListRegex]) {
			GBRegister([self registerUnorderedListFromString:component toParagraph:currentParagraph]);
			return;
		}
		if ([component isMatchedByRegex:componizer.orderedListRegex]) {
			GBRegister([self registerOrderedListFromString:component toParagraph:currentParagraph]);
			return;
		}
		if ([component isMatchedByRegex:componizer.warningSectionRegex]) {
			GBRegister([self registerWarningFromString:component toParagraph:currentParagraph]);
			return;
		}
		if ([component isMatchedByRegex:componizer.bugSectionRegex]) {
			GBRegister([self registerBugFromString:component toParagraph:currentParagraph]);
			return;
		}
		
		// If no other match was found, this is simple text, so start new paragraph.
		currentParagraph = [GBCommentParagraph paragraph];
		[self registerTextFromString:component toParagraph:currentParagraph];
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
	// Sometimes we can get newlines and spaces before or after the component, so remove them first, then use trimmed string as list's string value.
	NSString *trimmed = [string stringByReplacingOccurrencesOfRegex:self.spaceAndNewLineTrimRegex withString:@""];
	GBParagraphListItem *item = [GBParagraphListItem paragraphItemWithStringValue:trimmed];
	item.isOrdered = ordered;
	
	// Split the block of all list items to individual items, then process and register each one.
	NSArray *items = [trimmed componentsSeparatedByRegex:regex];
	[items enumerateObjectsUsingBlock:^(NSString *description, NSUInteger idx, BOOL *stop) {
		if ([description length] == 0) {
			GBLogWarn(@"%ld. item has empty description for list:\n%@", idx, trimmed);
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

- (void)registerSpecialFromString:(NSString *)string type:(GBSpecialItemType)type usingRegex:(NSString *)regex toParagraph:(GBCommentParagraph *)paragraph {
	// Get the description from the string. If empty, warn and exit.
	NSString *trimmed = [string stringByReplacingOccurrencesOfRegex:self.spaceAndNewLineTrimRegex withString:@""];
	NSString *description = [trimmed stringByMatching:regex capture:1];
	if ([description length] == 0) {
		GBLogWarn(@"Empty special section of type %ld found!", type);
		return;
	}
	
	// Prepare paragraph item and process the text.
	GBParagraphSpecialItem *item = [GBParagraphSpecialItem specialItemWithType:type stringValue:trimmed];
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
	return [string componentsSeparatedByRegex:@"(?m:^\\s*$)"];
}

- (NSArray *)componentsSeparatedByNewLinesFromString:(NSString *)string {
	return [string componentsSeparatedByRegex:[NSString stringWithUTF8String:"(?:\\r\n|[\n\\v\\f\\r\302\205\\p{Zl}\\p{Zp}])"]];
}

#pragma mark Properties

@synthesize spaceAndNewLineTrimRegex;
@synthesize settings;
@synthesize store;

@end
