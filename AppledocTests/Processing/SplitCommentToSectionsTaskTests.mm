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

describe(@"normal text:", ^{
	it(@"should convert second paragraph to discussion", ^{
		runWithTask(^(SplitCommentToSectionsTask *task, id comment) {
			// setup
			setupComment(comment, @"abstract\n\nsecond");
			// execute
			[task processComment:comment];
			// verify
			GBSections.count should equal(2);
			GBSections[0] should equal(@"abstract");
			GBSections[1] should equal(@"second");
		});
	});

	it(@"should convert second and subsequent paragraphs to discussion", ^{
		runWithTask(^(SplitCommentToSectionsTask *task, id comment) {
			// setup
			setupComment(comment, @"abstract\n\nsecond\n\nthird");
			// execute
			[task processComment:comment];
			// verify
			GBSections.count should equal(2);
			GBSections[0] should equal(@"abstract");
			GBSections[1] should equal(@"second\n\nthird");
		});
	});

	it(@"should handle multiple paragraphs with mutliple lines", ^{
		runWithTask(^(SplitCommentToSectionsTask *task, id comment) {
			// setup
			setupComment(comment, @"abstract\n\nline one\nline two\nline three\n\nthird paragraph\nand line two");
			// execute
			[task processComment:comment];
			// verify
			GBSections.count should equal(2);
			GBSections[0] should equal(@"abstract");
			GBSections[1] should equal(@"line one\nline two\nline three\n\nthird paragraph\nand line two");
		});
	});
});

describe(@"block code:", ^{
#define GBReplace(t) [t gb_stringByReplacing:@{ @"[": info[@"start"], @"]": info[@"end"], @"--": info[@"marker"] }]
	sharedExamplesFor(@"block code", ^(NSDictionary *info){
		it(@"should append block code to previous paragraph", ^{
			runWithTask(^(SplitCommentToSectionsTask *task, id comment) {
				// setup
				setupComment(comment, GBReplace(@"abstract\n\nnormal line\n\n[--block code]"));
				// execute
				[task processComment:comment];
				// verify
				GBSections.count should equal(3);
				GBSections[0] should equal(@"abstract");
				GBSections[1] should equal(@"normal line");
				GBSections[2] should equal(GBReplace(@"[--block code]"));
			});
		});

		it(@"should append all block code lines to previous paragraph", ^{
			runWithTask(^(SplitCommentToSectionsTask *task, id comment) {
				// setup
				setupComment(comment, GBReplace(@"abstract\n\nnormal line\n\n[--line 1\n--line 2]"));
				// execute
				[task processComment:comment];
				// verify
				GBSections.count should equal(3);
				GBSections[0] should equal(@"abstract");
				GBSections[1] should equal(@"normal line");
				GBSections[2] should equal(GBReplace(@"[--line 1\n--line 2]"));
			});
		});

		it(@"should append multiple block code sections to previous paragraph", ^{
			runWithTask(^(SplitCommentToSectionsTask *task, id comment) {
				// setup
				setupComment(comment, GBReplace(@"abstract\n\nnormal line\n\n[--line 1]\n\n[--line 2\n--line 3]"));
				// execute
				[task processComment:comment];
				// verify
				GBSections.count should equal(4);
				GBSections[0] should equal(@"abstract");
				GBSections[1] should equal(@"normal line");
				GBSections[2] should equal(GBReplace(@"[--line 1]"));
				GBSections[3] should equal(GBReplace(@"[--line 2\n--line 3]"));
			});
		});

		it(@"should append multiple block code sections delimited with normal paragraphs", ^{
			runWithTask(^(SplitCommentToSectionsTask *task, id comment) {
				// setup
				setupComment(comment, GBReplace(@"abstract\n\nnormal line 1\n\n[--line 1]\n\nnormal line 2\n\n[--line 2]"));
				// execute
				[task processComment:comment];
				// verify
				GBSections.count should equal(5);
				GBSections[0] should equal(@"abstract");
				GBSections[1] should equal(@"normal line 1");
				GBSections[2] should equal(GBReplace(@"[--line 1]"));
				GBSections[3] should equal(@"normal line 2");
				GBSections[4] should equal(GBReplace(@"[--line 2]"));
			});
		});

		it(@"should continue normal paragraph if not delimited with empty line", ^{
			runWithTask(^(SplitCommentToSectionsTask *task, id comment) {
				// setup
				setupComment(comment, GBReplace(@"abstract\n\nnormal line\n[--continue line]"));
				// execute
				[task processComment:comment];
				// verify
				GBSections.count should equal(2);
				GBSections[0] should equal(@"abstract");
				GBSections[1] should equal(GBReplace(@"normal line\n[--continue line]"));
			});
		});

		it(@"should keep all formatting after initial code block marker", ^{
			runWithTask(^(SplitCommentToSectionsTask *task, id comment) {
				// setup
				setupComment(comment, GBReplace(@"abstract\n\nnormal line\n\n[--line 1\n--\tline 2\n--    line 3]"));
				// execute
				[task processComment:comment];
				// verify
				GBSections.count should equal(3);
				GBSections[0] should equal(@"abstract");
				GBSections[1] should equal(@"normal line");
				GBSections[2] should equal(GBReplace(@"[--line 1\n--\tline 2\n--    line 3]"));
			});
		});
	});

	describe(@"delimited with tab:", ^{
		beforeEach(^{
			[[SpecHelper specHelper] sharedExampleContext][@"start"] = @"";
			[[SpecHelper specHelper] sharedExampleContext][@"marker"] = @"\t";
			[[SpecHelper specHelper] sharedExampleContext][@"end"] = @"";
		});
		itShouldBehaveLike(@"block code");
	});

	describe(@"delimited with spaces:", ^{
		beforeEach(^{
			[[SpecHelper specHelper] sharedExampleContext][@"start"] = @"";
			[[SpecHelper specHelper] sharedExampleContext][@"marker"] = @"    ";
			[[SpecHelper specHelper] sharedExampleContext][@"end"] = @"";
		});
		itShouldBehaveLike(@"block code");
	});

	describe(@"fenced code blocks:", ^{
		beforeEach(^{
			[[SpecHelper specHelper] sharedExampleContext][@"start"] = @"```";
			[[SpecHelper specHelper] sharedExampleContext][@"marker"] = @"";
			[[SpecHelper specHelper] sharedExampleContext][@"end"] = @"```";
		});
		itShouldBehaveLike(@"block code");
	});
});

TEST_END