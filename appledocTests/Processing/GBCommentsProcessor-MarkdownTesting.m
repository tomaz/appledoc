//
//  GBCommentsProcessor-MarkdownTesting.m
//  appledocTests
//
//  Created by Jebeom Gyeong on 2/22/20.
//  Copyright © 2020 Gentle Bytes. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "GBApplicationSettingsProvider.h"
#import "GBDataObjects.h"
#import "GBStore.h"
#import "GBCommentsProcessor.h"
#import "GBTestObjectsRegistry.h"

@interface GBCommentsProcessor_MarkdownTesting : XCTestCase

- (GBCommentsProcessor *)defaultProcessor;
- (GBStore *)defaultStore;
- (GBStore *)storeWithDefaultObjects;
- (void)assertComment:(GBComment *)comment matchesLongDescMarkdown:(NSString *)first, ... NS_REQUIRES_NIL_TERMINATION;
- (void)assertComponents:(GBCommentComponentsList *)components matchMarkdown:(NSString *)first, ... NS_REQUIRES_NIL_TERMINATION;

@end

#pragma mark -

@implementation GBCommentsProcessor_MarkdownTesting

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

#pragma mark Text blocks handling

- (void)testProcessCommentWithContextStore_markdown_shouldHandleSimpleText {
    // setup
    GBStore *store = [self defaultStore];
    GBCommentsProcessor *processor = [self defaultProcessor];
    GBComment *comment = [GBComment commentWithStringValue:@"Some text\n\nAnother paragraph"];
    // execute
    [processor processComment:comment withContext:nil store:store];
    // verify
    XCTAssertEqualObjects(((GBCommentComponent *)(comment.longDescription.components[0])).markdownValue, @"Some text\n\nAnother paragraph");
}

- (void)testProcessCommentWithContextStore_markdown_shouldConvertWarning {
    // setup
    GBStore *store = [self defaultStore];
    GBCommentsProcessor *processor = [self defaultProcessor];
    GBComment *comment = [GBComment commentWithStringValue:@"Some text\n\n@warning Another paragraph\n\nAnd another"];
    // execute
    [processor processComment:comment withContext:nil store:store];
    // verify
    XCTAssertEqualObjects(((GBCommentComponent *)(comment.longDescription.components[0])).markdownValue, @"Some text");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment.longDescription.components[1])).markdownValue, @"> %warning%\n> **Warning:** Another paragraph\n> \n> And another");
}

- (void)testProcessCommentWithContextStore_markdown_shouldConvertBug {
    // setup
    GBStore *store = [self defaultStore];
    GBCommentsProcessor *processor = [self defaultProcessor];
    GBComment *comment = [GBComment commentWithStringValue:@"Some text\n\n@bug Another paragraph\n\nAnd another"];
    // execute
    [processor processComment:comment withContext:nil store:store];
    // verify
    XCTAssertEqualObjects(((GBCommentComponent *)(comment.longDescription.components[0])).markdownValue, @"Some text");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment.longDescription.components[1])).markdownValue, @"> %bug%\n> **Bug:** Another paragraph\n> \n> And another");
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
    XCTAssertEqualObjects(((GBCommentComponent *)(comment1.longDescription.components[0])).markdownValue, @"[Class](Classes/Class.html)");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment2.longDescription.components[0])).markdownValue, @"[Class(Category)](Categories/Class+Category.html)");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment3.longDescription.components[0])).markdownValue, @"[Protocol](Protocols/Protocol.html)");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment4.longDescription.components[0])).markdownValue, @"[Document](docs/Document.html)");
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
    XCTAssertEqualObjects(((GBCommentComponent *)(comment1.longDescription.components[0])).markdownValue, @"[instanceMethod:](#//api/name/instanceMethod:)");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment2.longDescription.components[0])).markdownValue, @"[classMethod:](#//api/name/classMethod:)");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment3.longDescription.components[0])).markdownValue, @"[value](#//api/name/value)");
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
    XCTAssertEqualObjects(((GBCommentComponent *)(comment1.longDescription.components[0])).markdownValue, @"[[Class instanceMethod:]](Classes/Class.html#//api/name/instanceMethod:)");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment2.longDescription.components[0])).markdownValue, @"[[Class classMethod:]](Classes/Class.html#//api/name/classMethod:)");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment3.longDescription.components[0])).markdownValue, @"[[Class value]](Classes/Class.html#//api/name/value)");
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
    XCTAssertEqualObjects(((GBCommentComponent *)(comment1.longDescription.components[0])).markdownValue, @"[`Class`](Classes/Class.html)");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment2.longDescription.components[0])).markdownValue, @"[`Class(Category)`](Categories/Class+Category.html)");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment3.longDescription.components[0])).markdownValue, @"*[Protocol](Protocols/Protocol.html)*");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment4.longDescription.components[0])).markdownValue, @"_[Document](docs/Document.html)_");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment5.longDescription.components[0])).markdownValue, @"**[Protocol](Protocols/Protocol.html)**");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment6.longDescription.components[0])).markdownValue, @"__[Document](docs/Document.html)__");
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
    XCTAssertEqualObjects(((GBCommentComponent *)(comment1.longDescription.components[0])).markdownValue, @"*[Protocol](Protocols/Protocol.html)*");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment2.longDescription.components[0])).markdownValue, @"**~!$[Protocol](Protocols/Protocol.html)$!~**");
}

- (void)testProcessCommentWithContextStore_markdown_shouldProperlyFormatImageReferenceLinks {
    // setup
    GBStore *store = [self storeWithDefaultObjects];
    id settings1 = [GBTestObjectsRegistry realSettingsProvider];
    [settings1 setEmbedCrossReferencesWhenProcessingMarkdown:NO];
    GBCommentsProcessor *processor1 = [GBCommentsProcessor processorWithSettingsProvider:settings1];
    GBComment *comment1 = [GBComment commentWithStringValue:@"![alt info](http://foo/bar.blarg)"];
    id settings2 = [GBTestObjectsRegistry realSettingsProvider];
    [settings2 setEmbedCrossReferencesWhenProcessingMarkdown:YES];
    GBCommentsProcessor *processor2 = [GBCommentsProcessor processorWithSettingsProvider:settings2];
    GBComment *comment2 = [GBComment commentWithStringValue:@"![alt info](http://foo/bar.blarg)"];
    // execute
    [processor1 processComment:comment1 withContext:nil store:store];
    [processor2 processComment:comment2 withContext:nil store:store];
    // verify
    XCTAssertEqualObjects(((GBCommentComponent *)(comment1.longDescription.components[0])).markdownValue, @"![alt info](http://foo/bar.blarg)");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment2.longDescription.components[0])).markdownValue, @"~!@![alt info](http://foo/bar.blarg)@!~");
}

- (void)testProcessCommentWithContextStore_markdown_shouldProperlyFormatImageReferenceLinksWithPercentChars {
    // setup
    GBStore *store = [self storeWithDefaultObjects];
    id settings1 = [GBTestObjectsRegistry realSettingsProvider];
    [settings1 setEmbedCrossReferencesWhenProcessingMarkdown:NO];
    GBCommentsProcessor *processor1 = [GBCommentsProcessor processorWithSettingsProvider:settings1];
    NSString *raw = @"![alt info](http://foo/bar.%2.blarg \"foo%20bar\")";
    GBComment *comment1 = [GBComment commentWithStringValue:raw];
    id settings2 = [GBTestObjectsRegistry realSettingsProvider];
    [settings2 setEmbedCrossReferencesWhenProcessingMarkdown:YES];
    GBCommentsProcessor *processor2 = [GBCommentsProcessor processorWithSettingsProvider:settings2];
    GBComment *comment2 = [GBComment commentWithStringValue:raw];
    // execute
    [processor1 processComment:comment1 withContext:nil store:store];
    [processor2 processComment:comment2 withContext:nil store:store];
    // verify
    XCTAssertEqualObjects(((GBCommentComponent *)(comment1.longDescription.components[0])).markdownValue, raw);
    NSString *value = [NSString stringWithFormat:@"~!@%@@!~", raw];
    XCTAssertEqualObjects(((GBCommentComponent *)(comment2.longDescription.components[0])).markdownValue, value);
}

- (void)testProcessCommentWithContextStore_markdown_shouldProperlyFormatNestedImageReferenceLinks {
    // setup
    GBStore *store = [self storeWithDefaultObjects];
    id settings1 = [GBTestObjectsRegistry realSettingsProvider];
    [settings1 setEmbedCrossReferencesWhenProcessingMarkdown:NO];
    GBCommentsProcessor *processor1 = [GBCommentsProcessor processorWithSettingsProvider:settings1];
    GBComment *comment1 = [GBComment commentWithStringValue:@"[![alt info](http://foo/bar.blarg)](http://foo/bar.blip)"];
    id settings2 = [GBTestObjectsRegistry realSettingsProvider];
    [settings2 setEmbedCrossReferencesWhenProcessingMarkdown:YES];
    GBCommentsProcessor *processor2 = [GBCommentsProcessor processorWithSettingsProvider:settings2];
    GBComment *comment2 = [GBComment commentWithStringValue:@"[![alt info](http://foo/bar.blarg)](http://foo/bar.blip)"];
    // execute
    [processor1 processComment:comment1 withContext:nil store:store];
    [processor2 processComment:comment2 withContext:nil store:store];
    // verify
    XCTAssertEqualObjects(((GBCommentComponent *)(comment1.longDescription.components[0])).markdownValue, @"[![alt info](http://foo/bar.blarg)](http://foo/bar.blip)");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment2.longDescription.components[0])).markdownValue, @"~!@[![alt info](http://foo/bar.blarg)](http://foo/bar.blip)@!~");
}

- (void)testProcessCommentWithContextStore_markdown_shouldProperlyFormatMultipleNestedImageReferenceLinks {
    // setup
    GBStore *store = [self storeWithDefaultObjects];
    id settings1 = [GBTestObjectsRegistry realSettingsProvider];
    [settings1 setEmbedCrossReferencesWhenProcessingMarkdown:NO];
    GBCommentsProcessor *processor1 = [GBCommentsProcessor processorWithSettingsProvider:settings1];
    NSArray *rawStrings =
    @[@"[![Foo version](https://foo.io/bar/blarg%2blip.abc)](https://github.com/no%8body/Repo/releases)",
      @"[![Bar compatible](https://foo.io/bar/blargblip.abc?style=%20)](https://github.com/no%20body/empty%1)",
      @"[![Baz license](https://foo.io/bar/blargblip.abc)](https://raw.githubusercontent.com/no%20body/empty%1)"];
    NSString *raw = [rawStrings componentsJoinedByString:@" some text "];
    GBComment *comment1 = [GBComment commentWithStringValue:raw];
    id settings2 = [GBTestObjectsRegistry realSettingsProvider];
    [settings2 setEmbedCrossReferencesWhenProcessingMarkdown:YES];
    GBCommentsProcessor *processor2 = [GBCommentsProcessor processorWithSettingsProvider:settings2];
    GBComment *comment2 = [GBComment commentWithStringValue:raw];
    // execute
    [processor1 processComment:comment1 withContext:nil store:store];
    [processor2 processComment:comment2 withContext:nil store:store];
    // verify
    NSString *expected = raw;
    XCTAssertEqualObjects(((GBCommentComponent *)(comment1.longDescription.components[0])).markdownValue, expected);
    expected = [NSString stringWithFormat:@"~!@%@@!~", [rawStrings componentsJoinedByString:@"@!~ some text ~!@"]];
    XCTAssertEqualObjects(((GBCommentComponent *)(comment2.longDescription.components[0])).markdownValue, expected);
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
    XCTAssertEqualObjects(((GBCommentComponent *)(comment1.longDescription.components[0])).markdownValue, @"~!@[Class](Classes/Class.html)@!~");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment2.longDescription.components[0])).markdownValue, @"~!@[`Class`](Classes/Class.html)@!~");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment3.relatedItems.components[0])).markdownValue, @"~!@[Class](Classes/Class.html)@!~");
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
    XCTAssertEqualObjects(((GBCommentComponent *)(comment1.relatedItems.components[0])).markdownValue, @"[Class](Classes/Class.html)");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment2.relatedItems.components[0])).markdownValue, @"[Class(Category)](Categories/Class+Category.html)");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment3.relatedItems.components[0])).markdownValue, @"[Protocol](Protocols/Protocol.html)");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment4.relatedItems.components[0])).markdownValue, @"[Document](docs/Document.html)");
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
    XCTAssertEqualObjects(((GBCommentComponent *)(comment1.relatedItems.components[0])).markdownValue, @"[- instanceMethod:](#//api/name/instanceMethod:)");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment2.relatedItems.components[0])).markdownValue, @"[+ classMethod:](#//api/name/classMethod:)");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment3.relatedItems.components[0])).markdownValue, @"[@property value](#//api/name/value)");
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
    XCTAssertEqualObjects(((GBCommentComponent *)(comment1.relatedItems.components[0])).markdownValue, @"[[Class instanceMethod:]](Classes/Class.html#//api/name/instanceMethod:)");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment2.relatedItems.components[0])).markdownValue, @"[[Class classMethod:]](Classes/Class.html#//api/name/classMethod:)");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment3.relatedItems.components[0])).markdownValue, @"[[Class value]](Classes/Class.html#//api/name/value)");
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
    XCTAssertEqualObjects(((GBCommentComponent *)(comment.longDescription.components[0])).markdownValue, @"Some prefix [link1](address1) middle [link2](address2) and suffix");
}

- (void)testProcessCommentWithContextStore_markdown_shouldHandleSimpleLinksWithinMarkdownLinksProperly {
    // setup
    GBStore *store = [self storeWithDefaultObjects];
    GBCommentsProcessor *processor = [self defaultProcessor];
    GBComment *comment = [GBComment commentWithStringValue:@"[link1](address1) Document and [this class](Class) [link2](address2) longer suffix to make sure"];
    // execute
    [processor processComment:comment withContext:nil store:store];
    // verify
    XCTAssertEqualObjects(((GBCommentComponent *)(comment.longDescription.components[0])).markdownValue, @"[link1](address1) [Document](docs/Document.html) and [this class](Classes/Class.html) [link2](address2) longer suffix to make sure");
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
    XCTAssertEqualObjects(((GBCommentComponent *)(comment.longDescription.components[0])).markdownValue, @"[instanceMethod:](../Classes/Class.html#//api/name/instanceMethod:)");
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
    XCTAssertEqual(comment.longDescription.components.count, 0);
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
    
    XCTAssertEqual([comment.longDescription.components count], [expectations count]);
    for (NSUInteger i=0; i<[expectations count]; i++) {
        GBCommentComponent *component = comment.longDescription.components[i];
        NSString *expected = expectations[i];
        XCTAssertEqualObjects(component.markdownValue, expected);
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
    
    XCTAssertEqual([components.components count], [expectations count]);
    for (NSUInteger i=0; i<[expectations count]; i++) {
        GBCommentComponent *component = components.components[i];
        NSString *expected = expectations[i];
        XCTAssertEqualObjects(component.markdownValue, expected);
    }
}

@end
