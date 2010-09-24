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

- (BOOL)registerParagraphItemFromString:(NSString *)string toParagraph:(GBCommentParagraph **)paragraph;
- (GBCommentParagraph *)registerArgumentsFromString:(NSString *)string;
- (GBCommentArgument *)namedArgumentFromString:(NSString *)string usingRegex:(NSString *)regex matchLength:(NSUInteger *)length;
- (GBCommentParagraph *)simpleArgumentFromString:(NSString *)string usingRegex:(NSString *)regex matchLength:(NSUInteger *)length;
- (GBParagraphLinkItem *)linkArgumentFromString:(NSString *)string usingRegex:(NSString *)regex matchLength:(NSUInteger *)length;

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

- (GBParagraphLinkItem *)remoteMemberLinkItemFromString:(NSString *)string matchRange:(NSRange *)range;
- (GBParagraphLinkItem *)simpleLinkItemFromString:(NSString *)string matchRange:(NSRange *)range;

- (NSArray *)componentsSeparatedByEmptyLinesFromString:(NSString *)string;
- (NSArray *)componentsSeparatedByNewLinesFromString:(NSString *)string;

@property (retain) NSString *newLinesRegexSymbols;
@property (retain) NSString *spaceAndNewLineTrimRegex;
@property (retain) GBComment *currentComment;
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

- (void)processComment:(GBComment *)comment withStore:(id)store {
	[self processComment:comment withContext:nil store:store];
}

- (void)processComment:(GBComment *)comment withContext:(id<GBObjectDataProviding>)context store:(id)store {
	NSParameterAssert(comment != nil);
	NSParameterAssert(store != nil);
	NSParameterAssert([store conformsToProtocol:@protocol(GBStoreProviding)]);
	GBLogDebug(@"Processing comment %@ with store %@...", comment, store);
	self.currentComment = comment;
	self.currentContext = context;
	self.store = store;	
	NSArray *components = [self componentsSeparatedByEmptyLinesFromString:[self.currentComment stringValue]];
	__block GBCommentParagraph *paragraph = nil;
	[components enumerateObjectsUsingBlock:^(NSString *component, NSUInteger idx, BOOL *stop) {
		if ([self registerParagraphItemFromString:component toParagraph:&paragraph]) {
			[self.currentComment registerParagraph:paragraph];
		}
	}];	
	self.currentContext = nil;
}

#pragma mark Processing method arguments

- (BOOL)registerParagraphItemFromString:(NSString *)string toParagraph:(GBCommentParagraph **)paragraph {
	// Registers a single paragraph item contained in the given string to the given paragraph. Optionally we can allow creating a new paragraph for text. At the end we return YES if a new paragraph was created, NO otherwise. If a new paragraph was created, the instance is returned through paragraph parameter. It's up to caller to handle the paragraph.
	
	// As most components are given with preceeding new line, we should remove it to get cleaner testing.
	GBCommentComponentsProvider *componizer = self.settings.commentComponents;
	NSString *trimmed = [string stringByReplacingOccurrencesOfRegex:self.spaceAndNewLineTrimRegex withString:@""];
	
	// Match known paragraph parts. Note that order is important (like: lists must be processed before example sections).
	if ([trimmed isMatchedByRegex:componizer.unorderedListMatchRegex]) {
		BOOL create = (*paragraph == nil);
		if (create) *paragraph = [GBCommentParagraph paragraph];
		[self registerListFromString:trimmed toParagraph:*paragraph];
		return create;
	}
	if ([trimmed isMatchedByRegex:componizer.orderedListMatchRegex]) {
		BOOL create = (*paragraph == nil);
		if (create) *paragraph = [GBCommentParagraph paragraph];
		[self registerListFromString:trimmed toParagraph:*paragraph];
		return create;
	}
	if ([trimmed isMatchedByRegex:componizer.warningSectionRegex]) {
		BOOL create = (*paragraph == nil);
		if (create) *paragraph = [GBCommentParagraph paragraph];
		[self registerWarningFromString:trimmed toParagraph:*paragraph];
		return create;
	}
	if ([trimmed isMatchedByRegex:componizer.bugSectionRegex]) {
		BOOL create = (*paragraph == nil);
		if (create) *paragraph = [GBCommentParagraph paragraph];
		[self registerBugFromString:trimmed toParagraph:*paragraph];
		return create;
	}
	if ([trimmed isMatchedByRegex:componizer.exampleSectionRegex]) {
		BOOL create = (*paragraph == nil);
		if (create) *paragraph = [GBCommentParagraph paragraph];
		[self registerExampleFromString:trimmed toParagraph:*paragraph];
		return create;
	}
	
	// Match known comment parts. Note that we should register all remaining paragraph items to the created paragraph but return no as we shouldn't register the created paragraph as normal comment paragraph!
	if ([trimmed isMatchedByRegex:componizer.argumentsMatchingRegex]) {
		*paragraph = [self registerArgumentsFromString:trimmed];
		return NO;
	}
	
	// If no other match was found, this is simple text, so start new paragraph.
	*paragraph = [GBCommentParagraph paragraph];
	[self registerTextFromString:trimmed toParagraph:*paragraph];
	return YES;
}

- (GBCommentParagraph *)registerArgumentsFromString:(NSString *)string {
	// Processes the given string which only contains method arguments or cross reference. Method returns the last created paragraph as we need to append any subsequent paragraph items to it!
	GBCommentComponentsProvider *componizer = self.settings.commentComponents;
	NSString *parameterRegex = componizer.parameterDescriptionRegex;
	NSString *exceptionRegex = componizer.exceptionDescriptionRegex;
	NSString *returnRegex = componizer.returnDescriptionRegex;
	NSString *crossrefRegex = componizer.crossReferenceRegex;
	GBCommentParagraph *result = nil;
	while (YES) {
		NSUInteger length = 0;
		if ([string isMatchedByRegex:parameterRegex])
		{
			GBCommentArgument *argument = [self namedArgumentFromString:string usingRegex:parameterRegex matchLength:&length];
			[self.currentComment registerParameter:argument];
			result = argument.argumentDescription;
		} else if ([string isMatchedByRegex:exceptionRegex]) {
			GBCommentArgument *argument = [self namedArgumentFromString:string usingRegex:exceptionRegex matchLength:&length];
			[self.currentComment registerException:argument];
			result = argument.argumentDescription;
		} else if ([string isMatchedByRegex:returnRegex]) {
			GBCommentParagraph *value = [self simpleArgumentFromString:string usingRegex:returnRegex matchLength:&length];
			[self.currentComment registerResult:value];
			result = value;
		} else if ([string isMatchedByRegex:crossrefRegex]) {
			GBParagraphLinkItem *link = [self linkArgumentFromString:string usingRegex:crossrefRegex matchLength:&length];
			if (link) [self.currentComment registerCrossReference:link];
			result = nil;
		} else {
			NSString *directive = [string stringByMatching:componizer.argumentsMatchingRegex];
			GBLogWarn(@"%@: Directive %@ has invalid syntax in %@!", self.currentComment, directive, string);
		}
		if (length == [string length]) break;
		string = [string substringFromIndex:length];
	}
	return result;
}

- (GBCommentArgument *)namedArgumentFromString:(NSString *)string usingRegex:(NSString *)regex matchLength:(NSUInteger *)length {
	// Get argument name range from capture 1.
	NSRange nameRange = [string rangeOfRegex:regex capture:1];
	
	// Get the range of the next argument in the string or end of the string if this is last argument.
	NSUInteger location = nameRange.location + nameRange.length;
	NSRange remainingRange = NSMakeRange(location, [string length] - location);
	NSRange nextRange = [string rangeOfRegex:self.settings.commentComponents.nextArgumentRegex inRange:remainingRange];
	if (nextRange.location == NSNotFound) nextRange.location = [string length];
	
	// Prepare the range of the description and extract argument data from string. Note that we trim the description to remove possible tabbed prefix. The following code would assume this is an example section otherwise.
	NSRange descRange = NSMakeRange(location, nextRange.location - location);
	NSString *name = [string substringWithRange:nameRange];
	NSString *description = [self trimmedTextFromString:[string substringWithRange:descRange]];

	// Get the description into a paragraph, then create the argument and register the data.
	if (length) *length = descRange.location + descRange.length;
	GBCommentParagraph *paragraph = nil;
	[self registerParagraphItemFromString:description toParagraph:&paragraph];
	return [GBCommentArgument argumentWithName:name description:paragraph];
}

- (GBCommentParagraph *)simpleArgumentFromString:(NSString *)string usingRegex:(NSString *)regex matchLength:(NSUInteger *)length {
	// Get the range of the next argument in the string or end of the string if this is last argument.
	NSRange descRange = [string rangeOfRegex:regex capture:1];
	NSRange remainingRange = NSMakeRange(1, [string length] - 1);
	NSRange nextRange = [string rangeOfRegex:self.settings.commentComponents.nextArgumentRegex inRange:remainingRange];
	if (nextRange.location != NSNotFound) descRange.length -= ([string length] - nextRange.location);
	
	// Prepare the range of the description and extract argument data from string. Note that we trim the description to remove possible tabbed prefix. The following code would assume this is an example section otherwise.
	NSString *description = [self trimmedTextFromString:[string substringWithRange:descRange]];
	
	// Get the description into a paragraph, then create the argument and register the data.
	if (length) *length = descRange.location + descRange.length;
	GBCommentParagraph *paragraph = nil;
	[self registerParagraphItemFromString:description toParagraph:&paragraph];
	return paragraph;
}

- (GBParagraphLinkItem *)linkArgumentFromString:(NSString *)string usingRegex:(NSString *)regex matchLength:(NSUInteger *)length {
	// Get the range of the next argument in the string or end of the string if this is last argument.
	NSRange linkRange = [string rangeOfRegex:regex capture:1];
	NSRange remainingRange = NSMakeRange(1, [string length] - 1);
	NSRange nextRange = [string rangeOfRegex:self.settings.commentComponents.nextArgumentRegex inRange:remainingRange];
	if (nextRange.location != NSNotFound) linkRange.length -= ([string length] - nextRange.location);
	
	// Prepare the reference and extract data from string.
	NSString *reference = [string substringWithRange:linkRange];
	
	// Prepare the resulting link item. Note that we must first test for remote member reference!
	if (length) *length = linkRange.location + linkRange.length;
	GBParagraphLinkItem *item = [self remoteMemberLinkItemFromString:reference matchRange:NULL];
	if (!item) item = [self simpleLinkItemFromString:reference matchRange:NULL];
	return item;
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
			item = [GBParagraphListItem paragraphItem];
			item.isOrdered = ordered;
			[paragraph registerItem:item];
			[data setObject:indent forKey:@"indent"];
			[data setObject:item forKey:@"item"];
			[stack addObject:data];
		} else if ([indent length] > [[[stack lastObject] objectForKey:@"indent"] length]) {
			NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:3];
			item = [GBParagraphListItem paragraphItem];
			item.isOrdered = ordered;
			GBParagraphListItem *parent = [[stack lastObject] objectForKey:@"item"];
			[[[parent items] lastObject] registerItem:item];
			[data setObject:indent forKey:@"indent"];
			[data setObject:item forKey:@"item"];
			[stack addObject:data];
		} else if ([indent length] < [[[stack lastObject] objectForKey:@"indent"] length]) {
			while ([stack count] > 0 && [indent length] < [[[stack lastObject] objectForKey:@"indent"] length])
				[stack removeLastObject];
			item = [[stack lastObject] objectForKey:@"item"];
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
			GBLogWarn(@"%@: Found text '%@' at the start of the list:\n%@", self.currentComment, string); \
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
		GBLogWarn(@"%@: Empty example section found!", self.currentComment);
		return;
	}
	if ([example length] < [string length] - [lines count]) {
		NSString *remaining = [string substringFromIndex:[example length] + [lines count]];
		GBLogWarn(@"%@: Not all text was processed - '%@' was left, make sure an empty line without tabs is inserted before next paragraph!", self.currentComment, [remaining stringByReplacingOccurrencesOfRegex:self.spaceAndNewLineTrimRegex withString:@""]);
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
		GBLogWarn(@"%@: Empty special section of type %ld found!", self.currentComment, type);
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
		NSRange range;
		NSString *string = [item stringValue];
		while (YES) {
			GBParagraphLinkItem *link = [self remoteMemberLinkItemFromString:string matchRange:&range];
			if (!link) break;
			
			// If there's some skipped text in front of the match, linkify it.
			if (range.location > 0) {
				NSString *skipped = [string substringWithRange:NSMakeRange(0, range.location)];
				NSArray *children = [self paragraphSimpleLinkItemsFromString:skipped];
				[items addObjectsFromArray:children];
			}
			
			// Add the link item and continue search within remaining text.
			[items addObject:link];
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
	// Matches all known simple links (i.e. local member, object or URL) and prepares the array of all paragraph items.	
	NSMutableArray *result = [NSMutableArray array];
	NSMutableArray *staticText = [NSMutableArray array];
	NSArray *words = [string componentsSeparatedByRegex:@"\\s+"];
	[words enumerateObjectsUsingBlock:^(NSString *word, NSUInteger idx, BOOL *stop) {
		if ([word length] == 0) return;
		
		// If word is a link, create static text item if we have some prefix data, then add link.
		GBParagraphLinkItem *item = [self simpleLinkItemFromString:word matchRange:NULL];
		if (item) {
			GBCREATE_TEXT_ITEM;
			[result addObject:item];
			return;
		}
		
		// If word is no link, just add it to the list of static text.
		[staticText addObject:word];
	}];
	
	// Append remaining static text and exit.
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
					GBLogError(@"%@: Unknown text decorator type %@ detected!", self.currentComment, type);
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
	NSString *result = [string stringByWordifyingWithSpaces];
	return ([result length] > 0) ? result : nil;
}

- (NSString *)trimmedTextFromString:(NSString *)string {
	// Returns trimmed text where all occurences of whitespace at the start and end are stripped out. If text only contains whitespace, nil is returned.
	NSString *result = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	return ([result length] > 0) ? result : nil;
}

#pragma mark Processing cross references

- (GBParagraphLinkItem *)remoteMemberLinkItemFromString:(NSString *)string matchRange:(NSRange *)range {
	// Returns remote member link item or nil if not found within the string. Link is found regardless of the position of the link!
	NSString *regex = self.settings.commentComponents.remoteMemberCrossReferenceRegex;
	NSArray *components = [string captureComponentsMatchedByRegex:regex];
	if ([components count] == 0) return nil;
	
	// Get reference components and return match range within the string if requested.
	NSString *reference = [components objectAtIndex:0]; // Idx. 0 = full value of match.
	NSString *objectName = [components objectAtIndex:1];
	NSString *memberName = [components objectAtIndex:2];
	if (range) *range = [string rangeOfString:reference];
	
	// Find remote object first. If not found, issue a warning and exit.
	id objectRefence = [self.store classByName:objectName];
	if (!objectRefence) {
		objectRefence = [self.store categoryByName:objectName];
		if (!objectRefence) {
			objectRefence = [self.store protocolByName:objectName];
		}
	}
	if (!objectRefence) {
		GBLogWarn(@"%@: Invalid object reference: %@ object not found!", self.currentComment, objectName);
		return nil;
	}
	
	// If found, get the member reference.
	id memberReference = [[objectRefence methods] methodBySelector:memberName];
	if (memberReference) {
		NSString *stringValue = [reference stringByReplacingOccurrencesOfString:@"<" withString:@""];
		stringValue = [stringValue stringByReplacingOccurrencesOfString:@">" withString:@""];
		GBParagraphLinkItem *link = [GBParagraphLinkItem paragraphItemWithStringValue:stringValue];
		link.context = objectRefence;
		link.member = memberReference;
		link.isLocal = NO;
		return link;
	} else {
		GBLogWarn(@"%@: Invalid object reference for %@: member %@ not found!", self.currentComment, objectRefence, memberName);
		return nil;
	}
	
	return nil;
}

- (GBParagraphLinkItem *)simpleLinkItemFromString:(NSString *)string matchRange:(NSRange *)range {
	// Returns URL, local member or another known object link item or nil if the string doesn't represent the item.
	GBCommentComponentsProvider *provider = self.settings.commentComponents;

	// Test for URL reference.
	NSString *url = [string stringByMatching:provider.urlCrossReferenceRegex capture:1];
	if (url) {
		GBParagraphLinkItem *item = [GBParagraphLinkItem paragraphItemWithStringValue:url];
		if (range) *range = NSMakeRange(0, [string length]);
		return item;
	}
	
	// Test for local member reference (only if current context is given).
	if (self.currentContext) {
		NSString *selector = [string stringByMatching:provider.localMemberCrossReferenceRegex capture:1];
		if (selector) {
			GBMethodData *method = [self.currentContext.methods methodBySelector:selector];
			if (method) {
				GBParagraphLinkItem *item = [GBParagraphLinkItem paragraphItemWithStringValue:selector];
				item.context = self.currentContext;
				item.member = method;
				item.isLocal = YES;
				if (range) *range = NSMakeRange(0, [string length]);
				return item;
			}
		}
	}
	
	// Test for local or remote object reference.
	NSString *objectName = [string stringByMatching:provider.objectCrossReferenceRegex capture:1];
	if (objectName) {
		GBClassData *class = [self.store classByName:objectName];
		if (class) {
			GBParagraphLinkItem *item = [GBParagraphLinkItem paragraphItemWithStringValue:class.nameOfClass];
			item.context = class;
			item.isLocal = (class == self.currentContext);
			if (range) *range = NSMakeRange(0, [string length]);
			return item;
		}
		GBCategoryData *category = [self.store categoryByName:objectName];
		if (category) {
			GBParagraphLinkItem *item = [GBParagraphLinkItem paragraphItemWithStringValue:category.idOfCategory];
			item.context = category;
			item.isLocal = (category == self.currentContext);
			if (range) *range = NSMakeRange(0, [string length]);
			return item;
		}
		GBProtocolData *protocol = [self.store protocolByName:objectName];
		if (protocol) {
			GBParagraphLinkItem *item = [GBParagraphLinkItem paragraphItemWithStringValue:protocol.nameOfProtocol];
			item.context = protocol;
			item.isLocal = (protocol == self.currentContext);
			if (range) *range = NSMakeRange(0, [string length]);
			return item;
		}
	}
	
	return nil;
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
@synthesize currentComment;
@synthesize currentContext;
@synthesize settings;
@synthesize store;

@end
