//
//  ObjectiveCInterfaceStateTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/28/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectiveCInterfaceState.h"
#import "ObjectiveCStateTestsBase.h"

@interface ObjectiveCInterfaceStateTests : ObjectiveCStateTestsBase
@end

@interface ObjectiveCInterfaceStateTests (CreationMethods)
- (void)runWithState:(void(^)(ObjectiveCInterfaceState *state))handler;
@end

#pragma mark - 

@implementation ObjectiveCInterfaceStateTests

#pragma mark - Parsing adopted protocols

- (void)testParseStreamForParserStoreShouldRegisterSingleAdoptedProtocolToStore {
	[self runWithState:^(ObjectiveCInterfaceState *state) {
		[self runWithString:@"<MyProtocol>" block:^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] appendAdoptedProtocolWithName:@"MyProtocol"];
			// execute
			[state parseStream:tokens forParser:parser store:store];
			// verify
			STAssertNoThrow([store verify], nil);
		}];
	}];
}

- (void)testParseStreamForParserStoreShouldRegisterMultipleAdoptedProtocolsToStore {
	[self runWithState:^(ObjectiveCInterfaceState *state) {
		[self runWithString:@"<MyProtocol1, MyProtocol2, MyProtocol3>" block:^(id parser, id tokens) {
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
			STAssertNoThrow([store verify], nil);
		}];
	}];
}

#pragma mark - Parsing @end

- (void)testParseStreamForParserStoreShouldRegisterInterfaceEndToStore {
	[self runWithState:^(ObjectiveCInterfaceState *state) {
		[self runWithString:@"@end" block:^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] endCurrentObject];
			[[parser expect] popState];
			// execute
			[state parseStream:tokens forParser:parser store:store];
			// verify
			STAssertNoThrow([store verify], nil);
			STAssertNoThrow([parser verify], nil);
		}];
	}];
}

#pragma mark - Parsing methods and properties

- (void)testParseStreamForParserStoreShouldDetectPossibleInstanceMethod {
	[self runWithState:^(ObjectiveCInterfaceState *state) {
		[self runWithString:@"-" block:^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[parser expect] pushState:[parser methodState]];
			// execute
			[state parseStream:tokens forParser:parser store:store];
			// verify
			STAssertNoThrow([parser verify], nil);
		}];
	}];
}

- (void)testParseStreamForParserStoreShouldDetectPossibleClassMethod {
	[self runWithState:^(ObjectiveCInterfaceState *state) {
		[self runWithString:@"+" block:^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[parser expect] pushState:[parser methodState]];
			// execute
			[state parseStream:tokens forParser:parser store:store];
			// verify
			STAssertNoThrow([parser verify], nil);
		}];
	}];
}

- (void)testParseStreamForParserStoreShouldDetectPossibleProperty {
	[self runWithState:^(ObjectiveCInterfaceState *state) {
		[self runWithString:@"@property" block:^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[parser expect] pushState:[parser propertyState]];
			// execute
			[state parseStream:tokens forParser:parser store:store];
			// verify
			STAssertNoThrow([parser verify], nil);
		}];
	}];
}

#pragma mark - Parsing #pragma mark

- (void)testParseStreamForParserStoreShouldDetectPossiblePragmaMark {
	[self runWithState:^(ObjectiveCInterfaceState *state) {
		[self runWithString:@"#pragma mark" block:^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[parser expect] pushState:[parser pragmaMarkState]];
			// execute
			[state parseStream:tokens forParser:parser store:store];
			// verify
			STAssertNoThrow([parser verify], nil);
		}];
	}];
}

@end

#pragma mark - 

@implementation ObjectiveCInterfaceStateTests (CreationMethods)

- (void)runWithState:(void(^)(ObjectiveCInterfaceState *state))handler {
	ObjectiveCInterfaceState* state = [ObjectiveCInterfaceState new];
	handler(state);
}

@end