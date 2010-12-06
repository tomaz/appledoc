//
//  GBProcessor-CategoriesMergingTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 5.12.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBApplicationSettingsProviding.h"
#import "GBDataObjects.h"
#import "GBStore.h"
#import "GBProcessor.h"

@interface GBProcessorCategoriesMergingTesting : GHTestCase

- (GBProcessor *)processorWithMerge:(BOOL)merge keep:(BOOL)keep prefix:(BOOL)prefix;
- (NSString *)randomName;

@end

#pragma mark -

@implementation GBProcessorCategoriesMergingTesting

#pragma mark Top level handling

- (void)testProcessObjectsFromStore_shouldKeepCategoryIfMergeIsNo {
	// setup
	GBProcessor *processor = [self processorWithMerge:NO keep:NO prefix:NO];
	GBClassData *class = [GBClassData classDataWithName:@"Class"];
	GBCategoryData *category = [GBCategoryData categoryDataWithName:@"Category" className:@"Class"];
	GBCategoryData *extension = [GBCategoryData categoryDataWithName:nil className:@"Class"];
	GBStore *store = [GBTestObjectsRegistry storeWithObjects:class, category, extension, nil];
	// execute
	[processor processObjectsFromStore:store];
	// verify
	assertThatInteger([store.categories count], equalToInteger(2));
	assertThatBool([store.categories containsObject:category], equalToBool(YES));
	assertThatBool([store.categories containsObject:extension], equalToBool(YES));
}

- (void)testProcessObjectsFromStore_shouldMergeCategoryIfMergeIsYes {
	// setup
	GBProcessor *processor = [self processorWithMerge:YES keep:NO prefix:NO];
	GBClassData *class = [GBClassData classDataWithName:@"Class"];
	GBCategoryData *category = [GBCategoryData categoryDataWithName:@"Category" className:@"Class"];
	GBCategoryData *extension = [GBCategoryData categoryDataWithName:nil className:@"Class"];
	GBStore *store = [GBTestObjectsRegistry storeWithObjects:class, category, extension, nil];
	// execute
	[processor processObjectsFromStore:store];
	// verify
	assertThatInteger([store.categories count], equalToInteger(0));
}

- (void)testProcessObjectsFromStore_shouldKeepCategoryOfUnknownClassEvenIfMergeIsYes {
	// setup
	GBProcessor *processor = [self processorWithMerge:YES keep:NO prefix:NO];
	GBCategoryData *category = [GBCategoryData categoryDataWithName:@"Category" className:@"Class"];
	GBCategoryData *extension = [GBCategoryData categoryDataWithName:nil className:@"Class"];
	GBStore *store = [GBTestObjectsRegistry storeWithObjects:category, extension, nil];
	// execute
	[processor processObjectsFromStore:store];
	// verify
	assertThatInteger([store.categories count], equalToInteger(2));
	assertThatBool([store.categories containsObject:category], equalToBool(YES));
	assertThatBool([store.categories containsObject:extension], equalToBool(YES));
}

#pragma mark Methods merging testing

- (void)testProcessObjectsFromStore_shouldMergeAllMethodsFromCategories {
	// setup
	GBProcessor *processor = [self processorWithMerge:YES keep:NO prefix:NO];
	GBClassData *class = [GBClassData classDataWithName:@"Class"];
	GBCategoryData *category = [GBCategoryData categoryDataWithName:@"Category" className:@"Class"];
	[category.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"method1", nil]];
	GBCategoryData *extension = [GBCategoryData categoryDataWithName:nil className:@"Class"];
	[extension.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"method2", nil]];
	GBStore *store = [GBTestObjectsRegistry storeWithObjects:class, category, extension, nil];
	// execute
	[processor processObjectsFromStore:store];
	// verify
	NSArray *methods = [class.methods methods];
	assertThatInteger([methods count], equalToInteger(2));
	assertThatBool([methods containsObject:[category.methods.methods objectAtIndex:0]], equalToBool(YES));
	assertThatBool([methods containsObject:[extension.methods.methods objectAtIndex:0]], equalToBool(YES));
}

- (void)testProcessObjectsFromStore_shouldUseRegisterMethodOnClassToMergeMethods {
	// setup
	GBProcessor *processor = [self processorWithMerge:YES keep:NO prefix:NO];
	GBCategoryData *category = [GBCategoryData categoryDataWithName:@"Category" className:@"Class"];
	[category.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"method", nil]];
	OCMockObject *class = [OCMockObject niceMockForClass:[GBClassData class]];
	OCMockObject *provider = [OCMockObject niceMockForClass:[GBMethodsProvider class]];
	[[provider expect] registerMethod:[category.methods.methods objectAtIndex:0]];
	[[[class stub] andReturn:@"Class"] nameOfClass];
	[[[class stub] andReturn:provider] methods];
	GBStore *store = [GBTestObjectsRegistry storeWithObjects:class, category, nil];
	// execute
	[processor processObjectsFromStore:store];
	// verify - by using registerMethod: we're validating default section creation and the rest!
	[provider verify];
}

#pragma mark Creation methods

- (GBProcessor *)processorWithMerge:(BOOL)merge keep:(BOOL)keep prefix:(BOOL)prefix {
	OCMockObject *settings = [GBTestObjectsRegistry mockSettingsProvider];
	[[[settings stub] andReturnValue:[NSNumber numberWithBool:merge]] mergeCategoriesToClasses];
	[[[settings stub] andReturnValue:[NSNumber numberWithBool:keep]] keepMergedCategoriesSections];
	[[[settings stub] andReturnValue:[NSNumber numberWithBool:prefix]] prefixMergedCategoriesSectionsWithCategoryName];
	[GBTestObjectsRegistry settingsProvider:settings keepObjects:YES keepMembers:YES];
	return [GBProcessor processorWithSettingsProvider:settings];
}

- (NSString *)randomName {
	NSUInteger value = random();
	return [NSString stringWithFormat:@"N%ld", value];
}

@end
