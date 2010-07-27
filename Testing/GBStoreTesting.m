//
//  GBStoreTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 25.7.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBStore.h"
#import "GBClassData.h"

@interface GBStoreTesting : SenTestCase
@end
	
@implementation GBStoreTesting

#pragma mark Class registration testing

- (void)testRegisterClass_shouldAddClassToList {
	// setup
	GBStore *store = [[GBStore alloc] init];
	GBClassData *class = [[GBClassData alloc] initWithName:@"MyClass"];
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
	GBClassData *class = [[GBClassData alloc] initWithName:@"MyClass"];
	// execute
	[store registerClass:class];
	[store registerClass:class];
	// verify
	assertThatInteger([[store.classes allObjects] count], equalToInteger(1));
}

- (void)testRegisterClass_shouldPreventAddingDifferentInstanceWithSameName {
	// setup
	GBStore *store = [[GBStore alloc] init];
	GBClassData *class1 = [[GBClassData alloc] initWithName:@"MyClass"];
	GBClassData *class2 = [[GBClassData alloc] initWithName:@"MyClass"];
	[store registerClass:class1];
	// execute & verify
	STAssertThrows([store registerClass:class2], nil);
}

#pragma mark Category registration testing

- (void)testRegisterCategory_shouldAddCategoryToList {
	// setup
	GBStore *store = [[GBStore alloc] init];
	GBCategoryData *category = [[GBCategoryData alloc] initWithName:@"MyCategory" className:@"MyClass"];
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
	GBCategoryData *category = [[GBCategoryData alloc] initWithName:@"MyCategory" className:@"MyClass"];
	// execute
	[store registerCategory:category];
	[store registerCategory:category];
	// verify
	assertThatInteger([[store.categories allObjects] count], equalToInteger(1));
}

- (void)testRegisterCategory_shouldPreventAddingDifferentInstanceWithSameName {
	// setup
	GBStore *store = [[GBStore alloc] init];
	GBCategoryData *category1 = [[GBCategoryData alloc] initWithName:@"MyCategory" className:@"MyClass"];
	GBCategoryData *category2 = [[GBCategoryData alloc] initWithName:@"MyCategory" className:@"MyClass"];
	[store registerCategory:category1];
	// execute & verify
	STAssertThrows([store registerCategory:category2], nil);
}

- (void)testRegisterExtension_shouldAddExtensionToList {
	// setup
	GBStore *store = [[GBStore alloc] init];
	GBCategoryData *extension = [[GBCategoryData alloc] initWithName:nil className:@"MyClass"];
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
	GBCategoryData *extension = [[GBCategoryData alloc] initWithName:nil className:@"MyClass"];
	// execute
	[store registerCategory:extension];
	[store registerCategory:extension];
	// verify
	assertThatInteger([[store.categories allObjects] count], equalToInteger(1));
}

- (void)testRegisterExtension_shouldPreventAddingDifferentInstanceWithSameName {
	// setup
	GBStore *store = [[GBStore alloc] init];
	GBCategoryData *extension1 = [[GBCategoryData alloc] initWithName:nil className:@"MyClass"];
	GBCategoryData *extension2 = [[GBCategoryData alloc] initWithName:nil className:@"MyClass"];
	[store registerCategory:extension1];
	// execute & verify
	STAssertThrows([store registerCategory:extension2], nil);
}

- (void)testRegisterExtension_shouldAllowCategoryAndExtensionOfSameClass {
	// setup
	GBStore *store = [[GBStore alloc] init];
	GBCategoryData *category = [[GBCategoryData alloc] initWithName:@"MyCategory" className:@"MyClass"];
	GBCategoryData *extension = [[GBCategoryData alloc] initWithName:nil className:@"MyClass"];
	// execute
	[store registerCategory:category];
	[store registerCategory:extension];
	// execute & verify
	assertThatBool([store.categories containsObject:category], equalToBool(YES));
	assertThatBool([store.categories containsObject:extension], equalToBool(YES));
}

#pragma mark Protocol registration testing

- (void)testRegisterProtocol_shouldAddProtocolToList {
	// setup
	GBStore *store = [[GBStore alloc] init];
	GBProtocolData *protocol = [[GBProtocolData alloc] initWithName:@"MyProtocol"];
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
	GBProtocolData *protocol = [[GBProtocolData alloc] initWithName:@"MyProtocol"];
	// execute
	[store registerProtocol:protocol];
	[store registerProtocol:protocol];
	// verify
	assertThatInteger([[store.protocols allObjects] count], equalToInteger(1));
}

- (void)testRegisterProtocol_shouldPreventAddingDifferentInstanceWithSameName {
	// setup
	GBStore *store = [[GBStore alloc] init];
	GBProtocolData *protocol1 = [[GBProtocolData alloc] initWithName:@"MyProtocol"];
	GBProtocolData *protocol2 = [[GBProtocolData alloc] initWithName:@"MyProtocol"];
	[store registerProtocol:protocol1];
	// execute & verify
	STAssertThrows([store registerProtocol:protocol2], nil);
}

@end
