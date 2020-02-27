//
//  GBTemplateHandlerTesting.m
//  appledocTests
//
//  Created by Jebeom Gyeong on 2/22/20.
//  Copyright © 2020 Gentle Bytes. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <GRMustache/GRMustache.h>
#import "GBTemplateHandler.h"

@interface GBTemplateHandler (TestingAPI)
@property (readonly) NSString *templateString;
@property (readonly) NSDictionary *templateSections;
@property (readonly) GRMustacheTemplate *template;
@end

@implementation GBTemplateHandler (TestingAPI)
//method below is intenionally overwritten so we want to silent the warning
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
- (NSString *)templateString { return [self valueForKey:@"_templateString"]; }
#pragma clang diagnostic pop

- (NSDictionary *)templateSections { return [self valueForKey:@"_templateSections"]; }
- (GRMustacheTemplate *)template { return [self valueForKey:@"_template"]; }
@end

#pragma mark -

@interface GBTemplateHandlerTesting : XCTestCase

@end

@implementation GBTemplateHandlerTesting

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

#pragma mark Empty templates

- (void)testParseTemplate_empty_shouldIndicateSuccess {
    // setup
    GBTemplateHandler *loader = [GBTemplateHandler handler];
    // execute
    BOOL result = [loader parseTemplate:@"" error:nil];
    // verify
    XCTAssertTrue(result);
    XCTAssertEqual([loader.templateSections count], 0);
    XCTAssertEqualObjects(loader.templateString, @"");
}

- (void)testParseTemplate_empty_shouldClearBeforeReading {
    // setup
    GBTemplateHandler *loader = [GBTemplateHandler handler];
    [loader parseTemplate:@"Something Section name text EndSection" error:nil];
    // execute
    BOOL result = [loader parseTemplate:@"" error:nil];
    // verify
    XCTAssertTrue(result);
    XCTAssertEqualObjects(loader.templateString, @"");
    XCTAssertEqual([loader.templateSections count], 0);
}

#pragma mark Template sections

- (void)testParseTemplate_sections_shouldReadSimpleTemplateSection {
    // setup
    GBTemplateHandler *loader = [GBTemplateHandler handler];
    NSString *template = @"Section name text EndSection";
    // execute
    BOOL result = [loader parseTemplate:template error:nil];
    // verify
    XCTAssertTrue(result);
    XCTAssertEqual([loader.templateSections count], 1);
    XCTAssertEqualObjects(loader.templateSections[@"name"], @"text");
}

- (void)testParseTemplateError_sections_shouldReadAllTemplateSections {
    // setup
    GBTemplateHandler *loader = [GBTemplateHandler handler];
    NSString *template = @"Prefix \n Section name1 text1 EndSection \n Intermediate \n Section name2 text2 EndSection \n Suffix";
    // execute
    BOOL result = [loader parseTemplate:template error:nil];
    // verify
    XCTAssertTrue(result);
    XCTAssertEqual([loader.templateSections count], 2);
    XCTAssertEqualObjects(loader.templateSections[@"name1"], @"text1");
    XCTAssertEqualObjects(loader.templateSections[@"name2"], @"text2");
}

- (void)testParseTemplate_sections_shouldReadComplexTemplateSectionValue {
    // setup
    GBTemplateHandler *loader = [GBTemplateHandler handler];
    NSString *template = @"Section name \nfirst line\nsecond line\nEndSection";
    // execute
    BOOL result = [loader parseTemplate:template error:nil];
    // verify
    XCTAssertTrue(result);
    XCTAssertEqual([loader.templateSections count], 1);
    XCTAssertEqualObjects(loader.templateSections[@"name"], @"first line\nsecond line");
}

- (void)testParseTemplate_sections_shouldClearBeforeReading {
    // setup
    GBTemplateHandler *loader = [GBTemplateHandler handler];
    [loader parseTemplate:@"Section name1 text1 EndSection" error:nil];
    // execute
    BOOL result = [loader parseTemplate:@"Section name2 text2 EndSection" error:nil];
    // verify
    XCTAssertTrue(result);
    XCTAssertEqual([loader.templateSections count], 1);
    XCTAssertNil(loader.templateSections[@"name1"]);
    XCTAssertNotNil(loader.templateSections[@"name2"]);
}

#pragma mark Template string

- (void)testParseTemplate_string_shouldCopyWholeTextIfNoTemplateSectionFound {
    // setup
    GBTemplateHandler *loader = [GBTemplateHandler handler];
    NSString *template = @"This is template text";
    // execute
    BOOL result = [loader parseTemplate:template error:nil];
    // verify
    XCTAssertTrue(result);
    XCTAssertEqualObjects(loader.templateString, @"This is template text");
    XCTAssertEqual([loader.templateSections count], 0);
}

- (void)testParseTemplate_string_shouldTrimStringBeforeTemplateSections {
    // setup
    GBTemplateHandler *loader = [GBTemplateHandler handler];
    NSString *template = @"This is template text Section name text EndSection";
    // execute
    BOOL result = [loader parseTemplate:template error:nil];
    // verify
    XCTAssertTrue(result);
    XCTAssertEqualObjects(loader.templateString, @"This is template text");
}

- (void)testParseTemplate_string_shouldTrimStringBetweenTemplateSections {
    // setup
    GBTemplateHandler *loader = [GBTemplateHandler handler];
    NSString *template = @"Section name1 text EndSection This is text in the middle Section name2 text EndSection";
    // execute
    BOOL result = [loader parseTemplate:template error:nil];
    // verify
    XCTAssertTrue(result);
    XCTAssertEqualObjects(loader.templateString, @"This is text in the middle");
}

- (void)testParseTemplate_string_shouldTrimStringAfterTemplateSections {
    // setup
    GBTemplateHandler *loader = [GBTemplateHandler handler];
    NSString *template = @"Section name text EndSection This is template text";
    // execute
    BOOL result = [loader parseTemplate:template error:nil];
    // verify
    XCTAssertTrue(result);
    XCTAssertEqualObjects(loader.templateString, @"This is template text");
}

#pragma mark Complex examples

- (void)testParseTemplate_complex_shouldHandleComplexStrings {
    // setup
    GBTemplateHandler *loader = [GBTemplateHandler handler];
    NSString *template =
        @"Some text\nin multiple lines\n\n"
        @"Section name1 text\nline2\n\nEndSection\n\n"
        @"Followed\nby middle\ntext\n\n"
        @"Section name2 text2\n\tline2 EndSection\n\n"
        @"And by some\n\tprefix\n\n\n";
    // execute
    BOOL result = [loader parseTemplate:template error:nil];
    // verify
    XCTAssertTrue(result);
    XCTAssertEqualObjects(loader.templateString, @"Some text\nin multiple lines\nFollowed\nby middle\ntext\nAnd by some\n\tprefix");
    XCTAssertEqual([loader.templateSections count], 2);
    XCTAssertEqualObjects(loader.templateSections[@"name1"], @"text\nline2");
    XCTAssertEqualObjects(loader.templateSections[@"name2"], @"text2\n\tline2");
}

#pragma mark Template handling

- (void)testParsetTemplate_template_shouldCreateTemplateInstance {
    // setup
    GBTemplateHandler *loader = [GBTemplateHandler handler];
    NSString *template = @"Something Section name text EndSection";
    // execute
    [loader parseTemplate:template error:nil];
    // verify
    XCTAssertNotNil(loader.template);
}

- (void)testParseTemplate_template_shouldSetEmptyTemplateIfEmptyTemplateIsGiven {
    // setup
    GBTemplateHandler *loader = [GBTemplateHandler handler];
    // execute
    [loader parseTemplate:@"" error:nil];
    // verify
    XCTAssertNil(loader.template);
}

- (void)testParseTemplate_template_shouldResetTemplateInstanceIfEmptyTemplateIsGiven {
    // setup
    GBTemplateHandler *loader = [GBTemplateHandler handler];
    [loader parseTemplate:@"Something" error:nil];
    // execute
    [loader parseTemplate:@"" error:nil];
    // verify
    XCTAssertNil(loader.template);
}

#pragma mark Rendering handling (just simple testing, we rely on GRMustache for correct behavior!)

- (void)testRenderObject_shouldRenderSimpleTemplate {
    // setup
    GBTemplateHandler *loader = [GBTemplateHandler handler];
    [loader parseTemplate:@"prefix {{var1}}---{{var2}} suffix" error:nil];
    // execute
    NSString *result = [loader renderObject:@{@"var1" : @"value1", @"var2" : @"value2"}];
    // verify
    XCTAssertEqualObjects(result, @"prefix value1---value2 suffix");
}

- (void)testRenderObject_shouldRenderSectionIfCalled {
    // setup
    GBTemplateHandler *loader = [GBTemplateHandler handler];
    [loader parseTemplate:@"prefix {{>name}}! Section name text EndSection" error:nil];
    // execute
    NSString *result = [loader renderObject:nil];
    // verify
    XCTAssertEqualObjects(result, @"prefix text!");
}

- (void)testRenderObject_shouldNotRenderSectionIfNotCalled {
    // setup
    GBTemplateHandler *loader = [GBTemplateHandler handler];
    [loader parseTemplate:@"prefix Section name text EndSection" error:nil];
    // execute
    NSString *result = [loader renderObject:nil];
    // verify
    XCTAssertEqualObjects(result, @"prefix");
}

- (void)testRenderObject_shouldPassProperObjectToSections {
    // setup
    GBTemplateHandler *loader = [GBTemplateHandler handler];
    [loader parseTemplate:@"prefix {{#var1}}{{>name}}{{/var1}}! {{#var2}}{{>name}}{{/var2}}? Section name {{value}} EndSection" error:nil];
    NSDictionary *var1 = @{@"value" : @"value1"};
    NSDictionary *var2 = @{@"value" : @"value2"};
    // execute
    NSString *result = [loader renderObject:@{@"var1" : var1, @"var2" : var2}];
    // verify
    XCTAssertEqualObjects(result, @"prefix value1! value2?");
}

@end
