//
//  ObjectiveCFileStateTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/27/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectiveCFileState.h"
#import "ObjectiveCStateTestsHelpers.h"
#import "TestCaseBase.hh"

static void runWithState(void(^handler)(ObjectiveCFileState *state)) {
	ObjectiveCFileState* state = [[ObjectiveCFileState alloc] init];
	handler(state);
	[state release];
}

SPEC_BEGIN(ObjectiveCFileStateTests)

describe(@"classes parsing", ^{
	it(@"should register root class to store", ^{		
		runWithState(^(ObjectiveCFileState *state) {
			runWithString(@"@interface MyClass", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
				[[store expect] beginClassWithName:@"MyClass" derivedFromClassWithName:nil];
				[[parser expect] pushState:[parser interfaceState]];
				ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
				// execute
				[state parseWithData:data];
				// verify
				^{ [store verify]; } should_not raise_exception();
				^{ [parser verify]; } should_not raise_exception();
			});
		});
	});

	it(@"should register subclass to store", ^{
		runWithState(^(ObjectiveCFileState *state) {
			runWithString(@"@interface MyClass : SuperClass", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
				[[store expect] beginClassWithName:@"MyClass" derivedFromClassWithName:@"SuperClass"];
				[[parser expect] pushState:[parser interfaceState]];
				ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
				// execute
				[state parseWithData:data];
				// verify
				^{ [store verify]; } should_not raise_exception();
				^{ [parser verify]; } should_not raise_exception();
			});
		});
	});
});

describe(@"categories parsing", ^{
	it(@"should register class extension to store", ^{
		runWithState(^(ObjectiveCFileState *state) {
			runWithString(@"@interface MyClass ()", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
				[[store expect] beginExtensionForClassWithName:@"MyClass"];
				[[parser expect] pushState:[parser interfaceState]];
				ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
				// execute
				[state parseWithData:data];
				// verify
				^{ [store verify]; } should_not raise_exception();
				^{ [parser verify]; } should_not raise_exception();
			});
		});
	});

	it(@"should register class category to store", ^{	
		runWithState(^(ObjectiveCFileState *state) {
			runWithString(@"@interface MyClass (CategoryName)", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
				[[store expect] beginCategoryWithName:@"CategoryName" forClassWithName:@"MyClass"];
				[[parser expect] pushState:[parser interfaceState]];
				ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
				// execute
				[state parseWithData:data];
				// verify
				^{ [store verify]; } should_not raise_exception();
				^{ [parser verify]; } should_not raise_exception();
			});
		});
	});
});

describe(@"protocols parsing", ^{
	it(@"should register protocol to store", ^{
		runWithState(^(ObjectiveCFileState *state) {
			runWithString(@"@protocol MyProtocol", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
				[[store expect] beginProtocolWithName:@"MyProtocol"];
				[[parser expect] pushState:[parser interfaceState]];
				ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
				// execute
				[state parseWithData:data];
				// verify
				^{ [store verify]; } should_not raise_exception();
				^{ [parser verify]; } should_not raise_exception();
			});
		});
	});
});

describe(@"enums parsing", ^{
	it(@"should detect possible enum", ^{
		runWithState(^(ObjectiveCFileState *state) {
			runWithString(@"enum", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[parser expect] pushState:[parser enumState]];
				ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
				// execute
				[state parseWithData:data];
				// verify
				^{ [parser verify]; } should_not raise_exception();
			});
		});
	});
});

describe(@"structs parsing", ^{
	it(@"should detect possible struct", ^{
		runWithState(^(ObjectiveCFileState *state) {
			runWithString(@"struct", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[parser expect] pushState:[parser structState]];
				ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
				// execute
				[state parseWithData:data];
				// verify
				^{ [parser verify]; } should_not raise_exception();
			});
		});
	});
});

SPEC_END
