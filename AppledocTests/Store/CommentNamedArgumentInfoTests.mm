//
//  CommentNamedArgumentInfoTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 11/1/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "TestCaseBase.hh"

static void runWithCommentNamedArgumentInfo(void(^handler)(CommentNamedArgumentInfo *info)) {
	CommentNamedArgumentInfo *info = [[CommentNamedArgumentInfo alloc] init];
	handler(info);
	[info release];
}

#pragma mark - 

TEST_BEGIN(CommentNamedArgumentInfoTests)

describe(@"lazy accessors:", ^{
	it(@"should initialize objects", ^{
		runWithCommentNamedArgumentInfo(^(CommentNamedArgumentInfo *info) {
			// execute & verify
			info.argumentComponents should_not be_nil();
		});
	});
});

TEST_END
