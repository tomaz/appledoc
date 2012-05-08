//
//  ObjectiveCPragmaMarkStateTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/30/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectiveCPragmaMarkState.h"
#import "ObjectiveCStateTestsHelpers.h"
#import "TestCaseBase.hh"

static void runWithState(void(^handler)(ObjectiveCPragmaMarkState *state)) {
	ObjectiveCPragmaMarkState* state = [[ObjectiveCPragmaMarkState alloc] init];
	handler(state);
	[state release];
}

#pragma mark - 

TEST_BEGIN(ObjectiveCPragmaMarkStateTests)

describe(@"simple cases", ^{
	it(@"should detect single word", ^{
		runWithState(^(ObjectiveCPragmaMarkState *state) {
			runWithString(@"#pragma mark word", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
				[[store expect] appendMethodGroupWithDescription:@"word"];
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

	it(@"should detect multiple words", ^{
		runWithState(^(ObjectiveCPragmaMarkState *state) {
			runWithString(@"#pragma mark word1 word2 word3", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
				[[store expect] appendMethodGroupWithDescription:@"word1 word2 word3"];
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

describe(@"using minus", ^{
	it(@"should ignore minus prefix", ^{
		runWithState(^(ObjectiveCPragmaMarkState *state) {
			runWithString(@"#pragma mark - word1 word2 word3", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
				[[store expect] appendMethodGroupWithDescription:@"word1 word2 word3"];
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

	it(@"should ignore minus prefix and take minus suffix as part of description", ^{
		runWithState(^(ObjectiveCPragmaMarkState *state) {
			runWithString(@"#pragma mark - word1 word2 word3 -", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
				[[store expect] appendMethodGroupWithDescription:@"word1 word2 word3 -"];
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

describe(@"various edge cases", ^{
	it(@"should ignore if description only contains whitespace", ^{
		runWithState(^(ObjectiveCPragmaMarkState *state) {
			runWithString(@"#pragma mark - \t  \t \n", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
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

TEST_END
