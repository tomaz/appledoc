//
//  GBTemplateLoader.m
//  appledoc
//
//  Created by Tomaz Kragelj on 17.11.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "RegexKitLite.h"
#import "GBTemplateLoader.h"

static NSString *kGBSectionKey = @"section";
static NSString *kGBNameKey = @"name";
static NSString *kGBValueKey = @"value";

#pragma mark -

@interface GBTemplateLoader ()

- (void)clearParsedValues;
- (BOOL)validateSectionData:(NSDictionary *)data withTemplate:(NSString *)template;
- (NSUInteger)lineOfSectionData:(NSDictionary *)data withinTemplate:(NSString *)template;

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
	if (!template) {
		if (error) GBLogNSError(*error, @"Loading template %@ failed!", path);
		return NO;	
	}
	return [self parseTemplate:template error:error];
}

- (BOOL)parseTemplate:(NSString *)template error:(NSError **)error {
	[self clearParsedValues];
	if ([template length] == 0) return YES;
	NSString *regex = @"(Section\\s+(\\w+)\\s+(.*?)\\s+EndSection)";
	NSString *clean = [template copy];
	while (YES) {
		// Get all components of the regex.
		NSRange searchRange = NSMakeRange(0, [clean length]);
		NSDictionary *sectionData = [clean dictionaryByMatchingRegex:regex options:RKLDotAll range:searchRange error:nil withKeysAndCaptures:kGBSectionKey, 1, kGBNameKey, 2, kGBValueKey, 3, nil];
		if ([sectionData count] == 0) break;

		// If section data is valid, use it.
		if ([self validateSectionData:sectionData withTemplate:template]) {
			NSString *name = [sectionData objectForKey:kGBNameKey];
			NSString *value = [[sectionData objectForKey:kGBValueKey] stringByTrimmingWhitespaceAndNewLine];
			[_templateSections setObject:value forKey:name];
		}
		
		// If the section is valid, log it.
		NSUInteger line = [self lineOfSectionData:sectionData withinTemplate:template];
		GBLogDebug(@"Found section template %@ at line %ld...", [sectionData objectForKey:kGBNameKey], line);

		// Get the range of the regex within the clean string and remove the substring from it.
		NSString *section = [sectionData objectForKey:kGBSectionKey];
		NSRange range = [clean rangeOfString:section];
		NSString *prefix = [[clean substringToIndex:range.location] stringByTrimmingWhitespaceAndNewLine];
		NSString *suffix = [[clean substringFromIndex:range.location + range.length] stringByTrimmingWhitespaceAndNewLine];
		NSString *delimiter = ([prefix length] > 0 && [suffix length] > 0) ? @"\n" : @"";
		clean = [NSString stringWithFormat:@"%@%@%@", prefix, delimiter, suffix];
		if ([clean length] == 0) break;
	}
	
	// Prepare template string and warn if it's empty.
	if ([clean length] == 0) GBLogWarn(@"Template contains empty string (with %ld template sections)!", [self.templateSections count]);
	_templateString = [clean copy];
	return YES;
}

- (BOOL)validateSectionData:(NSDictionary *)data withTemplate:(NSString *)template {
	NSString *name = [data objectForKey:kGBNameKey];
	if ([name length] == 0) {
		NSUInteger line = [self lineOfSectionData:data withinTemplate:template];
		GBLogWarn(@"Unnamed section found at line %ld, ignoring!", line);
		return NO;
	}

	NSString *value = [[data objectForKey:kGBValueKey] stringByTrimmingWhitespace];
	if ([value length] == 0) {
		NSUInteger line = [self lineOfSectionData:data withinTemplate:template];
		GBLogWarn(@"Empty section %@ found at line %ld, ignoring!", name, line);
		return NO;
	}
	
	return YES;
}

- (NSUInteger)lineOfSectionData:(NSDictionary *)data withinTemplate:(NSString *)template {
	NSString *section = [data objectForKey:kGBSectionKey];
	NSRange range = [template rangeOfString:section];
	return [template numberOfLinesInRange:NSMakeRange(0, range.location)];
}

- (void)clearParsedValues {
	GBLogDebug(@"Clearing parsed values...");
	_templateString = @"";
	[_templateSections removeAllObjects];
}

#pragma mark Properties

@synthesize templateString = _templateString;
@synthesize templateSections = _templateSections;

@end
