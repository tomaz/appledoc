//
//  AttributesInfoTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/18/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "TestCaseBase.hh"

static void runWithPropertyAttributesInfo(void(^handler)(AttributesInfo *info)) {
	AttributesInfo *info = [[AttributesInfo alloc] init];
	handler(info);
	[info release];
}

#pragma mark - 

TEST_BEGIN(AttributesInfoTests)

describe(@"lazy accessors", ^{
	it(@"should initialize objects", ^{
		runWithPropertyAttributesInfo(^(AttributesInfo *info) {
			// execute & verify
			info.attributeItems should_not be_nil();
		});
	});
});

describe(@"attribute value", ^{
	it(@"should return value based on = token", ^{
		runWithPropertyAttributesInfo(^(AttributesInfo *info) {
			// setup
			info.attributeItems = [NSMutableArray arrayWithObjects:@"prefix", @"attribute", @"=", @"value", @"suffix", nil];
			// execute & verify
			[info valueForAttribute:@"attribute"] should equal(@"value");			
		});
	});
	
	it(@"should return correct value if multiple attributes are present", ^{
		runWithPropertyAttributesInfo(^(AttributesInfo *info) {
			// setup
			info.attributeItems = [NSMutableArray arrayWithObjects:@"prefix", @"attribute1", @"=", @"value1", @"attribute2", @"=", @"value2", @"suffix", nil];
			// execute & verify
			[info valueForAttribute:@"attribute1"] should equal(@"value1");
			[info valueForAttribute:@"attribute2"] should equal(@"value2");
		});
	});
	
	it(@"should return first attribute value if multiple attributes with the same name are present", ^{
		runWithPropertyAttributesInfo(^(AttributesInfo *info) {
			// setup
			info.attributeItems = [NSMutableArray arrayWithObjects:@"prefix", @"attribute", @"=", @"value1", @"attribute", @"=", @"value2", @"suffix", nil];
			// execute & verify
			[info valueForAttribute:@"attribute"] should equal(@"value1");
		});
	});
	
	it(@"should return nil if attribute name is not present", ^{
		runWithPropertyAttributesInfo(^(AttributesInfo *info) {
			// setup
			info.attributeItems = [NSMutableArray arrayWithObjects:@"prefix", @"attribute", @"=", @"value", @"suffix", nil];
			// execute & verify
			[info valueForAttribute:@"prefix"] should be_nil();
			[info valueForAttribute:@"suffix"] should be_nil();
			[info valueForAttribute:@"attr"] should be_nil();
			[info valueForAttribute:@"attribute1"] should be_nil();
			[info valueForAttribute:@"="] should be_nil();
			[info valueForAttribute:@"value"] should be_nil();
		});
	});
});

describe(@"appending attributes", ^{
	it(@"should add all strings to type items array", ^{
		runWithPropertyAttributesInfo(^(AttributesInfo *info) {			
			// execute
			[info appendAttribute:@"type1"];
			[info appendAttribute:@"type2"];
			// verify
			info.attributeItems.count should equal(2);
			[info.attributeItems objectAtIndex:0] should equal(@"type1");
			[info.attributeItems objectAtIndex:1] should equal(@"type2");
		});
	});
});

TEST_END