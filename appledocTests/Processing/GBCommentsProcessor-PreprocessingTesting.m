//
//  GBCommentsProcessor-PreprocessingTesting.m
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

@interface GBCommentsProcessor (PrivateAPI)
- (NSString *)stringByPreprocessingString:(NSString *)string withFlags:(NSUInteger)flags;
- (NSString *)stringByConvertingCrossReferencesInString:(NSString *)string withFlags:(NSUInteger)flags;
@end

#pragma mark -

@interface GBCommentsProcessor_PreprocessingTesting : XCTestCase

- (GBCommentsProcessor *)defaultProcessor;
- (GBCommentsProcessor *)processorWithStore:(id)store;
- (GBCommentsProcessor *)processorWithStore:(id)store context:(id)context;

@end

@implementation GBCommentsProcessor_PreprocessingTesting

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

#pragma mark Formatting markers conversion

- (void)testStringByPreprocessingString_shouldConvertAppledocBoldMarkersToTemporarySyntaxIfRequested {
    // setup
    id settings = [GBTestObjectsRegistry realSettingsProvider];
    [settings setEmbedCrossReferencesWhenProcessingMarkdown:NO];
    [settings setUseSingleStarForBold:YES];
    GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:settings];
    // execute
    NSString *result1 = [processor stringByPreprocessingString:@"*bold1* *bold text* * bolder text *" withFlags:0];
    NSString *result2 = [processor stringByPreprocessingString:@"*bold1* Middle *bold text*" withFlags:0];
    // verify
    XCTAssertEqualObjects(result1, @"**~!$bold1$!~** **~!$bold text$!~** **~!$ bolder text $!~**");
    XCTAssertEqualObjects(result2, @"**~!$bold1$!~** Middle **~!$bold text$!~**");
}

- (void)testStringByPreprocessingString_shouldNotConvertAppledocBoldMarkersToTemporarySyntaxIfPrevented {
    // setup
    id settings = [GBTestObjectsRegistry realSettingsProvider];
    [settings setEmbedCrossReferencesWhenProcessingMarkdown:NO];
    [settings setUseSingleStarForBold:NO];
    GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:settings];
    // execute
    NSString *result1 = [processor stringByPreprocessingString:@"*bold1* *bold text* * bolder text *" withFlags:0];
    NSString *result2 = [processor stringByPreprocessingString:@"*bold1* Middle *bold text*" withFlags:0];
    // verify
    XCTAssertEqualObjects(result1, @"*bold1* *bold text* * bolder text *");
    XCTAssertEqualObjects(result2, @"*bold1* Middle *bold text*");
}

- (void)testStringByPreprocessingString_shouldLeaveItalicsMarkers {
    // setup
    GBCommentsProcessor *processor = [self defaultProcessor];
    // execute
    NSString *result1 = [processor stringByPreprocessingString:@"_bold1_ _bold text_ _ bolder text _" withFlags:0];
    NSString *result2 = [processor stringByPreprocessingString:@"_bold1_ Middle _bold text_" withFlags:0];
    // verify
    XCTAssertEqualObjects(result1, @"_bold1_ _bold text_ _ bolder text _");
    XCTAssertEqualObjects(result2, @"_bold1_ Middle _bold text_");
}

- (void)testStringByPreprocessingString_shouldLeaveBoldItalicsMarkers {
    // setup
    GBCommentsProcessor *processor = [self defaultProcessor];
    // execute
    NSString *result = [processor stringByPreprocessingString:@"_*text1*_ *_marked text_* _* text2 *_" withFlags:0];
    // verify
    XCTAssertEqualObjects(result, @"_*text1*_ *_marked text_* _* text2 *_");
}

- (void)testStringByPreprocessingString_shouldHandleMonospaceMarkers {
    // setup
    GBCommentsProcessor *processor = [self defaultProcessor];
    // execute
    NSString *result = [processor stringByPreprocessingString:@"`mono` ` monoer `" withFlags:0];
    // verify
    XCTAssertEqualObjects(result, @"`mono` ` monoer `");
}

- (void)testStringByPreprocessingString_shouldHandleMarkdownBoldMarkers {
    // setup
    GBCommentsProcessor *processor = [self defaultProcessor];
    // execute
    NSString *result1 = [processor stringByPreprocessingString:@"__text1__ __ marked __" withFlags:0];
    NSString *result2 = [processor stringByPreprocessingString:@"**text1** ** marked **" withFlags:0];
    // verify
    XCTAssertEqualObjects(result1, @"__text1__ __ marked __");
    XCTAssertEqualObjects(result2, @"**text1** ** marked **");
}

- (void)testStringByPreprocessingString_shouldLeaveMarkdownBoldItalicsMarkers {
    // setup
    GBCommentsProcessor *processor = [self defaultProcessor];
    // execute
    NSString *result1 = [processor stringByPreprocessingString:@"__*text1*__ __* marked *__" withFlags:0];
    NSString *result2 = [processor stringByPreprocessingString:@"_**text1**_ _** marked **_" withFlags:0];
    NSString *result3 = [processor stringByPreprocessingString:@"*__text1__* *__ marked __*" withFlags:0];
    NSString *result4 = [processor stringByPreprocessingString:@"**_text1_** **_ marked _**" withFlags:0];
    NSString *result5 = [processor stringByPreprocessingString:@"___text1___ ___ marked ___" withFlags:0];
    NSString *result6 = [processor stringByPreprocessingString:@"***text1*** *** marked ***" withFlags:0];
    // verify
    XCTAssertEqualObjects(result1, @"__*text1*__ __* marked *__");
    XCTAssertEqualObjects(result2, @"_**text1**_ _** marked **_");
    XCTAssertEqualObjects(result3, @"*__text1__* *__ marked __*");
    XCTAssertEqualObjects(result4, @"**_text1_** **_ marked _**");
    XCTAssertEqualObjects(result5, @"___text1___ ___ marked ___");
    XCTAssertEqualObjects(result6, @"***text1*** *** marked ***");
}

- (void)testStringByPreprocessingString_shouldKeepReferencesWithMarkersIntact {
    // setup
    GBCommentsProcessor *processor = [self defaultProcessor];
    // execute
    NSString *result = [processor stringByPreprocessingString:@"[test_test](http://www.example.com/test_test.html)" withFlags:0];
    NSString *result2 = [processor stringByPreprocessingString:@"![test_test](http://www.example.com/test_test.html)" withFlags:0];
    // verify
    XCTAssertEqualObjects(result, @"[test_test](http://www.example.com/test_test.html)");
    XCTAssertEqualObjects(result2, @"![test_test](http://www.example.com/test_test.html)");
}

- (void)testStringByPreprocessingString_shouldConvertCodeBlockToMarkdownBackticks {
    // setup
    GBCommentsProcessor *processor = [self defaultProcessor];
    // execute
    NSString *result = [processor stringByPreprocessingString:@"\n  @code  \n[self doSomething];\n  @endcode  \n" withFlags:0];
    // verify
    XCTAssertEqualObjects(result, @"\n```\n[self doSomething];\n```\n");
}

- (void)testStringByPreprocessingString_shouldConvertTildeCodeBlockToMarkdownBackticks {
    // setup
    GBCommentsProcessor *processor = [self defaultProcessor];
    // execute
    NSString *result = [processor stringByPreprocessingString:@"\n  ~~~  \n[self doSomething];\n  ~~~  \n" withFlags:0];
    // verify
    XCTAssertEqualObjects(result, @"\n```\n[self doSomething];\n```\n");
}

- (void)testStringByPreprocessingString_shouldConvertBacktickCodeBlockToMarkdownBackticks {
    // setup
    GBCommentsProcessor *processor = [self defaultProcessor];
    // execute
    NSString *result = [processor stringByPreprocessingString:@"\n  ```  \n[self doSomething];\n  ```  \n" withFlags:0];
    // verify
    XCTAssertEqualObjects(result, @"\n```\n[self doSomething];\n```\n");
}

- (void)testStringByPreprocessingString_shouldConvertMultipleCodeBlocksToMarkdownBackticks {
    // setup
    GBCommentsProcessor *processor = [self defaultProcessor];
    NSString *raw = @"\n  @code  \n[self doSomething];\n  @endcode  \n\n  @code  \n[self doSomething];\n  @endcode  \n";
    NSString *expected = @"\n```\n[self doSomething];\n```\n\n```\n[self doSomething];\n```\n";
    // execute
    NSString *result = [processor stringByPreprocessingString:raw withFlags:0];
    // verify
    XCTAssertEqualObjects(result, expected);
}

#pragma mark Class, category and protocol cross references detection

- (void)testStringByConvertingCrossReferencesInString_shouldConvertClass {
    // setup
    GBStore *store = [GBTestObjectsRegistry storeWithObjects:[GBClassData classDataWithName:@"Class"], nil];
    GBCommentsProcessor *processor = [self processorWithStore:store];
    // execute
    NSString *result1 = [processor stringByConvertingCrossReferencesInString:@"Class" withFlags:0];
    NSString *result2 = [processor stringByConvertingCrossReferencesInString:@"<Class>" withFlags:0];
    NSString *result3 = [processor stringByConvertingCrossReferencesInString:@"Unknown" withFlags:0];
    NSString *result4 = [processor stringByConvertingCrossReferencesInString:@"<Unknown>" withFlags:0];
    // verify
    XCTAssertEqualObjects(result1, @"[Class](Classes/Class.html)");
    XCTAssertEqualObjects(result2, @"[Class](Classes/Class.html)");
    XCTAssertEqualObjects(result3, @"Unknown");
    XCTAssertEqualObjects(result4, @"<Unknown>");
}

- (void)testStringByConvertingCrossReferencesInString_shouldConvertCategory {
    // setup
    GBStore *store = [GBTestObjectsRegistry storeWithObjects:[GBCategoryData categoryDataWithName:@"Category" className:@"Class"], nil];
    GBCommentsProcessor *processor = [self processorWithStore:store];
    // execute
    NSString *result1 = [processor stringByConvertingCrossReferencesInString:@"Class(Category)" withFlags:0];
    NSString *result2 = [processor stringByConvertingCrossReferencesInString:@"<Class(Category)>" withFlags:0];
    NSString *result3 = [processor stringByConvertingCrossReferencesInString:@"Class(Unknown)" withFlags:0];
    NSString *result4 = [processor stringByConvertingCrossReferencesInString:@"<Class(Unknown)>" withFlags:0];
    // verify
    XCTAssertEqualObjects(result1, @"[Class(Category)](Categories/Class+Category.html)");
    XCTAssertEqualObjects(result2, @"[Class(Category)](Categories/Class+Category.html)");
    XCTAssertEqualObjects(result3, @"Class(Unknown)");
    XCTAssertEqualObjects(result4, @"<Class(Unknown)>");
}

- (void)testStringByConvertingCrossReferencesInString_shouldConvertProtocol {
    // setup
    GBStore *store = [GBTestObjectsRegistry storeWithObjects:[GBProtocolData protocolDataWithName:@"Protocol"], nil];
    GBCommentsProcessor *processor = [self processorWithStore:store];
    // execute
    NSString *result1 = [processor stringByConvertingCrossReferencesInString:@"Protocol" withFlags:0];
    NSString *result2 = [processor stringByConvertingCrossReferencesInString:@"<Protocol>" withFlags:0];
    NSString *result3 = [processor stringByConvertingCrossReferencesInString:@"Unknown" withFlags:0];
    NSString *result4 = [processor stringByConvertingCrossReferencesInString:@"<Unknown>" withFlags:0];
    // verify
    XCTAssertEqualObjects(result1, @"[Protocol](Protocols/Protocol.html)");
    XCTAssertEqualObjects(result2, @"[Protocol](Protocols/Protocol.html)");
    XCTAssertEqualObjects(result3, @"Unknown");
    XCTAssertEqualObjects(result4, @"<Unknown>");
}

#pragma mark Local members cross references detection

- (void)testStringByConvertingCrossReferencesInString_shouldConvertClassLocalInstanceMethod {
    // setup
    GBClassData *class = [GBTestObjectsRegistry classWithName:@"Class" methods:[GBTestObjectsRegistry instanceMethodWithNames:@"method", nil], nil];
    GBStore *store = [GBTestObjectsRegistry storeWithObjects:class, nil];
    GBCommentsProcessor *processor = [self processorWithStore:store context:class];
    // execute
    NSString *result1 = [processor stringByConvertingCrossReferencesInString:@"method:" withFlags:0];
    NSString *result2 = [processor stringByConvertingCrossReferencesInString:@"<method:>" withFlags:0];
    NSString *result3 = [processor stringByConvertingCrossReferencesInString:@"-method:" withFlags:0];
    NSString *result4 = [processor stringByConvertingCrossReferencesInString:@"<-method:>" withFlags:0];
    NSString *result5 = [processor stringByConvertingCrossReferencesInString:@"another:" withFlags:0];
    NSString *result6 = [processor stringByConvertingCrossReferencesInString:@"<another:>" withFlags:0];
    // verify
    XCTAssertEqualObjects(result1, @"[method:](#//api/name/method:)");
    XCTAssertEqualObjects(result2, @"[method:](#//api/name/method:)");
    XCTAssertEqualObjects(result3, @"[method:](#//api/name/method:)");
    XCTAssertEqualObjects(result4, @"[method:](#//api/name/method:)");
    XCTAssertEqualObjects(result5, @"another:");
    XCTAssertEqualObjects(result6, @"<another:>");
}

- (void)testStringByConvertingCrossReferencesInString_shouldConvertClassLocalClassMethod {
    // setup
    GBClassData *class = [GBTestObjectsRegistry classWithName:@"Class" methods:[GBTestObjectsRegistry classMethodWithNames:@"method", nil], nil];
    GBStore *store = [GBTestObjectsRegistry storeWithObjects:class, nil];
    GBCommentsProcessor *processor = [self processorWithStore:store context:class];
    // execute
    NSString *result1 = [processor stringByConvertingCrossReferencesInString:@"method:" withFlags:0];
    NSString *result2 = [processor stringByConvertingCrossReferencesInString:@"<method:>" withFlags:0];
    NSString *result3 = [processor stringByConvertingCrossReferencesInString:@"+method:" withFlags:0];
    NSString *result4 = [processor stringByConvertingCrossReferencesInString:@"<+method:>" withFlags:0];
    NSString *result5 = [processor stringByConvertingCrossReferencesInString:@"another:" withFlags:0];
    NSString *result6 = [processor stringByConvertingCrossReferencesInString:@"<another:>" withFlags:0];
    // verify
    XCTAssertEqualObjects(result1, @"[method:](#//api/name/method:)");
    XCTAssertEqualObjects(result2, @"[method:](#//api/name/method:)");
    XCTAssertEqualObjects(result3, @"[method:](#//api/name/method:)");
    XCTAssertEqualObjects(result4, @"[method:](#//api/name/method:)");
    XCTAssertEqualObjects(result5, @"another:");
    XCTAssertEqualObjects(result6, @"<another:>");
}

- (void)testStringByConvertingCrossReferencesInString_shouldConvertClassLocalProperty {
    // setup
    GBClassData *class = [GBTestObjectsRegistry classWithName:@"Class" methods:[GBTestObjectsRegistry propertyMethodWithArgument:@"method"], nil];
    GBStore *store = [GBTestObjectsRegistry storeWithObjects:class, nil];
    GBCommentsProcessor *processor = [self processorWithStore:store context:class];
    // execute
    NSString *result1 = [processor stringByConvertingCrossReferencesInString:@"method" withFlags:0];
    NSString *result2 = [processor stringByConvertingCrossReferencesInString:@"<method>" withFlags:0];
    NSString *result3 = [processor stringByConvertingCrossReferencesInString:@"method:" withFlags:0];
    NSString *result4 = [processor stringByConvertingCrossReferencesInString:@"<method:>" withFlags:0];
    NSString *result5 = [processor stringByConvertingCrossReferencesInString:@"another" withFlags:0];
    NSString *result6 = [processor stringByConvertingCrossReferencesInString:@"<another>" withFlags:0];
    // verify
    XCTAssertEqualObjects(result1, @"[method](#//api/name/method)");
    XCTAssertEqualObjects(result2, @"[method](#//api/name/method)");
    XCTAssertEqualObjects(result3, @"method:");
    XCTAssertEqualObjects(result4, @"<method:>");
    XCTAssertEqualObjects(result5, @"another");
    XCTAssertEqualObjects(result6, @"<another>");
}

- (void)testStringByConvertingCrossReferencesInString_shouldConvertCategoryAndProtocolLocalInstanceMethod {
    // setup
    id method1 = [GBTestObjectsRegistry instanceMethodWithNames:@"method1", nil];
    id method2 = [GBTestObjectsRegistry instanceMethodWithNames:@"method2", nil];
    GBCategoryData *category = [GBTestObjectsRegistry categoryWithName:@"Category" className:@"Class" methods:method1, nil];
    GBProtocolData *protocol = [GBTestObjectsRegistry protocolWithName:@"Protocol" methods:method2, nil];
    GBStore *store = [GBTestObjectsRegistry storeWithObjects:category, protocol, nil];
    GBCommentsProcessor *processor1 = [self processorWithStore:store context:category];
    GBCommentsProcessor *processor2 = [self processorWithStore:store context:protocol];
    // execute
    NSString *result1 = [processor1 stringByConvertingCrossReferencesInString:@"method1:" withFlags:0];
    NSString *result2 = [processor1 stringByConvertingCrossReferencesInString:@"<method1:>" withFlags:0];
    NSString *result3 = [processor1 stringByConvertingCrossReferencesInString:@"method2:" withFlags:0];
    NSString *result4 = [processor2 stringByConvertingCrossReferencesInString:@"method2:" withFlags:0];
    NSString *result5 = [processor2 stringByConvertingCrossReferencesInString:@"<method2:>" withFlags:0];
    NSString *result6 = [processor2 stringByConvertingCrossReferencesInString:@"method1:" withFlags:0];
    // verify
    XCTAssertEqualObjects(result1, @"[method1:](#//api/name/method1:)");
    XCTAssertEqualObjects(result2, @"[method1:](#//api/name/method1:)");
    XCTAssertEqualObjects(result3, @"method2:");
    XCTAssertEqualObjects(result4, @"[method2:](#//api/name/method2:)");
    XCTAssertEqualObjects(result5, @"[method2:](#//api/name/method2:)");
    XCTAssertEqualObjects(result6, @"method1:");
}

- (void)testStringByConvertingCrossReferencesInString_shouldConvertCategoryAndProtocolLocalClassMethod {
    // setup
    id method1 = [GBTestObjectsRegistry classMethodWithNames:@"method1", nil];
    id method2 = [GBTestObjectsRegistry classMethodWithNames:@"method2", nil];
    GBCategoryData *category = [GBTestObjectsRegistry categoryWithName:@"Category" className:@"Class" methods:method1, nil];
    GBProtocolData *protocol = [GBTestObjectsRegistry protocolWithName:@"Protocol" methods:method2, nil];
    GBStore *store = [GBTestObjectsRegistry storeWithObjects:category, protocol, nil];
    GBCommentsProcessor *processor1 = [self processorWithStore:store context:category];
    GBCommentsProcessor *processor2 = [self processorWithStore:store context:protocol];
    // execute
    NSString *result1 = [processor1 stringByConvertingCrossReferencesInString:@"method1:" withFlags:0];
    NSString *result2 = [processor1 stringByConvertingCrossReferencesInString:@"<method1:>" withFlags:0];
    NSString *result3 = [processor1 stringByConvertingCrossReferencesInString:@"method2:" withFlags:0];
    NSString *result4 = [processor2 stringByConvertingCrossReferencesInString:@"method2:" withFlags:0];
    NSString *result5 = [processor2 stringByConvertingCrossReferencesInString:@"<method2:>" withFlags:0];
    NSString *result6 = [processor2 stringByConvertingCrossReferencesInString:@"method1:" withFlags:0];
    // verify
    XCTAssertEqualObjects(result1, @"[method1:](#//api/name/method1:)");
    XCTAssertEqualObjects(result2, @"[method1:](#//api/name/method1:)");
    XCTAssertEqualObjects(result3, @"method2:");
    XCTAssertEqualObjects(result4, @"[method2:](#//api/name/method2:)");
    XCTAssertEqualObjects(result5, @"[method2:](#//api/name/method2:)");
    XCTAssertEqualObjects(result6, @"method1:");
}

- (void)testStringByConvertingCrossReferencesInString_shouldConvertCategoryAndProtocolLocalProperty {
    // setup
    id method1 = [GBTestObjectsRegistry propertyMethodWithArgument:@"method1"];
    id method2 = [GBTestObjectsRegistry propertyMethodWithArgument:@"method2"];
    GBCategoryData *category = [GBTestObjectsRegistry categoryWithName:@"Category" className:@"Class" methods:method1, nil];
    GBProtocolData *protocol = [GBTestObjectsRegistry protocolWithName:@"Protocol" methods:method2, nil];
    GBStore *store = [GBTestObjectsRegistry storeWithObjects:category, protocol, nil];
    GBCommentsProcessor *processor1 = [self processorWithStore:store context:category];
    GBCommentsProcessor *processor2 = [self processorWithStore:store context:protocol];
    // execute
    NSString *result1 = [processor1 stringByConvertingCrossReferencesInString:@"method1" withFlags:0];
    NSString *result2 = [processor1 stringByConvertingCrossReferencesInString:@"<method1>" withFlags:0];
    NSString *result3 = [processor1 stringByConvertingCrossReferencesInString:@"method2" withFlags:0];
    NSString *result4 = [processor2 stringByConvertingCrossReferencesInString:@"method2" withFlags:0];
    NSString *result5 = [processor2 stringByConvertingCrossReferencesInString:@"<method2>" withFlags:0];
    NSString *result6 = [processor2 stringByConvertingCrossReferencesInString:@"method1" withFlags:0];
    // verify
    XCTAssertEqualObjects(result1, @"[method1](#//api/name/method1)");
    XCTAssertEqualObjects(result2, @"[method1](#//api/name/method1)");
    XCTAssertEqualObjects(result3, @"method2");
    XCTAssertEqualObjects(result4, @"[method2](#//api/name/method2)");
    XCTAssertEqualObjects(result5, @"[method2](#//api/name/method2)");
    XCTAssertEqualObjects(result6, @"method1");
}

#pragma mark Remote members cross references detection

- (void)testStringByConvertingCrossReferencesInString_shouldConvertClassRemoteInstanceMethod {
    // setup
    GBClassData *class1 = [GBTestObjectsRegistry classWithName:@"Class1" methods:[GBTestObjectsRegistry instanceMethodWithNames:@"method", nil], nil];
    GBClassData *class2 = [GBClassData classDataWithName:@"Class2"];
    GBStore *store = [GBTestObjectsRegistry storeWithObjects:class1, class2, nil];
    GBCommentsProcessor *processor = [self processorWithStore:store context:class2];
    // execute
    NSString *result1 = [processor stringByConvertingCrossReferencesInString:@"[Class1 method:]" withFlags:0];
    NSString *result2 = [processor stringByConvertingCrossReferencesInString:@"<[Class1 method:]>" withFlags:0];
    NSString *result3 = [processor stringByConvertingCrossReferencesInString:@"-[Class1 method:]" withFlags:0];
    NSString *result4 = [processor stringByConvertingCrossReferencesInString:@"<-[Class1 method:]>" withFlags:0];
    NSString *result5 = [processor stringByConvertingCrossReferencesInString:@"[Unknown method:]" withFlags:0];
    NSString *result6 = [processor stringByConvertingCrossReferencesInString:@"method:" withFlags:0];
    // verify
    XCTAssertEqualObjects(result1, @"[[Class1 method:]](../Classes/Class1.html#//api/name/method:)");
    XCTAssertEqualObjects(result2, @"[[Class1 method:]](../Classes/Class1.html#//api/name/method:)");
    XCTAssertEqualObjects(result3, @"[[Class1 method:]](../Classes/Class1.html#//api/name/method:)");
    XCTAssertEqualObjects(result4, @"[[Class1 method:]](../Classes/Class1.html#//api/name/method:)");
    XCTAssertEqualObjects(result5, @"[Unknown method:]");
    XCTAssertEqualObjects(result6, @"method:");
}

- (void)testStringByConvertingCrossReferencesInString_shouldConvertCategoryRemoteInstanceMethod {
    // setup
    GBCategoryData *category = [GBTestObjectsRegistry categoryWithName:@"Category" className:@"Class" methods:[GBTestObjectsRegistry instanceMethodWithNames:@"method", nil], nil];
    GBClassData *class = [GBClassData classDataWithName:@"Class"];
    GBStore *store = [GBTestObjectsRegistry storeWithObjects:category, class, nil];
    GBCommentsProcessor *processor = [self processorWithStore:store context:class];
    // execute
    NSString *result1 = [processor stringByConvertingCrossReferencesInString:@"[Class(Category) method:]" withFlags:0];
    NSString *result2 = [processor stringByConvertingCrossReferencesInString:@"<[Class(Category) method:]>" withFlags:0];
    NSString *result3 = [processor stringByConvertingCrossReferencesInString:@"-[Class(Category) method:]" withFlags:0];
    NSString *result4 = [processor stringByConvertingCrossReferencesInString:@"<-[Class(Category) method:]>" withFlags:0];
    NSString *result5 = [processor stringByConvertingCrossReferencesInString:@"[Class(Unknown) method:]" withFlags:0];
    NSString *result6 = [processor stringByConvertingCrossReferencesInString:@"[Unknown(Category) method:]" withFlags:0];
    // verify
    XCTAssertEqualObjects(result1, @"[[Class(Category) method:]](../Categories/Class+Category.html#//api/name/method:)");
    XCTAssertEqualObjects(result2, @"[[Class(Category) method:]](../Categories/Class+Category.html#//api/name/method:)");
    XCTAssertEqualObjects(result3, @"[[Class(Category) method:]](../Categories/Class+Category.html#//api/name/method:)");
    XCTAssertEqualObjects(result4, @"[[Class(Category) method:]](../Categories/Class+Category.html#//api/name/method:)");
    XCTAssertEqualObjects(result5, @"[Class(Unknown) method:]");
    XCTAssertEqualObjects(result6, @"[Unknown(Category) method:]");
}

- (void)testStringByConvertingCrossReferencesInString_shouldConvertProtocolRemoteInstanceMethod {
    // setup
    GBProtocolData *protocol = [GBTestObjectsRegistry protocolWithName:@"Protocol" methods:[GBTestObjectsRegistry instanceMethodWithNames:@"method", nil], nil];
    GBClassData *class = [GBClassData classDataWithName:@"Class"];
    GBStore *store = [GBTestObjectsRegistry storeWithObjects:protocol, class, nil];
    GBCommentsProcessor *processor = [self processorWithStore:store context:class];
    // execute
    NSString *result1 = [processor stringByConvertingCrossReferencesInString:@"[Protocol method:]" withFlags:0];
    NSString *result2 = [processor stringByConvertingCrossReferencesInString:@"<[Protocol method:]>" withFlags:0];
    NSString *result3 = [processor stringByConvertingCrossReferencesInString:@"-[Protocol method:]" withFlags:0];
    NSString *result4 = [processor stringByConvertingCrossReferencesInString:@"<-[Protocol method:]>" withFlags:0];
    NSString *result5 = [processor stringByConvertingCrossReferencesInString:@"[Unknown method:]" withFlags:0];
    NSString *result6 = [processor stringByConvertingCrossReferencesInString:@"method:" withFlags:0];
    // verify
    XCTAssertEqualObjects(result1, @"[[Protocol method:]](../Protocols/Protocol.html#//api/name/method:)");
    XCTAssertEqualObjects(result2, @"[[Protocol method:]](../Protocols/Protocol.html#//api/name/method:)");
    XCTAssertEqualObjects(result3, @"[[Protocol method:]](../Protocols/Protocol.html#//api/name/method:)");
    XCTAssertEqualObjects(result4, @"[[Protocol method:]](../Protocols/Protocol.html#//api/name/method:)");
    XCTAssertEqualObjects(result5, @"[Unknown method:]");
    XCTAssertEqualObjects(result6, @"method:");
}

- (void)testStringByConvertingCrossReferencesInString_shouldKeepUnknownRemoteMemberEvenIfObjectIsKnown {
    // setup
    GBClassData *class1 = [GBTestObjectsRegistry classWithName:@"Class1" methods:[GBTestObjectsRegistry instanceMethodWithNames:@"method", nil], nil];
    GBClassData *class2 = [GBClassData classDataWithName:@"Class2"];
    GBStore *store = [GBTestObjectsRegistry storeWithObjects:class1, class2, nil];
    GBCommentsProcessor *processor = [self processorWithStore:store context:class2];
    // execute
    NSString *result = [processor stringByConvertingCrossReferencesInString:@"[Class1 unknown:]" withFlags:0];
    // verify
    XCTAssertEqualObjects(result, @"[Class1 unknown:]");
}

#pragma mark Document references detection

- (void)testStringByConvertingCrossReferencesInString_shouldConvertDocument {
    // setup
    GBDocumentData *document = [GBDocumentData documentDataWithContents:@"c" path:@"Document1.html"];
    GBStore *store = [GBTestObjectsRegistry storeWithObjects:document, nil];
    GBCommentsProcessor *processor = [self processorWithStore:store context:nil];
    // execute
    NSString *result1 = [processor stringByConvertingCrossReferencesInString:@"Document1" withFlags:0];
    NSString *result2 = [processor stringByConvertingCrossReferencesInString:@"<Document1>" withFlags:0];
    NSString *result3 = [processor stringByConvertingCrossReferencesInString:@"Document12" withFlags:0];
    // verify
    XCTAssertEqualObjects(result1, @"[Document1](docs/Document1.html)");
    XCTAssertEqualObjects(result2, @"[Document1](docs/Document1.html)");
    XCTAssertEqualObjects(result3, @"Document12");
}

#pragma mark URL cross references detection

- (void)testStringByConvertingCrossReferencesInString_shouldConvertHTML {
    // setup
    GBCommentsProcessor *processor = [self defaultProcessor];
    // execute
    NSString *result1 = [processor stringByConvertingCrossReferencesInString:@"http://gentlebytes.com" withFlags:0];
    NSString *result2 = [processor stringByConvertingCrossReferencesInString:@"https://gentlebytes.com" withFlags:0];
    NSString *result3 = [processor stringByConvertingCrossReferencesInString:@"<http://gentlebytes.com>" withFlags:0];
    NSString *result4 = [processor stringByConvertingCrossReferencesInString:@"<https://gentlebytes.com>" withFlags:0];
    NSString *result5 = [processor stringByConvertingCrossReferencesInString:@"http://gentlebytes.com https://gentlebytes.com" withFlags:0];
    NSString *result6 = [processor stringByConvertingCrossReferencesInString:@"https://gentlebytes.com http://gentlebytes.com" withFlags:0];
    // verify
    XCTAssertEqualObjects(result1, @"[http://gentlebytes.com](http://gentlebytes.com)");
    XCTAssertEqualObjects(result2, @"[https://gentlebytes.com](https://gentlebytes.com)");
    XCTAssertEqualObjects(result3, @"[http://gentlebytes.com](http://gentlebytes.com)");
    XCTAssertEqualObjects(result4, @"[https://gentlebytes.com](https://gentlebytes.com)");
    XCTAssertEqualObjects(result5, @"[http://gentlebytes.com](http://gentlebytes.com) [https://gentlebytes.com](https://gentlebytes.com)");
    XCTAssertEqualObjects(result6, @"[https://gentlebytes.com](https://gentlebytes.com) [http://gentlebytes.com](http://gentlebytes.com)");
}

- (void)testStringByConvertingCrossReferencesInString_shouldConvertFTP {
    // setup
    GBCommentsProcessor *processor = [self defaultProcessor];
    // execute
    NSString *result1 = [processor stringByConvertingCrossReferencesInString:@"ftp://gentlebytes.com" withFlags:0];
    NSString *result2 = [processor stringByConvertingCrossReferencesInString:@"ftps://gentlebytes.com" withFlags:0];
    NSString *result3 = [processor stringByConvertingCrossReferencesInString:@"<ftp://gentlebytes.com>" withFlags:0];
    NSString *result4 = [processor stringByConvertingCrossReferencesInString:@"<ftps://gentlebytes.com>" withFlags:0];
    NSString *result5 = [processor stringByConvertingCrossReferencesInString:@"ftp://gentlebytes.com ftps://gentlebytes.com" withFlags:0];
    NSString *result6 = [processor stringByConvertingCrossReferencesInString:@"ftps://gentlebytes.com ftp://gentlebytes.com" withFlags:0];
    // verify
    XCTAssertEqualObjects(result1, @"[ftp://gentlebytes.com](ftp://gentlebytes.com)");
    XCTAssertEqualObjects(result2, @"[ftps://gentlebytes.com](ftps://gentlebytes.com)");
    XCTAssertEqualObjects(result3, @"[ftp://gentlebytes.com](ftp://gentlebytes.com)");
    XCTAssertEqualObjects(result4, @"[ftps://gentlebytes.com](ftps://gentlebytes.com)");
    XCTAssertEqualObjects(result5, @"[ftp://gentlebytes.com](ftp://gentlebytes.com) [ftps://gentlebytes.com](ftps://gentlebytes.com)");
    XCTAssertEqualObjects(result6, @"[ftps://gentlebytes.com](ftps://gentlebytes.com) [ftp://gentlebytes.com](ftp://gentlebytes.com)");
}

- (void)testStringByConvertingCrossReferencesInString_shouldConvertNewsAndRSS {
    // setup
    GBCommentsProcessor *processor = [self defaultProcessor];
    // execute
    NSString *result1 = [processor stringByConvertingCrossReferencesInString:@"news://gentlebytes.com" withFlags:0];
    NSString *result2 = [processor stringByConvertingCrossReferencesInString:@"rss://gentlebytes.com" withFlags:0];
    NSString *result3 = [processor stringByConvertingCrossReferencesInString:@"<news://gentlebytes.com>" withFlags:0];
    NSString *result4 = [processor stringByConvertingCrossReferencesInString:@"<rss://gentlebytes.com>" withFlags:0];
    NSString *result5 = [processor stringByConvertingCrossReferencesInString:@"rss://gentlebytes.com news://gentlebytes.com" withFlags:0];
    NSString *result6 = [processor stringByConvertingCrossReferencesInString:@"news://gentlebytes.com rss://gentlebytes.com" withFlags:0];
    // verify
    XCTAssertEqualObjects(result1, @"[news://gentlebytes.com](news://gentlebytes.com)");
    XCTAssertEqualObjects(result2, @"[rss://gentlebytes.com](rss://gentlebytes.com)");
    XCTAssertEqualObjects(result3, @"[news://gentlebytes.com](news://gentlebytes.com)");
    XCTAssertEqualObjects(result4, @"[rss://gentlebytes.com](rss://gentlebytes.com)");
    XCTAssertEqualObjects(result5, @"[rss://gentlebytes.com](rss://gentlebytes.com) [news://gentlebytes.com](news://gentlebytes.com)");
    XCTAssertEqualObjects(result6, @"[news://gentlebytes.com](news://gentlebytes.com) [rss://gentlebytes.com](rss://gentlebytes.com)");
}

- (void)testStringByConvertingCrossReferencesInString_shouldConvertFile {
    // setup
    GBCommentsProcessor *processor = [self defaultProcessor];
    // execute
    NSString *result1 = [processor stringByConvertingCrossReferencesInString:@"file://gentlebytes.com" withFlags:0];
    NSString *result2 = [processor stringByConvertingCrossReferencesInString:@"<file://gentlebytes.com>" withFlags:0];
    NSString *result3 = [processor stringByConvertingCrossReferencesInString:@"file://first file://second" withFlags:0];
    // verify
    XCTAssertEqualObjects(result1, @"[file://gentlebytes.com](file://gentlebytes.com)");
    XCTAssertEqualObjects(result2, @"[file://gentlebytes.com](file://gentlebytes.com)");
    XCTAssertEqualObjects(result3, @"[file://first](file://first) [file://second](file://second)");
}

- (void)testStringByConvertingCrossReferencesInString_shouldConvertMailto {
    // setup
    GBCommentsProcessor *processor = [self defaultProcessor];
    // execute
    NSString *result1 = [processor stringByConvertingCrossReferencesInString:@"mailto:appledoc@gentlebytes.com" withFlags:0];
    NSString *result2 = [processor stringByConvertingCrossReferencesInString:@"<mailto:appledoc@gentlebytes.com>" withFlags:0];
    NSString *result3 = [processor stringByConvertingCrossReferencesInString:@"mailto:a@b.com mailto:c@d.com" withFlags:0];
    // verify
    XCTAssertEqualObjects(result1, @"[appledoc@gentlebytes.com](mailto:appledoc@gentlebytes.com)");
    XCTAssertEqualObjects(result2, @"[appledoc@gentlebytes.com](mailto:appledoc@gentlebytes.com)");
    XCTAssertEqualObjects(result3, @"[a@b.com](mailto:a@b.com) [c@d.com](mailto:c@d.com)");
}

#pragma mark Combinations detection testing

- (void)testStringByConvertingCrossReferencesInString_shouldConvertClassAndProtocol {
    // setup
    GBClassData *class = [GBClassData classDataWithName:@"Class"];
    GBProtocolData *protocol = [GBProtocolData protocolDataWithName:@"Protocol"];
    GBStore *store = [GBTestObjectsRegistry storeWithObjects:protocol, class, nil];
    GBCommentsProcessor *processor = [self processorWithStore:store];
    // execute
    NSString *result1 = [processor stringByConvertingCrossReferencesInString:@"Class Protocol" withFlags:0];
    NSString *result2 = [processor stringByConvertingCrossReferencesInString:@"Protocol Class" withFlags:0];
    // verify
    XCTAssertEqualObjects(result1, @"[Class](Classes/Class.html) [Protocol](Protocols/Protocol.html)");
    XCTAssertEqualObjects(result2, @"[Protocol](Protocols/Protocol.html) [Class](Classes/Class.html)");
}

- (void)testStringByConvertingCrossReferencesInString_shouldConvertCategoryAndClass {
    // setup
    GBCategoryData *category = [GBCategoryData categoryDataWithName:@"Category" className:@"Class"];
    GBClassData *class = [GBClassData classDataWithName:@"Class"];
    GBStore *store = [GBTestObjectsRegistry storeWithObjects:category, class, nil];
    GBCommentsProcessor *processor = [self processorWithStore:store];
    // execute
    NSString *result1 = [processor stringByConvertingCrossReferencesInString:@"Class(Category) Class" withFlags:0];
    NSString *result2 = [processor stringByConvertingCrossReferencesInString:@"Class Class(Category)" withFlags:0];
    // verify
    XCTAssertEqualObjects(result1, @"[Class(Category)](Categories/Class+Category.html) [Class](Classes/Class.html)");
    XCTAssertEqualObjects(result2, @"[Class](Classes/Class.html) [Class(Category)](Categories/Class+Category.html)");
}

- (void)testStringByConvertingCrossReferencesInString_shouldConvertCategoryAndProtocol {
    // setup - although it's not possible to do categories on protocols, we still test to properly cover these...
    GBCategoryData *category = [GBCategoryData categoryDataWithName:@"Category" className:@"Protocol"];
    GBProtocolData *protocol = [GBProtocolData protocolDataWithName:@"Protocol"];
    GBStore *store = [GBTestObjectsRegistry storeWithObjects:category, protocol, nil];
    GBCommentsProcessor *processor = [self processorWithStore:store];
    // execute
    NSString *result1 = [processor stringByConvertingCrossReferencesInString:@"Protocol(Category) Protocol" withFlags:0];
    NSString *result2 = [processor stringByConvertingCrossReferencesInString:@"Protocol Protocol(Category)" withFlags:0];
    // verify
    XCTAssertEqualObjects(result1, @"[Protocol(Category)](Categories/Protocol+Category.html) [Protocol](Protocols/Protocol.html)");
    XCTAssertEqualObjects(result2, @"[Protocol](Protocols/Protocol.html) [Protocol(Category)](Categories/Protocol+Category.html)");
}

#pragma mark Manual links detection testing

- (void)testStringByConvertingCrossReferencesInString_shouldKeepManualLinks {
    // setup
    GBCommentsProcessor *processor = [self processorWithStore:nil];
    // execute
    NSString *result1 = [processor stringByConvertingCrossReferencesInString:@"[text](something)" withFlags:0];
    NSString *result2 = [processor stringByConvertingCrossReferencesInString:@"[multi word](more words)" withFlags:0];
    NSString *result3 = [processor stringByConvertingCrossReferencesInString:@"![multi word](more words)" withFlags:0];
    NSString *result4 = [processor stringByConvertingCrossReferencesInString:@"[![multi word](more words)](foo)" withFlags:0];
    // verify
    XCTAssertEqualObjects(result1, @"[text](something)");
    XCTAssertEqualObjects(result2, @"[multi word](more words)");
    XCTAssertEqualObjects(result3, @"![multi word](more words)");
    XCTAssertEqualObjects(result4, @"[![multi word](more words)](foo)");
}

- (void)testStringByConvertingCrossReferencesInString_shouldKeepManualURLLinks {
    // setup
    GBCommentsProcessor *processor = [self processorWithStore:nil];
    // execute
    NSString *result1 = [processor stringByConvertingCrossReferencesInString:@"[text](http://ab.com)" withFlags:0];
    NSString *result2 = [processor stringByConvertingCrossReferencesInString:@"[text](https://ab.com)" withFlags:0];
    NSString *result3 = [processor stringByConvertingCrossReferencesInString:@"[text](ftp://ab.com)" withFlags:0];
    NSString *result4 = [processor stringByConvertingCrossReferencesInString:@"[text](ftps://ab.com)" withFlags:0];
    NSString *result5 = [processor stringByConvertingCrossReferencesInString:@"[text](news://ab.com)" withFlags:0];
    NSString *result6 = [processor stringByConvertingCrossReferencesInString:@"[text](rss://ab.com)" withFlags:0];
    NSString *result7 = [processor stringByConvertingCrossReferencesInString:@"[text](mailto:a@b.com)" withFlags:0];
    NSString *result8 = [processor stringByConvertingCrossReferencesInString:@"![text](http://ab.com)" withFlags:0];
    NSString *result9 = [processor stringByConvertingCrossReferencesInString:@"[![text](https://ab.com)](https://zx.com)" withFlags:0];

    // verify
    XCTAssertEqualObjects(result1, @"[text](http://ab.com)");
    XCTAssertEqualObjects(result2, @"[text](https://ab.com)");
    XCTAssertEqualObjects(result3, @"[text](ftp://ab.com)");
    XCTAssertEqualObjects(result4, @"[text](ftps://ab.com)");
    XCTAssertEqualObjects(result5, @"[text](news://ab.com)");
    XCTAssertEqualObjects(result6, @"[text](rss://ab.com)");
    XCTAssertEqualObjects(result7, @"[text](mailto:a@b.com)");
    XCTAssertEqualObjects(result8, @"![text](http://ab.com)");
    XCTAssertEqualObjects(result9, @"[![text](https://ab.com)](https://zx.com)");
}

- (void)testStringByConvertingCrossReferencesInString_shouldKeepManualObjectLinksAndUpdateAddress {
    // setup
    GBClassData *class = [GBClassData classDataWithName:@"Class"];
    GBCategoryData *category = [GBCategoryData categoryDataWithName:@"Category" className:@"Class"];
    GBProtocolData *protocol = [GBProtocolData protocolDataWithName:@"Protocol"];
    GBDocumentData *document = [GBDocumentData documentDataWithContents:@"c" path:@"document.ext"];
    GBStore *store = [GBTestObjectsRegistry storeWithObjects:class, category, protocol, document, nil];
    GBCommentsProcessor *processor = [self processorWithStore:store];
    // setup
    NSString *result1 = [processor stringByConvertingCrossReferencesInString:@"[text](Class)" withFlags:0];
    NSString *result2 = [processor stringByConvertingCrossReferencesInString:@"[text](Class(Category))" withFlags:0];
    NSString *result3 = [processor stringByConvertingCrossReferencesInString:@"[text](Protocol)" withFlags:0];
    NSString *result4 = [processor stringByConvertingCrossReferencesInString:@"[text](document)" withFlags:0];
    // verify
    XCTAssertEqualObjects(result1, @"[text](Classes/Class.html)");
    XCTAssertEqualObjects(result2, @"[text](Categories/Class+Category.html)");
    XCTAssertEqualObjects(result3, @"[text](Protocols/Protocol.html)");
    XCTAssertEqualObjects(result4, @"[text](docs/document.html)");
}

- (void)testStringByConvertingCrossReferencesInString_shouldKeepManualObjectMethodLinksAndUpdateAddress {
     GBClassData *class = [GBClassData classDataWithName:@"Class"];
    GBCategoryData *category = [GBCategoryData categoryDataWithName:@"Category" className:@"Class"];
    GBProtocolData *protocol = [GBProtocolData protocolDataWithName:@"Protocol"];
    GBDocumentData *document = [GBDocumentData documentDataWithContents:@"c" path:@"document.ext"];
    
    GBMethodArgument *argument = [GBMethodArgument methodArgumentWithName:@"method"];
    GBMethodData *method1 = [GBTestObjectsRegistry instanceMethodWithArguments:argument, nil];
    GBMethodData *method2 = [GBTestObjectsRegistry instanceMethodWithNames:@"doSomething", @"withVars", nil];
    GBMethodData *property = [GBTestObjectsRegistry propertyMethodWithArgument:@"value"];
    [class.methods registerMethod:method1];
    [class.methods registerMethod:method2];
    [class.methods registerMethod:property];
    
    GBStore *store = [GBTestObjectsRegistry storeWithObjects:class, category, protocol, document, nil];
    GBCommentsProcessor *processor = [self processorWithStore:store];

    NSString *result1 = [processor stringByConvertingCrossReferencesInString:@"[text](+[Class method])" withFlags:0];
    NSString *result2 = [processor stringByConvertingCrossReferencesInString:@"[text]([Class doSomething:withVars:])" withFlags:0];
    NSString *result3 = [processor stringByConvertingCrossReferencesInString:@"[text](-[Class value])" withFlags:0];
    NSString *result4 = [processor stringByConvertingCrossReferencesInString:@"[text with space](+[Class method])" withFlags:0];
    NSString *result4b = [processor stringByConvertingCrossReferencesInString:@"[text onlyOneSpace]([Class method])" withFlags:0];
    NSString *result4c = [processor stringByConvertingCrossReferencesInString:@"[text](+[Class method]), [text onlyOneSpace]([Class method])" withFlags:0];
    NSString *result5 = [processor stringByConvertingCrossReferencesInString:@"[doSomething:withVars:]([Class doSomething:withVars:])" withFlags:0];
    NSString *result6 = [processor stringByConvertingCrossReferencesInString:@"[doSomething:withVars:]([Class doSomething:withVars:]), [text]([Class method])" withFlags:0];
    NSString *result7 = [processor stringByConvertingCrossReferencesInString:@"[doSomething:withVars:]([Class doSomething:withVars:]), [text with space]([Class method])" withFlags:0];
    NSString *result8 = [processor stringByConvertingCrossReferencesInString:@"[text](<-[Class value]>)" withFlags:0];
    
    XCTAssertEqualObjects(result1, @"[text](Classes/Class.html#//api/name/method)");
    XCTAssertEqualObjects(result2, @"[text](Classes/Class.html#//api/name/doSomething:withVars:)");
    XCTAssertEqualObjects(result3, @"[text](Classes/Class.html#//api/name/value)");
    XCTAssertEqualObjects(result4, @"[text with space](Classes/Class.html#//api/name/method)");
    XCTAssertEqualObjects(result4b, @"[text onlyOneSpace](Classes/Class.html#//api/name/method)");
    XCTAssertEqualObjects(result4c, @"[text](Classes/Class.html#//api/name/method), [text onlyOneSpace](Classes/Class.html#//api/name/method)");
    XCTAssertEqualObjects(result5, @"[doSomething:withVars:](Classes/Class.html#//api/name/doSomething:withVars:)");
    XCTAssertEqualObjects(result6, @"[doSomething:withVars:](Classes/Class.html#//api/name/doSomething:withVars:), [text](Classes/Class.html#//api/name/method)");
    XCTAssertEqualObjects(result7, @"[doSomething:withVars:](Classes/Class.html#//api/name/doSomething:withVars:), [text with space](Classes/Class.html#//api/name/method)");
    XCTAssertEqualObjects(result8, @"[text](Classes/Class.html#//api/name/value)");
}

- (void)testStringByConvertingCrossReferencesInString_shouldIgnoreKnownObjectsInManualLinkDescriptionOrTitle {
    // setup
    GBClassData *class = [GBClassData classDataWithName:@"Class"];
    GBStore *store = [GBTestObjectsRegistry storeWithObjects:class, nil];
    GBCommentsProcessor *processor = [self processorWithStore:store];
    // setup
    NSString *result = [processor stringByConvertingCrossReferencesInString:@"[Class](Class \"Class\")" withFlags:0];
    // verify
    XCTAssertEqualObjects(result, @"[Class](Classes/Class.html \"Class\")");
}

- (void)testStringByConvertingCrossReferencesInString_shouldHandleMarkdownLinkReferences {
    // setup
    GBClassData *class = [GBClassData classDataWithName:@"Class"];
    GBStore *store = [GBTestObjectsRegistry storeWithObjects:class, nil];
    GBCommentsProcessor *processor = [self processorWithStore:store];
    // setup
    NSString *result1 = [processor stringByConvertingCrossReferencesInString:@"[1]: http://ab.com" withFlags:0];
    NSString *result2 = [processor stringByConvertingCrossReferencesInString:@"[1]: http://ab.com \"title\"" withFlags:0];
    NSString *result3 = [processor stringByConvertingCrossReferencesInString:@"[1]: Class" withFlags:0];
    NSString *result4 = [processor stringByConvertingCrossReferencesInString:@"[1]: Class \"title\"" withFlags:0];
    NSString *result5 = [processor stringByConvertingCrossReferencesInString:@"[Class]: something" withFlags:0];
    NSString *result6 = [processor stringByConvertingCrossReferencesInString:@"[1]: something \"Class\"" withFlags:0];
    // verify
    XCTAssertEqualObjects(result1, @"[1]: http://ab.com");
    XCTAssertEqualObjects(result2, @"[1]: http://ab.com \"title\"");
    XCTAssertEqualObjects(result3, @"[1]: Classes/Class.html");
    XCTAssertEqualObjects(result4, @"[1]: Classes/Class.html \"title\"");
    XCTAssertEqualObjects(result5, @"[Class]: something");
    XCTAssertEqualObjects(result6, @"[1]: something \"Class\"");
}

#pragma mark Links inside of links testing

- (void) testStringByConvertingCrossReferencesInString_shouldIgnoreLinksInsideOtherLinks {
    // setup
    GBClassData *class = [GBTestObjectsRegistry classWithName:@"Class" methods:[GBTestObjectsRegistry classMethodWithNames:@"URLWithString", nil], nil];
    GBStore *store = [GBTestObjectsRegistry storeWithObjects:class, nil];
    GBCommentsProcessor *processor = [self processorWithStore:store context:class];
    // execute
    NSString *result1 = [processor stringByConvertingCrossReferencesInString:@"[Class URLWithString:@\"http://gentlebytes.com\"]" withFlags:0];
    // verify
    XCTAssertEqualObjects(result1, @"[Class URLWithString:@\"http://gentlebytes.com\"]");
}


#pragma mark Creation methods

- (GBCommentsProcessor *)defaultProcessor {
    // Creates a new GBCommentsProcessor using real settings. Note that we disable embedding cross references to make test strings more readable.
    id settings = [GBTestObjectsRegistry realSettingsProvider];
    [settings setEmbedCrossReferencesWhenProcessingMarkdown:NO];
    return [GBCommentsProcessor processorWithSettingsProvider:settings];
}

- (GBCommentsProcessor *)processorWithStore:(id)store {
    // Creates a new GBCommentsProcessor using real settings and the given store.
    return [self processorWithStore:store context:nil];
}

- (GBCommentsProcessor *)processorWithStore:(id)store context:(id)context {
    // Creates a new GBCommentsProcessor using real settings and the given store and context. Note that we disable embedding cross references to make test strings more readable.
    id settings = [GBTestObjectsRegistry realSettingsProvider];
    [settings setEmbedCrossReferencesWhenProcessingMarkdown:NO];
    GBCommentsProcessor *result = [self defaultProcessor];
    [result setValue:store forKey:@"store"];
    [result setValue:context forKey:@"currentContext"];
    return result;
}

@end
