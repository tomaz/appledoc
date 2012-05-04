//
//  ObjectiveCPropertyStateTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/28/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectiveCPropertyState.h"
#import "ObjectiveCStateTestsHelpers.h"
#import "TestCaseBase.hh"

static void runWithState(void(^handler)(ObjectiveCPropertyState *state)) {
	ObjectiveCPropertyState* state = [[ObjectiveCPropertyState alloc] init];
	handler(state);
	[state release];
}

#pragma mark - 

SPEC_BEGIN(ObjectiveCPropertyStateTests)

#pragma mark - Properties without attributes
/*
describe(@"", ^{
	it(@"ParseStreamForParserStoreShouldDetectPropertyWithNoAttributes", ^{
	runWithState(^(ObjectiveCPropertyState *state) {
		runWithString(@"@property type name;", ^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginPropertyDefinition];
			[[store expect] beginPropertyTypes];
			[[store expect] appendType:@"type"];
			[[store expect] endCurrentObject];
			[[store expect] appendPropertyName:@"name"];
			[[store expect] endCurrentObject];
			[[parser expect] popState];
			// execute
			[state parseStream:tokens forParser:parser store:store];
			// verify
			^{ [store verify]; } should_not raise_exception();
			^{ [parser verify]; } should_not raise_exception();
		});
	});
});
});

describe(@"", ^{
	it(@"ParseStreamForParserStoreShouldDetectPropertyWithNoAttributesWithMultipleTypes", ^{
	runWithState(^(ObjectiveCPropertyState *state) {
		runWithString(@"@property type1 type2 type3 name;", ^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginPropertyDefinition];
			[[store expect] beginPropertyTypes];
			[[store expect] appendType:@"type1"];
			[[store expect] appendType:@"type2"];
			[[store expect] appendType:@"type3"];
			[[store expect] endCurrentObject];
			[[store expect] appendPropertyName:@"name"];
			[[store expect] endCurrentObject];
			[[parser expect] popState];
			// execute
			[state parseStream:tokens forParser:parser store:store];
			// verify
			^{ [store verify]; } should_not raise_exception();
			^{ [parser verify]; } should_not raise_exception();
		});
	});
});
 });

#pragma mark - Properties with attributes

describe(@"", ^{
	it(@"ParseStreamForParserStoreShouldDetectPropertyWithSingleAttribute", ^{
	runWithState(^(ObjectiveCPropertyState *state) {
		runWithString(@"@property (attr) type name;", ^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginPropertyDefinition];
			[[store expect] beginPropertyAttributes];
			[[store expect] appendAttribute:@"attr"];
			[[store expect] endCurrentObject];
			[[store expect] beginPropertyTypes];
			[[store expect] appendType:@"type"];
			[[store expect] endCurrentObject];
			[[store expect] appendPropertyName:@"name"];
			[[store expect] endCurrentObject];
			[[parser expect] popState];
			// execute
			[state parseStream:tokens forParser:parser store:store];
			// verify
			^{ [store verify]; } should_not raise_exception();
			^{ [parser verify]; } should_not raise_exception();
		});
	});
});
 });

describe(@"", ^{
	it(@"ParseStreamForParserStoreShouldDetectPropertyWithMultipleAttributes", ^{
	runWithState(^(ObjectiveCPropertyState *state) {
		runWithString(@"@property (attr1, attr2, attr3) type name;", ^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginPropertyDefinition];
			[[store expect] beginPropertyAttributes];
			[[store expect] appendAttribute:@"attr1"];
			[[store expect] appendAttribute:@"attr2"];
			[[store expect] appendAttribute:@"attr3"];
			[[store expect] endCurrentObject];
			[[store expect] beginPropertyTypes];
			[[store expect] appendType:@"type"];
			[[store expect] endCurrentObject];
			[[store expect] appendPropertyName:@"name"];
			[[store expect] endCurrentObject];
			[[parser expect] popState];
			// execute
			[state parseStream:tokens forParser:parser store:store];
			// verify
			^{ [store verify]; } should_not raise_exception();
			^{ [parser verify]; } should_not raise_exception();
		});
	});
});
 });

describe(@"", ^{
	it(@"ParseStreamForParserStoreShouldDetectPropertyWithMultipleAttributesAndTypes", ^{
	runWithState(^(ObjectiveCPropertyState *state) {
		runWithString(@"@property (attr1, attr2, attr3) type1 type2 type3 name;", ^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginPropertyDefinition];
			[[store expect] beginPropertyAttributes];
			[[store expect] appendAttribute:@"attr1"];
			[[store expect] appendAttribute:@"attr2"];
			[[store expect] appendAttribute:@"attr3"];
			[[store expect] endCurrentObject];
			[[store expect] beginPropertyTypes];
			[[store expect] appendType:@"type1"];
			[[store expect] appendType:@"type2"];
			[[store expect] appendType:@"type3"];
			[[store expect] endCurrentObject];
			[[store expect] appendPropertyName:@"name"];
			[[store expect] endCurrentObject];
			[[parser expect] popState];
			// execute
			[state parseStream:tokens forParser:parser store:store];
			// verify
			^{ [store verify]; } should_not raise_exception();
			^{ [parser verify]; } should_not raise_exception();
		});
	});
});
 });

describe(@"", ^{
	it(@"ParseStreamForParserStoreShouldDetectPropertyWithCustomGetterAndSetter", ^{
	runWithState(^(ObjectiveCPropertyState *state) {
		runWithString(@"@property (getter=isName, setter=setName:) type name;", ^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginPropertyDefinition];
			[[store expect] beginPropertyAttributes];
			[[store expect] appendAttribute:@"getter"];
			[[store expect] appendAttribute:@"="];
			[[store expect] appendAttribute:@"isName"];
			[[store expect] appendAttribute:@"setter"];
			[[store expect] appendAttribute:@"="];
			[[store expect] appendAttribute:@"setName"];
			[[store expect] appendAttribute:@":"];
			[[store expect] endCurrentObject];
			[[store expect] beginPropertyTypes];
			[[store expect] appendType:@"type"];
			[[store expect] endCurrentObject];
			[[store expect] appendPropertyName:@"name"];
			[[store expect] endCurrentObject];
			[[parser expect] popState];
			// execute
			[state parseStream:tokens forParser:parser store:store];
			// verify
			^{ [store verify]; } should_not raise_exception();
			^{ [parser verify]; } should_not raise_exception();
		});
	});
});
 });

#pragma mark - Properties with descriptors

describe(@"", ^{
	it(@"ParseStreamForParserStoreShouldDetectDescriptorsIfFirstWordStartsWithDoubleUnderscore", ^{
	runWithState(^(ObjectiveCPropertyState *state) {
		runWithString(@"@property BOOL name __something", ^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginPropertyDefinition];
			[[store expect] beginPropertyTypes];
			[[store expect] appendType:@"BOOL"];
			[[store expect] endCurrentObject]; // types
			[[store expect] appendPropertyName:@"name"];
			[[store expect] beginPropertyDescriptors];
			[[store expect] appendDescriptor:@"__something"];
			[[store expect] endCurrentObject]; // descriptors
			[[store expect] endCurrentObject]; // property
			[[parser expect] popState];
			// execute
			[state parseStream:tokens forParser:parser store:store];
			// verify
			^{ [store verify]; } should_not raise_exception();
			^{ [parser verify]; } should_not raise_exception();
		});
	});
});
 });

describe(@"", ^{
	it(@"ParseStreamForParserStoreShouldDetectAllDescriptorsAfterDoubleUnderscore", ^{
	runWithState(^(ObjectiveCPropertyState *state) {
		runWithString(@"@property BOOL name __attribute__((deprecated))", ^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginPropertyDefinition];
			[[store expect] beginPropertyTypes];
			[[store expect] appendType:@"BOOL"];
			[[store expect] endCurrentObject]; // types
			[[store expect] appendPropertyName:@"name"];
			[[store expect] beginPropertyDescriptors];
			[[store expect] appendDescriptor:@"__attribute__"];
			[[store expect] appendDescriptor:@"("];
			[[store expect] appendDescriptor:@"("];
			[[store expect] appendDescriptor:@"deprecated"];
			[[store expect] appendDescriptor:@")"];
			[[store expect] appendDescriptor:@")"];
			[[store expect] endCurrentObject]; // descriptors
			[[store expect] endCurrentObject]; // property
			[[parser expect] popState];
			// execute
			[state parseStream:tokens forParser:parser store:store];
			// verify
			^{ [store verify]; } should_not raise_exception();
			^{ [parser verify]; } should_not raise_exception();
		});
	});
});
 });

describe(@"", ^{
	it(@"ParseStreamForParserStoreShouldDetectDescriptorsIfFirstWordIsUppercase", ^{
	runWithState(^(ObjectiveCPropertyState *state) {
		runWithString(@"@property BOOL name THIS_IS_DESCRIPTOR", ^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginPropertyDefinition];
			[[store expect] beginPropertyTypes];
			[[store expect] appendType:@"BOOL"];
			[[store expect] endCurrentObject]; // types
			[[store expect] appendPropertyName:@"name"];
			[[store expect] beginPropertyDescriptors];
			[[store expect] appendDescriptor:@"THIS_IS_DESCRIPTOR"];
			[[store expect] endCurrentObject]; // descriptors
			[[store expect] endCurrentObject]; // property
			[[parser expect] popState];
			// execute
			[state parseStream:tokens forParser:parser store:store];
			// verify
			^{ [store verify]; } should_not raise_exception();
			^{ [parser verify]; } should_not raise_exception();
		});
	});
});
 });

describe(@"", ^{
	it(@"ParseStreamForParserStoreShouldDetectAllDescriptorsAfterUppercaseWord", ^{
	runWithState(^(ObjectiveCPropertyState *state) {
		runWithString(@"@property BOOL name THIS_IS_DESCRIPTOR and another", ^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginPropertyDefinition];
			[[store expect] beginPropertyTypes];
			[[store expect] appendType:@"BOOL"];
			[[store expect] endCurrentObject]; // types
			[[store expect] appendPropertyName:@"name"];
			[[store expect] beginPropertyDescriptors];
			[[store expect] appendDescriptor:@"THIS_IS_DESCRIPTOR"];
			[[store expect] appendDescriptor:@"and"];
			[[store expect] appendDescriptor:@"another"];
			[[store expect] endCurrentObject]; // descriptors
			[[store expect] endCurrentObject]; // property
			[[parser expect] popState];
			// execute
			[state parseStream:tokens forParser:parser store:store];
			// verify
			^{ [store verify]; } should_not raise_exception();
			^{ [parser verify]; } should_not raise_exception();
		});
	});
});
 });

#pragma mark - Handling edge cases / limitations for supporting descriptors

describe(@"", ^{
	it(@"ParseStreamForParserStoreShouldAllowPropertyNameWithDoubleUnderscore", ^{
	runWithState(^(ObjectiveCPropertyState *state) {
		runWithString(@"@property NSString *__name", ^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginPropertyDefinition];
			[[store expect] beginPropertyTypes];
			[[store expect] appendType:@"NSString"];
			[[store expect] appendType:@"*"];
			[[store expect] endCurrentObject]; // types
			[[store expect] appendPropertyName:@"__name"];
			[[store expect] endCurrentObject]; // property
			[[parser expect] popState];
			// execute
			[state parseStream:tokens forParser:parser store:store];
			// verify
			^{ [store verify]; } should_not raise_exception();
			^{ [parser verify]; } should_not raise_exception();
		});
	});
});
 });

describe(@"", ^{
	it(@"ParseStreamForParserStoreShouldAllowPropertyNameWithUppercase", ^{
	runWithState(^(ObjectiveCPropertyState *state) {
		runWithString(@"@property NSString *NAME", ^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginPropertyDefinition];
			[[store expect] beginPropertyTypes];
			[[store expect] appendType:@"NSString"];
			[[store expect] appendType:@"*"];
			[[store expect] endCurrentObject]; // types
			[[store expect] appendPropertyName:@"NAME"];
			[[store expect] endCurrentObject]; // property
			[[parser expect] popState];
			// execute
			[state parseStream:tokens forParser:parser store:store];
			// verify
			^{ [store verify]; } should_not raise_exception();
			^{ [parser verify]; } should_not raise_exception();
		});
	});
});
 });

describe(@"", ^{
	it(@"ParseStreamForParserStoreShouldDetectPropertyNameWithDoubleUnderscoreFollowedByAttributes", ^{
	runWithState(^(ObjectiveCPropertyState *state) {
		runWithString(@"@property BOOL __name __something", ^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginPropertyDefinition];
			[[store expect] beginPropertyTypes];
			[[store expect] appendType:@"BOOL"];
			[[store expect] endCurrentObject]; // types
			[[store expect] appendPropertyName:@"__name"];
			[[store expect] beginPropertyDescriptors];
			[[store expect] appendDescriptor:@"__something"];
			[[store expect] endCurrentObject]; // descriptors
			[[store expect] endCurrentObject]; // property
			[[parser expect] popState];
			// execute
			[state parseStream:tokens forParser:parser store:store];
			// verify
			^{ [store verify]; } should_not raise_exception();
			^{ [parser verify]; } should_not raise_exception();
		});
		runWithString(@"@property NSString ***__name __something", ^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginPropertyDefinition];
			[[store expect] beginPropertyTypes];
			[[store expect] appendType:@"NSString"];
			[[store expect] appendType:@"*"];
			[[store expect] appendType:@"*"];
			[[store expect] appendType:@"*"];
			[[store expect] endCurrentObject]; // types
			[[store expect] appendPropertyName:@"__name"];
			[[store expect] beginPropertyDescriptors];
			[[store expect] appendDescriptor:@"__something"];
			[[store expect] endCurrentObject]; // descriptors
			[[store expect] endCurrentObject]; // property
			[[parser expect] popState];
			// execute
			[state parseStream:tokens forParser:parser store:store];
			// verify
			^{ [store verify]; } should_not raise_exception();
			^{ [parser verify]; } should_not raise_exception();
		});
	});
});
 });

describe(@"", ^{
	it(@"ParseStreamForParserStoreShouldDetectPropertyNameWithUppercaseFollowedByAttributes", ^{
	runWithState(^(ObjectiveCPropertyState *state) {
		runWithString(@"@property BOOL NAME SOMETHING", ^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginPropertyDefinition];
			[[store expect] beginPropertyTypes];
			[[store expect] appendType:@"BOOL"];
			[[store expect] endCurrentObject]; // types
			[[store expect] appendPropertyName:@"NAME"];
			[[store expect] beginPropertyDescriptors];
			[[store expect] appendDescriptor:@"SOMETHING"];
			[[store expect] endCurrentObject]; // descriptors
			[[store expect] endCurrentObject]; // property
			[[parser expect] popState];
			// execute
			[state parseStream:tokens forParser:parser store:store];
			// verify
			^{ [store verify]; } should_not raise_exception();
			^{ [parser verify]; } should_not raise_exception();
		});
		runWithString(@"@property NSString ***NAME SOMETHING", ^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginPropertyDefinition];
			[[store expect] beginPropertyTypes];
			[[store expect] appendType:@"NSString"];
			[[store expect] appendType:@"*"];
			[[store expect] appendType:@"*"];
			[[store expect] appendType:@"*"];
			[[store expect] endCurrentObject]; // types
			[[store expect] appendPropertyName:@"NAME"];
			[[store expect] beginPropertyDescriptors];
			[[store expect] appendDescriptor:@"SOMETHING"];
			[[store expect] endCurrentObject]; // descriptors
			[[store expect] endCurrentObject]; // property
			[[parser expect] popState];
			// execute
			[state parseStream:tokens forParser:parser store:store];
			// verify
			^{ [store verify]; } should_not raise_exception();
			^{ [parser verify]; } should_not raise_exception();
		});
	});
});
 });

#pragma mark - Multiple properties

describe(@"", ^{
	it(@"ParseStreamForParserStoreShouldDetectMultipleProperties", ^{
	runWithState(^(ObjectiveCPropertyState *state) {
		[self runWithFile:@"PropertyStateMultipleDefinitions.h" block:^(id parser, id tokens) {
			// setup
			id store = [OCMockObject mockForClass:[Store class]];
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginPropertyDefinition];
			[[store expect] beginPropertyAttributes];
			[[store expect] appendAttribute:@"nonatomic"];
			[[store expect] appendAttribute:@"strong"];
			[[store expect] endCurrentObject]; // attributes
			[[store expect] beginPropertyTypes];
			[[store expect] appendType:@"NSString"];
			[[store expect] appendType:@"*"];
			[[store expect] endCurrentObject]; // types
			[[store expect] appendPropertyName:@"property1"];
			[[store expect] endCurrentObject]; // property
			[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
			[[store expect] beginPropertyDefinition];
			[[store expect] beginPropertyAttributes];
			[[store expect] appendAttribute:@"nonatomic"];
			[[store expect] appendAttribute:@"copy"];
			[[store expect] appendAttribute:@"readonly"];
			[[store expect] endCurrentObject]; // attributes
			[[store expect] beginPropertyTypes];
			[[store expect] appendType:@"NSArray"];
			[[store expect] appendType:@"*"];
			[[store expect] endCurrentObject]; // types
			[[store expect] appendPropertyName:@"property2"];
			[[store expect] endCurrentObject]; // property
			// execute
			[state parseStream:tokens forParser:parser store:store];
			[state parseStream:tokens forParser:parser store:store];
			// verify
			^{ [store verify]; } should_not raise_exception();
		});
	});
});
 });
*/

SPEC_END
