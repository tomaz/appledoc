//
//  GBCommentsProcessor-MarkdownTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 19.2.11.
//  Copyright (C) 2011 Gentle Bytes. All rights reserved.
//

#import "GBApplicationSettingsProvider.h"
#import "GBDataObjects.h"
#import "GBStore.h"
#import "GBCommentsProcessor.h"

@interface GBCommentsProcessorMarkdownTesting : GBObjectsAssertor

- (GBCommentsProcessor *)defaultProcessor;
- (GBStore *)defaultStore;
- (GBStore *)storeWithDefaultObjects;
- (void)assertComment:(GBComment *)comment matchesLongDescMarkdown:(NSString *)first, ... NS_REQUIRES_NIL_TERMINATION;
- (void)assertComponents:(GBCommentComponentsList *)components matchMarkdown:(NSString *)first, ... NS_REQUIRES_NIL_TERMINATION;

@end

#pragma mark -

@implementation GBCommentsProcessorMarkdownTesting

#pragma mark Text blocks handling

- (void)testProcessCommentWithContextStore_markdown_shouldHandleSimpleText {
	// setup
	GBStore *store = [self defaultStore];
	GBCommentsProcessor *processor = [self defaultProcessor];
	GBComment *comment = [GBComment commentWithStringValue:@"Some text\n\nAnother paragraph"];
	// execute
	[processor processComment:comment withContext:nil store:store];
	// verify
	[self assertComment:comment matchesLongDescMarkdown:@"Some text\n\nAnother paragraph", nil];
}

- (void)testProcessCommentWithContextStore_markdown_shouldConvertWarning {
	// setup
	GBStore *store = [self defaultStore];
	GBCommentsProcessor *processor = [self defaultProcessor];
	GBComment *comment = [GBComment commentWithStringValue:@"Some text\n\n@warning Another paragraph\n\nAnd another"];
	// execute
	[processor processComment:comment withContext:nil store:store];
	// verify
	[self assertComment:comment matchesLongDescMarkdown:@"Some text", @"> %warning%\n> **Warning:** Another paragraph\n> \n> And another", nil];
}

- (void)testProcessCommentWithContextStore_markdown_shouldConvertBug {
	// setup
	GBStore *store = [self defaultStore];
	GBCommentsProcessor *processor = [self defaultProcessor];
	GBComment *comment = [GBComment commentWithStringValue:@"Some text\n\n@bug Another paragraph\n\nAnd another"];
	// execute
	[processor processComment:comment withContext:nil store:store];
	// verify
	[self assertComment:comment matchesLongDescMarkdown:@"Some text", @"> %bug%\n> **Bug:** Another paragraph\n> \n> And another", nil];
}

#pragma mark Inline cross references handling

- (void)testProcessCommentWithContextStore_markdown_shouldKeepInlineTopLevelObjectsCrossRefsTexts {
	// setup
	GBStore *store = [self storeWithDefaultObjects];
	GBCommentsProcessor *processor = [self defaultProcessor];
	GBComment *comment1 = [GBComment commentWithStringValue:@"Class"];
	GBComment *comment2 = [GBComment commentWithStringValue:@"Class(Category)"];
	GBComment *comment3 = [GBComment commentWithStringValue:@"Protocol"];
	GBComment *comment4 = [GBComment commentWithStringValue:@"Document"];
	// execute
	[processor processComment:comment1 withContext:nil store:store];
	[processor processComment:comment2 withContext:nil store:store];
	[processor processComment:comment3 withContext:nil store:store];
	[processor processComment:comment4 withContext:nil store:store];
	// verify
	[self assertComment:comment1 matchesLongDescMarkdown:@"[Class](Classes/Class.html)", nil];
	[self assertComment:comment2 matchesLongDescMarkdown:@"[Class(Category)](Categories/Class+Category.html)", nil];
	[self assertComment:comment3 matchesLongDescMarkdown:@"[Protocol](Protocols/Protocol.html)", nil];
	[self assertComment:comment4 matchesLongDescMarkdown:@"[Document](docs/Document.html)", nil];
}

- (void)testProcessCommentWithContextStore_markdown_shouldKeepInlineLocalMemberCrossRefsTexts {
	// setup
	GBStore *store = [self storeWithDefaultObjects];
	GBCommentsProcessor *processor = [self defaultProcessor];
	GBComment *comment1 = [GBComment commentWithStringValue:@"instanceMethod:"];
	GBComment *comment2 = [GBComment commentWithStringValue:@"classMethod:"];
	GBComment *comment3 = [GBComment commentWithStringValue:@"value"];
	// execute
	id context = [store.classes anyObject];
	[processor processComment:comment1 withContext:context store:store];
	[processor processComment:comment2 withContext:context store:store];
	[processor processComment:comment3 withContext:context store:store];
	// verify
	[self assertComment:comment1 matchesLongDescMarkdown:@"[instanceMethod:](#//api/name/instanceMethod:)", nil];
	[self assertComment:comment2 matchesLongDescMarkdown:@"[classMethod:](#//api/name/classMethod:)", nil];
	[self assertComment:comment3 matchesLongDescMarkdown:@"[value](#//api/name/value)", nil];
}

- (void)testProcessCommentWithContextStore_markdown_shouldKeepInlineRemoteMemberCrossRefsTexts {
	// setup
	GBStore *store = [self storeWithDefaultObjects];
	GBCommentsProcessor *processor = [self defaultProcessor];
	GBComment *comment1 = [GBComment commentWithStringValue:@"[Class instanceMethod:]"];
	GBComment *comment2 = [GBComment commentWithStringValue:@"[Class classMethod:]"];
	GBComment *comment3 = [GBComment commentWithStringValue:@"[Class value]"];
	// execute
	[processor processComment:comment1 withContext:nil store:store];
	[processor processComment:comment2 withContext:nil store:store];
	[processor processComment:comment3 withContext:nil store:store];
	// verify
	[self assertComment:comment1 matchesLongDescMarkdown:@"[[Class instanceMethod:]](Classes/Class.html#//api/name/instanceMethod:)", nil];
	[self assertComment:comment2 matchesLongDescMarkdown:@"[[Class classMethod:]](Classes/Class.html#//api/name/classMethod:)", nil];
	[self assertComment:comment3 matchesLongDescMarkdown:@"[[Class value]](Classes/Class.html#//api/name/value)", nil];
}

- (void)testProcessCommentWithContextStore_markdown_shouldProperlyFormatInlineLinksWithinStandardMarkdownFormattingMarkers {
	// setup
	GBStore *store = [self storeWithDefaultObjects];
	GBCommentsProcessor *processor = [self defaultProcessor];
	GBComment *comment1 = [GBComment commentWithStringValue:@"`Class`"];
	GBComment *comment2 = [GBComment commentWithStringValue:@"`Class(Category)`"];
	GBComment *comment3 = [GBComment commentWithStringValue:@"*Protocol*"];
	GBComment *comment4 = [GBComment commentWithStringValue:@"_Document_"];
	GBComment *comment5 = [GBComment commentWithStringValue:@"**Protocol**"];
	GBComment *comment6 = [GBComment commentWithStringValue:@"__Document__"];
	// execute
	[processor processComment:comment1 withContext:nil store:store];
	[processor processComment:comment2 withContext:nil store:store];
	[processor processComment:comment3 withContext:nil store:store];
	[processor processComment:comment4 withContext:nil store:store];
	[processor processComment:comment5 withContext:nil store:store];
	[processor processComment:comment6 withContext:nil store:store];
	// verify
	[self assertComment:comment1 matchesLongDescMarkdown:@"[`Class`](Classes/Class.html)", nil];
	[self assertComment:comment2 matchesLongDescMarkdown:@"[`Class(Category)`](Categories/Class+Category.html)", nil];
	[self assertComment:comment3 matchesLongDescMarkdown:@"*[Protocol](Protocols/Protocol.html)*", nil];
	[self assertComment:comment4 matchesLongDescMarkdown:@"_[Document](docs/Document.html)_", nil];
	[self assertComment:comment5 matchesLongDescMarkdown:@"**[Protocol](Protocols/Protocol.html)**", nil];
	[self assertComment:comment6 matchesLongDescMarkdown:@"__[Document](docs/Document.html)__", nil];
}

- (void)testProcessCommentWithContextStore_markdown_shouldProperlyFormatInlineLinksWithinCustomFormattingMarkers {
	// setup
	GBStore *store = [self storeWithDefaultObjects];
	id settings1 = [GBTestObjectsRegistry realSettingsProvider];
	[settings1 setEmbedCrossReferencesWhenProcessingMarkdown:NO];
	[settings1 setUseSingleStarForBold:NO];
	GBCommentsProcessor *processor1 = [GBCommentsProcessor processorWithSettingsProvider:settings1];
	GBComment *comment1 = [GBComment commentWithStringValue:@"*Protocol*"];
	id settings2 = [GBTestObjectsRegistry realSettingsProvider];
	[settings2 setEmbedCrossReferencesWhenProcessingMarkdown:NO];
	[settings2 setUseSingleStarForBold:YES];
	GBCommentsProcessor *processor2 = [GBCommentsProcessor processorWithSettingsProvider:settings2];
	GBComment *comment2 = [GBComment commentWithStringValue:@"*Protocol*"];
	// execute
	[processor1 processComment:comment1 withContext:nil store:store];
	[processor2 processComment:comment2 withContext:nil store:store];
	// verify
	[self assertComment:comment1 matchesLongDescMarkdown:@"*[Protocol](Protocols/Protocol.html)*", nil];
	[self assertComment:comment2 matchesLongDescMarkdown:@"**~!$[Protocol](Protocols/Protocol.html)$!~**", nil];
}

- (void)testProcessCommentWithContextStore_markdown_shouldProperlyFormatInlineLinksWhenEmbeddingIsTurnedOn {
	// setup
	GBStore *store = [self storeWithDefaultObjects];
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	GBComment *comment1 = [GBComment commentWithStringValue:@"Class"];
	GBComment *comment2 = [GBComment commentWithStringValue:@"`Class`"];
	GBComment *comment3 = [GBComment commentWithStringValue:@"@see Class"];
	// execute
	[processor processComment:comment1 withContext:nil store:store];
	[processor processComment:comment2 withContext:nil store:store];
	[processor processComment:comment3 withContext:nil store:store];
	// verify
	[self assertComment:comment1 matchesLongDescMarkdown:@"~!@[Class](Classes/Class.html)@!~", nil];
	[self assertComment:comment2 matchesLongDescMarkdown:@"~!@[`Class`](Classes/Class.html)@!~", nil];
	[self assertComponents:comment3.relatedItems matchMarkdown:@"~!@[Class](Classes/Class.html)@!~", nil];
}

#pragma mark Related items cross references handling

- (void)testProcessCommentWithContextStore_markdown_shouldKeepRelatedItemsTopLevelObjectsCrossRefsTexts {
	// setup
	GBStore *store = [self storeWithDefaultObjects];
	GBCommentsProcessor *processor = [self defaultProcessor];
	GBComment *comment1 = [GBComment commentWithStringValue:@"@see Class"];
	GBComment *comment2 = [GBComment commentWithStringValue:@"@see Class(Category)"];
	GBComment *comment3 = [GBComment commentWithStringValue:@"@see Protocol"];
	GBComment *comment4 = [GBComment commentWithStringValue:@"@see Document"];
	// execute
	[processor processComment:comment1 withContext:nil store:store];
	[processor processComment:comment2 withContext:nil store:store];
	[processor processComment:comment3 withContext:nil store:store];
	[processor processComment:comment4 withContext:nil store:store];
	// verify
	[self assertComponents:comment1.relatedItems matchMarkdown:@"[Class](Classes/Class.html)", nil];
	[self assertComponents:comment2.relatedItems matchMarkdown:@"[Class(Category)](Categories/Class+Category.html)", nil];
	[self assertComponents:comment3.relatedItems matchMarkdown:@"[Protocol](Protocols/Protocol.html)", nil];
	[self assertComponents:comment4.relatedItems matchMarkdown:@"[Document](docs/Document.html)", nil];
}

- (void)testProcessCommentWithContextStore_markdown_shouldUsePrefixForRelatedItemsLocalMemberCrossRefsTexts {
	// setup
	GBStore *store = [self storeWithDefaultObjects];
	GBCommentsProcessor *processor = [self defaultProcessor];
	GBComment *comment1 = [GBComment commentWithStringValue:@"@see instanceMethod:"];
	GBComment *comment2 = [GBComment commentWithStringValue:@"@see classMethod:"];
	GBComment *comment3 = [GBComment commentWithStringValue:@"@see value"];
	// execute
	id context = [store.classes anyObject];
	[processor processComment:comment1 withContext:context store:store];
	[processor processComment:comment2 withContext:context store:store];
	[processor processComment:comment3 withContext:context store:store];
	// verify
	[self assertComponents:comment1.relatedItems matchMarkdown:@"[- instanceMethod:](#//api/name/instanceMethod:)", nil];
	[self assertComponents:comment2.relatedItems matchMarkdown:@"[+ classMethod:](#//api/name/classMethod:)", nil];
	[self assertComponents:comment3.relatedItems matchMarkdown:@"[@property value](#//api/name/value)", nil];
}

- (void)testProcessCommentWithContextStore_markdown_shouldKeepRelatedItemsRemoteMemberCrossRefsTexts {
	// setup
	GBStore *store = [self storeWithDefaultObjects];
	GBCommentsProcessor *processor = [self defaultProcessor];
	GBComment *comment1 = [GBComment commentWithStringValue:@"@see [Class instanceMethod:]"];
	GBComment *comment2 = [GBComment commentWithStringValue:@"@see [Class classMethod:]"];
	GBComment *comment3 = [GBComment commentWithStringValue:@"@see [Class value]"];
	// execute
	[processor processComment:comment1 withContext:nil store:store];
	[processor processComment:comment2 withContext:nil store:store];
	[processor processComment:comment3 withContext:nil store:store];
	// verify
	[self assertComponents:comment1.relatedItems matchMarkdown:@"[[Class instanceMethod:]](Classes/Class.html#//api/name/instanceMethod:)", nil];
	[self assertComponents:comment2.relatedItems matchMarkdown:@"[[Class classMethod:]](Classes/Class.html#//api/name/classMethod:)", nil];
	[self assertComponents:comment3.relatedItems matchMarkdown:@"[[Class value]](Classes/Class.html#//api/name/value)", nil];
}

#pragma mark Making sure reasonably complex stuff gets handled properly

- (void)testProcessCommentWithConextStore_markdown_shouldHandleMultipleMarkdownLinks {
	// setup
	GBStore *store = [self storeWithDefaultObjects];
	GBCommentsProcessor *processor = [self defaultProcessor];
	GBComment *comment = [GBComment commentWithStringValue:@"Some prefix [link1](address1) middle [link2](address2) and suffix"];
	// execute
	[processor processComment:comment withContext:nil store:store];
	// verify
	[self assertComment:comment matchesLongDescMarkdown:@"Some prefix [link1](address1) middle [link2](address2) and suffix", nil];
}

- (void)testProcessCommentWithContextStore_markdown_shouldHandleSimpleLinksWithinMarkdownLinksProperly {
	// setup
	GBStore *store = [self storeWithDefaultObjects];
	GBCommentsProcessor *processor = [self defaultProcessor];
	GBComment *comment = [GBComment commentWithStringValue:@"[link1](address1) Document and [this class](Class) [link2](address2) longer suffix to make sure"];
	// execute
	[processor processComment:comment withContext:nil store:store];
	// verify
	[self assertComment:comment matchesLongDescMarkdown:@"[link1](address1) [Document](docs/Document.html) and [this class](Classes/Class.html) [link2](address2) longer suffix to make sure", nil];
}

#pragma mark Copied comments handling

- (void)testStringByConvertingCrossReferencesInString_copied_shouldUseUniversalRelativePathForLocalMembers {
	// setup
	GBStore *store = [self storeWithDefaultObjects];
	GBClassData *class = [store classWithName:@"Class"];
	GBCommentsProcessor *processor = [self defaultProcessor];
	GBComment *comment = [GBComment commentWithStringValue:@"instanceMethod:"];
	comment.originalContext = class;
	// execute
	[processor processComment:comment withContext:class store:store];
	// verify
	[self assertComment:comment matchesLongDescMarkdown:@"[instanceMethod:](../Classes/Class.html#//api/name/instanceMethod:)", nil];
}
										 
- (void)testStringByConvertingCrossReferencesInString_copied_shouldIgnoreCommentIfOriginalContextDoesntMatch {
	// setup
	GBStore *store = [self storeWithDefaultObjects];
	GBCommentsProcessor *processor = [self defaultProcessor];
	GBComment *comment = [GBComment commentWithStringValue:@"instanceMethod:"];
	comment.originalContext = [store classWithName:@"Class"];
	// execute
	[processor processComment:comment withContext:[store protocolWithName:@"Protocol"] store:store];
	// verify
	[self assertComment:comment matchesLongDescMarkdown:nil];
}

#pragma mark Creation methods

- (GBCommentsProcessor *)defaultProcessor {
	// Creates a new GBCommentsProcessor using real settings. Note that we disable embedding cross references to make test strings more readable.
	id settings = [GBTestObjectsRegistry realSettingsProvider];
	[settings setEmbedCrossReferencesWhenProcessingMarkdown:NO];
	return [GBCommentsProcessor processorWithSettingsProvider:settings];
}

- (GBStore *)defaultStore {
	return [GBTestObjectsRegistry store];
}

- (GBStore *)storeWithDefaultObjects {
	GBMethodData *instanceMethod = [GBTestObjectsRegistry instanceMethodWithNames:@"instanceMethod", nil];
	GBMethodData *classMethod = [GBTestObjectsRegistry classMethodWithNames:@"classMethod", nil];
	GBMethodData *property = [GBTestObjectsRegistry propertyMethodWithArgument:@"value"];
	GBClassData *class = [GBTestObjectsRegistry classWithName:@"Class" methods:instanceMethod, classMethod, property, nil];
	GBCategoryData *category = [GBCategoryData categoryDataWithName:@"Category" className:@"Class"];
	GBProtocolData *protocol = [GBProtocolData protocolDataWithName:@"Protocol"];
	GBDocumentData *document = [GBDocumentData documentDataWithContents:@"c" path:@"Document.ext"];
	return [GBTestObjectsRegistry storeWithObjects:class, category, protocol, document, nil];
}

#pragma mark Assertion methods

- (void)assertComment:(GBComment *)comment matchesLongDescMarkdown:(NSString *)first, ... {
	NSMutableArray *expectations = [NSMutableArray array];
	va_list args;
	va_start(args, first);
	for (NSString *arg=first; arg != nil; arg=va_arg(args, NSString*)) {
		[expectations addObject:arg];
	}
	va_end(args);
	
	assertThatInteger([comment.longDescription.components count], equalToInteger([expectations count]));
	for (NSUInteger i=0; i<[expectations count]; i++) {
		GBCommentComponent *component = [comment.longDescription.components objectAtIndex:i];
		NSString *expected = [expectations objectAtIndex:i];
		assertThat(component.markdownValue, is(expected));
	}
}

- (void)assertComponents:(GBCommentComponentsList *)components matchMarkdown:(NSString *)first, ... {
	NSMutableArray *expectations = [NSMutableArray array];
	va_list args;
	va_start(args, first);
	for (NSString *arg=first; arg != nil; arg=va_arg(args, NSString*)) {
		[expectations addObject:arg];
	}
	va_end(args);
	
	assertThatInteger([components.components count], equalToInteger([expectations count]));
	for (NSUInteger i=0; i<[expectations count]; i++) {
		GBCommentComponent *component = [components.components objectAtIndex:i];
		NSString *expected = [expectations objectAtIndex:i];
		assertThat(component.markdownValue, is(expected));
	}
}

@end
