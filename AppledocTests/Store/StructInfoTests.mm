//
//  StructInfoTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "TestCaseBase.hh"

static void runWithStructInfo(void(^handler)(StructInfo *info)) {
	StructInfo *info = [[StructInfo alloc] init];
	handler(info);
	[info release];
}

#pragma mark - 

SPEC_BEGIN(StructInfoTests)

describe(@"lazy accessors", ^{
	it(@"should initialize objects", ^{
		runWithStructInfo(^(StructInfo *info) {
			// execute & verify
			info.structItems should_not be_nil();
		});
	});
});

describe(@"constant registration", ^{
	it(@"should create new constant info and add it to struct items", ^{
		runWithStructInfo(^(StructInfo *info) {
			// setup
			info.objectRegistrar = [OCMockObject niceMockForClass:[Store class]];
			// execute
			[info beginConstant];
			// verify
			info.structItems.count should equal(1);
			info.structItems.lastObject should be_instance_of([ConstantInfo class]);
			[info.structItems.lastObject objectRegistrar] should equal(info.objectRegistrar);
		});
	});

	it(@"should push constant info to registration stack", ^{
		runWithStructInfo(^(StructInfo *info) {
			// setup
			id mock = [OCMockObject mockForClass:[Store class]];
			[[mock expect] pushRegistrationObject:[OCMArg checkWithBlock:^BOOL(id obj) {
				return [obj isKindOfClass:[ConstantInfo class]];
			}]];
			info.objectRegistrar = mock;
			// execute
			[info beginConstant];
			// verify
			^{ [mock verify]; } should_not raise_exception();
		});
	});
});

describe(@"object cancellation", ^{
	it(@"should remove constant info", ^{
		runWithStructInfo(^(StructInfo *info) {
			// setup
			[info beginConstant];
			id mock = [OCMockObject niceMockForClass:[Store class]];
			[[[mock stub] andReturn:info.structItems.lastObject] currentRegistrationObject];
			info.objectRegistrar = mock;
			// execute
			[info cancelCurrentObject];
			// verify
			info.structItems.count should equal(0);
		});
	});
});

SPEC_END
