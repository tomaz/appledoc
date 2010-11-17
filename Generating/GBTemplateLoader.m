//
//  GBTemplateLoader.m
//  appledoc
//
//  Created by Tomaz Kragelj on 17.11.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "RegexKitLite.h"
#import "GBTemplateLoader.h"

@interface GBTemplateLoader ()

- (void)clearParsedValues;
- (BOOL)validateSectionData:(NSDictionary *)data withTemplate:(NSString *)template;

@end

#pragma mark -

@implementation GBTemplateLoader

#pragma mark Initialization & disposal

+ (id)loader {
	return [[[self alloc] init] autorelease];
}

- (id)init {
	self = [super init];
	if (self) {
		_templateSections = [[NSMutableDictionary alloc] init];
	}
	return self;
}

#pragma mark Parsing handling

- (BOOL)parseTemplateFromPath:(NSString *)path error:(NSError **)error {
	GBLogVerbose(@"Parsing template from %@...", path);
	[self clearParsedValues];
	NSString *template = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:error];
	if (!template) return NO;
	return [self parseTemplate:template error:error];
}

- (BOOL)parseTemplate:(NSString *)template error:(NSError **)error {
	[self clearParsedValues];
	if ([template length] == 0) return YES;
	NSString *regex = @"(Section\\s+(\\w+)\\s+(.*)\\s+EndSection)";
	NSString *clean = [template copy];
	while (YES) {
		// Get all components of the regex.
		NSDictionary *sectionData = [clean dictionaryByMatchingRegex:regex withKeysAndCaptures:@"section", 1, @"name", 2, @"value", 3, nil];
		if ([sectionData count] == 0) break;

		// If section data is valid, use it.
		if ([self validateSectionData:sectionData withTemplate:template]) {
			NSString *name = [sectionData objectForKey:@"name"];
			NSString *value = [[sectionData objectForKey:@"value"] stringByTrimmingWhitespace];
			[_templateSections setObject:value forKey:name];
		}
		
		// Get the range of the regex within the clean string and remove the substring from it.
		NSString *section = [sectionData objectForKey:@"section"];
		NSRange range = [clean rangeOfString:section];
		NSString *prefix = [clean substringToIndex:range.location];
		NSString *suffix = [clean substringFromIndex:range.location + range.length];
		clean = [NSString stringWithFormat:@"%@%@", prefix, suffix];
		if ([clean length] == 0) break;
	}
	return NO;
}

- (BOOL)validateSectionData:(NSDictionary *)data withTemplate:(NSString *)template {
	NSString *section = [data objectForKey:@"section"];
	NSString *name = [data objectForKey:@"name"];

	if ([name length] == 0) {
		NSRange range = [template rangeOfString:section];
		NSUInteger line = [template numberOfLinesInRange:NSMakeRange(0, range.location)];
		GBLogWarn(@"Unnamed section found at line %ld, ignoring!", line);
		return NO;
	}

	NSString *value = [[data objectForKey:@"value"] stringByTrimmingWhitespace];
	if ([value length] == 0) {
		NSRange range = [template rangeOfString:section];
		NSUInteger line = [template numberOfLinesInRange:NSMakeRange(0, range.location)];
		GBLogWarn(@"Empty section %@ found at line %ld, ignoring!", name, line);
		return NO;
	}
	
	return YES;
}

- (void)clearParsedValues {
	GBLogDebug(@"Clearing parsed values...");
	_templateString = nil;
	[_templateSections removeAllObjects];
}

#pragma mark Properties

@synthesize templateString = _templateString;
@synthesize templateSections = _templateSections;

@end
