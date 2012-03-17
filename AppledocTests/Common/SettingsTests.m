//
//  SettingsTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/13/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Settings+Appledoc.h"
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
		[settings setObject:@"1" forKey:GBOptions.inputPaths];
		[settings setObject:@"2" forKey:GBOptions.templatesPath];
		// verify
		assertThat(settings.inputPaths, onlyContains(@"1", nil));
		assertThat(settings.templatesPath, equalTo(@"2"));
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
