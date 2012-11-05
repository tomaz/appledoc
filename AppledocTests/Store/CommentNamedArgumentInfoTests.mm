//
//  CommentNamedSectionInfoTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 11/1/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "TestCaseBase.hh"

static void runWithCommentNamedSectionInfo(void(^handler)(CommentNamedSectionInfo *info)) {
	CommentNamedSectionInfo *info = [[CommentNamedSectionInfo alloc] init];
	handler(info);
	[info release];
}

#pragma mark - 

TEST_BEGIN(CommentNamedSectionInfoTests)

describe(@"lazy accessors:", ^{
	it(@"should initialize objects", ^{
		runWithCommentNamedSectionInfo(^(CommentNamedSectionInfo *info) {
			// execute & verify
			info.argumentComponents should_not be_nil();
		});
	});
});

TEST_END
