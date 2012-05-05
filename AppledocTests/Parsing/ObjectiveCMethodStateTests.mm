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

SPEC_BEGIN(ObjectiveCMethodStateTests)

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

describe(@"multiple methods", ^{
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

SPEC_END
