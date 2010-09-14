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

- (void)registerListFromString:(NSString *)string toParagraph:(GBCommentParagraph *)paragraph;
- (NSArray *)flattenedListItemsFromString:(NSString *)string;
- (NSString *)regexMatchingFirstListItemInString:(NSString *)string matchedRange:(NSRange *)range ordered:(BOOL *)ordered;

- (void)registerWarningFromString:(NSString *)string toParagraph:(GBCommentParagraph *)paragraph;
- (void)registerBugFromString:(NSString *)string toParagraph:(GBCommentParagraph *)paragraph;
- (void)registerExampleFromString:(NSString *)string toParagraph:(GBCommentParagraph *)paragraph;
- (void)registerSpecialFromString:(NSString *)string type:(GBSpecialItemType)type usingRegex:(NSString *)regex toParagraph:(GBCommentParagraph *)paragraph;

- (void)registerTextFromString:(NSString *)string toParagraph:(GBCommentParagraph *)paragraph;
- (NSArray *)linkifiedParagraphItemsFromItem:(GBParagraphItem *)item;
- (NSArray *)paragraphSimpleLinkItemsFromString:(NSString *)string;
- (NSArray *)paragraphTextItemsFromString:(NSString *)string;
- (NSString *)wordifiedTextFromString:(NSString *)string;
- (NSString *)trimmedTextFromString:(NSString *)string;

- (NSArray *)componentsSeparatedByEmptyLinesFromString:(NSString *)string;
- (NSArray *)componentsSeparatedByNewLinesFromString:(NSString *)string;

@property (retain) NSString *newLinesRegexSymbols;
@property (retain) NSString *spaceAndNewLineTrimRegex;
@property (retain) id<GBObjectDataProviding> currentContext;
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

- (void)processComment:(GBComment *)comment withContext:(id<GBObjectDataProviding>)context store:(id)store {
#define GBRegister(code) \
	BOOL shouldRegisterParagraph = (currentParagraph == nil); \
	if (shouldRegisterParagraph) currentParagraph = [GBCommentParagraph paragraph]; \
	code; \
	if (shouldRegisterParagraph) [comment registerParagraph:currentParagraph]

	NSParameterAssert(comment != nil);
	NSParameterAssert(store != nil);
	NSParameterAssert([store conformsToProtocol:@protocol(GBStoreProviding)]);
	GBLogDebug(@"Processing comment with store %@...", store);
	self.currentContext = context;
	self.store = store;	
	GBCommentComponentsProvider *componizer = self.settings.commentComponents;
	NSArray *components = [self componentsSeparatedByEmptyLinesFromString:[comment stringValue]];
	__block GBCommentParagraph *currentParagraph = nil;
	[components enumerateObjectsUsingBlock:^(NSString *component, NSUInteger idx, BOOL *stop) {
		// As most components are given with preceeding new line, we should remove it to get cleaner testing.
		NSString *trimmed = [component stringByReplacingOccurrencesOfRegex:self.spaceAndNewLineTrimRegex withString:@""];

		// Match known parts. Note that order is important for certain items (lists must be processed before examples for example).
		if ([trimmed isMatchedByRegex:componizer.unorderedListMatchRegex]) {
			GBRegister([self registerListFromString:trimmed toParagraph:currentParagraph]);
			return;
		}
		if ([trimmed isMatchedByRegex:componizer.orderedListMatchRegex]) {
			GBRegister([self registerListFromString:trimmed toParagraph:currentParagraph]);
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
	self.currentContext = nil;
}

- (void)processComment:(GBComment *)comment withStore:(id)store {
	[self processComment:comment withContext:nil store:store];
}

#pragma mark Processing paragraph lists

- (void)registerListFromString:(NSString *)string toParagraph:(GBCommentParagraph *)paragraph {
	// Each list is contained within GBParagraphListItem which can contain normal paragraph texts (each represents a list item) and sublists (each represented with another list item instance). Note that it names might be a bit confusing from the start: GBParagraphListItem holds a description of the whole list, while it's items (in the form of GBCommentParagraph), hold individual list's items texts (as GBParagraphTextItem) or sublists (again as GBParagraphListItem instance).
	NSArray *flattenedItems = [self flattenedListItemsFromString:string];
	NSMutableArray *stack = [NSMutableArray arrayWithCapacity:[flattenedItems count]];
	[flattenedItems enumerateObjectsUsingBlock:^(NSDictionary *itemData, NSUInteger idx, BOOL *stop) {
		// Get item data.
		NSString *description = [self trimmedTextFromString:[itemData objectForKey:@"description"]];
		NSString *indent = [itemData objectForKey:@"indent"];
		BOOL ordered = [[itemData objectForKey:@"ordered"] boolValue];
		
		// Determine level from indentation. If we use the same indentation, we need to create a new list item for the current list (also create the list item object if this is the first item). If indentation is greater, we need to create a sublist, otherwise we need to close sublist(s).
		GBParagraphListItem *item = nil;
		if ([stack count] == 0) {
			NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:3];
			item = [GBParagraphListItem paragraphItemWithStringValue:string];
			item.isOrdered = ordered;
			[paragraph registerItem:item];
			[data setObject:indent forKey:@"indent"];
			[data setObject:item forKey:@"item"];
			[stack addObject:data];
		} else if ([indent length] > [[[stack lastObject] objectForKey:@"indent"] length]) {
			NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:3];
			item = [GBParagraphListItem paragraphItemWithStringValue:string];
			item.isOrdered = ordered;
			[[[stack lastObject] objectForKey:@"item"] registerItem:item];
			[data setObject:indent forKey:@"indent"];
			[data setObject:item forKey:@"item"];
			[stack addObject:data];
		} else {
			item = [[stack lastObject] objectForKey:@"item"];
		}
		
		// Create the paragraph that will hold this item's text.
		GBCommentParagraph *itemParagraph = [GBCommentParagraph paragraph];
		[self registerTextFromString:description toParagraph:itemParagraph];
		[item registerItem:itemParagraph];
	}];
}

- (NSArray *)flattenedListItemsFromString:(NSString *)string {
	// Returns flattened array of all items data from the given string. Note that empty descriptions are also returned - as we can add some text to previously empty string in the next iteration, it's simpler to test afterwards.
#define GBAPPEND_STRING_TO_PREVIOUS_DESCRIPTION(string) \
	NSString *text = [self trimmedTextFromString:string]; \
	if ([text length] > 0) { \
		if ([result count] > 0) { \
			NSMutableDictionary *previousData = [result lastObject]; \
			NSString *previousDesc = [previousData objectForKey:@"description"]; \
			[previousData setObject:[NSString stringWithFormat:@"%@%@", previousDesc, text] forKey:@"description"]; \
		} else { \
			GBLogWarn(@"Found text '%@' at the start of the list:\n%@", string); \
		} \
	}
	NSMutableArray *result = [NSMutableArray array];
	while (YES) {
		// Get data required for matching next item, exit the loop if no more match is found.
		NSRange range;
		BOOL ordered;
		NSString *regex = [self regexMatchingFirstListItemInString:string matchedRange:&range ordered:&ordered];
		if (!regex) break;
		
		// Get item data and delete the chars from string. If the match is found after string start, append the text to previous item (this is important as current regex only matches until the end of the line)! However if there is no item in the list warn the user about unused text (shouldn't really happen, but just in case).
		NSString *capture = [string substringWithRange:range];
		if (range.location > 0) {
			GBAPPEND_STRING_TO_PREVIOUS_DESCRIPTION([string substringToIndex:range.location]);
		}
		string = [string substringFromIndex:range.location + range.length];
		
		// Prepare item data.
		NSDictionary *captures = [capture dictionaryByMatchingRegex:regex withKeysAndCaptures:@"indent", 1, @"description", 2, nil];
		NSMutableDictionary *itemData = [NSMutableDictionary dictionaryWithCapacity:4];
		[itemData setObject:[captures objectForKey:@"description"] forKey:@"description"];
		[itemData setObject:[captures objectForKey:@"indent"] forKey:@"indent"];
		[itemData setObject:[NSNumber numberWithBool:ordered] forKey:@"ordered"];
		[result addObject:itemData];
	}
	GBAPPEND_STRING_TO_PREVIOUS_DESCRIPTION(string);
	return result;
}

- (NSString *)regexMatchingFirstListItemInString:(NSString *)string matchedRange:(NSRange *)range ordered:(BOOL *)ordered {
	// Returns the regex used for matching the first list item in the given string and range of the item within the string.
	NSRange range1 = [string rangeOfRegex:self.settings.commentComponents.unorderedListRegex];
	NSRange range2 = [string rangeOfRegex:self.settings.commentComponents.orderedListRegex];
	
	// No item found, return nil.
	if (range1.location == NSNotFound && range2.location == NSNotFound) return nil;
	
	// If unordered item was found before ordered or ordered item not found at all, return unordered item data.
	if (range1.location != NSNotFound && range1.location < range2.location) {
		if (range) *range = range1;
		if (ordered) *ordered = NO;
		return self.settings.commentComponents.unorderedListRegex;
	}
	
	// If ordered item was found before unordered or unordered item not found at all, return ordered item data.
	if (range) *range = range2;
	if (ordered) *ordered = YES;
	return self.settings.commentComponents.orderedListRegex;
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
	// Get all components and post-process them for links and finaly register everything.
	NSArray *items = [self paragraphTextItemsFromString:string];
	[items enumerateObjectsUsingBlock:^(GBParagraphItem *item, NSUInteger idx, BOOL *stop) {
		// Split the item if links are detected and register all resulting items to the paragraph.
		NSArray *linkified = [self linkifiedParagraphItemsFromItem:item];		
		[linkified enumerateObjectsUsingBlock:^(GBParagraphItem *item, NSUInteger idx, BOOL *stop) {
			[paragraph registerItem:item];
		}];
	}];
}

- (NSArray *)linkifiedParagraphItemsFromItem:(GBParagraphItem *)item {
	// Processes GBParagraphItem's text for links and converts string value to words separated with spaces. If links are detected, the item is "split" to several GBParagraphTextItem and GBParagraphLinkItem instances as necessary and the array of all resulting items in proper order is returned. If the item doesn't contain any link, the array with a single object - the passed in item - is returned. If the given item is GBParagraphDecoratorItem, it's string value is wordified and decorated children items are recursively processed. If the item is anythin else, only it's string value is wordified.
	if ([item isKindOfClass:[GBParagraphDecoratorItem class]]) {
		GBParagraphDecoratorItem *decorator = (GBParagraphDecoratorItem *)item;
		NSMutableArray *linkifiedChildren = [NSMutableArray arrayWithCapacity:[decorator.decoratedItems count]];
		[decorator.decoratedItems enumerateObjectsUsingBlock:^(GBParagraphItem *child, NSUInteger idx, BOOL *stop) {
			NSArray *childsLinkifiedChildren = [self linkifiedParagraphItemsFromItem:child];
			[linkifiedChildren addObjectsFromArray:childsLinkifiedChildren];
		}];
		[decorator replaceItemsByRegisteringItemsFromArray:linkifiedChildren];
		decorator.stringValue = [self wordifiedTextFromString:decorator.stringValue];
		return [NSArray arrayWithObject:decorator];
	}
	
	// We only handle links for GBParagraphTextItem which we convert into an array of text/link items as needed. Note that if we detect a link, we don't even return the original item, but we create new items instead! We progressively scan item's string value for complex references and then we check the remaining text for local members or other objects links. We first split the original text with remote member links, then we scan the rest for other references.
	else if ([item isKindOfClass:[GBParagraphTextItem class]]) {
		NSMutableArray *items = [NSMutableArray array];
		NSString *regex = self.settings.commentComponents.remoteMemberCrossReferenceRegex;
		NSString *string = [item stringValue];
		while (YES) {
			// Get the first occurence of the match within current range. Exit if no more found.
			NSArray *components = [string captureComponentsMatchedByRegex:regex];
			if ([components count] == 0) break;
			
			// Get reference components.
			NSString *reference = [components objectAtIndex:0]; // Idx. 0 = full value of match.
			NSString *objectName = [components objectAtIndex:1];
			NSString *memberName = [components objectAtIndex:2];
			
			// If there's some skipped text in front of the match, linkify it.
			NSRange range = [string rangeOfString:reference];
			if (range.location > 0) {
				NSString *skipped = [string substringWithRange:NSMakeRange(0, range.location)];
				NSArray *children = [self paragraphSimpleLinkItemsFromString:skipped];
				[items addObjectsFromArray:children];
			}
			
			// Find remote object first.
			id objectRefence = [self.store classByName:objectName];
			if (!objectRefence) {
				objectRefence = [self.store categoryByName:objectName];
				if (!objectRefence) {
					objectRefence = [self.store protocolByName:objectName];
				}
			}
			
			// If found, get the member reference.
			id memberReference = nil;
			if (objectRefence) {
				memberReference = [[objectRefence methods] methodBySelector:memberName];
				if (memberReference) {
					NSString *stringValue = [reference stringByReplacingOccurrencesOfString:@"<" withString:@""];
					stringValue = [stringValue stringByReplacingOccurrencesOfString:@">" withString:@""];
					GBParagraphLinkItem *link = [GBParagraphLinkItem paragraphItemWithStringValue:stringValue];
					link.context = objectRefence;
					link.member = memberReference;
					link.isLocal = NO;
					[items addObject:link];
				} else {
					GBLogWarn(@"Invalid object reference for %@: member %@ not found!", objectRefence, memberName);
				}
			} else {
				GBLogWarn(@"Invalid object reference: %@ object not found!", objectName);
			}
			
			// If not found, add static text instead!
			if (!objectRefence || !memberReference) {
				GBParagraphTextItem *item = [GBParagraphTextItem paragraphItemWithStringValue:string];
				[items addObject:item];
			}
			
			// Search within the text after the match if there is some more.
			string = [string substringFromIndex:range.location + range.length];
		}
		
		// Linkify remaining text if any.
		if ([string length] > 0) {
			NSArray *children = [self paragraphSimpleLinkItemsFromString:string];
			[items addObjectsFromArray:children];
		}
		return items;
	}
	
	// For all other items, just wordify string value to get nicer debug and unit testing strings.
	item.stringValue = [self wordifiedTextFromString:item.stringValue];
	return [NSArray arrayWithObject:item];
}

- (NSArray *)paragraphSimpleLinkItemsFromString:(NSString *)string {
#define GBCREATE_TEXT_ITEM \
	if ([staticText count] > 0) { \
		NSMutableString *value = [NSMutableString string]; \
		[staticText enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) { \
			if ([value length] > 0) [value appendString:@" "]; \
			[value appendString:obj]; \
		}]; \
		GBParagraphTextItem *item = [GBParagraphTextItem paragraphItemWithStringValue:value]; \
		[result addObject:item]; \
		[staticText removeAllObjects]; \
	}
#define GBCREATE_OBJECT_LINK_ITEM(obj,str) \
	GBParagraphLinkItem *item = [GBParagraphLinkItem paragraphItemWithStringValue:str]; \
	item.context = obj; \
	item.isLocal = (obj == self.currentContext); \
	[result addObject:item]
	// Matches all known simple links (i.e. local member, object or URL) and prepares the array of all paragraph items.	
	NSMutableArray *result = [NSMutableArray array];
	NSMutableArray *staticText = [NSMutableArray array];
	GBCommentComponentsProvider *provider = self.settings.commentComponents;
	NSArray *words = [string componentsSeparatedByRegex:@"\\s+"];
	[words enumerateObjectsUsingBlock:^(NSString *word, NSUInteger idx, BOOL *stop) {
		if ([word length] == 0) return;
		
		// Test for URL reference.
		NSString *url = [word stringByMatching:provider.urlCrossReferenceRegex capture:1];
		if (url) {
			GBCREATE_TEXT_ITEM;
			GBParagraphLinkItem *item = [GBParagraphLinkItem paragraphItemWithStringValue:url];
			[result addObject:item];
			return;
		}
		
		// Test for local member reference (only if current context is given).
		if (self.currentContext) {
			NSString *selector = [word stringByMatching:provider.localMemberCrossReferenceRegex capture:1];
			if (selector) {
				GBMethodData *method = [self.currentContext.methods methodBySelector:selector];
				if (method) {
					GBCREATE_TEXT_ITEM;
					GBParagraphLinkItem *item = [GBParagraphLinkItem paragraphItemWithStringValue:selector];
					item.context = self.currentContext;
					item.member = method;
					item.isLocal = YES;
					[result addObject:item];
					return;
				}
			}
		}
		
		// Test for local or remote object reference.
		NSString *objectName = [word stringByMatching:provider.objectCrossReferenceRegex capture:1];
		if (objectName) {
			GBClassData *class = [self.store classByName:objectName];
			if (class) {
				GBCREATE_TEXT_ITEM;
				GBCREATE_OBJECT_LINK_ITEM(class, class.nameOfClass);
				return;
			}
			GBCategoryData *category = [self.store categoryByName:objectName];
			if (category) {
				GBCREATE_TEXT_ITEM;
				GBCREATE_OBJECT_LINK_ITEM(category, category.idOfCategory);
				return;
			}
			GBProtocolData *protocol = [self.store protocolByName:objectName];
			if (protocol) {
				GBCREATE_TEXT_ITEM;
				GBCREATE_OBJECT_LINK_ITEM(protocol, protocol.nameOfProtocol);
				return;
			}
		}
		
		// If word is no link, just add it to the list.
		[staticText addObject:word];
	}];
	
	GBCREATE_TEXT_ITEM;
	return result;
}

- (NSArray *)paragraphTextItemsFromString:(NSString *)string {
	// Splits given string into un/formatted parts to make further processing simpler. To simplify we first convert nested case markers into something different from single ones, so that we can then handle them all in the same loop. Note that we keep all paragraph item's texts intact - we'll process them later when handling links. Resulting array only contains GBParagraphTextItem or GBParagraphDecoratorItem instances!
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
			NSString *text = [self trimmedTextFromString:skipped];
			if (text) [result addObject:[GBParagraphTextItem paragraphItemWithStringValue:text]];
		}
		
		// Get formatted text and prepare properly decorated component. Note that we warn the user if we find unknown decorator type (this probably just means we changed some decorator value by forgot to change this part, so it's some sort of "exception" catching).
		NSString *value = [format valueForKey:@"value"];
		if ([value length] > 0) {
			NSString *text = [self trimmedTextFromString:value];
			if (text) {
				GBParagraphDecoratorItem *decorator = [GBParagraphDecoratorItem paragraphItemWithStringValue:text];
				if ([type isEqualToString:@"*"]) {
					decorator.decorationType = GBDecorationTypeBold;
					[decorator registerItem:[GBParagraphTextItem paragraphItemWithStringValue:text]];
				} else if ([type isEqualToString:@"_"]) {
					decorator.decorationType = GBDecorationTypeItalics;
					[decorator registerItem:[GBParagraphTextItem paragraphItemWithStringValue:text]];
				} else if ([type isEqualToString:@"`"]) {
					decorator.decorationType = GBDecorationTypeCode;
					[decorator registerItem:[GBParagraphTextItem paragraphItemWithStringValue:text]];
				} else if ([type isEqualToString:@"=!="]) {
					GBParagraphDecoratorItem *inner = [GBParagraphDecoratorItem paragraphItemWithStringValue:text];
					decorator.decorationType = GBDecorationTypeBold;
					[decorator registerItem:inner];
					inner.decorationType = GBDecorationTypeItalics;
					[inner registerItem:[GBParagraphTextItem paragraphItemWithStringValue:text]];
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
		NSString *text = [self trimmedTextFromString:skipped];
		if (text) [result addObject:[GBParagraphTextItem paragraphItemWithStringValue:text]];
	}
	return result;
}

- (NSString *)wordifiedTextFromString:(NSString *)string {
	// Strips the given text of all whitespace and returns all words separated by a single space. If text only contains whitespace, nil is returned.
	if ([string length] == 0) return nil;
	NSMutableString *result = [NSMutableString stringWithCapacity:[string length]];
	NSArray *words = [string componentsSeparatedByRegex:@"\\s+"];
	[words enumerateObjectsUsingBlock:^(NSString *word, NSUInteger idx, BOOL *stop) {
		if ([word length] == 0) return;
		if ([result length] > 0) [result appendString:@" "];
		[result appendString:word];
	}];
	return ([result length] > 0) ? result : nil;
}

- (NSString *)trimmedTextFromString:(NSString *)string {
	// Returns trimmed text where all occurences of whitespace at the start and end are stripped out. If text only contains whitespace, nil is returned.
	NSString *result = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
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
@synthesize currentContext;
@synthesize settings;
@synthesize store;

@end
