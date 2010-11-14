//
//  GBStoreTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 25.7.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBStore.h"
#import "GBDataObjects.h"

@interface GBStoreTesting : GHTestCase
@end
	
@implementation GBStoreTesting

#pragma mark Class registration testing

- (void)testRegisterClass_shouldAddClassToList {
	// setup
	GBStore *store = [[GBStore alloc] init];
	GBClassData *class = [GBClassData classDataWithName:@"MyClass"];
	// execute
	[store registerClass:class];
	// verify
	assertThatBool([store.classes containsObject:class], equalToBool(YES));
	assertThatInteger([[store.classes allObjects] count], equalToInteger(1));
	assertThat([[store.classes allObjects] objectAtIndex:0], is(class));
}

- (void)testRegisterClass_shouldIgnoreSameInstance {
	// setup
	GBStore *store = [[GBStore alloc] init];
	GBClassData *class = [GBClassData classDataWithName:@"MyClass"];
	// execute
	[store registerClass:class];
	[store registerClass:class];
	// verify
	assertThatInteger([[store.classes allObjects] count], equalToInteger(1));
}

- (void)testRegisterClass_shouldMergeDataFromInstancesOfSameName {
	// setup - only basic stuff here, details are tested within GBClassDataTesting!
	GBStore *store = [[GBStore alloc] init];
	GBClassData *class2 = [GBClassData classDataWithName:@"MyClass"];
	OCMockObject *class1 = [OCMockObject niceMockForClass:[GBClassData class]];
	[[[class1 stub] andReturn:@"MyClass"] nameOfClass];
	[[class1 expect] mergeDataFromObject:class2];
	// execute
	[store registerClass:(GBClassData *)class1];
	[store registerClass:class2];
	// verify
	assertThatInteger([store.classes count], equalToInteger(1));
	[class1 verify];
}

- (void)testClassByName_shouldReturnProperInstanceOrNil {
	// setup
	GBStore *store = [[GBStore alloc] init];
	GBClassData *class1 = [GBClassData classDataWithName:@"Class1"];
	GBClassData *class2 = [GBClassData classDataWithName:@"Class2"];
	[store registerClass:class1];
	[store registerClass:class2];
	// execute & verify
	assertThat([store classWithName:@"Class1"], is(class1));
	assertThat([store classWithName:@"Class2"], is(class2));
	assertThat([store classWithName:@"Class3"], is(nil));
	assertThat([store classWithName:@""], is(nil));
	assertThat([store classWithName:nil], is(nil));
}

#pragma mark Category registration testing

- (void)testRegisterCategory_shouldAddCategoryToList {
	// setup
	GBStore *store = [[GBStore alloc] init];
	GBCategoryData *category = [GBCategoryData categoryDataWithName:@"MyCategory" className:@"MyClass"];
	// execute
	[store registerCategory:category];
	// verify
	assertThatBool([store.categories containsObject:category], equalToBool(YES));
	assertThatInteger([[store.categories allObjects] count], equalToInteger(1));
	assertThat([[store.categories allObjects] objectAtIndex:0], is(category));
}

- (void)testRegisterCategory_shouldIgnoreSameInstance {
	// setup
	GBStore *store = [[GBStore alloc] init];
	GBCategoryData *category = [GBCategoryData categoryDataWithName:@"MyCategory" className:@"MyClass"];
	// execute
	[store registerCategory:category];
	[store registerCategory:category];
	// verify
	assertThatInteger([[store.categories allObjects] count], equalToInteger(1));
}

- (void)testRegisterCategory_shouldPreventAddingDifferentInstanceWithSameName {
	// setup
	GBStore *store = [[GBStore alloc] init];
	GBCategoryData *category2 = [GBCategoryData categoryDataWithName:@"MyCategory" className:@"MyClass"];
	OCMockObject *category1 = [OCMockObject niceMockForClass:[GBCategoryData class]];
	[[[category1 stub] andReturn:@"MyClass"] nameOfClass];
	[[[category1 stub] andReturn:@"MyCategory"] nameOfCategory];
	[[category1 expect] mergeDataFromObject:category2];
	// execute
	[store registerCategory:(GBCategoryData *)category1];
	[store registerCategory:category2];
	// verify
	assertThatInteger([store.categories count], equalToInteger(1));
	[category1 verify];
}

- (void)testRegisterExtension_shouldAddExtensionToList {
	// setup
	GBStore *store = [[GBStore alloc] init];
	GBCategoryData *extension = [GBCategoryData categoryDataWithName:nil className:@"MyClass"];
	// execute
	[store registerCategory:extension];
	// verify
	assertThatBool([store.categories containsObject:extension], equalToBool(YES));
	assertThatInteger([[store.categories allObjects] count], equalToInteger(1));
	assertThat([[store.categories allObjects] objectAtIndex:0], is(extension));
}

- (void)testRegisterExtension_shouldIgnoreSameInstance {
	// setup
	GBStore *store = [[GBStore alloc] init];
	GBCategoryData *extension = [GBCategoryData categoryDataWithName:nil className:@"MyClass"];
	// execute
	[store registerCategory:extension];
	[store registerCategory:extension];
	// verify
	assertThatInteger([[store.categories allObjects] count], equalToInteger(1));
}

- (void)testRegisterExtension_shouldPreventAddingDifferentInstanceWithSameName {
	// setup
	GBStore *store = [[GBStore alloc] init];
	GBCategoryData *extension2 = [GBCategoryData categoryDataWithName:nil className:@"MyClass"];
	OCMockObject *extension1 = [OCMockObject niceMockForClass:[GBCategoryData class]];
	[[[extension1 stub] andReturn:@"MyClass"] nameOfClass];
	[[[extension1 stub] andReturn:nil] nameOfCategory];
	[[extension1 expect] mergeDataFromObject:extension2];
	// execute
	[store registerCategory:(GBCategoryData *)extension1];
	[store registerCategory:extension2];
	// verify
	assertThatInteger([store.categories count], equalToInteger(1));
	[extension1 verify];
}

- (void)testRegisterExtension_shouldAllowCategoryAndExtensionOfSameClass {
	// setup
	GBStore *store = [[GBStore alloc] init];
	GBCategoryData *category = [GBCategoryData categoryDataWithName:@"MyCategory" className:@"MyClass"];
	GBCategoryData *extension = [GBCategoryData categoryDataWithName:nil className:@"MyClass"];
	// execute
	[store registerCategory:category];
	[store registerCategory:extension];
	// execute & verify
	assertThatBool([store.categories containsObject:category], equalToBool(YES));
	assertThatBool([store.categories containsObject:extension], equalToBool(YES));
}

- (void)testCategoryByName_shouldReturnProperInstanceOrNil {
	// setup
	GBStore *store = [[GBStore alloc] init];
	GBCategoryData *category1 = [GBCategoryData categoryDataWithName:@"Category1" className:@"Class"];
	GBCategoryData *category2 = [GBCategoryData categoryDataWithName:@"Category2" className:@"Class"];
	GBCategoryData *extension = [GBCategoryData categoryDataWithName:nil className:@"Class"];
	[store registerCategory:category1];
	[store registerCategory:category2];
	[store registerCategory:extension];
	// execute & verify
	assertThat([store categoryWithName:@"Class(Category1)"], is(category1));
	assertThat([store categoryWithName:@"Class(Category2)"], is(category2));
	assertThat([store categoryWithName:@"Class()"], is(extension));
	assertThat([store categoryWithName:@"Class(Category3)"], is(nil));
	assertThat([store categoryWithName:@"Class1()"], is(nil));
	assertThat([store categoryWithName:@"()"], is(nil));
	assertThat([store categoryWithName:nil], is(nil));
}

#pragma mark Protocol registration testing

- (void)testRegisterProtocol_shouldAddProtocolToList {
	// setup
	GBStore *store = [[GBStore alloc] init];
	GBProtocolData *protocol = [GBProtocolData protocolDataWithName:@"MyProtocol"];
	// execute
	[store registerProtocol:protocol];
	// verify
	assertThatBool([store.protocols containsObject:protocol], equalToBool(YES));
	assertThatInteger([[store.protocols allObjects] count], equalToInteger(1));
	assertThat([[store.protocols allObjects] objectAtIndex:0], is(protocol));
}

- (void)testRegisterProtocol_shouldIgnoreSameInstance {
	// setup
	GBStore *store = [[GBStore alloc] init];
	GBProtocolData *protocol = [GBProtocolData protocolDataWithName:@"MyProtocol"];
	// execute
	[store registerProtocol:protocol];
	[store registerProtocol:protocol];
	// verify
	assertThatInteger([[store.protocols allObjects] count], equalToInteger(1));
}

- (void)testRegisterProtocol_shouldPreventAddingDifferentInstanceWithSameName {
	// setup
	GBStore *store = [[GBStore alloc] init];
	GBProtocolData *protocol2 = [GBProtocolData protocolDataWithName:@"MyProtocol"];
	OCMockObject *protocol1 = [OCMockObject niceMockForClass:[GBProtocolData class]];
	[[[protocol1 stub] andReturn:@"MyProtocol"] nameOfProtocol];
	[[protocol1 expect] mergeDataFromObject:protocol2];
	// execute
	[store registerProtocol:(GBProtocolData *)protocol1];
	[store registerProtocol:protocol2];
	// verify
	assertThatInteger([store.protocols count], equalToInteger(1));
	[protocol1 verify];
}

- (void)testProtocolByName_shouldReturnProperInstanceOrNil {
	// setup
	GBStore *store = [[GBStore alloc] init];
	GBProtocolData *protocol1 = [GBProtocolData protocolDataWithName:@"Protocol1"];
	GBProtocolData *protocol2 = [GBProtocolData protocolDataWithName:@"Protocol2"];
	[store registerProtocol:protocol1];
	[store registerProtocol:protocol2];
	// execute & verify
	assertThat([store protocolWithName:@"Protocol1"], is(protocol1));
	assertThat([store protocolWithName:@"Protocol2"], is(protocol2));
	assertThat([store protocolWithName:@"Protocol3"], is(nil));
	assertThat([store protocolWithName:@""], is(nil));
	assertThat([store protocolWithName:nil], is(nil));
}

@end
