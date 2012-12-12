//
//  ProcessorTests.m
//  appledoc
//
//  Created by Tomaz Kragelj on 8/11/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "Processor.h"
#import "TestCaseBase.hh"

static void runWithProcessor(BOOL mockedTasks, void(^handler)(Processor *processor)) {
	Processor *processor = [[Processor alloc] init];
	if (mockedTasks) {
		processor.linkKnownObjectsTask = mock([ProcessorTask class]);
		processor.mergeKnownObjectsTask = mock([ProcessorTask class]);
		processor.fetchDocumentationTask = mock([ProcessorTask class]);
	}
	handler(processor);
	[processor release];
}

static void runWithProcessor(void(^handler)(Processor *processor)) {
	runWithProcessor(NO, handler);
}

#pragma mark -

@interface Processor (UnitTestingPrivateAPI)
- (NSInteger)processCommentForObject:(ObjectInfoBase *)object context:(ObjectInfoBase *)parent;
@property (nonatomic, strong) Store *store;
@property (nonatomic, strong) GBSettings *settings;
@end

#pragma mark -

TEST_BEGIN(ProcessorTests)

describe(@"lazy accessors:", ^{
	sharedExamplesFor(@"tasks", ^(NSDictionary *info) {
		it(@"should initialize task", ^{
			runWithProcessor(^(Processor *processor) {
				// setup
				processor.store = mock([Store class]);
				processor.settings = mock([GBSettings class]);
				// execute
				ProcessorTask *task = [processor valueForKey:info[@"task"]];
				// verify
				task should_not be_nil();
				[task store] should equal(processor.store);
				[task settings] should equal(processor.settings);
			});
		});
	});
	
	describe(@"link known objects task:", ^{
		beforeEach(^{
			[[SpecHelper specHelper] sharedExampleContext][@"task"] = @"linkKnownObjectsTask";
		});
		itShouldBehaveLike(@"tasks");
	});
	
	describe(@"merge known objects task:", ^{
		beforeEach(^{
			[[SpecHelper specHelper] sharedExampleContext][@"task"] = @"mergeKnownObjectsTask";
		});
		itShouldBehaveLike(@"tasks");
	});
	
	describe(@"fetch documentation task:", ^{
		beforeEach(^{
			[[SpecHelper specHelper] sharedExampleContext][@"task"] = @"fetchDocumentationTask";
		});
		itShouldBehaveLike(@"tasks");
	});
	
	describe(@"split comment to sections task:", ^{
		beforeEach(^{
			[[SpecHelper specHelper] sharedExampleContext][@"task"] = @"splitCommentToSectionsTask";
		});
		itShouldBehaveLike(@"tasks");
	});
	
	describe(@"register comment components task:", ^{
		beforeEach(^{
			[[SpecHelper specHelper] sharedExampleContext][@"task"] = @"registerCommentComponentsTask";
		});
		itShouldBehaveLike(@"tasks");
	});
	
	describe(@"detect cross references task:", ^{
		beforeEach(^{
			[[SpecHelper specHelper] sharedExampleContext][@"task"] = @"detectCrossReferencesTask";
		});
		itShouldBehaveLike(@"tasks");
	});
});

describe(@"objects processing:", ^{
	it(@"should invoke link known objects task", ^{
		runWithProcessor(^(Processor *processor) {
			// setup
			id settings = mock([GBSettings class]);
			id store = mock([Store class]);
			id task = mock([ProcessorTask class]);
			processor.linkKnownObjectsTask = task;
			// execute
			[processor runWithSettings:settings store:store];
			// verify
			gbcatch([verify(task) runTask]);
		});
	});
	
	it(@"should invoke merge known objects task", ^{
		runWithProcessor(^(Processor *processor) {
			// setup
			id settings = mock([GBSettings class]);
			id store = mock([Store class]);
			id task = mock([ProcessorTask class]);
			processor.mergeKnownObjectsTask = task;
			// execute
			[processor runWithSettings:settings store:store];
			// verify
			gbcatch([verify(task) runTask]);
		});
	});
	
	it(@"should invoke fetch documentation task", ^{
		runWithProcessor(^(Processor *processor) {
			// setup
			id settings = mock([GBSettings class]);
			id store = mock([Store class]);
			id task = mock([ProcessorTask class]);
			processor.fetchDocumentationTask = task;
			// execute
			[processor runWithSettings:settings store:store];
			// verify
			gbcatch([verify(task) runTask]);
		});
	});
});

describe(@"comment processing:", ^{
	describe(@"processing comments:", ^{
		__block id context;
		__block id object;
		__block id comment;
		__block id componentsTask;
		
		beforeEach(^{
			comment = [[CommentInfo alloc] init];
			context = mock([ObjectInfoBase class]);
			object = mock([ObjectInfoBase class]);
			componentsTask = mock([ProcessorCommentTask class]);
		});
		
		it(@"should invoke split comment to sections task if comment given", ^{
			runWithProcessor(^(Processor *processor) {
				// setup
				[given([object comment]) willReturn:comment];
				processor.splitCommentToSectionsTask = componentsTask;
				// execute
				[processor processCommentForObject:object context:context];
				// verify
				gbcatch([verify(componentsTask) processCommentForObject:object context:context]);
			});
		});

		it(@"should invoke register comment components task if comment given", ^{
			runWithProcessor(^(Processor *processor) {
				// setup
				[given([object comment]) willReturn:comment];
				processor.registerCommentComponentsTask = componentsTask;
				// execute
				[processor processCommentForObject:object context:context];
				// verify
				gbcatch([verify(componentsTask) processCommentForObject:object context:context]);
			});
		});
		
		it(@"should invoke detect cross references task if comment given", ^{
			runWithProcessor(^(Processor *processor) {
				// setup
				[given([object comment]) willReturn:comment];
				processor.detectCrossReferencesTask = componentsTask;
				// execute
				[processor processCommentForObject:object context:context];
				// verify
				gbcatch([verify(componentsTask) processCommentForObject:object context:context]);
			});
		});
		
		it(@"should ignore all required tasks if comment is not given", ^{
			runWithProcessor(^(Processor *processor) {
				// setup
				[given([object comment]) willReturn:nil];
				processor.splitCommentToSectionsTask = componentsTask;
				// execute
				[processor processCommentForObject:object context:context];
				// verify - we should fail because the method should not be invoked when comment is nil.
				gbfail([verify(componentsTask) processCommentForObject:object context:context]);
			});
		});
	});
});

TEST_END