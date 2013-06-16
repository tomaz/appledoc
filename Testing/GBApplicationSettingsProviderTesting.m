//
//  GBApplicationSettingsProviderTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 14.10.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBDataObjects.h"
#import "GBApplicationSettingsProvider.h"

@interface GBApplicationSettingsProviderTesting : GHTestCase

- (NSDateFormatter *)yearFormatterFromSettings:(GBApplicationSettingsProvider *)settings;
- (NSDateFormatter *)yearToDayFormatterFromSettings:(GBApplicationSettingsProvider *)settings;

@end
	
@implementation GBApplicationSettingsProviderTesting

#pragma mark Placeholders replacing

- (void)testPlaceholderReplacements_shouldReplacePlaceholderStringsInAllSupportedValues {
	// setup
	GBApplicationSettingsProvider *settings = [GBApplicationSettingsProvider provider];
	settings.projectName = @"<P N>";
	settings.projectCompany = @"<P C>";
	settings.projectVersion = @"<P V>";
	settings.companyIdentifier = @"<C I>";
	NSString *template = @"%PROJECT/%COMPANY/%VERSION/%PROJECTID/%COMPANYID/%VERSIONID/%YEAR/%UPDATEDATE";
	settings.docsetBundleIdentifier = template;
	settings.docsetBundleName = template;
	settings.docsetCertificateIssuer = template;
	settings.docsetCertificateSigner = template;
	settings.docsetDescription = template;
	settings.docsetFallbackURL = template;
	settings.docsetFeedName = template;
	settings.docsetFeedURL = template;
	settings.docsetPackageURL = template;
	settings.docsetMinimumXcodeVersion = template;
	settings.docsetPlatformFamily = template;
	settings.docsetPublisherIdentifier = template;
	settings.docsetPublisherName = template;
	settings.docsetCopyrightMessage = template;
	settings.docsetBundleFilename = template;
	settings.docsetAtomFilename = template;
    settings.docsetXMLFilename = template;
	settings.docsetPackageFilename = template;
	// setup expected values; this might break sometimes as it's based on time...
	NSDate *date = [NSDate date];
	NSString *year = [[self yearFormatterFromSettings:settings] stringFromDate:date];
	NSString *day = [[self yearToDayFormatterFromSettings:settings] stringFromDate:date];
	NSString *expected = [NSString stringWithFormat:@"<P N>/<P C>/<P V>/<P-N>/<C I>/<P-V>/%@/%@", year, day];
	// execute
	[settings replaceAllOccurencesOfPlaceholderStringsInSettingsValues];
	// verify
	assertThat(settings.docsetBundleIdentifier, is(expected));
	assertThat(settings.docsetBundleName, is(expected));
	assertThat(settings.docsetCertificateIssuer, is(expected));
	assertThat(settings.docsetCertificateSigner, is(expected));
	assertThat(settings.docsetDescription, is(expected));
	assertThat(settings.docsetFallbackURL, is(expected));
	assertThat(settings.docsetFeedName, is(expected));
	assertThat(settings.docsetFeedURL, is(expected));
	assertThat(settings.docsetPackageURL, is(expected));
	assertThat(settings.docsetMinimumXcodeVersion, is(expected));
	assertThat(settings.docsetPlatformFamily, is(expected));
	assertThat(settings.docsetPublisherIdentifier, is(expected));
	assertThat(settings.docsetPublisherName, is(expected));
	assertThat(settings.docsetCopyrightMessage, is(expected));
	assertThat(settings.docsetBundleFilename, is(expected));
	assertThat(settings.docsetAtomFilename, is(expected));
    assertThat(settings.docsetXMLFilename, is(expected));
	assertThat(settings.docsetPackageFilename, is(expected));
}

- (void)testPlaceholderReplacements_shouldReplaceDocSetFilenames {
	// setup
	GBApplicationSettingsProvider *settings = [GBApplicationSettingsProvider provider];
	settings.projectName = @"<PN>";
	settings.projectCompany = @"<PC>";
	settings.projectVersion = @"<PV>";
	settings.companyIdentifier = @"<CI>";
	settings.docsetBundleFilename = @"<DSB>";
	settings.docsetAtomFilename = @"<DSA>";
    settings.docsetXMLFilename = @"<DSX>";
	settings.docsetPackageFilename = @"<DSP>";
	NSString *template = @"%DOCSETBUNDLEFILENAME/%DOCSETATOMFILENAME/%DOCSETXMLFILENAME/%DOCSETPACKAGEFILENAME";
	settings.docsetBundleIdentifier = template;
	settings.docsetBundleName = template;
	settings.docsetCertificateIssuer = template;
	settings.docsetCertificateSigner = template;
	settings.docsetDescription = template;
	settings.docsetFallbackURL = template;
	settings.docsetFeedName = template;
	settings.docsetFeedURL = template;
	settings.docsetPackageURL = template;
	settings.docsetMinimumXcodeVersion = template;
	settings.docsetPlatformFamily = template;
	settings.docsetPublisherIdentifier = template;
	settings.docsetPublisherName = template;
	settings.docsetCopyrightMessage = template;
	NSString *expected = @"<DSB>/<DSA>/<DSX>/<DSP>";
	// execute
	[settings replaceAllOccurencesOfPlaceholderStringsInSettingsValues];
	// verify
	assertThat(settings.docsetBundleIdentifier, is(expected));
	assertThat(settings.docsetBundleName, is(expected));
	assertThat(settings.docsetCertificateIssuer, is(expected));
	assertThat(settings.docsetCertificateSigner, is(expected));
	assertThat(settings.docsetDescription, is(expected));
	assertThat(settings.docsetFallbackURL, is(expected));
	assertThat(settings.docsetFeedName, is(expected));
	assertThat(settings.docsetFeedURL, is(expected));
	assertThat(settings.docsetPackageURL, is(expected));
	assertThat(settings.docsetMinimumXcodeVersion, is(expected));
	assertThat(settings.docsetPlatformFamily, is(expected));
	assertThat(settings.docsetPublisherIdentifier, is(expected));
	assertThat(settings.docsetPublisherName, is(expected));
	assertThat(settings.docsetCopyrightMessage, is(expected));
}

- (void)testProjectIdentifier_shouldNormalizeProjectName {
	// setup
	GBApplicationSettingsProvider *settings = [GBApplicationSettingsProvider provider];
	settings.projectName = @"My Great  \t Project";
	// execute & verify
	assertThat(settings.projectIdentifier, is(@"My-Great-Project"));
}

- (void)testVersionIdentifier_shouldNormalizeProjectVersion {
	// setup
	GBApplicationSettingsProvider *settings = [GBApplicationSettingsProvider provider];
	settings.projectVersion = @"1.0 beta3  \t something";
	// execute & verify
	assertThat(settings.versionIdentifier, is(@"1.0-beta3-something"));
}

#pragma mark HTML href names handling

- (void)testHtmlReferenceNameForObject_shouldReturnProperValueForTopLevelObjects {
	// setup
	GBApplicationSettingsProvider *settings = [GBApplicationSettingsProvider provider];
	settings.outputPath = @"anything :)";
	GBClassData *class = [GBClassData classDataWithName:@"Class"];
	GBCategoryData *category = [GBCategoryData categoryDataWithName:@"Category" className:@"Class"];
	GBCategoryData *extension = [GBCategoryData categoryDataWithName:nil className:@"Class"];
	GBProtocolData *protocol = [GBProtocolData protocolDataWithName:@"Protocol"];
	// execute & verify
	assertThat([settings htmlReferenceNameForObject:class], is(@"Class.html"));
	assertThat([settings htmlReferenceNameForObject:category], is(@"Class+Category.html"));
	assertThat([settings htmlReferenceNameForObject:extension], is(@"Class+.html"));
	assertThat([settings htmlReferenceNameForObject:protocol], is(@"Protocol.html"));
}

- (void)testHtmlReferenceNameForObject_shouldReturnProperValueForDocuments {
	// setup
	GBApplicationSettingsProvider *settings = [GBApplicationSettingsProvider provider];
	settings.outputPath = @"anything :)";
	GBDocumentData *document1 = [GBDocumentData documentDataWithContents:@"c" path:@"document-template.html" basePath:@""];
	GBDocumentData *document2 = [GBDocumentData documentDataWithContents:@"c" path:@"path/document-template.html" basePath:@""];
	GBDocumentData *document3 = [GBDocumentData documentDataWithContents:@"c" path:@"path/sub/document-template.html" basePath:@""];
	GBDocumentData *document4 = [GBDocumentData documentDataWithContents:@"c" path:@"path/sub/document-template.html" basePath:@"path"];
	// verify
	assertThat([settings htmlReferenceNameForObject:document1], is(@"document.html"));
	assertThat([settings htmlReferenceNameForObject:document2], is(@"document.html"));
	assertThat([settings htmlReferenceNameForObject:document3], is(@"document.html"));
	assertThat([settings htmlReferenceNameForObject:document4], is(@"document.html"));
}

- (void)testHtmlReferenceNameForObject_shouldReturnProperValueForMethods {
	// setup
	GBApplicationSettingsProvider *settings1 = [GBApplicationSettingsProvider provider];
	GBApplicationSettingsProvider *settings2 = [GBApplicationSettingsProvider provider];
	settings1.outputPath = @"anything :)";
	settings2.outputPath = @"anything :)";
    settings2.htmlAnchorFormat = GBHTMLAnchorFormatApple;
	GBMethodArgument *argument = [GBMethodArgument methodArgumentWithName:@"method"];
	GBMethodData *method1 = [GBTestObjectsRegistry instanceMethodWithArguments:argument, nil];
	GBMethodData *method2 = [GBTestObjectsRegistry instanceMethodWithNames:@"doSomething", @"withVars", nil];
	GBMethodData *property = [GBTestObjectsRegistry propertyMethodWithArgument:@"value"];
	GBClassData *class = [GBClassData classDataWithName:@"Class"];
	[class.methods registerMethod:method1];
	[class.methods registerMethod:method2];
	[class.methods registerMethod:property];
	// execute & verify
	assertThat([settings1 htmlReferenceNameForObject:method1], is(@"//api/name/method"));
	assertThat([settings1 htmlReferenceNameForObject:method2], is(@"//api/name/doSomething:withVars:"));
	assertThat([settings1 htmlReferenceNameForObject:property], is(@"//api/name/value"));
	assertThat([settings2 htmlReferenceNameForObject:method1], is(@"//apple_ref/occ/instm/Class/method"));
	assertThat([settings2 htmlReferenceNameForObject:method2], is(@"//apple_ref/occ/instm/Class/doSomething:withVars:"));
	assertThat([settings2 htmlReferenceNameForObject:property], is(@"//apple_ref/occ/instp/Class/value"));
}

#pragma mark HTML href references handling - index

- (void)testHtmlReferenceForObjectFromSource_shouldReturnProperValueForClassFromIndex {
	// setup
	GBApplicationSettingsProvider *settings1 = [GBApplicationSettingsProvider provider];
	GBApplicationSettingsProvider *settings2 = [GBApplicationSettingsProvider provider];
	settings1.outputPath = @"anything :)";
	settings2.outputPath = @"anything :)";
    settings2.htmlAnchorFormat = GBHTMLAnchorFormatApple;
	GBClassData *class = [GBClassData classDataWithName:@"Class"];
	GBMethodData *method = [GBTestObjectsRegistry instanceMethodWithNames:@"method", nil];
	[class.methods registerMethod:method];
	// execute & verify
	assertThat([settings1 htmlReferenceForObject:class fromSource:nil], is(@"Classes/Class.html"));
	assertThat([settings1 htmlReferenceForObject:method fromSource:nil], is(@"Classes/Class.html#//api/name/method:"));
	assertThat([settings2 htmlReferenceForObject:class fromSource:nil], is(@"Classes/Class.html"));
	assertThat([settings2 htmlReferenceForObject:method fromSource:nil], is(@"Classes/Class.html#//apple_ref/occ/instm/Class/method:"));
}

- (void)testHtmlReferenceForObjectFromSource_shouldReturnProperValueForCategoryFromIndex {
	// setup
	GBApplicationSettingsProvider *settings1 = [GBApplicationSettingsProvider provider];
	GBApplicationSettingsProvider *settings2 = [GBApplicationSettingsProvider provider];
	settings1.outputPath = @"anything :)";
	settings2.outputPath = @"anything :)";
    settings2.htmlAnchorFormat = GBHTMLAnchorFormatApple;
	GBCategoryData *category = [GBCategoryData categoryDataWithName:@"Category" className:@"Class"];
	GBMethodData *method = [GBTestObjectsRegistry instanceMethodWithNames:@"method", nil];
	[category.methods registerMethod:method];
	// execute & verify
	assertThat([settings1 htmlReferenceForObject:category fromSource:nil], is(@"Categories/Class+Category.html"));
	assertThat([settings1 htmlReferenceForObject:method fromSource:nil], is(@"Categories/Class+Category.html#//api/name/method:"));
	assertThat([settings2 htmlReferenceForObject:category fromSource:nil], is(@"Categories/Class+Category.html"));
	assertThat([settings2 htmlReferenceForObject:method fromSource:nil], is(@"Categories/Class+Category.html#//apple_ref/occ/instm/Class(Category)/method:"));
}

- (void)testHtmlReferenceForObjectFromSource_shouldReturnProperValueForProtocolFromIndex {
	// setup
	GBApplicationSettingsProvider *settings1 = [GBApplicationSettingsProvider provider];
	GBApplicationSettingsProvider *settings2 = [GBApplicationSettingsProvider provider];
	settings1.outputPath = @"anything :)";
	settings2.outputPath = @"anything :)";
    settings2.htmlAnchorFormat = GBHTMLAnchorFormatApple;
	GBProtocolData *protocol = [GBProtocolData protocolDataWithName:@"Protocol"];
	GBMethodData *method = [GBTestObjectsRegistry instanceMethodWithNames:@"method", nil];
	[protocol.methods registerMethod:method];
	// execute & verify
	assertThat([settings1 htmlReferenceForObject:protocol fromSource:nil], is(@"Protocols/Protocol.html"));
	assertThat([settings1 htmlReferenceForObject:method fromSource:nil], is(@"Protocols/Protocol.html#//api/name/method:"));
	assertThat([settings2 htmlReferenceForObject:protocol fromSource:nil], is(@"Protocols/Protocol.html"));
	assertThat([settings2 htmlReferenceForObject:method fromSource:nil], is(@"Protocols/Protocol.html#//apple_ref/occ/intfm/Protocol/method:"));
}

- (void)testHtmlReferenceForObjectFromSource_shouldReturnProperValueForDocumentFromIndex {
	// setup
	GBApplicationSettingsProvider *settings = [GBApplicationSettingsProvider provider];
	settings.outputPath = @"anything :)";
	GBDocumentData *document1 = [GBDocumentData documentDataWithContents:@"c" path:@"document-template.html" basePath:@""];
	GBDocumentData *document2 = [GBDocumentData documentDataWithContents:@"c" path:@"include/document-template.html" basePath:@""];
	GBDocumentData *document3 = [GBDocumentData documentDataWithContents:@"c" path:@"include/sub/document-template.html" basePath:@""];
	GBDocumentData *document4 = [GBDocumentData documentDataWithContents:@"c" path:@"include/sub/document-template.html" basePath:@"include"];
	GBDocumentData *document5 = [GBDocumentData documentDataWithContents:@"c" path:@"include/sub/document-template.html" basePath:@"include/sub"];
	GBDocumentData *document6 = [GBDocumentData documentDataWithContents:@"c" path:@"include/sub/document-template.html" basePath:@"include/sub/document-template.html"];
	// verify
	assertThat([settings htmlReferenceForObject:document1 fromSource:nil], is(@"docs/document.html"));
	assertThat([settings htmlReferenceForObject:document2 fromSource:nil], is(@"docs/include/document.html"));
	assertThat([settings htmlReferenceForObject:document3 fromSource:nil], is(@"docs/include/sub/document.html"));
	assertThat([settings htmlReferenceForObject:document4 fromSource:nil], is(@"docs/include/sub/document.html"));
	assertThat([settings htmlReferenceForObject:document5 fromSource:nil], is(@"docs/sub/document.html"));
	assertThat([settings htmlReferenceForObject:document6 fromSource:nil], is(@"docs/document.html"));
}

#pragma mark HTML href references handling - top level to top level

- (void)testHtmlReferenceForObjectFromSource_shouldReturnProperValueForTopLevelObjectToSameObjectReference {
	// setup
	GBApplicationSettingsProvider *settings = [GBApplicationSettingsProvider provider];
	settings.outputPath = @"anything :)";
	GBClassData *class = [GBClassData classDataWithName:@"Class"];
	GBCategoryData *category = [GBCategoryData categoryDataWithName:@"Category" className:@"Class"];
	GBProtocolData *protocol = [GBProtocolData protocolDataWithName:@"Protocol"];
	GBDocumentData *document = [GBDocumentData documentDataWithContents:@"c" path:@"document.ext"];
	// execute & verify
	assertThat([settings htmlReferenceForObject:class fromSource:class], is(@"Class.html"));
	assertThat([settings htmlReferenceForObject:category fromSource:category], is(@"Class+Category.html"));
	assertThat([settings htmlReferenceForObject:protocol fromSource:protocol], is(@"Protocol.html"));
	assertThat([settings htmlReferenceForObject:document fromSource:document], is(@"document.html"));
}

- (void)testHtmlReferenceForObjectFromSource_shouldReturnProperValueForTopLevelObjectToSameTypeTopLevelObjectReference {
	// setup
	GBApplicationSettingsProvider *settings = [GBApplicationSettingsProvider provider];
	settings.outputPath = @"anything :)";
	GBClassData *class1 = [GBClassData classDataWithName:@"Class1"];
	GBClassData *class2 = [GBClassData classDataWithName:@"Class2"];
	GBCategoryData *category1 = [GBCategoryData categoryDataWithName:@"Category1" className:@"Class"];
	GBCategoryData *category2 = [GBCategoryData categoryDataWithName:@"Category2" className:@"Class"];
	GBProtocolData *protocol1 = [GBProtocolData protocolDataWithName:@"Protocol1"];
	GBProtocolData *protocol2 = [GBProtocolData protocolDataWithName:@"Protocol2"];
	GBDocumentData *document1 = [GBDocumentData documentDataWithContents:@"c" path:@"include/document1.ext" basePath:@"include"];
	GBDocumentData *document2 = [GBDocumentData documentDataWithContents:@"c" path:@"include/document2.ext" basePath:@"include/document2.ext"];
	// execute & verify
	assertThat([settings htmlReferenceForObject:class1 fromSource:class2], is(@"../Classes/Class1.html"));
	assertThat([settings htmlReferenceForObject:class2 fromSource:class1], is(@"../Classes/Class2.html"));
	assertThat([settings htmlReferenceForObject:category1 fromSource:category2], is(@"../Categories/Class+Category1.html"));
	assertThat([settings htmlReferenceForObject:category2 fromSource:category1], is(@"../Categories/Class+Category2.html"));
	assertThat([settings htmlReferenceForObject:protocol1 fromSource:protocol2], is(@"../Protocols/Protocol1.html"));
	assertThat([settings htmlReferenceForObject:protocol2 fromSource:protocol1], is(@"../Protocols/Protocol2.html"));
	assertThat([settings htmlReferenceForObject:document1 fromSource:document2], is(@"../docs/include/document1.html"));
	assertThat([settings htmlReferenceForObject:document2 fromSource:document1], is(@"../../docs/document2.html"));
}

- (void)testHtmlReferenceForObjectFromSource_shouldReturnProperValueForTopLevelObjectToDifferentTypeOfTopLevelObjectReference {
	// setup
	GBApplicationSettingsProvider *settings = [GBApplicationSettingsProvider provider];
	settings.outputPath = @"anything :)";
	GBClassData *class = [GBClassData classDataWithName:@"Class"];
	GBCategoryData *category = [GBCategoryData categoryDataWithName:@"Category" className:@"Class"];
	GBProtocolData *protocol = [GBProtocolData protocolDataWithName:@"Protocol"];
	GBDocumentData *document1 = [GBDocumentData documentDataWithContents:@"c" path:@"include/document1.ext" basePath:@"include/document1.ext"];
	GBDocumentData *document2 = [GBDocumentData documentDataWithContents:@"c" path:@"include/document2.ext" basePath:@"include"];
	// execute & verify
	assertThat([settings htmlReferenceForObject:class fromSource:category], is(@"../Classes/Class.html"));
	assertThat([settings htmlReferenceForObject:class fromSource:protocol], is(@"../Classes/Class.html"));
	assertThat([settings htmlReferenceForObject:class fromSource:document1], is(@"../Classes/Class.html"));
	assertThat([settings htmlReferenceForObject:class fromSource:document2], is(@"../../Classes/Class.html"));
	assertThat([settings htmlReferenceForObject:category fromSource:class], is(@"../Categories/Class+Category.html"));
	assertThat([settings htmlReferenceForObject:category fromSource:protocol], is(@"../Categories/Class+Category.html"));
	assertThat([settings htmlReferenceForObject:category fromSource:document1], is(@"../Categories/Class+Category.html"));
	assertThat([settings htmlReferenceForObject:category fromSource:document2], is(@"../../Categories/Class+Category.html"));
	assertThat([settings htmlReferenceForObject:protocol fromSource:class], is(@"../Protocols/Protocol.html"));
	assertThat([settings htmlReferenceForObject:protocol fromSource:category], is(@"../Protocols/Protocol.html"));	
	assertThat([settings htmlReferenceForObject:protocol fromSource:document1], is(@"../Protocols/Protocol.html"));
	assertThat([settings htmlReferenceForObject:protocol fromSource:document2], is(@"../../Protocols/Protocol.html"));	
	assertThat([settings htmlReferenceForObject:document1 fromSource:class], is(@"../docs/document1.html"));
	assertThat([settings htmlReferenceForObject:document1 fromSource:category], is(@"../docs/document1.html"));	
	assertThat([settings htmlReferenceForObject:document1 fromSource:protocol], is(@"../docs/document1.html"));
	assertThat([settings htmlReferenceForObject:document1 fromSource:document2], is(@"../../docs/document1.html"));
	assertThat([settings htmlReferenceForObject:document2 fromSource:class], is(@"../docs/include/document2.html"));
	assertThat([settings htmlReferenceForObject:document2 fromSource:category], is(@"../docs/include/document2.html"));	
	assertThat([settings htmlReferenceForObject:document2 fromSource:protocol], is(@"../docs/include/document2.html"));
	assertThat([settings htmlReferenceForObject:document2 fromSource:document1], is(@"../docs/include/document2.html"));
}

- (void)testHtmlReferenceForObjectFromSource_shouldReturnProperValueForDocumentToTopLevelObjectReference {
	// setup
	GBApplicationSettingsProvider *settings = [GBApplicationSettingsProvider provider];
	settings.outputPath = @"anything :)";
	GBClassData *class = [GBClassData classDataWithName:@"Class"];
	GBDocumentData *document1 = [GBDocumentData documentDataWithContents:@"c" path:@"document-template.html" basePath:@""];
	GBDocumentData *document2 = [GBDocumentData documentDataWithContents:@"c" path:@"include/document-template.html" basePath:@""];
	GBDocumentData *document3 = [GBDocumentData documentDataWithContents:@"c" path:@"include/sub/document-template.html" basePath:@"include"];
	GBDocumentData *document4 = [GBDocumentData documentDataWithContents:@"c" path:@"include/sub/document-template.html" basePath:@"include/sub/document-template.html"];
	// verify
	assertThat([settings htmlReferenceForObject:class fromSource:document1], is(@"../Classes/Class.html"));
	assertThat([settings htmlReferenceForObject:class fromSource:document2], is(@"../../Classes/Class.html"));
	assertThat([settings htmlReferenceForObject:class fromSource:document3], is(@"../../../Classes/Class.html"));
	assertThat([settings htmlReferenceForObject:class fromSource:document4], is(@"../Classes/Class.html"));
}

- (void)testHtmlReferenceForObjectFromSource_shouldReturnProperValueForCustomDocumentToTopLevelObjectReference {
	// setup
	GBApplicationSettingsProvider *settings = [GBApplicationSettingsProvider provider];
	settings.outputPath = @"anything :)";
	GBClassData *class = [GBClassData classDataWithName:@"Class"];
	GBDocumentData *document1 = [GBDocumentData documentDataWithContents:@"c" path:@"path/document-template.html" basePath:@"path"];
	document1.isCustomDocument = YES;
	GBDocumentData *document2 = [GBDocumentData documentDataWithContents:@"c" path:@"path/document-template.html" basePath:@""];
	document2.isCustomDocument = YES;
	// verify
	assertThat([settings htmlReferenceForObject:class fromSource:document1], is(@"../Classes/Class.html"));
	assertThat([settings htmlReferenceForObject:class fromSource:document2], is(@"Classes/Class.html"));
}

#pragma mark HTML href references handling - top level to members

- (void)testHtmlReferenceForObjectFromSource_shouldReturnProperValueForTopLevelObjectToItsMemberReference {
	// setup
	GBApplicationSettingsProvider *settings1 = [GBApplicationSettingsProvider provider];
	GBApplicationSettingsProvider *settings2 = [GBApplicationSettingsProvider provider];
	settings1.outputPath = @"anything :)";
	settings2.outputPath = @"anything :)";
    settings2.htmlAnchorFormat = GBHTMLAnchorFormatApple;
	GBClassData *class = [GBClassData classDataWithName:@"Class"];
	GBMethodData *method = [GBTestObjectsRegistry propertyMethodWithArgument:@"value"];
	[class.methods registerMethod:method];
	// execute & verify
	assertThat([settings1 htmlReferenceForObject:method fromSource:class], is(@"#//api/name/value"));
	assertThat([settings1 htmlReferenceForObject:class fromSource:method], is(@"Class.html"));
	assertThat([settings2 htmlReferenceForObject:method fromSource:class], is(@"#//apple_ref/occ/instp/Class/value"));
	assertThat([settings2 htmlReferenceForObject:class fromSource:method], is(@"Class.html"));
}

- (void)testHtmlReferenceForObjectFromSource_shouldReturnProperValueForTopLevelObjectToSameTypeRemoteMemberReference {
	// setup
	GBApplicationSettingsProvider *settings1 = [GBApplicationSettingsProvider provider];
	GBApplicationSettingsProvider *settings2 = [GBApplicationSettingsProvider provider];
	settings1.outputPath = @"anything :)";
	settings2.outputPath = @"anything :)";
    settings2.htmlAnchorFormat = GBHTMLAnchorFormatApple;
	GBClassData *class1 = [GBClassData classDataWithName:@"Class1"];
	GBClassData *class2 = [GBClassData classDataWithName:@"Class2"];
	GBMethodData *method = [GBTestObjectsRegistry propertyMethodWithArgument:@"value"];
	[class1.methods registerMethod:method];
	// execute & verify
	assertThat([settings1 htmlReferenceForObject:method fromSource:class2], is(@"../Classes/Class1.html#//api/name/value"));
	assertThat([settings1 htmlReferenceForObject:method fromSource:class1], is(@"#//api/name/value"));
	assertThat([settings1 htmlReferenceForObject:class1 fromSource:method], is(@"Class1.html"));
	assertThat([settings1 htmlReferenceForObject:class2 fromSource:method], is(@"../Classes/Class2.html"));
	assertThat([settings2 htmlReferenceForObject:method fromSource:class2], is(@"../Classes/Class1.html#//apple_ref/occ/instp/Class1/value"));
	assertThat([settings2 htmlReferenceForObject:method fromSource:class1], is(@"#//apple_ref/occ/instp/Class1/value"));
	assertThat([settings2 htmlReferenceForObject:class1 fromSource:method], is(@"Class1.html"));
	assertThat([settings2 htmlReferenceForObject:class2 fromSource:method], is(@"../Classes/Class2.html"));
}

- (void)testHtmlReferenceForObjectFromSource_shouldReturnProperValueForTopLevelObjectToDifferentTypeRemoteMemberReference {
	// setup
	GBApplicationSettingsProvider *settings1 = [GBApplicationSettingsProvider provider];
	GBApplicationSettingsProvider *settings2 = [GBApplicationSettingsProvider provider];
	settings1.outputPath = @"anything :)";
	settings2.outputPath = @"anything :)";
    settings2.htmlAnchorFormat = GBHTMLAnchorFormatApple;
	GBClassData *class = [GBClassData classDataWithName:@"Class"];
	GBCategoryData *protocol = [GBProtocolData protocolDataWithName:@"Protocol"];
	GBMethodData *method1 = [GBTestObjectsRegistry propertyMethodWithArgument:@"value1"];
	GBMethodData *method2 = [GBTestObjectsRegistry propertyMethodWithArgument:@"value2"];
	[class.methods registerMethod:method1];
	[protocol.methods registerMethod:method2];
	// execute & verify
	assertThat([settings1 htmlReferenceForObject:method1 fromSource:protocol], is(@"../Classes/Class.html#//api/name/value1"));
	assertThat([settings1 htmlReferenceForObject:method2 fromSource:class], is(@"../Protocols/Protocol.html#//api/name/value2"));
	assertThat([settings2 htmlReferenceForObject:method1 fromSource:protocol], is(@"../Classes/Class.html#//apple_ref/occ/instp/Class/value1"));
	assertThat([settings2 htmlReferenceForObject:method2 fromSource:class], is(@"../Protocols/Protocol.html#//apple_ref/occ/intfp/Protocol/value2"));
}

#pragma mark Template files handling

- (void)testIsPathRepresentingTemplateFile_shouldReturnCorrectResults {
	// setup
	GBApplicationSettingsProvider *settings = [GBApplicationSettingsProvider provider];
	// execute & verify
	assertThatBool([settings isPathRepresentingTemplateFile:@"file"], equalToBool(NO));
	assertThatBool([settings isPathRepresentingTemplateFile:@"file.html"], equalToBool(NO));
	assertThatBool([settings isPathRepresentingTemplateFile:@"path/file.html"], equalToBool(NO));
	assertThatBool([settings isPathRepresentingTemplateFile:@"file-template"], equalToBool(YES));
	assertThatBool([settings isPathRepresentingTemplateFile:@"file-template.html"], equalToBool(YES));
	assertThatBool([settings isPathRepresentingTemplateFile:@"path/file-template"], equalToBool(YES));
	assertThatBool([settings isPathRepresentingTemplateFile:@"path/file-template.html"], equalToBool(YES));
}

- (void)testOutputFilenameForTemplatePath_shouldReturnCorrectResults {
	// setup
	GBApplicationSettingsProvider *settings = [GBApplicationSettingsProvider provider];
	// execute & verify
	assertThat([settings outputFilenameForTemplatePath:@"file"], is(@"file"));
	assertThat([settings outputFilenameForTemplatePath:@"file.html"], is(@"file.html"));
	assertThat([settings outputFilenameForTemplatePath:@"path/file.html"], is(@"file.html"));
	assertThat([settings outputFilenameForTemplatePath:@"file-template"], is(@"file"));
	assertThat([settings outputFilenameForTemplatePath:@"file-template.html"], is(@"file.html"));
	assertThat([settings outputFilenameForTemplatePath:@"path/file-template"], is(@"file"));
	assertThat([settings outputFilenameForTemplatePath:@"path/file-template.html"], is(@"file.html"));
}

- (void)testTemplateFilenameForOutputPath_shuoldReturnCorrectResults {
	// setup
	GBApplicationSettingsProvider *settings = [GBApplicationSettingsProvider provider];
	// execute & verify
	assertThat([settings templateFilenameForOutputPath:@"file"], is(@"file-template"));
	assertThat([settings templateFilenameForOutputPath:@"file.html"], is(@"file-template.html"));
	assertThat([settings templateFilenameForOutputPath:@"path/file.html"], is(@"path/file-template.html"));
	assertThat([settings templateFilenameForOutputPath:@"path/file-template"], is(@"path/file-template"));
	assertThat([settings templateFilenameForOutputPath:@"path/file-template.html"], is(@"path/file-template.html"));
}

#pragma mark Text conversion methods

- (void)testStringByEmbeddingCrossReference_shouldEmbeddCrossReferenceIfRequired {
	// setup
	GBApplicationSettingsProvider *settings1 = [GBApplicationSettingsProvider provider];
	GBApplicationSettingsProvider *settings2 = [GBApplicationSettingsProvider provider];
	settings2.embedCrossReferencesWhenProcessingMarkdown = NO;
	// execute
	NSString *result11 = [settings1 stringByEmbeddingCrossReference:@"[description](address \"title\")"];
	NSString *result12 = [settings1 stringByEmbeddingCrossReference:@"[`description`](address \"title\")"];
	NSString *result21 = [settings2 stringByEmbeddingCrossReference:@"[description](address \"title\")"];
	NSString *result22 = [settings2 stringByEmbeddingCrossReference:@"[`description`](address \"title\")"];
	// verify
	assertThat(result11, is(@"~!@[description](address \"title\")@!~"));
	assertThat(result12, is(@"~!@[`description`](address \"title\")@!~"));
	assertThat(result21, is(@"[description](address \"title\")"));
	assertThat(result22, is(@"[`description`](address \"title\")"));
}

#pragma mark Markdown to HTML conversion

- (void)testStringByConvertingMarkdownToHTML_shouldConvertEmbeddedCrossReferencesInText {
	// setup
	GBApplicationSettingsProvider *settings = [GBApplicationSettingsProvider provider];
	// execute
	NSString *result1 = [settings stringByConvertingMarkdownToHTML:@"~!@[description](address)@!~"];
	NSString *result2 = [settings stringByConvertingMarkdownToHTML:@"[description](address)"];
	// verify - Discount converts any kind of link, we just need to strip embedded prefix and suffix!
	assertThat(result1, is(@"<p><a href=\"address\">description</a></p>"));
	assertThat(result2, is(@"<p><a href=\"address\">description</a></p>"));
}

- (void)testStringByConvertingMarkdownToHTML_shouldAllowUsageOfUTF8CharacterSet {
	// setup
	GBApplicationSettingsProvider *settings = [GBApplicationSettingsProvider provider];
	// execute
	NSString *result1 = [settings stringByConvertingMarkdownToHTML:@"对"];
	// verify
	assertThat(result1, is(@"<p>对</p>"));
}

- (void)testStringByConvertingMarkdownToHTML_shouldConvertEmbeddedCrossReferencesInExampleBlock {
	// setup
	GBApplicationSettingsProvider *settings = [GBApplicationSettingsProvider provider];
	// execute
	NSString *result1 = [settings stringByConvertingMarkdownToHTML:@"\t~!@[description](address)@!~"];
	NSString *result2 = [settings stringByConvertingMarkdownToHTML:@"\t[description](address)"];
	// verify - Discount doesn't process links here, but we need to return auto generated to deafult! Note that Discount adds new line!
	assertThat(result1, is(@"<pre><code>description\n</code></pre>"));
	assertThat(result2, is(@"<pre><code>[description](address)\n</code></pre>"));
}

- (void)testStringByConvertingMarkdownToHTML_shouldConvertAppledocStyleBoldMarkersInText {
	// setup
	GBApplicationSettingsProvider *settings = [GBApplicationSettingsProvider provider];
	// execute
	NSString *result = [settings stringByConvertingMarkdownToHTML:@"**~!$text$!~**"];
	// verify - Discount converts ** part, we just need to cleanup the remaining texts!
	assertThat(result, is(@"<p><strong>text</strong></p>"));
}

- (void)testStringByConvertingMarkdownToHTML_shouldConvertAppledocStyleBoldMarkersInExampleBlock {
	// setup
	GBApplicationSettingsProvider *settings = [GBApplicationSettingsProvider provider];
	// execute
	NSString *result1 = [settings stringByConvertingMarkdownToHTML:@"\t**~!$text$!~**"];
	NSString *result2 = [settings stringByConvertingMarkdownToHTML:@"\t**text**"];
	// verify - Discount doesn't process text here, so we should revert to original markup!
	assertThat(result1, is(@"<pre><code>*text*\n</code></pre>"));
	assertThat(result2, is(@"<pre><code>**text**\n</code></pre>"));
}

#pragma mark Markdown to text conversion

- (void)testStringByConvertingMarkdownToText_shouldConvertEmbeddedCrossReferencesInText {
	// setup
	GBApplicationSettingsProvider *settings = [GBApplicationSettingsProvider provider];
	// execute
	NSString *result1 = [settings stringByConvertingMarkdownToText:@"~!@[description](address)@!~"];
	NSString *result2 = [settings stringByConvertingMarkdownToText:@"[description](address)"];
	NSString *result3 = [settings stringByConvertingMarkdownToText:@"\t~!@[[class method]](address)@!~"];
	NSString *result4 = [settings stringByConvertingMarkdownToText:@"\t[[class method]](address)"];
	// verify - Discount converts any kind of link, we just need to strip embedded prefix and suffix!
	assertThat(result1, is(@"description"));
	assertThat(result2, is(@"description"));
	assertThat(result3, is(@"\t[class method]"));
	assertThat(result4, is(@"\t[class method]"));
}

- (void)testStringByConvertingMarkdownToText_shouldConvertEmbeddedCrossReferencesInExampleBlock {
	// setup
	GBApplicationSettingsProvider *settings = [GBApplicationSettingsProvider provider];
	// execute
	NSString *result1 = [settings stringByConvertingMarkdownToText:@"\t~!@[description](address)@!~"];
	NSString *result2 = [settings stringByConvertingMarkdownToText:@"\t[description](address)"];
	NSString *result3 = [settings stringByConvertingMarkdownToText:@"\t~!@[[class method]](address)@!~"];
	NSString *result4 = [settings stringByConvertingMarkdownToText:@"\t[[class method]](address)"];
	// verify - Discount doesn't process links here, but we need to return auto generated to deafult! Note that Discount adds new line!
	assertThat(result1, is(@"\tdescription"));
	assertThat(result2, is(@"\tdescription"));
	assertThat(result3, is(@"\t[class method]"));
	assertThat(result4, is(@"\t[class method]"));
}

- (void)testStringByConvertingMarkdownToText_shouldConvertEmbeddedAppledocBoldMarkersInText {
	// setup
	GBApplicationSettingsProvider *settings = [GBApplicationSettingsProvider provider];
	// execute
	NSString *result1 = [settings stringByConvertingMarkdownToText:@"~!$text$!~"];
	NSString *result2 = [settings stringByConvertingMarkdownToText:@"**~!$text$!~**"];
	// verify
	assertThat(result1, is(@"text"));
	assertThat(result2, is(@"text"));
}

- (void)testStringByConvertingMarkdownToText_shouldConvertEmbeddedAppledocBoldMarkersInExampleBlock {
	// setup
	GBApplicationSettingsProvider *settings = [GBApplicationSettingsProvider provider];
	// execute
	NSString *result1 = [settings stringByConvertingMarkdownToText:@"\t~!$text$!~"];
	NSString *result2 = [settings stringByConvertingMarkdownToText:@"\t**~!$text$!~**"];
	// verify
	assertThat(result1, is(@"\ttext"));
	assertThat(result2, is(@"\ttext"));
}

- (void)testStringByConvertingMarkdownToText_shouldConvertMarkdownReferences {
	// setup
	GBApplicationSettingsProvider *settings = [GBApplicationSettingsProvider provider];
	// execute
	NSString *result1 = [settings stringByConvertingMarkdownToText:@"simple text"];
	NSString *result2 = [settings stringByConvertingMarkdownToText:@"[description](address)"];
	NSString *result3 = [settings stringByConvertingMarkdownToText:@"[description](address \"title\")"];
	NSString *result4 = [settings stringByConvertingMarkdownToText:@"prefix [description](address) suffix"];
	NSString *result5 = [settings stringByConvertingMarkdownToText:@"[description1](address) [description2](address) [description3](address)"];
	// verify
	assertThat(result1, is(@"simple text"));
	assertThat(result2, is(@"description"));
	assertThat(result3, is(@"description"));
	assertThat(result4, is(@"prefix description suffix"));
	assertThat(result5, is(@"description1 description2 description3"));
}
						  
- (void)testStringByConvertingMarkdownToText_shouldConvertFormattingMarkers {
	// setup
	GBApplicationSettingsProvider *settings = [GBApplicationSettingsProvider provider];
	// execute
	NSString *result1 = [settings stringByConvertingMarkdownToText:@"*desc*"];
	NSString *result2 = [settings stringByConvertingMarkdownToText:@"`desc`"];
	NSString *result3 = [settings stringByConvertingMarkdownToText:@"prefix *desc* suffix"];
	NSString *result4 = [settings stringByConvertingMarkdownToText:@"*1* **2** ***3*** _4_ __5__ ___6___"];
	NSString *result5 = [settings stringByConvertingMarkdownToText:@"_*1*_ *_2_* **_3_** _**4**_ *__5__* __*6*__"];
	// verify
	assertThat(result1, is(@"desc"));
	assertThat(result2, is(@"desc"));
	assertThat(result3, is(@"prefix desc suffix"));
	assertThat(result4, is(@"1 2 3 4 5 6"));
	assertThat(result5, is(@"1 2 3 4 5 6"));
}

- (void)testStringByConvertingMarkdownToText_shouldConvertManualAnchors {
	// setup
	GBApplicationSettingsProvider *settings = [GBApplicationSettingsProvider provider];
	// execute
	NSString *result1 = [settings stringByConvertingMarkdownToText:@"<a href=\"address\">desc</a>"];
	NSString *result2 = [settings stringByConvertingMarkdownToText:@"<a href='address'>desc</a>"];
	NSString *result3 = [settings stringByConvertingMarkdownToText:@"<a href=\"address\"></a>"];
	NSString *result4 = [settings stringByConvertingMarkdownToText:@"<a href='address'></a>"];
	NSString *result5 = [settings stringByConvertingMarkdownToText:@"<a href=\"address\" />"];
	NSString *result6 = [settings stringByConvertingMarkdownToText:@"<a href='address' />"];
	NSString *result7 = [settings stringByConvertingMarkdownToText:@"<a\n\n\thref\n=\n\t   'address'\n>desc</a>"];
	NSString *result8 = [settings stringByConvertingMarkdownToText:@"<a\n\n\thref\n=\n\t   'address'\n/>"];
	// verify
	assertThat(result1, is(@"desc"));
	assertThat(result2, is(@"desc"));
	assertThat(result3, is(@"address"));
	assertThat(result4, is(@"address"));
	assertThat(result5, is(@"address"));
	assertThat(result6, is(@"address"));
	assertThat(result7, is(@"desc"));
	assertThat(result8, is(@"address"));
}

#pragma mark Private accessor helpers

- (NSDateFormatter *)yearFormatterFromSettings:(GBApplicationSettingsProvider *)settings {
	return [settings valueForKey:@"yearDateFormatter"];
}

- (NSDateFormatter *)yearToDayFormatterFromSettings:(GBApplicationSettingsProvider *)settings {
	return [settings valueForKey:@"yearToDayDateFormatter"];
}

@end
