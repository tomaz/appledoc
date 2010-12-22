//
//  GBHTMLOutputGenerator.m
//  appledoc
//
//  Created by Tomaz Kragelj on 29.11.10.
//  Copyright 2010 Gentle Bytes. All rights reserved.
//

#import "RegexKitLite.h"
#import "GBStore.h"
#import "GBApplicationSettingsProvider.h"
#import "GBDataObjects.h"
#import "GBHTMLTemplateVariablesProvider.h"
#import "GBTemplateHandler.h"
#import "GBHTMLOutputGenerator.h"

@interface GBHTMLOutputGenerator ()

- (BOOL)validateTemplates:(NSError **)error;
- (BOOL)processClasses:(NSError **)error;
- (BOOL)processCategories:(NSError **)error;
- (BOOL)processProtocols:(NSError **)error;
- (BOOL)processIndex:(NSError **)error;
- (BOOL)processHierarchy:(NSError **)error;
- (NSString *)stringByCleaningHtml:(NSString *)string;
- (NSString *)htmlOutputPathForIndex;
- (NSString *)htmlOutputPathForHierarchy;
- (NSString *)htmlOutputPathForObject:(GBModelBase *)object;
@property (readonly) GBTemplateHandler *htmlObjectTemplate;
@property (readonly) GBTemplateHandler *htmlIndexTemplate;
@property (readonly) GBTemplateHandler *htmlHierarchyTemplate;
@property (readonly) GBHTMLTemplateVariablesProvider *variablesProvider;

@end

#pragma mark -

@implementation GBHTMLOutputGenerator

#pragma Generation handling

- (BOOL)generateOutputWithStore:(id)store error:(NSError **)error {
	if (![super generateOutputWithStore:store error:error]) return NO;
	if (![self validateTemplates:error]) return NO;
	if (![self processClasses:error]) return NO;
	if (![self processCategories:error]) return NO;
	if (![self processProtocols:error]) return NO;
	if (![self processIndex:error]) return NO;
	if (![self processHierarchy:error]) return NO;
	return YES;
}

- (BOOL)processClasses:(NSError **)error {
	for (GBClassData *class in self.store.classes) {
		GBLogInfo(@"Generating output for class %@...", class);
		NSDictionary *vars = [self.variablesProvider variablesForClass:class withStore:self.store];
		NSString *output = [self.htmlObjectTemplate renderObject:vars];
		NSString *cleaned = [self stringByCleaningHtml:output];
		NSString *path = [self htmlOutputPathForObject:class];
		if (![self writeString:cleaned toFile:[path stringByStandardizingPath] error:error]) {
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
		NSString *cleaned = [self stringByCleaningHtml:output];
		NSString *path = [self htmlOutputPathForObject:category];
		if (![self writeString:cleaned toFile:[path stringByStandardizingPath] error:error]) {
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
		NSString *cleaned = [self stringByCleaningHtml:output];
		NSString *path = [self htmlOutputPathForObject:protocol];
		if (![self writeString:cleaned toFile:[path stringByStandardizingPath] error:error]) {
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
		NSString *cleaned = [self stringByCleaningHtml:output];
		NSString *path = [[self htmlOutputPathForIndex] stringByStandardizingPath];
		if (![self writeString:cleaned toFile:[path stringByStandardizingPath] error:error]) {
			GBLogWarn(@"Failed writting HTML index to '%@'!", path);
			return NO;
		}
	}
	GBLogDebug(@"Finished generating output for index.");
	return YES;
}

- (BOOL)processHierarchy:(NSError **)error {
	GBLogInfo(@"Generating output for hierarchy...");
	if ([self.store.classes count] > 0 || [self.store.protocols count] > 0 || [self.store.categories count] > 0) {
		NSDictionary *vars = [self.variablesProvider variablesForHierarchyWithStore:self.store];
		NSString *output = [self.htmlHierarchyTemplate renderObject:vars];
		NSString *cleaned = [self stringByCleaningHtml:output];
		NSString *path = [[self htmlOutputPathForHierarchy] stringByStandardizingPath];
		if (![self writeString:cleaned toFile:[path stringByStandardizingPath] error:error]) {
			GBLogWarn(@"Failed writting HTML hierarchy to '%@'!", path);
			return NO;
		}
	}
	GBLogDebug(@"Finished generating output for hierarchy.");
	return YES;
}

- (BOOL)validateTemplates:(NSError **)error {
	if (!self.htmlObjectTemplate) {
		if (error) {
			NSString *desc = [NSString stringWithFormat:@"Object template file 'object-template.html' is missing at '%@'!", self.templateUserPath];
			*error = [NSError errorWithCode:GBErrorHTMLObjectTemplateMissing description:desc reason:nil];
		}
		return NO;
	}
	if (!self.htmlIndexTemplate) {
		if (error) {
			NSString *desc = [NSString stringWithFormat:@"Index template file 'index-template.html' is missing at '%@'!", self.templateUserPath];
			*error = [NSError errorWithCode:GBErrorHTMLIndexTemplateMissing description:desc reason:nil];
		}
		return NO;
	}
	if (!self.htmlHierarchyTemplate) {
		if (error) {
			NSString *desc = [NSString stringWithFormat:@"Hierarchy template file 'hierarchy-template.html' is missing at '%@'!", self.templateUserPath];
			*error = [NSError errorWithCode:GBErrorHTMLHierarchyTemplateMissing description:desc reason:nil];
		}
		return NO;
	}
	return YES;
}

#pragma mark Helper methods

- (NSString *)stringByCleaningHtml:(NSString *)string {
	NSString *result = [string stringByReplacingOccurrencesOfString:@"  " withString:@" "];
	result = [result stringByReplacingOccurrencesOfString:@"<code> " withString:@"<code>"];
	result = [result stringByReplacingOccurrencesOfString:@" </code>" withString:@"</code>"];
	while (YES) {
		NSString *source = [result stringByMatching:@"</code> [],.!?:;'\")}>]"];
		if (!source) break;
		NSString *replacement = [source stringByReplacingOccurrencesOfString:@" " withString:@""];
		result = [result stringByReplacingOccurrencesOfString:source withString:replacement];
	}
	return result;
}

- (NSString *)htmlOutputPathForIndex {
	// Returns file name including full path for HTML file representing the main index.
	NSString *path = [self outputPathToTemplateEndingWith:@"index-template.html"];
	path = [path stringByAppendingPathComponent:@"index"];
	return [path stringByAppendingPathExtension:self.settings.htmlExtension];
}

- (NSString *)htmlOutputPathForHierarchy {
	// Returns file name including full path for HTML file representing the main hierarchy.
	NSString *path = [self outputPathToTemplateEndingWith:@"hierarchy-template.html"];
	path = [path stringByAppendingPathComponent:@"hierarchy"];
	return [path stringByAppendingPathExtension:self.settings.htmlExtension];
}

- (NSString *)htmlOutputPathForObject:(GBModelBase *)object {
	// Returns file name including full path for HTML file representing the given top-level object. This works for any top-level object: class, category or protocol. The path is automatically determined regarding to the object class.
	NSString *inner = [self.settings htmlReferenceForObjectFromIndex:object];
	return [self.outputUserPath stringByAppendingPathComponent:inner];
}

- (GBHTMLTemplateVariablesProvider *)variablesProvider {
	static GBHTMLTemplateVariablesProvider *result = nil;
	if (!result) {
		GBLogDebug(@"Initializing variables provider...");
		result = [[GBHTMLTemplateVariablesProvider alloc] initWithSettingsProvider:self.settings];
	}
	return result;
}

- (GBTemplateHandler *)htmlObjectTemplate {
	return [self.templateFiles objectForKey:@"object-template.html"];
}

- (GBTemplateHandler *)htmlIndexTemplate {
	return [self.templateFiles objectForKey:@"index-template.html"];
}

- (GBTemplateHandler *)htmlHierarchyTemplate {
	return [self.templateFiles objectForKey:@"hierarchy-template.html"];
}

#pragma mark Overriden methods

- (NSString *)outputSubpath {
	return @"html";
}

@end
