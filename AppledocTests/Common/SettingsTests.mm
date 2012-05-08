//
//  SettingsTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/13/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "GBSettings+Appledoc.h"
#import "TestCaseBase.hh"

static void runWithSettings(void(^handler)(GBSettings *settings)) {
	GBSettings *settings = [[GBSettings appledocSettingsWithName:@"name" parent:nil] retain];
	handler(settings);
}

#pragma mark - 

TEST_BEGIN(SettingsTests)

describe(@"initializer:", ^{
	it(@"should initialize all array keys", ^{		
		// setup & execute
		GBSettings *settings = [GBSettings appledocSettingsWithName:@"name" parent:nil];
		// verify
		[settings isKeyArray:GBOptions.inputPaths] should equal(YES);
		[settings isKeyArray:GBOptions.ignoredPaths] should equal(YES);
	});
});

context(@"cmd line switches", ^{
	it(@"should work for project related settings", ^{
		runWithSettings(^(GBSettings *settings) {
			// execute
			[settings setObject:@"1" forKey:GBOptions.projectName];
			[settings setObject:@"2" forKey:GBOptions.projectVersion];
			[settings setObject:@"3" forKey:GBOptions.companyName];
			[settings setObject:@"4" forKey:GBOptions.companyIdentifier];
			// verify
			settings.projectName should equal(@"1");
			settings.projectVersion should equal(@"2");
			settings.companyName should equal(@"3");
			settings.companyIdentifier should equal(@"4");
		});
	});
	
	it(@"should work for path related settings", ^{
		runWithSettings(^(GBSettings *settings) {
			// execute
			[settings setObject:@"input" forKey:GBOptions.inputPaths];
			[settings setObject:@"ignore" forKey:GBOptions.ignoredPaths];
			[settings setObject:@"template" forKey:GBOptions.templatesPath];
			// verify
			settings.inputPaths.count should equal(1);
			settings.inputPaths should contain(@"input");
			settings.ignoredPaths.count should equal(1);
			settings.ignoredPaths should contain(@"ignore");
			settings.templatesPath should equal(@"template");
		});
	});
	
	it(@"should work for logging related properties", ^{
		runWithSettings(^(GBSettings *settings) {
			// execute
			[settings setInteger:2 forKey:GBOptions.loggingFormat];
			[settings setInteger:3 forKey:GBOptions.loggingLevel];
			[settings setBool:YES forKey:GBOptions.loggingInternalEnabled];
			[settings setBool:YES forKey:GBOptions.loggingCommonEnabled];
			[settings setBool:YES forKey:GBOptions.loggingStoreEnabled];
			[settings setBool:YES forKey:GBOptions.loggingParsingEnabled];
			// verify
			settings.loggingFormat should equal(2);
			settings.loggingLevel should equal(3);
			settings.loggingInternalEnabled should equal(YES);
			settings.loggingCommonEnabled should equal(YES);
			settings.loggingStoreEnabled should equal(YES);
			settings.loggingParsingEnabled should equal(YES);
		});
	});
	
	it(@"should work for debugging aid related properties", ^{
		runWithSettings(^(GBSettings *settings) {
			// execute
			[settings setBool:YES forKey:GBOptions.printSettings];
			[settings setBool:YES forKey:GBOptions.printVersion];
			[settings setBool:YES forKey:GBOptions.printHelp];
			// verify
			settings.printSettings should equal(YES);
			settings.printVersion should equal(YES);
			settings.printHelp should equal(YES);
		});
	});
});

TEST_END
