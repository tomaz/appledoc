//
//  ObjectiveCPropertyStateTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/28/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectiveCPropertyState.h"
#import "ObjectiveCStateTestsBase.h"

@interface ObjectiveCPropertyStateTests : ObjectiveCStateTestsBase
@end

@interface ObjectiveCPropertyStateTests (CreationMethods)
- (void)runWithState:(void(^)(ObjectiveCPropertyState *state))handler;
@end

#pragma mark - 

@implementation ObjectiveCPropertyStateTests

- (void)testParseStreamForParserStoreShouldDetectPropertyWithNoAttributes {
	[self runWithState:^(ObjectiveCPropertyState *state) {
		[self runWithString:@"@property type name;" block:^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginPropertyDefinition];
			[[store expect] beginTypeDefinition];
			[[store expect] appendType:@"type"];
			[[store expect] endCurrentObject];
			[[store expect] appendPropertyName:@"name"];
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

@end

#pragma mark - 

@implementation ObjectiveCPropertyStateTests (CreationMethods)

- (void)runWithState:(void(^)(ObjectiveCPropertyState *state))handler {
	ObjectiveCPropertyState* state = [ObjectiveCPropertyState new];
	handler(state);
}

@end