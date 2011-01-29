//
//  GBCommentComponentsProviderTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 29.1.11.
//  Copyright (C) 2011 Gentle Bytes. All rights reserved.
//

#import "GBApplicationSettingsProvider.h"
#import "GBCommentComponentsProvider.h"

@interface GBCommentComponentsProviderTesting : GHTestCase
@end
	
@implementation GBCommentComponentsProviderTesting

- (void)testInitializer_shouldPrepareOptionalCrossReferencePrefixAndSuffix {
	// setup & execute
	GBCommentComponentsProvider *provider = [GBCommentComponentsProvider provider];
	// verify
	assertThat(provider.crossReferenceMarkersTemplate, is(@"<?%@>?"));
}

@end
