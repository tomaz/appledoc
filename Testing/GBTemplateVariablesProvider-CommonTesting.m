//
//  GBTemplateVariablesProvider-CommonTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 1.10.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBApplicationSettingsProvider.h"
#import "GBTemplateVariablesProvider.h"
#import "GBTokenizer.h"

@interface GBTemplateVariablesProviderCommonTesting : GHTestCase
@end

@implementation GBTemplateVariablesProviderCommonTesting

- (void)testVariablesForClass_shouldPrepareDefaultVariables {
	// setup
	GBTemplateVariablesProvider *provider = [GBTemplateVariablesProvider providerWithSettingsProvider:[GBApplicationSettingsProvider provider]];
	GBClassData *class = [GBClassData classDataWithName:@"Class"];	
	// execute
	NSDictionary *vars = [provider variablesForClass:class withStore:[GBTestObjectsRegistry store]];
	// verify - just basic tests...
	assertThat([vars objectForKey:@"page"], isNot(nil));
	assertThat([vars valueForKeyPath:@"page.cssPath"], isNot(nil));
	assertThat([vars valueForKeyPath:@"page.title"], isNot(nil));
	assertThat([vars valueForKeyPath:@"page.specifications"], isNot(nil));
	assertThat([vars objectForKey:@"object"], is(class));
}

@end
