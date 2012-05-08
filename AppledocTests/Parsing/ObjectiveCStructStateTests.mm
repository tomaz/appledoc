	//
//  ObjectiveCStructStateTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/30/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectiveCStructState.h"
#import "ObjectiveCStateTestsHelpers.h"
#import "TestCaseBase.hh"

static void runWithState(void(^handler)(ObjectiveCStructState *state)) {
	ObjectiveCStructState* state = [[ObjectiveCStructState alloc] init];
	handler(state);
	[state release];
}

#pragma mark - 

SPEC_BEGIN(ObjectiveCStructStateTests)

describe(@"partial parsing", ^{
	describe(@"struct start", ^{
		it(@"should detect struct", ^{
			runWithState(^(ObjectiveCStructState *state) {
				runWithString(@"struct {", ^(id parser, id tokens) {
					// setup
					id store = [OCMockObject mockForClass:[Store class]];
					[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
					[[store expect] beginStruct];
					ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
					// execute
					[state parseWithData:data];
					// verify
					^{ [store verify]; } should_not raise_exception();
					^{ [parser verify]; } should_not raise_exception();
				});
			});
		});
		
		it(@"should detect struct name", ^{
			runWithState(^(ObjectiveCStructState *state) {
				runWithString(@"struct name {", ^(id parser, id tokens) {
					// setup
					id store = [OCMockObject mockForClass:[Store class]];
					[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
					[[store expect] beginStruct];
					[[store expect] appendStructName:@"name"];
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

	describe(@"constants", ^{
		it(@"should detect constant", ^{
			runWithState(^(ObjectiveCStructState *state) {
				runWithString(@"type name", ^(id parser, id tokens) {
					// setup
					id store = [OCMockObject mockForClass:OCMOCK_ANY];
					[[parser expect] pushState:[parser constantState]];
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

	describe(@"struct end", ^{
		it(@"should detect end", ^{
			runWithState(^(ObjectiveCStructState *state) {
				runWithString(@"}", ^(id parser, id tokens) {
					// setup
					id store = [OCMockObject mockForClass:[Store class]];
					[[store expect] endCurrentObject];
					[[parser expect] popState];
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
});

describe(@"fail cases", ^{
	it(@"should fail if opening brace is missing", ^{
		runWithState(^(ObjectiveCStructState *state) {
			runWithString(@"struct name", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
				[[store expect] beginStruct];
				[[store expect] cancelCurrentObject];
				[[parser expect] popState];
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

SPEC_END
