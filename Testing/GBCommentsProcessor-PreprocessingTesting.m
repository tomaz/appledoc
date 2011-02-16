//
//  GBCommentsProcessor-PreprocessingTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 14.2.11.
//  Copyright (C) 2011 Gentle Bytes. All rights reserved.
//

#import "GBApplicationSettingsProvider.h"
#import "GBDataObjects.h"
#import "GBStore.h"
#import "GBCommentsProcessor.h"

@interface GBCommentsProcessor (PrivateAPI)
- (NSString *)stringByPreprocessingString:(NSString *)string;
@end

#pragma mark -

@interface GBCommentsProcessorPreprocessingTesting : GBObjectsAssertor
@end

#pragma mark -

@implementation GBCommentsProcessorPreprocessingTesting

#pragma mark Formatting markers conversion

- (void)testStringByPreprocessingString_shouldHandleBoldMarkers {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	// execute
	NSString *result1 = [processor stringByPreprocessingString:@"*bold1* *bold text* * bolder text *"];
	NSString *result2 = [processor stringByPreprocessingString:@"*bold1* Middle *bold text*"];
	// verify
	assertThat(result1, is(@"**bold1** **bold text** ** bolder text **"));
	assertThat(result2, is(@"**bold1** Middle **bold text**"));
}

- (void)testStringByPreprocessingString_shouldHandleItalicsMarkers {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	// execute
	NSString *result1 = [processor stringByPreprocessingString:@"_bold1_ _bold text_ _ bolder text _"];
	NSString *result2 = [processor stringByPreprocessingString:@"_bold1_ Middle _bold text_"];
	// verify
	assertThat(result1, is(@"_bold1_ _bold text_ _ bolder text _"));
	assertThat(result2, is(@"_bold1_ Middle _bold text_"));
}

- (void)testStringByPreprocessingString_shouldHandleBoldItalicsMarkers {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	// execute
	NSString *result = [processor stringByPreprocessingString:@"_*text1*_ *_marked text_* _* text2 *_"];
	// verify
	assertThat(result, is(@"***text1*** ***marked text*** *** text2 ***"));
}

- (void)testStringByPreprocessingString_shouldHandleMonospaceMarkers {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	// execute
	NSString *result = [processor stringByPreprocessingString:@"`mono` ` monoer `"];
	// verify
	assertThat(result, is(@"`mono` ` monoer `"));
}

- (void)testStringByPreprocessingString_shouldHandleMarkdownBoldMarkers {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	// execute
	NSString *result1 = [processor stringByPreprocessingString:@"__text1__ __ marked __"];
	NSString *result2 = [processor stringByPreprocessingString:@"**text1** ** marked **"];
	// verify
	assertThat(result1, is(@"**text1** ** marked **"));
	assertThat(result2, is(@"**text1** ** marked **"));
}

- (void)testStringByPreprocessingString_shouldHandleMarkdownBoldItalicsMarkers {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	// execute
	NSString *result1 = [processor stringByPreprocessingString:@"__*text1*__ __* marked *__"];
	NSString *result2 = [processor stringByPreprocessingString:@"_**text1**_ _** marked **_"];
	NSString *result3 = [processor stringByPreprocessingString:@"*__text1__* *__ marked __*"];
	NSString *result4 = [processor stringByPreprocessingString:@"**_text1_** **_ marked _**"];
	NSString *result5 = [processor stringByPreprocessingString:@"___text1___ ___ marked ___"];
	NSString *result6 = [processor stringByPreprocessingString:@"***text1*** *** marked ***"];
	// verify
	assertThat(result1, is(@"***text1*** *** marked ***"));
	assertThat(result2, is(@"***text1*** *** marked ***"));
	assertThat(result3, is(@"***text1*** *** marked ***"));
	assertThat(result4, is(@"***text1*** *** marked ***"));
	assertThat(result5, is(@"***text1*** *** marked ***"));
	assertThat(result6, is(@"***text1*** *** marked ***"));
}

@end
