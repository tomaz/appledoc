//
//  CategoryInfoTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/25/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "TestCaseBase.h"

@interface CategoryInfoTests : TestCaseBase
@end

@interface CategoryInfoTests (CreationMethods)
- (void)runWithCategoryInfo:(void(^)(CategoryInfo *info))handler;
@end

@implementation CategoryInfoTests

#pragma mark - isExtension & isCategory

- (void)testIsExtensionShouldReturnYesAndIsCategoryShouldReturnNoIfNameOfCategoryIsNil {
	[self runWithCategoryInfo:^(CategoryInfo *info) {
		// setup
		info.nameOfCategory = nil;
		// execute & verify
		assertThatBool(info.isExtension, equalToBool(YES));
		assertThatBool(info.isCategory, equalToBool(NO));
	}];
}

- (void)testIsExtensionShouldReturnYesAndIsCategoryShouldReturnNoIfNameOfCategoryIsEmptyString {
	[self runWithCategoryInfo:^(CategoryInfo *info) {
		// setup
		info.nameOfCategory = @"";
		// execute & verify
		assertThatBool(info.isExtension, equalToBool(YES));
		assertThatBool(info.isCategory, equalToBool(NO));
	}];
}

- (void)testIsExtensionShouldReturnNoAndIsCategoryShouldReturnYesIfNameOfCategoryIsProvided {
	[self runWithCategoryInfo:^(CategoryInfo *info) {
		// setup
		info.nameOfCategory = @"a";
		// execute & verify
		assertThatBool(info.isExtension, equalToBool(NO));
		assertThatBool(info.isCategory, equalToBool(YES));
	}];
}

@end

#pragma mark - 

@implementation CategoryInfoTests (CreationMethods)

- (void)runWithCategoryInfo:(void(^)(CategoryInfo *info))handler {
	CategoryInfo *info = [[CategoryInfo alloc] initWithRegistrar:nil];
	handler(info);
}

@end
