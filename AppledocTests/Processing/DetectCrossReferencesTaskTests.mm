//
//  DetectCrossReferencesTaskTests.m
//  appledoc
//
//  Created by Tomaz Kragelj on 24/11/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "DetectCrossReferencesTask.h"
#import "TestCaseBase.hh"

@interface DetectCrossReferencesTask (UnitTestingPrivateAPI)
- (void)processCrossRefsInString:(NSString *)string toBuilder:(NSMutableString *)builder;
@end

#pragma mark -

static void runWithTask(void(^handler)(DetectCrossReferencesTask *task, id comment)) {
	DetectCrossReferencesTask *task = [[DetectCrossReferencesTask alloc] init];
	CommentInfo *comment = [[CommentInfo alloc] init];
	handler(task, comment);
	[task release];
}

static void runWithBuilder(void(^handler)(DetectCrossReferencesTask *task, id builder)) {
	DetectCrossReferencesTask *task = [[DetectCrossReferencesTask alloc] init];
	NSMutableString *builder = [@"" mutableCopy];
	handler(task, builder);
	[task release];
}

static void runWithDefaultObjects(void(^handler)(DetectCrossReferencesTask *task, id store, id builder)) {
#define GBObject(o,t,c) id o = mock([t class]); [given([o objectCrossRefPathTemplate]) willReturn:c]
	runWithBuilder(^(DetectCrossReferencesTask *task, id builder) {
		id store = mock([Store class]);
		GBObject(classInfo, InterfaceInfoBase, @"$CLASSES/MyClass.$EXT");
		GBObject(extensionInfo, InterfaceInfoBase, @"$CATEGORIES/MyClass.$EXT");
		GBObject(categoryInfo, InterfaceInfoBase, @"$CATEGORIES/MyClass(MyCategory).$EXT");
		GBObject(protocolInfo, InterfaceInfoBase, @"$PROTOCOLS/MyProtocol.$EXT");
		NSDictionary *toplevel = @{ @"MyClass":classInfo, @"MyClass()":extensionInfo, @"MyClass(MyCategory)":categoryInfo, @"MyProtocol":protocolInfo };
		[given([store topLevelObjectsCache]) willReturn:toplevel];
		GBObject(classMethod, MethodInfo, @"");
		GBObject(instanceMethod, MethodInfo, @"");
		GBObject(property, PropertyInfo, @"");
		NSDictionary *members = @{ @"+[MyClass method:]":classMethod, @"-[MyClass method:]":instanceMethod, @"[MyClass method]":property };
		[given([store memberObjectsCache]) willReturn:members];
		task.store = store;
		handler(task, store, builder);
	});
}

static id setupComponent(id component, NSString *string) {
	if ([component isKindOfClass:[CommentComponentInfo class]])
		[component setSourceString:string];
	else
		[given([component sourceString]) willReturn:string];
	return component;
}

static id setupSection(id section, NSString *first ...) {
	va_list args;
	va_start(args, first);
	NSMutableArray *components = [@[] mutableCopy];
	for (NSString *arg=first; arg!=nil; arg=va_arg(args, NSString *)) {
		id component = mock([CommentComponentInfo class]);
		setupComponent(component, arg);
		[components addObject:component];
	}
	va_end(args);
	if ([section isKindOfClass:[CommentSectionInfo class]])
		[section setSectionComponents:components];
	else
		[given([section sectionComponents]) willReturn:components];
	return section;
}

#pragma mark -

TEST_BEGIN(DetectCrossReferencesTaskTests)

describe(@"comment components processing:", ^{
	it(@"should process all components", ^{
		runWithTask(^(DetectCrossReferencesTask *task, CommentInfo *comment) {
			// setup
			comment.commentAbstract = setupComponent(mock([CommentComponentInfo class]), @"");
			comment.commentDiscussion = setupSection(mock([CommentSectionInfo class]), @"", nil);
			comment.commentParameters = mock([NSMutableArray class]);
			comment.commentExceptions = mock([NSMutableArray class]);
			comment.commentReturn = setupSection(mock([CommentSectionInfo class]), @"", nil);
			// execute
			[task processComment:comment];
			// verify
			gbcatch([verify(comment.commentAbstract) sourceString]);
			gbcatch([verify(comment.commentDiscussion) sectionComponents]);
			gbcatch([verify(comment.commentParameters) enumerateObjectsUsingBlock:(id)anything()]);
			gbcatch([verify(comment.commentExceptions) enumerateObjectsUsingBlock:(id)anything()]);
			gbcatch([verify(comment.commentReturn) sectionComponents]);
		});
	});
});

describe(@"markdown links:", ^{
	it(@"should handle simple link only string", ^{
		runWithBuilder(^(DetectCrossReferencesTask *task, id builder) {
			// execute
			[task processCrossRefsInString:@"[text](path)" toBuilder:builder];
			// verify
			builder should equal(@"[text](path)");
		});
	});
	
	it(@"should keep prefix and suffix", ^{
		runWithBuilder(^(DetectCrossReferencesTask *task, id builder) {
			// execute
			[task processCrossRefsInString:@"prefix [text](path) suffix" toBuilder:builder];
			// verify
			builder should equal(@"prefix [text](path) suffix");
		});
	});
});

describe(@"unrecognized cross references:", ^{
	describe(@"remote member crossrefs:", ^{
		it(@"should keep unrecognized crossref", ^{
			runWithBuilder(^(DetectCrossReferencesTask *task, id builder) {
				// execute
				[task processCrossRefsInString:@"prefix [class member:method:] suffix" toBuilder:builder];
				// verify
				builder should equal(@"prefix [class member:method:] suffix");
			});
		});

		it(@"should keep unrecognized crossref for instance method", ^{
			runWithBuilder(^(DetectCrossReferencesTask *task, id builder) {
				// execute
				[task processCrossRefsInString:@"prefix -[class member:method:] suffix" toBuilder:builder];
				// verify
				builder should equal(@"prefix -[class member:method:] suffix");
			});
		});

		it(@"should keep unrecognized crossref for class method", ^{
			runWithBuilder(^(DetectCrossReferencesTask *task, id builder) {
				// execute
				[task processCrossRefsInString:@"prefix +[class member:method:] suffix" toBuilder:builder];
				// verify
				builder should equal(@"prefix +[class member:method:] suffix");
			});
		});
		
		it(@"should keep unrecognized crossref for property", ^{
			runWithBuilder(^(DetectCrossReferencesTask *task, id builder) {
				// execute
				[task processCrossRefsInString:@"prefix +[class property] suffix" toBuilder:builder];
				// verify
				builder should equal(@"prefix +[class property] suffix");
			});
		});
	});
});

describe(@"recognized cross references:", ^{
#define GBReplace(t) [t gb_stringByReplacing:@{ @"$$":info[@"name"], @"%%":info[@"path"] }]
	describe(@"top level objects:", ^{
		sharedExamplesFor(@"examples", ^(NSDictionary *info) {
			it(@"should detect as only word", ^{
				runWithDefaultObjects(^(DetectCrossReferencesTask *task, id store, id builder) {
					// setup
					NSString *text = GBReplace(@"$$");
					// execute
					[task processCrossRefsInString:text toBuilder:builder];
					// verify
					builder should equal(GBReplace(@"[$$](%%)"));
				});
			});
		});
		
		describe(@"classes:", ^{
			beforeEach(^{
				[[SpecHelper specHelper] sharedExampleContext][@"name"] = @"MyClass";
				[[SpecHelper specHelper] sharedExampleContext][@"path"] = @"$CLASSES/MyClass.$EXT";
			});
			itShouldBehaveLike(@"examples");
		});
		
		describe(@"extensions:", ^{
			beforeEach(^{
				[[SpecHelper specHelper] sharedExampleContext][@"name"] = @"MyClass()";
				[[SpecHelper specHelper] sharedExampleContext][@"path"] = @"$CATEGORIES/MyClass.$EXT";
			});
			itShouldBehaveLike(@"examples");
		});
		
		describe(@"categories:", ^{
			beforeEach(^{
				[[SpecHelper specHelper] sharedExampleContext][@"name"] = @"MyClass(MyCategory)";
				[[SpecHelper specHelper] sharedExampleContext][@"path"] = @"$CATEGORIES/MyClass(MyCategory).$EXT";
			});
			itShouldBehaveLike(@"examples");
		});
		
		describe(@"protocols:", ^{
			beforeEach(^{
				[[SpecHelper specHelper] sharedExampleContext][@"name"] = @"MyProtocol";
				[[SpecHelper specHelper] sharedExampleContext][@"path"] = @"$PROTOCOLS/MyProtocol.$EXT";
			});
			itShouldBehaveLike(@"examples");
		});
	});
});

TEST_END
