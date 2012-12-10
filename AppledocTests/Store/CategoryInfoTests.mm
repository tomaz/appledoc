//
//  CategoryInfoTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/25/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "TestCaseBase.hh"

static void runWithCategoryInfo(void(^handler)(CategoryInfo *info)) {
	CategoryInfo *info = [[CategoryInfo alloc] initWithRegistrar:nil];
	handler(info);
	[info release];
}

#pragma mark - 

TEST_BEGIN(CategoryInfoTests)

describe(@"lazy properties:", ^{
	it(@"should initialize objects on first access", ^{
		runWithCategoryInfo(^(CategoryInfo *info) {
			// execute & verify
			info.categoryClass should be_instance_of([ObjectLinkInfo class]);
		});
	});
});

describe(@"convenience properties:", ^{
	it(@"should return name of super class", ^{
		runWithCategoryInfo(^(CategoryInfo *info) {
			// setup
			info.categoryClass.nameOfObject = @"SomeClass";
			// execute & verify
			info.nameOfClass should equal(@"SomeClass");
		});
	});
});

describe(@"category or extension helpers:", ^{
	it(@"should work if name of category is nil", ^{
		runWithCategoryInfo(^(CategoryInfo *info) {
			// setup
			info.nameOfCategory = nil;
			// execute & verify
			info.isExtension should equal(YES);
			info.isCategory should equal(NO);
		});
	});
	
	it(@"should work if name of category is empty string", ^{
		runWithCategoryInfo(^(CategoryInfo *info) {
			// setup
			info.nameOfCategory = @"";
			// execute & verify
			info.isExtension should equal(YES);
			info.isCategory should equal(NO);
		});
	});
	
	it(@"should work if name of category is not nil and not empty string", ^{
		runWithCategoryInfo(^(CategoryInfo *info) {
			// setup
			info.nameOfCategory = @"a";
			// execute & verify
			info.isExtension should equal(NO);
			info.isCategory should equal(YES);
		});
	});
});

describe(@"descriptions:", ^{
	it(@"should handle extension", ^{
		runWithCategoryInfo(^(CategoryInfo *info) {
			// setup
			info.categoryClass.nameOfObject = @"MyClass";
			// execute & verify
			info.uniqueObjectID should equal(@"MyClass()");
			info.objectCrossRefPathTemplate should equal(@"$CATEGORIES/MyClass.$EXT");
		});
	});

	it(@"should handle category", ^{
		runWithCategoryInfo(^(CategoryInfo *info) {
			// setup
			info.categoryClass.nameOfObject = @"MyClass";
			info.nameOfCategory = @"MyCategory";
			// execute & verify
			info.uniqueObjectID should equal(@"MyClass(MyCategory)");
			info.objectCrossRefPathTemplate should equal(@"$CATEGORIES/MyClass(MyCategory).$EXT");
		});
	});
});

TEST_END
