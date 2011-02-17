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
- (NSString *)stringByConvertingCrossReferencesInString:(NSString *)string;
@end

#pragma mark -

@interface GBCommentsProcessorPreprocessingTesting : GBObjectsAssertor

- (GBCommentsProcessor *)processorWithClass;

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

#pragma mark Cross references detection

- (void)testStringByConvertingCrossReferencesInString_shouldConvertHTML {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	// execute
	NSString *result1 = [processor stringByConvertingCrossReferencesInString:@"http://gentlebytes.com"];
	NSString *result2 = [processor stringByConvertingCrossReferencesInString:@"https://gentlebytes.com"];
	NSString *result3 = [processor stringByConvertingCrossReferencesInString:@"<http://gentlebytes.com>"];
	NSString *result4 = [processor stringByConvertingCrossReferencesInString:@"<https://gentlebytes.com>"];
	// verify
	assertThat(result1, is(@"[http://gentlebytes.com](http://gentlebytes.com)"));
	assertThat(result2, is(@"[https://gentlebytes.com](https://gentlebytes.com)"));
	assertThat(result3, is(@"[http://gentlebytes.com](http://gentlebytes.com)"));
	assertThat(result4, is(@"[https://gentlebytes.com](https://gentlebytes.com)"));
}

- (void)testStringByConvertingCrossReferencesInString_shouldConvertFTP {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	// execute
	NSString *result1 = [processor stringByConvertingCrossReferencesInString:@"ftp://gentlebytes.com"];
	NSString *result2 = [processor stringByConvertingCrossReferencesInString:@"ftps://gentlebytes.com"];
	NSString *result3 = [processor stringByConvertingCrossReferencesInString:@"<ftp://gentlebytes.com>"];
	NSString *result4 = [processor stringByConvertingCrossReferencesInString:@"<ftps://gentlebytes.com>"];
	// verify
	assertThat(result1, is(@"[ftp://gentlebytes.com](ftp://gentlebytes.com)"));
	assertThat(result2, is(@"[ftps://gentlebytes.com](ftps://gentlebytes.com)"));
	assertThat(result3, is(@"[ftp://gentlebytes.com](ftp://gentlebytes.com)"));
	assertThat(result4, is(@"[ftps://gentlebytes.com](ftps://gentlebytes.com)"));
}

- (void)testStringByConvertingCrossReferencesInString_shouldConvertNewsAndRSS {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	// execute
	NSString *result1 = [processor stringByConvertingCrossReferencesInString:@"news://gentlebytes.com"];
	NSString *result2 = [processor stringByConvertingCrossReferencesInString:@"rss://gentlebytes.com"];
	NSString *result3 = [processor stringByConvertingCrossReferencesInString:@"<news://gentlebytes.com>"];
	NSString *result4 = [processor stringByConvertingCrossReferencesInString:@"<rss://gentlebytes.com>"];
	// verify
	assertThat(result1, is(@"[news://gentlebytes.com](news://gentlebytes.com)"));
	assertThat(result2, is(@"[rss://gentlebytes.com](rss://gentlebytes.com)"));
	assertThat(result3, is(@"[news://gentlebytes.com](news://gentlebytes.com)"));
	assertThat(result4, is(@"[rss://gentlebytes.com](rss://gentlebytes.com)"));
}

- (void)testStringByConvertingCrossReferencesInString_shouldConvertFile {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	// execute
	NSString *result1 = [processor stringByConvertingCrossReferencesInString:@"file://gentlebytes.com"];
	NSString *result2 = [processor stringByConvertingCrossReferencesInString:@"<file://gentlebytes.com>"];
	// verify
	assertThat(result1, is(@"[file://gentlebytes.com](file://gentlebytes.com)"));
	assertThat(result2, is(@"[file://gentlebytes.com](file://gentlebytes.com)"));
}

- (void)testStringByConvertingCrossReferencesInString_shouldConvertMailto {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	// execute
	NSString *result1 = [processor stringByConvertingCrossReferencesInString:@"mailto:appledoc@gentlebytes.com"];
	NSString *result2 = [processor stringByConvertingCrossReferencesInString:@"<mailto:appledoc@gentlebytes.com>"];
	// verify
	assertThat(result1, is(@"[appledoc@gentlebytes.com](mailto:appledoc@gentlebytes.com)"));
	assertThat(result2, is(@"[appledoc@gentlebytes.com](mailto:appledoc@gentlebytes.com)"));
}

#pragma mark Creation methods

- (GBCommentsProcessor *)processorWithClass {
	// Creates a new GBCommentsProcessor using real settings and store with a single GBClassData representing `Class` with a single method `method:`.
	GBMethodData *method = [GBTestObjectsRegistry instanceMethodWithNames:@"method", nil];
	GBClassData *class = [GBTestObjectsRegistry classWithName:@"Class" methods:method, nil];
	GBStore *store = [GBTestObjectsRegistry storeWithObjects:class, nil];
	
	id settings = [GBTestObjectsRegistry realSettingsProvider];
	GBCommentsProcessor *result = [GBCommentsProcessor processorWithSettingsProvider:settings];
	[result setValue:store forKey:@"store"];
	return result;
}

@end
