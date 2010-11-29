//
//  GBHTMLOutputGenerator.m
//  appledoc
//
//  Created by Tomaz Kragelj on 29.11.10.
//  Copyright 2010 Gentle Bytes. All rights reserved.
//

#import "GBApplicationSettingsProviding.h"
#import "GBDataObjects.h"
#import "GBTemplateVariablesProvider.h"
#import "GBTemplateHandler.h"
#import "GBHTMLOutputGenerator.h"

@interface GBHTMLOutputGenerator ()

- (BOOL)processClasses:(NSError **)error;
- (BOOL)processCategories:(NSError **)error;
- (BOOL)processProtocols:(NSError **)error;
- (BOOL)processIndex:(NSError **)error;
- (NSString *)htmlOutputPathForIndex;
- (NSString *)htmlOutputPathForObject:(GBModelBase *)object;
@property (readonly) GBTemplateHandler *htmlObjectTemplate;
@property (readonly) GBTemplateHandler *htmlIndexTemplate;
@property (readonly) GBTemplateVariablesProvider *variablesProvider;

@end

#pragma mark -

@implementation GBHTMLOutputGenerator

#pragma Generation handling

- (BOOL)generateOutputWithStore:(id<GBStoreProviding>)store error:(NSError **)error {
	if (![super generateOutputWithStore:store error:error]) return NO;
	if (![self processClasses:error]) return NO;
	if (![self processCategories:error]) return NO;
	if (![self processProtocols:error]) return NO;
	if (![self processIndex:error]) return NO;
	return YES;
}

- (BOOL)processClasses:(NSError **)error {
	for (GBClassData *class in self.store.classes) {
		GBLogInfo(@"Generating output for class %@...", class);
		NSDictionary *vars = [self.variablesProvider variablesForClass:class withStore:self.store];
		NSString *output = [self.htmlObjectTemplate renderObject:vars];
		NSString *path = [self htmlOutputPathForObject:class];
		if (![self writeString:output toFile:[path stringByStandardizingPath] error:error]) {
			GBLogWarn(@"Failed writting HTML for class %@ to '%@'!", class, path);
			return NO;
		}
		GBLogDebug(@"Finished generating output for class %@.", class);
	}
	return YES;
}

- (BOOL)processCategories:(NSError **)error {
	for (GBCategoryData *category in self.store.categories) {
		GBLogInfo(@"Generating output for category %@...", category);
		NSDictionary *vars = [self.variablesProvider variablesForCategory:category withStore:self.store];
		NSString *output = [self.htmlObjectTemplate renderObject:vars];
		NSString *path = [self htmlOutputPathForObject:category];
		if (![self writeString:output toFile:[path stringByStandardizingPath] error:error]) {
			GBLogWarn(@"Failed writting HTML for category %@ to '%@'!", category, path);
			return NO;
		}
		GBLogDebug(@"Finished generating output for category %@.", category);
	}
	return YES;
}

- (BOOL)processProtocols:(NSError **)error {
	for (GBProtocolData *protocol in self.store.protocols) {
		GBLogInfo(@"Generating output for protocol %@...", protocol);
		NSDictionary *vars = [self.variablesProvider variablesForProtocol:protocol withStore:self.store];
		NSString *output = [self.htmlObjectTemplate renderObject:vars];
		NSString *path = [self htmlOutputPathForObject:protocol];
		if (![self writeString:output toFile:[path stringByStandardizingPath] error:error]) {
			GBLogWarn(@"Failed writting HTML for protocol %@ to '%@'!", protocol, path);
			return NO;
		}
		GBLogDebug(@"Finished generating output for protocol %@.", protocol);
	}
	return YES;
}

- (BOOL)processIndex:(NSError **)error {
	GBLogInfo(@"Generating output for index...");
	if ([self.store.classes count] > 0 || [self.store.protocols count] > 0 || [self.store.categories count] > 0) {
		NSDictionary *vars = [self.variablesProvider variablesForIndexWithStore:self.store];
		NSString *output = [self.htmlIndexTemplate renderObject:vars];
		NSString *path = [[self htmlOutputPathForIndex] stringByStandardizingPath];
		if (![self writeString:output toFile:[path stringByStandardizingPath] error:error]) {
			GBLogWarn(@"Failed writting HTML index to '%@'!", path);
			return NO;
		}
	}
	GBLogDebug(@"Finished generating output for index.");
	return YES;
}

#pragma mark Helper methods

- (NSString *)htmlOutputPathForIndex {
	// Returns file name including full path for HTML file representing the main index.
	NSString *result = [self.outputUserPath stringByAppendingPathComponent:@"index"];
	return [result stringByAppendingPathExtension:self.settings.htmlExtension];
}

- (NSString *)htmlOutputPathForObject:(GBModelBase *)object {
	// Returns file name including full path for HTML file representing the given top-level object. This works for any top-level object: class, category or protocol. The path is automatically determined regarding to the object class.
	NSString *inner = [self.settings htmlReferenceForObjectFromIndex:object];
	return [self.outputUserPath stringByAppendingPathComponent:inner];
}

- (GBTemplateVariablesProvider *)variablesProvider {
	static GBTemplateVariablesProvider *result = nil;
	if (!result) {
		GBLogDebug(@"Initializing variables provider...");
		result = [[GBTemplateVariablesProvider alloc] initWithSettingsProvider:self.settings];
	}
	return result;
}

- (GBTemplateHandler *)htmlObjectTemplate {
	return [self.templateFiles objectForKey:@"object-template.html"];
}

- (GBTemplateHandler *)htmlIndexTemplate {
	return [self.templateFiles objectForKey:@"index-template.html"];
}

#pragma mark Overriden methods

- (NSString *)outputSubpath {
	return @"html";
}

@end
