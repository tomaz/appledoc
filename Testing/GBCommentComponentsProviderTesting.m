//
//  GBCommentComponentsProviderTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 29.1.11.
//  Copyright (C) 2011 Gentle Bytes. All rights reserved.
//

#import "GBApplicationSettingsProvider.h"
#import "GBCommentComponentsProvider.h"

@interface GBCommentComponentsProvider (TestingAPI)
- (NSString *)crossReferenceTemplateValue;
@end

@implementation GBCommentComponentsProvider (TestingAPI)

- (NSString *)crossReferenceTemplateValue {
	return [self valueForKey:@"crossReferenceTemplate"];
}

@end

#pragma mark -

@interface GBCommentComponentsProviderTesting : GHTestCase
@end
	
@implementation GBCommentComponentsProviderTesting

- (void)testInitializer_shouldPrepareOptionalCrossReferencePrefixAndSuffix {
	// setup & execute
	GBCommentComponentsProvider *provider = [GBCommentComponentsProvider provider];
	// verify
	assertThat(provider.crossReferenceTemplateValue, is(@"<?%@>?"));
}

- (void)testSetCrossReferenceTemplate_shouldChangeCrossReferenceTemplate {
	// setup
	GBCommentComponentsProvider *provider = [GBCommentComponentsProvider provider];
	// execute
	[provider setCrossReferenceMarkers:@"PREFIX%@SUFFIX"];
	// verify
	assertThat(provider.crossReferenceTemplateValue, is(@"PREFIX%@SUFFIX"));
}

- (void)testSetCrossReferenceTemplate_throwsIfTemplateIsNotGiven {
	// setup
	GBCommentComponentsProvider *provider = [GBCommentComponentsProvider provider];
	// execute & verify
	GHAssertThrows([provider setCrossReferenceMarkers:@"aaaa"], @"");
}

@end
