//
//  GBTemplateLoaderTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 17.11.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GRMustache.h"
#import "GBTemplateLoader.h"

@interface GBTemplateLoader (TestingAPI)
@property (readonly) NSString *templateString;
@property (readonly) NSDictionary *templateSections;
@property (readonly) GRMustacheTemplate *template;
@end

@implementation GBTemplateLoader (TestingAPI)
- (NSString *)templateString { return [self valueForKey:@"_templateString"]; }
- (NSDictionary *)templateSections { return [self valueForKey:@"_templateSections"]; }
- (GRMustacheTemplate *)template { return [self valueForKey:@"_template"]; }
@end

#pragma mark -

@interface GBTemplateLoaderTesting : GHTestCase
@end

@implementation GBTemplateLoaderTesting

#pragma mark Empty templates

- (void)testParseTemplate_empty_shouldIndicateSuccess {
	// setup
	GBTemplateLoader *loader = [GBTemplateLoader loader];
	// execute
	BOOL result = [loader parseTemplate:@"" error:nil];
	// verify
	assertThatBool(result, equalToBool(YES));
	assertThatInteger([loader.templateSections count], equalToInteger(0));
	assertThat(loader.templateString, is(@""));
}

- (void)testParseTemplate_empty_shouldClearBeforeReading {
	// setup
	GBTemplateLoader *loader = [GBTemplateLoader loader];
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
	GBTemplateLoader *loader = [GBTemplateLoader loader];
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
	GBTemplateLoader *loader = [GBTemplateLoader loader];
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
	GBTemplateLoader *loader = [GBTemplateLoader loader];
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
	GBTemplateLoader *loader = [GBTemplateLoader loader];
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
	GBTemplateLoader *loader = [GBTemplateLoader loader];
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
	GBTemplateLoader *loader = [GBTemplateLoader loader];
	NSString *template = @"This is template text Section name text EndSection";
	// execute
	BOOL result = [loader parseTemplate:template error:nil];
	// verify
	assertThatBool(result, equalToBool(YES));
	assertThat(loader.templateString, is(@"This is template text"));
}

- (void)testParseTemplate_string_shouldTrimStringBetweenTemplateSections {
	// setup
	GBTemplateLoader *loader = [GBTemplateLoader loader];
	NSString *template = @"Section name1 text EndSection This is text in the middle Section name2 text EndSection";
	// execute
	BOOL result = [loader parseTemplate:template error:nil];
	// verify
	assertThatBool(result, equalToBool(YES));
	assertThat(loader.templateString, is(@"This is text in the middle"));
}

- (void)testParseTemplate_string_shouldTrimStringAfterTemplateSections {
	// setup
	GBTemplateLoader *loader = [GBTemplateLoader loader];
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
	GBTemplateLoader *loader = [GBTemplateLoader loader];
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
	GBTemplateLoader *loader = [GBTemplateLoader loader];
	NSString *template = @"Something Section name text EndSection";
	// execute
	[loader parseTemplate:template error:nil];
	// verify
	assertThat(loader.template, isNot(nil));
}

- (void)testParseTemplate_template_shouldSetEmptyTemplateIfEmptyTemplateIsGiven {
	// setup
	GBTemplateLoader *loader = [GBTemplateLoader loader];
	// execute
	[loader parseTemplate:@"" error:nil];
	// verify
	assertThat(loader.template, is(nil));
}

- (void)testParseTemplate_template_shouldResetTemplateInstanceIfEmptyTemplateIsGiven {
	// setup
	GBTemplateLoader *loader = [GBTemplateLoader loader];
	[loader parseTemplate:@"Something" error:nil];
	// execute
	[loader parseTemplate:@"" error:nil];
	// verify
	assertThat(loader.template, is(nil));
}

@end
