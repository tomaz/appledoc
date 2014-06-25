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
- (BOOL)processDocuments:(NSError **)error;
- (BOOL)processConstants:(NSError **)error;
- (BOOL)processBlocks:(NSError **)error;
- (BOOL)processIndex:(NSError **)error;
- (BOOL)processHierarchy:(NSError **)error;
- (NSString *)stringByCleaningHtml:(NSString *)string;
- (NSString *)htmlOutputPathForIndex;
- (NSString *)htmlOutputPathForHierarchy;
- (NSString *)htmlOutputPathForObject:(GBModelBase *)object;
- (NSString *)htmlOutputPathForTemplateName:(NSString *)template;
@property (readonly) GBTemplateHandler *htmlObjectTemplate;
@property (readonly) GBTemplateHandler *htmlIndexTemplate;
@property (readonly) GBTemplateHandler *htmlHierarchyTemplate;
@property (readonly) GBTemplateHandler *htmlDocumentTemplate;
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
	if (![self processDocuments:error]) return NO;
    if (![self processConstants:error]) return NO;
    if (![self processBlocks:error]) return NO;
	if (![self processIndex:error]) return NO;
	if (![self processHierarchy:error]) return NO;
	return YES;
}

- (BOOL)processClasses:(NSError **)error {
	for (GBClassData *class in self.store.classes) {
        if (!class.includeInOutput) continue;
		GBLogInfo(@"Generating output for class %@...", class);
		NSDictionary *vars = [self.variablesProvider variablesForClass:class withStore:self.store];
		NSString *output = [self.htmlObjectTemplate renderObject:vars];
		NSString *cleaned = [self stringByCleaningHtml:output];
		NSString *path = [self htmlOutputPathForObject:class];
		if (![self writeString:cleaned toFile:[path stringByStandardizingPath] error:error]) {
			GBLogWarn(@"Failed writing HTML for class %@ to '%@'!", class, path);
			return NO;
		}
		GBLogDebug(@"Finished generating output for class %@.", class);
	}
	return YES;
}

- (BOOL)processCategories:(NSError **)error {
	for (GBCategoryData *category in self.store.categories) {
        if (!category.includeInOutput) continue;
		GBLogInfo(@"Generating output for category %@...", category);
		NSDictionary *vars = [self.variablesProvider variablesForCategory:category withStore:self.store];
		NSString *output = [self.htmlObjectTemplate renderObject:vars];
		NSString *cleaned = [self stringByCleaningHtml:output];
		NSString *path = [self htmlOutputPathForObject:category];
		if (![self writeString:cleaned toFile:[path stringByStandardizingPath] error:error]) {
			GBLogWarn(@"Failed writing HTML for category %@ to '%@'!", category, path);
			return NO;
		}
		GBLogDebug(@"Finished generating output for category %@.", category);
	}
	return YES;
}

- (BOOL)processProtocols:(NSError **)error {
	for (GBProtocolData *protocol in self.store.protocols) {
        if (!protocol.includeInOutput) continue;
		GBLogInfo(@"Generating output for protocol %@...", protocol);
		NSDictionary *vars = [self.variablesProvider variablesForProtocol:protocol withStore:self.store];
		NSString *output = [self.htmlObjectTemplate renderObject:vars];
		NSString *cleaned = [self stringByCleaningHtml:output];
		NSString *path = [self htmlOutputPathForObject:protocol];
		if (![self writeString:cleaned toFile:[path stringByStandardizingPath] error:error]) {
			GBLogWarn(@"Failed writing HTML for protocol %@ to '%@'!", protocol, path);
			return NO;
		}
		GBLogDebug(@"Finished generating output for protocol %@.", protocol);
	}
	return YES;
}

- (BOOL)processConstants:(NSError **)error {
	for (GBTypedefEnumData *enumTypedef in self.store.constants) {
        if (!enumTypedef.includeInOutput) continue;
		GBLogInfo(@"Generating output for constant %@...", enumTypedef);
		NSDictionary *vars = [self.variablesProvider variablesForConstant:enumTypedef withStore:self.store];
		NSString *output = [self.htmlObjectTemplate renderObject:vars];
		NSString *cleaned = [self stringByCleaningHtml:output];
		NSString *path = [self htmlOutputPathForObject:enumTypedef];
		if (![self writeString:cleaned toFile:[path stringByStandardizingPath] error:error]) {
			GBLogWarn(@"Failed writing HTML for constant %@ to '%@'!", enumTypedef, path);
			return NO;
		}
		GBLogDebug(@"Finished generating output for constant %@.", enumTypedef);
	}
	return YES;
}

- (BOOL)processBlocks:(NSError **)error {
    for (GBTypedefBlockData *blockTypedef in self.store.blocks) {
        if (!blockTypedef.includeInOutput) continue;
        GBLogInfo(@"Generating output for block %@...", blockTypedef);
        NSDictionary *vars = [self.variablesProvider variablesForBlocks:blockTypedef withStore:self.store];
        NSString *output = [self.htmlObjectTemplate renderObject:vars];
        NSString *cleaned = [self stringByCleaningHtml:output];
        NSString *path = [self htmlOutputPathForObject:blockTypedef];
        if (![self writeString:cleaned toFile:[path stringByStandardizingPath] error:error]) {
            GBLogWarn(@"Failed writing HTML for block %@ to '%@'!", blockTypedef, path);
            return NO;
        }
        GBLogDebug(@"Finished generating output for block %@.", blockTypedef);
    }
    return YES;
}

- (BOOL)processDocuments:(NSError **)error {	
	// First process all include paths by copying them over to the destination. Note that we do it even if no template is found - if the user specified some include path, we should use it...
	NSString *docsUserPath = [self.outputUserPath stringByAppendingPathComponent:self.settings.htmlStaticDocumentsSubpath];
	GBTemplateFilesHandler *handler = [[GBTemplateFilesHandler alloc] init];
	for (NSString *path in self.settings.includePaths) {
		GBLogInfo(@"Copying static documents from '%@'...", path);
		NSString *lastComponent = [path lastPathComponent];
		NSString *installPath = [docsUserPath stringByAppendingPathComponent:lastComponent];
		handler.templateUserPath = path;
		handler.outputUserPath = installPath;
		if (![handler copyTemplateFilesToOutputPath:error]) return NO;
	}
	
	// Now process all documents.
	for (GBDocumentData *document in self.store.documents) {
		GBLogInfo(@"Generating output for document %@...", document);
		NSDictionary *vars = [self.variablesProvider variablesForDocument:document withStore:self.store];
		NSString *output = [self.htmlDocumentTemplate renderObject:vars];
		NSString *cleaned = [self stringByCleaningHtml:output];
		NSString *path = [self htmlOutputPathForObject:document];
		if (![self writeString:cleaned toFile:[path stringByStandardizingPath] error:error]) {
			GBLogWarn(@"Failed writing HTML for document %@ to '%@'!", document, path);
			return NO;
		}
		GBLogDebug(@"Finished generating output for document %@.", document);
	}
	return YES;
}

- (BOOL)processIndex:(NSError **)error {
	GBLogInfo(@"Generating output for index...");
	if ([self.store.classes count] > 0 || [self.store.protocols count] > 0 || [self.store.categories count] > 0 || [self.store.constants count] > 0 || [self.store.blocks count] > 0) {
		NSDictionary *vars = [self.variablesProvider variablesForIndexWithStore:self.store];
		NSString *output = [self.htmlIndexTemplate renderObject:vars];
		NSString *cleaned = [self stringByCleaningHtml:output];
		NSString *path = [[self htmlOutputPathForIndex] stringByStandardizingPath];
		if (![self writeString:cleaned toFile:[path stringByStandardizingPath] error:error]) {
			GBLogWarn(@"Failed writing HTML index to '%@'!", path);
			return NO;
		}
	}
	GBLogDebug(@"Finished generating output for index.");
	return YES;
}

- (BOOL)processHierarchy:(NSError **)error {
	GBLogInfo(@"Generating output for hierarchy...");
	if ([self.store.classes count] > 0 || [self.store.protocols count] > 0 || [self.store.categories count] > 0 || [self.store.constants count] > 0 || [self.store.blocks count] > 0) {
		NSDictionary *vars = [self.variablesProvider variablesForHierarchyWithStore:self.store];
		NSString *output = [self.htmlHierarchyTemplate renderObject:vars];
		NSString *cleaned = [self stringByCleaningHtml:output];
		NSString *path = [[self htmlOutputPathForHierarchy] stringByStandardizingPath];
		if (![self writeString:cleaned toFile:[path stringByStandardizingPath] error:error]) {
			GBLogWarn(@"Failed writing HTML hierarchy to '%@'!", path);
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
	if (!self.htmlDocumentTemplate) {
		if (error) {
			NSString *desc = [NSString stringWithFormat:@"Document template file 'document-template.html' is missing at '%@'!", self.templateUserPath];
			*error = [NSError errorWithCode:GBErrorHTMLDocumentTemplateMissing description:desc reason:nil];
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
	// Nothing to do at this point - as we're preserving all whitespace, we should be just fine with generated string. The method is still left as a placeholder for possible future handling.
	return string;
}

- (NSString *)htmlOutputPathForIndex {
	// Returns file name including full path for HTML file representing the main index.
	return [self htmlOutputPathForTemplateName:@"index-template.html"];
}

- (NSString *)htmlOutputPathForHierarchy {
	// Returns file name including full path for HTML file representing the main hierarchy.
	return [self htmlOutputPathForTemplateName:@"hierarchy-template.html"];
}

- (NSString *)htmlOutputPathForObject:(GBModelBase *)object {
	// Returns file name including full path for HTML file representing the given top-level object. This works for any top-level object: class, category or protocol. The path is automatically determined regarding to the object class. Note that we use the HTML reference to get us the actual path - we can't rely on template filename as it's the same for all objects...
	NSString *inner = [self.settings htmlReferenceForObjectFromIndex:object];
	return [self.outputUserPath stringByAppendingPathComponent:inner];
}

- (NSString *)htmlOutputPathForTemplateName:(NSString *)template {
	// Returns full path and actual file name corresponding to the given template.
	NSString *path = [self outputPathToTemplateEndingWith:template];
	NSString *filename = [self.settings outputFilenameForTemplatePath:template];
	return [path stringByAppendingPathComponent:filename];
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

- (GBTemplateHandler *)htmlDocumentTemplate {
	return [self.templateFiles objectForKey:@"document-template.html"];
}

#pragma mark Overriden methods

- (NSString *)outputSubpath {
	return @"html";
}

@end
