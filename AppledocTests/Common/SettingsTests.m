//
//  SettingsTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/13/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "GBSettings+Appledoc.h"
#import "Objects+TestingPrivateAPI.h"
#import "TestCaseBase.h"

@interface SettingsTests : TestCaseBase
@end

@interface SettingsTests (CreationMethods)
- (void)runWithSettings:(void(^)(GBSettings *settings))handler;
@end

@implementation SettingsTests

#pragma mark - appledocSettingsWithName:parent:

- (void)testAppledocSettingsWithNameParentShouldSetupAllArrayKeys {
	// setup & execute
	GBSettings *settings = [GBSettings appledocSettingsWithName:@"name" parent:nil];
	// verify
	assertThatBool([settings isKeyArray:GBOptions.inputPaths], equalToBool(YES));
	assertThatBool([settings isKeyArray:GBOptions.ignoredPaths], equalToBool(YES));
}

#pragma mark - Verify we've wired up settings correctly!

- (void)testProjectPropertiesAreWiredToCorrectCmdLineSwitches {
	[self runWithSettings:^(GBSettings *settings) {
		// execute
		[settings setObject:@"1" forKey:GBOptions.projectName];
		[settings setObject:@"2" forKey:GBOptions.projectVersion];
		[settings setObject:@"3" forKey:GBOptions.companyName];
		[settings setObject:@"4" forKey:GBOptions.companyIdentifier];
		// verify
		assertThat(settings.projectName, equalTo(@"1"));
		assertThat(settings.projectVersion, equalTo(@"2"));
		assertThat(settings.companyName, equalTo(@"3"));
		assertThat(settings.companyIdentifier, equalTo(@"4"));
	}];
}

- (void)testPathsPropertiesAreWiredToCorrectCmdLineSwitches {
	[self runWithSettings:^(GBSettings *settings) {
		// execute
		[settings setObject:@"input" forKey:GBOptions.inputPaths];
		[settings setObject:@"ignore" forKey:GBOptions.ignoredPaths];
		[settings setObject:@"template" forKey:GBOptions.templatesPath];
		// verify
		assertThat(settings.inputPaths, onlyContains(@"input", nil));
		assertThat(settings.ignoredPaths, onlyContains(@"ignore", nil));
		assertThat(settings.templatesPath, equalTo(@"template"));
	}];
}

- (void)testLoggingPropertiesAreWiredToCorrectCmdLineSwitched {
	[self runWithSettings:^(GBSettings *settings) {
		// execute
		[settings setInteger:2 forKey:GBOptions.loggingFormat];
		[settings setInteger:3 forKey:GBOptions.loggingLevel];
		[settings setBool:YES forKey:GBOptions.loggingCommonEnabled];
		[settings setBool:YES forKey:GBOptions.loggingStoreEnabled];
		[settings setBool:YES forKey:GBOptions.loggingParsingEnabled];
		// verify
		assertThatInt(settings.loggingFormat, equalToInt(2));
		assertThatInt(settings.loggingLevel, equalToInt(3));
		assertThatBool(settings.loggingCommonEnabled, equalToBool(YES));
		assertThatBool(settings.loggingStoreEnabled, equalToBool(YES));
		assertThatBool(settings.loggingParsingEnabled, equalToBool(YES));
	}];
}

- (void)testDebuggingAidPropertiesAreWiredToCorrectCmdLineSwitches {
	[self runWithSettings:^(GBSettings *settings) {
		// execute
		[settings setBool:YES forKey:GBOptions.printSettings];
		[settings setBool:YES forKey:GBOptions.printVersion];
		[settings setBool:YES forKey:GBOptions.printHelp];
		// verify
		assertThatBool(settings.printSettings, equalToBool(YES));
		assertThatBool(settings.printVersion, equalToBool(YES));
		assertThatBool(settings.printHelp, equalToBool(YES));
	}];
}

@end

#pragma mark -

@implementation SettingsTests (CreationMethods)

- (void)runWithSettings:(void(^)(GBSettings *settings))handler {
	GBSettings *settings = [GBSettings appledocSettingsWithName:@"name" parent:nil];
	handler(settings);
}

@end