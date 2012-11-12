//
//  AppledocTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/14/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "Parser.h"
#import "Processor.h"
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

TEST_BEGIN(AppledocTests)

describe(@"lazy accessors:", ^{
	it(@"should initialize objects", ^{
		runWithAppledoc(^(Appledoc *appledoc) {
			// execute & verify
			appledoc.store should be_instance_of([Store class]);
			appledoc.parser should be_instance_of([Parser class]);
			appledoc.processor should be_instance_of([Processor class]);
		});
	});
});

describe(@"run:", ^{
	it(@"should invoke parser", ^{
		runWithAppledoc(^(Appledoc *appledoc) {
			// setup
			id settings = mock([GBSettings class]);
			id parser = mock([Parser class]);
			id store = mock([Store class]);
			appledoc.processor = mock([Processor class]);
			appledoc.store = store;
			appledoc.parser = parser;
			// execute
			[appledoc runWithSettings:settings];
			// verify
			gbcatch([verify(parser) runWithSettings:settings store:store]);
		});
	});

	it(@"should invoke processor", ^{
		runWithAppledoc(^(Appledoc *appledoc) {
			// setup
			id settings = mock([GBSettings class]);
			id store = mock([Store class]);
			id processor = mock([Processor class]);
			appledoc.parser = mock([Parser class]);
			appledoc.store = store;
			appledoc.processor = processor;
			// execute
			[appledoc runWithSettings:settings];
			// verify
			gbcatch([verify(processor) runWithSettings:settings store:store]);
		});
	});
});

TEST_END
