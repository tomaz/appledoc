//
//  GBMarkdownOutputGenerator.m
//  appledoc
//
//  Created by Matthew Murray on 3/1/18.
//  Copyright © 2018 Gentle Bytes. All rights reserved.
//

#import "GBMarkdownOutputGenerator.h"
#import "GBStore.h"
#import "GBApplicationSettingsProvider.h"
#import "GBDataObjects.h"
#import "GBHTMLTemplateVariablesProvider.h"
#import "GBTemplateHandler.h"

@interface GBMarkdownOutputGenerator ()
    
- (BOOL)validateTemplates:(NSError **)error;
- (BOOL)processClasses:(NSError **)error;
- (BOOL)processCategories:(NSError **)error;
- (BOOL)processProtocols:(NSError **)error;
- (BOOL)processConstants:(NSError **)error;
- (BOOL)processBlocks:(NSError **)error;
- (NSString *)stringByCleaningHtml:(NSString *)string;
- (NSString *)markdownOutputPathForObject:(GBModelBase *)object;
@property (readonly) GBTemplateHandler *markdownTemplate;
@property (readonly) GBHTMLTemplateVariablesProvider *variablesProvider;
    
@end

@implementation GBMarkdownOutputGenerator

#pragma Generation handling

- (BOOL)generateOutputWithStore:(id)store error:(NSError **)error {
    if (![super generateOutputWithStore:store error:error]) return NO;
    if (![self validateTemplates:error]) return NO;
    if (![self processClasses:error]) return NO;
    if (![self processCategories:error]) return NO;
    if (![self processProtocols:error]) return NO;
    if (![self processConstants:error]) return NO;
    if (![self processBlocks:error]) return NO;
    return YES;
}

- (BOOL)processClasses:(NSError **)error {
    for (GBClassData *class in self.store.classes) {
        if (!class.includeInOutput) continue;
        GBLogInfo(@"Generating output for class %@...", class);
        NSDictionary *vars = [self.variablesProvider variablesForClass:class withStore:self.store];
        NSString *output = [self.markdownTemplate renderObject:vars];
        NSString *cleaned = [self stringByCleaningHtml:output];
        NSString *path = [self markdownOutputPathForObject:class];
        if (![self writeString:cleaned toFile:[path stringByStandardizingPath] error:error]) {
            GBLogWarn(@"Failed writing markdown for class %@ to '%@'!", class, path);
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
        NSString *output = [self.markdownTemplate renderObject:vars];
        NSString *cleaned = [self stringByCleaningHtml:output];
        NSString *path = [self markdownOutputPathForObject:category];
        if (![self writeString:cleaned toFile:[path stringByStandardizingPath] error:error]) {
            GBLogWarn(@"Failed writing markdown for category %@ to '%@'!", category, path);
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
        NSString *output = [self.markdownTemplate renderObject:vars];
        NSString *cleaned = [self stringByCleaningHtml:output];
        NSString *path = [self markdownOutputPathForObject:protocol];
        if (![self writeString:cleaned toFile:[path stringByStandardizingPath] error:error]) {
            GBLogWarn(@"Failed writing markdown for protocol %@ to '%@'!", protocol, path);
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
        NSString *output = [self.markdownTemplate renderObject:vars];
        NSString *cleaned = [self stringByCleaningHtml:output];
        NSString *path = [self markdownOutputPathForObject:enumTypedef];
        if (![self writeString:cleaned toFile:[path stringByStandardizingPath] error:error]) {
            GBLogWarn(@"Failed writing markdown for constant %@ to '%@'!", enumTypedef, path);
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
        NSString *output = [self.markdownTemplate renderObject:vars];
        NSString *cleaned = [self stringByCleaningHtml:output];
        NSString *path = [self markdownOutputPathForObject:blockTypedef];
        if (![self writeString:cleaned toFile:[path stringByStandardizingPath] error:error]) {
            GBLogWarn(@"Failed writing markdown for block %@ to '%@'!", blockTypedef, path);
            return NO;
        }
        GBLogDebug(@"Finished generating output for block %@.", blockTypedef);
    }
    return YES;
}


- (BOOL)validateTemplates:(NSError **)error {
    if (!self.markdownTemplate) {
        if (error) {
            NSString *desc = [NSString stringWithFormat:@"Markdown template file 'markdown-template.md' is missing at '%@'!", self.templateUserPath];
            *error = [NSError errorWithCode:4000 description:desc reason:nil];
        }
        return NO;
    }
    return YES;
}

#pragma mark Helper methods

- (NSString *)stringByCleaningHtml:(NSString *)string {
    // Remove excess whitespace
    NSError *err;
    NSRegularExpression *newLinesMatchRegx = [NSRegularExpression regularExpressionWithPattern:@"[\\n]{2,}" options:0 error:&err];
    NSRegularExpression *paragraphMatchRegx = [NSRegularExpression regularExpressionWithPattern:@"<p>|</p>" options:0 error:&err];
    NSRegularExpression *divMatchRegx = [NSRegularExpression regularExpressionWithPattern:@"<div(.*?)>" options:0 error:&err];
    NSRegularExpression *divCloseMatchRegx = [NSRegularExpression regularExpressionWithPattern:@"<\\/div>" options:0 error:&err];
    string = [newLinesMatchRegx stringByReplacingMatchesInString:string options:0 range:NSMakeRange(0, string.length) withTemplate:@"\n\n"];
    string = [paragraphMatchRegx stringByReplacingMatchesInString:string options:0 range:NSMakeRange(0, string.length) withTemplate:@""];
    string = [divMatchRegx stringByReplacingMatchesInString:string options:0 range:NSMakeRange(0, string.length) withTemplate:@"\n\n"];
    string = [divCloseMatchRegx stringByReplacingMatchesInString:string options:0 range:NSMakeRange(0, string.length) withTemplate:@""];
    return string;
}

- (NSString *)markdownOutputPathForObject:(GBModelBase *)object {
    // Returns file name including full path for markdown file representing the given top-level object. This works for any top-level object: class, category or protocol. The path is automatically determined regarding to the object class.
    NSString *inner = [self.settings outputPathForObject:object withExtension:@"md"];
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

- (GBTemplateHandler *)markdownTemplate {
    return self.templateFiles[@"markdown-template.md"];
}


#pragma mark Overriden methods

- (NSString *)outputSubpath {
    return @"markdown";
}


@end
