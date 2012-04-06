//
//  ObjectiveCStructStateTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/30/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectiveCStructState.h"
#import "ObjectiveCStateTestsBase.h"

@interface ObjectiveCStructStateTests : ObjectiveCStateTestsBase
@end

@interface ObjectiveCStructStateTests (CreationMethods)
- (void)runWithState:(void(^)(ObjectiveCStructState *state))handler;
@end

#pragma mark - 

@implementation ObjectiveCStructStateTests

#pragma mark - Simple cases

- (void)testParseStreamForParserStoreShouldDetectEmptyStruct {
	[self runWithState:^(ObjectiveCStructState *state) {
		[self runWithString:@"struct {};" block:^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginStruct];
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

#pragma mark - Single items and no values

- (void)testParseStreamForParserStoreShouldDetectStructWithSingleItemWithSingleTypeAndNoValue {
	[self runWithState:^(ObjectiveCStructState *state) {
		[self runWithString:@"struct { type item; };" block:^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginStruct];
			[[store expect] beginConstant];
			[[store expect] appendConstantType:@"type"];
			[[store expect] appendConstantName:@"item"];
			[[store expect] endCurrentObject]; // constant
			[[store expect] endCurrentObject]; // struct
			[[parser expect] popState];
			// execute
			[state parseStream:tokens forParser:parser store:store];
			// verify
			STAssertNoThrow([store verify], nil);
			STAssertNoThrow([parser verify], nil);
		}];
	}];
}

- (void)testParseStreamForParserStoreShouldDetectStructWithSingleItemWithMultipleTypesAndNoValues {
	[self runWithState:^(ObjectiveCStructState *state) {
		[self runWithString:@"struct { type1 type2 type3 item; };" block:^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginStruct];
			[[store expect] beginConstant];
			[[store expect] appendConstantType:@"type1"];
			[[store expect] appendConstantType:@"type2"];
			[[store expect] appendConstantType:@"type3"];
			[[store expect] appendConstantName:@"item"];
			[[store expect] endCurrentObject]; // constant
			[[store expect] endCurrentObject]; // struct
			[[parser expect] popState];
			// execute
			[state parseStream:tokens forParser:parser store:store];
			// verify
			STAssertNoThrow([store verify], nil);
			STAssertNoThrow([parser verify], nil);
		}];
	}];
}

#pragma mark - Multiple items and no values

- (void)testParseStreamForParserStoreShouldDetectStructWithMultipleItemsWithSingleTypeAndNoValue {
	[self runWithState:^(ObjectiveCStructState *state) {
		[self runWithString:@"struct { type1 item1; type2 item2; };" block:^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginStruct];
			[[store expect] beginConstant];
			[[store expect] appendConstantType:@"type1"];
			[[store expect] appendConstantName:@"item1"];
			[[store expect] endCurrentObject]; // constant
			[[store expect] beginConstant];
			[[store expect] appendConstantType:@"type2"];
			[[store expect] appendConstantName:@"item2"];
			[[store expect] endCurrentObject]; // constant
			[[store expect] endCurrentObject]; // struct
			[[parser expect] popState];
			// execute
			[state parseStream:tokens forParser:parser store:store];
			// verify
			STAssertNoThrow([store verify], nil);
			STAssertNoThrow([parser verify], nil);
		}];
	}];
}

- (void)testParseStreamForParserStoreShouldDetectStructWithMultipleItemWithMultipleTypesAndNoValues {
	[self runWithState:^(ObjectiveCStructState *state) {
		[self runWithString:@"struct { typeA1 typeA2 typeA3 itemA; typeB1 typeB2 typeB3 itemB; };" block:^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginStruct];
			[[store expect] beginConstant];
			[[store expect] appendConstantType:@"typeA1"];
			[[store expect] appendConstantType:@"typeA2"];
			[[store expect] appendConstantType:@"typeA3"];
			[[store expect] appendConstantName:@"itemA"];
			[[store expect] endCurrentObject]; // constant
			[[store expect] beginConstant];
			[[store expect] appendConstantType:@"typeB1"];
			[[store expect] appendConstantType:@"typeB2"];
			[[store expect] appendConstantType:@"typeB3"];
			[[store expect] appendConstantName:@"itemB"];
			[[store expect] endCurrentObject]; // constant
			[[store expect] endCurrentObject]; // struct
			[[parser expect] popState];
			// execute
			[state parseStream:tokens forParser:parser store:store];
			// verify
			STAssertNoThrow([store verify], nil);
			STAssertNoThrow([parser verify], nil);
		}];
	}];
}

#pragma mark - Various failure cases

- (void)testParseStreamForParserStoreShouldFailIfStartOfStructBodyIsMissing {
	[self runWithState:^(ObjectiveCStructState *state) {
		[self runWithString:@"struct word1 word2 word3 };" block:^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginStruct];
			[[store expect] cancelCurrentObject];
			[[parser expect] popState];
			// execute
			[state parseStream:tokens forParser:parser store:store];
			// verify
			STAssertNoThrow([store verify], nil);
			STAssertNoThrow([parser verify], nil);
		}];
	}];
}

- (void)testParseStreamForParserStoreShouldFailIfEndOfStructBodyIsMissing {
	[self runWithState:^(ObjectiveCStructState *state) {
		[self runWithString:@"struct { item ;" block:^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginStruct];
			[[store expect] beginConstant];
			[[store expect] appendConstantName:@"item"];
			[[store expect] endCurrentObject]; // succesfull constant "item" parsed!
			[[store expect] cancelCurrentObject];
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

@implementation ObjectiveCStructStateTests (CreationMethods)

- (void)runWithState:(void(^)(ObjectiveCStructState *state))handler {
	ObjectiveCStructState* state = [ObjectiveCStructState new];
	handler(state);
}

@end