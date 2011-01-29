//
//  GBApplicationSettingsProvider.m
//  appledoc
//
//  Created by Tomaz Kragelj on 3.10.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import <objc/runtime.h>
#import "RegexKitLite.h"
#import "GBDataObjects.h"
#import "GBApplicationSettingsProvider.h"

NSString *kGBTemplatePlaceholderCompanyID = @"%COMPANYID";
NSString *kGBTemplatePlaceholderProjectID = @"%PROJECTID";
NSString *kGBTemplatePlaceholderVersionID = @"%VERSIONID";
NSString *kGBTemplatePlaceholderProject = @"%PROJECT";
NSString *kGBTemplatePlaceholderCompany = @"%COMPANY";
NSString *kGBTemplatePlaceholderVersion = @"%VERSION";
NSString *kGBTemplatePlaceholderDocSetBundleFilename = @"%DOCSETBUNDLEFILENAME";
NSString *kGBTemplatePlaceholderDocSetAtomFilename = @"%DOCSETATOMFILENAME";
NSString *kGBTemplatePlaceholderDocSetPackageFilename = @"%DOCSETPACKAGEFILENAME";
NSString *kGBTemplatePlaceholderYear = @"%YEAR";
NSString *kGBTemplatePlaceholderUpdateDate = @"%UPDATEDATE";

#pragma mark -

@interface GBApplicationSettingsProvider ()

+ (NSSet *)nonCopyableProperties;
- (NSString *)outputPathForObject:(id)object withExtension:(NSString *)extension;
- (NSString *)relativePathPrefixFromObject:(GBModelBase *)source toObject:(GBModelBase *)destination;
- (NSString *)htmlReferenceForObjectFromIndex:(GBModelBase *)object;
- (NSString *)htmlReferenceForTopLevelObject:(GBModelBase *)object fromTopLevelObject:(GBModelBase *)source;
- (NSString *)htmlReferenceForMember:(GBModelBase *)member prefixedWith:(NSString *)prefix;
- (NSString *)stringByNormalizingString:(NSString *)string;
@property (readonly) NSDateFormatter *yearDateFormatter;
@property (readonly) NSDateFormatter *yearToDayDateFormatter;

@end

#pragma mark -

@implementation GBApplicationSettingsProvider

#pragma mark Initialization & disposal

+ (NSSet *)nonCopyableProperties {
	return [NSSet setWithObjects:@"htmlExtension", @"yearDateFormatter", @"yearToDayDateFormatter", @"commentComponents", @"stringTemplates", nil];
}

+ (id)provider {
	return [[[self alloc] init] autorelease];
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
		self.docsetUtilPath = @"/Developer/usr/bin/docsetutil";
		self.ignoredPaths = [NSMutableSet set];
		
		self.createHTML = YES;
		self.createDocSet = YES;
		self.installDocSet = YES;
		self.publishDocSet = NO;
		self.repeatFirstParagraphForMemberDescription = YES;
		self.keepIntermediateFiles = NO;
		self.keepUndocumentedObjects = NO;
		self.keepUndocumentedMembers = NO;
		self.findUndocumentedMembersDocumentation = YES;
		self.mergeCategoriesToClasses = YES;
		self.keepMergedCategoriesSections = NO;
		self.prefixMergedCategoriesSectionsWithCategoryName = NO;

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
		self.docsetPackageURL = @"";
		self.docsetMinimumXcodeVersion = @"3.0";
		self.docsetPlatformFamily = @"";
		self.docsetPublisherIdentifier = [NSString stringWithFormat:@"%@.documentation", kGBTemplatePlaceholderCompanyID];
		self.docsetPublisherName = [NSString stringWithFormat:@"%@", kGBTemplatePlaceholderCompany];
		self.docsetCopyrightMessage = [NSString stringWithFormat:@"Copyright © %@ %@. All rights reserved.", kGBTemplatePlaceholderYear, kGBTemplatePlaceholderCompany];
		
		self.docsetBundleFilename = [NSString stringWithFormat:@"%@.%@.docset", kGBTemplatePlaceholderCompanyID, kGBTemplatePlaceholderProjectID];
		self.docsetAtomFilename = [NSString stringWithFormat:@"%@.%@.atom", kGBTemplatePlaceholderCompanyID, kGBTemplatePlaceholderProjectID];
		self.docsetPackageFilename = [NSString stringWithFormat:@"%@.%@-%@.xar", kGBTemplatePlaceholderCompanyID, kGBTemplatePlaceholderProjectID, kGBTemplatePlaceholderVersionID];
		
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

- (NSString *)htmlReferenceNameForObject:(GBModelBase *)object {
	NSParameterAssert(object != nil);
	if (object.isTopLevelObject) return [self htmlReferenceForObject:object fromSource:object];
	return [self htmlReferenceForMember:object prefixedWith:@""];
}

- (NSString *)htmlReferenceForObject:(GBModelBase *)object fromSource:(GBModelBase *)source {
	NSParameterAssert(object != nil);
	
	// Generate hrefs from index to objects:
	if (!source) {
		// To top-level object.
		if (object.isTopLevelObject) return [self htmlReferenceForObjectFromIndex:object];
		
		// To a member of top-level object.
		NSString *path = [self htmlReferenceForObjectFromIndex:object.parentObject];
		NSString *memberReference = [self htmlReferenceForMember:object prefixedWith:@"#"];
		return [NSString stringWithFormat:@"%@%@", path, memberReference];
	}
	
	// Generate hrefs from member to other objects:
	if (!source.isTopLevelObject) {
		GBModelBase *sourceParent = source.parentObject;
		
		// To the parent or another top-level object.
		if (object.isTopLevelObject) return [self htmlReferenceForObject:object fromSource:sourceParent];

		// To same or another member of the same parent.
		if (object.parentObject == sourceParent) return [self htmlReferenceForMember:object prefixedWith:@"#"];

		// To a member of another top-level object.
		NSString *path = [self htmlReferenceForObject:object.parentObject fromSource:sourceParent];
		NSString *memberReference = [self htmlReferenceForMember:object prefixedWith:@"#"];
		return [NSString stringWithFormat:@"%@%@", path, memberReference];
	}
	
	// From top-level object to samo or another top level object.
	if (object == source || object.isTopLevelObject) {
		return [self htmlReferenceForTopLevelObject:object fromTopLevelObject:source];
	}
	
	// From top-level object to another top-level object member.
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

- (NSString *)htmlReferenceForTopLevelObject:(GBModelBase *)object fromTopLevelObject:(GBModelBase *)source {
	NSString *path = [self outputPathForObject:object withExtension:[self htmlExtension]];
	if ([object isKindOfClass:[source class]]) return [path lastPathComponent];
	NSString *prefix = [self relativePathPrefixFromObject:source toObject:object];
	return [prefix stringByAppendingPathComponent:path];
}

- (NSString *)htmlReferenceForMember:(GBModelBase *)member prefixedWith:(NSString *)prefix {
	NSParameterAssert(member != nil);
	NSParameterAssert(prefix != nil);
	if ([member isKindOfClass:[GBMethodData class]]) {
		GBMethodData *method = (GBMethodData *)member;
		return [NSString stringWithFormat:@"%@//api/name/%@", prefix, method.methodSelector];
	}
	return @"";
}

- (NSString *)htmlExtension {
	return @"html";
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
	NSString *basePath = nil;
	NSString *name = nil;
	if ([object isKindOfClass:[GBClassData class]]) {
		basePath = @"Classes";
		name = [object nameOfClass];
	}
	else if ([object isKindOfClass:[GBCategoryData class]]) {
		basePath = @"Categories";
		name = [object idOfCategory];
	}
	else if ([object isKindOfClass:[GBProtocolData class]]) {		
		basePath = @"Protocols";
		name = [object nameOfProtocol];
	}
	
	if (basePath == nil || name == nil) return nil;
	basePath = [basePath stringByAppendingPathComponent:name];
	return [basePath stringByAppendingPathExtension:extension];
}

- (NSString *)relativePathPrefixFromObject:(GBModelBase *)source toObject:(GBModelBase *)destination {
	if ([source isKindOfClass:[destination class]]) return @"";
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
@synthesize docsetUtilPath;
@synthesize templatesPath;
@synthesize ignoredPaths;

@synthesize docsetBundleIdentifier;
@synthesize docsetBundleName;
@synthesize docsetCertificateIssuer;
@synthesize docsetCertificateSigner;
@synthesize docsetDescription;
@synthesize docsetFallbackURL;
@synthesize docsetFeedName;
@synthesize docsetFeedURL;
@synthesize docsetPackageURL;
@synthesize docsetMinimumXcodeVersion;
@synthesize docsetPlatformFamily;
@synthesize docsetPublisherIdentifier;
@synthesize docsetPublisherName;
@synthesize docsetCopyrightMessage;

@synthesize docsetBundleFilename;
@synthesize docsetAtomFilename;
@synthesize docsetPackageFilename;

@synthesize repeatFirstParagraphForMemberDescription;
@synthesize keepUndocumentedObjects;
@synthesize keepUndocumentedMembers;
@synthesize findUndocumentedMembersDocumentation;

@synthesize mergeCategoriesToClasses;
@synthesize keepMergedCategoriesSections;
@synthesize prefixMergedCategoriesSectionsWithCategoryName;

@synthesize createHTML;
@synthesize createDocSet;
@synthesize installDocSet;
@synthesize publishDocSet;
@synthesize keepIntermediateFiles;

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
