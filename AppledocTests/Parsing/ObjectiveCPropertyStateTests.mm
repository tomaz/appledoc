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

TEST_BEGIN(ObjectiveCPropertyStateTests)

#pragma mark - Properties without attributes

describe(@"simple properties", ^{
	it(@"should detect single type", ^{
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
				ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
				// execute
				[state parseWithData:data];
				// verify
				^{ [store verify]; } should_not raise_exception();
				^{ [parser verify]; } should_not raise_exception();
			});
		});
	});

	it(@"should detect mutliple types", ^{
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

describe(@"properties with attributes", ^{
	it(@"should detect single attribute", ^{
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
				ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
				// execute
				[state parseWithData:data];
				// verify
				^{ [store verify]; } should_not raise_exception();
				^{ [parser verify]; } should_not raise_exception();
			});
		});
	});

	it(@"should detect multiple attributes", ^{
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
				ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
				// execute
				[state parseWithData:data];
				// verify
				^{ [store verify]; } should_not raise_exception();
				^{ [parser verify]; } should_not raise_exception();
			});
		});
	});

	it(@"should detect multiple attributes and types", ^{
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
				ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
				// execute
				[state parseWithData:data];
				// verify
				^{ [store verify]; } should_not raise_exception();
				^{ [parser verify]; } should_not raise_exception();
			});
		});
	});

	it(@"should detect custom getter and setter", ^{
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

describe(@"properties with descriptors", ^{	
	describe(@"if descriptors start with double underscore word", ^{
		it(@"should detect descriptor after property name", ^{
			runWithState(^(ObjectiveCPropertyState *state) {
				runWithString(@"@property BOOL name __something;", ^(id parser, id tokens) {
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
					ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
					// execute
					[state parseWithData:data];
					// verify
					^{ [store verify]; } should_not raise_exception();
					^{ [parser verify]; } should_not raise_exception();
				});
			});
		});

		it(@"should detect all descriptor tokens after property name", ^{
			runWithState(^(ObjectiveCPropertyState *state) {
				runWithString(@"@property BOOL name __attribute__((deprecated));", ^(id parser, id tokens) {
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

	describe(@"if descriptors start with all uppercase word", ^{
		it(@"should detect descriptor after property name", ^{
			runWithState(^(ObjectiveCPropertyState *state) {
				runWithString(@"@property BOOL name THIS_IS_DESCRIPTOR;", ^(id parser, id tokens) {
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
					ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
					// execute
					[state parseWithData:data];
					// verify
					^{ [store verify]; } should_not raise_exception();
					^{ [parser verify]; } should_not raise_exception();
				});
			});
		});

		it(@"should detect all descriptor tokens after property name", ^{
			runWithState(^(ObjectiveCPropertyState *state) {
				runWithString(@"@property BOOL name THIS_IS_DESCRIPTOR and another;", ^(id parser, id tokens) {
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

	describe(@"edge cases / limitations for supporting descriptors", ^{
		describe(@"if property name has the form of descriptor but not followed by one", ^{
			it(@"should allow property name with double underscore prefix", ^{
				runWithState(^(ObjectiveCPropertyState *state) {
					runWithString(@"@property NSString *__name;", ^(id parser, id tokens) {
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
						ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
						// execute
						[state parseWithData:data];
						// verify
						^{ [store verify]; } should_not raise_exception();
						^{ [parser verify]; } should_not raise_exception();
					});
				});
			});

			it(@"should allow property name with uppercase letters", ^{
				runWithState(^(ObjectiveCPropertyState *state) {
					runWithString(@"@property NSString *NAME;", ^(id parser, id tokens) {
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
		
		describe(@"if property name is prefixed with double underscore followed by descriptors", ^{
			it(@"should detect if followed by double underscore descriptor", ^{
				runWithState(^(ObjectiveCPropertyState *state) {
					runWithString(@"@property BOOL __name __something;", ^(id parser, id tokens) {
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
						ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
						// execute
						[state parseWithData:data];
						// verify
						^{ [store verify]; } should_not raise_exception();
						^{ [parser verify]; } should_not raise_exception();
					});
				});
			});
			
			it(@"should detect if types end with one or more asterisks", ^{
				runWithState(^(ObjectiveCPropertyState *state) {
					runWithString(@"@property NSString ***__name __something;", ^(id parser, id tokens) {
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

		describe(@"if property name is all uppercase letters followed by descriptors", ^{
			it(@"should allow if followed by all uppercase descriptor", ^{
				runWithState(^(ObjectiveCPropertyState *state) {
					runWithString(@"@property BOOL NAME SOMETHING;", ^(id parser, id tokens) {
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
						ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
						// execute
						[state parseWithData:data];
						// verify
						^{ [store verify]; } should_not raise_exception();
						^{ [parser verify]; } should_not raise_exception();
					});
				});
			});
			
			it(@"should detect if types end with one or more asterisks", ^{
			   runWithState(^(ObjectiveCPropertyState *state) {
					runWithString(@"@property NSString ***NAME SOMETHING;", ^(id parser, id tokens) {
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
	});
});

describe(@"multiple successive properties", ^{
	it(@"should detect successive properties if invoked multiple times", ^{
		runWithState(^(ObjectiveCPropertyState *state) {
			runWithFile(@"PropertyStateMultipleDefinitions.h", ^(id parser, id tokens) {
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
				ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
				// execute
				[state parseWithData:data];
				[state parseWithData:data];
				// verify
				^{ [store verify]; } should_not raise_exception();
			});
		});
	});
});

describe(@"fail cases", ^{
	it(@"should cancel if property semicolon is missing", ^{
		runWithState(^(ObjectiveCPropertyState *state) {
			runWithString(@"@property type name", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
				[[store expect] beginPropertyDefinition];
				[[store expect] beginPropertyTypes];
				[[store expect] appendType:@"type"];
				[[store expect] appendType:@"name"];
				[[store expect] cancelCurrentObject];
				[[store expect] cancelCurrentObject];
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

	it(@"should cancel if attributes closing parenthesis is missing", ^{
		runWithState(^(ObjectiveCPropertyState *state) {
			runWithString(@"@property (attribute name;", ^(id parser, id tokens) {
				// setup
				id store = [OCMockObject mockForClass:[Store class]];
				[[store expect] setCurrentSourceInfo:OCMOCK_ANY];
				[[store expect] beginPropertyDefinition];
				[[store expect] beginPropertyAttributes];
				[[store expect] appendAttribute:@"attribute"];
				[[store expect] appendAttribute:@"name"];
				[[store expect] cancelCurrentObject];
				[[store expect] cancelCurrentObject];
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

TEST_END
