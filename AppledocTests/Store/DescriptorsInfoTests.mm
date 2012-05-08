//
//  DescriptorsInfoTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/18/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "TestCaseBase.hh"

static void runWithPropertyDescriptorsInfo(void(^handler)(DescriptorsInfo *info)) {
	DescriptorsInfo *info = [[DescriptorsInfo alloc] init];
	handler(info);
	[info release];
}

#pragma mark - 

TEST_BEGIN(DescriptorsInfoTests)

describe(@"lazy accessors:", ^{
	it(@"should initialize objects", ^{
		runWithPropertyDescriptorsInfo(^(DescriptorsInfo *info) {			
			// execute & verify
			info.descriptorItems should_not be_nil();
		});
	});
});

describe(@"appending descriptors:", ^{
	it(@"should add all strings to desciptor items array", ^{
		runWithPropertyDescriptorsInfo(^(DescriptorsInfo *info) {
			// execute
			[info appendDescriptor:@"type1"];
			[info appendDescriptor:@"type2"];
			// verify
			info.descriptorItems.count should equal(2);
			[info.descriptorItems objectAtIndex:0] should equal(@"type1");
			[info.descriptorItems objectAtIndex:1] should equal(@"type2");
		});
	});
});

TEST_END