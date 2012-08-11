//
//  CommentInfoTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 8/22/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "TestCaseBase.hh"

static void runWithCommentInfo(void(^handler)(CommentInfo *info)) {
	CommentInfo *info = [[CommentInfo alloc] init];
	handler(info);
	[info release];
}

#pragma mark - 

TEST_BEGIN(CommentInfoTests)

describe(@"lazy accessors:", ^{
	it(@"should initialize objects", ^{
		runWithCommentInfo(^(CommentInfo *info) {
			// execute & verify
			info.commentDiscussion should_not be_nil();
		});
	});
});

TEST_END
