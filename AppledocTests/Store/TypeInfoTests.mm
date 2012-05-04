//
//  TypeInfoTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/18/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "TestCaseBase.hh"
#import "TestCaseBase.h"

static void runWithTypeInfo(void(^handler)(TypeInfo *info)) {
	TypeInfo *info = [[TypeInfo alloc] init];
	handler(info);
	[info release];
}

#pragma mark - 

SPEC_BEGIN(TypeInfoTests)

describe(@"lazy accessors", ^{
	it(@"should initialize objects", ^{
		runWithTypeInfo(^(TypeInfo *info) {
			info.typeItems should_not be_nil();
		});
	});
});

describe(@"append type", ^{
	it(@"should add all strings to type items array", ^{
		runWithTypeInfo(^(TypeInfo *info) {
			// execute
			[info appendType:@"type1"];
			[info appendType:@"type2"];
			// verify
			info.typeItems.count should equal(2);
			[info.typeItems objectAtIndex:0] should equal(@"type1");
			[info.typeItems objectAtIndex:1] should equal(@"type2");
		});
	});
});

SPEC_END
