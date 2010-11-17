//
//  GBTemplateLoaderTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 17.11.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBTemplateLoader.h"

@interface GBTemplateLoaderTesting : GHTestCase
@end

@implementation GBTemplateLoaderTesting

- (void)testParseTemplate_shouldReadSimpleTemplate {
	// setup
	GBTemplateLoader *loader = [GBTemplateLoader loader];
	NSString *template = @"Section name text EndSection";
	// execute
	[loader parseTemplate:template error:nil];
	// verify
	assertThatInteger([loader.templateSections count], equalToInteger(1));
	assertThat([loader.templateSections objectForKey:@"name"], is(@"text"));
}

- (void)testParseTemplateError_shouldReadAllTemplates {
	// setup
	GBTemplateLoader *loader = [GBTemplateLoader loader];
	NSString *template = @"Prefix \n Section name1 text1 EndSection \n Intermediate \n Section name2 text2 EndSection \n Suffix";
	// execute
	[loader parseTemplate:template error:nil];
	// verify
	assertThatInteger([loader.templateSections count], equalToInteger(2));
	assertThat([loader.templateSections objectForKey:@"name1"], is(@"text1"));
	assertThat([loader.templateSections objectForKey:@"name2"], is(@"text2"));
}

- (void)testParseTemplate_shouldClearBeforeReading {
	// setup
	GBTemplateLoader *loader = [GBTemplateLoader loader];
	[loader parseTemplate:@"Section name1 text1 EndSection" error:nil];
	// execute
	[loader parseTemplate:@"Section name2 text2 EndSection" error:nil];
	// verify
	assertThatInteger([loader.templateSections count], equalToInteger(1));
	assertThat([loader.templateSections objectForKey:@"name1"], is(nil));
	assertThat([loader.templateSections objectForKey:@"name2"], isNot(nil));
}

@end
