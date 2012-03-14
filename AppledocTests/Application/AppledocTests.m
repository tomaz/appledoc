//
//  AppledocTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/14/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects+TestingPrivateAPI.h"
#import "Appledoc.h"
#import "Settings.h"
#import "TestCaseBase.h"

@interface Appledoc (TestingPrivateAPI)
@property (nonatomic, strong) Settings *settings;
@end

#pragma mark - 

@interface AppledocTests : TestCaseBase
@end

@interface AppledocTests (CreationMethods)
- (void)runWithAppledoc:(void(^)(Appledoc *appledoc))handler;
@end

@implementation AppledocTests

#pragma mark - setupSettingsFromCmdLineArgs:count:

- (void)testSetupSettingsFromCmdLineArgsCountShouldSetupSettings {
	[self runWithAppledoc:^(Appledoc *appledoc) {
		// execute
		[appledoc setupSettingsFromCmdLineArgs:NULL count:0];
		// verify
		assertThat(appledoc.settings, isNot(nil));
		assertThat(appledoc.settings.name, is(@"CmdLine"));
		assertThat(appledoc.settings.parent, isNot(nil));
		assertThat(appledoc.settings.parent.name, is(@"Project"));
		assertThat(appledoc.settings.parent.parent, isNot(nil));
		assertThat(appledoc.settings.parent.parent.name, is(@"Global"));
		assertThat(appledoc.settings.parent.parent.parent, isNot(nil));
		assertThat(appledoc.settings.parent.parent.parent.name, is(@"Factory"));
		assertThat(appledoc.settings.parent.parent.parent.parent, equalTo(nil));
	}];
}

@end

#pragma mark -

@implementation AppledocTests (CreationMethods)

- (void)runWithAppledoc:(void(^)(Appledoc *appledoc))handler {
	Appledoc *appledoc = [[Appledoc alloc] init];
	handler(appledoc);
}

@end
