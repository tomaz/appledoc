//
//  EnumInfoTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "TestCaseBase.hh"

static void runWithEnumInfo(void(^handler)(EnumInfo *info)) {
	EnumInfo *info = [[EnumInfo alloc] init];
	handler(info);
	[info release];
}

#pragma mark - 

SPEC_BEGIN(EnumInfoTests)

describe(@"lazy accessors", ^{
	it(@"should initialize objects", ^{
		runWithEnumInfo(^(EnumInfo *info) {
			// execute & verify
			info.enumItems should_not be_nil();
		});
	});
});

describe(@"enumeration item registration", ^{
	it(@"should add all items to items array", ^{
		runWithEnumInfo(^(EnumInfo *info) {
			// execute
			[info appendEnumerationItem:@"item1"];
			[info appendEnumerationItem:@"item2"];
			// verify
			info.enumItems.count should equal(2);
			[info.enumItems objectAtIndex:0] should be_instance_of([EnumItemInfo class]);
			[info.enumItems objectAtIndex:1] should be_instance_of([EnumItemInfo class]);
			[[info.enumItems objectAtIndex:0] itemName] should equal(@"item1");
			[[info.enumItems objectAtIndex:1] itemName] should equal(@"item2");
		});
	});
});

describe(@"enumeration value registration", ^{
	it(@"should set value if single item is registered", ^{
		runWithEnumInfo(^(EnumInfo *info) {
			// setup
			[info appendEnumerationItem:@"item"];
			// execute
			[info appendEnumerationValue:@"value"];
			// verify
			info.enumItems.count should equal(1);
			[[info.enumItems objectAtIndex:0] itemName] should equal(@"item");
			[[info.enumItems objectAtIndex:0] itemValue] should equal(@"value");
		});
	});
	
	it(@"should set value to last item is multiple items are registered", ^{
		runWithEnumInfo(^(EnumInfo *info) {
			// setup
			[info appendEnumerationItem:@"item1"];
			[info appendEnumerationItem:@"item2"];
			// execute
			[info appendEnumerationValue:@"value"];
			// verify
			info.enumItems.count should equal(2);
			[[info.enumItems objectAtIndex:0] itemName] should equal(@"item1");
			[[info.enumItems objectAtIndex:0] itemValue] should be_nil();
			[[info.enumItems objectAtIndex:1] itemName] should equal(@"item2");
			[[info.enumItems objectAtIndex:1] itemValue] should equal(@"value");
		});
	});
	
	it(@"should ignore if no item is registered", ^{
		runWithEnumInfo(^(EnumInfo *info) {
			// execute
			[info appendEnumerationValue:@"value"];
			// verify - we log a warning in such case, but we don't test it here!
			info.enumItems.count should equal(0);
		});
	});
});

SPEC_END
