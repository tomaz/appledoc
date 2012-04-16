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
			[[store expect] beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
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
			[[store expect] beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
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
			[[store expect] beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
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

- (void)testParseStreamForParserStoreShouldDetectInstanceMethodDefinitionWithSingleArgumentWithNoType {
	[self runWithState:^(ObjectiveCMethodState *state) {
		[self runWithString:@"- method:var;" block:^(id parser, id tokens) {
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
			// execute
			[state parseStream:tokens forParser:parser store:store];
			// verify
			STAssertNoThrow([store verify], nil);
			STAssertNoThrow([parser verify], nil);
		}];
	}];
}

- (void)testParseStreamForParserStoreShouldDetectInstanceMethodDefinitionWithSingleArgumentWithSingleType {
	[self runWithState:^(ObjectiveCMethodState *state) {
		[self runWithString:@"- method:(type1)var;" block:^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
			[[store expect] beginMethodArgument];
			[[store expect] appendMethodArgumentSelector:@"method"];
			[[store expect] beginTypeDefinition];
			[[store expect] appendType:@"type1"];
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

- (void)testParseStreamForParserStoreShouldDetectInstanceMethodDefinitionWithSingleArgumentWithMultipleTypes {
	[self runWithState:^(ObjectiveCMethodState *state) {
		[self runWithString:@"- method:(type1 type2 type3)var;" block:^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
			[[store expect] beginMethodArgument];
			[[store expect] appendMethodArgumentSelector:@"method"];
			[[store expect] beginTypeDefinition];
			[[store expect] appendType:@"type1"];
			[[store expect] appendType:@"type2"];
			[[store expect] appendType:@"type3"];
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

- (void)testParseStreamForParserStoreShouldDetectInstanceMethodDefinitionWithMultipleArgumentsWithNoType {
	[self runWithState:^(ObjectiveCMethodState *state) {
		[self runWithString:@"- method:var1 that:var2 rocks:var3;" block:^(id parser, id tokens) {
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
			// execute
			[state parseStream:tokens forParser:parser store:store];
			// verify
			STAssertNoThrow([store verify], nil);
			STAssertNoThrow([parser verify], nil);
		}];
	}];
}

- (void)testParseStreamForParserStoreShouldDetectInstanceMethodDefinitionWithMultipleArgumentsWithTypes {
	[self runWithState:^(ObjectiveCMethodState *state) {
		[self runWithString:@"- method:(type1)var1 that:(type2 type3)var2 rocks:(type4 type5 type6)var3;" block:^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
			[[store expect] beginMethodArgument];
			[[store expect] appendMethodArgumentSelector:@"method"];
			[[store expect] beginTypeDefinition];
			[[store expect] appendType:@"type1"];
			[[store expect] endCurrentObject]; // argument types
			[[store expect] appendMethodArgumentVariable:@"var1"];
			[[store expect] endCurrentObject]; // method argument
			[[store expect] beginMethodArgument];
			[[store expect] appendMethodArgumentSelector:@"that"];
			[[store expect] beginTypeDefinition];
			[[store expect] appendType:@"type2"];
			[[store expect] appendType:@"type3"];
			[[store expect] endCurrentObject]; // argument types
			[[store expect] appendMethodArgumentVariable:@"var2"];
			[[store expect] endCurrentObject]; // method argument
			[[store expect] beginMethodArgument];
			[[store expect] appendMethodArgumentSelector:@"rocks"];
			[[store expect] beginTypeDefinition];
			[[store expect] appendType:@"type4"];
			[[store expect] appendType:@"type5"];
			[[store expect] appendType:@"type6"];
			[[store expect] endCurrentObject]; // argument types
			[[store expect] appendMethodArgumentVariable:@"var3"];
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
			[[store expect] beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
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

- (void)testParseStreamForParserStoreShouldFailIfClosingArgumentVariableTypeParenthesisIsNotFound {
	[self runWithState:^(ObjectiveCMethodState *state) {
		[self runWithString:@"- method:(type;" block:^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
			[[store expect] beginMethodArgument];
			[[store expect] appendMethodArgumentSelector:@"method"];
			[[store expect] beginTypeDefinition];
			[[store expect] appendType:@"type"];
			[[store expect] cancelCurrentObject]; // result types
			[[store expect] cancelCurrentObject]; // method argument
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
			[[store expect] beginMethodDefinitionWithType:GBStoreTypes.classMethod];
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
			[[store expect] beginMethodDefinitionWithType:GBStoreTypes.classMethod];
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
			[[store expect] beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
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