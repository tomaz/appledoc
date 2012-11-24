//
//  RegisterCommentComponentsTaskTests.m
//  appledoc
//
//  Created by Tomaz Kragelj on 8/11/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "RegisterCommentComponentsTask.h"
#import "TestCaseBase.hh"

static void runWithTask(void(^handler)(RegisterCommentComponentsTask *task, id comment)) {
	// RegisterCommentComponentsTask doesn't need store/settings/object/context, so we can get away with only giving it the comment.
	RegisterCommentComponentsTask *task = [[RegisterCommentComponentsTask alloc] init];
	CommentInfo *comment = [[CommentInfo alloc] init];
	handler(task, comment);
	[task release];
}

static void setupComment(id comment, NSString *first ...) {
	va_list args;
	va_start(args, first);
	NSMutableArray *sections = [@[] mutableCopy];
	for (NSString *arg=first; arg!=nil; arg=va_arg(args, NSString *)) {
		[sections addObject:arg];
	}
	va_end(args);
	
	if ([comment isKindOfClass:[CommentInfo class]])
		[comment setSourceSections:sections];
	else
		[given([comment sourceSections]) willReturn:sections];
}

#pragma mark - 

#define GBAbstract(t,c) \
	[[comment commentAbstract] sourceString] should equal(t); \
	[[comment commentAbstract] class] should equal([c class])

#define GBDiscussionsCount(c) [[[comment commentDiscussion] sectionComponents] count] should equal(c)
#define GBDiscussion(i,t,c) \
	[[[comment commentDiscussion] sectionComponents][i] sourceString] should equal(t); \
	[[[comment commentDiscussion] sectionComponents][i] class] should equal([c class])

#define GBParametersCount(c) [[comment commentParameters] count] should equal(c);
#define GBExceptionsCount(c) [[comment commentExceptions] count] should equal(c);
#define GBReturnCount(c) [[[comment commentReturn] sectionComponents] count] should equal(c)

#define GBMethodSectionsEmpty() GBParametersCount(0); GBExceptionsCount(0); GBReturnCount(0)

#pragma mark -

TEST_BEGIN(RegisterCommentComponentsTaskTests)

describe(@"normal text:", ^{
	it(@"should convert single section to abstract", ^{
		runWithTask(^(RegisterCommentComponentsTask *task, id comment) {
			// setup
			setupComment(comment, @"section 1", nil);
			// execute
			[task processComment:comment];
			// verify
			GBAbstract(@"section 1", CommentComponentInfo);
			GBDiscussionsCount(0);
			GBMethodSectionsEmpty();
		});
	});

	it(@"should convert multiple sections to abstract and discussion", ^{
		runWithTask(^(RegisterCommentComponentsTask *task, id comment) {
			// setup
			setupComment(comment, @"section 1", @"section 2", @"section 3", nil);
			// execute
			[task processComment:comment];
			// verify
			GBAbstract(@"section 1", CommentComponentInfo);
			GBDiscussionsCount(2);
			GBDiscussion(0, @"section 2", CommentComponentInfo);
			GBDiscussion(1, @"section 3", CommentComponentInfo);
			GBMethodSectionsEmpty();
		});
	});
});

describe(@"code blocks:", ^{
#define GBReplace(t) [t gb_stringByReplacing:@{ @"[": info[@"start"], @"]": info[@"end"], @"--": info[@"marker"] }]
	sharedExamplesFor(@"code block", ^(NSDictionary *info) {
		it(@"should append code block section to previous paragraph", ^{
			runWithTask(^(RegisterCommentComponentsTask *task, id comment) {
				// setup
				setupComment(comment, @"abstract", @"normal line", GBReplace(@"[--code line]"), nil);
				// execute
				[task processComment:comment];
				// verify
				GBAbstract(@"abstract", CommentComponentInfo);
				GBDiscussionsCount(2);
				GBDiscussion(0, @"normal line", CommentComponentInfo);
				GBDiscussion(1, GBReplace(@"[--code line]"), CommentCodeBlockComponentInfo);
				GBMethodSectionsEmpty();
			});
		});

		it(@"should append all code block sections to previous paragraph", ^{
			runWithTask(^(RegisterCommentComponentsTask *task, id comment) {
				// setup
				setupComment(comment, @"abstract", @"normal line", GBReplace(@"[--code section 1]"), GBReplace(@"[--code section 2]"), nil);
				// execute
				[task processComment:comment];
				// verify
				GBAbstract(@"abstract", CommentComponentInfo);
				GBDiscussionsCount(3);
				GBDiscussion(0, @"normal line", CommentComponentInfo);
				GBDiscussion(1, GBReplace(@"[--code section 1]"), CommentCodeBlockComponentInfo);
				GBDiscussion(2, GBReplace(@"[--code section 2]"), CommentCodeBlockComponentInfo);
				GBMethodSectionsEmpty();
			});
		});
		
		it(@"should append mixed code block sections to previous paragraph", ^{
			runWithTask(^(RegisterCommentComponentsTask *task, id comment) {
				// setup
				setupComment(comment, @"abstract", @"normal line 1", GBReplace(@"[--code section 1]"), @"normal line 2", GBReplace(@"[--code section 2]"), nil);
				// execute
				[task processComment:comment];
				// verify
				GBAbstract(@"abstract", CommentComponentInfo);
				GBDiscussionsCount(4);
				GBDiscussion(0, @"normal line 1", CommentComponentInfo);
				GBDiscussion(1, GBReplace(@"[--code section 1]"), CommentCodeBlockComponentInfo);
				GBDiscussion(2, @"normal line 2", CommentComponentInfo);
				GBDiscussion(3, GBReplace(@"[--code section 2]"), CommentCodeBlockComponentInfo);
				GBMethodSectionsEmpty();
			});
		});
	});
	
	describe(@"delimited with tab:", ^{
		beforeEach(^{
			[[SpecHelper specHelper] sharedExampleContext][@"start"] = @"";
			[[SpecHelper specHelper] sharedExampleContext][@"marker"] = @"\t";
			[[SpecHelper specHelper] sharedExampleContext][@"end"] = @"";
		});
		itShouldBehaveLike(@"code block");
	});
	
	describe(@"delimited with spaces:", ^{
		beforeEach(^{
			[[SpecHelper specHelper] sharedExampleContext][@"start"] = @"";
			[[SpecHelper specHelper] sharedExampleContext][@"marker"] = @"    ";
			[[SpecHelper specHelper] sharedExampleContext][@"end"] = @"";
		});
		itShouldBehaveLike(@"code block");
	});
	
	describe(@"fenced code blocks:", ^{
		beforeEach(^{
			[[SpecHelper specHelper] sharedExampleContext][@"start"] = @"```";
			[[SpecHelper specHelper] sharedExampleContext][@"marker"] = @"";
			[[SpecHelper specHelper] sharedExampleContext][@"end"] = @"```";
		});
		itShouldBehaveLike(@"code block");
	});
});
//describe(@"warnings and bugs:", ^{
//#define GBReplace(t) [t stringByReplacingOccurrencesOfString:@"@id" withString:info[@"id"]]
//#define GBClass() info[@"type"]
//	sharedExamplesFor(@"as part of abstract", ^(NSDictionary *info) {
//		it(@"should take as part of abstract if not delimited by empty line", ^{
//			runWithTask(^(RegisterCommentComponentsTask *task, id comment) {
//				// setup
//				setupComment(comment, GBReplace(@"abstract\n@id text"));
//				// execute
//				[task processComment:comment];
//				// verify
//				GBAbstract.sourceString should equal(GBReplace(@"abstract\n@id text"));
//				[GBAbstract class] should equal([CommentComponentInfo class]);
//			});
//		});
//
//		it(@"should take as part of abstract and take next paragraph as discussion if not delimited by empty line", ^{
//			runWithTask(^(RegisterCommentComponentsTask *task, id comment) {
//				// setup
//				setupComment(comment, GBReplace(@"abstract\n@id text\n\nparagraph"));
//				// execute
//				[task processComment:comment];
//				// verify
//				GBAbstract.sourceString should equal(GBReplace(@"abstract\n@id text"));
//				[GBAbstract class] should equal([CommentComponentInfo class]);
//				GBDiscussion.sectionComponents.count should equal(1);
//				[GBDiscussion.sectionComponents[0] sourceString] should equal(@"paragraph");
//				[GBDiscussion.sectionComponents[0] class] should equal([CommentComponentInfo class]);
//			});
//		});
//		
//		it(@"should make abstract special component if started with directive", ^{
//			runWithTask(^(RegisterCommentComponentsTask *task, id comment) {
//				// setup
//				setupComment(comment, GBReplace(@"@id text"));
//				// execute
//				[task processComment:comment];
//				// verify
//				GBAbstract.sourceString should equal(GBReplace(@"@id text"));
//				[GBAbstract class] should equal(GBClass());
//			});
//		});
//	});
//
//	sharedExamplesFor(@"as part of discussion", ^(NSDictionary *info) {
//		it(@"should take as part of discussion if found as first paragraph after abstract", ^{
//			runWithTask(^(RegisterCommentComponentsTask *task, id comment) {
//				// setup
//				setupComment(comment, GBReplace(@"abstract\n\n@id text"));
//				// execute
//				[task processComment:comment];
//				// verify
//				GBAbstract.sourceString should equal(@"abstract");
//				[GBAbstract class] should equal([CommentComponentInfo class]);
//				GBDiscussion.sectionComponents.count should equal(1);
//				[GBDiscussion.sectionComponents[0] sourceString] should equal(GBReplace(@"@id text"));
//				[GBDiscussion.sectionComponents[0] class] should equal(GBClass());
//			});
//		});
//
//		it(@"should continue section if not delimited by empty line", ^{
//			runWithTask(^(RegisterCommentComponentsTask *task, id comment) {
//				// setup
//				setupComment(comment, GBReplace(@"abstract\n\n@id text\n@id continuation"));
//				// execute
//				[task processComment:comment];
//				// verify
//				GBAbstract.sourceString should equal(@"abstract");
//				[GBAbstract class] should equal([CommentComponentInfo class]);
//				GBDiscussion.sectionComponents.count should equal(1);
//				[GBDiscussion.sectionComponents[0] sourceString] should equal(GBReplace(@"@id text\n@id continuation"));
//				[GBDiscussion.sectionComponents[0] class] should equal(GBClass());
//			});
//		});
//		
//		it(@"should start new paragraph if delimited by empty line", ^{
//			runWithTask(^(RegisterCommentComponentsTask *task, id comment) {
//				// setup
//				setupComment(comment, GBReplace(@"abstract\n\nparagraph\n\n@id text"));
//				// execute
//				[task processComment:comment];
//				// verify
//				GBAbstract.sourceString should equal(@"abstract");
//				[GBAbstract class] should equal([CommentComponentInfo class]);
//				GBDiscussion.sectionComponents.count should equal(2);
//				[GBDiscussion.sectionComponents[0] sourceString] should equal(@"paragraph");
//				[GBDiscussion.sectionComponents[1] sourceString] should equal(GBReplace(@"@id text"));
//				[GBDiscussion.sectionComponents[1] class] should equal(GBClass());
//			});
//		});
//
//		it(@"should take all subsequent paragraphs as part of section", ^{
//			runWithTask(^(RegisterCommentComponentsTask *task, id comment) {
//				// setup
//				setupComment(comment, GBReplace(@"abstract\n\nparagraph\n\n@id text\n\nnext paragraph"));
//				// execute
//				[task processComment:comment];
//				// verify
//				GBAbstract.sourceString should equal(@"abstract");
//				[GBAbstract class] should equal([CommentComponentInfo class]);
//				GBDiscussion.sectionComponents.count should equal(2);
//				[GBDiscussion.sectionComponents[0] sourceString] should equal(@"paragraph");
//				[GBDiscussion.sectionComponents[1] sourceString] should equal(GBReplace(@"@id text\n\nnext paragraph"));
//				[GBDiscussion.sectionComponents[1] class] should equal(GBClass());
//			});
//		});
//
//		it(@"should start new paragraph with next section directive", ^{
//			runWithTask(^(RegisterCommentComponentsTask *task, id comment) {
//				// setup
//				setupComment(comment, GBReplace(@"abstract\n\n@id first\n\n@id second"));
//				// execute
//				[task processComment:comment];
//				// verify
//				GBAbstract.sourceString should equal(@"abstract");
//				[GBAbstract class] should equal([CommentComponentInfo class]);
//				GBDiscussion.sectionComponents.count should equal(2);
//				[GBDiscussion.sectionComponents[0] sourceString] should equal(GBReplace(@"@id first"));
//				[GBDiscussion.sectionComponents[1] sourceString] should equal(GBReplace(@"@id second"));
//				[GBDiscussion.sectionComponents[0] class] should equal(GBClass());
//				[GBDiscussion.sectionComponents[1] class] should equal(GBClass());
//			});
//		});
//	});
//	
//	describe(@"@warning:", ^{
//		beforeEach(^{
//			[[SpecHelper specHelper] sharedExampleContext][@"id"] = @"@warning";
//			[[SpecHelper specHelper] sharedExampleContext][@"type"] = [CommentWarningComponentInfo class];
//		});
//		itShouldBehaveLike(@"as part of abstract");
//		itShouldBehaveLike(@"as part of discussion");
//	});
//	
//	describe(@"@bug:", ^{
//		beforeEach(^{
//			[[SpecHelper specHelper] sharedExampleContext][@"id"] = @"@bug";
//			[[SpecHelper specHelper] sharedExampleContext][@"type"] = [CommentBugComponentInfo class];
//		});
//		itShouldBehaveLike(@"as part of abstract");
//		itShouldBehaveLike(@"as part of discussion");
//	});
//});
//
//describe(@"method parameters:", ^{
//#define GBParameters ((NSArray *)[comment commentParameters])
//#define GBParameter(i) GBParameters[i]
//#define GBComponent(i,n) [GBParameters[i] sectionComponents][n]
//	it(@"should register single parameter:", ^{
//		runWithTask(^(RegisterCommentComponentsTask *task, id comment) {
//			// setup
//			setupComment(comment, @"abstract\n\n@param name description");
//			// execute
//			[task processComment:comment];
//			// verify
//			GBAbstract.sourceString should equal(@"abstract");
//			[GBAbstract class] should equal([CommentComponentInfo class]);
//			GBParameters.count should equal(1);
//			[GBParameter(0) sectionName] should equal(@"name");
//			[GBParameter(0) sectionComponents].count should equal(1);
//			[GBComponent(0,0) sourceString] should equal(@"description");
//			[GBComponent(0,0) class] should equal([CommentComponentInfo class]);
//		});
//	});
//	
//	it(@"should register multiple parameters:", ^{
//		runWithTask(^(RegisterCommentComponentsTask *task, id comment) {
//			// setup
//			setupComment(comment, @"abstract\n\n@param name1 description 1\n@param name2 description 2");
//			// execute
//			[task processComment:comment];
//			// verify
//			GBAbstract.sourceString should equal(@"abstract");
//			[GBAbstract class] should equal([CommentComponentInfo class]);
//			GBParameters.count should equal(2);
//			[GBParameter(0) sectionName] should equal(@"name1");
//			[GBParameter(0) sectionComponents].count should equal(1);
//			[GBComponent(0,0) sourceString] should equal(@"description 1");
//			[GBComponent(0,0) class] should equal([CommentComponentInfo class]);
//			[GBParameter(1) sectionName] should equal(@"name2");
//			[GBParameter(1) sectionComponents].count should equal(1);
//			[GBComponent(1,0) sourceString] should equal(@"description 2");
//			[GBComponent(1,0) class] should equal([CommentComponentInfo class]);
//		});
//	});
//	
//	it(@"should take all paragraphs following directive as part of directive:", ^{
//		runWithTask(^(RegisterCommentComponentsTask *task, id comment) {
//			// setup
//			setupComment(comment, @"abstract\n\n@param name1 description1\nin multiple\n\nlines and paragraphs\n\n@param name2 description 2");
//			// execute
//			[task processComment:comment];
//			// verify
//			GBAbstract.sourceString should equal(@"abstract");
//			[GBAbstract class] should equal([CommentComponentInfo class]);
//			GBParameters.count should equal(2);
//			[GBParameter(0) sectionName] should equal(@"name1");
//			[GBParameter(0) sectionComponents].count should equal(1);
//			[GBComponent(0,0) sourceString] should equal(@"description1\nin multiple\n\nlines and paragraphs");
//			[GBComponent(0,0) class] should equal([CommentComponentInfo class]);
//			[GBParameter(1) sectionName] should equal(@"name2");
//			[GBParameter(1) sectionComponents].count should equal(1);
//			[GBComponent(1,0) sourceString] should equal(@"description 2");
//			[GBComponent(1,0) class] should equal([CommentComponentInfo class]);
//		});
//	});
//});
//
//describe(@"method exceptions:", ^{
//#define GBExceptions ((NSArray *)[comment commentExceptions])
//#define GBException(i) GBExceptions[i]
//#define GBComponent(i,n) [GBExceptions[i] sectionComponents][n]
//	it(@"should register single exception:", ^{
//		runWithTask(^(RegisterCommentComponentsTask *task, id comment) {
//			// setup
//			setupComment(comment, @"abstract\n\n@exception name description");
//			// execute
//			[task processComment:comment];
//			// verify
//			GBAbstract.sourceString should equal(@"abstract");
//			[GBAbstract class] should equal([CommentComponentInfo class]);
//			GBExceptions.count should equal(1);
//			[GBException(0) sectionName] should equal(@"name");
//			[GBException(0) sectionComponents].count should equal(1);
//			[GBComponent(0,0) sourceString] should equal(@"description");
//			[GBComponent(0,0) class] should equal([CommentComponentInfo class]);
//		});
//	});
//	
//	it(@"should register multiple exceptions:", ^{
//		runWithTask(^(RegisterCommentComponentsTask *task, id comment) {
//			// setup
//			setupComment(comment, @"abstract\n\n@exception name1 description 1\n@exception name2 description 2");
//			// execute
//			[task processComment:comment];
//			// verify
//			GBAbstract.sourceString should equal(@"abstract");
//			[GBAbstract class] should equal([CommentComponentInfo class]);
//			GBExceptions.count should equal(2);
//			[GBException(0) sectionName] should equal(@"name1");
//			[GBException(0) sectionComponents].count should equal(1);
//			[GBComponent(0,0) sourceString] should equal(@"description 1");
//			[GBComponent(0,0) class] should equal([CommentComponentInfo class]);
//			[GBException(1) sectionName] should equal(@"name2");
//			[GBException(1) sectionComponents].count should equal(1);
//			[GBComponent(1,0) sourceString] should equal(@"description 2");
//			[GBComponent(1,0) class] should equal([CommentComponentInfo class]);
//		});
//	});
//	
//	it(@"should take all paragraphs following directive as part of directive:", ^{
//		runWithTask(^(RegisterCommentComponentsTask *task, id comment) {
//			// setup
//			setupComment(comment, @"abstract\n\n@exception name1 description1\nin multiple\n\nlines and paragraphs\n\n@exception name2 description 2");
//			// execute
//			[task processComment:comment];
//			// verify
//			GBAbstract.sourceString should equal(@"abstract");
//			[GBAbstract class] should equal([CommentComponentInfo class]);
//			GBExceptions.count should equal(2);
//			[GBException(0) sectionName] should equal(@"name1");
//			[GBException(0) sectionComponents].count should equal(1);
//			[GBComponent(0,0) sourceString] should equal(@"description1\nin multiple\n\nlines and paragraphs");
//			[GBComponent(0,0) class] should equal([CommentComponentInfo class]);
//			[GBException(1) sectionName] should equal(@"name2");
//			[GBException(1) sectionComponents].count should equal(1);
//			[GBComponent(1,0) sourceString] should equal(@"description 2");
//			[GBComponent(1,0) class] should equal([CommentComponentInfo class]);
//		});
//	});
//});
//
//describe(@"method return:", ^{
//#define GBReturn ((CommentSectionInfo *)[comment commentReturn])
//	it(@"should register single return:", ^{
//		runWithTask(^(RegisterCommentComponentsTask *task, id comment) {
//			// setup
//			setupComment(comment, @"abstract\n\n@return description");
//			// execute
//			[task processComment:comment];
//			// verify
//			GBAbstract.sourceString should equal(@"abstract");
//			[GBAbstract class] should equal([CommentComponentInfo class]);
//			GBReturn.sectionComponents.count should equal(1);
//			[GBReturn.sectionComponents[0] sourceString] should equal(@"description");
//			[GBReturn.sectionComponents[0] class] should equal([CommentComponentInfo class]);
//		});
//	});
//	
//	it(@"should use last return if multiple found:", ^{
//		runWithTask(^(RegisterCommentComponentsTask *task, id comment) {
//			// setup
//			setupComment(comment, @"abstract\n\n@return description 1\n@return description 2");
//			// execute
//			[task processComment:comment];
//			// verify
//			GBAbstract.sourceString should equal(@"abstract");
//			[GBAbstract class] should equal([CommentComponentInfo class]);
//			GBReturn.sectionComponents.count should equal(1);
//			[GBReturn.sectionComponents[0] sourceString] should equal(@"description 2");
//			[GBReturn.sectionComponents[0] class] should equal([CommentComponentInfo class]);
//		});
//	});
//	
//	it(@"should take all paragraphs following directive as part of directive:", ^{
//		runWithTask(^(RegisterCommentComponentsTask *task, id comment) {
//			// setup
//			setupComment(comment, @"abstract\n\n@return description\nin multiple\n\nlines and paragraphs");
//			// execute
//			[task processComment:comment];
//			// verify
//			GBAbstract.sourceString should equal(@"abstract");
//			[GBAbstract class] should equal([CommentComponentInfo class]);
//			GBReturn.sectionComponents.count should equal(1);
//			[GBReturn.sectionComponents[0] sourceString] should equal(@"description\nin multiple\n\nlines and paragraphs");
//			[GBReturn.sectionComponents[0] class] should equal([CommentComponentInfo class]);
//		});
//	});
//});
//
TEST_END
