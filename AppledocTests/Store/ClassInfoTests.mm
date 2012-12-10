//
//  ClassInfoTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 10/11/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "TestCaseBase.hh"

static void runWithClassInfo(void(^handler)(ClassInfo *info)) {
	ClassInfo *info = [[ClassInfo alloc] initWithRegistrar:nil];
	handler(info);
	[info release];
}

#pragma mark - 

TEST_BEGIN(ClassInfoTests)

describe(@"lazy properties:", ^{
	it(@"should initialize objects on first access", ^{
		runWithClassInfo(^(ClassInfo *info) {
			// execute & verify
			info.classSuperClass should be_instance_of([ObjectLinkInfo class]);
		});
	});
});

TEST_END
