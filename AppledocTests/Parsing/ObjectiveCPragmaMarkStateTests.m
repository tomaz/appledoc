//
//  ObjectiveCPragmaMarkStateTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/30/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectiveCPragmaMarkState.h"
#import "ObjectiveCStateTestsBase.h"

@interface ObjectiveCPragmaMarkStateTests : ObjectiveCStateTestsBase
@end

@interface ObjectiveCPragmaMarkStateTests (CreationMethods)
- (void)runWithState:(void(^)(ObjectiveCPragmaMarkState *state))handler;
@end

#pragma mark - 

@implementation ObjectiveCPragmaMarkStateTests

#pragma mark - Simple cases

- (void)testParseStreamForParserStoreShouldDetectPragmaMarkWithSingleWord {
	[self runWithState:^(ObjectiveCPragmaMarkState *state) {
		[self runWithString:@"#pragma mark word" block:^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginMethodGroup];
			[[store expect] appendDescription:@"word"];
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

- (void)testParseStreamForParserStoreShouldDetectPragmaMarkWithMultipleWords {
	[self runWithState:^(ObjectiveCPragmaMarkState *state) {
		[self runWithString:@"#pragma mark word1 word2 word3" block:^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginMethodGroup];
			[[store expect] appendDescription:@"word1 word2 word3"];
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

#pragma mark - Using -

- (void)testParseStreamForParserStoreShouldDetectPragmaMarkWithMinusPrefix {
	[self runWithState:^(ObjectiveCPragmaMarkState *state) {
		[self runWithString:@"#pragma mark - word1 word2 word3" block:^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginMethodGroup];
			[[store expect] appendDescription:@"word1 word2 word3"];
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

- (void)testParseStreamForParserStoreShouldDetectPragmaMarkWithMinusPrefixAndTakeMinusSuffixAsPartOfDescription {
	[self runWithState:^(ObjectiveCPragmaMarkState *state) {
		[self runWithString:@"#pragma mark - word1 word2 word3 -" block:^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginMethodGroup];
			[[store expect] appendDescription:@"word1 word2 word3 -"];
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

#pragma mark - Various edge cases

- (void)testParseStreamForParserStoreShouldSkipPragmaMarkIfWhitespaceOnlyIsUsedForDescription {
	[self runWithState:^(ObjectiveCPragmaMarkState *state) {
		[self runWithString:@"#pragma mark - \t  \t \n" block:^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
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

@implementation ObjectiveCPragmaMarkStateTests (CreationMethods)

- (void)runWithState:(void(^)(ObjectiveCPragmaMarkState *state))handler {
	ObjectiveCPragmaMarkState* state = [ObjectiveCPragmaMarkState new];
	handler(state);
}

@end