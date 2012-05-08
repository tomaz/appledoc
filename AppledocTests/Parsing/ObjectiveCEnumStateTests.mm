//
//  ObjectiveCEnumStateTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/30/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectiveCEnumState.h"
#import "ObjectiveCStateTestsHelpers.h"
#import "TestCaseBase.hh"

static void runWithState(void(^handler)(ObjectiveCEnumState *state)) {
	ObjectiveCEnumState* state = [[ObjectiveCEnumState alloc] init];
	handler(state);
	[state release];
}

#pragma mark - 

TEST_BEGIN(ObjectiveCEnumStateTests)

describe(@"simple cases:", ^{
	it(@"should detect", ^{
		runWithState(^(ObjectiveCEnumState *state) {
			runWithString(@"enum {};", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
				[[store expect] beginEnumeration];
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
	
	it(@"should detect name", ^{
		runWithState(^(ObjectiveCEnumState *state) {
			runWithString(@"enum name {};", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
				[[store expect] beginEnumeration];
				[[store expect] appendEnumerationName:@"name"];
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

	it(@"should use last token before enum body as name", ^{
		runWithState(^(ObjectiveCEnumState *state) {
			runWithString(@"enum word1 word2 word3 {};", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
				[[store expect] beginEnumeration];
				[[store expect] appendEnumerationName:@"word3"];
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

describe(@"single item enums:", ^{
	it(@"should detect item", ^{
		runWithState(^(ObjectiveCEnumState *state) {
			runWithString(@"enum { item };", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
				[[store expect] beginEnumeration];
				[[store expect] appendEnumerationItem:@"item"];
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

	it(@"should detect item even if delimited by comma", ^{
		runWithState(^(ObjectiveCEnumState *state) {
			runWithString(@"enum { item, };", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
				[[store expect] beginEnumeration];
				[[store expect] appendEnumerationItem:@"item"];
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
	
	it(@"should detect item with value", ^{
		runWithState(^(ObjectiveCEnumState *state) {
			runWithString(@"enum { item = value };", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
				[[store expect] beginEnumeration];
				[[store expect] appendEnumerationItem:@"item"];
				[[store expect] appendEnumerationValue:@"value"];
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

	it(@"should detect item with value even if delimited by comma", ^{
		runWithState(^(ObjectiveCEnumState *state) {
			runWithString(@"enum { item = value, };", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
				[[store expect] beginEnumeration];
				[[store expect] appendEnumerationItem:@"item"];
				[[store expect] appendEnumerationValue:@"value"];
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

describe(@"enums with multiple items:", ^{
	it(@"shuold detect all items", ^{
		runWithState(^(ObjectiveCEnumState *state) {
			runWithString(@"enum { item1, item2, item3 };", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
				[[store expect] beginEnumeration];
				[[store expect] appendEnumerationItem:@"item1"];
				[[store expect] appendEnumerationItem:@"item2"];
				[[store expect] appendEnumerationItem:@"item3"];
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

	it(@"should detect items with values", ^{
		runWithState(^(ObjectiveCEnumState *state) {
			runWithString(@"enum { item1 = value1, item2 = value2, item3 = value3 };", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
				[[store expect] beginEnumeration];
				[[store expect] appendEnumerationItem:@"item1"];
				[[store expect] appendEnumerationValue:@"value1"];
				[[store expect] appendEnumerationItem:@"item2"];
				[[store expect] appendEnumerationValue:@"value2"];
				[[store expect] appendEnumerationItem:@"item3"];
				[[store expect] appendEnumerationValue:@"value3"];
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

	it(@"should detect items with mixed values", ^{
		runWithState(^(ObjectiveCEnumState *state) {
			runWithString(@"enum { item1 = value1, item2, item3 = value3, };", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
				[[store expect] beginEnumeration];
				[[store expect] appendEnumerationItem:@"item1"];
				[[store expect] appendEnumerationValue:@"value1"];
				[[store expect] appendEnumerationItem:@"item2"];
				[[store expect] appendEnumerationItem:@"item3"];
				[[store expect] appendEnumerationValue:@"value3"];
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

describe(@"few more complex cases:", ^{
	it(@"should detect enum with complex values", ^{
		runWithState(^(ObjectiveCEnumState *state) {
			runWithString(@"enum { item1 = (1 << 0), item2 = (item2 + 30 * (1 << 4)) };", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
				[[store expect] beginEnumeration];
				[[store expect] appendEnumerationItem:@"item1"];
				[[store expect] appendEnumerationValue:@"(1 << 0)"];
				[[store expect] appendEnumerationItem:@"item2"];
				[[store expect] appendEnumerationValue:@"(item2 + 30 * (1 << 4))"];
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

describe(@"enums with names:", ^{
	describe(@"if name is part of enum:", ^{
		it(@"should detect single item", ^{
			runWithState(^(ObjectiveCEnumState *state) {
				runWithString(@"enum name {};", ^(id parser, id tokens) {
					// setup
					id store = [OCMockObject mockForClass:[Store class]];
					[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
					[[store expect] beginEnumeration];
					[[store expect] appendEnumerationName:@"name"];
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
	
describe(@"fail cases:", ^{
	it(@"should cancel if start of enum body is missing", ^{
		runWithState(^(ObjectiveCEnumState *state) {
			runWithString(@"enum word1 word2 word3 };", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
				[[store expect] beginEnumeration];
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

	it(@"should cancel if end of enum body is missing", ^{
		runWithState(^(ObjectiveCEnumState *state) {
			runWithString(@"enum { item ;", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
				[[store expect] beginEnumeration];
				[[store expect] appendEnumerationItem:@"item"];
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

	it(@"should cancel if ending semicolon is missing", ^{
		runWithState(^(ObjectiveCEnumState *state) {
			runWithString(@"enum {}", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
				[[store expect] beginEnumeration];
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

TEST_END
