//
//  CommentNamedSectionInfoTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 11/1/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "TestCaseBase.hh"

static void runWithCommentNamedSectionInfo(void(^handler)(CommentSectionInfo *info)) {
	CommentSectionInfo *info = [[CommentSectionInfo alloc] init];
	handler(info);
	[info release];
}

#pragma mark - 

TEST_BEGIN(CommentSectionInfoTests)

describe(@"lazy accessors:", ^{
	it(@"should initialize objects", ^{
		runWithCommentNamedSectionInfo(^(CommentSectionInfo *info) {
			// execute & verify
			info.sectionComponents should_not be_nil();
		});
	});
});

TEST_END
