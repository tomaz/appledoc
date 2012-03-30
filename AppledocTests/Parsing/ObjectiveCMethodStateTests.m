//
//  ObjectiveCMethodStateTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/30/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectiveCMethodState.h"
#import "ObjectiveCStateTestsBase.h"

@interface ObjectiveCMethodStateTests : ObjectiveCStateTestsBase
@end

@interface ObjectiveCMethodStateTests (CreationMethods)
- (void)runWithState:(void(^)(ObjectiveCMethodState *state))handler;
@end

#pragma mark - 

@implementation ObjectiveCMethodStateTests

#pragma mark - No arguments methods

- (void)testParseStreamForParserStoreShouldDetectInstanceMethodDefinitionWithNoReturnType {
	[self runWithState:^(ObjectiveCMethodState *state) {
		[self runWithString:@"- method;" block:^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginMethodDefinition];
			[[store expect] appendMethodType:GBStoreTypes.instanceMethod];
			[[store expect] beginMethodArgument];
			[[store expect] appendMethodArgumentSelector:@"method"];
			[[store expect] endCurrentObject]; // method argument
			[[store expect] endCurrentObject]; // method definition
			[[parser expect] popState];
			// execute
			[state parseStream:tokens forParser:parser store:store];
			// verify
			STAssertNoThrow([store verify], nil);
			STAssertNoThrow([parser verify], nil);
		}];
	}];
}

- (void)testParseStreamForParserStoreShouldDetectInstanceMethodDefinitionWithSingleReturnTypeAndNoArguments {
	[self runWithState:^(ObjectiveCMethodState *state) {
		[self runWithString:@"- (type)method;" block:^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginMethodDefinition];
			[[store expect] appendMethodType:GBStoreTypes.instanceMethod];
			[[store expect] beginTypeDefinition];
			[[store expect] appendType:@"type"];
			[[store expect] endCurrentObject]; // result types
			[[store expect] beginMethodArgument];
			[[store expect] appendMethodArgumentSelector:@"method"];
			[[store expect] endCurrentObject]; // method argument
			[[store expect] endCurrentObject]; // method definition
			[[parser expect] popState];
			// execute
			[state parseStream:tokens forParser:parser store:store];
			// verify
			STAssertNoThrow([store verify], nil);
			STAssertNoThrow([parser verify], nil);
		}];
	}];
}

- (void)testParseStreamForParserStoreShouldDetectMethodDefinitionWithMultipleReturnTypesAndNoArguments {
	[self runWithState:^(ObjectiveCMethodState *state) {
		[self runWithString:@"- (type1 type2 type3)method;" block:^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginMethodDefinition];
			[[store expect] appendMethodType:GBStoreTypes.instanceMethod];
			[[store expect] beginTypeDefinition];
			[[store expect] appendType:@"type1"];
			[[store expect] appendType:@"type2"];
			[[store expect] appendType:@"type3"];
			[[store expect] endCurrentObject]; // result types
			[[store expect] beginMethodArgument];
			[[store expect] appendMethodArgumentSelector:@"method"];
			[[store expect] endCurrentObject]; // method argument
			[[store expect] endCurrentObject]; // method definition
			[[parser expect] popState];
			// execute
			[state parseStream:tokens forParser:parser store:store];
			// verify
			STAssertNoThrow([store verify], nil);
			STAssertNoThrow([parser verify], nil);
		}];
	}];
}

#pragma mark - Single argument methods

- (void)testParseStreamForParserStoreShouldDetectInstanceMethodDefinitionWithSingleReturnTypeAndSingleArgumentWithNoType {
	[self runWithState:^(ObjectiveCMethodState *state) {
		[self runWithString:@"- (type)method:var;" block:^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginMethodDefinition];
			[[store expect] appendMethodType:GBStoreTypes.instanceMethod];
			[[store expect] beginTypeDefinition];
			[[store expect] appendType:@"type"];
			[[store expect] endCurrentObject]; // result types
			[[store expect] beginMethodArgument];
			[[store expect] appendMethodArgumentSelector:@"method"];
			[[store expect] appendMethodArgumentVariable:@"var"];
			[[store expect] endCurrentObject]; // method argument
			[[store expect] endCurrentObject]; // method definition
			[[parser expect] popState];
			// execute
			[state parseStream:tokens forParser:parser store:store];
			// verify
			STAssertNoThrow([store verify], nil);
			STAssertNoThrow([parser verify], nil);
		}];
	}];
}

- (void)testParseStreamForParserStoreShouldDetectInstanceMethodDefinitionWithSingleReturnTypeAndSingleArgumentWithSingleType {
	[self runWithState:^(ObjectiveCMethodState *state) {
		[self runWithString:@"- (type1)method:(type2)var;" block:^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginMethodDefinition];
			[[store expect] appendMethodType:GBStoreTypes.instanceMethod];
			[[store expect] beginTypeDefinition];
			[[store expect] appendType:@"type1"];
			[[store expect] endCurrentObject]; // result types
			[[store expect] beginMethodArgument];
			[[store expect] appendMethodArgumentSelector:@"method"];
			[[store expect] beginTypeDefinition];
			[[store expect] appendType:@"type2"];
			[[store expect] endCurrentObject]; // argument types
			[[store expect] appendMethodArgumentVariable:@"var"];
			[[store expect] endCurrentObject]; // method argument
			[[store expect] endCurrentObject]; // method definition
			[[parser expect] popState];
			// execute
			[state parseStream:tokens forParser:parser store:store];
			// verify
			STAssertNoThrow([store verify], nil);
			STAssertNoThrow([parser verify], nil);
		}];
	}];
}

- (void)testParseStreamForParserStoreShouldDetectInstanceMethodDefinitionWithSingleReturnTypeAndSingleArgumentWithMultipleType {
	[self runWithState:^(ObjectiveCMethodState *state) {
		[self runWithString:@"- (type1)method:(type2 type3 type4)var;" block:^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginMethodDefinition];
			[[store expect] appendMethodType:GBStoreTypes.instanceMethod];
			[[store expect] beginTypeDefinition];
			[[store expect] appendType:@"type1"];
			[[store expect] endCurrentObject]; // result types
			[[store expect] beginMethodArgument];
			[[store expect] appendMethodArgumentSelector:@"method"];
			[[store expect] beginTypeDefinition];
			[[store expect] appendType:@"type2"];
			[[store expect] appendType:@"type3"];
			[[store expect] appendType:@"type4"];
			[[store expect] endCurrentObject]; // argument types
			[[store expect] appendMethodArgumentVariable:@"var"];
			[[store expect] endCurrentObject]; // method argument
			[[store expect] endCurrentObject]; // method definition
			[[parser expect] popState];
			// execute
			[state parseStream:tokens forParser:parser store:store];
			// verify
			STAssertNoThrow([store verify], nil);
			STAssertNoThrow([parser verify], nil);
		}];
	}];
}

#pragma mark - Verify various fail cases

- (void)testParseStreamForParserStoreShouldFailIfClosingResultsParenthesisIsNotFound {
	[self runWithState:^(ObjectiveCMethodState *state) {
		[self runWithString:@"- (type method;" block:^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginMethodDefinition];
			[[store expect] appendMethodType:GBStoreTypes.instanceMethod];
			[[store expect] beginTypeDefinition];
			[[store expect] appendType:@"type"];
			[[store expect] appendType:@"method"];
			[[store expect] cancelCurrentObject]; // result types
			[[store expect] cancelCurrentObject]; // method definition
			[[parser expect] popState];
			// execute
			[state parseStream:tokens forParser:parser store:store];
			// verify
			STAssertNoThrow([store verify], nil);
			STAssertNoThrow([parser verify], nil);
		}];
	}];
}

#pragma mark - 
#pragma mark Just few quick cases for verifying class methods and declaration parsing support
#pragma mark As we use exactly the same code for all these, we just verify simple cases here

- (void)testParseStreamForParserStoreShouldDetectClassMethodDefinition {
	[self runWithState:^(ObjectiveCMethodState *state) {
		[self runWithString:@"+ (type)method;" block:^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginMethodDefinition];
			[[store expect] appendMethodType:GBStoreTypes.classMethod];
			[[store expect] beginTypeDefinition];
			[[store expect] appendType:@"type"];
			[[store expect] endCurrentObject]; // result types
			[[store expect] beginMethodArgument];
			[[store expect] appendMethodArgumentSelector:@"method"];
			[[store expect] endCurrentObject]; // method argument
			[[store expect] endCurrentObject]; // method definition
			[[parser expect] popState];
			// execute
			[state parseStream:tokens forParser:parser store:store];
			// verify
			STAssertNoThrow([store verify], nil);
			STAssertNoThrow([parser verify], nil);
		}];
	}];
}

- (void)testParseStreamForParserStoreShouldDetectClassMethodDeclaration {
	[self runWithState:^(ObjectiveCMethodState *state) {
		[self runWithString:@"+ (type)method {" block:^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginMethodDefinition];
			[[store expect] appendMethodType:GBStoreTypes.classMethod];
			[[store expect] beginTypeDefinition];
			[[store expect] appendType:@"type"];
			[[store expect] endCurrentObject]; // result types
			[[store expect] beginMethodArgument];
			[[store expect] appendMethodArgumentSelector:@"method"];
			[[store expect] endCurrentObject]; // method argument
			[[store expect] endCurrentObject]; // method definition
			[[parser expect] popState];
			// execute
			[state parseStream:tokens forParser:parser store:store];
			// verify
			STAssertNoThrow([store verify], nil);
			STAssertNoThrow([parser verify], nil);
		}];
	}];
}

- (void)testParseStreamForParserStoreShouldDetectInstanceMethodDeclaration {
	[self runWithState:^(ObjectiveCMethodState *state) {
		[self runWithString:@"- (type)method {" block:^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginMethodDefinition];
			[[store expect] appendMethodType:GBStoreTypes.instanceMethod];
			[[store expect] beginTypeDefinition];
			[[store expect] appendType:@"type"];
			[[store expect] endCurrentObject]; // result types
			[[store expect] beginMethodArgument];
			[[store expect] appendMethodArgumentSelector:@"method"];
			[[store expect] endCurrentObject]; // method argument
			[[store expect] endCurrentObject]; // method definition
			[[parser expect] popState];
			// execute
			[state parseStream:tokens forParser:parser store:store];
			// verify
			STAssertNoThrow([store verify], nil);
			STAssertNoThrow([parser verify], nil);
		}];
	}];
}

@end

#pragma mark - 

@implementation ObjectiveCMethodStateTests (CreationMethods)

- (void)runWithState:(void(^)(ObjectiveCMethodState *state))handler {
	ObjectiveCMethodState* state = [ObjectiveCMethodState new];
	handler(state);
}

@end