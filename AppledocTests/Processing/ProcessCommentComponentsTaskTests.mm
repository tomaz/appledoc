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

#define GBAbstract ((CommentComponentInfo *)[comment commentAbstract])
#define GBDiscussion ((CommentSectionInfo *)[comment commentDiscussion])

#pragma mark -

static void runWithMockTask(void(^handler)(ProcessCommentComponentsTask *task, id comment)) {
	// ProcessCommentComponentsTask doesn't need store/settings/object/context, so we can get away with only giving it the comment.
	ProcessCommentComponentsTask *task = [[ProcessCommentComponentsTask alloc] init];
	id mock = mock([CommentInfo class]);
	handler(task, mock);
	[task release];
}

static void runWithTask(void(^handler)(ProcessCommentComponentsTask *task, id comment)) {
	// ProcessCommentComponentsTask doesn't need store/settings/object/context, so we can get away with only giving it the comment.
	ProcessCommentComponentsTask *task = [[ProcessCommentComponentsTask alloc] init];
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

@interface ProcessCommentComponentsTask (UnitTestingPrivateAPI)
- (NSInteger)processCommentForObject:(ObjectInfoBase *)object context:(ObjectInfoBase *)parent;
@end

#pragma mark -

TEST_BEGIN(ProcessCommentComponentsTaskTests)

describe(@"abstract:", ^{
	it(@"should convert single line to abstract", ^{
		runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
			// setup
			setupComment(comment, @"line");
			// execute
			[task processComment:comment];
			// verify
			((CommentComponentInfo *)[comment commentAbstract]).sourceString should equal(@"line");
			GBAbstract.sourceString should equal(@"line");
		});
	});
	
	it(@"should convert single paragraph composed of multiple lines to abstract", ^{
		runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
			// setup
			setupComment(comment, @"line one\nline two\nline three");
			// execute
			[task processComment:comment];
			// verify
			GBAbstract.sourceString should equal(@"line one\nline two\nline three");
		});
	});
});

describe(@"normal text:", ^{
	it(@"should convert second paragraph to discussion", ^{
		runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
			// setup
			setupComment(comment, @"abstract\n\nsecond");
			// execute
			[task processComment:comment];
			// verify
			GBAbstract.sourceString should equal(@"abstract");
			GBDiscussion.sectionComponents.count should equal(1);
			[GBDiscussion.sectionComponents[0] sourceString] should equal(@"second");
			[GBDiscussion.sectionComponents[0] class] should equal([CommentComponentInfo class]);
		});
	});
	
	it(@"should convert second and subsequent paragraphs to discussion", ^{
		runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
			// setup
			setupComment(comment, @"abstract\n\nsecond\n\nthird");
			// execute
			[task processComment:comment];
			// verify
			GBAbstract.sourceString should equal(@"abstract");
			GBDiscussion.sectionComponents.count should equal(1);
			[GBDiscussion.sectionComponents[0] sourceString] should equal(@"second\n\nthird");
			[GBDiscussion.sectionComponents[0] class] should equal([CommentComponentInfo class]);
		});
	});
	
	it(@"should handle multiple paragraphs with mutliple lines", ^{
		runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
			// setup
			setupComment(comment, @"abstract\n\nline one\nline two\nline three\n\nthird paragraph\nand line two");
			// execute
			[task processComment:comment];
			// verify
			GBAbstract.sourceString should equal(@"abstract");
			GBDiscussion.sectionComponents.count should equal(1);
			[GBDiscussion.sectionComponents[0] sourceString] should equal(@"line one\nline two\nline three\n\nthird paragraph\nand line two");
			[GBDiscussion.sectionComponents[0] class] should equal([CommentComponentInfo class]);
		});
	});
});

describe(@"block code:", ^{
#define GBReplace(t) [t stringByReplacingOccurrencesOfString:@"--" withString:info[@"marker"]]
	sharedExamplesFor(@"block code", ^(NSDictionary *info){
		it(@"should append block code to previous paragraph", ^{
			runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
				// setup
				setupComment(comment, GBReplace(@"abstract\n\nnormal line\n\n--block code"));
				// execute
				[task processComment:comment];
				// verify
				GBAbstract.sourceString should equal(@"abstract");
				GBDiscussion.sectionComponents.count should equal(1);
				[GBDiscussion.sectionComponents[0] sourceString] should equal(GBReplace(@"normal line\n\n--block code"));
			});
		});

		it(@"should append all block code lines to previous paragraph", ^{
			runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
				// setup
				setupComment(comment, GBReplace(@"abstract\n\nnormal line\n\n--line 1\n--line 2"));
				// execute
				[task processComment:comment];
				// verify
				GBAbstract.sourceString should equal(@"abstract");
				GBDiscussion.sectionComponents.count should equal(1);
				[GBDiscussion.sectionComponents[0] sourceString] should equal(GBReplace(@"normal line\n\n--line 1\n--line 2"));
			});
		});

		it(@"should append multiple block code sections to previous paragraph", ^{
			runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
				// setup
				setupComment(comment, GBReplace(@"abstract\n\nnormal line\n\n--line 1\n\n--line 2\n--line 3"));
				// execute
				[task processComment:comment];
				// verify
				GBAbstract.sourceString should equal(@"abstract");
				GBDiscussion.sectionComponents.count should equal(1);
				[GBDiscussion.sectionComponents[0] sourceString] should equal(GBReplace(@"normal line\n\n--line 1\n\n--line 2\n--line 3"));
			});
		});

		it(@"should append multiple block code sections delimited with normal paragraphs", ^{
			runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
				// setup
				setupComment(comment, GBReplace(@"abstract\n\nnormal line 1\n\n--line 1\n\nnormal line 2\n\n--line 2"));
				// execute
				[task processComment:comment];
				// verify
				GBAbstract.sourceString should equal(@"abstract");
				GBDiscussion.sectionComponents.count should equal(1);
				[GBDiscussion.sectionComponents[0] sourceString] should equal(GBReplace(@"normal line 1\n\n--line 1\n\nnormal line 2\n\n--line 2"));
			});
		});

		it(@"should continue normal paragraph if not delimited with empty line", ^{
			runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
				// setup
				setupComment(comment, GBReplace(@"abstract\n\nnormal line\n--continue line"));
				// execute
				[task processComment:comment];
				// verify
				GBAbstract.sourceString should equal(@"abstract");
				GBDiscussion.sectionComponents.count should equal(1);
				[GBDiscussion.sectionComponents[0] sourceString] should equal(GBReplace(@"normal line\n--continue line"));
			});
		});

		it(@"should keep all formatting after initial code block marker", ^{
			runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
				// setup
				setupComment(comment, GBReplace(@"abstract\n\nnormal line\n\n--line 1\n--\tline 2\n--    line 3"));
				// execute
				[task processComment:comment];
				// verify
				GBAbstract.sourceString should equal(@"abstract");
				GBDiscussion.sectionComponents.count should equal(1);
				[GBDiscussion.sectionComponents[0] sourceString] should equal(GBReplace(@"normal line\n\n--line 1\n--\tline 2\n--    line 3"));
			});
		});
	});
	
	describe(@"delimited with tab:", ^{
		beforeEach(^{ [[SpecHelper specHelper] sharedExampleContext][@"marker"] = @"\t"; });
		itShouldBehaveLike(@"block code");
	});
	
	describe(@"delimited with spaces", ^{
		beforeEach(^{ [[SpecHelper specHelper] sharedExampleContext][@"marker"] = @"    "; });
		itShouldBehaveLike(@"block code");
	});
});

describe(@"block quote:", ^{
	it(@"should append block quote to previous paragraph", ^{
		runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
			// setup
			setupComment(comment, @"abstract\n\nnormal line\n\n> block quote");
			// execute
			[task processComment:comment];
			// verify
			GBAbstract.sourceString should equal(@"abstract");
			GBDiscussion.sectionComponents.count should equal(1);
			[GBDiscussion.sectionComponents[0] sourceString] should equal(@"normal line\n\n> block quote");
			[GBDiscussion.sectionComponents[0] class] should equal([CommentComponentInfo class]);
		});
	});

	it(@"should append all block quotes to previous paragraph", ^{
		runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
			// setup
			setupComment(comment, @"abstract\n\nnormal line\n\n> line 1\n> line 2\n\n> line 3");
			// execute
			[task processComment:comment];
			// verify
			GBAbstract.sourceString should equal(@"abstract");
			GBDiscussion.sectionComponents.count should equal(1);
			[GBDiscussion.sectionComponents[0] sourceString] should equal(@"normal line\n\n> line 1\n> line 2\n\n> line 3");
			[GBDiscussion.sectionComponents[0] class] should equal([CommentComponentInfo class]);
		});
	});
	
	it(@"should handle nested block quotes", ^{
		runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
			// setup
			setupComment(comment, @"abstract\n\nnormal line\n\n> level 1\n> > level 2\n> back to 1");
			// execute
			[task processComment:comment];
			// verify
			GBAbstract.sourceString should equal(@"abstract");
			GBDiscussion.sectionComponents.count should equal(1);
			[GBDiscussion.sectionComponents[0] sourceString] should equal(@"normal line\n\n> level 1\n> > level 2\n> back to 1");
			[GBDiscussion.sectionComponents[0] class] should equal([CommentComponentInfo class]);
		});
	});
	
	it(@"should take block quote for abstract", ^{
		runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
			// setup
			setupComment(comment, @"> block quote");
			// execute
			[task processComment:comment];
			// verify
			GBAbstract.sourceString should equal(@"> block quote");
			GBDiscussion.sectionComponents.count should equal(0);
		});
	});
});

describe(@"lists:", ^{
#define GBReplace(t) [t stringByReplacingOccurrencesOfString:@"--" withString:info[@"marker"]]
	sharedExamplesFor(@"lists", ^(NSDictionary *info) {
		it(@"should append list to previous paragraph", ^{
			runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
				// setup
				setupComment(comment, GBReplace(@"abstract\n\nnormal line\n\n-- list item"));
				// execute
				[task processComment:comment];
				// verify
				GBAbstract.sourceString should equal(@"abstract");
				GBDiscussion.sectionComponents.count should equal(1);
				[GBDiscussion.sectionComponents[0] sourceString] should equal(GBReplace(@"normal line\n\n-- list item"));
				[GBDiscussion.sectionComponents[0] class] should equal([CommentComponentInfo class]);
			});
		});

		it(@"should append all list items to previous paragraph", ^{
			runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
				// setup
				setupComment(comment, GBReplace(@"abstract\n\nnormal line\n\n-- line 1\n-- line 2\n\n-- line 3"));
				// execute
				[task processComment:comment];
				// verify
				GBAbstract.sourceString should equal(@"abstract");
				GBDiscussion.sectionComponents.count should equal(1);
				[GBDiscussion.sectionComponents[0] sourceString] should equal(GBReplace(@"normal line\n\n-- line 1\n-- line 2\n\n-- line 3"));
				[GBDiscussion.sectionComponents[0] class] should equal([CommentComponentInfo class]);
			});
		});

		it(@"should handle nested lists", ^{
			runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
				// setup
				setupComment(comment, GBReplace(@"abstract\n\nnormal line\n\n-- level 1\n\t-- level 2\n-- back to 1"));
				// execute
				[task processComment:comment];
				// verify
				GBAbstract.sourceString should equal(@"abstract");
				GBDiscussion.sectionComponents.count should equal(1);
				[GBDiscussion.sectionComponents[0] sourceString] should equal(GBReplace(@"normal line\n\n-- level 1\n\t-- level 2\n-- back to 1"));
				[GBDiscussion.sectionComponents[0] class] should equal([CommentComponentInfo class]);
			});
		});

		it(@"should take list for abstract", ^{
			runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
				// setup
				setupComment(comment, GBReplace(@"-- item"));
				// execute
				[task processComment:comment];
				// verify
				GBAbstract.sourceString should equal(GBReplace(@"-- item"));
				GBDiscussion.sectionComponents.count should equal(0);
			});
		});
	});

	describe(@"unordered lists with minus:", ^{
		beforeEach(^{ [[SpecHelper specHelper] sharedExampleContext][@"marker"] = @"-"; });
		itShouldBehaveLike(@"lists");
	});
	
	describe(@"unordered lists with star:", ^{
		beforeEach(^{ [[SpecHelper specHelper] sharedExampleContext][@"marker"] = @"*"; });
		itShouldBehaveLike(@"lists");
	});
	
	describe(@"ordered lists:", ^{
		beforeEach(^{ [[SpecHelper specHelper] sharedExampleContext][@"marker"] = @"1."; });
		itShouldBehaveLike(@"lists");
	});
});

describe(@"tables:", ^{
	it(@"should append table to previous paragraph", ^{
		runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
			// setup
			setupComment(comment, @"abstract\n\nnormal line\n\nheader 1 | header 2\n-------|------\ni11|i12\ni21|i22");
			// execute
			[task processComment:comment];
			// verify
			GBAbstract.sourceString should equal(@"abstract");
			GBDiscussion.sectionComponents.count should equal(1);
			[GBDiscussion.sectionComponents[0] sourceString] should equal(@"normal line\n\nheader 1 | header 2\n-------|------\ni11|i12\ni21|i22");
		});
	});
});

describe(@"warnings and bugs:", ^{
#define GBReplace(t) [t stringByReplacingOccurrencesOfString:@"@id" withString:info[@"id"]]
	sharedExamplesFor(@"as part of abstract", ^(NSDictionary *info) {
		it(@"should take as part of abstract if not delimited by empty line", ^{
			runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
				// setup
				setupComment(comment, GBReplace(@"abstract\n@id text"));
				// execute
				[task processComment:comment];
				// verify
				GBAbstract.sourceString should equal(GBReplace(@"abstract\n@id text"));
			});
		});

		it(@"should take as part of abstract and take next paragraph as discussion if not delimited by empty line", ^{
			runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
				// setup
				setupComment(comment, GBReplace(@"abstract\n@id text\n\nparagraph"));
				// execute
				[task processComment:comment];
				// verify
				GBAbstract.sourceString should equal(GBReplace(@"abstract\n@id text"));
				GBDiscussion.sectionComponents.count should equal(1);
				[GBDiscussion.sectionComponents[0] sourceString] should equal(@"paragraph");
			});
		});
	});

	sharedExamplesFor(@"as part of discussion", ^(NSDictionary *info) {
		it(@"should take as part of discussion if found as first paragraph after abstract", ^{
			runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
				// setup
				setupComment(comment, GBReplace(@"abstract\n\n@id text"));
				// execute
				[task processComment:comment];
				// verify
				GBAbstract.sourceString should equal(@"abstract");
				GBDiscussion.sectionComponents.count should equal(1);
				[GBDiscussion.sectionComponents[0] sourceString] should equal(GBReplace(@"@id text"));
			});
		});

		it(@"should start new paragraph if delimited by empty line", ^{
			runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
				// setup
				setupComment(comment, GBReplace(@"abstract\n\nparagraph\n\n@id text"));
				// execute
				[task processComment:comment];
				// verify
				GBAbstract.sourceString should equal(@"abstract");
				GBDiscussion.sectionComponents.count should equal(2);
				[GBDiscussion.sectionComponents[0] sourceString] should equal(@"paragraph");
				[GBDiscussion.sectionComponents[1] sourceString] should equal(GBReplace(@"@id text"));
			});
		});

		it(@"should take all subsequent paragraphs as part of section", ^{
			runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
				// setup
				setupComment(comment, GBReplace(@"abstract\n\nparagraph\n\n@id text\n\nnext paragraph"));
				// execute
				[task processComment:comment];
				// verify
				GBAbstract.sourceString should equal(@"abstract");
				GBDiscussion.sectionComponents.count should equal(2);
				[GBDiscussion.sectionComponents[0] sourceString] should equal(@"paragraph");
				[GBDiscussion.sectionComponents[1] sourceString] should equal(GBReplace(@"@id text\n\nnext paragraph"));
			});
		});

		it(@"should start new paragraph with next section directive", ^{
			runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
				// setup
				setupComment(comment, GBReplace(@"abstract\n\n@id first\n\n@id second"));
				// execute
				[task processComment:comment];
				// verify
				GBAbstract.sourceString should equal(@"abstract");
				GBDiscussion.sectionComponents.count should equal(2);
				[GBDiscussion.sectionComponents[0] sourceString] should equal(GBReplace(@"@id first"));
				[GBDiscussion.sectionComponents[1] sourceString] should equal(GBReplace(@"@id second"));
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
#define GBParameters ((NSArray *)[comment commentParameters])
#define GBParameter(i) GBParameters[i]
#define GBComponent(i,n) [GBParameters[i] sectionComponents][n]
	it(@"should register single parameter:", ^{
		runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
			// setup
			setupComment(comment, @"abstract\n\n@param name description");
			// execute
			[task processComment:comment];
			// verify
			GBAbstract.sourceString should equal(@"abstract");
			GBParameters.count should equal(1);
			[GBParameter(0) sectionName] should equal(@"name");
			[GBParameter(0) sectionComponents].count should equal(1);
			[GBComponent(0,0) sourceString] should equal(@"description");
			[GBComponent(0,0) class] should equal([CommentComponentInfo class]);
		});
	});
	
	it(@"should register multiple parameters:", ^{
		runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
			// setup
			setupComment(comment, @"abstract\n\n@param name1 description 1\n@param name2 description 2");
			// execute
			[task processComment:comment];
			// verify
			GBAbstract.sourceString should equal(@"abstract");
			GBParameters.count should equal(2);
			[GBParameter(0) sectionName] should equal(@"name1");
			[GBParameter(0) sectionComponents].count should equal(1);
			[GBComponent(0,0) sourceString] should equal(@"description 1");
			[GBComponent(0,0) class] should equal([CommentComponentInfo class]);
			[GBParameter(1) sectionName] should equal(@"name2");
			[GBParameter(1) sectionComponents].count should equal(1);
			[GBComponent(1,0) sourceString] should equal(@"description 2");
			[GBComponent(1,0) class] should equal([CommentComponentInfo class]);
		});
	});
	
	it(@"should take all paragraphs following directive as part of directive:", ^{
		runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
			// setup
			setupComment(comment, @"abstract\n\n@param name1 description1\nin multiple\n\nlines and paragraphs\n\n@param name2 description 2");
			// execute
			[task processComment:comment];
			// verify
			GBAbstract.sourceString should equal(@"abstract");
			GBParameters.count should equal(2);
			[GBParameter(0) sectionName] should equal(@"name1");
			[GBParameter(0) sectionComponents].count should equal(1);
			[GBComponent(0,0) sourceString] should equal(@"description1\nin multiple\n\nlines and paragraphs");
			[GBComponent(0,0) class] should equal([CommentComponentInfo class]);
			[GBParameter(1) sectionName] should equal(@"name2");
			[GBParameter(1) sectionComponents].count should equal(1);
			[GBComponent(1,0) sourceString] should equal(@"description 2");
			[GBComponent(1,0) class] should equal([CommentComponentInfo class]);
		});
	});
});

describe(@"method exceptions:", ^{
#define GBExceptions ((NSArray *)[comment commentExceptions])
#define GBException(i) GBExceptions[i]
#define GBComponent(i,n) [GBExceptions[i] sectionComponents][n]
	it(@"should register single exception:", ^{
		runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
			// setup
			setupComment(comment, @"abstract\n\n@exception name description");
			// execute
			[task processComment:comment];
			// verify
			GBAbstract.sourceString should equal(@"abstract");
			GBExceptions.count should equal(1);
			[GBException(0) sectionName] should equal(@"name");
			[GBException(0) sectionComponents].count should equal(1);
			[GBComponent(0,0) sourceString] should equal(@"description");
			[GBComponent(0,0) class] should equal([CommentComponentInfo class]);
		});
	});
	
	it(@"should register multiple exceptions:", ^{
		runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
			// setup
			setupComment(comment, @"abstract\n\n@exception name1 description 1\n@exception name2 description 2");
			// execute
			[task processComment:comment];
			// verify
			GBAbstract.sourceString should equal(@"abstract");
			GBExceptions.count should equal(2);
			[GBException(0) sectionName] should equal(@"name1");
			[GBException(0) sectionComponents].count should equal(1);
			[GBComponent(0,0) sourceString] should equal(@"description 1");
			[GBComponent(0,0) class] should equal([CommentComponentInfo class]);
			[GBException(1) sectionName] should equal(@"name2");
			[GBException(1) sectionComponents].count should equal(1);
			[GBComponent(1,0) sourceString] should equal(@"description 2");
			[GBComponent(1,0) class] should equal([CommentComponentInfo class]);
		});
	});
	
	it(@"should take all paragraphs following directive as part of directive:", ^{
		runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
			// setup
			setupComment(comment, @"abstract\n\n@exception name1 description1\nin multiple\n\nlines and paragraphs\n\n@exception name2 description 2");
			// execute
			[task processComment:comment];
			// verify
			GBAbstract.sourceString should equal(@"abstract");
			GBExceptions.count should equal(2);
			[GBException(0) sectionName] should equal(@"name1");
			[GBException(0) sectionComponents].count should equal(1);
			[GBComponent(0,0) sourceString] should equal(@"description1\nin multiple\n\nlines and paragraphs");
			[GBComponent(0,0) class] should equal([CommentComponentInfo class]);
			[GBException(1) sectionName] should equal(@"name2");
			[GBException(1) sectionComponents].count should equal(1);
			[GBComponent(1,0) sourceString] should equal(@"description 2");
			[GBComponent(1,0) class] should equal([CommentComponentInfo class]);
		});
	});
});

describe(@"method return:", ^{
#define GBReturn ((CommentSectionInfo *)[comment commentReturn])
	it(@"should register single return:", ^{
		runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
			// setup
			setupComment(comment, @"abstract\n\n@return description");
			// execute
			[task processComment:comment];
			// verify
			GBAbstract.sourceString should equal(@"abstract");
			GBReturn.sectionComponents.count should equal(1);
			[GBReturn.sectionComponents[0] sourceString] should equal(@"description");
			[GBReturn.sectionComponents[0] class] should equal([CommentComponentInfo class]);
		});
	});
	
	it(@"should use last return if multiple found:", ^{
		runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
			// setup
			setupComment(comment, @"abstract\n\n@return description 1\n@return description 2");
			// execute
			[task processComment:comment];
			// verify
			GBAbstract.sourceString should equal(@"abstract");
			GBReturn.sectionComponents.count should equal(1);
			[GBReturn.sectionComponents[0] sourceString] should equal(@"description 2");
			[GBReturn.sectionComponents[0] class] should equal([CommentComponentInfo class]);
		});
	});
	
	it(@"should take all paragraphs following directive as part of directive:", ^{
		runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
			// setup
			setupComment(comment, @"abstract\n\n@return description\nin multiple\n\nlines and paragraphs");
			// execute
			[task processComment:comment];
			// verify
			GBAbstract.sourceString should equal(@"abstract");
			GBReturn.sectionComponents.count should equal(1);
			[GBReturn.sectionComponents[0] sourceString] should equal(@"description\nin multiple\n\nlines and paragraphs");
			[GBReturn.sectionComponents[0] class] should equal([CommentComponentInfo class]);
		});
	});
});

TEST_END