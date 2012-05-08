//
//  ConstantInfoTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "TestCaseBase.hh"

static void runWithConstantInfo(void(^handler)(ConstantInfo *info)) {
	ConstantInfo *info = [[ConstantInfo alloc] init];
	handler(info);
	[info release];
}

SPEC_BEGIN(ConstantInfoTests)

describe(@"lazy accessors", ^{
	it(@"should initialize objects", ^{
		runWithConstantInfo(^(ConstantInfo *info) {
			// execute & verify
			info.constantTypes should be_instance_of([TypeInfo class]);
			info.constantDescriptors should be_instance_of([DescriptorsInfo class]);
		});
	});
});

describe(@"constant types registration", ^{
	it(@"should change current registration object to constant types info", ^{
		runWithConstantInfo(^(ConstantInfo *info) {
			// setup
			id mock = [OCMockObject mockForClass:[Store class]];
			[[mock expect] pushRegistrationObject:info.constantTypes];
			info.objectRegistrar = mock;
			// execute
			[info beginConstantTypes];
			// verify
			^{ [mock verify]; } should_not raise_exception();
		});
	});
});

describe(@"constant name registration", ^{
	it(@"should assign given string", ^{
		runWithConstantInfo(^(ConstantInfo *info) {
			// execute
			[info appendConstantName:@"value"];
			// verify
			info.constantName should equal(@"value");
		});
	});
	
	it(@"should use last value if sent multiple times", ^{
		runWithConstantInfo(^(ConstantInfo *info) {
			// execute
			[info appendConstantName:@"value1"];
			[info appendConstantName:@"value2"];
			// verify
			info.constantName should equal(@"value2");
		});
	});
});

describe(@"constant descriptors registration", ^{
	it(@"should push descriptors info to registration stack", ^{
		runWithConstantInfo(^(ConstantInfo *info) {
			// setup
			id mock = [OCMockObject mockForClass:[Store class]];
			[[mock expect] pushRegistrationObject:info.constantDescriptors];
			info.objectRegistrar = mock;
			// execute
			[info beginConstantDescriptors];
			// verify
			^{ [mock verify]; } should_not raise_exception();
		});
	});
});

SPEC_END
