//
//  FetchDocumentationTaskTests.m
//  appledoc
//
//  Created by Tomaz Kragelj on 7/12/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "StoreMocks.h"
#import "FetchDocumentationTask.h"
#import "TestCaseBase.hh"

#define GBSections [comment sourceSections]

#pragma mark -

static void runWithTask(id store, id settings, void(^handler)(FetchDocumentationTask *task, id store, id settings)) {
	FetchDocumentationTask *task = [[FetchDocumentationTask alloc] init];
	task.settings = settings ? settings : mock([GBSettings class]);
	task.store = store ? store : mock([Store class]);
	handler(task, task.store, task.settings);
	[task release];
}

static void runWithTask(void(^handler)(FetchDocumentationTask *task, id store, id settings)) {
	runWithTask(nil, nil, handler);
}

static id createBaseClass() {
	return [StoreMocks mockClass:@"BaseClass" block:^(id object) { }];
}

static id createDerivedClass(id baseClass) {
	return [StoreMocks mockClass:@"DerivedClass" block:^(id object) {
		[StoreMocks add:object asDerivedClassFrom:baseClass];
	}];
}

static id createAdoptedProtocol(NSString *name, id adoptedInObject) {
	return [StoreMocks mockProtocol:name block:^(id object) {
		[StoreMocks add:adoptedInObject asAdopting:object];
	}];
}

static id createMethod(NSString *selector, id parent) {
	BOOL isClassMethod = [selector hasPrefix:@"+"];
	return [StoreMocks createMethod:selector block:^(MethodInfo *object) {
		if (isClassMethod)
			[StoreMocks add:object asClassMethodOf:parent];
		else
			[StoreMocks add:object asInstanceMethodOf:parent];
	}];
}

static id createCommentedMethod(NSString *selector, id parent) {
	id result = createMethod(selector, parent);
	[StoreMocks addMockCommentTo:result];
	return result;
}

static id createProperty(NSString *name, id parent) {
	return [StoreMocks createProperty:name block:^(PropertyInfo *object) {
		[StoreMocks add:object asPropertyOf:parent];
	}];
}

static id createCommentedProperty(NSString *name, id parent) {
	id result = createProperty(name, parent);
	[StoreMocks addMockCommentTo:result];
	return result;
}

#define GBSearch [info[@"search"] boolValue]
#define GBVerify(d,b) if (GBSearch) d.comment should equal(b.comment); else d.comment should be_nil()

#pragma mark -

TEST_BEGIN(FetchDocumentationTaskTests)

describe(@"copy documentation from super classes:", ^{
	sharedExamplesFor(@"examples", ^(NSDictionary *info) {
		__block id settings;
		
		beforeEach(^{
			settings = mock([GBSettings class]);
			[given([settings searchForMissingComments]) willReturnBool:GBSearch];
		});

		it(@"should handle class method", ^{
			runWithTask(nil, settings, ^(FetchDocumentationTask *task, id store, id settings) {
				// setup
				id baseClass = createBaseClass();
				id derivedClass = createDerivedClass(baseClass);
				MethodInfo *baseMethod = createCommentedMethod(@"+method", baseClass);
				MethodInfo *derivedMethod = createMethod(@"+method", derivedClass);
				[given([store storeClasses]) willReturn:@[ baseClass, derivedClass ]];
				// execute
				[task runTask];
				// verify
				GBVerify(derivedMethod, baseMethod);
			});
		});
		
		it(@"should handle instance method", ^{
			runWithTask(nil, settings, ^(FetchDocumentationTask *task, id store, id settings) {
				// setup
				id baseClass = createBaseClass();
				id derivedClass = createDerivedClass(baseClass);
				MethodInfo *baseMethod = createCommentedMethod(@"-method", baseClass);
				MethodInfo *derivedMethod = createMethod(@"-method", derivedClass);
				[given([store storeClasses]) willReturn:@[ baseClass, derivedClass ]];
				// execute
				[task runTask];
				// verify
				GBVerify(derivedMethod, baseMethod);
			});
		});
		
		it(@"should copy property from base class", ^{
			runWithTask(nil, settings, ^(FetchDocumentationTask *task, id store, id settings) {
				// setup
				id baseClass = createBaseClass();
				id derivedClass = createDerivedClass(baseClass);
				PropertyInfo *baseProperty = createCommentedProperty(@"property", baseClass);
				PropertyInfo *derivedProperty = createProperty(@"property", derivedClass);
				[given([store storeClasses]) willReturn:@[ baseClass, derivedClass ]];
				// execute
				[task runTask];
				// verify
				GBVerify(derivedProperty, baseProperty);
			});
		});
	});
	
	describe(@"search enabled:", ^{
		beforeEach(^{
			[[SpecHelper specHelper] sharedExampleContext][@"search"] = @(YES);
		});
		itShouldBehaveLike(@"examples");
	});
	
	describe(@"search disabled:", ^{
		beforeEach(^{
			[[SpecHelper specHelper] sharedExampleContext][@"search"] = @(NO);
		});
		itShouldBehaveLike(@"examples");
	});
});

describe(@"adopted protocols:", ^{
	// This block describes actual unit tests.
	sharedExamplesFor(@"examples", ^(NSDictionary *info) {
		__block id store;
		__block id settings;
		
		beforeEach(^{
			store = info[@"store"];
			settings = mock([GBSettings class]);
			[given([settings searchForMissingComments]) willReturnBool:GBSearch];
		});
		
		it(@"should fetch for class methods", ^{
			runWithTask(store, settings, ^(FetchDocumentationTask *task, id store, id settings) {
				// setup
				id object = info[@"object"];
				id protocol = createAdoptedProtocol(@"Protocol", object);
				MethodInfo *objectClassMethod = createMethod(@"+method", object);
				ObjectInfoBase *protocolClassMethod = createCommentedMethod(@"+method", protocol);
				// execute
				[task runTask];
				// verify
				GBVerify(objectClassMethod, protocolClassMethod);
			});
		});
		
		it(@"should fetch for instance methods", ^{
			runWithTask(store, settings, ^(FetchDocumentationTask *task, id store, id settings) {
				// setup
				id object = info[@"object"];
				id protocol = createAdoptedProtocol(@"Protocol", object);
				MethodInfo *objectInstanceMethod = createMethod(@"-method", object);
				ObjectInfoBase *protocolInstanceMethod = createCommentedMethod(@"-method", protocol);
				// execute
				[task runTask];
				// verify
				GBVerify(objectInstanceMethod, protocolInstanceMethod);
			});
		});

		it(@"should fetch for properties", ^{
			runWithTask(store, settings, ^(FetchDocumentationTask *task, id store, id settings) {
				// setup
				id object = info[@"object"];
				id protocol = createAdoptedProtocol(@"Protocol", object);
				PropertyInfo *objectProperty = createProperty(@"property", object);
				ObjectInfoBase *protocolProperty = createCommentedProperty(@"property", protocol);
				// execute
				[task runTask];
				// verify
				GBVerify(objectProperty, protocolProperty);
			});
		});
	});
	
	// This block described variants for above tests (repeats the tests for different types of objects).
	sharedExamplesFor(@"variants", ^(NSDictionary *info) {
		describe(@"classes:", ^{
			beforeEach(^{
				id store = mock([Store class]);
				id object = mock([ClassInfo class]);
				[given([store storeClasses]) willReturn:@[ object ]];
				[[SpecHelper specHelper] sharedExampleContext][@"store"] = store;
				[[SpecHelper specHelper] sharedExampleContext][@"object"] = object;
			});
			itShouldBehaveLike(@"examples");
		});
		
		describe(@"extensions:", ^{
			beforeEach(^{
				id store = mock([Store class]);
				id object = mock([CategoryInfo class]);
				[given([store storeExtensions]) willReturn:@[ object ]];
				[[SpecHelper specHelper] sharedExampleContext][@"store"] = store;
				[[SpecHelper specHelper] sharedExampleContext][@"object"] = object;
			});
			itShouldBehaveLike(@"examples");
		});
		
		describe(@"categories:", ^{
			beforeEach(^{
				id store = mock([Store class]);
				id object = mock([CategoryInfo class]);
				[given([store storeCategories]) willReturn:@[ object ]];
				[[SpecHelper specHelper] sharedExampleContext][@"store"] = store;
				[[SpecHelper specHelper] sharedExampleContext][@"object"] = object;
			});
			itShouldBehaveLike(@"examples");
		});
		
		describe(@"protocols:", ^{
			beforeEach(^{
				id store = mock([Store class]);
				id object = mock([ProtocolInfo class]);
				[given([store storeProtocols]) willReturn:@[ object ]];
				[[SpecHelper specHelper] sharedExampleContext][@"store"] = store;
				[[SpecHelper specHelper] sharedExampleContext][@"object"] = object;
			});
			itShouldBehaveLike(@"examples");
		});
	});
	
	// These two blocks repeat all the variants, for all the examples, for search enabled or disabled.
	describe(@"search enabled:", ^{
		beforeEach(^{
			[[SpecHelper specHelper] sharedExampleContext][@"search"] = @(YES);
		});
		itShouldBehaveLike(@"variants");
	});
	describe(@"search disabled:", ^{
		beforeEach(^{
			[[SpecHelper specHelper] sharedExampleContext][@"search"] = @(NO);
		});
		itShouldBehaveLike(@"variants");
	});
});

TEST_END