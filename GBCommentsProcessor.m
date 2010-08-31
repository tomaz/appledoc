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

- (void)registerComponent:(NSString *)component toComment:(GBComment *)comment;
- (NSArray *)componentsSeparatedByEmptyLinesFromString:(NSString *)string;
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
	NSArray *components = [self componentsSeparatedByEmptyLinesFromString:[comment stringValue]];
	for (NSString *component in components) {
		[self registerComponent:component toComment:comment];
	}
}

- (void)registerComponent:(NSString *)component toComment:(GBComment *)comment {
	// String all whitespace and convert paragraph text into a single line with words separated with spaces.
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

#pragma mark Properties

@synthesize settings;
@synthesize store;

@end
