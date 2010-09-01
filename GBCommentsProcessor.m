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
- (void)registerTextFromString:(NSString *)string toParagraph:(GBCommentParagraph *)paragraph;
- (NSArray *)componentsSeparatedByEmptyLinesFromString:(NSString *)string;
- (NSArray *)componentsSeparatedByNewLinesFromString:(NSString *)string;
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
		
		// If no other match was found, this is simple text, so start new paragraph.
		currentParagraph = [GBCommentParagraph paragraph];
		[self registerTextFromString:component toParagraph:currentParagraph];
		[comment registerParagraph:currentParagraph];
	}];
}

- (void)registerUnorderedListFromString:(NSString *)string toParagraph:(GBCommentParagraph *)paragraph {
	GBParagraphListItem *paragraphItem = [GBParagraphListItem paragraphItemWithStringValue:string];

	// Split the block of all list items to individual items, then process and register each one.
	NSArray *items = [string componentsSeparatedByRegex:self.settings.commentComponents.unorderedListPrefixRegex];
	[items enumerateObjectsUsingBlock:^(NSString *description, NSUInteger idx, BOOL *stop) {
		if ([description length] == 0) return;
		GBCommentParagraph *itemParagraph = [GBCommentParagraph paragraph];
		[self registerTextFromString:description toParagraph:itemParagraph];
		[paragraphItem registerItem:itemParagraph];
	}];
	
	// Register list item to paragraph.
	[paragraph registerItem:paragraphItem];
}

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

- (void)registerComponent:(NSString *)component toComment:(GBComment *)comment {
	// Strip all whitespace and convert paragraph text into a single line with words separated with spaces.
	NSArray *componentParts = [component componentsSeparatedByRegex:@"\\s+"];
	NSMutableString *strippedPartValue = [NSMutableString stringWithCapacity:[component length]];
	[componentParts enumerateObjectsUsingBlock:^(NSString *componentPart, NSUInteger idx, BOOL *stop) {
		if ([componentPart length] == 0) return;
		if ([strippedPartValue length] > 0) [strippedPartValue appendString:@" "];
		[strippedPartValue appendString:componentPart];
	}];
	
	// Register new paragraph with the item.
	GBCommentParagraph *paragraph = [GBCommentParagraph paragraph];
	GBParagraphTextItem *item = [GBParagraphTextItem paragraphItemWithStringValue:strippedPartValue];
	[paragraph registerItem:item];
	[comment registerParagraph:paragraph];
}

- (NSArray *)componentsSeparatedByEmptyLinesFromString:(NSString *)string {
	return [string componentsSeparatedByRegex:@"(?m:^\\s*$)"];
}

- (NSArray *)componentsSeparatedByNewLinesFromString:(NSString *)string {
	return [string componentsSeparatedByRegex:[NSString stringWithUTF8String:"(?:\\r\n|[\n\\v\\f\\r\302\205\\p{Zl}\\p{Zp}])"]];
}

#pragma mark Properties

@synthesize settings;
@synthesize store;

@end
