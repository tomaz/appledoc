//
//  GBTemplateHandlerTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 17.11.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GRMustache/GRMustache.h"
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

@interface GBTemplateHandlerTesting : GHTestCase
@end

@implementation GBTemplateHandlerTesting

#pragma mark Empty templates

- (void)testParseTemplate_empty_shouldIndicateSuccess {
	// setup
	GBTemplateHandler *loader = [GBTemplateHandler handler];
	// execute
	BOOL result = [loader parseTemplate:@"" error:nil];
	// verify
	assertThatBool(result, equalToBool(YES));
	assertThatInteger([loader.templateSections count], equalToInteger(0));
	assertThat(loader.templateString, is(@""));
}

- (void)testParseTemplate_empty_shouldClearBeforeReading {
	// setup
	GBTemplateHandler *loader = [GBTemplateHandler handler];
	[loader parseTemplate:@"Something Section name text EndSection" error:nil];
	// execute
	BOOL result = [loader parseTemplate:@"" error:nil];
	// verify
	assertThatBool(result, equalToBool(YES));
	assertThat(loader.templateString, is(@""));
	assertThatInteger([loader.templateSections count], equalToInteger(0));
}

#pragma mark Template sections

- (void)testParseTemplate_sections_shouldReadSimpleTemplateSection {
	// setup
	GBTemplateHandler *loader = [GBTemplateHandler handler];
	NSString *template = @"Section name text EndSection";
	// execute
	BOOL result = [loader parseTemplate:template error:nil];
	// verify
	assertThatBool(result, equalToBool(YES));
	assertThatInteger([loader.templateSections count], equalToInteger(1));
	assertThat([loader.templateSections objectForKey:@"name"], is(@"text"));
}

- (void)testParseTemplateError_sections_shouldReadAllTemplateSections {
	// setup
	GBTemplateHandler *loader = [GBTemplateHandler handler];
	NSString *template = @"Prefix \n Section name1 text1 EndSection \n Intermediate \n Section name2 text2 EndSection \n Suffix";
	// execute
	BOOL result = [loader parseTemplate:template error:nil];
	// verify
	assertThatBool(result, equalToBool(YES));
	assertThatInteger([loader.templateSections count], equalToInteger(2));
	assertThat([loader.templateSections objectForKey:@"name1"], is(@"text1"));
	assertThat([loader.templateSections objectForKey:@"name2"], is(@"text2"));
}

- (void)testParseTemplate_sections_shouldReadComplexTemplateSectionValue {
	// setup
	GBTemplateHandler *loader = [GBTemplateHandler handler];
	NSString *template = @"Section name \nfirst line\nsecond line\nEndSection";
	// execute
	BOOL result = [loader parseTemplate:template error:nil];
	// verify
	assertThatBool(result, equalToBool(YES));
	assertThatInteger([loader.templateSections count], equalToInteger(1));
	assertThat([loader.templateSections objectForKey:@"name"], is(@"first line\nsecond line"));
}

- (void)testParseTemplate_sections_shouldClearBeforeReading {
	// setup
	GBTemplateHandler *loader = [GBTemplateHandler handler];
	[loader parseTemplate:@"Section name1 text1 EndSection" error:nil];
	// execute
	BOOL result = [loader parseTemplate:@"Section name2 text2 EndSection" error:nil];
	// verify
	assertThatBool(result, equalToBool(YES));
	assertThatInteger([loader.templateSections count], equalToInteger(1));
	assertThat([loader.templateSections objectForKey:@"name1"], is(nil));
	assertThat([loader.templateSections objectForKey:@"name2"], isNot(nil));
}

#pragma mark Template string

- (void)testParseTemplate_string_shouldCopyWholeTextIfNoTemplateSectionFound {
	// setup
	GBTemplateHandler *loader = [GBTemplateHandler handler];
	NSString *template = @"This is template text";
	// execute
	BOOL result = [loader parseTemplate:template error:nil];
	// verify
	assertThatBool(result, equalToBool(YES));
	assertThat(loader.templateString, is(@"This is template text"));
	assertThatInteger([loader.templateSections count], equalToInteger(0));
}

- (void)testParseTemplate_string_shouldTrimStringBeforeTemplateSections {
	// setup
	GBTemplateHandler *loader = [GBTemplateHandler handler];
	NSString *template = @"This is template text Section name text EndSection";
	// execute
	BOOL result = [loader parseTemplate:template error:nil];
	// verify
	assertThatBool(result, equalToBool(YES));
	assertThat(loader.templateString, is(@"This is template text"));
}

- (void)testParseTemplate_string_shouldTrimStringBetweenTemplateSections {
	// setup
	GBTemplateHandler *loader = [GBTemplateHandler handler];
	NSString *template = @"Section name1 text EndSection This is text in the middle Section name2 text EndSection";
	// execute
	BOOL result = [loader parseTemplate:template error:nil];
	// verify
	assertThatBool(result, equalToBool(YES));
	assertThat(loader.templateString, is(@"This is text in the middle"));
}

- (void)testParseTemplate_string_shouldTrimStringAfterTemplateSections {
	// setup
	GBTemplateHandler *loader = [GBTemplateHandler handler];
	NSString *template = @"Section name text EndSection This is template text";
	// execute
	BOOL result = [loader parseTemplate:template error:nil];
	// verify
	assertThatBool(result, equalToBool(YES));
	assertThat(loader.templateString, is(@"This is template text"));
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
	assertThatBool(result, equalToBool(YES));
	assertThat(loader.templateString, is(@"Some text\nin multiple lines\nFollowed\nby middle\ntext\nAnd by some\n\tprefix"));
	assertThatInteger([loader.templateSections count], equalToInteger(2));
	assertThat([loader.templateSections objectForKey:@"name1"], is(@"text\nline2"));
	assertThat([loader.templateSections objectForKey:@"name2"], is(@"text2\n\tline2"));
}

#pragma mark Template handling

- (void)testParsetTemplate_template_shouldCreateTemplateInstance {
	// setup
	GBTemplateHandler *loader = [GBTemplateHandler handler];
	NSString *template = @"Something Section name text EndSection";
	// execute
	[loader parseTemplate:template error:nil];
	// verify
	assertThat(loader.template, isNot(nil));
}

- (void)testParseTemplate_template_shouldSetEmptyTemplateIfEmptyTemplateIsGiven {
	// setup
	GBTemplateHandler *loader = [GBTemplateHandler handler];
	// execute
	[loader parseTemplate:@"" error:nil];
	// verify
	assertThat(loader.template, is(nil));
}

- (void)testParseTemplate_template_shouldResetTemplateInstanceIfEmptyTemplateIsGiven {
	// setup
	GBTemplateHandler *loader = [GBTemplateHandler handler];
	[loader parseTemplate:@"Something" error:nil];
	// execute
	[loader parseTemplate:@"" error:nil];
	// verify
	assertThat(loader.template, is(nil));
}

#pragma mark Rendering handling (just simple testing, we rely on GRMustache for correct behavior!)

- (void)testRenderObject_shouldRenderSimpleTemplate {
	// setup
	GBTemplateHandler *loader = [GBTemplateHandler handler];
	[loader parseTemplate:@"prefix {{var1}}---{{var2}} suffix" error:nil];
	// execute
	NSString *result = [loader renderObject:[NSDictionary dictionaryWithObjectsAndKeys:@"value1", @"var1", @"value2", @"var2", nil]];
	// verify
	assertThat(result, is(@"prefix value1---value2 suffix"));
}

- (void)testRenderObject_shouldRenderSectionIfCalled {
	// setup
	GBTemplateHandler *loader = [GBTemplateHandler handler];
	[loader parseTemplate:@"prefix {{>name}}! Section name text EndSection" error:nil];
	// execute
	NSString *result = [loader renderObject:nil];
	// verify
	assertThat(result, is(@"prefix text!"));
}

- (void)testRenderObject_shouldNotRenderSectionIfNotCalled {
	// setup
	GBTemplateHandler *loader = [GBTemplateHandler handler];
	[loader parseTemplate:@"prefix Section name text EndSection" error:nil];
	// execute
	NSString *result = [loader renderObject:nil];
	// verify
	assertThat(result, is(@"prefix"));
}

- (void)testRenderObject_shouldPassProperObjectToSections {
	// setup
	GBTemplateHandler *loader = [GBTemplateHandler handler];
	[loader parseTemplate:@"prefix {{#var1}}{{>name}}{{/var1}}! {{#var2}}{{>name}}{{/var2}}? Section name {{value}} EndSection" error:nil];
	NSDictionary *var1 = [NSDictionary dictionaryWithObjectsAndKeys:@"value1", @"value", nil];
	NSDictionary *var2 = [NSDictionary dictionaryWithObjectsAndKeys:@"value2", @"value", nil];
	// execute
	NSString *result = [loader renderObject:[NSDictionary dictionaryWithObjectsAndKeys:var1, @"var1", var2, @"var2", nil]];
	// verify
	assertThat(result, is(@"prefix value1! value2?"));
}

@end
