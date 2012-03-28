//
//  ObjectiveCFileStateTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/27/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectiveCFileState.h"
#import "ObjectiveCStateTestsBase.h"

@interface ObjectiveCFileStateTests : ObjectiveCStateTestsBase
@end

@interface ObjectiveCFileStateTests (CreationMethods)
- (void)runWithState:(void(^)(ObjectiveCFileState *state))handler;
@end

#pragma mark - 

@implementation ObjectiveCFileStateTests

#pragma mark - Parsing classes

- (void)testParseStreamForParserStoreShouldRegisterRootClassToStore {
	[self runWithState:^(ObjectiveCFileState *state) {
		[self runWithString:@"@interface MyClass" block:^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginClassWithName:@"MyClass" derivedFromClassWithName:nil];
			[[parser expect] pushState:[parser interfaceState]];
			// execute
			[state parseStream:tokens forParser:parser store:store];
			// verify
			STAssertNoThrow([store verify], nil);
			STAssertNoThrow([parser verify], nil);
		}];
	}];
}

- (void)testParseStreamForParserStoreShouldRegisterSubclassToStore {
	[self runWithState:^(ObjectiveCFileState *state) {
		[self runWithString:@"@interface MyClass : SuperClass" block:^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginClassWithName:@"MyClass" derivedFromClassWithName:@"SuperClass"];
			[[parser expect] pushState:[parser interfaceState]];
			// execute
			[state parseStream:tokens forParser:parser store:store];
			// verify
			STAssertNoThrow([store verify], nil);
			STAssertNoThrow([parser verify], nil);
		}];
	}];
}

#pragma mark - Parsing categories

- (void)testParseStreamForParserStoreShouldRegisterClassExtensionToStore {
	[self runWithState:^(ObjectiveCFileState *state) {
		[self runWithString:@"@interface MyClass ()" block:^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginExtensionForClassWithName:@"MyClass"];
			[[parser expect] pushState:[parser interfaceState]];
			// execute
			[state parseStream:tokens forParser:parser store:store];
			// verify
			STAssertNoThrow([store verify], nil);
			STAssertNoThrow([parser verify], nil);
		}];
	}];
}

- (void)testParseStreamForParserStoreShouldRegisterClassCategoryToStore {
	[self runWithState:^(ObjectiveCFileState *state) {
		[self runWithString:@"@interface MyClass (CategoryName)" block:^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginCategoryWithName:@"CategoryName" forClassWithName:@"MyClass"];
			[[parser expect] pushState:[parser interfaceState]];
			// execute
			[state parseStream:tokens forParser:parser store:store];
			// verify
			STAssertNoThrow([store verify], nil);
			STAssertNoThrow([parser verify], nil);
		}];
	}];
}

#pragma mark - Parsing protocols

- (void)testParseStreamForParserStoreShouldRegisterProtocolToStore {
	[self runWithState:^(ObjectiveCFileState *state) {
		[self runWithString:@"@protocol MyProtocol" block:^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginProtocolWithName:@"MyProtocol"];
			[[parser expect] pushState:[parser interfaceState]];
			// execute
			[state parseStream:tokens forParser:parser store:store];
			// verify
			STAssertNoThrow([store verify], nil);
			STAssertNoThrow([parser verify], nil);
		}];
	}];
}

#pragma mark - Parsing enumerations

- (void)testParseStreamForParserStoreShouldDetectPossibleEnumeration {
	[self runWithState:^(ObjectiveCFileState *state) {
		[self runWithString:@"enum" block:^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[parser expect] pushState:[parser enumState]];
			// execute
			[state parseStream:tokens forParser:parser store:store];
			// verify
			STAssertNoThrow([parser verify], nil);
		}];
	}];
}

#pragma mark - Parsing structs

- (void)testParseStreamForParserStoreShouldDetectPossibleStruct {
	[self runWithState:^(ObjectiveCFileState *state) {
		[self runWithString:@"struct" block:^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[parser expect] pushState:[parser structState]];
			// execute
			[state parseStream:tokens forParser:parser store:store];
			// verify
			STAssertNoThrow([parser verify], nil);
		}];
	}];
}

@end

#pragma mark - 

@implementation ObjectiveCFileStateTests (CreationMethods)

- (void)runWithState:(void(^)(ObjectiveCFileState *state))handler {
	ObjectiveCFileState* state = [ObjectiveCFileState new];
	handler(state);
}

@end