//
//  GBProcessor-CategoriesMergingTesting.m
//  appledocTests
//
//  Created by Jebeom Gyeong on 2/22/20.
//  Copyright © 2020 Gentle Bytes. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "GBApplicationSettingsProvider.h"
#import "GBDataObjects.h"
#import "GBStore.h"
#import "GBProcessor.h"
#import "GBTestObjectsRegistry.h"

@interface GBProcessor_CategoriesMergingTesting : XCTestCase

- (GBProcessor *)processorWithMerge:(BOOL)merge keep:(BOOL)keep prefix:(BOOL)prefix;
- (NSString *)randomName;

@end

#pragma mark -

@implementation GBProcessor_CategoriesMergingTesting

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

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
    XCTAssertEqual([store.categories count], 2);
    XCTAssertTrue([store.categories containsObject:category]);
    XCTAssertTrue([store.categories containsObject:extension]);
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
    XCTAssertEqual([store.categories count], 0);
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
    XCTAssertEqual([store.categories count], 2);
    XCTAssertTrue([store.categories containsObject:category]);
    XCTAssertTrue([store.categories containsObject:extension]);
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
    XCTAssertEqual([methods count], 2);
    XCTAssertTrue([methods containsObject:category.methods.methods[0]]);
    XCTAssertTrue([methods containsObject:extension.methods.methods[0]]);
}

- (void)testProcessObjectsFromStore_shouldUseRegisterMethodOnClassToMergeMethods {
    // setup
    GBProcessor *processor = [self processorWithMerge:YES keep:NO prefix:NO];
    GBCategoryData *category = [GBCategoryData categoryDataWithName:@"Category" className:@"Class"];
    [category.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"method", nil]];
    OCMockObject *class = [OCMockObject niceMockForClass:[GBClassData class]];
    OCMockObject *provider = [OCMockObject niceMockForClass:[GBMethodsProvider class]];
    [[provider expect] registerMethod:category.methods.methods[0]];
    [[[class stub] andReturn:@"Class"] nameOfClass];
    [[[class stub] andReturn:provider] methods];
    GBStore *store = [GBTestObjectsRegistry storeWithObjects:class, category, nil];
    // execute
    [processor processObjectsFromStore:store];
    // verify - by using registerMethod: we're validating default section creation and the rest!
    [provider verify];
}

#pragma mark Sections merging testing

- (void)testProcessObjectsFromStore_shouldAppendSectionsToEndOfExistingClassSections {
    // setup
    GBProcessor *processor = [self processorWithMerge:YES keep:NO prefix:NO];
    GBClassData *class = [GBClassData classDataWithName:@"Class"];
    [class.methods registerSectionWithName:@"Section1"];
    [class.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"method1", nil]];
    GBCategoryData *category = [GBCategoryData categoryDataWithName:@"Category" className:@"Class"];
    [category.methods registerSectionWithName:@"Section2"];
    [category.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"method2", nil]];
    GBStore *store = [GBTestObjectsRegistry storeWithObjects:class, category, nil];
    // execute
    [processor processObjectsFromStore:store];
    // verify
    NSArray *sections = [class.methods sections];
    XCTAssertEqual([sections count], 2);
    GBMethodSectionData *section = sections[1];
    XCTAssertEqual([section.methods count], 1);
    XCTAssertTrue([section.methods containsObject:category.methods.methods[0]]);
}

- (void)testProcessObjectsFromStore_shouldCreateSingleSectionIfKeepSectionsIsNo {
    // setup
    GBProcessor *processor = [self processorWithMerge:YES keep:NO prefix:NO];
    GBClassData *class = [GBClassData classDataWithName:@"Class"];
    GBCategoryData *category = [GBCategoryData categoryDataWithName:@"Category" className:@"Class"];
    [category.methods registerSectionWithName:@"Section1"];
    [category.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"method1", nil]];
    [category.methods registerSectionWithName:@"Section2"];
    [category.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"method2", nil]];
    GBStore *store = [GBTestObjectsRegistry storeWithObjects:class, category, nil];
    // execute
    [processor processObjectsFromStore:store];
    // verify
    NSArray *sections = [class.methods sections];
    XCTAssertEqual([sections count], 1);
    GBMethodSectionData *section = sections[0];
    XCTAssertEqual([section.methods count], 2);
    XCTAssertTrue([section.methods containsObject:category.methods.methods[0]]);
    XCTAssertTrue([section.methods containsObject:category.methods.methods[1]]);
}

- (void)testProcessObjectsFromStore_shouldDuplicateSectionsIfKeepSectionsIsYes {
    // setup
    GBProcessor *processor = [self processorWithMerge:YES keep:YES prefix:NO];
    GBClassData *class = [GBClassData classDataWithName:@"Class"];
    GBCategoryData *category = [GBCategoryData categoryDataWithName:@"Category" className:@"Class"];
    [category.methods registerSectionWithName:@"Section1"];
    [category.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"method1", nil]];
    [category.methods registerSectionWithName:@"Section2"];
    [category.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"method2", nil]];
    GBStore *store = [GBTestObjectsRegistry storeWithObjects:class, category, nil];
    // execute
    [processor processObjectsFromStore:store];
    // verify
    GBMethodSectionData *section;
    NSArray *sections = [class.methods sections];
    XCTAssertEqual([sections count], 2);
    section = sections[0];
    XCTAssertEqual([section.methods count], 1);
    XCTAssertTrue([section.methods containsObject:category.methods.methods[0]]);
    section = sections[1];
    XCTAssertEqual([section.methods count], 1);
    XCTAssertTrue([section.methods containsObject:category.methods.methods[1]]);
}

#pragma mark Section naming testing

- (void)testProcessObjectsFromStore_shouldNameSingleSectionAfterCategory {
    // setup
    GBProcessor *processor = [self processorWithMerge:YES keep:NO prefix:NO];
    GBClassData *class = [GBClassData classDataWithName:@"Class"];
    GBCategoryData *category = [GBCategoryData categoryDataWithName:@"Category" className:@"Class"];
    [category.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"method1", nil]];
    GBStore *store = [GBTestObjectsRegistry storeWithObjects:class, category, nil];
    // execute
    [processor processObjectsFromStore:store];
    // verify
    NSString *name = [class.methods.sections[0] sectionName];
    XCTAssertTrue([name rangeOfString:category.nameOfCategory].location != NSNotFound);
}

- (void)testProcessObjectsFromStore_shouldUseOriginalSectionNamesIfPrefixIsNo {
    // setup
    GBProcessor *processor = [self processorWithMerge:YES keep:YES prefix:NO];
    GBClassData *class = [GBClassData classDataWithName:@"Class"];
    GBCategoryData *category = [GBCategoryData categoryDataWithName:@"Category" className:@"Class"];
    [category.methods registerSectionWithName:@"Section"];
    [category.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"method1", nil]];
    GBStore *store = [GBTestObjectsRegistry storeWithObjects:class, category, nil];
    // execute
    [processor processObjectsFromStore:store];
    // verify
    XCTAssertEqualObjects([class.methods.sections[0] sectionName], @"Section");
}

- (void)testProcessObjectsFromStore_shouldAddCategoryNameToSectionNamesIfPrefixIsYes {
    // setup
    GBProcessor *processor = [self processorWithMerge:YES keep:YES prefix:YES];
    GBClassData *class = [GBClassData classDataWithName:@"Class"];
    GBCategoryData *category = [GBCategoryData categoryDataWithName:@"Category" className:@"Class"];
    [category.methods registerSectionWithName:@"Section"];
    [category.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"method1", nil]];
    GBStore *store = [GBTestObjectsRegistry storeWithObjects:class, category, nil];
    // execute
    [processor processObjectsFromStore:store];
    // verify
    NSString *name = [class.methods.sections[0] sectionName];
    XCTAssertTrue([name rangeOfString:@"Section"].location != NSNotFound);
    XCTAssertTrue([name rangeOfString:category.nameOfCategory].location != NSNotFound);
}

- (void)testProcessObjectsFromStore_shouldNotAddExtensionKeywordToSectionNamesEvenIfPrefixIsYes {
    // setup
    GBProcessor *processor = [self processorWithMerge:YES keep:YES prefix:YES];
    GBClassData *class = [GBClassData classDataWithName:@"Class"];
    GBCategoryData *category = [GBCategoryData categoryDataWithName:nil className:@"Class"];
    [category.methods registerSectionWithName:@"Section"];
    [category.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"method1", nil]];
    GBStore *store = [GBTestObjectsRegistry storeWithObjects:class, category, nil];
    // execute
    [processor processObjectsFromStore:store];
    // verify
    XCTAssertEqualObjects([class.methods.sections[0] sectionName], @"Section");
}

#pragma mark Creation methods

- (GBProcessor *)processorWithMerge:(BOOL)merge keep:(BOOL)keep prefix:(BOOL)prefix {
    OCMockObject *settings = [GBTestObjectsRegistry mockSettingsProvider];
    [[[settings stub] andReturnValue:@(merge)] mergeCategoriesToClasses];
    [[[settings stub] andReturnValue:@(keep)] keepMergedCategoriesSections];
    [[[settings stub] andReturnValue:@(prefix)] prefixMergedCategoriesSectionsWithCategoryName];
    [GBTestObjectsRegistry settingsProvider:settings keepObjects:YES keepMembers:YES];
    return [GBProcessor processorWithSettingsProvider:settings];
}

- (NSString *)randomName {
    NSUInteger value = random();
    return [NSString stringWithFormat:@"N%ld", value];
}

@end
