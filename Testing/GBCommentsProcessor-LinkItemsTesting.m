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
	GBComment *comment5 = [GBComment commentWithStringValue:@"mailto:tomaz@gentlebytes.com"];
	// execute
	[processor processComment:comment1 withStore:[GBTestObjectsRegistry store]];
	[processor processComment:comment2 withStore:[GBTestObjectsRegistry store]];
	[processor processComment:comment3 withStore:[GBTestObjectsRegistry store]];
	[processor processComment:comment4 withStore:[GBTestObjectsRegistry store]];
	[processor processComment:comment5 withStore:[GBTestObjectsRegistry store]];
	// verify
	[self assertParagraph:[comment1.paragraphs objectAtIndex:0] containsLinks:@"http://gentlebytes.com", GBNULL, GBNULL, NO, nil];
	[self assertParagraph:[comment2.paragraphs objectAtIndex:0] containsLinks:@"https://gentlebytes.com", GBNULL, GBNULL, NO, nil];
	[self assertParagraph:[comment3.paragraphs objectAtIndex:0] containsLinks:@"ftp://user:pass@gentlebytes.com", GBNULL, GBNULL, NO, nil];
	[self assertParagraph:[comment4.paragraphs objectAtIndex:0] containsLinks:@"file://gentlebytes.com", GBNULL, GBNULL, NO, nil];
	[self assertParagraph:[comment5.paragraphs objectAtIndex:0] containsLinks:@"mailto:tomaz@gentlebytes.com", GBNULL, GBNULL, NO, nil];
}

- (void)testProcessCommentWithStore_url_shouldDetectMarkedUrl {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"<http://gentlebytes.com>"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	[self assertParagraph:[comment.paragraphs objectAtIndex:0] containsLinks:@"http://gentlebytes.com", GBNULL, GBNULL, NO, nil];
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
	[self assertParagraph:[comment1.paragraphs objectAtIndex:0] containsTexts:@"appledoc://gentlebytes.com", nil];
	[self assertParagraph:[comment2.paragraphs objectAtIndex:0] containsTexts:@"htp://gentlebytes.com", nil];
}

- (void)testProcessCommentWithStore_url_shouldDetectUrlWithinParenthesis {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment1 = [GBComment commentWithStringValue:@"(http://gentlebytes.com)"];
	GBComment *comment2 = [GBComment commentWithStringValue:@"(<http://gentlebytes.com>)"];
	// execute
	[processor processComment:comment1 withStore:[GBTestObjectsRegistry store]];
	[processor processComment:comment2 withStore:[GBTestObjectsRegistry store]];
	// verify	
	[self assertParagraph:[comment1.paragraphs objectAtIndex:0] containsItems:[GBParagraphTextItem class], @"(", [GBParagraphLinkItem class], @"http://gentlebytes.com", [GBParagraphTextItem class], @")", nil];
	[self assertParagraph:[comment2.paragraphs objectAtIndex:0] containsItems:[GBParagraphTextItem class], @"(", [GBParagraphLinkItem class], @"http://gentlebytes.com", [GBParagraphTextItem class], @")", nil];
}

#pragma mark Remote instance methods processing testing

- (void)testProcessCommentWithStore_remoteMember_shouldDetectKnownInstanceMethodForClass {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBMethodData *method = [GBTestObjectsRegistry instanceMethodWithNames:@"instance", nil];
	GBClassData *class = [GBTestObjectsRegistry classWithName:@"Class" methods:method, nil];
	GBStore *store = [GBTestObjectsRegistry storeByPerformingSelector:@selector(registerClass:) withObject:class];
	GBComment *comment = [GBComment commentWithStringValue:@"[Class instance:]"];
	// execute
	[processor processComment:comment withContext:nil store:store];
	// verify
	[self assertParagraph:[comment.paragraphs objectAtIndex:0] containsLinks:@"[Class instance:]", class, method, NO, nil];
}

- (void)testProcessCommentWithStore_remoteMember_shouldDetectKnownInstanceMethodForCategory {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBMethodData *method = [GBTestObjectsRegistry instanceMethodWithNames:@"instance", nil];
	GBCategoryData *category = [GBTestObjectsRegistry categoryWithName:@"Category" className:@"Class" methods:method, nil];
	GBStore *store = [GBTestObjectsRegistry storeByPerformingSelector:@selector(registerCategory:) withObject:category];
	GBComment *comment = [GBComment commentWithStringValue:@"[Class(Category) instance:]"];
	// execute
	[processor processComment:comment withContext:nil store:store];
	// verify
	[self assertParagraph:[comment.paragraphs objectAtIndex:0] containsLinks:@"[Class(Category) instance:]", category, method, NO, nil];
}

- (void)testProcessCommentWithStore_remoteMember_shouldDetectKnownInstanceMethodForExtension {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBMethodData *method = [GBTestObjectsRegistry instanceMethodWithNames:@"instance", nil];
	GBCategoryData *extension = [GBTestObjectsRegistry categoryWithName:nil className:@"Class" methods:method, nil];
	GBStore *store = [GBTestObjectsRegistry storeByPerformingSelector:@selector(registerCategory:) withObject:extension];
	GBComment *comment = [GBComment commentWithStringValue:@"[Class() instance:]"];
	// execute
	[processor processComment:comment withContext:nil store:store];
	// verify
	[self assertParagraph:[comment.paragraphs objectAtIndex:0] containsLinks:@"[Class() instance:]", extension, method, NO, nil];
}

- (void)testProcessCommentWithStore_remoteMember_shouldDetectKnownInstanceMethodForProtocol {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBMethodData *method = [GBTestObjectsRegistry instanceMethodWithNames:@"instance", nil];
	GBProtocolData *protocol = [GBTestObjectsRegistry protocolWithName:@"Protocol" methods:method, nil];
	GBStore *store = [GBTestObjectsRegistry storeByPerformingSelector:@selector(registerProtocol:) withObject:protocol];
	GBComment *comment = [GBComment commentWithStringValue:@"[Protocol instance:]"];
	// execute
	[processor processComment:comment withContext:nil store:store];
	// verify
	[self assertParagraph:[comment.paragraphs objectAtIndex:0] containsLinks:@"[Protocol instance:]", protocol, method, NO, nil];
}

#pragma mark Remote class methods processing testing

- (void)testProcessCommentWithStore_remoteMember_shouldDetectKnownClassMethodForClass {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBMethodData *method = [GBTestObjectsRegistry classMethodWithNames:@"instance", nil];
	GBClassData *class = [GBTestObjectsRegistry classWithName:@"Class" methods:method, nil];
	GBStore *store = [GBTestObjectsRegistry storeByPerformingSelector:@selector(registerClass:) withObject:class];
	GBComment *comment = [GBComment commentWithStringValue:@"[Class instance:]"];
	// execute
	[processor processComment:comment withContext:nil store:store];
	// verify
	[self assertParagraph:[comment.paragraphs objectAtIndex:0] containsLinks:@"[Class instance:]", class, method, NO, nil];
}

- (void)testProcessCommentWithStore_remoteMember_shouldDetectKnownClassMethodForCategory {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBMethodData *method = [GBTestObjectsRegistry classMethodWithNames:@"instance", nil];
	GBCategoryData *category = [GBTestObjectsRegistry categoryWithName:@"Category" className:@"Class" methods:method, nil];
	GBStore *store = [GBTestObjectsRegistry storeByPerformingSelector:@selector(registerCategory:) withObject:category];
	GBComment *comment = [GBComment commentWithStringValue:@"[Class(Category) instance:]"];
	// execute
	[processor processComment:comment withContext:nil store:store];
	// verify
	[self assertParagraph:[comment.paragraphs objectAtIndex:0] containsLinks:@"[Class(Category) instance:]", category, method, NO, nil];
}

- (void)testProcessCommentWithStore_remoteMember_shouldDetectKnownClassMethodForExtension {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBMethodData *method = [GBTestObjectsRegistry classMethodWithNames:@"instance", nil];
	GBCategoryData *extension = [GBTestObjectsRegistry categoryWithName:nil className:@"Class" methods:method, nil];
	GBStore *store = [GBTestObjectsRegistry storeByPerformingSelector:@selector(registerCategory:) withObject:extension];
	GBComment *comment = [GBComment commentWithStringValue:@"[Class() instance:]"];
	// execute
	[processor processComment:comment withContext:nil store:store];
	// verify
	[self assertParagraph:[comment.paragraphs objectAtIndex:0] containsLinks:@"[Class() instance:]", extension, method, NO, nil];
}

- (void)testProcessCommentWithStore_remoteMember_shouldDetectKnownClassMethodForProtocol {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBMethodData *method = [GBTestObjectsRegistry classMethodWithNames:@"instance", nil];
	GBProtocolData *protocol = [GBTestObjectsRegistry protocolWithName:@"Protocol" methods:method, nil];
	GBStore *store = [GBTestObjectsRegistry storeByPerformingSelector:@selector(registerProtocol:) withObject:protocol];
	GBComment *comment = [GBComment commentWithStringValue:@"[Protocol instance:]"];
	// execute
	[processor processComment:comment withContext:nil store:store];
	// verify
	[self assertParagraph:[comment.paragraphs objectAtIndex:0] containsLinks:@"[Protocol instance:]", protocol, method, NO, nil];
}

#pragma mark Remote properties processing testing

- (void)testProcessCommentWithStore_remoteMember_shouldDetectKnownPropertyForClass {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBMethodData *method = [GBTestObjectsRegistry propertyMethodWithArgument:@"name"];
	GBClassData *class = [GBTestObjectsRegistry classWithName:@"Class" methods:method, nil];
	GBStore *store = [GBTestObjectsRegistry storeByPerformingSelector:@selector(registerClass:) withObject:class];
	GBComment *comment = [GBComment commentWithStringValue:@"[Class name]"];
	// execute
	[processor processComment:comment withContext:nil store:store];
	// verify
	[self assertParagraph:[comment.paragraphs objectAtIndex:0] containsLinks:@"[Class name]", class, method, NO, nil];
}

- (void)testProcessCommentWithStore_remoteMember_shouldDetectKnownPropertyForCategory {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBMethodData *method = [GBTestObjectsRegistry propertyMethodWithArgument:@"name"];
	GBCategoryData *category = [GBTestObjectsRegistry categoryWithName:@"Category" className:@"Class" methods:method, nil];
	GBStore *store = [GBTestObjectsRegistry storeByPerformingSelector:@selector(registerCategory:) withObject:category];
	GBComment *comment = [GBComment commentWithStringValue:@"[Class(Category) name]"];
	// execute
	[processor processComment:comment withContext:nil store:store];
	// verify
	[self assertParagraph:[comment.paragraphs objectAtIndex:0] containsLinks:@"[Class(Category) name]", category, method, NO, nil];
}

- (void)testProcessCommentWithStore_remoteMember_shouldDetectKnownPropertyForExtension {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBMethodData *method = [GBTestObjectsRegistry propertyMethodWithArgument:@"name"];
	GBCategoryData *extension = [GBTestObjectsRegistry categoryWithName:nil className:@"Class" methods:method, nil];
	GBStore *store = [GBTestObjectsRegistry storeByPerformingSelector:@selector(registerCategory:) withObject:extension];
	GBComment *comment = [GBComment commentWithStringValue:@"[Class() name]"];
	// execute
	[processor processComment:comment withContext:nil store:store];
	// verify
	[self assertParagraph:[comment.paragraphs objectAtIndex:0] containsLinks:@"[Class() name]", extension, method, NO, nil];
}

- (void)testProcessCommentWithStore_remoteMember_shouldDetectKnownPropertyForProtocol {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBMethodData *method = [GBTestObjectsRegistry propertyMethodWithArgument:@"name"];
	GBProtocolData *protocol = [GBTestObjectsRegistry protocolWithName:@"Protocol" methods:method, nil];
	GBStore *store = [GBTestObjectsRegistry storeByPerformingSelector:@selector(registerProtocol:) withObject:protocol];
	GBComment *comment = [GBComment commentWithStringValue:@"[Protocol name]"];
	// execute
	[processor processComment:comment withContext:nil store:store];
	// verify
	[self assertParagraph:[comment.paragraphs objectAtIndex:0] containsLinks:@"[Protocol name]", protocol, method, NO, nil];
}

#pragma mark Remote methods common processing testing

- (void)testProcessCommentWithStore_remoteMember_shouldDetectMarkedMember {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBMethodData *method = [GBTestObjectsRegistry propertyMethodWithArgument:@"name"];
	GBClassData *class = [GBTestObjectsRegistry classWithName:@"Class" methods:method, nil];
	GBStore *store = [GBTestObjectsRegistry storeByPerformingSelector:@selector(registerClass:) withObject:class];
	GBComment *comment = [GBComment commentWithStringValue:@"<[Class name]>"];
	// execute
	[processor processComment:comment withContext:nil store:store];
	// verify
	[self assertParagraph:[comment.paragraphs objectAtIndex:0] containsLinks:@"[Class name]", class, method, NO, nil];
}

- (void)testProcessCommentWithStore_remoteMember_shouldDetectMemberRegardlessOfPrefix {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBMethodData *method = [GBTestObjectsRegistry propertyMethodWithArgument:@"name"];
	GBClassData *class = [GBTestObjectsRegistry classWithName:@"Class" methods:method, nil];
	GBStore *store = [GBTestObjectsRegistry storeByPerformingSelector:@selector(registerClass:) withObject:class];
	GBComment *comment1 = [GBComment commentWithStringValue:@"-[Class name]"];
	GBComment *comment2 = [GBComment commentWithStringValue:@"+[Class name]"];
	// execute
	[processor processComment:comment1 withContext:nil store:store];
	[processor processComment:comment2 withContext:nil store:store];
	// verify
	[self assertParagraph:[comment1.paragraphs objectAtIndex:0] containsLinks:@"-[Class name]", class, method, NO, nil];
	[self assertParagraph:[comment2.paragraphs objectAtIndex:0] containsLinks:@"+[Class name]", class, method, NO, nil];
}

- (void)testProcessCommentWithStore_remoteMember_shouldIgnoreUnknownMethod {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBMethodData *method = [GBTestObjectsRegistry propertyMethodWithArgument:@"name"];
	GBClassData *class = [GBTestObjectsRegistry classWithName:@"Class" methods:method, nil];
	GBStore *store = [GBTestObjectsRegistry storeByPerformingSelector:@selector(registerClass:) withObject:class];
	GBComment *comment = [GBComment commentWithStringValue:@"[Class instance]"];
	// execute
	[processor processComment:comment withContext:nil store:store];
	// verify
	[self assertParagraph:[comment.paragraphs objectAtIndex:0] containsTexts:@"[Class instance]", nil];
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
	[self assertParagraph:[comment.paragraphs objectAtIndex:0] containsTexts:@"name", nil];
}

- (void)testProcessCommentWithStore_localMember_shouldIgnoreMethodIfNoContextIsGiven {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [GBTestObjectsRegistry store];
	GBComment *comment = [GBComment commentWithStringValue:@"instance:"];
	// execute
	[processor processComment:comment withContext:nil store:store];
	// verify
	[self assertParagraph:[comment.paragraphs objectAtIndex:0] containsTexts:@"instance:", nil];
}

#pragma mark Classes processing testing

- (void)testProcessCommentWithStore_class_shouldDetectLocalLink {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBClassData *class = [GBClassData classDataWithName:@"Class"];
	GBStore *store = [GBTestObjectsRegistry storeByPerformingSelector:@selector(registerClass:) withObject:class];
	GBComment *comment = [GBComment commentWithStringValue:@"Class"];
	// execute
	[processor processComment:comment withContext:class store:store];
	// verify
	[self assertParagraph:[comment.paragraphs objectAtIndex:0] containsLinks:@"Class", class, GBNULL, YES, nil];
}

- (void)testProcessCommentWithStore_class_shouldDetectRemoteLink {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBClassData *class1 = [GBClassData classDataWithName:@"Class1"];
	GBClassData *class2 = [GBClassData classDataWithName:@"Class2"];
	GBStore *store = [GBTestObjectsRegistry store];
	[store registerClass:class1];
	[store registerClass:class2];
	GBComment *comment = [GBComment commentWithStringValue:@"Class2"];
	// execute
	[processor processComment:comment withContext:class1 store:store];
	// verify
	[self assertParagraph:[comment.paragraphs objectAtIndex:0] containsLinks:@"Class2", class2, GBNULL, NO, nil];
}

- (void)testProcessCommentWithStore_class_shouldIgnoreIfNotRegisteredToStoreEvenIfPassedAsCurrentContext {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBClassData *class = [GBClassData classDataWithName:@"Class"];
	GBStore *store = [GBTestObjectsRegistry store];
	GBComment *comment = [GBComment commentWithStringValue:@"Class"];
	// execute
	[processor processComment:comment withContext:class store:store];
	// verify
	[self assertParagraph:[comment.paragraphs objectAtIndex:0] containsTexts:@"Class", nil];
}

#pragma mark Categories processing testing

- (void)testProcessCommentWithStore_category_shouldDetectLocalLink {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBCategoryData *category = [GBCategoryData categoryDataWithName:@"Category" className:@"Class"];
	GBStore *store = [GBTestObjectsRegistry storeByPerformingSelector:@selector(registerCategory:) withObject:category];
	GBComment *comment = [GBComment commentWithStringValue:@"Class(Category)"];
	// execute
	[processor processComment:comment withContext:category store:store];
	// verify
	[self assertParagraph:[comment.paragraphs objectAtIndex:0] containsLinks:@"Class(Category)", category, GBNULL, YES, nil];
}

- (void)testProcessCommentWithStore_category_shouldDetectRemoteLink {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBCategoryData *category1 = [GBCategoryData categoryDataWithName:@"Category1" className:@"Class"];
	GBCategoryData *category2 = [GBCategoryData categoryDataWithName:@"Category2" className:@"Class"];
	GBStore *store = [GBTestObjectsRegistry store];
	[store registerCategory:category1];
	[store registerCategory:category2];
	GBComment *comment = [GBComment commentWithStringValue:@"Class(Category2)"];
	// execute
	[processor processComment:comment withContext:category1 store:store];
	// verify
	[self assertParagraph:[comment.paragraphs objectAtIndex:0] containsLinks:@"Class(Category2)", category2, GBNULL, NO, nil];
}

- (void)testProcessCommentWithStore_category_shouldIgnoreIfNotRegisteredToStoreEvenIfPassedAsCurrentContext {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBCategoryData *category = [GBCategoryData categoryDataWithName:@"Category" className:@"Class"];
	GBStore *store = [GBTestObjectsRegistry store];
	GBComment *comment = [GBComment commentWithStringValue:@"Class(Category)"];
	// execute
	[processor processComment:comment withContext:category store:store];
	// verify
	[self assertParagraph:[comment.paragraphs objectAtIndex:0] containsTexts:@"Class(Category)", nil];
}

- (void)testProcessCommentWithStore_category_shouldIgnoreIfWhitespaceIsWrittenWithinWords {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBCategoryData *category = [GBCategoryData categoryDataWithName:@"Category" className:@"Class"];
	GBStore *store = [GBTestObjectsRegistry storeByPerformingSelector:@selector(registerCategory:) withObject:category];
	GBComment *comment1 = [GBComment commentWithStringValue:@"Class (Category)"];
	GBComment *comment2 = [GBComment commentWithStringValue:@"Class( Category)"];
	GBComment *comment3 = [GBComment commentWithStringValue:@"Class(Category )"];
	// execute
	[processor processComment:comment1 withContext:category store:store];
	[processor processComment:comment2 withContext:category store:store];
	[processor processComment:comment3 withContext:category store:store];
	// verify
	[self assertParagraph:[comment1.paragraphs objectAtIndex:0] containsTexts:@"Class (Category)", nil];
	[self assertParagraph:[comment2.paragraphs objectAtIndex:0] containsTexts:@"Class( Category)", nil];
	[self assertParagraph:[comment3.paragraphs objectAtIndex:0] containsTexts:@"Class(Category )", nil];
}

#pragma mark Extensions processing testing

- (void)testProcessCommentWithStore_extension_shouldDetectLocalLink {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBCategoryData *extension = [GBCategoryData categoryDataWithName:nil className:@"Class"];
	GBStore *store = [GBTestObjectsRegistry storeByPerformingSelector:@selector(registerCategory:) withObject:extension];
	GBComment *comment = [GBComment commentWithStringValue:@"Class()"];
	// execute
	[processor processComment:comment withContext:extension store:store];
	// verify
	[self assertParagraph:[comment.paragraphs objectAtIndex:0] containsLinks:@"Class()", extension, GBNULL, YES, nil];
}

- (void)testProcessCommentWithStore_extension_shouldDetectRemoteLink {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBCategoryData *extension1 = [GBCategoryData categoryDataWithName:nil className:@"Class1"];
	GBCategoryData *extension2 = [GBCategoryData categoryDataWithName:nil className:@"Class2"];
	GBStore *store = [GBTestObjectsRegistry store];
	[store registerCategory:extension1];
	[store registerCategory:extension2];
	GBComment *comment = [GBComment commentWithStringValue:@"Class2()"];
	// execute
	[processor processComment:comment withContext:extension1 store:store];
	// verify
	[self assertParagraph:[comment.paragraphs objectAtIndex:0] containsLinks:@"Class2()", extension2, GBNULL, NO, nil];
}

- (void)testProcessCommentWithStore_extension_shouldIgnoreIfNotRegisteredToStoreEvenIfPassedAsCurrentContext {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBCategoryData *extension = [GBCategoryData categoryDataWithName:nil className:@"Class"];
	GBStore *store = [GBTestObjectsRegistry store];
	GBComment *comment = [GBComment commentWithStringValue:@"Class()"];
	// execute
	[processor processComment:comment withContext:extension store:store];
	// verify
	[self assertParagraph:[comment.paragraphs objectAtIndex:0] containsTexts:@"Class()", nil];
}

- (void)testProcessCommentWithStore_extension_shouldIgnoreIfWhitespaceIsWrittenWithinWords {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBCategoryData *extension = [GBCategoryData categoryDataWithName:@"Category" className:@"Class"];
	GBStore *store = [GBTestObjectsRegistry storeByPerformingSelector:@selector(registerCategory:) withObject:extension];
	GBComment *comment1 = [GBComment commentWithStringValue:@"Class ()"];
	GBComment *comment2 = [GBComment commentWithStringValue:@"Class( )"];
	// execute
	[processor processComment:comment1 withContext:extension store:store];
	[processor processComment:comment2 withContext:extension store:store];
	// verify
	[self assertParagraph:[comment1.paragraphs objectAtIndex:0] containsTexts:@"Class ()", nil];
	[self assertParagraph:[comment2.paragraphs objectAtIndex:0] containsTexts:@"Class( )", nil];
}

#pragma mark Protocols processing testing

- (void)testProcessCommentWithStore_protocol_shouldDetectLocalLink {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBProtocolData *protocol = [GBProtocolData protocolDataWithName:@"Protocol"];
	GBStore *store = [GBTestObjectsRegistry storeByPerformingSelector:@selector(registerProtocol:) withObject:protocol];
	GBComment *comment = [GBComment commentWithStringValue:@"Protocol"];
	// execute
	[processor processComment:comment withContext:protocol store:store];
	// verify
	[self assertParagraph:[comment.paragraphs objectAtIndex:0] containsLinks:@"Protocol", protocol, GBNULL, YES, nil];
}

- (void)testProcessCommentWithStore_protocol_shouldDetectRemoteLink {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBProtocolData *protocol1 = [GBProtocolData protocolDataWithName:@"Protocol1"];
	GBProtocolData *protocol2 = [GBProtocolData protocolDataWithName:@"Protocol2"];
	GBStore *store = [GBTestObjectsRegistry store];
	[store registerProtocol:protocol1];
	[store registerProtocol:protocol2];
	GBComment *comment = [GBComment commentWithStringValue:@"Protocol2"];
	// execute
	[processor processComment:comment withContext:protocol1 store:store];
	// verify
	[self assertParagraph:[comment.paragraphs objectAtIndex:0] containsLinks:@"Protocol2", protocol2, GBNULL, NO, nil];
}

- (void)testProcessCommentWithStore_protocol_shouldIgnoreIfNotRegisteredToStoreEvenIfPassedAsCurrentContext {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBProtocolData *protocol = [GBProtocolData protocolDataWithName:@"Protocol"];
	GBStore *store = [GBTestObjectsRegistry store];
	GBComment *comment = [GBComment commentWithStringValue:@"Protocol"];
	// execute
	[processor processComment:comment withContext:protocol store:store];
	// verify
	[self assertParagraph:[comment.paragraphs objectAtIndex:0] containsTexts:@"Protocol", nil];
}

@end
