//
//  GBTemplatesReader.m
//  appledoc
//
//  Created by Tomaz Kragelj on 30.9.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "ICUTemplateMatcher.h"
#import "GBApplicationSettingsProviding.h"
#import "GBTemplateReader.h"

@interface GBTemplateReader ()

- (NSString *)templateStringByRemovingTemplateSections:(NSString *)string;
- (NSDictionary *)templateWithName:(NSString *)name;
@property (readonly) MGTemplateEngine *engine;
@property (retain) id<GBApplicationSettingsProviding> settings;

@end

#pragma mark -

@implementation GBTemplateReader

#pragma mark Initialization & disposal

+ (id)readerWithSettingsProvider:(id)settingsProvider {
	return [[[self alloc] initWithSettingsProvider:settingsProvider] autorelease];
}

- (id)initWithSettingsProvider:(id)settingsProvider {
	NSParameterAssert(settingsProvider != nil);
	NSParameterAssert([settingsProvider conformsToProtocol:@protocol(GBApplicationSettingsProviding)]);
	GBLogDebug(@"Initializing template reader with settings provider %@...", settingsProvider);
	self = [super init];
	if (self) {
		_templates = [[NSMutableDictionary alloc] init];
		_templateLocations = [[NSMutableDictionary alloc] init];
		self.settings = settingsProvider;
	}
	return self;
}

#pragma mark Reading handling

- (void)readTemplateSectionsFromTemplate:(NSString *)string {
	NSParameterAssert(string != nil);
	GBLogInfo(@"Reading template sections...");
	[_templates removeAllObjects];
	[_templateLocations removeAllObjects];
	[self.engine processTemplate:string withVariables:nil];
	_templateString = [self templateStringByRemovingTemplateSections:string];
}

- (id)templateEngine:(MGTemplateEngine *)engine blockEnded:(NSDictionary *)blockInfo {
	// When section declaring a template is encountered, store its string value so that we can use it in second pass.
	if ([[blockInfo objectForKey:BLOCK_NAME_KEY] isEqualToString:@"section"]) {
		NSArray *arguments = [blockInfo objectForKey:BLOCK_ARGUMENTS_KEY];
		if ([arguments count] < 2) return nil;
		if (![[arguments objectAtIndex:0] isEqualToString:@"template"]) return nil;
		
		NSRange startRange = [[blockInfo objectForKey:BLOCK_START_MARKER_RANGE_KEY] rangeValue];
		NSRange endRange = [[blockInfo objectForKey:BLOCK_END_MARKER_RANGE_KEY] rangeValue];
		NSRange range = NSMakeRange(startRange.location + startRange.length, endRange.location - startRange.location - startRange.length);
		NSString *template = [engine.templateContents substringWithRange:range];
		NSString *name = [arguments objectAtIndex:1];
		NSArray *expectedArguments = [arguments subarrayWithRange:NSMakeRange(2, [arguments count]-2)];
		
		GBLogDebug(@"Found %@ template '%@' expecting %ld arguments...", name, [template normalizedDescription], [expectedArguments count]);
		if ([_templates objectForKey:name]) {
			NSRange existingRange = [[_templateLocations objectForKey:name] rangeValue];
			NSUInteger existingLine = [engine.templateContents numberOfLinesInRange:NSMakeRange(0, existingRange.location)];
			NSUInteger line = [engine.templateContents numberOfLinesInRange:NSMakeRange(0, startRange.location)];
			GBLogWarn(@"Template with name %@ already exists (found at line %ld, duplicated at %ld)!", name, existingLine, line);
			return nil;
		}
		
		NSRange fullRange = NSMakeRange(startRange.location, endRange.location + endRange.length - startRange.location);
		NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:template, @"template", expectedArguments, @"arguments", nil];
		[_templateLocations setObject:[NSValue valueWithRange:fullRange] forKey:name];
		[_templates setObject:data forKey:name];
	}
	return nil;
}

- (NSString *)templateStringByRemovingTemplateSections:(NSString *)string {
	// Removes all template sections from the given string. Note that the string must be the one that was passed to the template engine! Also note that we are removing in last to first order so that we can use prepared ranges directly, without offsetting them with deleted portions of the string. NOTE: this removes all entries from _templateLocations dictionary, so make sure it's the last message sent after scanning the template!
	NSMutableString *result = [string mutableCopy];
		while ([_templateLocations count] > 0) {
		__block NSUInteger lastLocation = NSNotFound;
		__block NSString *lastKey = nil;
		[_templateLocations enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSValue *value, BOOL *stop) {
			if (lastLocation == NSNotFound || [value rangeValue].location > lastLocation) {
				lastLocation = [value rangeValue].location;
				lastKey = key;
			}
		}];
		
		NSRange range = [[_templateLocations objectForKey:lastKey] rangeValue];
		[result deleteCharactersInRange:range];
		[_templateLocations removeObjectForKey:lastKey];
	}
	return result;
}

- (MGTemplateEngine *)engine {
	if (!_engine) {
		_engine = [[MGTemplateEngine alloc] init];
		[_engine setDelegate:self];
		[_engine setMatcher:[ICUTemplateMatcher matcherWithTemplateEngine:_engine]];
	}
	return _engine;
}

#pragma mark Returning template values

- (NSString*)valueOfTemplateWithName:(NSString *)name {
	return [[self templateWithName:name] objectForKey:@"template"];
}

- (NSArray *)argumentsOfTemplateWithName:(NSString *)name {
	return [[self templateWithName:name] objectForKey:@"arguments"];
}

- (NSDictionary *)templateWithName:(NSString *)name {
	return [self.templates objectForKey:name];
}

#pragma mark Properties

@synthesize settings;
@synthesize templates = _templates;
@synthesize templateString = _templateString;

@end
