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

- (void)registerDerivedValuesToComment:(GBComment *)comment fromTrimmedLines:(NSArray *)lines;
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
	[self registerDerivedValuesToComment:comment fromTrimmedLines:lines];
}

- (void)registerDerivedValuesToComment:(GBComment *)comment fromTrimmedLines:(NSArray *)lines {
	// Groups whole paragraph texts into a single line and registers all comment components.
	//GBCommentComponentsProvider *componetizer = self.settings.commentComponents;
	GBCommentParagraph *currentParagraph = [GBCommentParagraph paragraph];
	NSMutableString *currentTextValue = [NSMutableString string];
	for (NSString *line in lines) {
		// When empty line is found, we should end current paragraph text an begin new one.
		if ([line length] == 0) {
			if ([currentTextValue length] > 0) {
				GBParagraphTextItem *item = [GBParagraphTextItem paragraphItem];
				item.stringValue = currentTextValue;
				[currentParagraph registerItem:item];
				[comment registerParagraph:currentParagraph];
			}
			currentParagraph = [GBCommentParagraph paragraph];
			[currentTextValue setString:@""];			
		} else {
			if ([currentTextValue length] > 0)
				[currentTextValue appendFormat:@" %@", line];
			else
				[currentTextValue setString:line];
		}
	}
	
	if ([currentTextValue length] > 0) {
		GBParagraphTextItem *item = [GBParagraphTextItem paragraphItem];
		item.stringValue = currentTextValue;
		[currentParagraph registerItem:item];
		[comment registerParagraph:currentParagraph];
	}
}

- (NSArray *)trimmedLinesFromString:(NSString *)string {
	// Splits string into lines and trims them of extra spaces. We do keep tabs as we need them for detecting example lines.
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
