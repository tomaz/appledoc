//
//  LinkKnownObjectsTaskTests.m
//  appledoc
//
//  Created by Tomaz Kragelj on 7/12/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "TestCaseBase.hh"
#import "StoreMocks.h"
#import "LinkKnownObjectsTask.h"

#define GBSections [comment sourceSections]

#pragma mark -

static void runWithTask(void(^handler)(LinkKnownObjectsTask *task, id store)) {
	LinkKnownObjectsTask *task = [[LinkKnownObjectsTask alloc] init];
	task.store = mock([Store class]);
	handler(task, task.store);
	[task release];
}

static id createClass(NSString *name) {
	return [StoreMocks mockClass:name block:^(id object) { }];
}

static id createProtocol(NSString *name) {
	return [StoreMocks mockProtocol:name block:^(id object) { }];
}

static id createDerivedClass(NSString *name, NSString *baseName) {
	return [StoreMocks createClass:^(ClassInfo *object) {
		object.nameOfClass = name;
		[object derive:baseName];
	}];
}

static id createCategory(NSString *className) {
	return [StoreMocks createCategory:^(CategoryInfo *object) {
		[object extend:className];
	}];
}

#pragma mark -

TEST_BEGIN(LinkKnownObjectsTaskTests)

describe(@"adopted protocols:", ^{
	sharedExamplesFor(@"examples", ^(NSDictionary *info) {
		it(@"should link classes to known protocols", ^{
			runWithTask(^(LinkKnownObjectsTask *task, id store) {
				// setup
				ClassInfo *class1 = [StoreMocks createClass:^(ClassInfo *object) {
					[object adopt:@"MyProtocol1", @"MyProtocol2", @"UnknownProtocol", nil];
				}];
				id protocol1 = createProtocol(@"MyProtocol1");
				id protocol2 = createProtocol(@"MyProtocol2");
				[given([store storeProtocols]) willReturn:@[ protocol1, protocol2 ]];
				[given([store storeClasses]) willReturn:@[ class1 ]];
				// execute
				[task runTask];
				// verify
				[class1.interfaceAdoptedProtocols[0] linkToObject] should equal(protocol1);
				[class1.interfaceAdoptedProtocols[1] linkToObject] should equal(protocol2);
				[class1.interfaceAdoptedProtocols[2] linkToObject] should be_nil();
			});
		});
	});
	
	it(@"should link extensions to known protocols", ^{
		runWithTask(^(LinkKnownObjectsTask *task, id store) {
			CategoryInfo *extension1 = [StoreMocks createCategory:^(CategoryInfo *object) {
				[object adopt:@"MyProtocol1", @"MyProtocol2", @"UnknownProtocol", nil];
			}];
			id protocol1 = createProtocol(@"MyProtocol1");
			id protocol2 = createProtocol(@"MyProtocol2");
			[given([store storeProtocols]) willReturn:@[ protocol1, protocol2 ]];
			[given([store storeExtensions]) willReturn:@[ extension1 ]];
			// execute
			[task runTask];
			// verify
			[extension1.interfaceAdoptedProtocols[0] linkToObject] should equal(protocol1);
			[extension1.interfaceAdoptedProtocols[1] linkToObject] should equal(protocol2);
			[extension1.interfaceAdoptedProtocols[2] linkToObject] should be_nil();
		});
	});

	it(@"should link categories to known protocols", ^{
		runWithTask(^(LinkKnownObjectsTask *task, id store) {
			// setup
			CategoryInfo *category1 = [StoreMocks createCategory:^(CategoryInfo *object) {
				[object adopt:@"MyProtocol1", @"MyProtocol2", @"UnknownProtocol", nil];
			}];
			id protocol1 = createProtocol(@"MyProtocol1");
			id protocol2 = createProtocol(@"MyProtocol2");
			[given([store storeProtocols]) willReturn:@[ protocol1, protocol2 ]];
			[given([store storeCategories]) willReturn:@[ category1 ]];
			// execute
			[task runTask];
			// verify
			[category1.interfaceAdoptedProtocols[0] linkToObject] should equal(protocol1);
			[category1.interfaceAdoptedProtocols[1] linkToObject] should equal(protocol2);
			[category1.interfaceAdoptedProtocols[2] linkToObject] should be_nil();
		});
	});

	it(@"should link protocols to known protocols", ^{
		runWithTask(^(LinkKnownObjectsTask *task, id store) {
			// setup
			ProtocolInfo *protocol1 = [StoreMocks createProtocol:^(ProtocolInfo *object) {
				[object adopt:@"MyProtocol1", @"MyProtocol2", @"UnknownProtocol", nil];
			}];
			id protocol2 = createProtocol(@"MyProtocol1");
			id protocol3 = createProtocol(@"MyProtocol2");
			[given([store storeProtocols]) willReturn:@[ protocol1, protocol2, protocol3 ]];
			// execute
			[task runTask];
			// verify
			[protocol1.interfaceAdoptedProtocols[0] linkToObject] should equal(protocol2);
			[protocol1.interfaceAdoptedProtocols[1] linkToObject] should equal(protocol3);
			[protocol1.interfaceAdoptedProtocols[2] linkToObject] should be_nil();
		});
	});
});

describe(@"super classes:", ^{
	it(@"should link to known super classes", ^{
		runWithTask(^(LinkKnownObjectsTask *task, id store) {
			// setup
			ClassInfo *class1 = createDerivedClass(@"MyClass", @"MyBaseClass");
			id class2 = createClass(@"MyBaseClass");
			[given([store storeClasses]) willReturn:@[ class1, class2 ]];
			// execute
			[task runTask];
			// verify
			class1.classSuperClass.linkToObject should equal(class2);
		});
	});

	it(@"should handle multiple depths of class hierarchies", ^{
		runWithTask(^(LinkKnownObjectsTask *task, id store) {
			// setup
			ClassInfo *class1 = createDerivedClass(@"Class1", @"Class2");
			ClassInfo *class2 = createDerivedClass(@"Class2", @"Class3");
			ClassInfo *class3 = createDerivedClass(@"Class3", @"UnknownClass");
			[given([store storeClasses]) willReturn:@[ class1, class2, class3 ]];
			// execute
			[task runTask];
			// verify
			class1.classSuperClass.linkToObject should equal(class2);
			class2.classSuperClass.linkToObject should equal(class3);
			class3.classSuperClass.linkToObject should be_nil();
		});
	});
});

describe(@"category classes:", ^{
	it(@"should link extensions to known classes", ^{
		runWithTask(^(LinkKnownObjectsTask *task, id store) {
			// setup
			CategoryInfo *extension1 = createCategory(@"Class1");
			CategoryInfo *extension2 = createCategory(@"UnknownClass");
			ClassInfo *class1 = createClass(@"Class1");
			[given([store storeExtensions]) willReturn:@[ extension1, extension2 ]];
			[given([store storeClasses]) willReturn:@[ class1 ]];
			// execute
			[task runTask];
			// verify
			extension1.categoryClass.linkToObject should equal(class1);
			extension2.categoryClass.linkToObject should be_nil();
		});
	});

	it(@"should link categories to known classes", ^{
		runWithTask(^(LinkKnownObjectsTask *task, id store) {
			// setup
			CategoryInfo *category1 = createCategory(@"Class1");
			CategoryInfo *category2 = createCategory(@"UnknownClass");
			ClassInfo *class1 = createClass(@"Class1");
			[given([store storeCategories]) willReturn:@[ category1, category2 ]];
			[given([store storeClasses]) willReturn:@[ class1 ]];
			// execute
			[task runTask];
			// verify
			category1.categoryClass.linkToObject should equal(class1);
			category2.categoryClass.linkToObject should be_nil();
		});
	});
});

TEST_END