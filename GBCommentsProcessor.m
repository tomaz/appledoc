//
//  GBCommentsProcessor.m
//  appledoc
//
//  Created by Tomaz Kragelj on 27.8.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBApplicationSettingsProviding.h"
#import "GBStoreProviding.h"
#import "GBDataObjects.h"
#import "GBCommentsProcessor.h"

@interface GBCommentsProcessor ()

- (void)registerDerivedValuesToComment:(GBComment *)comment fromItems:(NSArray *)items;
- (NSArray *)itemsFromTrimmedLines:(NSArray *)lines;
- (NSArray *)trimmedLinesFromString:(NSString *)string;
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
	NSParameterAssert(comment != nil);
	NSParameterAssert(store != nil);
	NSParameterAssert([store conformsToProtocol:@protocol(GBStoreProviding)]);
	GBLogDebug(@"Processing comment with store %@...", store);
	self.store = store;
	NSArray *lines = [self trimmedLinesFromString:[comment stringValue]];
	NSArray *items = [self itemsFromTrimmedLines:lines];
	[self registerDerivedValuesToComment:comment fromItems:items];
}

- (void)registerDerivedValuesToComment:(GBComment *)comment fromItems:(NSArray *)items {
	for (NSString *item in items) {
		GBCommentParagraph *paragraph = [GBCommentParagraph paragraph];
		paragraph.stringValue = item;
		[comment registerParagraph:paragraph];
	}
}

- (NSArray *)itemsFromTrimmedLines:(NSArray *)lines {
	// Converts individual lines to individual comment items:
	// - warning section string values (each array entry is a single warning description)
	// - bug section string values (each array entry is a single bug description)
	// - ordered or unordered list string values (each array entry contains a single list item!)
	// - example code string values (each array entry contains all lines of the example!)
	// - parameter string values (each array entry is a single parameter with full description paragraph)
	// - return string value (each array entry is a single return value)
	// - exception string values (each array entry is a single exception with full description paragraph)
	// - see also string values (each array entry is a single see also item)
	// - paragraph string values (each array entry contains a single, full parameter text with new lines removed)
#define GBAppendCurrentItemAndResetTo(l) { \
	if ([currentItem length] > 0) [items addObject:[currentItem copy]]; \
	if (l) [currentItem setString:l]; \
}

	GBCommentComponentsProvider *componetizer = self.settings.commentComponents;
	NSMutableArray *items = [NSMutableArray array];
	NSMutableString *currentItem = [NSMutableString string];
	for (NSString *line in lines) {
		// First handle known objects.
		if ([componetizer stringDefinesWarning:line])
			GBAppendCurrentItemAndResetTo(line)
		else if ([componetizer stringDefinesBug:line])
			GBAppendCurrentItemAndResetTo(line)
		else if ([componetizer stringDefinesParameter:line])
			GBAppendCurrentItemAndResetTo(line)
		else if ([componetizer stringDefinesReturn:line])
			GBAppendCurrentItemAndResetTo(line)
		else if ([componetizer stringDefinesException:line])
			GBAppendCurrentItemAndResetTo(line)
		else if ([componetizer stringDefinesCrossReference:line])
			GBAppendCurrentItemAndResetTo(line)
			
		// End paragraph if necessary.
		else if ([line length] == 0)
			GBAppendCurrentItemAndResetTo(@"")
			
		// Append text to paragraph.
		else if ([currentItem length] > 0)
			[currentItem appendFormat:@" %@", line];
		else
			[currentItem appendString:line];
	}
	
	GBAppendCurrentItemAndResetTo(nil);
	return items;
}

- (NSArray *)trimmedLinesFromString:(NSString *)string {
	// Note that we can't simply delete all new lines as this will put all list items, parameters etc. in single line which will make post processing harder. This code is copied from apple documentation. After getting the lines, we trim all spaces from both ends, but we do keep tabs as we need them for detecting example lines.
	NSCharacterSet *newLinesSet = [NSCharacterSet newlineCharacterSet];
	NSCharacterSet *spacesSet = [NSCharacterSet characterSetWithCharactersInString:@" "];
	NSMutableArray *lines = [NSMutableArray arrayWithArray:[string componentsSeparatedByCharactersInSet:newLinesSet]];
	for (NSUInteger i=0; i<[lines count]; i++) {
		NSString *line = [lines objectAtIndex:i];
		NSString *clean = [line stringByTrimmingCharactersInSet:spacesSet];
		[lines replaceObjectAtIndex:i withObject:clean];
	}
	return lines;
}

#pragma mark Properties

@synthesize settings;
@synthesize store;

@end
