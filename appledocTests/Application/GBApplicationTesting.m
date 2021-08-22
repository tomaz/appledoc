//
//  GBApplicationTesting.m
//  appledocTests
//
//  Created by Jebeom Gyeong on 2/21/20.
//  Copyright © 2020 Gentle Bytes. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "DDCliApplication.h"
#import "DDGetoptLongParser.h"
#import "GBApplicationSettingsProvider.h"
#import "GBAppledocApplication.h"

@interface GBApplicationTesting : XCTestCase

@end

@implementation GBApplicationTesting

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

#pragma mark Helper methods testing

- (void)testStandardizeCurrentDirectoryForPath_shouldConvertDotToCurrentDir {
    // setup
    GBAppledocApplication *app = [[GBAppledocApplication alloc] init];
    XCTAssertNotNil(app);
    //execute & verify
    XCTAssertEqualObjects([app standardizeCurrentDirectoryForPath:@"."], self.currentPath);
    
    NSString *path = [app standardizeCurrentDirectoryForPath:@"./path/subpath"];
    NSString *subpath = [NSString stringWithFormat:@"%@/path/subpath", self.currentPath];
    XCTAssertNotNil(path);
    XCTAssertNotNil(subpath);
    XCTAssertEqualObjects(path, subpath);
    
    NSString *dot = [app standardizeCurrentDirectoryForPath:@"path.with/dots/."];
    XCTAssertEqualObjects(dot, @"path.with/dots/.");
    
    NSString *doubleDot = [app standardizeCurrentDirectoryForPath:@".."];
    XCTAssertEqualObjects(doubleDot, @"..");
    
    NSString *doubleDotSubpath = [app standardizeCurrentDirectoryForPath:@"../path/subpath"];
    XCTAssertEqualObjects(doubleDotSubpath, @"../path/subpath");
}

#pragma mark Paths settings testing

- (void)testOutput_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings1 = [self settingsByRunningWithArgs:@"--output", @"path", nil];
    GBApplicationSettingsProvider *settings2 = [self settingsByRunningWithArgs:@"--output", @".", nil];
    // verify
    XCTAssertEqualObjects(settings1.outputPath, @"path");
    XCTAssertEqualObjects(settings2.outputPath, self.currentPath);
}

- (void)testTemplates_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings1 = [self settingsByRunningWithArgs:@"--templates", @"path", nil];
    GBApplicationSettingsProvider *settings2 = [self settingsByRunningWithArgs:@"--templates", @".", nil];
    // verify
    XCTAssertEqualObjects(settings1.templatesPath, @"path");
    XCTAssertEqualObjects(settings2.templatesPath, self.currentPath);
}

- (void)testDocsetInstallPath_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings1 = [self settingsByRunningWithArgs:@"--docset-install-path", @"path", nil];
    GBApplicationSettingsProvider *settings2 = [self settingsByRunningWithArgs:@"--docset-install-path", @".", nil];
    // verify
    XCTAssertEqualObjects(settings1.docsetInstallPath, @"path");
    XCTAssertEqualObjects(settings2.docsetInstallPath, self.currentPath);
}

- (void)testXcrunPath_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings1 = [self settingsByRunningWithArgs:@"--xcrun-path", @"path", nil];
    GBApplicationSettingsProvider *settings2 = [self settingsByRunningWithArgs:@"--xcrun-path", @".", nil];
    // verify
    XCTAssertEqualObjects(settings1.xcrunPath, @"path");
    XCTAssertEqualObjects(settings2.xcrunPath, self.currentPath);
}

- (void)testIndexDesc_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings1 = [self settingsByRunningWithArgs:@"--index-desc", @"path/file.txt", nil];
    GBApplicationSettingsProvider *settings2 = [self settingsByRunningWithArgs:@"--index-desc", @".", nil];
    // verify
    XCTAssertEqualObjects(settings1.indexDescriptionPath, @"path/file.txt");
    XCTAssertEqualObjects(settings2.indexDescriptionPath, self.currentPath);
}

- (void)testInclude_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings1 = [self settingsByRunningWithArgs:@"--include", @"path", nil];
    GBApplicationSettingsProvider *settings2 = [self settingsByRunningWithArgs:@"--include", @".", nil];
    // verify - note that ignore should not convert dot to current path; this would prevent .m being parsed properly!
    XCTAssertEqual([settings1.includePaths count], 1);
    XCTAssertTrue([settings1.includePaths containsObject:@"path"]);
    XCTAssertTrue([settings2.includePaths containsObject:self.currentPath]);
}

- (void)testInclude_shouldAssignMutlipleValuesToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings = [self settingsByRunningWithArgs:@"--include", @"path1", @"--include", @"path2", @"--include", @"path3", nil];
    // verify
    XCTAssertEqual([settings.includePaths count], 3);
    XCTAssertTrue([settings.includePaths containsObject:@"path1"]);
    XCTAssertTrue([settings.includePaths containsObject:@"path2"]);
    XCTAssertTrue([settings.includePaths containsObject:@"path3"]);
}

- (void)testIgnore_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings1 = [self settingsByRunningWithArgs:@"--ignore", @"path", nil];
    GBApplicationSettingsProvider *settings2 = [self settingsByRunningWithArgs:@"--ignore", @".", nil];
    // verify - note that ignore should not convert dot to current path; this would prevent .m being parsed properly!
    XCTAssertEqual([settings1.ignoredPaths count], 1);
    XCTAssertTrue([settings1.ignoredPaths containsObject:@"path"]);
    XCTAssertTrue([settings2.ignoredPaths containsObject:@"."]);
}

- (void)testIgnore_shouldAssignMutlipleValuesToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings = [self settingsByRunningWithArgs:@"--ignore", @"path1", @"--ignore", @"path2", @"--ignore", @"path3", nil];
    // verify
    XCTAssertEqual([settings.ignoredPaths count], 3);
    XCTAssertTrue([settings.ignoredPaths containsObject:@"path1"]);
    XCTAssertTrue([settings.ignoredPaths containsObject:@"path2"]);
    XCTAssertTrue([settings.ignoredPaths containsObject:@"path3"]);
}

#pragma mark Project settings testing

- (void)testProjectName_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings = [self settingsByRunningWithArgs:@"--project-name", @"value", nil];
    // verify
    XCTAssertEqualObjects(settings.projectName, @"value");
}

- (void)testProjectVersion_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings = [self settingsByRunningWithArgs:@"--project-version", @"value", nil];
    // verify
    XCTAssertEqualObjects(settings.projectVersion, @"value");
}

- (void)testProjectCompany_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings = [self settingsByRunningWithArgs:@"--project-company", @"value", nil];
    // verify
    XCTAssertEqualObjects(settings.projectCompany, @"value");
}

- (void)testCompanyIdentifier_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings = [self settingsByRunningWithArgs:@"--company-id", @"value", nil];
    // verify
    XCTAssertEqualObjects(settings.companyIdentifier, @"value");
}

#pragma mark Behavior settings testing

- (void)testCleanOutput_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings1 = [self settingsByRunningWithArgs:@"--clean-output", nil];
    GBApplicationSettingsProvider *settings2 = [self settingsByRunningWithArgs:@"--no-clean-output", nil];
    // verify
    XCTAssertTrue(settings1.cleanupOutputPathBeforeRunning);
    XCTAssertFalse(settings2.cleanupOutputPathBeforeRunning);
}

- (void)testCreateHTML_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings1 = [self settingsByRunningWithArgs:@"--create-html", nil];
    GBApplicationSettingsProvider *settings2 = [self settingsByRunningWithArgs:@"--no-create-html", nil];
    // verify
    XCTAssertTrue(settings1.createHTML);
    XCTAssertFalse(settings2.createHTML);
    XCTAssertFalse(settings2.createDocSet);
    XCTAssertFalse(settings2.installDocSet);
    XCTAssertFalse(settings2.publishDocSet);
}

- (void)testCreateDocSet_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings1 = [self settingsByRunningWithArgs:@"--create-docset", nil];
    GBApplicationSettingsProvider *settings2 = [self settingsByRunningWithArgs:@"--no-create-docset", nil];
    // verify
    XCTAssertTrue(settings1.createHTML);
    XCTAssertFalse(settings2.createDocSet);
    XCTAssertTrue(settings1.createDocSet);
    XCTAssertFalse(settings2.installDocSet);
    XCTAssertFalse(settings2.publishDocSet);
}

- (void)testInstallDocSet_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings1 = [self settingsByRunningWithArgs:@"--install-docset", nil];
    GBApplicationSettingsProvider *settings2 = [self settingsByRunningWithArgs:@"--no-install-docset", nil];
    // verify
    XCTAssertTrue(settings1.createHTML);
    XCTAssertTrue(settings1.createDocSet);
    XCTAssertTrue(settings1.installDocSet);
    XCTAssertFalse(settings2.installDocSet);
    XCTAssertFalse(settings2.publishDocSet);
}

- (void)testPublishDocSet_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings1 = [self settingsByRunningWithArgs:@"--publish-docset", nil];
    GBApplicationSettingsProvider *settings2 = [self settingsByRunningWithArgs:@"--no-publish-docset", nil];
    // verify
    XCTAssertTrue(settings1.createHTML);
    XCTAssertTrue(settings1.createDocSet);
    XCTAssertTrue(settings1.installDocSet);
    XCTAssertTrue(settings1.publishDocSet);
    XCTAssertFalse(settings2.publishDocSet);
}

- (void)testUseAppleAnchors_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings1 = [self settingsByRunningWithArgs:@"--html-anchors", @"appledoc", nil];
    GBApplicationSettingsProvider *settings2 = [self settingsByRunningWithArgs:@"--html-anchors", @"apple", nil];
    GBApplicationSettingsProvider *settings3 = [self settingsByRunningWithArgs:nil];
    // verify
    XCTAssertEqual(settings1.htmlAnchorFormat, GBHTMLAnchorFormatAppleDoc);
    XCTAssertEqual(settings2.htmlAnchorFormat, GBHTMLAnchorFormatApple);
    XCTAssertEqual(settings3.htmlAnchorFormat, GBHTMLAnchorFormatAppleDoc);
}

- (void)testKeepIntermediateFiles_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings1 = [self settingsByRunningWithArgs:@"--keep-intermediate-files", nil];
    GBApplicationSettingsProvider *settings2 = [self settingsByRunningWithArgs:@"--no-keep-intermediate-files", nil];
    // verify
    XCTAssertTrue(settings1.keepIntermediateFiles);
    XCTAssertFalse(settings2.keepIntermediateFiles);
}

- (void)testKeepUndocumentedObjects_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings1 = [self settingsByRunningWithArgs:@"--keep-undocumented-objects", nil];
    GBApplicationSettingsProvider *settings2 = [self settingsByRunningWithArgs:@"--no-keep-undocumented-objects", nil];
    // verify
    XCTAssertTrue(settings1.keepUndocumentedObjects);
    XCTAssertFalse(settings2.keepUndocumentedObjects);
}

- (void)testKeepUndocumentedMembers_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings1 = [self settingsByRunningWithArgs:@"--keep-undocumented-members", nil];
    GBApplicationSettingsProvider *settings2 = [self settingsByRunningWithArgs:@"--no-keep-undocumented-members", nil];
    // verify
    XCTAssertTrue(settings1.keepUndocumentedMembers);
    XCTAssertFalse(settings2.keepUndocumentedMembers);
}

- (void)testFindUndocumentedMembersDocumentation_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings1 = [self settingsByRunningWithArgs:@"--search-undocumented-doc", nil];
    GBApplicationSettingsProvider *settings2 = [self settingsByRunningWithArgs:@"--no-search-undocumented-doc", nil];
    // verify
    XCTAssertTrue(settings1.findUndocumentedMembersDocumentation);
    XCTAssertFalse(settings2.findUndocumentedMembersDocumentation);
}

- (void)testRepeatFirstParagraph_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings1 = [self settingsByRunningWithArgs:@"--repeat-first-par", nil];
    GBApplicationSettingsProvider *settings2 = [self settingsByRunningWithArgs:@"--no-repeat-first-par", nil];
    // verify
    XCTAssertTrue(settings1.repeatFirstParagraphForMemberDescription);
    XCTAssertFalse(settings2.repeatFirstParagraphForMemberDescription);
}

- (void)testPreprocessHeaderDoc_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings1 = [self settingsByRunningWithArgs:@"--preprocess-headerdoc", nil];
    GBApplicationSettingsProvider *settings2 = [self settingsByRunningWithArgs:@"--no-preprocess-headerdoc", nil];
    // verify
    XCTAssertTrue(settings1.preprocessHeaderDoc);
    XCTAssertFalse(settings2.preprocessHeaderDoc);
}

- (void)testUseSingleStarForBold_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings1 = [self settingsByRunningWithArgs:@"--use-single-star", nil];
    GBApplicationSettingsProvider *settings2 = [self settingsByRunningWithArgs:@"--no-use-single-star", nil];
    // verify
    XCTAssertTrue(settings1.useSingleStarForBold);
    XCTAssertFalse(settings2.useSingleStarForBold);
}

- (void)testMergeCategoriesToClasses_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings1 = [self settingsByRunningWithArgs:@"--merge-categories", nil];
    GBApplicationSettingsProvider *settings2 = [self settingsByRunningWithArgs:@"--no-merge-categories", nil];
    // verify
    XCTAssertTrue(settings1.mergeCategoriesToClasses);
    XCTAssertFalse(settings2.mergeCategoriesToClasses);
}

- (void)testMergeCategoryCommentToClass_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings1 = [self settingsByRunningWithArgs:@"--merge-category-comment", nil];
    GBApplicationSettingsProvider *settings2 = [self settingsByRunningWithArgs:@"--no-merge-category-comment", nil];
    // verify
    XCTAssertTrue(settings1.mergeCategoryCommentToClass);
    XCTAssertFalse(settings2.mergeCategoryCommentToClass);
}

- (void)testKeepMergedCategoriesSections_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings1 = [self settingsByRunningWithArgs:@"--keep-merged-sections", nil];
    GBApplicationSettingsProvider *settings2 = [self settingsByRunningWithArgs:@"--no-keep-merged-sections", nil];
    // verify
    XCTAssertTrue(settings1.keepMergedCategoriesSections);
    XCTAssertFalse(settings2.keepMergedCategoriesSections);
}

- (void)testPrefixMergedCategoriesSectionsWithCategoryName_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings1 = [self settingsByRunningWithArgs:@"--prefix-merged-sections", nil];
    GBApplicationSettingsProvider *settings2 = [self settingsByRunningWithArgs:@"--no-prefix-merged-sections", nil];
    // verify
    XCTAssertTrue(settings1.prefixMergedCategoriesSectionsWithCategoryName);
    XCTAssertFalse(settings2.prefixMergedCategoriesSectionsWithCategoryName);
}

- (void)testExplicitCrossRef_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings1 = [self settingsByRunningWithArgs:@"--explicit-crossref", nil];
    GBApplicationSettingsProvider *settings2 = [self settingsByRunningWithArgs:@"--no-explicit-crossref", nil];
    // verify
    XCTAssertEqualObjects(settings1.commentComponents.crossReferenceMarkersTemplate, @"<%@>");
    XCTAssertEqualObjects(settings2.commentComponents.crossReferenceMarkersTemplate, @"<?%@>?");
}

- (void)testCrossRefFormat_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings = [self settingsByRunningWithArgs:@"--crossref-format", @"FORMAT", nil];
    // verify
    XCTAssertEqualObjects(settings.commentComponents.crossReferenceMarkersTemplate, @"FORMAT");
}

- (void)testExitCodeThreshold_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings = [self settingsByRunningWithArgs:@"--exit-threshold", @"2", nil];
    // verify
    XCTAssertEqual(settings.exitCodeThreshold, 2);
}

#pragma mark Warnings settings testing

- (void)testWarnOnMissingOutputPath_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings1 = [self settingsByRunningWithArgs:@"--warn-missing-output-path", nil];
    GBApplicationSettingsProvider *settings2 = [self settingsByRunningWithArgs:@"--no-warn-missing-output-path", nil];
    // verify
    XCTAssertTrue(settings1.warnOnMissingOutputPathArgument);
    XCTAssertFalse(settings2.warnOnMissingOutputPathArgument);
}

- (void)testWarnOnMissingCompanyIdentifier_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings1 = [self settingsByRunningWithArgs:@"--warn-missing-company-id", nil];
    GBApplicationSettingsProvider *settings2 = [self settingsByRunningWithArgs:@"--no-warn-missing-company-id", nil];
    // verify
    XCTAssertTrue(settings1.warnOnMissingCompanyIdentifier);
    XCTAssertFalse(settings2.warnOnMissingCompanyIdentifier);
}

- (void)testWarnOnUndocumentedObject_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings1 = [self settingsByRunningWithArgs:@"--warn-undocumented-object", nil];
    GBApplicationSettingsProvider *settings2 = [self settingsByRunningWithArgs:@"--no-warn-undocumented-object", nil];
    // verify
    XCTAssertTrue(settings1.warnOnUndocumentedObject);
    XCTAssertFalse(settings2.warnOnUndocumentedObject);
}

- (void)testWarnOnUndocumentedMember_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings1 = [self settingsByRunningWithArgs:@"--warn-undocumented-member", nil];
    GBApplicationSettingsProvider *settings2 = [self settingsByRunningWithArgs:@"--no-warn-undocumented-member", nil];
    // verify
    XCTAssertTrue(settings1.warnOnUndocumentedMember);
    XCTAssertFalse(settings2.warnOnUndocumentedMember);
}

- (void)testWarnOnEmptyDescription_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings1 = [self settingsByRunningWithArgs:@"--warn-empty-description", nil];
    GBApplicationSettingsProvider *settings2 = [self settingsByRunningWithArgs:@"--no-warn-empty-description", nil];
    // verify
    XCTAssertTrue(settings1.warnOnEmptyDescription);
    XCTAssertFalse(settings2.warnOnEmptyDescription);
}

- (void)testWarnOnUnknownDirective_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings1 = [self settingsByRunningWithArgs:@"--warn-unknown-directive", nil];
    GBApplicationSettingsProvider *settings2 = [self settingsByRunningWithArgs:@"--no-warn-unknown-directive", nil];
    // verify
    XCTAssertTrue(settings1.warnOnUnknownDirective);
    XCTAssertFalse(settings2.warnOnUnknownDirective);
}

- (void)testWarnOnInvalidCrossReference_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings1 = [self settingsByRunningWithArgs:@"--warn-invalid-crossref", nil];
    GBApplicationSettingsProvider *settings2 = [self settingsByRunningWithArgs:@"--no-warn-invalid-crossref", nil];
    // verify
    XCTAssertTrue(settings1.warnOnInvalidCrossReference);
    XCTAssertFalse(settings2.warnOnInvalidCrossReference);
}

- (void)testWarnOnMissingMethodArgument_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings1 = [self settingsByRunningWithArgs:@"--warn-missing-arg", nil];
    GBApplicationSettingsProvider *settings2 = [self settingsByRunningWithArgs:@"--no-warn-missing-arg", nil];
    // verify
    XCTAssertTrue(settings1.warnOnMissingMethodArgument);
    XCTAssertFalse(settings2.warnOnMissingMethodArgument);
}

- (void)testWarnOnUnsupportedTypedefEnum_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings1 = [self settingsByRunningWithArgs:@"--warn-unsupported-typedef-enum", nil];
    GBApplicationSettingsProvider *settings2 = [self settingsByRunningWithArgs:@"--no-warn-unsupported-typedef-enum", nil];
    // verify
    XCTAssertTrue(settings1.warnOnUnsupportedTypedefEnum);
    XCTAssertFalse(settings2.warnOnUnsupportedTypedefEnum);
}

#pragma mark Documentation set settings testing

- (void)testDocSetBudnleIdentifier_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings = [self settingsByRunningWithArgs:@"--docset-bundle-id", @"value", nil];
    // verify
    XCTAssertEqualObjects(settings.docsetBundleIdentifier, @"value");
}

- (void)testDocSetBundleName_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings = [self settingsByRunningWithArgs:@"--docset-bundle-name", @"value", nil];
    // verify
    XCTAssertEqualObjects(settings.docsetBundleName, @"value");
}

- (void)testDocSetDescription_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings = [self settingsByRunningWithArgs:@"--docset-desc", @"value", nil];
    // verify
    XCTAssertEqualObjects(settings.docsetDescription, @"value");
}

- (void)testDocSetCopyright_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings = [self settingsByRunningWithArgs:@"--docset-copyright", @"value", nil];
    // verify
    XCTAssertEqualObjects(settings.docsetCopyrightMessage, @"value");
}

- (void)testDocSetFeedName_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings = [self settingsByRunningWithArgs:@"--docset-feed-name", @"value", nil];
    // verify
    XCTAssertEqualObjects(settings.docsetFeedName, @"value");
}

- (void)testDocSetFeedURL_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings = [self settingsByRunningWithArgs:@"--docset-feed-url", @"value", nil];
    // verify
    XCTAssertEqualObjects(settings.docsetFeedURL, @"value");
}

- (void)testDocSetFeedFormat_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings1 = [self settingsByRunningWithArgs:@"--docset-feed-formats", @"value", nil];
    GBApplicationSettingsProvider *settings2 = [self settingsByRunningWithArgs:@"--docset-feed-formats", @"atom", nil];
    GBApplicationSettingsProvider *settings3 = [self settingsByRunningWithArgs:@"--docset-feed-formats", @"xml", nil];
    GBApplicationSettingsProvider *settings4 = [self settingsByRunningWithArgs:@"--docset-feed-formats", @"atom,xml", nil];
    GBApplicationSettingsProvider *settings5 = [self settingsByRunningWithArgs:@"--docset-feed-formats", @"xml,atom", nil];
    // verify
    XCTAssertEqual(settings1.docsetFeedFormats, 0);
    XCTAssertEqual(settings2.docsetFeedFormats, GBPublishedFeedFormatAtom);
    XCTAssertEqual(settings3.docsetFeedFormats, GBPublishedFeedFormatXML);
    XCTAssertEqual(settings4.docsetFeedFormats, GBPublishedFeedFormatAtom | GBPublishedFeedFormatXML);
    XCTAssertEqual(settings5.docsetFeedFormats, GBPublishedFeedFormatAtom | GBPublishedFeedFormatXML);
}

- (void)testDocSetPackageURL_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings = [self settingsByRunningWithArgs:@"--docset-package-url", @"value", nil];
    // verify
    XCTAssertEqualObjects(settings.docsetPackageURL, @"value");
}

- (void)testDocSetFallbackURL_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings = [self settingsByRunningWithArgs:@"--docset-fallback-url", @"value", nil];
    // verify
    XCTAssertEqualObjects(settings.docsetFallbackURL, @"value");
}

- (void)testDocSetPublisherIdentifier_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings = [self settingsByRunningWithArgs:@"--docset-publisher-id", @"value", nil];
    // verify
    XCTAssertEqualObjects(settings.docsetPublisherIdentifier, @"value");
}

- (void)testDocSetPublisherName_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings = [self settingsByRunningWithArgs:@"--docset-publisher-name", @"value", nil];
    // verify
    XCTAssertEqualObjects(settings.docsetPublisherName, @"value");
}

- (void)testDocSetMinXcodeVersion_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings = [self settingsByRunningWithArgs:@"--docset-min-xcode-version", @"value", nil];
    // verify
    XCTAssertEqualObjects(settings.docsetMinimumXcodeVersion, @"value");
}

- (void)testDocSetPlatformFamily_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings = [self settingsByRunningWithArgs:@"--docset-platform-family", @"value", nil];
    // verify
    XCTAssertEqualObjects(settings.docsetPlatformFamily, @"value");
}

- (void)testDocSetCertificateIssuer_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings = [self settingsByRunningWithArgs:@"--docset-cert-issuer", @"value", nil];
    // verify
    XCTAssertEqualObjects(settings.docsetCertificateIssuer, @"value");
}

- (void)testDocSetCertificateSigner_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings = [self settingsByRunningWithArgs:@"--docset-cert-signer", @"value", nil];
    // verify
    XCTAssertEqualObjects(settings.docsetCertificateSigner, @"value");
}

- (void)testDocSetBundleFilename_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings = [self settingsByRunningWithArgs:@"--docset-bundle-filename", @"value", nil];
    // verify
    XCTAssertEqualObjects(settings.docsetBundleFilename, @"value");
}

- (void)testDocSetAtomFilename_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings = [self settingsByRunningWithArgs:@"--docset-atom-filename", @"value", nil];
    // verify
    XCTAssertEqualObjects(settings.docsetAtomFilename, @"value");
}

- (void)testDocSetXMLFilename_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings = [self settingsByRunningWithArgs:@"--docset-xml-filename", @"value", nil];
    // verify
    XCTAssertEqualObjects(settings.docsetXMLFilename, @"value");
}

- (void)testDocSetPackageFilename_shouldAssignValueToSettings {
    // setup & execute
    GBApplicationSettingsProvider *settings = [self settingsByRunningWithArgs:@"--docset-package-filename", @"value", nil];
    // verify
    XCTAssertEqualObjects(settings.docsetPackageFilename, @"value");
}

#pragma mark Creation methods

- (GBApplicationSettingsProvider *)settingsByRunningWithArgs:(NSString *)first, ... {
    // Basically this method allows testing whether the application properly maps command line arguments to settings. The method is a hack - it partially duplicates the internal workings of DDGetoptLongParser. First thing it constructs GBAppledocApplication object and injects it custom settings. Then it converts the given list of command line options to appropriate KVC messages and sends them to the application object - it uses DDGetoptLongParser to get the name of the KVC key for each option (some additions were required in order to expose the method that converts arguments to keys). As application more or less maps each command line option to specific property of it's settings, we can then use the injected settings to check whether all properties have correct values.
    // Note that this might easily be broken if internal workings of DDCli changes. In fact at first I did try to use DDCliRunApplication, but this only worked the first time used, it failed to extract options in all subsequent tests. And even then, DDCli code required some additions so that I was able passing it arbitrary list of arguments. On the other hand, the whole DDCli source code copy is used by appledoc, so any change to it is predictable...
    // Also note that we could go without changing any of DDCli code by simply using keys instead of command line arguments, but that would make unit tests less obvious... Another way would be to create the code that converts cli argument to key manually, but current solution seemed quite acceptable.

    // get arguments
    NSMutableArray *arguments = [NSMutableArray array];
    va_list args;
    va_start(args, first);
    for (NSString *arg=first; arg != nil; arg=va_arg(args, NSString*)) {
        [arguments addObject:arg];
    }
    va_end(args);
    
    // setup the application and inject settings to it.
    GBAppledocApplication *application = [[GBAppledocApplication alloc] init];
    GBApplicationSettingsProvider *result = [GBApplicationSettingsProvider provider];
    [application setValue:result forKey:@"settings"];
    
    // send all KVC messages for all options
    for (NSUInteger i=0; i<[arguments count]; i++) {
        NSString *arg = arguments[i];
        if ([arg hasPrefix:@"--"]) {
            // get the key corresponding to the argument
            NSString *key = [DDGetoptLongParser optionToKey:arg];
            
            key = [key stringByReplacingOccurrencesOfString:@"xcrun" withString:@"xCRun"];
            
            // if we have a value following, use it for KVC, otherwise just send YES
            if (i < [arguments count] - 1) {
                NSString *value = arguments[i + 1];
                if (![value hasPrefix:@"--"]) {
                    [application setValue:value forKey:key];
                    i++;
                    continue;
                }
            }
            [application setValue:@YES forKey:key];
        }
    }
    
    // return settings for validation these should now contain all values application passed from KVC messages
    return result;
}

- (NSString *)currentPath {
    return [[NSFileManager defaultManager] currentDirectoryPath];
}

@end
