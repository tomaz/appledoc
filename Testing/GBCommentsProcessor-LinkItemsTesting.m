//
//  GBCommentsProcessor-LinkItemsTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 7.9.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBComment.h"
#import "GBCommentsProcessor.h"

@interface GBCommentsProcessorLinkItemsTesting : GBObjectsAssertor
@end

#pragma mark -

@implementation GBCommentsProcessorLinkItemsTesting

#pragma mark General processing & URL testing

- (void)testProcesCommentWithStore_shouldGenerateParagraphIfNoneSpecifiedBefore {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"http://gentlebytes.com"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([comment.paragraphs count], equalToInteger(1));
	[self assertParagraph:[comment.paragraphs objectAtIndex:0] containsItems:[GBParagraphLinkItem class], @"http://gentlebytes.com", nil];
}

- (void)testProcesCommentWithStore_shouldDetectAtTheStartOfParagraph {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"http://gentlebytes.com normal"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([comment.paragraphs count], equalToInteger(1));
	[self assertParagraph:[comment.paragraphs objectAtIndex:0] containsItems:[GBParagraphLinkItem class], @"http://gentlebytes.com", [GBParagraphTextItem class], @"normal", nil];
}

- (void)testProcesCommentWithStore_shouldDetectAtTheEndOfParagraph {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"normal http://gentlebytes.com"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([comment.paragraphs count], equalToInteger(1));
	[self assertParagraph:[comment.paragraphs objectAtIndex:0] containsItems:[GBParagraphTextItem class], @"normal", [GBParagraphLinkItem class], @"http://gentlebytes.com", nil];
}

- (void)testProcesCommentWithStore_shouldDetectInTheMiddleOfParagraph {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"prefix http://gentlebytes.com suffix"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([comment.paragraphs count], equalToInteger(1));
	[self assertParagraph:[comment.paragraphs objectAtIndex:0] containsItems:[GBParagraphTextItem class], @"prefix", [GBParagraphLinkItem class], @"http://gentlebytes.com", [GBParagraphTextItem class], @"suffix", nil];
}

#pragma mark URL processing testing

- (void)testProcessCommentWithStore_url_shouldDetectVariousPrefixes {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment1 = [GBComment commentWithStringValue:@"http://gentlebytes.com"];
	GBComment *comment2 = [GBComment commentWithStringValue:@"https://gentlebytes.com"];
	GBComment *comment3 = [GBComment commentWithStringValue:@"ftp://user:pass@gentlebytes.com"];
	GBComment *comment4 = [GBComment commentWithStringValue:@"file://gentlebytes.com"];
	// execute
	[processor processComment:comment1 withStore:[GBTestObjectsRegistry store]];
	[processor processComment:comment2 withStore:[GBTestObjectsRegistry store]];
	[processor processComment:comment3 withStore:[GBTestObjectsRegistry store]];
	[processor processComment:comment4 withStore:[GBTestObjectsRegistry store]];
	// verify
	[self assertParagraph:[comment1.paragraphs objectAtIndex:0] containsLinks:@"http://gentlebytes.com", [NSNull null], [NSNull null], NO, nil];
	[self assertParagraph:[comment2.paragraphs objectAtIndex:0] containsLinks:@"https://gentlebytes.com", [NSNull null], [NSNull null], NO, nil];
	[self assertParagraph:[comment3.paragraphs objectAtIndex:0] containsLinks:@"ftp://user:pass@gentlebytes.com", [NSNull null], [NSNull null], NO, nil];
	[self assertParagraph:[comment4.paragraphs objectAtIndex:0] containsLinks:@"file://gentlebytes.com", [NSNull null], [NSNull null], NO, nil];
}

- (void)testProcessCommentWithStore_url_shouldDetectMarkedUrl {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"<http://gentlebytes.com>"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	[self assertParagraph:[comment.paragraphs objectAtIndex:0] containsLinks:@"http://gentlebytes.com", [NSNull null], [NSNull null], NO, nil];
}

- (void)testProcessCommentWithStore_url_shouldIgnoreUnknownPrefixes {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment1 = [GBComment commentWithStringValue:@"appledoc://gentlebytes.com"];
	GBComment *comment2 = [GBComment commentWithStringValue:@"htp://gentlebytes.com"];
	// execute
	[processor processComment:comment1 withStore:[GBTestObjectsRegistry store]];
	[processor processComment:comment2 withStore:[GBTestObjectsRegistry store]];
	// verify
	[self assertParagraph:[comment1.paragraphs objectAtIndex:0] containsItems:[GBParagraphTextItem class], @"appledoc://gentlebytes.com", nil];
	[self assertParagraph:[comment2.paragraphs objectAtIndex:0] containsItems:[GBParagraphTextItem class], @"htp://gentlebytes.com", nil];
}

#pragma mark Local members processing testing

- (void)testProcessCommentWithStore_localMember_shouldDetectKnownInstanceMethod {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [GBTestObjectsRegistry store];
	GBMethodData *method = [GBTestObjectsRegistry instanceMethodWithNames:@"instance", nil];
	GBClassData *class = [GBTestObjectsRegistry classWithName:@"Class" methods:method, nil];
	GBComment *comment = [GBComment commentWithStringValue:@"instance:"];
	// execute
	[processor processComment:comment withContext:class store:store];
	// verify
	[self assertParagraph:[comment.paragraphs objectAtIndex:0] containsLinks:@"instance:", class, method, YES, nil];
}

- (void)testProcessCommentWithStore_localMember_shouldDetectKnownClassMethod {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [GBTestObjectsRegistry store];
	GBMethodData *method = [GBTestObjectsRegistry classMethodWithNames:@"class", nil];
	GBClassData *class = [GBTestObjectsRegistry classWithName:@"Class" methods:method, nil];
	GBComment *comment = [GBComment commentWithStringValue:@"class:"];
	// execute
	[processor processComment:comment withContext:class store:store];
	// verify
	[self assertParagraph:[comment.paragraphs objectAtIndex:0] containsLinks:@"class:", class, method, YES, nil];
}

- (void)testProcessCommentWithStore_localMember_shouldDetectKnownProperty {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [GBTestObjectsRegistry store];
	GBMethodData *method = [GBTestObjectsRegistry propertyMethodWithArgument:@"name"];
	GBClassData *class = [GBTestObjectsRegistry classWithName:@"Class" methods:method, nil];
	GBComment *comment = [GBComment commentWithStringValue:@"name"];
	// execute
	[processor processComment:comment withContext:class store:store];
	// verify
	[self assertParagraph:[comment.paragraphs objectAtIndex:0] containsLinks:@"name", class, method, YES, nil];
}

- (void)testProcessCommentWithStore_localMember_shouldDetectMarkedMethod {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [GBTestObjectsRegistry store];
	GBMethodData *method = [GBTestObjectsRegistry instanceMethodWithNames:@"instance", nil];
	GBClassData *class = [GBTestObjectsRegistry classWithName:@"Class" methods:method, nil];
	GBComment *comment = [GBComment commentWithStringValue:@"<instance:>"];
	// execute
	[processor processComment:comment withContext:class store:store];
	// verify
	[self assertParagraph:[comment.paragraphs objectAtIndex:0] containsLinks:@"instance:", class, method, YES, nil];
}

- (void)testProcessCommentWithStore_localMember_shouldIgnoreUnknownMethodForCurrentContext {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [GBTestObjectsRegistry store];
	GBMethodData *method = [GBTestObjectsRegistry instanceMethodWithNames:@"instance", nil];
	GBClassData *class = [GBTestObjectsRegistry classWithName:@"Class" methods:method, nil];
	GBComment *comment = [GBComment commentWithStringValue:@"name"];
	// execute
	[processor processComment:comment withContext:class store:store];
	// verify
	[self assertParagraph:[comment.paragraphs objectAtIndex:0] containsItems:[GBParagraphTextItem class], @"name", nil];
}

- (void)testProcessCommentWithStore_localMember_shouldIgnoreMethodIfNoContextIsGiven {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [GBTestObjectsRegistry store];
	GBComment *comment = [GBComment commentWithStringValue:@"instance:"];
	// execute
	[processor processComment:comment withContext:nil store:store];
	// verify
	[self assertParagraph:[comment.paragraphs objectAtIndex:0] containsItems:[GBParagraphTextItem class], @"instance:", nil];
}

@end


