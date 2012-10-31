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
	describe(@"abstract:", ^{
		it(@"should convert single line to abstract", ^{
			runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
				// setup
				setupCommentText(comment, @"line");
				[[comment expect] setCommentAbstract:[OCMArg checkWithBlock:^BOOL(CommentComponentInfo *info) {
					return [info.sourceString isEqualToString:@"line"];
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
		
		it(@"should convert single paragraph composed of multiple lines to abstract", ^{
			runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
				// setup
				setupCommentText(comment, @"line one\nline two\nline three");
				[[comment expect] setCommentAbstract:[OCMArg checkWithBlock:^BOOL(CommentComponentInfo *info) {
					return [info.sourceString isEqualToString:@"line one\nline two\nline three"];
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
	});
		
	describe(@"discussion:", ^{
		it(@"should convert second paragraph to discussion", ^{
			runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
				// setup
				setupCommentText(comment, @"first\n\nsecond");
				[[comment expect] setCommentAbstract:[OCMArg checkWithBlock:^BOOL(CommentComponentInfo *info) {
					return [info.sourceString isEqualToString:@"first"];
				}]];
				[[comment expect] setCommentDiscussion:[OCMArg checkWithBlock:^BOOL(NSMutableArray *array) {
					if (array.count != 1) return NO;
					return [[array[0] sourceString] isEqualToString:@"second"];
				}]];
				// execute
				[task processComment:comment];
				// verify
				^{ [comment verify]; } should_not raise_exception();
			});
		});

		it(@"should convert second and subsequent paragraphs to discussion", ^{
			runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
				// setup
				setupCommentText(comment, @"first\n\nsecond\n\nthird");
				[[comment expect] setCommentAbstract:[OCMArg checkWithBlock:^BOOL(CommentComponentInfo *info) {
					return [info.sourceString isEqualToString:@"first"];
				}]];
				[[comment expect] setCommentDiscussion:[OCMArg checkWithBlock:^BOOL(NSMutableArray *array) {
					if (array.count != 2) return NO;
					return [[array[0] sourceString] isEqualToString:@"second"];
					return [[array[1] sourceString] isEqualToString:@"third"];
				}]];
				// execute
				[task processComment:comment];
				// verify
				^{ [comment verify]; } should_not raise_exception();
			});
		});

		it(@"should handle multiple paragraphs with mutliple lines", ^{
			runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
				// setup
				setupCommentText(comment, @"first\n\nline one\nline two\nline three\n\nthird paragraph\nand line two");
				[[comment expect] setCommentAbstract:[OCMArg checkWithBlock:^BOOL(CommentComponentInfo *info) {
					return [info.sourceString isEqualToString:@"first"];
				}]];
				[[comment expect] setCommentDiscussion:[OCMArg checkWithBlock:^BOOL(NSMutableArray *array) {
					if (array.count != 2) return NO;
					return [[array[0] sourceString] isEqualToString:@"line one\nline two\nline three"];
					return [[array[1] sourceString] isEqualToString:@"third paragraph\nand line two"];
				}]];
				// execute
				[task processComment:comment];
				// verify
				^{ [comment verify]; } should_not raise_exception();
			});
		});
	});
		
	describe(@"@warning:", ^{
		describe(@"as part of abstract:", ^{
			it(@"should take as part of abstract if not delimited by empty line", ^{
				runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
					// setup
					setupCommentText(comment, @"abstract\n@warning text");
					[[comment expect] setCommentAbstract:[OCMArg checkWithBlock:^BOOL(CommentComponentInfo *info) {
						return [info.sourceString isEqualToString:@"abstract\n@warning text"];
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
			
			it(@"should take as part of abstract and take next paragraph as discussion", ^{
				runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
					// setup
					setupCommentText(comment, @"abstract\n@warning text\n\nparagraph");
					[[comment expect] setCommentAbstract:[OCMArg checkWithBlock:^BOOL(CommentComponentInfo *info) {
						return [info.sourceString isEqualToString:@"abstract\n@warning text"];
					}]];
					[[comment expect] setCommentDiscussion:[OCMArg checkWithBlock:^BOOL(NSMutableArray *array) {
						if (array.count != 1) return NO;
						if (![[array[0] sourceString] isEqualToString:@"paragraph"]) return NO;
						return YES;
					}]];
					// execute
					[task processComment:comment];
					// verify
					^{ [comment verify]; } should_not raise_exception();
				});
			});
		});
		
		describe(@"as part of discussion:", ^{
			it(@"should take as part of discussion if found as first paragraph after abstract", ^{
				runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
					// setup
					setupCommentText(comment, @"abstract\n\n@warning text");
					[[comment expect] setCommentAbstract:[OCMArg checkWithBlock:^BOOL(CommentComponentInfo *info) {
						return [info.sourceString isEqualToString:@"abstract"];
					}]];
					[[comment expect] setCommentDiscussion:[OCMArg checkWithBlock:^BOOL(NSMutableArray *array) {
						if (array.count != 1) return NO;
						if (![[array[0] sourceString] isEqualToString:@"@warning text"]) return NO;
						return YES;
					}]];
					// execute
					[task processComment:comment];
					// verify
					^{ [comment verify]; } should_not raise_exception();
				});
			});
			
			it(@"should start new paragraph if delimited by empty line", ^{
				runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
					// setup
					setupCommentText(comment, @"abstract\n\nparagraph\n\n@warning text");
					[[comment expect] setCommentAbstract:[OCMArg checkWithBlock:^BOOL(CommentComponentInfo *info) {
						return [info.sourceString isEqualToString:@"abstract"];
					}]];
					[[comment expect] setCommentDiscussion:[OCMArg checkWithBlock:^BOOL(NSMutableArray *array) {
						if (array.count != 2) return NO;
						if (![[array[0] sourceString] isEqualToString:@"paragraph"]) return NO;
						if (![[array[1] sourceString] isEqualToString:@"@warning text"]) return NO;
						return YES;
					}]];
					// execute
					[task processComment:comment];
					// verify
					^{ [comment verify]; } should_not raise_exception();
				});
			});
			
			it(@"should start new paragraph after next empty line", ^{
				runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
					// setup
					setupCommentText(comment, @"abstract\n\nparagraph\n\n@warning text\n\nnext paragraph");
					[[comment expect] setCommentAbstract:[OCMArg checkWithBlock:^BOOL(CommentComponentInfo *info) {
						return [info.sourceString isEqualToString:@"abstract"];
					}]];
					[[comment expect] setCommentDiscussion:[OCMArg checkWithBlock:^BOOL(NSMutableArray *array) {
						if (array.count != 3) return NO;
						if (![[array[0] sourceString] isEqualToString:@"paragraph"]) return NO;
						if (![[array[1] sourceString] isEqualToString:@"@warning text"]) return NO;
						if (![[array[2] sourceString] isEqualToString:@"next paragraph"]) return NO;
						return YES;
					}]];
					// execute
					[task processComment:comment];
					// verify
					^{ [comment verify]; } should_not raise_exception();
				});
			});
			
			it(@"should start new paragraph with next @warning directive", ^{
				runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
					// setup
					setupCommentText(comment, @"abstract\n\n@warning first\n\n@warning second");
					[[comment expect] setCommentAbstract:[OCMArg checkWithBlock:^BOOL(CommentComponentInfo *info) {
						return [info.sourceString isEqualToString:@"abstract"];
					}]];
					[[comment expect] setCommentDiscussion:[OCMArg checkWithBlock:^BOOL(NSMutableArray *array) {
						if (array.count != 2) return NO;
						if (![[array[0] sourceString] isEqualToString:@"@warning first"]) return NO;
						if (![[array[1] sourceString] isEqualToString:@"@warning second"]) return NO;
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
	
	describe(@"@bug:", ^{
		describe(@"as part of abstract:", ^{
			it(@"should take as part of abstract if not delimited by empty line", ^{
				runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
					// setup
					setupCommentText(comment, @"abstract\n@bug text");
					[[comment expect] setCommentAbstract:[OCMArg checkWithBlock:^BOOL(CommentComponentInfo *info) {
						return [info.sourceString isEqualToString:@"abstract\n@bug text"];
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
			
			it(@"should take as part of abstract and take next paragraph as discussion", ^{
				runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
					// setup
					setupCommentText(comment, @"abstract\n@bug text\n\nparagraph");
					[[comment expect] setCommentAbstract:[OCMArg checkWithBlock:^BOOL(CommentComponentInfo *info) {
						return [info.sourceString isEqualToString:@"abstract\n@bug text"];
					}]];
					[[comment expect] setCommentDiscussion:[OCMArg checkWithBlock:^BOOL(NSMutableArray *array) {
						if (array.count != 1) return NO;
						if (![[array[0] sourceString] isEqualToString:@"paragraph"]) return NO;
						return YES;
					}]];
					// execute
					[task processComment:comment];
					// verify
					^{ [comment verify]; } should_not raise_exception();
				});
			});
		});
		
		describe(@"as part of discussion:", ^{
			it(@"should take as part of discussion if found as first paragraph after abstract", ^{
				runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
					// setup
					setupCommentText(comment, @"abstract\n\n@bug text");
					[[comment expect] setCommentAbstract:[OCMArg checkWithBlock:^BOOL(CommentComponentInfo *info) {
						return [info.sourceString isEqualToString:@"abstract"];
					}]];
					[[comment expect] setCommentDiscussion:[OCMArg checkWithBlock:^BOOL(NSMutableArray *array) {
						if (array.count != 1) return NO;
						if (![[array[0] sourceString] isEqualToString:@"@bug text"]) return NO;
						return YES;
					}]];
					// execute
					[task processComment:comment];
					// verify
					^{ [comment verify]; } should_not raise_exception();
				});
			});
			
			it(@"should start new paragraph if delimited by empty line", ^{
				runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
					// setup
					setupCommentText(comment, @"abstract\n\nparagraph\n\n@bug text");
					[[comment expect] setCommentAbstract:[OCMArg checkWithBlock:^BOOL(CommentComponentInfo *info) {
						return [info.sourceString isEqualToString:@"abstract"];
					}]];
					[[comment expect] setCommentDiscussion:[OCMArg checkWithBlock:^BOOL(NSMutableArray *array) {
						if (array.count != 2) return NO;
						if (![[array[0] sourceString] isEqualToString:@"paragraph"]) return NO;
						if (![[array[1] sourceString] isEqualToString:@"@bug text"]) return NO;
						return YES;
					}]];
					// execute
					[task processComment:comment];
					// verify
					^{ [comment verify]; } should_not raise_exception();
				});
			});
			
			it(@"should start new paragraph after next empty line", ^{
				runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
					// setup
					setupCommentText(comment, @"abstract\n\nparagraph\n\n@bug text\n\nnext paragraph");
					[[comment expect] setCommentAbstract:[OCMArg checkWithBlock:^BOOL(CommentComponentInfo *info) {
						return [info.sourceString isEqualToString:@"abstract"];
					}]];
					[[comment expect] setCommentDiscussion:[OCMArg checkWithBlock:^BOOL(NSMutableArray *array) {
						if (array.count != 3) return NO;
						if (![[array[0] sourceString] isEqualToString:@"paragraph"]) return NO;
						if (![[array[1] sourceString] isEqualToString:@"@bug text"]) return NO;
						if (![[array[2] sourceString] isEqualToString:@"next paragraph"]) return NO;
						return YES;
					}]];
					// execute
					[task processComment:comment];
					// verify
					^{ [comment verify]; } should_not raise_exception();
				});
			});
			
			it(@"should start new paragraph with next @bug directive", ^{
				runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
					// setup
					setupCommentText(comment, @"abstract\n\n@bug first\n\n@bug second");
					[[comment expect] setCommentAbstract:[OCMArg checkWithBlock:^BOOL(CommentComponentInfo *info) {
						return [info.sourceString isEqualToString:@"abstract"];
					}]];
					[[comment expect] setCommentDiscussion:[OCMArg checkWithBlock:^BOOL(NSMutableArray *array) {
						if (array.count != 2) return NO;
						if (![[array[0] sourceString] isEqualToString:@"@bug first"]) return NO;
						if (![[array[1] sourceString] isEqualToString:@"@bug second"]) return NO;
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
});

TEST_END