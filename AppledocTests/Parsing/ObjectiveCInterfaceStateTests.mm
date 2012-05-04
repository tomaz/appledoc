//
//  ObjectiveCInterfaceStateTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/28/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectiveCInterfaceState.h"
#import "ObjectiveCStateTestsHelpers.h"
#import "TestCaseBase.hh"


static void runWithState(void(^handler)(ObjectiveCInterfaceState *state)) {
	ObjectiveCInterfaceState* state = [[ObjectiveCInterfaceState alloc] init];
	handler(state);
	[state release];
}

SPEC_BEGIN(ObjectiveCInterfaceStateTests)

describe(@"adopted protocols parsing", ^{
	it(@"should register single adopted protocol to store", ^{
		runWithState(^(ObjectiveCInterfaceState *state) {
			runWithString(@"<MyProtocol>", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
				[[store expect] appendAdoptedProtocolWithName:@"MyProtocol"];
				// execute
				[state parseStream:tokens forParser:parser store:store];
				// verify
				^{ [store verify]; } should_not raise_exception();
			});
		});
	});

	it(@"should register multiple adopted protocols to store", ^{
		runWithState(^(ObjectiveCInterfaceState *state) {
			runWithString(@"<MyProtocol1, MyProtocol2, MyProtocol3>", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
				[[store expect] appendAdoptedProtocolWithName:@"MyProtocol1"];
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
				[[store expect] appendAdoptedProtocolWithName:@"MyProtocol2"];
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
				[[store expect] appendAdoptedProtocolWithName:@"MyProtocol3"];
				// execute
				[state parseStream:tokens forParser:parser store:store];
				// verify
				^{ [store verify]; } should_not raise_exception();
			});
		});
	});
	
	it(@"should ignore empty adopted protocols list", ^{
		runWithState(^(ObjectiveCInterfaceState *state) {
			runWithString(@"<>", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				// execute
				[state parseStream:tokens forParser:parser store:store];
				// verify
				^{ [store verify]; } should_not raise_exception();
			});
		});
	});
});

describe(@"@end parsing", ^{
	it(@"should register interface end to store", ^{
		runWithState(^(ObjectiveCInterfaceState *state) {
			runWithString(@"@end", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
				[[store expect] endCurrentObject];
				[[parser expect] popState];
				// execute
				[state parseStream:tokens forParser:parser store:store];
				// verify
				^{ [store verify]; } should_not raise_exception();
				^{ [parser verify]; } should_not raise_exception();
			});
		});
	});
});

describe(@"methods and properties parsing", ^{
	it(@"should detect possible instance method", ^{
		runWithState(^(ObjectiveCInterfaceState *state) {
			runWithString(@"-", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[parser expect] pushState:[parser methodState]];
				// execute
				[state parseStream:tokens forParser:parser store:store];
				// verify
				^{ [parser verify]; } should_not raise_exception();
			});
		});
	});

	it(@"should detect possible class method", ^{
		runWithState(^(ObjectiveCInterfaceState *state) {
			runWithString(@"+", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[parser expect] pushState:[parser methodState]];
				// execute
				[state parseStream:tokens forParser:parser store:store];
				// verify
				^{ [parser verify]; } should_not raise_exception();
			});
		});
	});

	it(@"should detect possible property", ^{
		runWithState(^(ObjectiveCInterfaceState *state) {
			runWithString(@"@property", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[parser expect] pushState:[parser propertyState]];
				// execute
				[state parseStream:tokens forParser:parser store:store];
				// verify
				^{ [parser verify]; } should_not raise_exception();
			});
		});
	});
});

describe(@"#pragma mark parsing", ^{
	it(@"should detect possible pragma mark", ^{
		runWithState(^(ObjectiveCInterfaceState *state) {
			runWithString(@"#pragma mark", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[parser expect] pushState:[parser pragmaMarkState]];
				// execute
				[state parseStream:tokens forParser:parser store:store];
				// verify
				^{ [parser verify]; } should_not raise_exception();
			});
		});
	});
});

SPEC_END
