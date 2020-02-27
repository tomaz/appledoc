//
//  GBApplicationSettingsProviderTesting.m
//  appledocTests
//
//  Created by Jebeom Gyeong on 2/22/20.
//  Copyright © 2020 Gentle Bytes. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "GBDataObjects.h"
#import "GBApplicationSettingsProvider.h"
#import "GBTestObjectsRegistry.h"

@interface GBApplicationSettingsProviderTesting : XCTestCase

@end

@implementation GBApplicationSettingsProviderTesting

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

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
    XCTAssertEqualObjects(settings.docsetBundleIdentifier, expected);
    XCTAssertEqualObjects(settings.docsetBundleName, expected);
    XCTAssertEqualObjects(settings.docsetCertificateIssuer, expected);
    XCTAssertEqualObjects(settings.docsetCertificateSigner, expected);
    XCTAssertEqualObjects(settings.docsetDescription, expected);
    XCTAssertEqualObjects(settings.docsetFallbackURL, expected);
    XCTAssertEqualObjects(settings.docsetFeedName, expected);
    XCTAssertEqualObjects(settings.docsetFeedURL, expected);
    XCTAssertEqualObjects(settings.docsetPackageURL, expected);
    XCTAssertEqualObjects(settings.docsetMinimumXcodeVersion, expected);
    XCTAssertEqualObjects(settings.docsetPlatformFamily, expected);
    XCTAssertEqualObjects(settings.docsetPublisherIdentifier, expected);
    XCTAssertEqualObjects(settings.docsetPublisherName, expected);
    XCTAssertEqualObjects(settings.docsetCopyrightMessage, expected);
    XCTAssertEqualObjects(settings.docsetBundleFilename, expected);
    XCTAssertEqualObjects(settings.docsetAtomFilename, expected);
    XCTAssertEqualObjects(settings.docsetXMLFilename, expected);
    XCTAssertEqualObjects(settings.docsetPackageFilename, expected);
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
    XCTAssertEqualObjects(settings.docsetBundleIdentifier, expected);
    XCTAssertEqualObjects(settings.docsetBundleName, expected);
    XCTAssertEqualObjects(settings.docsetCertificateIssuer, expected);
    XCTAssertEqualObjects(settings.docsetCertificateSigner, expected);
    XCTAssertEqualObjects(settings.docsetDescription, expected);
    XCTAssertEqualObjects(settings.docsetFallbackURL, expected);
    XCTAssertEqualObjects(settings.docsetFeedName, expected);
    XCTAssertEqualObjects(settings.docsetFeedURL, expected);
    XCTAssertEqualObjects(settings.docsetPackageURL, expected);
    XCTAssertEqualObjects(settings.docsetMinimumXcodeVersion, expected);
    XCTAssertEqualObjects(settings.docsetPlatformFamily, expected);
    XCTAssertEqualObjects(settings.docsetPublisherIdentifier, expected);
    XCTAssertEqualObjects(settings.docsetPublisherName, expected);
    XCTAssertEqualObjects(settings.docsetCopyrightMessage, expected);
}

- (void)testProjectIdentifier_shouldNormalizeProjectName {
    // setup
    GBApplicationSettingsProvider *settings = [GBApplicationSettingsProvider provider];
    settings.projectName = @"My Great  \t Project";
    // execute & verify
    XCTAssertEqualObjects(settings.projectIdentifier, @"My-Great-Project");
}

- (void)testVersionIdentifier_shouldNormalizeProjectVersion {
    // setup
    GBApplicationSettingsProvider *settings = [GBApplicationSettingsProvider provider];
    settings.projectVersion = @"1.0 beta3  \t something";
    // execute & verify
    XCTAssertEqualObjects(settings.versionIdentifier, @"1.0-beta3-something");
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
    XCTAssertEqualObjects([settings htmlReferenceNameForObject:class], @"Class.html");
    XCTAssertEqualObjects([settings htmlReferenceNameForObject:category], @"Class+Category.html");
    XCTAssertEqualObjects([settings htmlReferenceNameForObject:extension], @"Class+.html");
    XCTAssertEqualObjects([settings htmlReferenceNameForObject:protocol], @"Protocol.html");
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
    XCTAssertEqualObjects([settings htmlReferenceNameForObject:document1], @"document.html");
    XCTAssertEqualObjects([settings htmlReferenceNameForObject:document2], @"document.html");
    XCTAssertEqualObjects([settings htmlReferenceNameForObject:document3], @"document.html");
    XCTAssertEqualObjects([settings htmlReferenceNameForObject:document4], @"document.html");
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
    XCTAssertEqualObjects([settings1 htmlReferenceNameForObject:method1], @"//api/name/method");
    XCTAssertEqualObjects([settings1 htmlReferenceNameForObject:method2], @"//api/name/doSomething:withVars:");
    XCTAssertEqualObjects([settings1 htmlReferenceNameForObject:property], @"//api/name/value");
    XCTAssertEqualObjects([settings2 htmlReferenceNameForObject:method1], @"//apple_ref/occ/instm/Class/method");
    XCTAssertEqualObjects([settings2 htmlReferenceNameForObject:method2], @"//apple_ref/occ/instm/Class/doSomething:withVars:");
    XCTAssertEqualObjects([settings2 htmlReferenceNameForObject:property], @"//apple_ref/occ/instp/Class/value");
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
    XCTAssertEqualObjects([settings1 htmlReferenceForObject:class fromSource:nil], @"Classes/Class.html");
    XCTAssertEqualObjects([settings1 htmlReferenceForObject:method fromSource:nil], @"Classes/Class.html#//api/name/method:");
    XCTAssertEqualObjects([settings2 htmlReferenceForObject:class fromSource:nil], @"Classes/Class.html");
    XCTAssertEqualObjects([settings2 htmlReferenceForObject:method fromSource:nil], @"Classes/Class.html#//apple_ref/occ/instm/Class/method:");
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
    XCTAssertEqualObjects([settings1 htmlReferenceForObject:category fromSource:nil], @"Categories/Class+Category.html");
    XCTAssertEqualObjects([settings1 htmlReferenceForObject:method fromSource:nil], @"Categories/Class+Category.html#//api/name/method:");
    XCTAssertEqualObjects([settings2 htmlReferenceForObject:category fromSource:nil], @"Categories/Class+Category.html");
    XCTAssertEqualObjects([settings2 htmlReferenceForObject:method fromSource:nil], @"Categories/Class+Category.html#//apple_ref/occ/instm/Class(Category)/method:");
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
    XCTAssertEqualObjects([settings1 htmlReferenceForObject:protocol fromSource:nil], @"Protocols/Protocol.html");
    XCTAssertEqualObjects([settings1 htmlReferenceForObject:method fromSource:nil], @"Protocols/Protocol.html#//api/name/method:");
    XCTAssertEqualObjects([settings2 htmlReferenceForObject:protocol fromSource:nil], @"Protocols/Protocol.html");
    XCTAssertEqualObjects([settings2 htmlReferenceForObject:method fromSource:nil], @"Protocols/Protocol.html#//apple_ref/occ/intfm/Protocol/method:");
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
    XCTAssertEqualObjects([settings htmlReferenceForObject:document1 fromSource:nil], @"docs/document.html");
    XCTAssertEqualObjects([settings htmlReferenceForObject:document2 fromSource:nil], @"docs/include/document.html");
    XCTAssertEqualObjects([settings htmlReferenceForObject:document3 fromSource:nil], @"docs/include/sub/document.html");
    XCTAssertEqualObjects([settings htmlReferenceForObject:document4 fromSource:nil], @"docs/include/sub/document.html");
    XCTAssertEqualObjects([settings htmlReferenceForObject:document5 fromSource:nil], @"docs/sub/document.html");
    XCTAssertEqualObjects([settings htmlReferenceForObject:document6 fromSource:nil], @"docs/document.html");
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
    XCTAssertEqualObjects([settings htmlReferenceForObject:class fromSource:class], @"Class.html");
    XCTAssertEqualObjects([settings htmlReferenceForObject:category fromSource:category], @"Class+Category.html");
    XCTAssertEqualObjects([settings htmlReferenceForObject:protocol fromSource:protocol], @"Protocol.html");
    XCTAssertEqualObjects([settings htmlReferenceForObject:document fromSource:document], @"document.html");
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
    XCTAssertEqualObjects([settings htmlReferenceForObject:class1 fromSource:class2], @"../Classes/Class1.html");
    XCTAssertEqualObjects([settings htmlReferenceForObject:class2 fromSource:class1], @"../Classes/Class2.html");
    XCTAssertEqualObjects([settings htmlReferenceForObject:category1 fromSource:category2], @"../Categories/Class+Category1.html");
    XCTAssertEqualObjects([settings htmlReferenceForObject:category2 fromSource:category1], @"../Categories/Class+Category2.html");
    XCTAssertEqualObjects([settings htmlReferenceForObject:protocol1 fromSource:protocol2], @"../Protocols/Protocol1.html");
    XCTAssertEqualObjects([settings htmlReferenceForObject:protocol2 fromSource:protocol1], @"../Protocols/Protocol2.html");
    XCTAssertEqualObjects([settings htmlReferenceForObject:document1 fromSource:document2], @"../docs/include/document1.html");
    XCTAssertEqualObjects([settings htmlReferenceForObject:document2 fromSource:document1], @"../../docs/document2.html");
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
    XCTAssertEqualObjects([settings htmlReferenceForObject:class fromSource:category], @"../Classes/Class.html");
    XCTAssertEqualObjects([settings htmlReferenceForObject:class fromSource:protocol], @"../Classes/Class.html");
    XCTAssertEqualObjects([settings htmlReferenceForObject:class fromSource:document1], @"../Classes/Class.html");
    XCTAssertEqualObjects([settings htmlReferenceForObject:class fromSource:document2], @"../../Classes/Class.html");
    XCTAssertEqualObjects([settings htmlReferenceForObject:category fromSource:class], @"../Categories/Class+Category.html");
    XCTAssertEqualObjects([settings htmlReferenceForObject:category fromSource:protocol], @"../Categories/Class+Category.html");
    XCTAssertEqualObjects([settings htmlReferenceForObject:category fromSource:document1], @"../Categories/Class+Category.html");
    XCTAssertEqualObjects([settings htmlReferenceForObject:category fromSource:document2], @"../../Categories/Class+Category.html");
    XCTAssertEqualObjects([settings htmlReferenceForObject:protocol fromSource:class], @"../Protocols/Protocol.html");
    XCTAssertEqualObjects([settings htmlReferenceForObject:protocol fromSource:category], @"../Protocols/Protocol.html");
    XCTAssertEqualObjects([settings htmlReferenceForObject:protocol fromSource:document1], @"../Protocols/Protocol.html");
    XCTAssertEqualObjects([settings htmlReferenceForObject:protocol fromSource:document2], @"../../Protocols/Protocol.html");
    XCTAssertEqualObjects([settings htmlReferenceForObject:document1 fromSource:class], @"../docs/document1.html");
    XCTAssertEqualObjects([settings htmlReferenceForObject:document1 fromSource:category], @"../docs/document1.html");
    XCTAssertEqualObjects([settings htmlReferenceForObject:document1 fromSource:protocol], @"../docs/document1.html");
    XCTAssertEqualObjects([settings htmlReferenceForObject:document1 fromSource:document2], @"../../docs/document1.html");
    XCTAssertEqualObjects([settings htmlReferenceForObject:document2 fromSource:class], @"../docs/include/document2.html");
    XCTAssertEqualObjects([settings htmlReferenceForObject:document2 fromSource:category], @"../docs/include/document2.html");
    XCTAssertEqualObjects([settings htmlReferenceForObject:document2 fromSource:protocol], @"../docs/include/document2.html");
    XCTAssertEqualObjects([settings htmlReferenceForObject:document2 fromSource:document1], @"../docs/include/document2.html");
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
    XCTAssertEqualObjects([settings htmlReferenceForObject:class fromSource:document1], @"../Classes/Class.html");
    XCTAssertEqualObjects([settings htmlReferenceForObject:class fromSource:document2], @"../../Classes/Class.html");
    XCTAssertEqualObjects([settings htmlReferenceForObject:class fromSource:document3], @"../../../Classes/Class.html");
    XCTAssertEqualObjects([settings htmlReferenceForObject:class fromSource:document4], @"../Classes/Class.html");
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
    XCTAssertEqualObjects([settings htmlReferenceForObject:class fromSource:document1], @"../Classes/Class.html");
    XCTAssertEqualObjects([settings htmlReferenceForObject:class fromSource:document2], @"Classes/Class.html");
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
    XCTAssertEqualObjects([settings1 htmlReferenceForObject:method fromSource:class], @"#//api/name/value");
    XCTAssertEqualObjects([settings1 htmlReferenceForObject:class fromSource:method], @"Class.html");
    XCTAssertEqualObjects([settings2 htmlReferenceForObject:method fromSource:class], @"#//apple_ref/occ/instp/Class/value");
    XCTAssertEqualObjects([settings2 htmlReferenceForObject:class fromSource:method], @"Class.html");
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
    XCTAssertEqualObjects([settings1 htmlReferenceForObject:method fromSource:class2], @"../Classes/Class1.html#//api/name/value");
    XCTAssertEqualObjects([settings1 htmlReferenceForObject:method fromSource:class1], @"#//api/name/value");
    XCTAssertEqualObjects([settings1 htmlReferenceForObject:class1 fromSource:method], @"Class1.html");
    XCTAssertEqualObjects([settings1 htmlReferenceForObject:class2 fromSource:method], @"../Classes/Class2.html");
    XCTAssertEqualObjects([settings2 htmlReferenceForObject:method fromSource:class2], @"../Classes/Class1.html#//apple_ref/occ/instp/Class1/value");
    XCTAssertEqualObjects([settings2 htmlReferenceForObject:method fromSource:class1], @"#//apple_ref/occ/instp/Class1/value");
    XCTAssertEqualObjects([settings2 htmlReferenceForObject:class1 fromSource:method], @"Class1.html");
    XCTAssertEqualObjects([settings2 htmlReferenceForObject:class2 fromSource:method], @"../Classes/Class2.html");
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
    XCTAssertEqualObjects([settings1 htmlReferenceForObject:method1 fromSource:protocol], @"../Classes/Class.html#//api/name/value1");
    XCTAssertEqualObjects([settings1 htmlReferenceForObject:method2 fromSource:class], @"../Protocols/Protocol.html#//api/name/value2");
    XCTAssertEqualObjects([settings2 htmlReferenceForObject:method1 fromSource:protocol], @"../Classes/Class.html#//apple_ref/occ/instp/Class/value1");
    XCTAssertEqualObjects([settings2 htmlReferenceForObject:method2 fromSource:class], @"../Protocols/Protocol.html#//apple_ref/occ/intfp/Protocol/value2");
}

#pragma mark Template files handling

- (void)testIsPathRepresentingTemplateFile_shouldReturnCorrectResults {
    // setup
    GBApplicationSettingsProvider *settings = [GBApplicationSettingsProvider provider];
    // execute & verify
    XCTAssertFalse([settings isPathRepresentingTemplateFile:@"file"]);
    XCTAssertFalse([settings isPathRepresentingTemplateFile:@"file.html"]);
    XCTAssertFalse([settings isPathRepresentingTemplateFile:@"path/file.html"]);
    XCTAssertTrue([settings isPathRepresentingTemplateFile:@"file-template"]);
    XCTAssertTrue([settings isPathRepresentingTemplateFile:@"file-template.html"]);
    XCTAssertTrue([settings isPathRepresentingTemplateFile:@"path/file-template"]);
    XCTAssertTrue([settings isPathRepresentingTemplateFile:@"path/file-template.html"]);
}

- (void)testOutputFilenameForTemplatePath_shouldReturnCorrectResults {
    // setup
    GBApplicationSettingsProvider *settings = [GBApplicationSettingsProvider provider];
    // execute & verify
    XCTAssertEqualObjects([settings outputFilenameForTemplatePath:@"file"], @"file");
    XCTAssertEqualObjects([settings outputFilenameForTemplatePath:@"file.html"], @"file.html");
    XCTAssertEqualObjects([settings outputFilenameForTemplatePath:@"path/file.html"], @"file.html");
    XCTAssertEqualObjects([settings outputFilenameForTemplatePath:@"file-template"], @"file");
    XCTAssertEqualObjects([settings outputFilenameForTemplatePath:@"file-template.html"], @"file.html");
    XCTAssertEqualObjects([settings outputFilenameForTemplatePath:@"path/file-template"], @"file");
    XCTAssertEqualObjects([settings outputFilenameForTemplatePath:@"path/file-template.html"], @"file.html");
}

- (void)testTemplateFilenameForOutputPath_shuoldReturnCorrectResults {
    // setup
    GBApplicationSettingsProvider *settings = [GBApplicationSettingsProvider provider];
    // execute & verify
    XCTAssertEqualObjects([settings templateFilenameForOutputPath:@"file"], @"file-template");
    XCTAssertEqualObjects([settings templateFilenameForOutputPath:@"file.html"], @"file-template.html");
    XCTAssertEqualObjects([settings templateFilenameForOutputPath:@"path/file.html"], @"path/file-template.html");
    XCTAssertEqualObjects([settings templateFilenameForOutputPath:@"path/file-template"], @"path/file-template");
    XCTAssertEqualObjects([settings templateFilenameForOutputPath:@"path/file-template.html"], @"path/file-template.html");
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
    NSString *result13 = [settings1 stringByEmbeddingCrossReference:@"![Some Stuff](https://foo.bar/blarg/flip%2flop.xyz)]"];

    NSString *result21 = [settings2 stringByEmbeddingCrossReference:@"[description](address \"title\")"];
    NSString *result22 = [settings2 stringByEmbeddingCrossReference:@"[`description`](address \"title\")"];
    NSString *result23 = [settings2 stringByEmbeddingCrossReference:@"![Some Stuff](https://foo.bar/blarg/flip%2flop.xyz)]"];

    // verify
    XCTAssertEqualObjects(result11, @"~!@[description](address \"title\")@!~");
    XCTAssertEqualObjects(result12, @"~!@[`description`](address \"title\")@!~");
    XCTAssertEqualObjects(result13, @"~!@![Some Stuff](https://foo.bar/blarg/flip%2flop.xyz)]@!~");

    XCTAssertEqualObjects(result21, @"[description](address \"title\")");
    XCTAssertEqualObjects(result22, @"[`description`](address \"title\")");
    XCTAssertEqualObjects(result23, @"![Some Stuff](https://foo.bar/blarg/flip%2flop.xyz)]");
}

#pragma mark Markdown to HTML conversion

- (void)testStringByConvertingMarkdownToHTML_shouldConvertEmbeddedCrossReferencesInText {
    // setup
    GBApplicationSettingsProvider *settings = [GBApplicationSettingsProvider provider];
    // execute
    NSString *result1 = [settings stringByConvertingMarkdownToHTML:@"~!@[description](address)@!~"];
    NSString *result2 = [settings stringByConvertingMarkdownToHTML:@"[description](address)"];
    NSString *result3 = [settings stringByConvertingMarkdownToHTML:@"![alt text](https://xyz/foo.bar)]"];
    NSString *result4 = [settings stringByConvertingMarkdownToHTML:@"[![alt text](https://xyz/foo.bar)](https://xyz/foo.blarg)"];
    // verify - Discount converts any kind of link, we just need to strip embedded prefix and suffix!
    XCTAssertEqualObjects(result1, @"<p><a href=\"address\">description</a></p>");
    XCTAssertEqualObjects(result2, @"<p><a href=\"address\">description</a></p>");
    XCTAssertEqualObjects(result3, @"<p><img src=\"https://xyz/foo.bar\" alt=\"alt text\" />]</p>");
    XCTAssertEqualObjects(result4, @"<p><a href=\"https://xyz/foo.blarg\"><img src=\"https://xyz/foo.bar\" alt=\"alt text\" /></a></p>");
}

- (void)testStringByConvertingMarkdownToHTML_shouldAllowUsageOfUTF8CharacterSet {
    // setup
    GBApplicationSettingsProvider *settings = [GBApplicationSettingsProvider provider];
    // execute
    NSString *result1 = [settings stringByConvertingMarkdownToHTML:@"对"];
    // verify
    XCTAssertEqualObjects(result1, @"<p>对</p>");
}

- (void)testStringByConvertingMarkdownToHTML_shouldConvertEmbeddedCrossReferencesInExampleBlock {
    // setup
    GBApplicationSettingsProvider *settings = [GBApplicationSettingsProvider provider];
    // execute
    NSString *result1 = [settings stringByConvertingMarkdownToHTML:@"\t~!@[description](address)@!~"];
    NSString *result2 = [settings stringByConvertingMarkdownToHTML:@"\t[description](address)"];
    // verify - Discount doesn't process links here, but we need to return auto generated to deafult! Note that Discount adds new line!
    XCTAssertEqualObjects(result1, @"<pre><code>description\n</code></pre>");
    XCTAssertEqualObjects(result2, @"<pre><code>[description](address)\n</code></pre>");
}

- (void)testStringByConvertingMarkdownToHTML_shouldConvertAppledocStyleBoldMarkersInText {
    // setup
    GBApplicationSettingsProvider *settings = [GBApplicationSettingsProvider provider];
    // execute
    NSString *result = [settings stringByConvertingMarkdownToHTML:@"**~!$text$!~**"];
    // verify - Discount converts ** part, we just need to cleanup the remaining texts!
    XCTAssertEqualObjects(result, @"<p><strong>text</strong></p>");
}

- (void)testStringByConvertingMarkdownToHTML_shouldConvertAppledocStyleBoldMarkersInExampleBlock {
    // setup
    GBApplicationSettingsProvider *settings = [GBApplicationSettingsProvider provider];
    // execute
    NSString *result1 = [settings stringByConvertingMarkdownToHTML:@"\t**~!$text$!~**"];
    NSString *result2 = [settings stringByConvertingMarkdownToHTML:@"\t**text**"];
    // verify - Discount doesn't process text here, so we should revert to original markup!
    XCTAssertEqualObjects(result1, @"<pre><code>*text*\n</code></pre>");
    XCTAssertEqualObjects(result2, @"<pre><code>**text**\n</code></pre>");
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
    XCTAssertEqualObjects(result1, @"description");
    XCTAssertEqualObjects(result2, @"description");
    XCTAssertEqualObjects(result3, @"\t[class method]");
    XCTAssertEqualObjects(result4, @"\t[class method]");
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
    XCTAssertEqualObjects(result1, @"\tdescription");
    XCTAssertEqualObjects(result2, @"\tdescription");
    XCTAssertEqualObjects(result3, @"\t[class method]");
    XCTAssertEqualObjects(result4, @"\t[class method]");
}

- (void)testStringByConvertingMarkdownToText_shouldConvertEmbeddedAppledocBoldMarkersInText {
    // setup
    GBApplicationSettingsProvider *settings = [GBApplicationSettingsProvider provider];
    // execute
    NSString *result1 = [settings stringByConvertingMarkdownToText:@"~!$text$!~"];
    NSString *result2 = [settings stringByConvertingMarkdownToText:@"**~!$text$!~**"];
    // verify
    XCTAssertEqualObjects(result1, @"text");
    XCTAssertEqualObjects(result2, @"text");
}

- (void)testStringByConvertingMarkdownToText_shouldConvertEmbeddedAppledocBoldMarkersInExampleBlock {
    // setup
    GBApplicationSettingsProvider *settings = [GBApplicationSettingsProvider provider];
    // execute
    NSString *result1 = [settings stringByConvertingMarkdownToText:@"\t~!$text$!~"];
    NSString *result2 = [settings stringByConvertingMarkdownToText:@"\t**~!$text$!~**"];
    // verify
    XCTAssertEqualObjects(result1, @"\ttext");
    XCTAssertEqualObjects(result2, @"\ttext");
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
    XCTAssertEqualObjects(result1, @"simple text");
    XCTAssertEqualObjects(result2, @"description");
    XCTAssertEqualObjects(result3, @"description");
    XCTAssertEqualObjects(result4, @"prefix description suffix");
    XCTAssertEqualObjects(result5, @"description1 description2 description3");
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
    XCTAssertEqualObjects(result1, @"desc");
    XCTAssertEqualObjects(result2, @"desc");
    XCTAssertEqualObjects(result3, @"prefix desc suffix");
    XCTAssertEqualObjects(result4, @"1 2 3 4 5 6");
    XCTAssertEqualObjects(result5, @"1 2 3 4 5 6");
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
    XCTAssertEqualObjects(result1, @"desc");
    XCTAssertEqualObjects(result2, @"desc");
    XCTAssertEqualObjects(result3, @"address");
    XCTAssertEqualObjects(result4, @"address");
    XCTAssertEqualObjects(result5, @"address");
    XCTAssertEqualObjects(result6, @"address");
    XCTAssertEqualObjects(result7, @"desc");
    XCTAssertEqualObjects(result8, @"address");
}

#pragma mark Private accessor helpers

- (NSDateFormatter *)yearFormatterFromSettings:(GBApplicationSettingsProvider *)settings {
    return [settings valueForKey:@"yearDateFormatter"];
}

- (NSDateFormatter *)yearToDayFormatterFromSettings:(GBApplicationSettingsProvider *)settings {
    return [settings valueForKey:@"yearToDayDateFormatter"];
}

@end
