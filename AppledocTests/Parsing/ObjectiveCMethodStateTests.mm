//
//  ObjectiveCMethodStateTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/30/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectiveCMethodState.h"
#import "ObjectiveCStateTestsHelpers.h"
#import "TestCaseBase.hh"

static void runWithState(void(^handler)(ObjectiveCMethodState *state)) {
	ObjectiveCMethodState* state = [[ObjectiveCMethodState alloc] init];
	handler(state);
	[state release];
}

#pragma mark - 

TEST_BEGIN(ObjectiveCMethodStateTests)

describe(@"no arguments methods", ^{
	it(@"should detect definition with no return type", ^{
		runWithState(^(ObjectiveCMethodState *state) {
			runWithString(@"- method;", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
				[[store expect] beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
				[[store expect] beginMethodArgument];
				[[store expect] appendMethodArgumentSelector:@"method"];
				[[store expect] endCurrentObject]; // method argument
				[[store expect] endCurrentObject]; // method definition
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
	
	it(@"should detect definition with signle return type", ^{
		runWithState(^(ObjectiveCMethodState *state) {
			runWithString(@"- (type)method;", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
				[[store expect] beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
				[[store expect] beginMethodResults];
				[[store expect] appendType:@"type"];
				[[store expect] endCurrentObject]; // method result
				[[store expect] beginMethodArgument];
				[[store expect] appendMethodArgumentSelector:@"method"];
				[[store expect] endCurrentObject]; // method argument
				[[store expect] endCurrentObject]; // method definition
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
	
	it(@"should detect definition with multiple return types", ^{
		runWithState(^(ObjectiveCMethodState *state) {
			runWithString(@"- (type1 type2 type3)method;", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
				[[store expect] beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
				[[store expect] beginMethodResults];
				[[store expect] appendType:@"type1"];
				[[store expect] appendType:@"type2"];
				[[store expect] appendType:@"type3"];
				[[store expect] endCurrentObject]; // result types
				[[store expect] beginMethodArgument];
				[[store expect] appendMethodArgumentSelector:@"method"];
				[[store expect] endCurrentObject]; // method argument
				[[store expect] endCurrentObject]; // method definition
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

describe(@"single argument methods", ^{
	it(@"should detect definition with no type", ^{
		runWithState(^(ObjectiveCMethodState *state) {
			runWithString(@"- method:var;", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
				[[store expect] beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
				[[store expect] beginMethodArgument];
				[[store expect] appendMethodArgumentSelector:@"method"];
				[[store expect] appendMethodArgumentVariable:@"var"];
				[[store expect] endCurrentObject]; // method argument
				[[store expect] endCurrentObject]; // method definition
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
	
	it(@"should detect definition with signle type", ^{
		runWithState(^(ObjectiveCMethodState *state) {
			runWithString(@"- method:(type1)var;", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
				[[store expect] beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
				[[store expect] beginMethodArgument];
				[[store expect] appendMethodArgumentSelector:@"method"];
				[[store expect] beginMethodArgumentTypes];
				[[store expect] appendType:@"type1"];
				[[store expect] endCurrentObject]; // argument types
				[[store expect] appendMethodArgumentVariable:@"var"];
				[[store expect] endCurrentObject]; // method argument
				[[store expect] endCurrentObject]; // method definition
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
	
	it(@"should detect definition with multiple types", ^{
		runWithState(^(ObjectiveCMethodState *state) {
			runWithString(@"- method:(type1 type2 type3)var;", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
				[[store expect] beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
				[[store expect] beginMethodArgument];
				[[store expect] appendMethodArgumentSelector:@"method"];
				[[store expect] beginMethodArgumentTypes];
				[[store expect] appendType:@"type1"];
				[[store expect] appendType:@"type2"];
				[[store expect] appendType:@"type3"];
				[[store expect] endCurrentObject]; // argument types
				[[store expect] appendMethodArgumentVariable:@"var"];
				[[store expect] endCurrentObject]; // method argument
				[[store expect] endCurrentObject]; // method definition
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

describe(@"multiple arguments methods", ^{
	it(@"should detect definition with no types", ^{
		runWithState(^(ObjectiveCMethodState *state) {
			runWithString(@"- method:var1 that:var2 rocks:var3;", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
				[[store expect] beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
				[[store expect] beginMethodArgument];
				[[store expect] appendMethodArgumentSelector:@"method"];
				[[store expect] appendMethodArgumentVariable:@"var1"];
				[[store expect] endCurrentObject]; // method argument
				[[store expect] beginMethodArgument];
				[[store expect] appendMethodArgumentSelector:@"that"];
				[[store expect] appendMethodArgumentVariable:@"var2"];
				[[store expect] endCurrentObject]; // method argument
				[[store expect] beginMethodArgument];
				[[store expect] appendMethodArgumentSelector:@"rocks"];
				[[store expect] appendMethodArgumentVariable:@"var3"];
				[[store expect] endCurrentObject]; // method argument
				[[store expect] endCurrentObject]; // method definition
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
	
	it(@"should detect definitions with single and multiple types", ^{
		runWithState(^(ObjectiveCMethodState *state) {
			runWithString(@"- method:(type1)var1 that:(type2 type3)var2 rocks:(type4 type5 type6)var3;", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
				[[store expect] beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
				[[store expect] beginMethodArgument];
				[[store expect] appendMethodArgumentSelector:@"method"];
				[[store expect] beginMethodArgumentTypes];
				[[store expect] appendType:@"type1"];
				[[store expect] endCurrentObject]; // argument types
				[[store expect] appendMethodArgumentVariable:@"var1"];
				[[store expect] endCurrentObject]; // method argument
				[[store expect] beginMethodArgument];
				[[store expect] appendMethodArgumentSelector:@"that"];
				[[store expect] beginMethodArgumentTypes];
				[[store expect] appendType:@"type2"];
				[[store expect] appendType:@"type3"];
				[[store expect] endCurrentObject]; // argument types
				[[store expect] appendMethodArgumentVariable:@"var2"];
				[[store expect] endCurrentObject]; // method argument
				[[store expect] beginMethodArgument];
				[[store expect] appendMethodArgumentSelector:@"rocks"];
				[[store expect] beginMethodArgumentTypes];
				[[store expect] appendType:@"type4"];
				[[store expect] appendType:@"type5"];
				[[store expect] appendType:@"type6"];
				[[store expect] endCurrentObject]; // argument types
				[[store expect] appendMethodArgumentVariable:@"var3"];
				[[store expect] endCurrentObject]; // method argument
				[[store expect] endCurrentObject]; // method definition
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

describe(@"methods with descriptors", ^{
	describe(@"if methods have no arguments", ^{
		it(@"should take double underscore prefixed word after selector as descriptor", ^{
			runWithState(^(ObjectiveCMethodState *state) {
				runWithString(@"- method __a;", ^(id parser, id tokens) {
					// setup
					id store = [OCMockObject mockForClass:[Store class]];
					[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
					[[store expect] beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
					[[store expect] beginMethodArgument];
					[[store expect] appendMethodArgumentSelector:@"method"];
					[[store expect] endCurrentObject]; // method argument
					[[store expect] beginMethodDescriptors];
					[[store expect] appendDescriptor:@"__a"];
					[[store expect] endCurrentObject]; // method descriptors
					[[store expect] endCurrentObject]; // method definition
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

		it(@"should take all words after double underscore prefixed word after selector as descriptors", ^{
			runWithState(^(ObjectiveCMethodState *state) {
				runWithString(@"- method __a1 a2 a3;", ^(id parser, id tokens) {
					// setup
					id store = [OCMockObject mockForClass:[Store class]];
					[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
					[[store expect] beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
					[[store expect] beginMethodArgument];
					[[store expect] appendMethodArgumentSelector:@"method"];
					[[store expect] endCurrentObject]; // method argument
					[[store expect] beginMethodDescriptors];
					[[store expect] appendDescriptor:@"__a1"];
					[[store expect] appendDescriptor:@"a2"];
					[[store expect] appendDescriptor:@"a3"];
					[[store expect] endCurrentObject]; // method descriptors
					[[store expect] endCurrentObject]; // method definition
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

		it(@"should allow double underscore prefixed word as argument selector", ^{
			runWithState(^(ObjectiveCMethodState *state) {
				runWithString(@"- __a __b;", ^(id parser, id tokens) {
					// setup
					id store = [OCMockObject mockForClass:[Store class]];
					[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
					[[store expect] beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
					[[store expect] beginMethodArgument];
					[[store expect] appendMethodArgumentSelector:@"__a"];
					[[store expect] endCurrentObject]; // method argument
					[[store expect] beginMethodDescriptors];
					[[store expect] appendDescriptor:@"__b"];
					[[store expect] endCurrentObject]; // method descriptors
					[[store expect] endCurrentObject]; // method definition
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
		
		it(@"should take uppercase word after selector as descriptor", ^{
			runWithState(^(ObjectiveCMethodState *state) {
				runWithString(@"- method A;", ^(id parser, id tokens) {
					// setup
					id store = [OCMockObject mockForClass:[Store class]];
					[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
					[[store expect] beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
					[[store expect] beginMethodArgument];
					[[store expect] appendMethodArgumentSelector:@"method"];
					[[store expect] endCurrentObject]; // method argument
					[[store expect] beginMethodDescriptors];
					[[store expect] appendDescriptor:@"A"];
					[[store expect] endCurrentObject]; // method descriptors
					[[store expect] endCurrentObject]; // method definition
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
		
		it(@"should take all words after uppercase word after selector as descriptors", ^{
			runWithState(^(ObjectiveCMethodState *state) {
				runWithString(@"- method A1 a2 a3;", ^(id parser, id tokens) {
					// setup
					id store = [OCMockObject mockForClass:[Store class]];
					[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
					[[store expect] beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
					[[store expect] beginMethodArgument];
					[[store expect] appendMethodArgumentSelector:@"method"];
					[[store expect] endCurrentObject]; // method argument
					[[store expect] beginMethodDescriptors];
					[[store expect] appendDescriptor:@"A1"];
					[[store expect] appendDescriptor:@"a2"];
					[[store expect] appendDescriptor:@"a3"];
					[[store expect] endCurrentObject]; // method descriptors
					[[store expect] endCurrentObject]; // method definition
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
		
		it(@"should allow uppercase word as argument selector", ^{
			runWithState(^(ObjectiveCMethodState *state) {
				runWithString(@"- A B;", ^(id parser, id tokens) {
					// setup
					id store = [OCMockObject mockForClass:[Store class]];
					[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
					[[store expect] beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
					[[store expect] beginMethodArgument];
					[[store expect] appendMethodArgumentSelector:@"A"];
					[[store expect] endCurrentObject]; // method argument
					[[store expect] beginMethodDescriptors];
					[[store expect] appendDescriptor:@"B"];
					[[store expect] endCurrentObject]; // method descriptors
					[[store expect] endCurrentObject]; // method definition
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
	
	describe(@"if methods have single argument", ^{
		it(@"should take double underscored word after variable name as descriptor", ^{
			runWithState(^(ObjectiveCMethodState *state) {
				runWithString(@"- method:var __a;", ^(id parser, id tokens) {
					// setup
					id store = [OCMockObject mockForClass:[Store class]];
					[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
					[[store expect] beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
					[[store expect] beginMethodArgument];
					[[store expect] appendMethodArgumentSelector:@"method"];
					[[store expect] appendMethodArgumentVariable:@"var"];
					[[store expect] endCurrentObject]; // method argument
					[[store expect] beginMethodDescriptors];
					[[store expect] appendDescriptor:@"__a"];
					[[store expect] endCurrentObject]; // method descriptors
					[[store expect] endCurrentObject]; // method definition
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
		
		it(@"should take all words after double underscore prefixed word after variable name as descriptors", ^{
			runWithState(^(ObjectiveCMethodState *state) {
				runWithString(@"- method:var __a b;", ^(id parser, id tokens) {
					// setup
					id store = [OCMockObject mockForClass:[Store class]];
					[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
					[[store expect] beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
					[[store expect] beginMethodArgument];
					[[store expect] appendMethodArgumentSelector:@"method"];
					[[store expect] appendMethodArgumentVariable:@"var"];
					[[store expect] endCurrentObject]; // method argument
					[[store expect] beginMethodDescriptors];
					[[store expect] appendDescriptor:@"__a"];
					[[store expect] appendDescriptor:@"b"];
					[[store expect] endCurrentObject]; // method descriptors
					[[store expect] endCurrentObject]; // method definition
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

		it(@"should allow double underscored variable name", ^{
			runWithState(^(ObjectiveCMethodState *state) {
				runWithString(@"- method:__a __b;", ^(id parser, id tokens) {
					// setup
					id store = [OCMockObject mockForClass:[Store class]];
					[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
					[[store expect] beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
					[[store expect] beginMethodArgument];
					[[store expect] appendMethodArgumentSelector:@"method"];
					[[store expect] appendMethodArgumentVariable:@"__a"];
					[[store expect] endCurrentObject]; // method argument
					[[store expect] beginMethodDescriptors];
					[[store expect] appendDescriptor:@"__b"];
					[[store expect] endCurrentObject]; // method descriptors
					[[store expect] endCurrentObject]; // method definition
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
		
		it(@"should take uppercase word after variable name as descriptor", ^{
			runWithState(^(ObjectiveCMethodState *state) {
				runWithString(@"- method:var A;", ^(id parser, id tokens) {
					// setup
					id store = [OCMockObject mockForClass:[Store class]];
					[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
					[[store expect] beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
					[[store expect] beginMethodArgument];
					[[store expect] appendMethodArgumentSelector:@"method"];
					[[store expect] appendMethodArgumentVariable:@"var"];
					[[store expect] endCurrentObject]; // method argument
					[[store expect] beginMethodDescriptors];
					[[store expect] appendDescriptor:@"A"];
					[[store expect] endCurrentObject]; // method descriptors
					[[store expect] endCurrentObject]; // method definition
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
		
		it(@"should take all words after uppercase word after variable name as descriptors", ^{
			runWithState(^(ObjectiveCMethodState *state) {
				runWithString(@"- method:var A b;", ^(id parser, id tokens) {
					// setup
					id store = [OCMockObject mockForClass:[Store class]];
					[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
					[[store expect] beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
					[[store expect] beginMethodArgument];
					[[store expect] appendMethodArgumentSelector:@"method"];
					[[store expect] appendMethodArgumentVariable:@"var"];
					[[store expect] endCurrentObject]; // method argument
					[[store expect] beginMethodDescriptors];
					[[store expect] appendDescriptor:@"A"];
					[[store expect] appendDescriptor:@"b"];
					[[store expect] endCurrentObject]; // method descriptors
					[[store expect] endCurrentObject]; // method definition
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

		it(@"should take uppercase word after variable name as descriptor", ^{
			runWithState(^(ObjectiveCMethodState *state) {
				runWithString(@"- method:A B;", ^(id parser, id tokens) {
					// setup
					id store = [OCMockObject mockForClass:[Store class]];
					[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
					[[store expect] beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
					[[store expect] beginMethodArgument];
					[[store expect] appendMethodArgumentSelector:@"method"];
					[[store expect] appendMethodArgumentVariable:@"A"];
					[[store expect] endCurrentObject]; // method argument
					[[store expect] beginMethodDescriptors];
					[[store expect] appendDescriptor:@"B"];
					[[store expect] endCurrentObject]; // method descriptors
					[[store expect] endCurrentObject]; // method definition
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
	
	describe(@"if methods have multiple arguments", ^{
		it(@"should take double underscore prefixed word after last selector as descriptor", ^{
			runWithState(^(ObjectiveCMethodState *state) {
				runWithString(@"- sel1:var1 sel2:var2 __a;", ^(id parser, id tokens) {
					// setup
					id store = [OCMockObject mockForClass:[Store class]];
					[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
					[[store expect] beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
					[[store expect] beginMethodArgument];
					[[store expect] appendMethodArgumentSelector:@"sel1"];
					[[store expect] appendMethodArgumentVariable:@"var1"];
					[[store expect] endCurrentObject]; // method argument
					[[store expect] beginMethodArgument];
					[[store expect] appendMethodArgumentSelector:@"sel2"];
					[[store expect] appendMethodArgumentVariable:@"var2"];
					[[store expect] endCurrentObject]; // method argument
					[[store expect] beginMethodDescriptors];
					[[store expect] appendDescriptor:@"__a"];
					[[store expect] endCurrentObject]; // method descriptors
					[[store expect] endCurrentObject]; // method definition
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

		it(@"should take all words after double underscore prefixed word after last selector as descriptors", ^{
			runWithState(^(ObjectiveCMethodState *state) {
				runWithString(@"- sel1:var1 sel2:var2 __a b;", ^(id parser, id tokens) {
					// setup
					id store = [OCMockObject mockForClass:[Store class]];
					[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
					[[store expect] beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
					[[store expect] beginMethodArgument];
					[[store expect] appendMethodArgumentSelector:@"sel1"];
					[[store expect] appendMethodArgumentVariable:@"var1"];
					[[store expect] endCurrentObject]; // method argument
					[[store expect] beginMethodArgument];
					[[store expect] appendMethodArgumentSelector:@"sel2"];
					[[store expect] appendMethodArgumentVariable:@"var2"];
					[[store expect] endCurrentObject]; // method argument
					[[store expect] beginMethodDescriptors];
					[[store expect] appendDescriptor:@"__a"];
					[[store expect] appendDescriptor:@"b"];
					[[store expect] endCurrentObject]; // method descriptors
					[[store expect] endCurrentObject]; // method definition
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

		it(@"should allow double underscore prefixed word as argument variable name", ^{
			runWithState(^(ObjectiveCMethodState *state) {
				runWithString(@"- sel1:var1 sel2:__a __b;", ^(id parser, id tokens) {
					// setup
					id store = [OCMockObject mockForClass:[Store class]];
					[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
					[[store expect] beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
					[[store expect] beginMethodArgument];
					[[store expect] appendMethodArgumentSelector:@"sel1"];
					[[store expect] appendMethodArgumentVariable:@"var1"];
					[[store expect] endCurrentObject]; // method argument
					[[store expect] beginMethodArgument];
					[[store expect] appendMethodArgumentSelector:@"sel2"];
					[[store expect] appendMethodArgumentVariable:@"__a"];
					[[store expect] endCurrentObject]; // method argument
					[[store expect] beginMethodDescriptors];
					[[store expect] appendDescriptor:@"__b"];
					[[store expect] endCurrentObject]; // method descriptors
					[[store expect] endCurrentObject]; // method definition
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
		
		it(@"should take uppercase word after last selector as descriptor", ^{
			runWithState(^(ObjectiveCMethodState *state) {
				runWithString(@"- sel1:var1 sel2:var2 A;", ^(id parser, id tokens) {
					// setup
					id store = [OCMockObject mockForClass:[Store class]];
					[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
					[[store expect] beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
					[[store expect] beginMethodArgument];
					[[store expect] appendMethodArgumentSelector:@"sel1"];
					[[store expect] appendMethodArgumentVariable:@"var1"];
					[[store expect] endCurrentObject]; // method argument
					[[store expect] beginMethodArgument];
					[[store expect] appendMethodArgumentSelector:@"sel2"];
					[[store expect] appendMethodArgumentVariable:@"var2"];
					[[store expect] endCurrentObject]; // method argument
					[[store expect] beginMethodDescriptors];
					[[store expect] appendDescriptor:@"A"];
					[[store expect] endCurrentObject]; // method descriptors
					[[store expect] endCurrentObject]; // method definition
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
		
		it(@"should take all words after uppercase word after last selector as descriptors", ^{
			runWithState(^(ObjectiveCMethodState *state) {
				runWithString(@"- sel1:var1 sel2:var2 A b;", ^(id parser, id tokens) {
					// setup
					id store = [OCMockObject mockForClass:[Store class]];
					[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
					[[store expect] beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
					[[store expect] beginMethodArgument];
					[[store expect] appendMethodArgumentSelector:@"sel1"];
					[[store expect] appendMethodArgumentVariable:@"var1"];
					[[store expect] endCurrentObject]; // method argument
					[[store expect] beginMethodArgument];
					[[store expect] appendMethodArgumentSelector:@"sel2"];
					[[store expect] appendMethodArgumentVariable:@"var2"];
					[[store expect] endCurrentObject]; // method argument
					[[store expect] beginMethodDescriptors];
					[[store expect] appendDescriptor:@"A"];
					[[store expect] appendDescriptor:@"b"];
					[[store expect] endCurrentObject]; // method descriptors
					[[store expect] endCurrentObject]; // method definition
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
		
		it(@"should allow uppercase word as argument variable name", ^{
			runWithState(^(ObjectiveCMethodState *state) {
				runWithString(@"- sel1:var1 sel2:A B;", ^(id parser, id tokens) {
					// setup
					id store = [OCMockObject mockForClass:[Store class]];
					[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
					[[store expect] beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
					[[store expect] beginMethodArgument];
					[[store expect] appendMethodArgumentSelector:@"sel1"];
					[[store expect] appendMethodArgumentVariable:@"var1"];
					[[store expect] endCurrentObject]; // method argument
					[[store expect] beginMethodArgument];
					[[store expect] appendMethodArgumentSelector:@"sel2"];
					[[store expect] appendMethodArgumentVariable:@"A"];
					[[store expect] endCurrentObject]; // method argument
					[[store expect] beginMethodDescriptors];
					[[store expect] appendDescriptor:@"B"];
					[[store expect] endCurrentObject]; // method descriptors
					[[store expect] endCurrentObject]; // method definition
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

describe(@"multiple successive methods", ^{
	it(@"shuold detect all definitions", ^{
		runWithState(^(ObjectiveCMethodState *state) {
			runWithFile(@"MethodStateMultipleDefinitions.h", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
				[[store expect] beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
				[[store expect] beginMethodResults];
				[[store expect] appendType:@"void"];
				[[store expect] endCurrentObject]; // method result
				[[store expect] beginMethodArgument];
				[[store expect] appendMethodArgumentSelector:@"method1"];
				[[store expect] endCurrentObject]; // method argument
				[[store expect] endCurrentObject]; // method definition
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
				[[store expect] beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
				[[store expect] beginMethodResults];
				[[store expect] appendType:@"void"];
				[[store expect] endCurrentObject]; // method result
				[[store expect] beginMethodArgument];
				[[store expect] appendMethodArgumentSelector:@"method2"];
				[[store expect] beginMethodArgumentTypes];
				[[store expect] appendType:@"int"];
				[[store expect] endCurrentObject]; // argument types
				[[store expect] appendMethodArgumentVariable:@"arg"];
				[[store expect] endCurrentObject]; // method argument
				[[store expect] endCurrentObject]; // method definition
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
				[[store expect] beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
				[[store expect] beginMethodResults];
				[[store expect] appendType:@"void"];
				[[store expect] endCurrentObject]; // method result
				[[store expect] beginMethodArgument];
				[[store expect] appendMethodArgumentSelector:@"method3"];
				[[store expect] beginMethodArgumentTypes];
				[[store expect] appendType:@"int"];
				[[store expect] endCurrentObject]; // argument types
				[[store expect] appendMethodArgumentVariable:@"arg1"];
				[[store expect] endCurrentObject]; // method argument
				[[store expect] beginMethodArgument];
				[[store expect] appendMethodArgumentSelector:@"second"];
				[[store expect] beginMethodArgumentTypes];
				[[store expect] appendType:@"NSString"];
				[[store expect] appendType:@"*"];
				[[store expect] appendType:@"*"];
				[[store expect] endCurrentObject]; // argument types
				[[store expect] appendMethodArgumentVariable:@"arg2"];
				[[store expect] endCurrentObject]; // method argument
				[[store expect] endCurrentObject]; // method definition
				ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
				// execute
				[state parseWithData:data];
				[state parseWithData:data];
				[state parseWithData:data];
				// verify
				^{ [store verify]; } should_not raise_exception();
			});
		});
	});
	
	it(@"should detect declarations ignoring method bodies", ^{
		runWithState(^(ObjectiveCMethodState *state) {
			runWithFile(@"MethodStateMultipleDeclarations.m", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
				[[store expect] beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
				[[store expect] beginMethodResults];
				[[store expect] appendType:@"void"];
				[[store expect] endCurrentObject]; // method result
				[[store expect] beginMethodArgument];
				[[store expect] appendMethodArgumentSelector:@"method1"];
				[[store expect] endCurrentObject]; // method argument
				[[store expect] endCurrentObject]; // method definition
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
				[[store expect] beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
				[[store expect] beginMethodResults];
				[[store expect] appendType:@"void"];
				[[store expect] endCurrentObject]; // method result
				[[store expect] beginMethodArgument];
				[[store expect] appendMethodArgumentSelector:@"method2"];
				[[store expect] beginMethodArgumentTypes];
				[[store expect] appendType:@"int"];
				[[store expect] endCurrentObject]; // argument types
				[[store expect] appendMethodArgumentVariable:@"arg"];
				[[store expect] endCurrentObject]; // method argument
				[[store expect] endCurrentObject]; // method definition
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
				[[store expect] beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
				[[store expect] beginMethodResults];
				[[store expect] appendType:@"void"];
				[[store expect] endCurrentObject]; // method result
				[[store expect] beginMethodArgument];
				[[store expect] appendMethodArgumentSelector:@"method3"];
				[[store expect] beginMethodArgumentTypes];
				[[store expect] appendType:@"int"];
				[[store expect] endCurrentObject]; // argument types
				[[store expect] appendMethodArgumentVariable:@"arg1"];
				[[store expect] endCurrentObject]; // method argument
				[[store expect] beginMethodArgument];
				[[store expect] appendMethodArgumentSelector:@"second"];
				[[store expect] beginMethodArgumentTypes];
				[[store expect] appendType:@"NSString"];
				[[store expect] appendType:@"*"];
				[[store expect] appendType:@"*"];
				[[store expect] endCurrentObject]; // argument types
				[[store expect] appendMethodArgumentVariable:@"arg2"];
				[[store expect] endCurrentObject]; // method argument
				[[store expect] endCurrentObject]; // method definition
				ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
				// execute
				[state parseWithData:data];
				[state parseWithData:data];
				[state parseWithData:data];
				// verify
				^{ [store verify]; } should_not raise_exception();
			});
		});
	});
});

describe(@"various fail cases", ^{
	it(@"should cancel if closing results parenthesis is not found", ^{
		runWithState(^(ObjectiveCMethodState *state) {
			runWithString(@"- (type method;", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
				[[store expect] beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
				[[store expect] beginMethodResults];
				[[store expect] appendType:@"type"];
				[[store expect] appendType:@"method"];
				[[store expect] cancelCurrentObject]; // result types
				[[store expect] cancelCurrentObject]; // method definition
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
	
	it(@"should cancel if closing argument variable type parenthesis is not found", ^{
		runWithState(^(ObjectiveCMethodState *state) {
			runWithString(@"- method:(type;", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
				[[store expect] beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
				[[store expect] beginMethodArgument];
				[[store expect] appendMethodArgumentSelector:@"method"];
				[[store expect] beginMethodArgumentTypes];
				[[store expect] appendType:@"type"];
				[[store expect] cancelCurrentObject]; // result types
				[[store expect] cancelCurrentObject]; // method argument
				[[store expect] cancelCurrentObject]; // method definition
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

	it(@"should cancel if method requires argument but doesn't provide variable name", ^{
		// this is otherwise valid Objective C syntax, but appledoc doesn't accept it at this point...
		runWithState(^(ObjectiveCMethodState *state) {
			runWithString(@"- method:;", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
				[[store expect] beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
				[[store expect] beginMethodArgument];
				[[store expect] appendMethodArgumentSelector:@"method"];
				[[store expect] cancelCurrentObject]; // method argument
				[[store expect] cancelCurrentObject]; // method definition
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
	
	it(@"should cancel if method starts descriptors but doesn't end", ^{
		// this is otherwise valid Objective C syntax, but appledoc doesn't accept it at this point...
		runWithState(^(ObjectiveCMethodState *state) {
			runWithString(@"- method:var __a", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
				[[store expect] beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
				[[store expect] beginMethodArgument];
				[[store expect] appendMethodArgumentSelector:@"method"];
				[[store expect] appendMethodArgumentVariable:@"var"];
				[[store expect] endCurrentObject]; // method argument
				[[store expect] beginMethodDescriptors];
				[[store expect] appendDescriptor:@"__a"];
				[[store expect] cancelCurrentObject]; // method descriptors
				[[store expect] cancelCurrentObject]; // method definition
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

#pragma mark - 
#pragma mark Just few quick cases for verifying class methods and declaration parsing support
#pragma mark As we use exactly the same code for all these, we just verify simple cases here

describe(@"class methods", ^{
	it(@"should detect definition", ^{
		runWithState(^(ObjectiveCMethodState *state) {
			runWithString(@"+ (type)method;", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
				[[store expect] beginMethodDefinitionWithType:GBStoreTypes.classMethod];
				[[store expect] beginMethodResults];
				[[store expect] appendType:@"type"];
				[[store expect] endCurrentObject]; // result types
				[[store expect] beginMethodArgument];
				[[store expect] appendMethodArgumentSelector:@"method"];
				[[store expect] endCurrentObject]; // method argument
				[[store expect] endCurrentObject]; // method definition
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
	
	it(@"should detect declaration", ^{
		runWithState(^(ObjectiveCMethodState *state) {
			runWithString(@"+ (type)method {", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
				[[store expect] beginMethodDefinitionWithType:GBStoreTypes.classMethod];
				[[store expect] beginMethodResults];
				[[store expect] appendType:@"type"];
				[[store expect] endCurrentObject]; // result types
				[[store expect] beginMethodArgument];
				[[store expect] appendMethodArgumentSelector:@"method"];
				[[store expect] endCurrentObject]; // method argument
				[[store expect] endCurrentObject]; // method definition
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
