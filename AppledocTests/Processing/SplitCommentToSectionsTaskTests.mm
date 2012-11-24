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

describe(@"warnings and bugs:", ^{
#define GBReplace(t) [t stringByReplacingOccurrencesOfString:@"@id" withString:info[@"id"]]
	sharedExamplesFor(@"as part of abstract", ^(NSDictionary *info) {
		it(@"should take as part of abstract if not delimited by empty line", ^{
			runWithTask(^(SplitCommentToSectionsTask *task, id comment) {
				// setup
				setupComment(comment, GBReplace(@"abstract\n@id text"));
				// execute
				[task processComment:comment];
				// verify
				GBSections.count should equal(1);
				GBSections[0] should equal(GBReplace(@"abstract\n@id text"));
			});
		});

		it(@"should take as part of abstract and take next paragraph as discussion if not delimited by empty line", ^{
			runWithTask(^(SplitCommentToSectionsTask *task, id comment) {
				// setup
				setupComment(comment, GBReplace(@"abstract\n@id text\n\nparagraph"));
				// execute
				[task processComment:comment];
				// verify
				GBSections.count should equal(2);
				GBSections[0] should equal(GBReplace(@"abstract\n@id text"));
				GBSections[1] should equal(@"paragraph");
			});
		});

		it(@"should make abstract special component if started with directive", ^{
			runWithTask(^(SplitCommentToSectionsTask *task, id comment) {
				// setup
				setupComment(comment, GBReplace(@"@id text"));
				// execute
				[task processComment:comment];
				// verify
				GBSections.count should equal(1);
				GBSections[0] should equal(GBReplace(@"@id text"));
			});
		});
	});

	sharedExamplesFor(@"as part of discussion", ^(NSDictionary *info) {
		it(@"should take as part of discussion if found as first paragraph after abstract", ^{
			runWithTask(^(SplitCommentToSectionsTask *task, id comment) {
				// setup
				setupComment(comment, GBReplace(@"abstract\n\n@id text"));
				// execute
				[task processComment:comment];
				// verify
				GBSections.count should equal(2);
				GBSections[0] should equal(@"abstract");
				GBSections[1] should equal(GBReplace(@"@id text"));
			});
		});

		it(@"should continue section if not delimited by empty line", ^{
			runWithTask(^(SplitCommentToSectionsTask *task, id comment) {
				// setup
				setupComment(comment, GBReplace(@"abstract\n\n@id text\n@id continuation"));
				// execute
				[task processComment:comment];
				// verify
				GBSections.count should equal(2);
				GBSections[0] should equal(@"abstract");
				GBSections[1] should equal(GBReplace(@"@id text\n@id continuation"));
			});
		});

		it(@"should start new paragraph if delimited by empty line", ^{
			runWithTask(^(SplitCommentToSectionsTask *task, id comment) {
				// setup
				setupComment(comment, GBReplace(@"abstract\n\nparagraph\n\n@id text"));
				// execute
				[task processComment:comment];
				// verify
				GBSections.count should equal(3);
				GBSections[0] should equal(@"abstract");
				GBSections[1] should equal(@"paragraph");
				GBSections[2] should equal(GBReplace(@"@id text"));
			});
		});

		it(@"should take all subsequent paragraphs as part of section", ^{
			runWithTask(^(SplitCommentToSectionsTask *task, id comment) {
				// setup
				setupComment(comment, GBReplace(@"abstract\n\nparagraph\n\n@id text\n\nnext paragraph"));
				// execute
				[task processComment:comment];
				// verify
				GBSections.count should equal(3);
				GBSections[0] should equal(@"abstract");
				GBSections[1] should equal(@"paragraph");
				GBSections[2] should equal(GBReplace(@"@id text\n\nnext paragraph"));
			});
		});

		it(@"should start new paragraph with next section directive", ^{
			runWithTask(^(SplitCommentToSectionsTask *task, id comment) {
				// setup
				setupComment(comment, GBReplace(@"abstract\n\n@id first\n\n@id second"));
				// execute
				[task processComment:comment];
				// verify
				GBSections.count should equal(3);
				GBSections[0] should equal(@"abstract");
				GBSections[1] should equal(GBReplace(@"@id first"));
				GBSections[2] should equal(GBReplace(@"@id second"));
			});
		});
	});

	describe(@"@warning:", ^{
		beforeEach(^{ [[SpecHelper specHelper] sharedExampleContext][@"id"] = @"@warning"; });
		itShouldBehaveLike(@"as part of abstract");
		itShouldBehaveLike(@"as part of discussion");
	});

	describe(@"@bug:", ^{
		beforeEach(^{ [[SpecHelper specHelper] sharedExampleContext][@"id"] = @"@bug"; });
		itShouldBehaveLike(@"as part of abstract");
		itShouldBehaveLike(@"as part of discussion");
	});
});

describe(@"method parameters:", ^{
	it(@"should register single parameter:", ^{
		runWithTask(^(SplitCommentToSectionsTask *task, id comment) {
			// setup
			setupComment(comment, @"abstract\n\n@param name description");
			// execute
			[task processComment:comment];
			// verify
			GBSections.count should equal(2);
			GBSections[0] should equal(@"abstract");
			GBSections[1] should equal(@"@param name description");
		});
	});

	it(@"should register multiple parameters:", ^{
		runWithTask(^(SplitCommentToSectionsTask *task, id comment) {
			// setup
			setupComment(comment, @"abstract\n\n@param name1 description 1\n@param name2 description 2");
			// execute
			[task processComment:comment];
			// verify
			GBSections.count should equal(3);
			GBSections[0] should equal(@"abstract");
			GBSections[1] should equal(@"@param name1 description 1");
			GBSections[2] should equal(@"@param name2 description 2");
		});
	});

	it(@"should take all paragraphs following directive as part of directive:", ^{
		runWithTask(^(SplitCommentToSectionsTask *task, id comment) {
			// setup
			setupComment(comment, @"abstract\n\n@param name1 description1\nin multiple\n\nlines and paragraphs\n\n@param name2 description 2");
			// execute
			[task processComment:comment];
			// verify
			GBSections.count should equal(3);
			GBSections[0] should equal(@"abstract");
			GBSections[1] should equal(@"@param name1 description1\nin multiple\n\nlines and paragraphs");
			GBSections[2] should equal(@"@param name2 description 2");
		});
	});
});

describe(@"method exceptions:", ^{
	it(@"should register single exception:", ^{
		runWithTask(^(SplitCommentToSectionsTask *task, id comment) {
			// setup
			setupComment(comment, @"abstract\n\n@exception name description");
			// execute
			[task processComment:comment];
			// verify
			GBSections.count should equal(2);
			GBSections[0] should equal(@"abstract");
			GBSections[1] should equal(@"@exception name description");
		});
	});

	it(@"should register multiple exceptions:", ^{
		runWithTask(^(SplitCommentToSectionsTask *task, id comment) {
			// setup
			setupComment(comment, @"abstract\n\n@exception name1 description 1\n@exception name2 description 2");
			// execute
			[task processComment:comment];
			// verify
			GBSections.count should equal(3);
			GBSections[0] should equal(@"abstract");
			GBSections[1] should equal(@"@exception name1 description 1");
			GBSections[2] should equal(@"@exception name2 description 2");
		});
	});

	it(@"should take all paragraphs following directive as part of directive:", ^{
		runWithTask(^(SplitCommentToSectionsTask *task, id comment) {
			// setup
			setupComment(comment, @"abstract\n\n@exception name1 description1\nin multiple\n\nlines and paragraphs\n\n@exception name2 description 2");
			// execute
			[task processComment:comment];
			// verify
			GBSections.count should equal(3);
			GBSections[0] should equal(@"abstract");
			GBSections[1] should equal(@"@exception name1 description1\nin multiple\n\nlines and paragraphs");
			GBSections[2] should equal(@"@exception name2 description 2");
		});
	});
});

describe(@"method return:", ^{
	it(@"should register single return:", ^{
		runWithTask(^(SplitCommentToSectionsTask *task, id comment) {
			// setup
			setupComment(comment, @"abstract\n\n@return description");
			// execute
			[task processComment:comment];
			// verify
			GBSections.count should equal(2);
			GBSections[0] should equal(@"abstract");
			GBSections[1] should equal(@"@return description");
		});
	});

	it(@"should register all detected return sections:", ^{
		runWithTask(^(SplitCommentToSectionsTask *task, id comment) {
			// setup
			setupComment(comment, @"abstract\n\n@return description 1\n@return description 2");
			// execute
			[task processComment:comment];
			// verify
			GBSections.count should equal(3);
			GBSections[0] should equal(@"abstract");
			GBSections[1] should equal(@"@return description 1");
			GBSections[2] should equal(@"@return description 2");
		});
	});

	it(@"should take all paragraphs following directive as part of directive:", ^{
		runWithTask(^(SplitCommentToSectionsTask *task, id comment) {
			// setup
			setupComment(comment, @"abstract\n\n@return description\nin multiple\n\nlines and paragraphs");
			// execute
			[task processComment:comment];
			// verify
			GBSections.count should equal(2);
			GBSections[0] should equal(@"abstract");
			GBSections[1] should equal(@"@return description\nin multiple\n\nlines and paragraphs");
		});
	});
});

TEST_END