//
//  GBTemplateReaderTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 1.10.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBTemplateReader.h"
#import "GBTemplateWriter.h"
#import "GBTokenizer.h"

@interface GBTemplateWriterTesting : GHTestCase

- (GBTemplateWriter *)defaultWriter;
- (GBTemplateReader *)readerWithTemplate:(NSString *)string;

@end

@implementation GBTemplateWriterTesting

#pragma mark Basic writing testing

- (void)testOutputStringWithReaderVariables_shouldUseGivenVariablesInTemplate {
	// setup
	GBTemplateReader *reader = [self readerWithTemplate:@"{{ var2 }} {{ var1 }}"];
	GBTemplateWriter *writer = [self defaultWriter];
	NSDictionary *variables = [NSDictionary dictionaryWithObjectsAndKeys:@"val1", @"var1", @"val2", @"var2", nil];
	// execute
	NSString *output = [writer outputStringWithReader:reader variables:variables];
	// verify
	assertThat(output, is(@"val2 val1"));
}

- (void)testOutputStringWithReaderVariables_shouldAddApplicationStringTemplates {
	// setup
	GBTemplateReader *reader = [self readerWithTemplate:@"{{ var }} {{ strings.objectOverview.title }}"];
	GBTemplateWriter *writer = [self defaultWriter];
	NSDictionary *variables = [NSDictionary dictionaryWithObjectsAndKeys:@"value", @"var", nil];
	// execute
	NSString *output = [writer outputStringWithReader:reader variables:variables];
	// verify
	assertThat(output, is(@"value Overview"));
}

- (void)testOutputStringWithReaderVariables_shouldDisableOutputWithinFalseIfBlock {
	// setup
	GBTemplateReader *reader = [self readerWithTemplate:@"{% if 1 == 0 %}invalid{% else %}valid{% /if %}"];
	GBTemplateWriter *writer = [self defaultWriter];
	// execute
	NSString *output = [writer outputStringWithReader:reader variables:nil];
	// verify
	assertThat(output, is(@"valid"));
}

- (void)testOutputStringWithReaderVariables_shouldDisableOutputWithinFalseIfBlockContainingFor {
	// setup
	GBTemplateReader *reader = [self readerWithTemplate:@"{% if 1 == 0 %}\n({% for 1 to 5 %}{% /for %})\n{% else %}valid{% /if %}"];
	GBTemplateWriter *writer = [self defaultWriter];
	// execute
	NSString *output = [writer outputStringWithReader:reader variables:nil];
	// verify
	assertThat(output, is(@"valid"));
}

#pragma mark Template sections handling

- (void)testOutputStringWithReaderVariables_shouldIgnoreNotReferencedTemplateSections {
	// setup
	GBTemplateReader *reader = [self readerWithTemplate:@"{% section template Name %}hola{% /section %}"];
	GBTemplateWriter *writer = [self defaultWriter];
	// execute
	NSString *output = [writer outputStringWithReader:reader variables:nil];
	// verify
	assertThat(output, is(@""));
}

- (void)testOutputStringWithReaderVariables_shouldExecuteReferencedTemplateSections {
	// setup
	GBTemplateReader *reader = [self readerWithTemplate:@"{% section execute Name %}{% /section %}{% section template Name %}hola{% /section %}"];
	GBTemplateWriter *writer = [self defaultWriter];
	// execute
	NSString *output = [writer outputStringWithReader:reader variables:nil];
	// verify
	assertThat(output, is(@"hola"));
}

- (void)testOutputStringWithReaderVariables_shouldExecuteTemplateSectionWithArguments {
	// setup
	GBTemplateReader *reader = [self readerWithTemplate:@"{% for v in args %}{% section execute Name var v %}{% /section %}{% /for %}{% section template Name var %}{{ var }}{% /section %}"];
	GBTemplateWriter *writer = [self defaultWriter];
	NSArray *array = [NSArray arrayWithObjects:@"a", @"b", @"c", nil];
	NSDictionary *variables = [NSDictionary dictionaryWithObjectsAndKeys:array, @"args", nil];
	// execute
	NSString *output = [writer outputStringWithReader:reader variables:variables];
	// verify
	assertThat(output, is(@"abc"));
}

- (void)testOutputStringWithReaderVariables_shouldIgnoreUnknownTemplateSection {
	// setup
	GBTemplateReader *reader = [self readerWithTemplate:@"{% section execute Unknown %}{% /section %}{% section template Name %}hola{% /section %}"];
	GBTemplateWriter *writer = [self defaultWriter];
	// execute
	NSString *output = [writer outputStringWithReader:reader variables:nil];
	// verify
	assertThat(output, is(@""));
}

- (void)testOutputStringWithReaderVariables_shouldIgnoreTemplateSectionIfNoArgumentsArePassed {
	// setup
	GBTemplateReader *reader = [self readerWithTemplate:@"{% section execute Name %}{% /section %}{% section template Name var %}hola{% /section %}"];
	GBTemplateWriter *writer = [self defaultWriter];
	// execute
	NSString *output = [writer outputStringWithReader:reader variables:nil];
	// verify
	assertThat(output, is(@""));
}

- (void)testOutputStringWithReaderVariables_shouldIgnoreTemplateSectionIfInvalidArgumentsArePassed {
	// setup
	GBTemplateReader *reader = [self readerWithTemplate:@"{% section execute Name unknown %}{% /section %}{% section template Name var %}hola{% /section %}"];
	GBTemplateWriter *writer = [self defaultWriter];
	// execute
	NSString *output = [writer outputStringWithReader:reader variables:nil];
	// verify
	assertThat(output, is(@""));
}

#pragma mark Creation methods

- (GBTemplateWriter *)defaultWriter {
	return [GBTemplateWriter writerWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
}

- (GBTemplateReader *)readerWithTemplate:(NSString *)string {
	GBTemplateReader *result = [GBTemplateReader readerWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	[result readTemplateSectionsFromTemplate:string];
	return result;
}

@end
