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
@property (nonatomic, strong) NSDictionary *localMembersCache;
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

static id mockObject(Class t, NSString *u, NSString *c) {
	id result = mock(t);
	[given([result uniqueObjectID]) willReturn:u];
	[given([result objectCrossRefPathTemplate]) willReturn:c];
	return result;
}

static void runWithDefaultObjects(void(^handler)(DetectCrossReferencesTask *task, id store, id builder)) {
	runWithBuilder(^(DetectCrossReferencesTask *task, id builder) {
		// Setup top level objects cache.
		NSDictionary *toplevel = @{
			@"MyClass":mockObject([InterfaceInfoBase class], @"", @"$CLASSES/MyClass.$EXT"),
			@"MyClass()":mockObject([InterfaceInfoBase class], @"", @"$CATEGORIES/MyClass.$EXT"),
			@"MyClass(MyCategory)":mockObject([InterfaceInfoBase class], @"", @"$CATEGORIES/MyClass(MyCategory).$EXT"),
			@"MyProtocol":mockObject([InterfaceInfoBase class], @"", @"$PROTOCOLS/MyProtocol.$EXT")
		};
		id store = mock([Store class]);
		[given([store topLevelObjectsCache]) willReturn:toplevel];
		
		// Setup remote members cache.
		NSDictionary *members = @{
			@"+[MyClass method:]":mockObject([MethodInfo class], @"", @"$CLASSES/MyClass.$EXT#+method:"),
			@"+[MyClass class:]":mockObject([MethodInfo class], @"", @"$CLASSES/MyClass.$EXT#+class:"),
			@"-[MyClass method:]":mockObject([MethodInfo class], @"", @"$CLASSES/MyClass.$EXT#-method:"),
			@"-[MyClass instance:]":mockObject([MethodInfo class], @"", @"$CLASSES/MyClass.$EXT#-instance:"),
			@"[MyClass property]":mockObject([PropertyInfo class], @"", @"$CLASSES/MyClass.$EXT#property")
		};
		[given([store memberObjectsCache]) willReturn:members];

		// Setup local members cache.
		NSDictionary *locals = @{
			@"+method:":mockObject([MethodInfo class], @"", @"#+method:"),
			@"+class:":mockObject([MethodInfo class], @"", @"#+class:"),
			@"-method:":mockObject([MethodInfo class], @"", @"#-method:"),
			@"-instance:":mockObject([MethodInfo class], @"", @"#-instance:"),
			@"property":mockObject([PropertyInfo class], @"", @"#property")
		};
		task.localMembersCache = locals;
		
		// Setup store and run...
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

describe(@"local members cache:", ^{
	__block id interfaceInfo;
	__block id classMethod;
	__block id instanceMethod;
	__block id property;
	
	beforeEach(^{
		classMethod = mockObject([MethodInfo class], @"method:", @"+method:");
		instanceMethod = mockObject([MethodInfo class], @"method:", @"-method:");
		property = mockObject([PropertyInfo class], @"property", @"property");
		[given([property propertyGetterSelector]) willReturn:@"isProperty"];
		[given([property propertySetterSelector]) willReturn:@"setProperty:"];
		interfaceInfo = mock([InterfaceInfoBase class]);
		[given([interfaceInfo interfaceClassMethods]) willReturn:[@[classMethod] mutableCopy]];
		[given([interfaceInfo interfaceInstanceMethods]) willReturn:[@[instanceMethod] mutableCopy]];
		[given([interfaceInfo interfaceProperties]) willReturn:[@[property] mutableCopy]];
	});
	
	it(@"should initialize cache on first use", ^{
		runWithTask(^(DetectCrossReferencesTask *task, CommentInfo *comment) {
			// setup
			comment.commentAbstract = setupComponent(mock([CommentComponentInfo class]), @"method:");
			task.processingContext = interfaceInfo;
			// execute
			[task processComment:comment];
			// verify
			task.localMembersCache should_not be_nil();
			task.localMembersCache.count should equal(5);
			task.localMembersCache[@"+method:"] should equal(classMethod);
			task.localMembersCache[@"-method:"] should equal(instanceMethod);
			task.localMembersCache[@"property"] should equal(property);
			task.localMembersCache[@"-isProperty"] should equal(property);
			task.localMembersCache[@"-setProperty:"] should equal(property);
		});
	});

	it(@"should re-initialize cache after changing context", ^{
		runWithTask(^(DetectCrossReferencesTask *task, CommentInfo *comment) {
			// setup - assign empty dictionary which will have to be reset when assigning context.
			comment.commentAbstract = setupComponent(mock([CommentComponentInfo class]), @"method:");
			task.localMembersCache = [@{} mutableCopy];
			// execute
			task.processingContext = interfaceInfo;
			[task processComment:comment];
			// verify
			task.localMembersCache should_not be_nil();
			task.localMembersCache.count should equal(5);
		});
	});
});

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
		
		it(@"should detect inside sentence", ^{
			runWithDefaultObjects(^(DetectCrossReferencesTask *task, id store, id builder) {
				// setup
				NSString *text = GBReplace(@"prefix $$\tsuffix");
				// execute
				[task processCrossRefsInString:text toBuilder:builder];
				// verify
				builder should equal(GBReplace(@"prefix [$$](%%)\tsuffix"));
			});
		});
		
		it(@"should detect all references", ^{
			runWithDefaultObjects(^(DetectCrossReferencesTask *task, id store, id builder) {
				// setup
				NSString *text = GBReplace(@"prefix $$ and $$ end");
				// execute
				[task processCrossRefsInString:text toBuilder:builder];
				// verify
				builder should equal(GBReplace(@"prefix [$$](%%) and [$$](%%) end"));
			});
		});
	});

	describe(@"top level objects:", ^{
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
		
		it(@"should detect mixed cases", ^{
			runWithDefaultObjects(^(DetectCrossReferencesTask *task, id store, id builder) {
				// setup
				NSString *text = @"MyClass MyClass() MyClass(MyCategory) MyProtocol";
				// execute
				[task processCrossRefsInString:text toBuilder:builder];
				// verify
				builder should equal(@"[MyClass]($CLASSES/MyClass.$EXT) [MyClass()]($CATEGORIES/MyClass.$EXT) [MyClass(MyCategory)]($CATEGORIES/MyClass(MyCategory).$EXT) [MyProtocol]($PROTOCOLS/MyProtocol.$EXT)");
			});
		});
	});
	
	describe(@"remote members:", ^{		
		describe(@"class methods:", ^{
			describe(@"class methods w/ prefix:", ^{
				beforeEach(^{
					[[SpecHelper specHelper] sharedExampleContext][@"name"] = @"+[MyClass class:]";
					[[SpecHelper specHelper] sharedExampleContext][@"path"] = @"$CLASSES/MyClass.$EXT#+class:";
				});
				itShouldBehaveLike(@"examples");
			});
			
			describe(@"class methods w/o prefix:", ^{
				beforeEach(^{
					[[SpecHelper specHelper] sharedExampleContext][@"name"] = @"[MyClass class:]";
					[[SpecHelper specHelper] sharedExampleContext][@"path"] = @"$CLASSES/MyClass.$EXT#+class:";
				});
				itShouldBehaveLike(@"examples");
			});
		});
		
		describe(@"instance methods:", ^{
			describe(@"instance methods w/ prefix:", ^{
				beforeEach(^{
					[[SpecHelper specHelper] sharedExampleContext][@"name"] = @"-[MyClass instance:]";
					[[SpecHelper specHelper] sharedExampleContext][@"path"] = @"$CLASSES/MyClass.$EXT#-instance:";
				});
				itShouldBehaveLike(@"examples");
			});
			
			describe(@"instance methods w/o prefix:", ^{
				beforeEach(^{
					[[SpecHelper specHelper] sharedExampleContext][@"name"] = @"[MyClass instance:]";
					[[SpecHelper specHelper] sharedExampleContext][@"path"] = @"$CLASSES/MyClass.$EXT#-instance:";
				});
				itShouldBehaveLike(@"examples");
			});
		});

		describe(@"class vs. instance:", ^{
			describe(@"prefers class to instance if no prefix given:", ^{
				beforeEach(^{
					[[SpecHelper specHelper] sharedExampleContext][@"name"] = @"[MyClass method:]";
					[[SpecHelper specHelper] sharedExampleContext][@"path"] = @"$CLASSES/MyClass.$EXT#+method:";
				});
				itShouldBehaveLike(@"examples");
			});

			describe(@"uses class method if prefix given:", ^{
				beforeEach(^{
					[[SpecHelper specHelper] sharedExampleContext][@"name"] = @"+[MyClass method:]";
					[[SpecHelper specHelper] sharedExampleContext][@"path"] = @"$CLASSES/MyClass.$EXT#+method:";
				});
				itShouldBehaveLike(@"examples");
			});

			describe(@"uses instance method if prefix given:", ^{
				beforeEach(^{
					[[SpecHelper specHelper] sharedExampleContext][@"name"] = @"-[MyClass method:]";
					[[SpecHelper specHelper] sharedExampleContext][@"path"] = @"$CLASSES/MyClass.$EXT#-method:";
				});
				itShouldBehaveLike(@"examples");
			});
		});
		
		describe(@"properties:", ^{
			beforeEach(^{
				[[SpecHelper specHelper] sharedExampleContext][@"name"] = @"[MyClass property]";
				[[SpecHelper specHelper] sharedExampleContext][@"path"] = @"$CLASSES/MyClass.$EXT#property";
			});
			itShouldBehaveLike(@"examples");
		});
		
		it(@"should detect mixed cases", ^{
			runWithDefaultObjects(^(DetectCrossReferencesTask *task, id store, id builder) {
				// setup
				NSString *text = @"[MyClass method:] -[MyClass method:] [MyClass class:] [MyClass instance:] [MyClass property]";
				// execute
				[task processCrossRefsInString:text toBuilder:builder];
				// verify
				builder should equal(@"[[MyClass method:]]($CLASSES/MyClass.$EXT#+method:) [-[MyClass method:]]($CLASSES/MyClass.$EXT#-method:) [[MyClass class:]]($CLASSES/MyClass.$EXT#+class:) [[MyClass instance:]]($CLASSES/MyClass.$EXT#-instance:) [[MyClass property]]($CLASSES/MyClass.$EXT#property)");
			});
		});
	});
	
	describe(@"local members:", ^{
		describe(@"class methods:", ^{
			describe(@"class methods w/ prefix:", ^{
				beforeEach(^{
					[[SpecHelper specHelper] sharedExampleContext][@"name"] = @"+class:";
					[[SpecHelper specHelper] sharedExampleContext][@"path"] = @"#+class:";
				});
				itShouldBehaveLike(@"examples");
			});
			
			describe(@"class methods w/o prefix:", ^{
				beforeEach(^{
					[[SpecHelper specHelper] sharedExampleContext][@"name"] = @"class:";
					[[SpecHelper specHelper] sharedExampleContext][@"path"] = @"#+class:";
				});
				itShouldBehaveLike(@"examples");
			});
		});
		
		describe(@"instance methods:", ^{
			describe(@"instance methods w/ prefix:", ^{
				beforeEach(^{
					[[SpecHelper specHelper] sharedExampleContext][@"name"] = @"-instance:";
					[[SpecHelper specHelper] sharedExampleContext][@"path"] = @"#-instance:";
				});
				itShouldBehaveLike(@"examples");
			});
			
			describe(@"instance methods w/o prefix:", ^{
				beforeEach(^{
					[[SpecHelper specHelper] sharedExampleContext][@"name"] = @"instance:";
					[[SpecHelper specHelper] sharedExampleContext][@"path"] = @"#-instance:";
				});
				itShouldBehaveLike(@"examples");
			});
		});
		
		describe(@"class vs. instance:", ^{
			describe(@"prefers class to instance if no prefix given:", ^{
				beforeEach(^{
					[[SpecHelper specHelper] sharedExampleContext][@"name"] = @"method:";
					[[SpecHelper specHelper] sharedExampleContext][@"path"] = @"#+method:";
				});
				itShouldBehaveLike(@"examples");
			});
			
			describe(@"uses class method if prefix given:", ^{
				beforeEach(^{
					[[SpecHelper specHelper] sharedExampleContext][@"name"] = @"+method:";
					[[SpecHelper specHelper] sharedExampleContext][@"path"] = @"#+method:";
				});
				itShouldBehaveLike(@"examples");
			});
			
			describe(@"uses instance method if prefix given:", ^{
				beforeEach(^{
					[[SpecHelper specHelper] sharedExampleContext][@"name"] = @"-method:";
					[[SpecHelper specHelper] sharedExampleContext][@"path"] = @"#-method:";
				});
				itShouldBehaveLike(@"examples");
			});
		});
		
		describe(@"properties:", ^{
			beforeEach(^{
				[[SpecHelper specHelper] sharedExampleContext][@"name"] = @"property";
				[[SpecHelper specHelper] sharedExampleContext][@"path"] = @"#property";
			});
			itShouldBehaveLike(@"examples");
		});
		
		it(@"should detect mixed cases", ^{
			runWithDefaultObjects(^(DetectCrossReferencesTask *task, id store, id builder) {
				// setup
				NSString *text = @"method: -method: class: instance: property";
				// execute
				[task processCrossRefsInString:text toBuilder:builder];
				// verify
				builder should equal(@"[method:](#+method:) [-method:](#-method:) [class:](#+class:) [instance:](#-instance:) [property](#property)");
			});
		});
	});
});

TEST_END
