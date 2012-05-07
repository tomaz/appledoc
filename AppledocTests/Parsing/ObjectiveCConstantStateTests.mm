//
//  ObjectiveCConstantStateTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/30/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectiveCConstantState.h"
#import "ObjectiveCStateTestsHelpers.h"
#import "TestCaseBase.hh"

static void runWithState(void(^handler)(ObjectiveCConstantState *state)) {
	ObjectiveCConstantState* state = [[ObjectiveCConstantState alloc] init];
	handler(state);
	[state release];
}

#pragma mark - 

SPEC_BEGIN(ObjectiveCConstantStateTests)

describe(@"simple cases", ^{
	it(@"should detect single type", ^{
		runWithState(^(ObjectiveCConstantState *state) {
			runWithString(@"type item;", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
				[[store expect] beginConstant];
				[[store expect] beginConstantTypes];
				[[store expect] appendType:@"type"];
				[[store expect] endCurrentObject]; // types
				[[store expect] appendConstantName:@"item"];
				[[store expect] endCurrentObject]; // constant
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

	it(@"should detect multiple types", ^{
		runWithState(^(ObjectiveCConstantState *state) {
			runWithString(@"type1 type2 type3 item;", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
				[[store expect] beginConstant];
				[[store expect] beginConstantTypes];
				[[store expect] appendType:@"type1"];
				[[store expect] appendType:@"type2"];
				[[store expect] appendType:@"type3"];
				[[store expect] endCurrentObject]; // types
				[[store expect] appendConstantName:@"item"];
				[[store expect] endCurrentObject]; // constant
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

describe(@"descriptors", ^{
	describe(@"if descriptors start with double underscore prefixed word", ^{
		it(@"should detect single descriptor", ^{
			runWithState(^(ObjectiveCConstantState *state) {
				runWithString(@"type name __a;", ^(id parser, id tokens) {
					// setup
					id store = [OCMockObject mockForClass:[Store class]];
					[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
					[[store expect] beginConstant];
					[[store expect] beginConstantTypes];
					[[store expect] appendType:@"type"];
					[[store expect] endCurrentObject]; // types
					[[store expect] appendConstantName:@"name"];
					[[store expect] beginConstantDescriptors];
					[[store expect] appendDescriptor:@"__a"];
					[[store expect] endCurrentObject]; // descriptors
					[[store expect] endCurrentObject]; // constant
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

		it(@"should detect all descriptors", ^{
			runWithState(^(ObjectiveCConstantState *state) {
				runWithString(@"type name __a b c;", ^(id parser, id tokens) {
					// setup
					id store = [OCMockObject mockForClass:[Store class]];
					[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
					[[store expect] beginConstant];
					[[store expect] beginConstantTypes];
					[[store expect] appendType:@"type"];
					[[store expect] endCurrentObject]; // types
					[[store expect] appendConstantName:@"name"];
					[[store expect] beginConstantDescriptors];
					[[store expect] appendDescriptor:@"__a"];
					[[store expect] appendDescriptor:@"b"];
					[[store expect] appendDescriptor:@"c"];
					[[store expect] endCurrentObject]; // descriptors
					[[store expect] endCurrentObject]; // constant
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

	describe(@"if descriptors start with uppercase word", ^{
		it(@"should detect single descriptor", ^{
			runWithState(^(ObjectiveCConstantState *state) {
				runWithString(@"type name A;", ^(id parser, id tokens) {
					// setup
					id store = [OCMockObject mockForClass:[Store class]];
					[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
					[[store expect] beginConstant];
					[[store expect] beginConstantTypes];
					[[store expect] appendType:@"type"];
					[[store expect] endCurrentObject]; // types
					[[store expect] appendConstantName:@"name"];
					[[store expect] beginConstantDescriptors];
					[[store expect] appendDescriptor:@"A"];
					[[store expect] endCurrentObject]; // descriptors
					[[store expect] endCurrentObject]; // constant
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
		
		it(@"should detect all descriptors", ^{
			runWithState(^(ObjectiveCConstantState *state) {
				runWithString(@"type name A b c;", ^(id parser, id tokens) {
					// setup
					id store = [OCMockObject mockForClass:[Store class]];
					[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
					[[store expect] beginConstant];
					[[store expect] beginConstantTypes];
					[[store expect] appendType:@"type"];
					[[store expect] endCurrentObject]; // types
					[[store expect] appendConstantName:@"name"];
					[[store expect] beginConstantDescriptors];
					[[store expect] appendDescriptor:@"A"];
					[[store expect] appendDescriptor:@"b"];
					[[store expect] appendDescriptor:@"c"];
					[[store expect] endCurrentObject]; // descriptors
					[[store expect] endCurrentObject]; // constant
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
	
	describe(@"if constant name starts with double underscore", ^{
		it(@"should detect name", ^{
			runWithState(^(ObjectiveCConstantState *state) {
				runWithString(@"type __a;", ^(id parser, id tokens) {
					// setup
					id store = [OCMockObject mockForClass:[Store class]];
					[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
					[[store expect] beginConstant];
					[[store expect] beginConstantTypes];
					[[store expect] appendType:@"type"];
					[[store expect] endCurrentObject]; // types
					[[store expect] appendConstantName:@"__a"];
					[[store expect] endCurrentObject]; // constant
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

		it(@"should detect double underscore descriptors", ^{
			runWithState(^(ObjectiveCConstantState *state) {
				runWithString(@"type __a __b;", ^(id parser, id tokens) {
					// setup
					id store = [OCMockObject mockForClass:[Store class]];
					[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
					[[store expect] beginConstant];
					[[store expect] beginConstantTypes];
					[[store expect] appendType:@"type"];
					[[store expect] endCurrentObject]; // types
					[[store expect] appendConstantName:@"__a"];
					[[store expect] beginConstantDescriptors];
					[[store expect] appendDescriptor:@"__b"];
					[[store expect] endCurrentObject]; // descriptors
					[[store expect] endCurrentObject]; // constant
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
		
		it(@"should detect uppercase descriptors", ^{
			runWithState(^(ObjectiveCConstantState *state) {
				runWithString(@"type __a A;", ^(id parser, id tokens) {
					// setup
					id store = [OCMockObject mockForClass:[Store class]];
					[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
					[[store expect] beginConstant];
					[[store expect] beginConstantTypes];
					[[store expect] appendType:@"type"];
					[[store expect] endCurrentObject]; // types
					[[store expect] appendConstantName:@"__a"];
					[[store expect] beginConstantDescriptors];
					[[store expect] appendDescriptor:@"A"];
					[[store expect] endCurrentObject]; // descriptors
					[[store expect] endCurrentObject]; // constant
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

	describe(@"if constant name is uppercase word", ^{
		it(@"should detect name", ^{
			runWithState(^(ObjectiveCConstantState *state) {
				runWithString(@"type A;", ^(id parser, id tokens) {
					// setup
					id store = [OCMockObject mockForClass:[Store class]];
					[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
					[[store expect] beginConstant];
					[[store expect] beginConstantTypes];
					[[store expect] appendType:@"type"];
					[[store expect] endCurrentObject]; // types
					[[store expect] appendConstantName:@"A"];
					[[store expect] endCurrentObject]; // constant
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
		
		it(@"should detect double underscore descriptors", ^{
			runWithState(^(ObjectiveCConstantState *state) {
				runWithString(@"type A __a;", ^(id parser, id tokens) {
					// setup
					id store = [OCMockObject mockForClass:[Store class]];
					[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
					[[store expect] beginConstant];
					[[store expect] beginConstantTypes];
					[[store expect] appendType:@"type"];
					[[store expect] endCurrentObject]; // types
					[[store expect] appendConstantName:@"A"];
					[[store expect] beginConstantDescriptors];
					[[store expect] appendDescriptor:@"__a"];
					[[store expect] endCurrentObject]; // descriptors
					[[store expect] endCurrentObject]; // constant
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
		
		it(@"should detect uppercase descriptors", ^{
			runWithState(^(ObjectiveCConstantState *state) {
				runWithString(@"type A B;", ^(id parser, id tokens) {
					// setup
					id store = [OCMockObject mockForClass:[Store class]];
					[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
					[[store expect] beginConstant];
					[[store expect] beginConstantTypes];
					[[store expect] appendType:@"type"];
					[[store expect] endCurrentObject]; // types
					[[store expect] appendConstantName:@"A"];
					[[store expect] beginConstantDescriptors];
					[[store expect] appendDescriptor:@"B"];
					[[store expect] endCurrentObject]; // descriptors
					[[store expect] endCurrentObject]; // constant
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
	it(@"should cancel if only single token is given", ^{
		runWithState(^(ObjectiveCConstantState *state) {
			runWithString(@"value", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
				[[store expect] beginConstant];
				[[store expect] beginConstantTypes];
				[[store expect] appendType:@"value"];
				[[store expect] cancelCurrentObject]; // types
				[[store expect] cancelCurrentObject]; // constant
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

	it(@"should cancel if semicolon is missing", ^{
		runWithState(^(ObjectiveCConstantState *state) {
			runWithString(@"type item", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
				[[store expect] beginConstant];
				[[store expect] beginConstantTypes];
				[[store expect] appendType:@"type"];
				[[store expect] appendType:@"item"];
				[[store expect] cancelCurrentObject]; // types
				[[store expect] cancelCurrentObject]; // constant
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
