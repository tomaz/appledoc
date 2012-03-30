//
//  ObjectiveCEnumStateTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/30/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectiveCEnumState.h"
#import "ObjectiveCStateTestsBase.h"

@interface ObjectiveCEnumStateTests : ObjectiveCStateTestsBase
@end

@interface ObjectiveCEnumStateTests (CreationMethods)
- (void)runWithState:(void(^)(ObjectiveCEnumState *state))handler;
@end

#pragma mark - 

@implementation ObjectiveCEnumStateTests

#pragma mark - Simple cases

- (void)testParseStreamForParserStoreShouldDetectEmptyEnum {
	[self runWithState:^(ObjectiveCEnumState *state) {
		[self runWithString:@"enum {};" block:^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginEnumeration];
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

- (void)testParseStreamForParserStoreShouldSkipAnythingBetweenEnumKeywordAndStartOfEnumBody {
	[self runWithState:^(ObjectiveCEnumState *state) {
		[self runWithString:@"enum word1 word2 word3 {};" block:^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginEnumeration];
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

- (void)testParseStreamForParserStoreShouldDetectEnumWithSingleItemWithoutValue {
	[self runWithState:^(ObjectiveCEnumState *state) {
		[self runWithString:@"enum { item };" block:^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginEnumeration];
			[[store expect] appendEnumerationItem:@"item"];
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

- (void)testParseStreamForParserStoreShouldDetectEnumWithSingleItemWithValue {
	[self runWithState:^(ObjectiveCEnumState *state) {
		[self runWithString:@"enum { item = value };" block:^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginEnumeration];
			[[store expect] appendEnumerationItem:@"item"];
			[[store expect] appendEnumerationValue:@"value"];
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

- (void)testParseStreamForParserStoreShouldDetectEnumWithSingleItemWithValueEvenIfDelimitedByComma {
	[self runWithState:^(ObjectiveCEnumState *state) {
		[self runWithString:@"enum { item = value, };" block:^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginEnumeration];
			[[store expect] appendEnumerationItem:@"item"];
			[[store expect] appendEnumerationValue:@"value"];
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

#pragma mark - Enumerations with multiple items

- (void)testParseStreamForParserStoreShouldDetectEnumWithMultipleItemWithoutValues {
	[self runWithState:^(ObjectiveCEnumState *state) {
		[self runWithString:@"enum { item1, item2, item3 };" block:^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginEnumeration];
			[[store expect] appendEnumerationItem:@"item1"];
			[[store expect] appendEnumerationItem:@"item2"];
			[[store expect] appendEnumerationItem:@"item3"];
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

- (void)testParseStreamForParserStoreShouldDetectEnumWithMultipleItemWithValues {
	[self runWithState:^(ObjectiveCEnumState *state) {
		[self runWithString:@"enum { item1 = value1, item2 = value2, item3 = value3 };" block:^(id parser, id tokens) {
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
			// execute
			[state parseStream:tokens forParser:parser store:store];
			// verify
			STAssertNoThrow([store verify], nil);
			STAssertNoThrow([parser verify], nil);
		}];
	}];
}

- (void)testParseStreamForParserStoreShouldDetectEnumWithMultipleItemWithMixedValues {
	[self runWithState:^(ObjectiveCEnumState *state) {
		[self runWithString:@"enum { item1 = value1, item2, item3 = value3, };" block:^(id parser, id tokens) {
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
			// execute
			[state parseStream:tokens forParser:parser store:store];
			// verify
			STAssertNoThrow([store verify], nil);
			STAssertNoThrow([parser verify], nil);
		}];
	}];
}

#pragma mark - More realistic values

- (void)testParseStreamForParserStoreShouldDetectEnumWithComplexValues {
	[self runWithState:^(ObjectiveCEnumState *state) {
		[self runWithString:@"enum { item1 = (1 << 0), item2 = (item2 + 30 * (1 << 4)) };" block:^(id parser, id tokens) {
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
			// execute
			[state parseStream:tokens forParser:parser store:store];
			// verify
			STAssertNoThrow([store verify], nil);
			STAssertNoThrow([parser verify], nil);
		}];
	}];
}

#pragma mark - Various failure cases

- (void)testParseStreamForParserStoreShouldFailIfStartOfEnumBodyIsMissing {
	[self runWithState:^(ObjectiveCEnumState *state) {
		[self runWithString:@"enum word1 word2 word3 };" block:^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginEnumeration];
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

- (void)testParseStreamForParserStoreShouldFailIfEndOfEnumBodyIsMissing {
	[self runWithState:^(ObjectiveCEnumState *state) {
		[self runWithString:@"enum { item ;" block:^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginEnumeration];
			[[store expect] appendEnumerationItem:@"item"];
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

@implementation ObjectiveCEnumStateTests (CreationMethods)

- (void)runWithState:(void(^)(ObjectiveCEnumState *state))handler {
	ObjectiveCEnumState* state = [ObjectiveCEnumState new];
	handler(state);
}

@end