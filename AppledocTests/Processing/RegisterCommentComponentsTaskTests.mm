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
#define GBDiscussion() [comment commentDiscussion]

#define GBParametersCount(c) [[comment commentParameters] count] should equal(c);
#define GBParameter(i) [comment commentParameters][i]

#define GBExceptionsCount(c) [[comment commentExceptions] count] should equal(c);
#define GBException(i) [comment commentExceptions][i]

#define GBReturnCount(c) [[[comment commentReturn] sectionComponents] count] should equal(c)
#define GBReturn() [comment commentReturn]

#define GBSectionName(p,n) [p sectionName] should equal(n);
#define GBSectionComponentsCount(p,c) [[p sectionComponents] count] should equal(c)
#define GBSectionComponent(p,i,t,c) \
	[[p sectionComponents][i] sourceString] should equal(t); \
	[[p sectionComponents][i] class] should equal([c class])

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
			GBSectionComponent(GBDiscussion(), 0, @"section 2", CommentComponentInfo);
			GBSectionComponent(GBDiscussion(), 1, @"section 3", CommentComponentInfo);
			GBMethodSectionsEmpty();
		});
	});
});

describe(@"code blocks:", ^{
#define GBReplace(t) [t gb_stringByReplacing:@{ @"[": info[@"start"], @"]": info[@"end"], @"--": info[@"marker"] }]
	sharedExamplesFor(@"code block", ^(NSDictionary *info) {
		it(@"should append section to previous paragraph", ^{
			runWithTask(^(RegisterCommentComponentsTask *task, id comment) {
				// setup
				setupComment(comment, @"abstract", @"normal line", GBReplace(@"[--code line]"), nil);
				// execute
				[task processComment:comment];
				// verify
				GBAbstract(@"abstract", CommentComponentInfo);
				GBDiscussionsCount(2);
				GBSectionComponent(GBDiscussion(), 0, @"normal line", CommentComponentInfo);
				GBSectionComponent(GBDiscussion(), 1, GBReplace(@"[--code line]"), CommentCodeBlockComponentInfo);
				GBMethodSectionsEmpty();
			});
		});

		it(@"should append all sections to previous paragraph", ^{
			runWithTask(^(RegisterCommentComponentsTask *task, id comment) {
				// setup
				setupComment(comment, @"abstract", @"normal line", GBReplace(@"[--code section 1]"), GBReplace(@"[--code section 2]"), nil);
				// execute
				[task processComment:comment];
				// verify
				GBAbstract(@"abstract", CommentComponentInfo);
				GBDiscussionsCount(3);
				GBSectionComponent(GBDiscussion(), 0, @"normal line", CommentComponentInfo);
				GBSectionComponent(GBDiscussion(), 1, GBReplace(@"[--code section 1]"), CommentCodeBlockComponentInfo);
				GBSectionComponent(GBDiscussion(), 2, GBReplace(@"[--code section 2]"), CommentCodeBlockComponentInfo);
				GBMethodSectionsEmpty();
			});
		});
		
		it(@"should append mixed sections to previous paragraph", ^{
			runWithTask(^(RegisterCommentComponentsTask *task, id comment) {
				// setup
				setupComment(comment, @"abstract", @"normal line 1", GBReplace(@"[--code section 1]"), @"normal line 2", GBReplace(@"[--code section 2]"), nil);
				// execute
				[task processComment:comment];
				// verify
				GBAbstract(@"abstract", CommentComponentInfo);
				GBDiscussionsCount(4);
				GBSectionComponent(GBDiscussion(), 0, @"normal line 1", CommentComponentInfo);
				GBSectionComponent(GBDiscussion(), 1, GBReplace(@"[--code section 1]"), CommentCodeBlockComponentInfo);
				GBSectionComponent(GBDiscussion(), 2, @"normal line 2", CommentComponentInfo);
				GBSectionComponent(GBDiscussion(), 3, GBReplace(@"[--code section 2]"), CommentCodeBlockComponentInfo);
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

describe(@"warnings and bugs:", ^{
#define GBReplace(t) [t gb_stringByReplacing:@{ @"@id": info[@"id"] }]
#define GBComponentType info[@"type"]
	sharedExamplesFor(@"warning or bug", ^(NSDictionary *info) {
		it(@"should take section as abstract", ^{
			runWithTask(^(RegisterCommentComponentsTask *task, id comment) {
				// setup
				setupComment(comment, GBReplace(@"@id text"), nil);
				// execute
				[task processComment:comment];
				// verify
				GBAbstract(GBReplace(@"@id text"), GBComponentType);
				GBDiscussionsCount(0);
				GBMethodSectionsEmpty();
			});
		});
		
		it(@"should take section as single paragraph", ^{
			runWithTask(^(RegisterCommentComponentsTask *task, id comment) {
				// setup
				setupComment(comment, @"abstract", GBReplace(@"@id text"), nil);
				// execute
				[task processComment:comment];
				// verify
				GBAbstract(@"abstract", CommentComponentInfo);
				GBDiscussionsCount(1);
				GBSectionComponent(GBDiscussion(), 0, GBReplace(@"@id text"), GBComponentType);
				GBMethodSectionsEmpty();
			});
		});

		it(@"should append section to previous paragraph", ^{
			runWithTask(^(RegisterCommentComponentsTask *task, id comment) {
				// setup
				setupComment(comment, @"abstract", @"normal line", GBReplace(@"@id text"), nil);
				// execute
				[task processComment:comment];
				// verify
				GBAbstract(@"abstract", CommentComponentInfo);
				GBDiscussionsCount(2);
				GBSectionComponent(GBDiscussion(), 0, @"normal line", CommentComponentInfo);
				GBSectionComponent(GBDiscussion(), 1, GBReplace(@"@id text"), GBComponentType);
				GBMethodSectionsEmpty();
			});
		});		
		
		it(@"should append sections to previous paragraph", ^{
			runWithTask(^(RegisterCommentComponentsTask *task, id comment) {
				// setup
				setupComment(comment, @"abstract", @"normal line 1", GBReplace(@"@id text 1"), @"normal line 2", GBReplace(@"@id text 2"), nil);
				// execute
				[task processComment:comment];
				// verify
				GBAbstract(@"abstract", CommentComponentInfo);
				GBDiscussionsCount(4);
				GBSectionComponent(GBDiscussion(), 0, @"normal line 1", CommentComponentInfo);
				GBSectionComponent(GBDiscussion(), 1, GBReplace(@"@id text 1"), GBComponentType);
				GBSectionComponent(GBDiscussion(), 2, @"normal line 2", CommentComponentInfo);
				GBSectionComponent(GBDiscussion(), 3, GBReplace(@"@id text 2"), GBComponentType);
				GBMethodSectionsEmpty();
			});
		});
	});
	
	describe(@"@warning:", ^{
		beforeEach(^{
			[[SpecHelper specHelper] sharedExampleContext][@"id"] = @"@warning";
			[[SpecHelper specHelper] sharedExampleContext][@"type"] = [CommentWarningComponentInfo class];
		});
		itShouldBehaveLike(@"warning or bug");
	});
	
	describe(@"@bug:", ^{
		beforeEach(^{
			[[SpecHelper specHelper] sharedExampleContext][@"id"] = @"@bug";
			[[SpecHelper specHelper] sharedExampleContext][@"type"] = [CommentBugComponentInfo class];
		});
		itShouldBehaveLike(@"warning or bug");
	});
});

describe(@"method parameters:", ^{
	it(@"should register single parameter", ^{
		runWithTask(^(RegisterCommentComponentsTask *task, id comment) {
			// setup
			setupComment(comment, @"abstract", @"@param name description", nil);
			// execute
			[task processComment:comment];
			// verify
			GBAbstract(@"abstract", CommentComponentInfo);
			GBParametersCount(1);
			GBSectionName(GBParameter(0), @"name");
			GBSectionComponentsCount(GBParameter(0), 1);
			GBSectionComponent(GBParameter(0), 0, @"description", CommentComponentInfo);
			GBDiscussionsCount(0);
			GBExceptionsCount(0);
			GBReturnCount(0);
		});
	});

	it(@"should register multiple parameter", ^{
		runWithTask(^(RegisterCommentComponentsTask *task, id comment) {
			// setup
			setupComment(comment, @"abstract", @"@param name1 description 1", @"@param name2 description 2", nil);
			// execute
			[task processComment:comment];
			// verify
			GBAbstract(@"abstract", CommentComponentInfo);
			GBParametersCount(2);
			GBSectionName(GBParameter(0), @"name1");
			GBSectionName(GBParameter(1), @"name2");
			GBSectionComponentsCount(GBParameter(0), 1);
			GBSectionComponent(GBParameter(0), 0, @"description 1", CommentComponentInfo);
			GBSectionComponentsCount(GBParameter(1), 1);
			GBSectionComponent(GBParameter(1), 0, @"description 2", CommentComponentInfo);
			GBDiscussionsCount(0);
			GBExceptionsCount(0);
			GBReturnCount(0);
		});
	});
	
	it(@"should append normal paragraph to previous parameter", ^{
		runWithTask(^(RegisterCommentComponentsTask *task, id comment) {
			// setup
			setupComment(comment, @"abstract", @"@param name1 description 1", @"subsequent paragraph", @"@param name2 description 2", nil);
			// execute
			[task processComment:comment];
			// verify
			GBAbstract(@"abstract", CommentComponentInfo);
			GBParametersCount(2);
			GBSectionName(GBParameter(0), @"name1");
			GBSectionName(GBParameter(1), @"name2");
			GBSectionComponentsCount(GBParameter(0), 2);
			GBSectionComponent(GBParameter(0), 0, @"description 1", CommentComponentInfo);
			GBSectionComponent(GBParameter(0), 1, @"subsequent paragraph", CommentComponentInfo);
			GBSectionComponentsCount(GBParameter(1), 1);
			GBSectionComponent(GBParameter(1), 0, @"description 2", CommentComponentInfo);
			GBDiscussionsCount(0);
			GBExceptionsCount(0);
			GBReturnCount(0);
		});
	});
});

describe(@"method exceptions:", ^{
	it(@"should register single exception", ^{
		runWithTask(^(RegisterCommentComponentsTask *task, id comment) {
			// setup
			setupComment(comment, @"abstract", @"@exception name description", nil);
			// execute
			[task processComment:comment];
			// verify
			GBAbstract(@"abstract", CommentComponentInfo);
			GBExceptionsCount(1);
			GBSectionName(GBException(0), @"name");
			GBSectionComponentsCount(GBException(0), 1);
			GBSectionComponent(GBException(0), 0, @"description", CommentComponentInfo);
			GBDiscussionsCount(0);
			GBParametersCount(0);
			GBReturnCount(0);
		});
	});
	
	it(@"should register multiple exception", ^{
		runWithTask(^(RegisterCommentComponentsTask *task, id comment) {
			// setup
			setupComment(comment, @"abstract", @"@exception name1 description 1", @"@exception name2 description 2", nil);
			// execute
			[task processComment:comment];
			// verify
			GBAbstract(@"abstract", CommentComponentInfo);
			GBExceptionsCount(2);
			GBSectionName(GBException(0), @"name1");
			GBSectionName(GBException(1), @"name2");
			GBSectionComponentsCount(GBException(0), 1);
			GBSectionComponent(GBException(0), 0, @"description 1", CommentComponentInfo);
			GBSectionComponentsCount(GBException(1), 1);
			GBSectionComponent(GBException(1), 0, @"description 2", CommentComponentInfo);
			GBDiscussionsCount(0);
			GBParametersCount(0);
			GBReturnCount(0);
		});
	});
	
	it(@"should append normal paragraph to previous exception", ^{
		runWithTask(^(RegisterCommentComponentsTask *task, id comment) {
			// setup
			setupComment(comment, @"abstract", @"@exception name1 description 1", @"subsequent paragraph", @"@exception name2 description 2", nil);
			// execute
			[task processComment:comment];
			// verify
			GBAbstract(@"abstract", CommentComponentInfo);
			GBExceptionsCount(2);
			GBSectionName(GBException(0), @"name1");
			GBSectionName(GBException(1), @"name2");
			GBSectionComponentsCount(GBException(0), 2);
			GBSectionComponent(GBException(0), 0, @"description 1", CommentComponentInfo);
			GBSectionComponent(GBException(0), 1, @"subsequent paragraph", CommentComponentInfo);
			GBSectionComponentsCount(GBException(1), 1);
			GBSectionComponent(GBException(1), 0, @"description 2", CommentComponentInfo);
			GBDiscussionsCount(0);
			GBParametersCount(0);
			GBReturnCount(0);
		});
	});
});

describe(@"method result:", ^{
	it(@"should register return", ^{
		runWithTask(^(RegisterCommentComponentsTask *task, id comment) {
			// setup
			setupComment(comment, @"abstract", @"@return description", nil);
			// execute
			[task processComment:comment];
			// verify
			GBAbstract(@"abstract", CommentComponentInfo);
			GBSectionComponentsCount(GBReturn(), 1);
			GBSectionComponent(GBReturn(), 0, @"description", CommentComponentInfo);
			GBDiscussionsCount(0);
			GBParametersCount(0);
			GBExceptionsCount(0);
		});
	});
	
	it(@"should register last return only", ^{
		runWithTask(^(RegisterCommentComponentsTask *task, id comment) {
			// setup
			setupComment(comment, @"abstract", @"@return description 1", @"@return description 2", nil);
			// execute
			[task processComment:comment];
			// verify
			GBAbstract(@"abstract", CommentComponentInfo);
			GBSectionComponentsCount(GBReturn(), 1);
			GBSectionComponent(GBReturn(), 0, @"description 2", CommentComponentInfo);
			GBDiscussionsCount(0);
			GBParametersCount(0);
			GBExceptionsCount(0);
		});
	});
	
	it(@"should append normal paragraph to previous return", ^{
		runWithTask(^(RegisterCommentComponentsTask *task, id comment) {
			// setup
			setupComment(comment, @"abstract", @"@return description", @"subsequent paragraph", nil);
			// execute
			[task processComment:comment];
			// verify
			GBAbstract(@"abstract", CommentComponentInfo);
			GBSectionComponentsCount(GBReturn(), 2);
			GBSectionComponent(GBReturn(), 0, @"description", CommentComponentInfo);
			GBSectionComponent(GBReturn(), 1, @"subsequent paragraph", CommentComponentInfo);
			GBDiscussionsCount(0);
			GBParametersCount(0);
			GBExceptionsCount(0);
		});
	});
});

TEST_END
