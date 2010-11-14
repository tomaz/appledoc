//
//  GBTemplateWriter.m
//  appledoc
//
//  Created by Tomaz Kragelj on 30.9.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "ICUTemplateMatcher.h"
#import "GBApplicationSettingsProviding.h"
#import "GBTemplateReader.h"
#import "GBTemplateWriter.h"

@interface GBTemplateWriter ()

- (NSString *)processTemplate:(NSString *)template withVariables:(NSDictionary *)variables;
@property (retain) GBTemplateReader *reader;
@property (retain) id<GBApplicationSettingsProviding> settings;

@end

#pragma mark -

@implementation GBTemplateWriter

#pragma mark Initialization & disposal

+ (id)writerWithSettingsProvider:(id)settingsProvider {
	return [[[self alloc] initWithSettingsProvider:settingsProvider] autorelease];
}

- (id)initWithSettingsProvider:(id)settingsProvider {
	NSParameterAssert(settingsProvider != nil);
	NSParameterAssert([settingsProvider conformsToProtocol:@protocol(GBApplicationSettingsProviding)]);
	GBLogDebug(@"Initializing template writer with settings provider %@...", settingsProvider);
	self = [super init];
	if (self) {
		self.settings = settingsProvider;
	}
	return self;
}

#pragma mark Output generation

- (NSString *)outputStringWithReader:(GBTemplateReader *)reader variables:(NSDictionary *)variables {
	NSParameterAssert(reader != nil);
	self.reader = reader;
	return [self processTemplate:self.reader.templateString withVariables:variables];
}

- (id)templateEngine:(MGTemplateEngine *)engine blockEnded:(NSDictionary *)blockInfo {
	// When section declaring a template execution is encountered, execute it with a template engine.
	if ([[blockInfo objectForKey:BLOCK_NAME_KEY] isEqualToString:@"section"]) {
		NSArray *arguments = [blockInfo objectForKey:BLOCK_ARGUMENTS_KEY];
		if ([arguments count] < 2) return nil;
		if (![[arguments objectAtIndex:0] isEqualToString:@"execute"]) return nil;
		NSString *name = [arguments objectAtIndex:1];

		// Make sure all injected variable/value pairs are there (i.e. we could forget to add value of some variable).
		if ([arguments count] % 2 != 0) {
			GBLogWarn(@"Template %@ execution directive is missing value for var %@, ignoring!", name, [arguments lastObject]);
			return nil;
		}
		
		// Get the template from reader and validate we have a template with the given name.
		NSString *template = [self.reader valueOfTemplateWithName:name];
		if (!template) {
			GBLogWarn(@"Template execution directive found for unknown template %@, ignoring!", name);
			return nil;
		}
		
		// Prepare injection variables.
		NSArray *expectedArguments = [self.reader argumentsOfTemplateWithName:name];
		NSMutableString *injection = GBLogIsEnabled(LOG_LEVEL_DEBUG) ? [NSMutableString string] : nil;
		NSMutableDictionary *vars = [NSMutableDictionary dictionary];
		for (NSUInteger i=2; i<[arguments count]; i+=2) {
			// Get expected variable name and the variable that is to be extracted from current engine. Validate variable name with expected variables of the template to make sure they match.
			NSString *templateVarName = [arguments objectAtIndex:i];
			NSString *injectedVarName = [arguments objectAtIndex:i+1];
			if (![expectedArguments containsObject:templateVarName]) {
				GBLogWarn(@"Variable %@ is not expected for template %@, ignoring!", templateVarName, name);
				return nil;
			}
			
			// Get the variable value from current engine and exit if not found.
			id injectedValue = [engine resolveVariable:injectedVarName];
			if (!injectedValue) {
				GBLogWarn(@"Variable %@ value is nil for argument %@ of template %@, ignoring!", injectedVarName, templateVarName, name);
				return nil;
			}
			
			// Add the variable to injected variables list and prepare log description (we're not doing it unless debug verbosity).
			[vars setObject:injectedValue forKey:templateVarName];
			if (GBLogIsEnabled(LOG_LEVEL_DEBUG)) {
				if ([injection length] > 0) [injection appendFormat:@", "];
				[injection appendFormat:@"%@=%@", templateVarName, injectedValue];
			}
		}
		
		// If given variables don't match expected variables, exit.
		if ([expectedArguments count] != [vars count]) {
			GBLogWarn(@"Template %@ expects %ld variables, found %ld, ignoring!", name, [expectedArguments count], [vars count]);
			return nil;
		}

		// Process the template.
		GBLogDebug(@"Executing template %@ with vars %@...", name, [injection normalizedDescriptionWithMaxLength:70]);		
		return [self processTemplate:template withVariables:vars];
	}
	return nil;
}

- (void)templateEngine:(MGTemplateEngine *)engine encounteredError:(NSError *)error isContinuing:(BOOL)continuing {
	GBLogNSError(error, @"Encountered error while generating output:");
}

- (NSString *)processTemplate:(NSString *)template withVariables:(NSDictionary *)variables {
	MGTemplateEngine *engine = [[[MGTemplateEngine alloc] init] autorelease];
	[engine setDelegate:self];
	[engine setMatcher:[ICUTemplateMatcher matcherWithTemplateEngine:engine]];
	[engine setObject:self.settings.stringTemplates forKey:@"strings"];
	return [engine processTemplate:template withVariables:variables];
}

#pragma mark Properties

@synthesize settings;
@synthesize reader;

@end
