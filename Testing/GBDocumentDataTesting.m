//
//  GBDocumentDataTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 10.2.11.
//  Copyright (C) 2011 Gentle Bytes. All rights reserved.
//

#import "GBDataObjects.h"
#import "GBApplicationSettingsProvider.h"

@interface GBDocumentDataTesting : GHTestCase
@end

@implementation GBDocumentDataTesting

#pragma mark Initializers testing

- (void)testInitWithContentsData_shouldCreateCommentWithContentsAsStringValue {
	// setup & execute
	GBDocumentData *document = [GBDocumentData documentDataWithContents:@"contents" path:@"path"];
	// verify
	assertThat(document.comment, isNot(nil));
	assertThat(document.comment.stringValue, is(@"contents"));
}

- (void)testInitWithContentsData_shouldCreateSourceInfoUsingThePathAsFilename {
	// setup & execute
	GBDocumentData *document = [GBDocumentData documentDataWithContents:@"contents" path:@"path/to/document.ext"];
	// verify
	assertThatInteger([document.sourceInfos count], equalToInteger(1));
	assertThatInteger([[document.sourceInfos anyObject] lineNumber], equalToInteger(1));
	assertThat([[document.sourceInfos anyObject] filename], is(@"document.ext"));
}

- (void)testInitWithContentsData_shouldAssignNameOfDocument {
	// setup & execute
	GBDocumentData *document = [GBDocumentData documentDataWithContents:@"contents" path:@"path/document.extension"];
	// verify
	assertThat(document.nameOfDocument, is(@"document.extension"));
}

- (void)testInitWithContentsData_shouldAssignPathOfDocument {
	// setup & execute
	GBDocumentData *document = [GBDocumentData documentDataWithContents:@"contents" path:@"path/document.extension"];
	// verify
	assertThat(document.pathOfDocument, is(@"path/document.extension"));
}

#pragma mark Convenience methods testing

- (void)testSubpathOfDocument_shouldReturnProperValue {
	// setup & execute
	GBDocumentData *document1 = [GBDocumentData documentDataWithContents:@"c" path:@"document.ext" basePath:@""];
	GBDocumentData *document2 = [GBDocumentData documentDataWithContents:@"c" path:@"path/sub/document.ext" basePath:@""];
	GBDocumentData *document3 = [GBDocumentData documentDataWithContents:@"c" path:@"path/document.ext" basePath:@"path"];
	GBDocumentData *document4 = [GBDocumentData documentDataWithContents:@"c" path:@"path/sub/document.ext" basePath:@"path"];
	GBDocumentData *document5 = [GBDocumentData documentDataWithContents:@"c" path:@"path/sub/document.ext" basePath:@"path/sub"];
	// verify
	assertThat(document1.subpathOfDocument, is(@"document.ext"));
	assertThat(document2.subpathOfDocument, is(@"path/sub/document.ext"));
	assertThat(document3.subpathOfDocument, is(@"document.ext"));
	assertThat(document4.subpathOfDocument, is(@"sub/document.ext"));
	assertThat(document5.subpathOfDocument, is(@"document.ext"));
}

#pragma mark Overriden methods

- (void)testIsStaticDocument_shouldReturnYES {
	// setup & execute
	GBDocumentData *document = [GBDocumentData documentDataWithContents:@"contents" path:@"path"];
	// verify
	assertThatBool(document.isStaticDocument, equalToBool(YES));
}

- (void)testIsTopLevelObject_shouldReturnNO {
	// setup & execute
	GBDocumentData *document = [GBDocumentData documentDataWithContents:@"contents" path:@"path"];
	// verify
	assertThatBool(document.isTopLevelObject, equalToBool(NO));
}

@end
