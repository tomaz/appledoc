//
//  GBCommentsProcessor-RegistrationsTesting.m
//  appledocTests
//
//  Created by Jebeom Gyeong on 2/22/20.
//  Copyright © 2020 Gentle Bytes. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <OCMock/OCMockObject.h>

#import "GBApplicationSettingsProvider.h"
#import "GBDataObjects.h"
#import "GBStore.h"
#import "GBCommentsProcessor.h"
#import "GBTestObjectsRegistry.h"
#import "NSString+GBString.h"

@interface GBCommentsProcessor (PrivateAPI)
- (BOOL)findCommentBlockInLines:(NSArray *)lines blockRange:(NSRange *)range shortRange:(NSRange *)shortRange;
@end

@interface GBCommentsProcessor_RegistrationsTesting : XCTestCase

- (OCMockObject *)settingsProviderRepeatFirst:(BOOL)repeat;
- (void)assertFindCommentWithString:(NSString *)string matchesBlockRange:(NSRange)b shortRange:(NSRange)s;

@end

#pragma mark -

@implementation GBCommentsProcessor_RegistrationsTesting

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

#pragma mark Short & long descriptions testing

- (void)testProcessCommentWithContextStore_descriptions_shouldHandleTextOnlyBasedOnSettings {
    // setup
    GBStore *store = [GBTestObjectsRegistry store];
    GBCommentsProcessor *processor1 = [GBCommentsProcessor processorWithSettingsProvider:[self settingsProviderRepeatFirst:YES]];
    GBCommentsProcessor *processor2 = [GBCommentsProcessor processorWithSettingsProvider:[self settingsProviderRepeatFirst:NO]];
    GBComment *comment1 = [GBComment commentWithStringValue:@"Some text\n\nAnother paragraph"];
    GBComment *comment2 = [GBComment commentWithStringValue:comment1.stringValue];
    // execute
    [processor1 processComment:comment1 withContext:nil store:store];
    [processor2 processComment:comment2 withContext:nil store:store];
    // verify
    XCTAssertEqualObjects(comment1.shortDescription.stringValue, @"Some text");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment1.longDescription.components[0])).stringValue, @"Some text\n\nAnother paragraph");
    XCTAssertEqualObjects(comment2.shortDescription.stringValue, @"Some text");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment2.longDescription.components[0])).stringValue, @"Another paragraph");
}

- (void)testProcessCommentWithContextStore_descriptions_shouldHandleAllTextAsLongDescBasedOnFlagsRegardlessOnSettingsAndContext {
    // setup
    GBStore *store = [GBTestObjectsRegistry store];
    GBCommentsProcessor *processor1 = [GBCommentsProcessor processorWithSettingsProvider:[self settingsProviderRepeatFirst:YES]];
    GBCommentsProcessor *processor2 = [GBCommentsProcessor processorWithSettingsProvider:[self settingsProviderRepeatFirst:NO]];
    GBComment *comment1 = [GBComment commentWithStringValue:@"Some text\n\nAnother paragraph"];
    GBComment *comment2 = [GBComment commentWithStringValue:comment1.stringValue];
    // execute
    processor1.alwaysRepeatFirstParagraph = YES;
    [processor1 processComment:comment1 withContext:nil store:store];
    processor2.alwaysRepeatFirstParagraph = YES;
    [processor2 processComment:comment2 withContext:nil store:store];
    // verify
    XCTAssertEqualObjects(comment1.shortDescription.stringValue, @"Some text");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment1.longDescription.components[0])).stringValue, @"Some text\n\nAnother paragraph");
    XCTAssertEqualObjects(comment2.shortDescription.stringValue, @"Some text");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment2.longDescription.components[0])).stringValue, @"Some text\n\nAnother paragraph");
}

- (void)testProcessCommentWithContextStore_descriptions_shouldHandleTextBeforeDirectivesBasedOnSettings {
    // setup
    GBStore *store = [GBTestObjectsRegistry store];
    GBCommentsProcessor *processor1 = [GBCommentsProcessor processorWithSettingsProvider:[self settingsProviderRepeatFirst:YES]];
    GBCommentsProcessor *processor2 = [GBCommentsProcessor processorWithSettingsProvider:[self settingsProviderRepeatFirst:NO]];
    GBComment *comment1 = [GBComment commentWithStringValue:@"Some text\n\nAnother paragraph\n\n@warning Description"];
    GBComment *comment2 = [GBComment commentWithStringValue:comment1.stringValue];
    // execute
    [processor1 processComment:comment1 withContext:nil store:store];
    [processor2 processComment:comment2 withContext:nil store:store];
    // verify
    XCTAssertEqualObjects(comment1.shortDescription.stringValue, @"Some text");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment1.longDescription.components[0])).stringValue, @"Some text\n\nAnother paragraph");
    XCTAssertEqualObjects(comment2.shortDescription.stringValue, @"Some text");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment2.longDescription.components[0])).stringValue, @"Another paragraph");
}

- (void)testProcessCommentWithContextStore_descriptions_shouldHandleTextAfterDescriptionDirectiveRegardlessOfSettings {
    // setup
    GBStore *store = [GBTestObjectsRegistry store];
    GBCommentsProcessor *processor1 = [GBCommentsProcessor processorWithSettingsProvider:[self settingsProviderRepeatFirst:YES]];
    GBCommentsProcessor *processor2 = [GBCommentsProcessor processorWithSettingsProvider:[self settingsProviderRepeatFirst:NO]];
    GBComment *comment1 = [GBComment commentWithStringValue:@"@warning Some text\n\nAnother paragraph"];
    GBComment *comment2 = [GBComment commentWithStringValue:comment1.stringValue];
    // execute
    [processor1 processComment:comment1 withContext:nil store:store];
    [processor2 processComment:comment2 withContext:nil store:store];
    // verify - all text after directive is considered part of that directive, but short text is still properly detected.
    XCTAssertEqualObjects(comment1.shortDescription.stringValue, @"Some text");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment1.longDescription.components[0])).stringValue, @"@warning Some text\n\nAnother paragraph");
    XCTAssertEqualObjects(comment2.shortDescription.stringValue, @"Some text");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment2.longDescription.components[0])).stringValue, @"@warning Some text\n\nAnother paragraph");
}

- (void)testProcessCommentWithContextStore_descriptions_shouldHandleMultipleDescriptionDirectivesProperly {
    // setup
    GBStore *store = [GBTestObjectsRegistry store];
    GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
    GBComment *comment1 = [GBComment commentWithStringValue:@"@warning Paragraph 1.1\n\nParagraph 1.2\n\n@warning Paragraph 2.1\n\nParagraph 2.2"];
    GBComment *comment2 = [GBComment commentWithStringValue:@"@warning Warning\n\n@bug Bug"];
    GBComment *comment3 = [GBComment commentWithStringValue:@"@bug Bug\n\n@warning Warning"];
    // execute
    [processor processComment:comment1 withContext:nil store:store];
    [processor processComment:comment2 withContext:nil store:store];
    [processor processComment:comment3 withContext:nil store:store];
    // verify
    XCTAssertEqualObjects(comment1.shortDescription.stringValue, @"Paragraph 1.1");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment1.longDescription.components[0])).stringValue, @"@warning Paragraph 1.1\n\nParagraph 1.2");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment1.longDescription.components[1])).stringValue, @"@warning Paragraph 2.1\n\nParagraph 2.2");
    
    XCTAssertEqualObjects(comment2.shortDescription.stringValue, @"Warning");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment2.longDescription.components[0])).stringValue, @"@warning Warning");

    XCTAssertEqualObjects(comment3.shortDescription.stringValue, @"Bug");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment3.longDescription.components[0])).stringValue, @"@bug Bug");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment3.longDescription.components[1])).stringValue, @"@warning Warning");
}

- (void)testProcessCommentWithContextStore_descriptions_shouldHandleDescriptionForParamDirectiveRegardlessOfSettings {
    // setup
    GBStore *store = [GBTestObjectsRegistry store];
    GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
    GBComment *comment1 = [GBComment commentWithStringValue:@"@param name Description\n\nParagraph"];
    GBComment *comment2 = [GBComment commentWithStringValue:@"@param name Description\n\nParagraph\n\n@warning Warning"];
    GBComment *comment3 = [GBComment commentWithStringValue:@"@param name1 Description1\n@param name2 Description2"];
    GBComment *comment4 = [GBComment commentWithStringValue:@"Prefix\n\n@param name Description\n\nParagraph"];
    // execute
    [processor processComment:comment1 withContext:nil store:store];
    [processor processComment:comment2 withContext:nil store:store];
    [processor processComment:comment3 withContext:nil store:store];
    [processor processComment:comment4 withContext:nil store:store];
    // verify - we only use parameter description if there is nothing else found in the comment.
    XCTAssertEqualObjects(comment1.shortDescription.stringValue, @"Description");
    XCTAssertEqual(comment1.longDescription.components.count, 0);
    
    XCTAssertEqualObjects(comment2.shortDescription.stringValue, @"Warning");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment2.longDescription.components[0])).stringValue, @"@warning Warning");
    
    XCTAssertEqualObjects(comment3.shortDescription.stringValue, @"Description1");
    XCTAssertEqual(comment3.longDescription.components.count, 0);
    
    XCTAssertEqualObjects(comment4.shortDescription.stringValue, @"Prefix");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment4.longDescription.components[0])).stringValue, @"Prefix");
}

- (void)testProcessCommentWithContextStore_descriptions_shouldHandleDescriptionForExceptionDirectiveRegardlessOfSettings {
    // setup
    GBStore *store = [GBTestObjectsRegistry store];
    GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
    GBComment *comment1 = [GBComment commentWithStringValue:@"@exception name Description\n\nParagraph"];
    GBComment *comment2 = [GBComment commentWithStringValue:@"@exception name Description\n\nParagraph\n\n@warning Warning"];
    GBComment *comment3 = [GBComment commentWithStringValue:@"@exception name Description1\n@exception name2 Description2"];
    GBComment *comment4 = [GBComment commentWithStringValue:@"Prefix\n\n@exception name Description\n\nParagraph"];
    // execute
    [processor processComment:comment1 withContext:nil store:store];
    [processor processComment:comment2 withContext:nil store:store];
    [processor processComment:comment3 withContext:nil store:store];
    [processor processComment:comment4 withContext:nil store:store];
    // verify - we only use parameter description if there is nothing else found in the comment.
    XCTAssertEqualObjects(comment1.shortDescription.stringValue, @"Description");
    XCTAssertEqual(comment1.longDescription.components.count, 0);
    
    XCTAssertEqualObjects(comment2.shortDescription.stringValue, @"Warning");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment2.longDescription.components[0])).stringValue, @"@warning Warning");
    
    XCTAssertEqualObjects(comment3.shortDescription.stringValue, @"Description1");
    XCTAssertEqual(comment3.longDescription.components.count, 0);
    
    XCTAssertEqualObjects(comment4.shortDescription.stringValue, @"Prefix");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment4.longDescription.components[0])).stringValue, @"Prefix");
}

- (void)testProcessCommentWithContextStore_descriptions_shouldHandleDescriptionForReturnDirectiveRegardlessOfSettings {
    // setup
    GBStore *store = [GBTestObjectsRegistry store];
    GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
    GBComment *comment1 = [GBComment commentWithStringValue:@"@return Description\n\nParagraph"];
    GBComment *comment2 = [GBComment commentWithStringValue:@"@return Description\n\nParagraph\n\n@warning Warning"];
    GBComment *comment3 = [GBComment commentWithStringValue:@"Prefix\n\n@return Description\n\nParagraph"];
    // execute
    [processor processComment:comment1 withContext:nil store:store];
    [processor processComment:comment2 withContext:nil store:store];
    [processor processComment:comment3 withContext:nil store:store];
    // verify - we only use parameter description if there is nothing else found in the comment.
    XCTAssertEqualObjects(comment1.shortDescription.stringValue, @"Description");
    XCTAssertEqual(comment1.longDescription.components.count, 0);
    
    XCTAssertEqualObjects(comment2.shortDescription.stringValue, @"Warning");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment2.longDescription.components[0])).stringValue, @"@warning Warning");
    
    XCTAssertEqualObjects(comment3.shortDescription.stringValue, @"Prefix");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment3.longDescription.components[0])).stringValue, @"Prefix");
}

- (void)testProcessCommentWithContextStore_descriptions_shouldHandleRelatedSymbolsForReturnDirectiveRegardlessOfSettings {
    // setup
    GBStore *store = [GBTestObjectsRegistry store];
    GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
    GBComment *comment1 = [GBComment commentWithStringValue:@"@see Description\n\nParagraph"];
    GBComment *comment2 = [GBComment commentWithStringValue:@"@see Description\n\nParagraph\n\n@warning Warning"];
    GBComment *comment3 = [GBComment commentWithStringValue:@"Prefix\n\n@see Description\n\nParagraph"];
    // execute
    [processor processComment:comment1 withContext:nil store:store];
    [processor processComment:comment2 withContext:nil store:store];
    [processor processComment:comment3 withContext:nil store:store];
    // verify - we only use parameter description if there is nothing else found in the comment.
    XCTAssertEqualObjects(comment1.shortDescription.stringValue, @"Description");
    XCTAssertEqual(comment1.longDescription.components.count, 0);
    
    XCTAssertEqualObjects(comment2.shortDescription.stringValue, @"Warning");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment2.longDescription.components[0])).stringValue, @"@warning Warning");
    
    XCTAssertEqualObjects(comment3.shortDescription.stringValue, @"Prefix");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment3.longDescription.components[0])).stringValue, @"Prefix");
}

- (void)testProcessCommentWithContextStore_descriptions_shouldAssignSettingsToAllCommentComponents {
    // setup
    id settings = [GBTestObjectsRegistry realSettingsProvider];
    GBStore *store = [GBTestObjectsRegistry storeWithObjects:[GBClassData classDataWithName:@"Class"], nil];
    GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:settings];
    GBComment *comment = [GBComment commentWithStringValue:
                          @"Short\n\n"
                          @"Long\n\n"
                          @"@warning Warning\n\n"
                          @"@bug Bug\n\n"
                          @"@param name Desc\n"
                          @"@exception name Desc\n"
                          @"@return Desc"
                          @"@see Class"
                          @"@since Version 1.0"];
    // execute
    [processor processComment:comment withContext:nil store:store];
    // verify
    XCTAssertEqualObjects(comment.shortDescription.settings, settings);
    XCTAssertNotNil(comment.shortDescription.sourceInfo);
    for (GBCommentComponent *c in comment.longDescription.components) {
        XCTAssertEqualObjects(c.settings, settings);
        XCTAssertNotNil(c.sourceInfo);
    }
    for (GBCommentArgument *a in comment.methodParameters) {
        for (GBCommentComponent *c in a.argumentDescription.components) {
            XCTAssertEqualObjects(c.settings, settings);
            XCTAssertNotNil(c.sourceInfo);
        }
    }
    for (GBCommentArgument *a in comment.methodExceptions) {
        for (GBCommentComponent *c in a.argumentDescription.components) {
            XCTAssertEqualObjects(c.settings, settings);
            XCTAssertNotNil(c.sourceInfo);
        }
    }
    for (GBCommentComponent *c in comment.methodResult.components) {
        XCTAssertEqualObjects(c.settings, settings);
        XCTAssertNotNil(c.sourceInfo);
    }
    for (GBCommentComponent *c in comment.relatedItems.components) {
        XCTAssertEqualObjects(c.settings, settings);
        XCTAssertNotNil(c.sourceInfo);
    }
    for (GBCommentComponent *c in comment.availability.components) {
        XCTAssertEqualObjects(c.settings, settings);
        XCTAssertNotNil(c.sourceInfo);
    }
}

#pragma mark Method data testing

- (void)testProcessCommentWithContextStore_methods_shouldRegisterAllParametersDescriptionsProperly {
    // setup
    GBStore *store = [GBTestObjectsRegistry store];
    GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
    GBComment *comment = [GBComment commentWithStringValue:@"@param name1 Description1\nLine2\n\nParagraph2\n@param name2 Description2"];
    // execute
    [processor processComment:comment withContext:nil store:store];
    // verify - we only use parameter description if there is nothing else found in the comment.
    XCTAssertEqualObjects(((GBCommentArgument *)comment.methodParameters[0]).argumentName, @"name1");
    XCTAssertEqualObjects(((GBCommentComponent *)(((GBCommentArgument *)comment.methodParameters[0]).argumentDescription.components[0])).stringValue, @"Description1\nLine2\n\nParagraph2");
    
    XCTAssertEqualObjects(((GBCommentArgument *)comment.methodParameters[1]).argumentName, @"name2");
    XCTAssertEqualObjects(((GBCommentComponent *)(((GBCommentArgument *)comment.methodParameters[1]).argumentDescription.components[0])).stringValue, @"Description2");
}

- (void)testProcessCommentWithContextStore_methods_shouldRegisterAllParametersRegardlessOfEmptyLinesGaps {
    // setup
    GBStore *store = [GBTestObjectsRegistry store];
    GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
    GBComment *comment1 = [GBComment commentWithStringValue:@"@param name1 Description1\n@param name2 Description2"];
    GBComment *comment2 = [GBComment commentWithStringValue:@"@param name1 Description1\n\n\n\n\n\n@param name2 Description2"];
    // execute
    [processor processComment:comment1 withContext:nil store:store];
    [processor processComment:comment2 withContext:nil store:store];
    // verify - we only use parameter description if there is nothing else found in the comment.
    XCTAssertEqualObjects(((GBCommentArgument *)comment1.methodParameters[0]).argumentName, @"name1");
    XCTAssertEqualObjects(((GBCommentComponent *)(((GBCommentArgument *)comment1.methodParameters[0]).argumentDescription.components[0])).stringValue, @"Description1");
    
    XCTAssertEqualObjects(((GBCommentArgument *)comment1.methodParameters[1]).argumentName, @"name2");
    XCTAssertEqualObjects(((GBCommentComponent *)(((GBCommentArgument *)comment1.methodParameters[1]).argumentDescription.components[0])).stringValue, @"Description2");
    
    XCTAssertEqualObjects(((GBCommentArgument *)comment2.methodParameters[0]).argumentName, @"name1");
    XCTAssertEqualObjects(((GBCommentComponent *)(((GBCommentArgument *)comment2.methodParameters[0]).argumentDescription.components[0])).stringValue, @"Description1");
    
    XCTAssertEqualObjects(((GBCommentArgument *)comment2.methodParameters[1]).argumentName, @"name2");
    XCTAssertEqualObjects(((GBCommentComponent *)(((GBCommentArgument *)comment2.methodParameters[1]).argumentDescription.components[0])).stringValue, @"Description2");
}

- (void)testProcessCommentWithContextStore_methods_shouldRegisterAllExceptionsRegardlessOfEmptyLinesGaps {
    // setup
    GBStore *store = [GBTestObjectsRegistry store];
    GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
    GBComment *comment1 = [GBComment commentWithStringValue:@"@exception name1 Description1\n@exception name2 Description2"];
    GBComment *comment2 = [GBComment commentWithStringValue:@"@exception name1 Description1\n\n\n\n\n\n@exception name2 Description2"];
    // execute
    [processor processComment:comment1 withContext:nil store:store];
    [processor processComment:comment2 withContext:nil store:store];
    // verify - we only use parameter description if there is nothing else found in the comment.
    XCTAssertEqualObjects(((GBCommentArgument *)comment1.methodExceptions[0]).argumentName, @"name1");
    XCTAssertEqualObjects(((GBCommentComponent *)(((GBCommentArgument *)comment1.methodExceptions[0]).argumentDescription.components[0])).stringValue, @"Description1");
    
    XCTAssertEqualObjects(((GBCommentArgument *)comment2.methodExceptions[0]).argumentName, @"name1");
    XCTAssertEqualObjects(((GBCommentComponent *)(((GBCommentArgument *)comment2.methodExceptions[0]).argumentDescription.components[0])).stringValue, @"Description1");
}

- (void)testProcessCommentWithContextStore_methods_shouldRegisterResultDescriptionProperly {
    // setup
    GBStore *store = [GBTestObjectsRegistry store];
    GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
    GBComment *comment1 = [GBComment commentWithStringValue:@"@return Description"];
    GBComment *comment2 = [GBComment commentWithStringValue:@"@return Description1\nLine2\n\nParagraph2"];
    // execute
    [processor processComment:comment1 withContext:nil store:store];
    [processor processComment:comment2 withContext:nil store:store];
    // verify - we only use parameter description if there is nothing else found in the comment.
    XCTAssertEqualObjects(((GBCommentComponent *)(comment1.methodResult.components[0])).stringValue, @"Description");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment2.methodResult.components[0])).stringValue, @"Description1\nLine2\n\nParagraph2");
}

- (void)testProcessCommentWithContextStore_methods_shouldRegisterAvailabilityDescriptionProperly {
    // setup
    GBStore *store = [GBTestObjectsRegistry store];
    GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
    GBComment *comment1 = [GBComment commentWithStringValue:@"@since Description"];
    GBComment *comment2 = [GBComment commentWithStringValue:@"@available Description1\nLine2\n\nParagraph2"];
    // execute
    [processor processComment:comment1 withContext:nil store:store];
    [processor processComment:comment2 withContext:nil store:store];
    // verify - we only use parameter description if there is nothing else found in the comment.
    XCTAssertEqualObjects(((GBCommentComponent *)(comment1.availability.components[0])).stringValue, @"Description");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment2.availability.components[0])).stringValue, @"Description1\nLine2\n\nParagraph2");
}

#pragma mark Common directives testing

- (void)testProcessCommentWithContextStore_directives_shouldRegisterRelatedItemsForKnownTopLevelObjects {
    // setup
    GBClassData *class = [GBClassData classDataWithName:@"Class"];
    GBCategoryData *category = [GBCategoryData categoryDataWithName:@"Category" className:@"Class"];
    GBProtocolData *protocol = [GBProtocolData protocolDataWithName:@"Protocol"];
    GBStore *store = [GBTestObjectsRegistry storeWithObjects:class, category, protocol, nil];
    GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
    GBComment *comment1 = [GBComment commentWithStringValue:@"@see Class"];
    GBComment *comment2 = [GBComment commentWithStringValue:@"@see Class(Category)"];
    GBComment *comment3 = [GBComment commentWithStringValue:@"@see Protocol"];
    GBComment *comment4 = [GBComment commentWithStringValue:@"@see Unknown"];
    // execute
    [processor processComment:comment1 withContext:nil store:store];
    [processor processComment:comment2 withContext:nil store:store];
    [processor processComment:comment3 withContext:nil store:store];
    [processor processComment:comment4 withContext:nil store:store];
    // verify - we only use parameter description if there is nothing else found in the comment.
    XCTAssertEqualObjects(((GBCommentComponent *)(comment1.relatedItems.components[0])).stringValue, @"Class");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment2.relatedItems.components[0])).stringValue, @"Class(Category)");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment3.relatedItems.components[0])).stringValue, @"Protocol");
    XCTAssertEqual(comment4.relatedItems.components.count, 0);
}

- (void)testProcessCommentWithContextStore_directives_shouldRegisterRelatedItemsForKnownDocuments {
    // setup
    GBDocumentData *document1 = [GBDocumentData documentDataWithContents:@"c" path:@"Document1.html"];
    GBDocumentData *document2 = [GBDocumentData documentDataWithContents:@"c" path:@"Document2.html"];
    GBStore *store = [GBTestObjectsRegistry storeWithObjects:document1, document2, nil];
    GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
    GBComment *comment1 = [GBComment commentWithStringValue:@"@see Document1"];
    GBComment *comment2 = [GBComment commentWithStringValue:@"@see Document2"];
    GBComment *comment3 = [GBComment commentWithStringValue:@"@see Unknown"];
    // execute
    [processor processComment:comment1 withContext:nil store:store];
    [processor processComment:comment2 withContext:nil store:store];
    [processor processComment:comment3 withContext:nil store:store];
    // verify - we only use parameter description if there is nothing else found in the comment.
    XCTAssertEqualObjects(((GBCommentComponent *)(comment1.relatedItems.components[0])).stringValue, @"Document1");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment2.relatedItems.components[0])).stringValue, @"Document2");
    XCTAssertEqual(comment3.relatedItems.components.count, 0);
}

- (void)testProcessCommentWithContextStore_directives_shouldRegisterRelatedItemsForKnownLocalMembers {
    // setup
    GBClassData *class = [GBTestObjectsRegistry classWithName:@"Class" methods:[GBTestObjectsRegistry instanceMethodWithNames:@"method", nil], nil];
    GBStore *store = [GBTestObjectsRegistry storeWithObjects:class, nil];
    GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
    GBComment *comment1 = [GBComment commentWithStringValue:@"@see method:"];
    GBComment *comment2 = [GBComment commentWithStringValue:@"@see unknown:"];
    // execute
    [processor processComment:comment1 withContext:class store:store];
    [processor processComment:comment2 withContext:class store:store];
    // verify - we only use parameter description if there is nothing else found in the comment.
    XCTAssertEqualObjects(((GBCommentComponent *)(comment1.relatedItems.components[0])).stringValue, @"method:");
    XCTAssertEqual(comment2.relatedItems.components.count, 0);
}

- (void)testProcessCommentWithContextStore_directives_shouldRegisterRelatedItemsForKnownRemoteMembers {
    // setup
    GBClassData *class = [GBTestObjectsRegistry classWithName:@"Class" methods:[GBTestObjectsRegistry instanceMethodWithNames:@"method", nil], nil];
    GBStore *store = [GBTestObjectsRegistry storeWithObjects:class, nil];
    GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
    GBComment *comment1 = [GBComment commentWithStringValue:@"@see [Class method:]"];
    GBComment *comment2 = [GBComment commentWithStringValue:@"@see [Class unknown:]"];
    GBComment *comment3 = [GBComment commentWithStringValue:@"@see [Unknown method:]"];
    // execute
    [processor processComment:comment1 withContext:nil store:store];
    [processor processComment:comment2 withContext:nil store:store];
    [processor processComment:comment3 withContext:nil store:store];
    // verify - we only use parameter description if there is nothing else found in the comment.
    XCTAssertEqualObjects(((GBCommentComponent *)(comment1.relatedItems.components[0])).stringValue, @"[Class method:]");
    XCTAssertEqual(comment2.relatedItems.components.count, 0);
    XCTAssertEqual(comment3.relatedItems.components.count, 0);
}

#pragma mark Combinations testing

- (void)testProcessCommentWithContextStore_combinations_shouldRegisterMethodDescriptionBlock {
    // setup
    GBStore *store = [GBTestObjectsRegistry store];
    GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
    GBComment *comment = [GBComment commentWithStringValue:
                          @"@param name1 Description1\nLine2\n\nParagraph2\n"
                          @"@exception exc Exception\n"
                          @"@param name2 Description2\n"
                          @"@return Return\n"
                          @"@param name3 Description3\n"
                          @"@since Version 1.0\n"];
    // execute
    [processor processComment:comment withContext:nil store:store];
    // verify - we only use parameter description if there is nothing else found in the comment.
    XCTAssertEqualObjects(((GBCommentArgument *)(comment.methodParameters[0])).argumentName, @"name1");
    XCTAssertEqualObjects(((GBCommentComponent *)(((GBCommentArgument *)(comment.methodParameters[0])).argumentDescription.components[0])).stringValue, @"Description1\nLine2\n\nParagraph2");
    XCTAssertEqualObjects(((GBCommentArgument *)(comment.methodParameters[1])).argumentName, @"name2");
    XCTAssertEqualObjects(((GBCommentComponent *)(((GBCommentArgument *)(comment.methodParameters[1])).argumentDescription.components[0])).stringValue, @"Description2");
    XCTAssertEqualObjects(((GBCommentArgument *)(comment.methodParameters[2])).argumentName, @"name3");
    XCTAssertEqualObjects(((GBCommentComponent *)(((GBCommentArgument *)(comment.methodParameters[2])).argumentDescription.components[0])).stringValue, @"Description3");
    XCTAssertEqualObjects(((GBCommentArgument *)(comment.methodExceptions[0])).argumentName, @"exc");
    XCTAssertEqualObjects(((GBCommentComponent *)(((GBCommentArgument *)(comment.methodExceptions[0])).argumentDescription.components[0])).stringValue, @"Exception");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment.methodResult.components[0])).stringValue, @"Return");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment.availability.components[0])).stringValue, @"Version 1.0");
}

- (void)testProcessCommentWithContextStore_combinations_shouldRegisterWarningAfterMethodBlockAsMainDescription {
    // setup
    GBStore *store = [GBTestObjectsRegistry store];
    GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
    GBComment *comment1 = [GBComment commentWithStringValue:@"@param name Description\n@warning Warning"];
    GBComment *comment2 = [GBComment commentWithStringValue:@"@exception name Description\n@warning Warning"];
    GBComment *comment3 = [GBComment commentWithStringValue:@"@return Description\n@warning Warning"];
    GBComment *comment4 = [GBComment commentWithStringValue:@"@since Description\n@warning Warning"];
    // execute
    [processor processComment:comment1 withContext:nil store:store];
    [processor processComment:comment2 withContext:nil store:store];
    [processor processComment:comment3 withContext:nil store:store];
    [processor processComment:comment4 withContext:nil store:store];
    // verify - we only use parameter description if there is nothing else found in the comment.
    XCTAssertEqualObjects(((GBCommentArgument *)comment1.methodParameters[0]).argumentName, @"name");
    XCTAssertEqualObjects(((GBCommentComponent *)(((GBCommentArgument *)comment1.methodParameters[0]).argumentDescription.components[0])).stringValue, @"Description");

    XCTAssertEqualObjects(((GBCommentArgument *)comment2.methodExceptions[0]).argumentName, @"name");
    XCTAssertEqualObjects(((GBCommentComponent *)(((GBCommentArgument *)comment2.methodExceptions[0]).argumentDescription.components[0])).stringValue, @"Description");
    
    XCTAssertEqualObjects(((GBCommentComponent *)(comment3.methodResult.components[0])).stringValue, @"Description");
    
    XCTAssertEqualObjects(((GBCommentComponent *)(comment4.availability.components[0])).stringValue, @"Description");
    
    XCTAssertEqualObjects(comment1.shortDescription.stringValue, @"Warning");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment1.longDescription.components[0])).stringValue, @"@warning Warning");
    
    XCTAssertEqualObjects(comment2.shortDescription.stringValue, @"Warning");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment2.longDescription.components[0])).stringValue, @"@warning Warning");
    
    XCTAssertEqualObjects(comment3.shortDescription.stringValue, @"Warning");
    XCTAssertEqualObjects(((GBCommentComponent *)(comment3.longDescription.components[0])).stringValue, @"@warning Warning");
    
    XCTAssertEqualObjects(comment4.shortDescription.stringValue, @"Warning");
     XCTAssertEqualObjects(((GBCommentComponent *)(comment4.longDescription.components[0])).stringValue, @"@warning Warning");
}

#pragma mark Miscellaneous handling

- (void)testProcessCommentWithContextStore_misc_shouldSetIsProcessed {
    // setup
    GBStore *store = [GBTestObjectsRegistry store];
    GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
    GBComment *comment = [GBComment commentWithStringValue:@""];
    // execute
    [processor processComment:comment withContext:nil store:store];
    // verify
    XCTAssertTrue(comment.isProcessed);
}

#pragma mark Private methods testing

- (void)testFindCommentBlockInLinesBlockRangeShortRange_shouldDetectSingleComponent {
    [self assertFindCommentWithString:@"line" matchesBlockRange:NSMakeRange(0, 1) shortRange:NSMakeRange(0, 1)];
    [self assertFindCommentWithString:@"line1\nline2" matchesBlockRange:NSMakeRange(0, 2) shortRange:NSMakeRange(0, 2)];
    [self assertFindCommentWithString:@"para1\n\npara" matchesBlockRange:NSMakeRange(0, 3) shortRange:NSMakeRange(0, 1)];
    [self assertFindCommentWithString:@"para1\n\npara2\n\npara3" matchesBlockRange:NSMakeRange(0, 5) shortRange:NSMakeRange(0, 1)];
}

- (void)testFindCommentBlockInLinesBlockRangeShortRange_shouldDetectSingleComponentUpToDirective {
    [self assertFindCommentWithString:@"line\n@warning desc" matchesBlockRange:NSMakeRange(0, 1) shortRange:NSMakeRange(0, 1)];
    [self assertFindCommentWithString:@"line\n\n@warning desc" matchesBlockRange:NSMakeRange(0, 2) shortRange:NSMakeRange(0, 1)];
    [self assertFindCommentWithString:@"para1\n\npara2\n@warning desc" matchesBlockRange:NSMakeRange(0, 3) shortRange:NSMakeRange(0, 1)];
    [self assertFindCommentWithString:@"para1\n\npara2\n\n@warning desc" matchesBlockRange:NSMakeRange(0, 4) shortRange:NSMakeRange(0, 1)];
}

- (void)testFindCommentBlockInLinesBlockRangeShortRange_shouldDetectDirectiveComponentUpToEndOfLines {
    [self assertFindCommentWithString:@"@warning desc" matchesBlockRange:NSMakeRange(0, 1) shortRange:NSMakeRange(0, 1)];
    [self assertFindCommentWithString:@"@warning line1\nline2" matchesBlockRange:NSMakeRange(0, 2) shortRange:NSMakeRange(0, 2)];
    [self assertFindCommentWithString:@"@warning para1\n\npara2" matchesBlockRange:NSMakeRange(0, 3) shortRange:NSMakeRange(0, 1)];
}

- (void)testFindCommentBlockInLinesBlockRangeShortRange_shouldDetectDirectiveComponentUpToNextDirective {
    [self assertFindCommentWithString:@"@warning desc\n@warning next" matchesBlockRange:NSMakeRange(0, 1) shortRange:NSMakeRange(0, 1)];
    [self assertFindCommentWithString:@"@warning desc\n\n@warning next" matchesBlockRange:NSMakeRange(0, 2) shortRange:NSMakeRange(0, 1)];
    [self assertFindCommentWithString:@"@warning line1\nline2\n@warning next" matchesBlockRange:NSMakeRange(0, 2) shortRange:NSMakeRange(0, 2)];
    [self assertFindCommentWithString:@"@warning line1\nline2\n\n@warning next" matchesBlockRange:NSMakeRange(0, 3) shortRange:NSMakeRange(0, 2)];
    [self assertFindCommentWithString:@"@warning para1\n\npara2\n@warning next" matchesBlockRange:NSMakeRange(0, 3) shortRange:NSMakeRange(0, 1)];
    [self assertFindCommentWithString:@"@warning para1\n\npara2\n\n@warning next" matchesBlockRange:NSMakeRange(0, 4) shortRange:NSMakeRange(0, 1)];
}

- (void)testFindCommentBlockInLinesBlockRangeShortRange_shouldStopAtAnyDirective {
    NSRange blockRange = NSMakeRange(0, 1);
    NSRange shortRange = NSMakeRange(0, 1);
    [self assertFindCommentWithString:@"line\n@warning desc" matchesBlockRange:blockRange shortRange:shortRange];
    [self assertFindCommentWithString:@"line\n@bug desc" matchesBlockRange:blockRange shortRange:shortRange];
    [self assertFindCommentWithString:@"line\n@param name desc" matchesBlockRange:blockRange shortRange:shortRange];
    [self assertFindCommentWithString:@"line\n@return desc" matchesBlockRange:blockRange shortRange:shortRange];
    [self assertFindCommentWithString:@"line\n@returns desc" matchesBlockRange:blockRange shortRange:shortRange];
    [self assertFindCommentWithString:@"line\n@exception name desc" matchesBlockRange:blockRange shortRange:shortRange];
    [self assertFindCommentWithString:@"line\n@see desc" matchesBlockRange:blockRange shortRange:shortRange];
    [self assertFindCommentWithString:@"line\n@sa desc" matchesBlockRange:blockRange shortRange:shortRange];
}

#pragma Creation & assertion methods

- (OCMockObject *)settingsProviderRepeatFirst:(BOOL)repeat {
    OCMockObject *result = [GBTestObjectsRegistry mockSettingsProvider];
    [[[result stub] andReturnValue:@(repeat)] repeatFirstParagraphForMemberDescription];
    return result;
}

- (void)assertFindCommentWithString:(NSString *)string matchesBlockRange:(NSRange)b shortRange:(NSRange)s {
    // setup
    GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
    // execute
    NSRange blockRange = NSMakeRange(0, 0);
    NSRange shortRange = NSMakeRange(0, 0);
    [processor findCommentBlockInLines:[string arrayOfLines] blockRange:&blockRange shortRange:&shortRange];
    // verify
    XCTAssertEqual(blockRange.location, b.location);
    XCTAssertEqual(blockRange.length, b.length);
    XCTAssertEqual(shortRange.location, s.location);
    XCTAssertEqual(shortRange.length, s.length);
}

@end
