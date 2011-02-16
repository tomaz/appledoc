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

- (void)testStringByPreprocessingString_shouldConvertSingleBoldMarkers {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	// execute
	NSString *result1 = [processor stringByPreprocessingString:@"*bold*"];
	NSString *result2 = [processor stringByPreprocessingString:@"Prefix *bold*"];
	NSString *result3 = [processor stringByPreprocessingString:@"*bold* Suffix"];
	NSString *result4 = [processor stringByPreprocessingString:@"Prefix *bold* Suffix"];
	// verify
	assertThat(result1, is(@"**bold**"));
	assertThat(result2, is(@"Prefix **bold**"));
	assertThat(result3, is(@"**bold** Suffix"));
	assertThat(result4, is(@"Prefix **bold** Suffix"));
}

- (void)testStringByPreprocessingString_shouldConvertMultipleBoldMarkers {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	// execute
	NSString *result1 = [processor stringByPreprocessingString:@"*bold1* *bold text*"];
	NSString *result2 = [processor stringByPreprocessingString:@"*bold1* Middle *bold text*"];
	// verify
	assertThat(result1, is(@"**bold1** **bold text**"));
	assertThat(result2, is(@"**bold1** Middle **bold text**"));
}

- (void)testStringByPreprocessingString_shouldConvertBoldItalicsMarkers {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	// execute
	NSString *result = [processor stringByPreprocessingString:@"_*text1*_ *_marked text_*"];
	// verify
	assertThat(result, is(@"***text1*** ***marked text***"));
}

- (void)testStringByPreprocessingString_shouldKeepStandardMarkers {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	// execute
	NSString *result = [processor stringByPreprocessingString:@"_emph_ `mono`"];
	// verify
	assertThat(result, is(@"_emph_ `mono`"));
}

@end
