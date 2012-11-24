//
//  SplitCommentToSectionsTaskTests.m
//  appledoc
//
//  Created by Tomaz Kragelj on 8/11/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "SplitCommentToSectionsTask.h"
#import "TestCaseBase.hh"

#define GBSections [comment sourceSections]

#pragma mark -

static void runWithMockTask(void(^handler)(SplitCommentToSectionsTask *task, id comment)) {
	// SplitCommentToSectionsTask doesn't need store/settings/object/context, so we can get away with only giving it the comment.
	SplitCommentToSectionsTask *task = [[SplitCommentToSectionsTask alloc] init];
	id mock = mock([CommentInfo class]);
	handler(task, mock);
	[task release];
}

static void runWithTask(void(^handler)(SplitCommentToSectionsTask *task, id comment)) {
	// SplitCommentToSectionsTask doesn't need store/settings/object/context, so we can get away with only giving it the comment.
	SplitCommentToSectionsTask *task = [[SplitCommentToSectionsTask alloc] init];
	CommentInfo *comment = [[CommentInfo alloc] init];
	handler(task, comment);
	[task release];
}

static void setupComment(id comment, NSString *text) {
	if ([comment isKindOfClass:[CommentInfo class]])
		[comment setSourceString:text];
	else
		[given([comment sourceString]) willReturn:text];
}

#pragma mark -

@interface SplitCommentToSectionsTask (UnitTestingPrivateAPI)
- (NSInteger)processCommentForObject:(ObjectInfoBase *)object context:(ObjectInfoBase *)parent;
@end

#pragma mark -

TEST_BEGIN(SplitCommentToSectionsTaskTests)

describe(@"abstract:", ^{
	it(@"should convert single line to abstract", ^{
		runWithTask(^(SplitCommentToSectionsTask *task, id comment) {
			// setup
			setupComment(comment, @"line");
			// execute
			[task processComment:comment];
			// verify
			GBSections.count should equal(1);
			GBSections[0] should equal(@"line");
		});
	});
	
	it(@"should convert single paragraph composed of multiple lines to abstract", ^{
		runWithTask(^(SplitCommentToSectionsTask *task, id comment) {
			// setup
			setupComment(comment, @"line one\nline two\nline three");
			// execute
			[task processComment:comment];
			// verify
			GBSections.count should equal(1);
			GBSections[0] should equal(@"line one\nline two\nline three");
		});
	});
});

TEST_END