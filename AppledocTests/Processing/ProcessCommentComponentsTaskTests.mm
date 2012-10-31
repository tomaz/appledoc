//
//  ProcessCommentComponentsTaskTests.m
//  appledoc
//
//  Created by Tomaz Kragelj on 8/11/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "ProcessCommentComponentsTask.h"
#import "TestCaseBase.hh"

static void runWithTask(void(^handler)(ProcessCommentComponentsTask *task, id comment)) {
	// ProcessCommentComponentsTask doesn't need store/settings/object/context, so we can get away with only giving it the comment.
	ProcessCommentComponentsTask *task = [[ProcessCommentComponentsTask alloc] init];
	id mock = [OCMockObject niceMockForClass:[CommentInfo class]];
	handler(task, mock);
	[task release];
}

static void setupCommentText(id comment, NSString *text) {
	[[[comment stub] andReturn:text] sourceString];
}

#pragma mark - 

@interface ProcessCommentComponentsTask (UnitTestingPrivateAPI)
- (NSInteger)processCommentForObject:(ObjectInfoBase *)object context:(ObjectInfoBase *)parent;
@end

#pragma mark -

TEST_BEGIN(ProcessCommentComponentsTaskTests)

describe(@"processing:", ^{
	describe(@"abstract and discussion:", ^{
		it(@"should detect for single paragraph", ^{
			runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
				// setup
				setupCommentText(comment, @"line");
				[[comment expect] setCommentAbstract:[OCMArg checkWithBlock:^BOOL(CommentComponentInfo *info) {
					return [info.componentSourceString isEqualToString:@"line"];
				}]];
				[[comment expect] setCommentDiscussion:[OCMArg checkWithBlock:^BOOL(NSMutableArray *array) {
					return (array.count == 0);
				}]];
				// execute
				[task processComment:comment];
				// verify
				^{ [comment verify]; } should_not raise_exception();
			});
		});
		
		it(@"should detect for multiple paragraphs", ^{
			runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
				// setup
				setupCommentText(comment, @"first\n\nsecond");
				[[comment expect] setCommentAbstract:[OCMArg checkWithBlock:^BOOL(CommentComponentInfo *info) {
					return [info.componentSourceString isEqualToString:@"first"];
				}]];
				[[comment expect] setCommentDiscussion:[OCMArg checkWithBlock:^BOOL(NSMutableArray *array) {
					if (array.count != 1) return NO;
					return [[array[0] componentSourceString] isEqualToString:@"second"];
				}]];
				// execute
				[task processComment:comment];
				// verify
				^{ [comment verify]; } should_not raise_exception();
			});
		});
		
		it(@"should detect @warning block", ^{
			runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
				// setup
				setupCommentText(comment, @"first\n\n@warning text1\n\n@warning text2");
				[[comment expect] setCommentAbstract:[OCMArg checkWithBlock:^BOOL(CommentComponentInfo *info) {
					return [info.componentSourceString isEqualToString:@"first"];
				}]];
				[[comment expect] setCommentDiscussion:[OCMArg checkWithBlock:^BOOL(NSMutableArray *array) {
					if (array.count != 2) return NO;
					if (![[array[0] componentSourceString] isEqualToString:@"@warning text1"]) return NO;
					if (![[array[1] componentSourceString] isEqualToString:@"@warning text2"]) return NO;
					return YES;
				}]];
				// execute
				[task processComment:comment];
				// verify
				^{ [comment verify]; } should_not raise_exception();
			});
		});
	});
});

TEST_END