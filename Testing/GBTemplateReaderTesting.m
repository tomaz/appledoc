//
//  GBTemplateReaderTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 30.9.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBTemplateReader.h"
#import "GBTokenizer.h"

@interface GBTemplateReaderTesting : GHTestCase
@end

@implementation GBTemplateReaderTesting

#pragma mark Basic reading testing

- (void)testReadTemplateSectionsFromTemplate_shouldDetectTemplateWithNoArguments {
	// setup
	GBTemplateReader *reader = [GBTemplateReader readerWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	NSString *template = @"{% section template name %}{% /section %}";
	// execute
	[reader readTemplateSectionsFromTemplate:template];
	// verify
	assertThatInteger([reader.templates count], equalToInteger(1));
	assertThat([reader.templates objectForKey:@"name"], isNot(nil));
	assertThat([[reader.templates objectForKey:@"name"] objectForKey:@"template"], is(@""));
	assertThatInteger([[[reader.templates objectForKey:@"name"] objectForKey:@"arguments"] count], equalToInteger(0));
}

- (void)testReadTemplateSectionsFromTemplate_shouldDetectTemplateWithArguments {
	// setup
	GBTemplateReader *reader = [GBTemplateReader readerWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	NSString *template = @"{% section template name arg1 arg2 %}{% /section %}";
	// execute
	[reader readTemplateSectionsFromTemplate:template];
	// verify
	assertThatInteger([reader.templates count], equalToInteger(1));
	assertThat([reader.templates objectForKey:@"name"], isNot(nil));
	assertThat([[reader.templates objectForKey:@"name"] objectForKey:@"template"], is(@""));
	assertThatInteger([[[reader.templates objectForKey:@"name"] objectForKey:@"arguments"] count], equalToInteger(2));
}

- (void)testReadTemplateSectionsFromTemplate_shouldDetectTemplateString {
	// setup
	GBTemplateReader *reader = [GBTemplateReader readerWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	NSString *template = @"{% section template name %}The string{% /section %}";
	// execute
	[reader readTemplateSectionsFromTemplate:template];
	// verify
	assertThat([[reader.templates objectForKey:@"name"] objectForKey:@"template"], is(@"The string"));
}

#pragma mark Multiple templates testing

- (void)testReadTemplateSectionsFromTemplate_shouldDetectAllTemplates {
	// setup
	GBTemplateReader *reader = [GBTemplateReader readerWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	NSString *template = @"{% section template name1 %}{% /section %}{% section template name2 %}{% /section %}";
	// execute
	[reader readTemplateSectionsFromTemplate:template];
	// verify
	assertThatInteger([reader.templates count], equalToInteger(2));
	assertThat([reader.templates objectForKey:@"name1"], isNot(nil));
	assertThat([reader.templates objectForKey:@"name2"], isNot(nil));
}

- (void)testReadTemplateSectionsFromTemplate_shouldDetectProperKeywordedTemplates {
	// setup
	GBTemplateReader *reader = [GBTemplateReader readerWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	NSString *template = @"{% section template name1 %}{% /section %}{% section atemplate name2 %}{% /section %}";
	// execute
	[reader readTemplateSectionsFromTemplate:template];
	// verify
	assertThatInteger([reader.templates count], equalToInteger(1));
	assertThat([reader.templates objectForKey:@"name1"], isNot(nil));
	assertThat([reader.templates objectForKey:@"name2"], is(nil));
}

#pragma mark Complex scenarios handling

- (void)testReadTemplateSectionsFromTemplate_shouldDetectTemplateContainingMarkers {
	// setup
	GBTemplateReader *reader = [GBTemplateReader readerWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	NSString *template = @"{% section template name %}{% for p in pars %}- this {{ p }}\n{% /for %}{% /section %}";
	// execute
	[reader readTemplateSectionsFromTemplate:template];
	// verify
	assertThat([[reader.templates objectForKey:@"name"] objectForKey:@"template"], is(@"{% for p in pars %}- this {{ p }}\n{% /for %}"));
}

- (void)testReadTemplateSectionsFromTemplate_shouldDetectTemplateWithinTrueIfBlock {
	// setup
	GBTemplateReader *reader = [GBTemplateReader readerWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	NSString *template = @"{% if 1 == 1 %}{% section template NAME %}value{% /section %}{% /if %}";
	// execute
	[reader readTemplateSectionsFromTemplate:template];
	// verify
	assertThatInteger([reader.templates count], equalToInteger(1));
	assertThat([[reader.templates objectForKey:@"NAME"] objectForKey:@"template"], is(@"value"));
}

- (void)testReadTemplateSectionsFromTemplate_shouldIgnoreTemplateWithinFalseIfBlock {
	// setup
	GBTemplateReader *reader = [GBTemplateReader readerWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	NSString *template = @"{% if 1 == 0 %}{% section template NAME %}value{% /section %}{% /if %}";
	// execute
	[reader readTemplateSectionsFromTemplate:template];
	// verify
	assertThatInteger([reader.templates count], equalToInteger(0));
}

#pragma mark Miscellaneous template handling

- (void)testReadTemplateSectionsFromTemplate_shouldDeleteSectionStringFromAssignedTemplate {
	// setup
	GBTemplateReader *reader = [GBTemplateReader readerWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	NSString *template = @"PREFIX {% section template name1 %}value1{% /section %} MIDDLE {% section template name2 %}{% /section %} SUFFIX";
	// execute
	[reader readTemplateSectionsFromTemplate:template];
	// verify
	assertThat(reader.templateString, is(@"PREFIX  MIDDLE  SUFFIX"));
}

#pragma mark Values return testing

- (void)testValueOfTemplateWithName_shouldReturnTemplateValue {
	// setup
	GBTemplateReader *reader = [GBTemplateReader readerWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	NSString *template = @"{% section template name %}value{% /section %}";
	// execute
	[reader readTemplateSectionsFromTemplate:template];
	// verify
	assertThat([reader valueOfTemplateWithName:@"name"], is(@"value"));
}

- (void)testArgumentsOfTemplateWithName_shouldReturnTemplateArguments {
	// setup
	GBTemplateReader *reader = [GBTemplateReader readerWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	NSString *template = @"{% section template name arg1 %}value{% /section %}";
	// execute
	[reader readTemplateSectionsFromTemplate:template];
	// verify
	assertThatInteger([[reader argumentsOfTemplateWithName:@"name"] count], equalToInteger(1));
	assertThat([[reader argumentsOfTemplateWithName:@"name"] objectAtIndex:0], is(@"arg1"));
}

@end
