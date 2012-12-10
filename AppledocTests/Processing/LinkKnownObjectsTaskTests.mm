//
//  LinkKnownObjectsTaskTests.m
//  appledoc
//
//  Created by Tomaz Kragelj on 7/12/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "LinkKnownObjectsTask.h"
#import "TestCaseBase.hh"

#define GBSections [comment sourceSections]

#pragma mark -

static void runWithTask(void(^handler)(LinkKnownObjectsTask *task, id store)) {
	LinkKnownObjectsTask *task = [[LinkKnownObjectsTask alloc] init];
	task.store = mock([Store class]);
	handler(task, task.store);
	[task release];
}

static id createInterface(void(^handler)(InterfaceInfoBase *interface)) {
	InterfaceInfoBase *result = [[InterfaceInfoBase alloc] init];
	handler(result);
	return result;
}

static id createClass(void(^handler)(ClassInfo *info)) {
	ClassInfo *result = [[ClassInfo alloc] init];
	handler(result);
	return result;
}

static id createClass(NSString *name) {
	id result = mock([ClassInfo class]);
	[given([result nameOfClass]) willReturn:name];
	return result;
}

static id createCategory(void(^handler)(CategoryInfo *info)) {
	CategoryInfo *result = [[CategoryInfo alloc] init];
	handler(result);
	return result;
}

static id createProtocol(void(^handler)(ProtocolInfo *info)) {
	ProtocolInfo *result = [[ProtocolInfo alloc] init];
	handler(result);
	return result;
}

static id createProtocol(NSString *name) {
	id result = mock([ProtocolInfo class]);
	[given([result nameOfProtocol]) willReturn:name];
	return result;
}

static void deriveClass(ClassInfo *object, NSString *name) {
	object.classSuperClass.nameOfObject = name;
}

static void extendClass(CategoryInfo *object, NSString *name) {
	object.categoryClass.nameOfObject = name;
}

static void adoptProtocols(InterfaceInfoBase *interface, NSString *first, ...) {
	va_list args;
	va_start(args, first);
	for (NSString *arg=first; arg!=nil; arg=va_arg(args, NSString *)) {
		ObjectLinkInfo *link = [[ObjectLinkInfo alloc] init];
		link.nameOfObject = arg;
		[interface.interfaceAdoptedProtocols addObject:link];
	}
	va_end(args);
}

#pragma mark -

TEST_BEGIN(LinkKnownObjectsTaskTests)

describe(@"adopted protocols:", ^{
	sharedExamplesFor(@"examples", ^(NSDictionary *info) {
		it(@"should link classes to known protocols", ^{
			runWithTask(^(LinkKnownObjectsTask *task, id store) {
				// setup
				InterfaceInfoBase *class1 = createInterface(^(InterfaceInfoBase *interface) {
					adoptProtocols(interface, @"MyProtocol1", @"MyProtocol2", @"UnknownProtocol", nil);
				});
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
			// setup
			InterfaceInfoBase *extension1 = createCategory(^(CategoryInfo *interface) {
				adoptProtocols(interface, @"MyProtocol1", @"MyProtocol2", @"UnknownProtocol", nil);
			});
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
			InterfaceInfoBase *category1 = createCategory(^(CategoryInfo *interface) {
				adoptProtocols(interface, @"MyProtocol1", @"MyProtocol2", @"UnknownProtocol", nil);
			});
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
			ProtocolInfo *protocol1 = createProtocol(^(ProtocolInfo *info) {
				adoptProtocols(info, @"MyProtocol1", @"MyProtocol2", @"UnknownProtocol", nil);
			});
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
			ClassInfo *class1 = createClass(^(ClassInfo *info) {
				deriveClass(info, @"MyBaseClass");
			});
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
			ClassInfo *class1 = createClass(^(ClassInfo *info) {
				info.nameOfClass = @"Class1";
				deriveClass(info, @"Class2");
			});
			ClassInfo *class2 = createClass(^(ClassInfo *info) {
				info.nameOfClass = @"Class2";
				deriveClass(info, @"Class3");
			});
			ClassInfo *class3 = createClass(^(ClassInfo *info) {
				info.nameOfClass = @"Class3";
				deriveClass(info, @"Unknown");
			});
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
			CategoryInfo *extension1 = createCategory(^(CategoryInfo *info) {
				extendClass(info, @"Class1");
			});
			CategoryInfo *extension2 = createCategory(^(CategoryInfo *info) {
				extendClass(info, @"UnknownClass");
			});
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
			CategoryInfo *category1 = createCategory(^(CategoryInfo *info) {
				extendClass(info, @"Class1");
			});
			CategoryInfo *category2 = createCategory(^(CategoryInfo *info) {
				extendClass(info, @"UnknownClass");
			});
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