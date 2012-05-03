//
//  AppledocTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/14/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "Parser.h"
#import "Appledoc.h"
#import "TestCaseBase.hh"

@interface Appledoc (TestingPrivateAPI)
@property (nonatomic, strong) GBSettings *settings;
@end

#pragma mark - 

static void runWithAppledoc(void(^handler)(Appledoc *appledoc)) {
	Appledoc *appledoc = [[Appledoc alloc] init];
	handler(appledoc);
	[appledoc release];
}

#pragma mark - 

SPEC_BEGIN(AppledocTests)

describe(@"lazy accessors", ^{
	it(@"should initialize objects", ^{
		runWithAppledoc(^(Appledoc *appledoc) {
			// execute & verify
			appledoc.store should be_instance_of([Store class]);
			appledoc.parser should be_instance_of([Parser class]);
		});
	});
});

describe(@"run", ^{
	it(@"should invoke parser", ^{
		runWithAppledoc(^(Appledoc *appledoc) {
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
			^{ [parser verify]; } should_not raise_exception();
		});
	});
});

SPEC_END
