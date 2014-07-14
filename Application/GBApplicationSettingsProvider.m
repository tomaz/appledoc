//
//  GBApplicationSettingsProvider.m
//  appledoc
//
//  Created by Tomaz Kragelj on 3.10.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#include "mkdio.h"
#import <objc/runtime.h>
#import <Cocoa/Cocoa.h>
#import "RegexKitLite.h"
#import "GBDataObjects.h"
#import "GBApplicationSettingsProvider.h"
#import "GBLog.h"

#import "SynthesizeSingleton.h"

NSString *kGBTemplatePlaceholderCompanyID = @"%COMPANYID";
NSString *kGBTemplatePlaceholderProjectID = @"%PROJECTID";
NSString *kGBTemplatePlaceholderVersionID = @"%VERSIONID";
NSString *kGBTemplatePlaceholderProject = @"%PROJECT";
NSString *kGBTemplatePlaceholderCompany = @"%COMPANY";
NSString *kGBTemplatePlaceholderVersion = @"%VERSION";
NSString *kGBTemplatePlaceholderDocSetBundleFilename = @"%DOCSETBUNDLEFILENAME";
NSString *kGBTemplatePlaceholderDocSetAtomFilename = @"%DOCSETATOMFILENAME";
NSString *kGBTemplatePlaceholderDocSetXMLFilename = @"%DOCSETXMLFILENAME";
NSString *kGBTemplatePlaceholderDocSetPackageFilename = @"%DOCSETPACKAGEFILENAME";
NSString *kGBTemplatePlaceholderYear = @"%YEAR";
NSString *kGBTemplatePlaceholderUpdateDate = @"%UPDATEDATE";

NSString *kGBCustomDocumentIndexDescKey = @"index-description";

GBHTMLAnchorFormat GBHTMLAnchorFormatFromNSString(NSString *formatString) {
    NSString *lowercaseFormatString = [formatString lowercaseString];
    if ([lowercaseFormatString isEqualToString:@"apple"]) {
        return GBHTMLAnchorFormatApple;
    }
    // We default to appledoc format if the option is not recognised
    return GBHTMLAnchorFormatAppleDoc;
}

NSString *NSStringFromGBHTMLAnchorFormat(GBHTMLAnchorFormat format) {
    switch (format) {
        case GBHTMLAnchorFormatAppleDoc:
            return @"appledoc";
        case GBHTMLAnchorFormatApple:
            return @"apple";
    }
}

GBPublishedFeedFormats GBPublishedFeedFormatsFromNSString(NSString *formatString) {
    // These items are comma delimited
    NSArray *formatItems = [[formatString lowercaseString] componentsSeparatedByString:@","];
    GBPublishedFeedFormats formats = 0;
    if ([formatItems containsObject:@"xml"]) {
        formats = formats | GBPublishedFeedFormatXML;
    }
    if ([formatItems containsObject:@"atom"]) {
        formats = formats | GBPublishedFeedFormatAtom;
    }
    return formats;
}

NSString *NSStringFromGBPublishedFeedFormats(GBPublishedFeedFormats formats) {
    NSMutableArray *formatItems = [NSMutableArray array];
    if(formats & GBPublishedFeedFormatAtom)
    {
        [formatItems addObject:@"atom"];
    }
    if(formats & GBPublishedFeedFormatXML)
    {
        [formatItems addObject:@"xml"];
    }
    return [formatItems componentsJoinedByString:@","];
}

#pragma mark -

@interface GBApplicationSettingsProvider ()

+ (NSSet *)nonCopyableProperties;
- (NSString *)htmlReferenceForObjectFromIndex:(GBModelBase *)object;
- (NSString *)htmlReferenceForTopLevelObject:(GBModelBase *)object fromTopLevelObject:(GBModelBase *)source;
- (NSString *)htmlReferenceForMember:(id)member prefixedWith:(id)prefix;
- (NSString *)outputPathForObject:(id)object withExtension:(NSString *)extension;
- (NSString *)stringByReplacingOccurencesOfRegex:(NSString *)regex inHTML:(NSString *)string usingBlock:(NSString *(^)(NSInteger captureCount, NSString * __unsafe_unretained *capturedStrings, BOOL insideCode))block;
- (NSString *)stringByNormalizingString:(NSString *)string;
@property (readonly) NSDateFormatter *yearDateFormatter;
@property (readonly) NSDateFormatter *yearToDayDateFormatter;

@end

#pragma mark -

@implementation GBApplicationSettingsProvider

SYNTHESIZE_SINGLETON_FOR_CLASS(GBApplicationSettingsProvider, sharedApplicationSettingsProvider);

#pragma mark Initialization & disposal

+ (NSSet *)nonCopyableProperties {
	return [NSSet setWithObjects:@"htmlExtension", @"yearDateFormatter", @"yearToDayDateFormatter", @"commentComponents", @"stringTemplates", nil];
}

+ (id)provider {
	return [[self alloc] init];
}

- (id)init {
	self = [super init];
	if (self) {
		self.projectName = nil;
		self.projectCompany = nil;
		self.projectVersion = @"1.0";
		self.companyIdentifier = @"";

		self.outputPath = @"";
		self.templatesPath = nil;
		self.docsetInstallPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Developer/Shared/Documentation/DocSets"];
		self.xcrunPath = @"/usr/bin/xcrun";
		if (![[NSFileManager defaultManager] fileExistsAtPath:self.xcrunPath]) {
			NSString *xcodePath = [[NSWorkspace sharedWorkspace] fullPathForApplication:@"Xcode"];
			self.xcrunPath = [xcodePath stringByAppendingPathComponent:@"Contents/Developer/usr/bin/xcrun"];
		}
		self.indexDescriptionPath = nil;
		self.includePaths = [NSMutableSet set];
		self.ignoredPaths = [NSMutableSet set];
        self.excludeOutputPaths = [NSMutableSet set];
		
		self.createHTML = YES;
		self.createDocSet = YES;
		self.installDocSet = YES;
		self.publishDocSet = NO;
        self.htmlAnchorFormat = GBHTMLAnchorFormatAppleDoc;
		self.repeatFirstParagraphForMemberDescription = YES;
		self.preprocessHeaderDoc = NO;
		self.printInformationBlockTitles = YES;
		self.useSingleStarForBold = NO;
		self.keepIntermediateFiles = NO;
		self.cleanupOutputPathBeforeRunning = NO;
		self.keepUndocumentedObjects = NO;
		self.keepUndocumentedMembers = NO;
		self.findUndocumentedMembersDocumentation = YES;
		self.treatDocSetIndexingErrorsAsFatals = NO;
		self.exitCodeThreshold = 0;
		
		self.mergeCategoriesToClasses = YES;
		self.mergeCategoryCommentToClass = YES;
		self.keepMergedCategoriesSections = NO;
		self.prefixMergedCategoriesSectionsWithCategoryName = NO;
        self.useCodeOrder = NO;
		
		self.prefixLocalMembersInRelatedItemsList = YES;
		self.embedCrossReferencesWhenProcessingMarkdown = YES;
		self.embedAppledocBoldMarkersWhenProcessingMarkdown = YES;

		self.warnOnMissingOutputPathArgument = YES;
		self.warnOnMissingCompanyIdentifier = YES;
		self.warnOnUndocumentedObject = YES;
		self.warnOnUndocumentedMember = YES;
		self.warnOnEmptyDescription = YES;
		self.warnOnUnknownDirective = YES;
		self.warnOnInvalidCrossReference = YES;
		self.warnOnMissingMethodArgument = YES;
		
		self.docsetBundleIdentifier = [NSString stringWithFormat:@"%@.%@", kGBTemplatePlaceholderCompanyID, kGBTemplatePlaceholderProjectID];
		self.docsetBundleName = [NSString stringWithFormat:@"%@ Documentation", kGBTemplatePlaceholderProject];
		self.docsetCertificateIssuer = @"";
		self.docsetCertificateSigner = @"";
		self.docsetDescription = @"";
		self.docsetFallbackURL = @"";
		self.docsetFeedName = self.docsetBundleName;
		self.docsetFeedURL = @"";
        self.docsetFeedFormats = GBPublishedFeedFormatAtom;
		self.docsetPackageURL = @"";
		self.docsetMinimumXcodeVersion = @"3.0";
		self.dashDocsetPlatformFamily = @"appledoc"; // this makes docset TOC usable from within Dash - http://kapeli.com/dash/
		self.docsetPlatformFamily = @"";
		self.docsetPublisherIdentifier = [NSString stringWithFormat:@"%@.documentation", kGBTemplatePlaceholderCompanyID];
		self.docsetPublisherName = [NSString stringWithFormat:@"%@", kGBTemplatePlaceholderCompany];
		self.docsetCopyrightMessage = [NSString stringWithFormat:@"Copyright © %@ %@. All rights reserved.", kGBTemplatePlaceholderYear, kGBTemplatePlaceholderCompany];
		
		self.docsetBundleFilename = [NSString stringWithFormat:@"%@.%@.docset", kGBTemplatePlaceholderCompanyID, kGBTemplatePlaceholderProjectID];
		self.docsetAtomFilename = [NSString stringWithFormat:@"%@.%@.atom", kGBTemplatePlaceholderCompanyID, kGBTemplatePlaceholderProjectID];
        self.docsetXMLFilename = [NSString stringWithFormat:@"%@.%@.xml", kGBTemplatePlaceholderCompanyID, kGBTemplatePlaceholderProjectID];
		self.docsetPackageFilename = [NSString stringWithFormat:@"%@.%@-%@", kGBTemplatePlaceholderCompanyID, kGBTemplatePlaceholderProjectID, kGBTemplatePlaceholderVersionID];
		
		self.commentComponents = [GBCommentComponentsProvider provider];
		self.stringTemplates = [GBApplicationStringsProvider provider];
	}
	return self;
}

#pragma mark Helper methods

- (void)updateHelperClassesWithSettingsValues {	
}

- (void)replaceAllOccurencesOfPlaceholderStringsInSettingsValues {
	// These need to be replaced first as they can be used in other settings!
	self.docsetBundleFilename = [self stringByReplacingOccurencesOfPlaceholdersInString:self.docsetBundleFilename];
	self.docsetAtomFilename = [self stringByReplacingOccurencesOfPlaceholdersInString:self.docsetAtomFilename];
    self.docsetXMLFilename = [self stringByReplacingOccurencesOfPlaceholdersInString:self.docsetXMLFilename];
	self.docsetPackageFilename = [self stringByReplacingOccurencesOfPlaceholdersInString:self.docsetPackageFilename];
	// Handle the rest now.
	self.docsetBundleIdentifier = [self stringByReplacingOccurencesOfPlaceholdersInString:self.docsetBundleIdentifier];
	self.docsetBundleName = [self stringByReplacingOccurencesOfPlaceholdersInString:self.docsetBundleName];
	self.docsetCertificateIssuer = [self stringByReplacingOccurencesOfPlaceholdersInString:self.docsetCertificateIssuer];
	self.docsetCertificateSigner = [self stringByReplacingOccurencesOfPlaceholdersInString:self.docsetCertificateSigner];
	self.docsetDescription = [self stringByReplacingOccurencesOfPlaceholdersInString:self.docsetDescription];
	self.docsetFallbackURL = [self stringByReplacingOccurencesOfPlaceholdersInString:self.docsetFallbackURL];
	self.docsetFeedName = [self stringByReplacingOccurencesOfPlaceholdersInString:self.docsetFeedName];
	self.docsetFeedURL = [self stringByReplacingOccurencesOfPlaceholdersInString:self.docsetFeedURL];
	self.docsetPackageURL = [self stringByReplacingOccurencesOfPlaceholdersInString:self.docsetPackageURL];
	self.docsetMinimumXcodeVersion = [self stringByReplacingOccurencesOfPlaceholdersInString:self.docsetMinimumXcodeVersion];
	self.docsetPlatformFamily = [self stringByReplacingOccurencesOfPlaceholdersInString:self.docsetPlatformFamily];
	self.docsetPublisherIdentifier = [self stringByReplacingOccurencesOfPlaceholdersInString:self.docsetPublisherIdentifier];
	self.docsetPublisherName = [self stringByReplacingOccurencesOfPlaceholdersInString:self.docsetPublisherName];
	self.docsetCopyrightMessage = [self stringByReplacingOccurencesOfPlaceholdersInString:self.docsetCopyrightMessage];
}

#pragma mark Common HTML handling

- (NSString *)stringByEmbeddingCrossReference:(NSString *)value {
	if (!self.embedCrossReferencesWhenProcessingMarkdown) return value;
	return [NSString stringWithFormat:@"%@%@%@", self.commentComponents.codeSpanStartMarker, value, self.commentComponents.codeSpanEndMarker];
}

- (NSString *)stringByEmbeddingAppledocBoldMarkers:(NSString *)value {
	if (!self.embedAppledocBoldMarkersWhenProcessingMarkdown) return value;
	return [NSString stringWithFormat:@"%@%@%@", self.commentComponents.appledocBoldStartMarker, value, self.commentComponents.appledocBoldEndMarker];
}

- (NSString *)stringByConvertingMarkdownToHTML:(NSString *)markdown {
	// First pass the markdown to discount to get it converted to HTML.
	NSString *result = nil;
	const char* input=[markdown cStringUsingEncoding:NSUTF8StringEncoding];
	
	if(input) {
		// Using gfm_string doesn't properly handle > %class%, so reverting back to original implementation!
		//MMIOT *document = gfm_string((char *)input, (int)strlen(input), 0);
		MMIOT *document = mkd_string((char *)input, (int)strlen(input), 0);
		mkd_compile(document, 0);
		
		char *html = NULL;
		int size = mkd_document(document, &html);
		
		if (size <= 0) {
			GBLogWarn(@"Failed converting markdown '%@' to HTML!", [markdown description]);
		} else {
			result = [NSString stringWithCString:html encoding:NSUTF8StringEncoding];
			if(!result)
				result = [NSString stringWithCString:html encoding:NSASCIIStringEncoding];
		}
		mkd_cleanup(document);
	}
	
	// We should properly handle cross references: if outside example block, simply strip prexif/suffix markers, otherwise extract description from Markdown style scross reference (i.e. [description](the rest)) and only use that part.
	if (self.embedCrossReferencesWhenProcessingMarkdown) {
		NSString *regex = [self stringByEmbeddingCrossReference:@"(.+?)"];
		result = [self stringByReplacingOccurencesOfRegex:regex inHTML:result usingBlock:^NSString *(NSInteger captureCount, NSString * __unsafe_unretained *capturedStrings, BOOL insideCode) {
			NSString *linkText = capturedStrings[1];
			if (!insideCode) return linkText;
			NSArray *components = [linkText captureComponentsMatchedByRegex:self.commentComponents.markdownInlineLinkRegex];
			if ([components count] < 1) return linkText;
			return [components objectAtIndex:1];
		}];
	}

	// We should properly handle Markdown bold markers (**) converted from appledoc style ones (*): if outside example block, simply strip prefix/suffix markers, otherwise convert back to single stars. Note that we first need to handle remaining placeholder markers inside example blocks, then cleanup converter formats.
	if (self.embedAppledocBoldMarkersWhenProcessingMarkdown) {
		NSString *openingMarker = [NSString stringWithFormat:@"**%@", self.commentComponents.appledocBoldStartMarker];
		NSString *closingMarker = [NSString stringWithFormat:@"%@**", self.commentComponents.appledocBoldEndMarker];
		result = [result stringByReplacingOccurrencesOfString:openingMarker withString:@"*"];
		result = [result stringByReplacingOccurrencesOfString:closingMarker withString:@"*"];
		result = [result stringByReplacingOccurrencesOfString:self.commentComponents.appledocBoldStartMarker withString:@""];
		result = [result stringByReplacingOccurrencesOfString:self.commentComponents.appledocBoldEndMarker withString:@""];
	}
	
	return result;
}

- (NSString *)stringByConvertingMarkdownToText:(NSString *)markdown {
	NSString *result = markdown;
	
	// Clean Markdown inline links. Note that we need to additionally handle remote member links [[class method]](address), these are not detected by our standard regex, but using common regex for these cases would incorrectly handle multiple links in the same string (it would greedily match the whole content between the first and the last link as the description). Note that the order of processing is important - we first need to handle "simple" links and then continue with remote members.
	result = [result stringByReplacingOccurrencesOfRegex:self.commentComponents.markdownInlineLinkRegex usingBlock:^NSString *(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
		return capturedStrings[1];
	}];
	result = [result stringByReplacingOccurrencesOfRegex:@"\\[(.+)\\]\\(([^\\s]+)(?:\\s*\"([^\"]+)\")?\\)" usingBlock:^NSString *(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
		return capturedStrings[1];
	}];
	
	// Clean formatting directives. Couldn't find single regex matcher for cleaning up all cases, so ended up in doing several phases and finally repeating the last one for any remaining cases... This makes unit tests pass...
	result = [result stringByReplacingOccurrencesOfRegex:@"(\\*\\*\\*|___|\\*\\*_|_\\*\\*|\\*__|__\\*)(.+?)\\1" usingBlock:^NSString *(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
		return capturedStrings[2];
	}];
	result = [result stringByReplacingOccurrencesOfRegex:@"(\\*\\*|__|\\*_|_\\*)(.+?)\\1" usingBlock:^NSString *(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
		return capturedStrings[2];
	}];
	result = [result stringByReplacingOccurrencesOfRegex:@"([*_`])(.+?)\\1" usingBlock:^NSString *(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
		return capturedStrings[2];
	}];
	result = [result stringByReplacingOccurrencesOfRegex:@"([*_`])(.+?)\\1" usingBlock:^NSString *(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
		return capturedStrings[2];
	}];
	
	// Convert hard coded HTML anchor links as these may cause problems with docsetutil. Basically we get address and description and output only description if found. Otherwise we use address.
	NSString *anchorRegex = @"<a\\s+href\\s*=\\s*([\"'])([^\\1]*)[\"']\\s*(?:(?:>([^>]*)</a>)|(?:/>))";
	result = [result stringByReplacingOccurrencesOfRegex:anchorRegex usingBlock:^NSString *(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
		if (captureCount < 2) return capturedStrings[0];
		if (captureCount < 3) return capturedStrings[2];
		NSString *description = capturedStrings[3];
		if ([description length] > 0) return description;
		return capturedStrings[2];
	}];
	
	// Replace any & sign with &amp; otherwise docsetutil will fail. However according to Apple stuff like &amp;ndash; should still be properly displayed in Xcode quick help when using html mode, which I can verify from my quick tests.
	result = [result stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
	
	// Remove embedded prefix/suffix.
	result = [result stringByReplacingOccurrencesOfString:self.commentComponents.codeSpanStartMarker withString:@""];
	result = [result stringByReplacingOccurrencesOfString:self.commentComponents.codeSpanEndMarker withString:@""];
	result = [result stringByReplacingOccurrencesOfString:self.commentComponents.appledocBoldStartMarker withString:@""];
	result = [result stringByReplacingOccurrencesOfString:self.commentComponents.appledocBoldEndMarker withString:@""];
	return result;
}

- (NSString *)stringByEscapingHTML:(NSString *)string {
	// Copied directly from GRMustache's GRMustacheVariableElement.m...
	NSMutableString *result = [NSMutableString stringWithCapacity:5 + ceilf(string.length * 1.1)];
	[result appendString:string];
	[result replaceOccurrencesOfString:@"&" withString:@"&amp;" options:NSLiteralSearch range:NSMakeRange(0, result.length)];
	[result replaceOccurrencesOfString:@"<" withString:@"&lt;" options:NSLiteralSearch range:NSMakeRange(0, result.length)];
	[result replaceOccurrencesOfString:@">" withString:@"&gt;" options:NSLiteralSearch range:NSMakeRange(0, result.length)];
	[result replaceOccurrencesOfString:@"\"" withString:@"&quot;" options:NSLiteralSearch range:NSMakeRange(0, result.length)];
	[result replaceOccurrencesOfString:@"'" withString:@"&apos;" options:NSLiteralSearch range:NSMakeRange(0, result.length)];
	return result;
}

- (NSString *)stringByReplacingOccurencesOfRegex:(NSString *)regex inHTML:(NSString *)string usingBlock:(NSString *(^)(NSInteger captureCount, NSString * __unsafe_unretained *capturedStrings, BOOL insideCode))block {
	NSString *theRegex = [NSString stringWithFormat:@"<code>|</code>|%@", regex];
	__block BOOL insideExampleBlock = NO;
	return [string stringByReplacingOccurrencesOfRegex:theRegex usingBlock:^NSString *(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
		// Change flag when inside example block - we need to handle strings differently there!
		NSString *matchedText = capturedStrings[0];
		if ([matchedText isEqualToString:@"<code>"]) {
			insideExampleBlock = YES;
			return matchedText;
		} else if ([matchedText isEqualToString:@"</code>"]) {
			insideExampleBlock = NO;
			return matchedText;
		}
		
		// Invoke parent block when matched the given regex
		NSString * __unsafe_unretained *strings = (NSString **)capturedStrings;
		return block(captureCount, strings, insideExampleBlock);
	}];
}

- (NSString *)htmlReferenceNameForObject:(GBModelBase *)object {
	NSParameterAssert(object != nil);
	if (object.isTopLevelObject) return [self htmlReferenceForObject:object fromSource:object];
	if (object.isStaticDocument) return [self htmlReferenceForObject:object fromSource:object];
	return [self htmlReferenceForMember:object prefixedWith:@""];
}

- (NSString *)htmlReferenceForObject:(GBModelBase *)object fromSource:(GBModelBase *)source {
	NSParameterAssert(object != nil);
	
	// Generate hrefs from index to objects:
	if (!source) {
		// To top-level object.
		if (object.isTopLevelObject) return [self htmlReferenceForObjectFromIndex:object];
		if (object.isStaticDocument) return [self htmlReferenceForObjectFromIndex:object];
		
		// To a member of top-level object.
		NSString *path = [self htmlReferenceForObjectFromIndex:object.parentObject];
		NSString *memberReference = [self htmlReferenceForMember:object prefixedWith:@"#"];
		return [NSString stringWithFormat:@"%@%@", path, memberReference];
	}
	
	// Generate hrefs from members to other objects.
	if (!source.isTopLevelObject && !source.isStaticDocument) {
		GBModelBase *sourceParent = source.parentObject;
		
		// To the parent or another top-level object.
		if (object.isTopLevelObject) return [self htmlReferenceForObject:object fromSource:sourceParent];
		if (object.isStaticDocument) return [self htmlReferenceForObject:object fromSource:sourceParent];

		// To same or another member of the same parent.
		if (object.parentObject == sourceParent) return [self htmlReferenceForMember:object prefixedWith:@"#"];

		// To a member of another top-level object.
		NSString *path = [self htmlReferenceForObject:object.parentObject fromSource:sourceParent];
		NSString *memberReference = [self htmlReferenceForMember:object prefixedWith:@"#"];
		return [NSString stringWithFormat:@"%@%@", path, memberReference];
	}
	
	// From now on we're generating hrefs from top-level object or documents to other documents, top-level objects or their members. First handle links from any kind of object to itself and top-level object or document to top-level object. Handle links from document to document slighlty differently, they are more complicated due to arbitrary directory structure.
	if (object == source || object.isTopLevelObject || object.isStaticDocument) return [self htmlReferenceForTopLevelObject:object fromTopLevelObject:source];
	
	// From top-level object or document to top-level object member.
	NSString *memberPath = [self htmlReferenceForMember:object prefixedWith:@"#"];
	if (object.parentObject != source) {
		NSString *objectPath = [self htmlReferenceForTopLevelObject:object.parentObject fromTopLevelObject:source];
		return [NSString stringWithFormat:@"%@%@", objectPath, memberPath];
	}
	
	// From top-level object to one of it's members.
	return memberPath;
}

- (NSString *)htmlReferenceForObjectFromIndex:(GBModelBase *)object {
	return [self outputPathForObject:object withExtension:[self htmlExtension]];
}

- (NSString *)htmlReferenceForTopLevelObject:(id)object fromTopLevelObject:(id)source {
	// Handles top-level object or document to top-level object or document.
	NSString *path = [self outputPathForObject:object withExtension:[self htmlExtension]];
	if (object == source) return [path lastPathComponent];
	NSString *prefix = [self htmlRelativePathToIndexFromObject:source];
	return [prefix stringByAppendingPathComponent:path];
}

- (NSString *)htmlReferenceForMember:(GBModelBase *)member prefixedWith:(NSString *)prefix {
	NSParameterAssert(member != nil);
	NSParameterAssert(prefix != nil);
	if ([member isKindOfClass:[GBMethodData class]]) {
		GBMethodData *method = (GBMethodData *)member;
        switch (htmlAnchorFormat) {
            case GBHTMLAnchorFormatApple:
                return [NSString stringWithFormat:@"%@//apple_ref/occ/%@/%@/%@", prefix, [method methodTypeString], [method parentObject], method.methodSelector];
            case GBHTMLAnchorFormatAppleDoc:
                return [NSString stringWithFormat:@"%@//api/name/%@", prefix, method.methodSelector];
        }
	}
	return @"";
}

- (NSString *)htmlStaticDocumentsSubpath {
	return @"docs";
}

- (NSString *)htmlExtension {
	return @"html";
}

#pragma mark Common template files helpers

- (BOOL)isPathRepresentingTemplateFile:(NSString *)path {
	NSString *filename = [[path lastPathComponent] stringByDeletingPathExtension];
	if ([filename hasSuffix:@"-template"]) return YES;
	return NO;
}

- (NSString *)outputFilenameForTemplatePath:(NSString *)path {
	NSString *result = [path lastPathComponent];
	return [result stringByReplacingOccurrencesOfString:@"-template" withString:@""];
}

- (NSString *)templateFilenameForOutputPath:(NSString *)path {
	// If the path is already valid template, just return it.
	if ([self isPathRepresentingTemplateFile:path]) return path;
	
	// Get all components.
	NSString *prefix = [path stringByDeletingLastPathComponent];
	NSString *filename = [[[path lastPathComponent] stringByDeletingPathExtension] stringByAppendingString:@"-template"];
	NSString *extension = [path pathExtension];
	
	// Prepare the result.
	NSString *result = [prefix stringByAppendingPathComponent:filename];
	if ([extension length] > 0) result = [result stringByAppendingPathExtension:extension];
	return result;
}

#pragma mark Date and time helpers

- (NSString *)yearStringFromDate:(NSDate *)date {
	return [self.yearDateFormatter stringFromDate:date];
}

- (NSString *)yearToDayStringFromDate:(NSDate *)date {
	return [self.yearToDayDateFormatter stringFromDate:date];
}

- (NSDateFormatter *)yearDateFormatter {
	static NSDateFormatter *result = nil;
	if (!result) {
		result = [[NSDateFormatter alloc] init];
		[result setDateFormat:@"yyyy"];
	}
	return result;
}

- (NSDateFormatter *)yearToDayDateFormatter {
	static NSDateFormatter *result = nil;
	if (!result) {
		result = [[NSDateFormatter alloc] init];
		[result setDateFormat:@"yyyy-MM-dd"];
	}
	return result;
}

#pragma mark Paths helper methods

- (NSString *)outputPathForObject:(id)object withExtension:(NSString *)extension {
	// Returns relative path to the given object from the output root (i.e. from the index file).
	NSString *basePath = nil;
	NSString *name = nil;
	if ([object isKindOfClass:[GBClassData class]]) {
		basePath = @"Classes";
		name = [object nameOfClass];
	}
	else if ([object isKindOfClass:[GBCategoryData class]]) {
		basePath = @"Categories";
		name = [NSString stringWithFormat:@"%@+%@", [object nameOfClass], [object nameOfCategory] ? [object nameOfCategory] : @""];
	}
	else if ([object isKindOfClass:[GBProtocolData class]]) {		
		basePath = @"Protocols";
		name = [object nameOfProtocol];
	}
    else if ([object isKindOfClass:[GBTypedefEnumData class]]) {
		basePath = @"Constants";
		name = [object nameOfEnum];
	}
    else if ([object isKindOfClass:[GBTypedefBlockData class]]) {
        basePath = @"Blocks";
        name = [object nameOfBlock];
    }
	else if ([object isKindOfClass:[GBDocumentData class]]) {
		GBDocumentData *document = object;
		
		// If this is custom document, just use it's relative path, otherwise take into account the registered path.
		if (document.isCustomDocument) {
			basePath = document.basePathOfDocument;
			name = document.nameOfDocument;
		} else {
			// Get output filename (removing template suffix) and document subpath without filename. Note that we need to remove extension as we'll add html by default!
			NSString *subpath = [document.subpathOfDocument stringByDeletingLastPathComponent];
			NSString *filename = [self outputFilenameForTemplatePath:document.pathOfDocument];
			filename = [filename stringByDeletingPathExtension];
			
			// If the document is included as part of a directory structure, we should use subdir, otherwise just leave the filename.
			if (![document.basePathOfDocument isEqualToString:document.pathOfDocument]) {
				NSString *includePath = [document.basePathOfDocument lastPathComponent];
				subpath = [includePath stringByAppendingPathComponent:subpath];
			}

			// Prepare relative path from output path to the document now.
			basePath = [self.htmlStaticDocumentsSubpath stringByAppendingPathComponent:subpath];
			name = filename;
		}
	}
	
	if (basePath == nil || name == nil) return nil;
	basePath = [basePath stringByAppendingPathComponent:name];
	return [basePath stringByAppendingPathExtension:extension];
}

- (NSString *)htmlRelativePathToIndexFromObject:(id)object {
	// Returns relative path prefix from the given source to the given destination or empty string if both objects live in the same path. This is pretty simple except when object is a document. In such case we need to handle arbitrary depth.	
	if ([object isStaticDocument]) {
		NSString *subpath = [self outputPathForObject:object withExtension:@"extension"];
		subpath = [subpath stringByDeletingLastPathComponent];
		if ([subpath length] > 0) {
			NSArray *components = [subpath pathComponents];
			NSMutableString *result = [NSMutableString stringWithCapacity:[subpath length]];
			for (NSUInteger i=0; i<[components count]; i++) [result appendString:@"../"];
			return result;
		} else {
			return @"";
		}
	}
	return @"../";
}

#pragma mark Helper methods

- (BOOL)isTopLevelStoreObject:(id)object {
	if ([object isKindOfClass:[GBClassData class]] || [object isKindOfClass:[GBCategoryData class]] || [object isKindOfClass:[GBProtocolData class]])
		return YES;
	return NO;
}

- (NSString *)stringByReplacingOccurencesOfPlaceholdersInString:(NSString *)string {
	string = [string stringByReplacingOccurrencesOfString:kGBTemplatePlaceholderCompanyID withString:self.companyIdentifier];
	string = [string stringByReplacingOccurrencesOfString:kGBTemplatePlaceholderProjectID withString:self.projectIdentifier];
	string = [string stringByReplacingOccurrencesOfString:kGBTemplatePlaceholderVersionID withString:self.versionIdentifier];
	string = [string stringByReplacingOccurrencesOfString:kGBTemplatePlaceholderProject withString:self.projectName];
	string = [string stringByReplacingOccurrencesOfString:kGBTemplatePlaceholderCompany withString:self.projectCompany];
	string = [string stringByReplacingOccurrencesOfString:kGBTemplatePlaceholderVersion withString:self.projectVersion];
	string = [string stringByReplacingOccurrencesOfString:kGBTemplatePlaceholderDocSetBundleFilename withString:self.docsetBundleFilename];
	string = [string stringByReplacingOccurrencesOfString:kGBTemplatePlaceholderDocSetAtomFilename withString:self.docsetAtomFilename];
    string = [string stringByReplacingOccurrencesOfString:kGBTemplatePlaceholderDocSetXMLFilename withString:self.docsetXMLFilename];
	string = [string stringByReplacingOccurrencesOfString:kGBTemplatePlaceholderDocSetPackageFilename withString:self.docsetPackageFilename];
	string = [string stringByReplacingOccurrencesOfString:kGBTemplatePlaceholderYear withString:[self yearStringFromDate:[NSDate date]]];
	string = [string stringByReplacingOccurrencesOfString:kGBTemplatePlaceholderUpdateDate withString:[self yearToDayStringFromDate:[NSDate date]]];
	return string;
}

- (NSString *)stringByNormalizingString:(NSString *)string {
	return [string stringByReplacingOccurrencesOfRegex:@"[ \t]+" withString:@"-"];
}

#pragma mark Overriden methods

- (NSString *)description {
	return [self className];
}

- (NSString *)debugDescription {
	// Based on http://stackoverflow.com/questions/754824/get-an-object-attributes-list-in-objective-c/4008326#4008326
	NSMutableString *result = [NSMutableString string];
	unsigned int outCount, i;	
	objc_property_t *properties = class_copyPropertyList([self class], &outCount);
	for (i=0; i<outCount; i++) {
		objc_property_t property = properties[i];
		const char *propName = property_getName(property);
		if (propName) {
            NSString *propertyName = [NSString stringWithUTF8String:propName];
			NSString *propertyValue = [self valueForKey:propertyName];
			[result appendFormat:@"%@ = %@\n", propertyName, propertyValue];
		}
	}
	free(properties);
	return result;
}

#pragma mark Properties

- (NSString *)projectIdentifier {
	return [self stringByNormalizingString:self.projectName];
}

- (NSString *)versionIdentifier {
	return [self stringByNormalizingString:self.projectVersion];
}

@synthesize projectName;
@synthesize projectCompany;
@synthesize projectVersion;
@synthesize companyIdentifier;

@synthesize outputPath;
@synthesize docsetInstallPath;
@synthesize xcrunPath;
@synthesize templatesPath;
@synthesize includePaths;
@synthesize indexDescriptionPath;
@synthesize ignoredPaths;
@synthesize excludeOutputPaths;

@synthesize docsetBundleIdentifier;
@synthesize docsetBundleName;
@synthesize docsetCertificateIssuer;
@synthesize docsetCertificateSigner;
@synthesize docsetDescription;
@synthesize docsetFallbackURL;
@synthesize docsetFeedName;
@synthesize docsetFeedURL;
@synthesize docsetFeedFormats;
@synthesize docsetPackageURL;
@synthesize docsetMinimumXcodeVersion;
@synthesize dashDocsetPlatformFamily;
@synthesize docsetPlatformFamily;
@synthesize docsetPublisherIdentifier;
@synthesize docsetPublisherName;
@synthesize docsetCopyrightMessage;

@synthesize docsetBundleFilename;
@synthesize docsetAtomFilename;
@synthesize docsetXMLFilename;
@synthesize docsetPackageFilename;

@synthesize repeatFirstParagraphForMemberDescription;
@synthesize preprocessHeaderDoc;
@synthesize printInformationBlockTitles;
@synthesize useSingleStarForBold;
@synthesize keepUndocumentedObjects;
@synthesize keepUndocumentedMembers;
@synthesize findUndocumentedMembersDocumentation;

@synthesize mergeCategoriesToClasses;
@synthesize mergeCategoryCommentToClass;
@synthesize keepMergedCategoriesSections;
@synthesize prefixMergedCategoriesSectionsWithCategoryName;
@synthesize useCodeOrder;

@synthesize prefixLocalMembersInRelatedItemsList;
@synthesize embedCrossReferencesWhenProcessingMarkdown;
@synthesize embedAppledocBoldMarkersWhenProcessingMarkdown;

@synthesize createHTML;
@synthesize createDocSet;
@synthesize installDocSet;
@synthesize publishDocSet;
@synthesize htmlAnchorFormat;
@synthesize keepIntermediateFiles;
@synthesize cleanupOutputPathBeforeRunning;
@synthesize treatDocSetIndexingErrorsAsFatals;
@synthesize exitCodeThreshold;

@synthesize warnOnMissingOutputPathArgument;
@synthesize warnOnMissingCompanyIdentifier;
@synthesize warnOnUndocumentedObject;
@synthesize warnOnUndocumentedMember;
@synthesize warnOnEmptyDescription;
@synthesize warnOnUnknownDirective;
@synthesize warnOnInvalidCrossReference;
@synthesize warnOnMissingMethodArgument;

@synthesize commentComponents;
@synthesize stringTemplates;

@end
