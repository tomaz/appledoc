//
//  AppledocTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/14/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects+TestingPrivateAPI.h"
#import "Store.h"
#import "Parser.h"
#import "Appledoc.h"
#import "TestCaseBase.h"

@interface Appledoc (TestingPrivateAPI)
@property (nonatomic, strong) GBSettings *settings;
@end

#pragma mark - 

@interface AppledocTests : TestCaseBase
@end

@interface AppledocTests (CreationMethods)
- (void)runWithAppledoc:(void(^)(Appledoc *appledoc))handler;
@end

@implementation AppledocTests

#pragma mark - Properties

- (void)testLazyAccessorsShouldInitializeObjects {
	[self runWithAppledoc:^(Appledoc *appledoc) {
		// execute & verify
		assertThat(appledoc.store, instanceOf([Store class]));
		assertThat(appledoc.parser, instanceOf([Parser class]));
	}];
}

#pragma mark - runWithSettings:

- (void)testRunWithSettingsShouldInvokeAllSubcomponents {
	[self runWithAppledoc:^(Appledoc *appledoc) {
		// setup
		id settings = [OCMockObject niceMockForClass:[GBSettings class]];
		id store = [OCMockObject niceMockForClass:[Store class]];
		id parser = [OCMockObject mockForClass:[Parser class]];
		[[parser expect] runWithSettings:settings store:store];
		appledoc.store = store;
		appledoc.parser = parser;
		// execute
		[appledoc runWithSettings:settings];
		// verify
		STAssertNoThrow([parser verify], nil);
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
