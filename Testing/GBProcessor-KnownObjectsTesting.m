//
//  GBProcessor-KnownObjectsTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 27.8.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBApplicationSettingsProvider.h"
#import "GBDataObjects.h"
#import "GBStore.h"
#import "GBProcessor.h"

@interface GBProcessorKnownObjectsTesting : GHTestCase

- (OCMockObject *)mockSettingsProvider;

@end

#pragma mark -

@implementation GBProcessorKnownObjectsTesting

#pragma mark Adopted protocols handling

- (void)testProcessObjectsFromStore_shouldReplaceKnownClassAdoptedProtocolsWithProtocolsFromStore {
	// setup
	GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[self mockSettingsProvider]];
	GBProtocolData *realProtocol = [GBProtocolData protocolDataWithName:@"P1"];
	GBProtocolData *adoptedProtocol1 = [GBProtocolData protocolDataWithName:@"P1"];
	GBProtocolData *adoptedProtocol2 = [GBProtocolData protocolDataWithName:@"P2"];
	GBClassData *class = [GBClassData classDataWithName:@"Class"];
	[class.adoptedProtocols registerProtocol:adoptedProtocol1];
	[class.adoptedProtocols registerProtocol:adoptedProtocol2];
	GBStore *store = [[GBStore alloc] init];
	[store registerClass:class];
	[store registerProtocol:realProtocol];
	// execute
	[processor processObjectsFromStore:store];
	// verify
	NSArray *protocols = [class.adoptedProtocols protocolsSortedByName];
	assertThatInteger([protocols count], equalToInteger(2));
	assertThat([protocols objectAtIndex:0], is(realProtocol));
	assertThat([protocols objectAtIndex:1], is(adoptedProtocol2));
}

- (void)testProcessObjectsFromStore_shouldReplaceKnownCategoryAdoptedProtocolsWithProtocolsFromStore {
	// setup
	GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[self mockSettingsProvider]];
	GBProtocolData *realProtocol = [GBProtocolData protocolDataWithName:@"P1"];
	GBProtocolData *adoptedProtocol1 = [GBProtocolData protocolDataWithName:@"P1"];
	GBProtocolData *adoptedProtocol2 = [GBProtocolData protocolDataWithName:@"P2"];
	GBCategoryData *category = [GBCategoryData categoryDataWithName:@"Category" className:@"Class"];
	[category.adoptedProtocols registerProtocol:adoptedProtocol1];
	[category.adoptedProtocols registerProtocol:adoptedProtocol2];
	GBStore *store = [[GBStore alloc] init];
	[store registerCategory:category];
	[store registerProtocol:realProtocol];
	// execute
	[processor processObjectsFromStore:store];
	// verify
	NSArray *protocols = [category.adoptedProtocols protocolsSortedByName];
	assertThatInteger([protocols count], equalToInteger(2));
	assertThat([protocols objectAtIndex:0], is(realProtocol));
	assertThat([protocols objectAtIndex:1], is(adoptedProtocol2));
}

- (void)testProcessObjectsFromStore_shouldReplaceKnownProtocolAdoptedProtocolsWithProtocolsFromStore {
	// setup
	GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[self mockSettingsProvider]];
	GBProtocolData *realProtocol = [GBProtocolData protocolDataWithName:@"P1"];
	GBProtocolData *adoptedProtocol1 = [GBProtocolData protocolDataWithName:@"P1"];
	GBProtocolData *adoptedProtocol2 = [GBProtocolData protocolDataWithName:@"P2"];
	GBProtocolData *protocol = [GBProtocolData protocolDataWithName:@"Protocol"];
	[protocol.adoptedProtocols registerProtocol:adoptedProtocol1];
	[protocol.adoptedProtocols registerProtocol:adoptedProtocol2];
	GBStore *store = [[GBStore alloc] init];
	[store registerProtocol:protocol];
	[store registerProtocol:realProtocol];
	// execute
	[processor processObjectsFromStore:store];
	// verify
	NSArray *protocols = [protocol.adoptedProtocols protocolsSortedByName];
	assertThatInteger([protocols count], equalToInteger(2));
	assertThat([protocols objectAtIndex:0], is(realProtocol));
	assertThat([protocols objectAtIndex:1], is(adoptedProtocol2));
}

#pragma mark Subclasses handling

- (void)testProcessObjectsFromStore_shouldSetupSubclassesWithKnownClassesFromStore {
	// setup
	GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[self mockSettingsProvider]];
	GBClassData *class1 = [GBClassData classDataWithName:@"Class1"];
	GBClassData *class2 = [GBClassData classDataWithName:@"Class2"];
	GBClassData *class3 = [GBClassData classDataWithName:@"Class3"];
	GBClassData *class4 = [GBClassData classDataWithName:@"Class4"];
	class3.nameOfSuperclass = @"Class2";
	class2.nameOfSuperclass = @"Class1";
	class1.nameOfSuperclass = @"NSObject";
	GBStore *store = [[GBStore alloc] init];
	[store registerClass:class1];
	[store registerClass:class2];
	[store registerClass:class3];
	[store registerClass:class4];
	// execute
	[processor processObjectsFromStore:store];
	// verify
	assertThat(class1.superclass, is(nil));
	assertThat(class2.superclass, is(class1));
	assertThat(class3.superclass, is(class2));
	assertThat(class4.superclass, is(nil));
}

#pragma mark Objects and methods references handling

- (void)testProcessObjectsFromStore_shouldAssignHtmlReferencesToClasses {
	// setup
	OCMockObject *settings = [self mockSettingsProvider];
	GBProcessor *processor = [GBProcessor processorWithSettingsProvider:settings];
	GBClassData *class1 = [GBClassData classDataWithName:@"Class1"];
	GBClassData *class2 = [GBClassData classDataWithName:@"Class2"];
	[[[settings expect] andReturn:@"#class1"] htmlReferenceForObject:class1 fromSource:class1];
	[[[settings expect] andReturn:@"#class2"] htmlReferenceForObject:class2 fromSource:class2];
	[[[settings expect] andReturn:@"class1"] htmlReferenceNameForObject:class1];
	[[[settings expect] andReturn:@"class2"] htmlReferenceNameForObject:class2];
	GBStore *store = [[GBStore alloc] init];
	[store registerClass:class1];
	[store registerClass:class2];
	// execute
	[processor processObjectsFromStore:store];
	// verify
	assertThat(class1.htmlLocalReference, is(@"#class1"));
	assertThat(class2.htmlLocalReference, is(@"#class2"));
	assertThat(class1.htmlReferenceName, is(@"class1"));
	assertThat(class2.htmlReferenceName, is(@"class2"));
}

- (void)testProcessObjectsFromStore_shouldAssignHtmlReferencesToCategories {
	// setup
	OCMockObject *settings = [self mockSettingsProvider];
	GBProcessor *processor = [GBProcessor processorWithSettingsProvider:settings];
	GBCategoryData *category1 = [GBCategoryData categoryDataWithName:@"Category1" className:@"Class"];
	GBCategoryData *category2 = [GBCategoryData categoryDataWithName:@"Category2" className:@"Class"];
	[[[settings expect] andReturn:@"#category1"] htmlReferenceForObject:category1 fromSource:category1];
	[[[settings expect] andReturn:@"#category2"] htmlReferenceForObject:category2 fromSource:category2];
	[[[settings expect] andReturn:@"category1"] htmlReferenceNameForObject:category1];
	[[[settings expect] andReturn:@"category2"] htmlReferenceNameForObject:category2];
	GBStore *store = [[GBStore alloc] init];
	[store registerCategory:category1];
	[store registerCategory:category2];
	// execute
	[processor processObjectsFromStore:store];
	// verify
	assertThat(category1.htmlLocalReference, is(@"#category1"));
	assertThat(category2.htmlLocalReference, is(@"#category2"));
	assertThat(category1.htmlReferenceName, is(@"category1"));
	assertThat(category2.htmlReferenceName, is(@"category2"));
}

- (void)testProcessObjectsFromStore_shouldAssignHtmlReferencesToExtensions {
	// setup
	OCMockObject *settings = [self mockSettingsProvider];
	GBProcessor *processor = [GBProcessor processorWithSettingsProvider:settings];
	GBCategoryData *category1 = [GBCategoryData categoryDataWithName:nil className:@"Class1"];
	GBCategoryData *category2 = [GBCategoryData categoryDataWithName:nil className:@"Class2"];
	[[[settings expect] andReturn:@"#category1"] htmlReferenceForObject:category1 fromSource:category1];
	[[[settings expect] andReturn:@"#category2"] htmlReferenceForObject:category2 fromSource:category2];
	[[[settings expect] andReturn:@"category1"] htmlReferenceNameForObject:category1];
	[[[settings expect] andReturn:@"category2"] htmlReferenceNameForObject:category2];
	GBStore *store = [[GBStore alloc] init];
	[store registerCategory:category1];
	[store registerCategory:category2];
	// execute
	[processor processObjectsFromStore:store];
	// verify
	assertThat(category1.htmlLocalReference, is(@"#category1"));
	assertThat(category2.htmlLocalReference, is(@"#category2"));
	assertThat(category1.htmlReferenceName, is(@"category1"));
	assertThat(category2.htmlReferenceName, is(@"category2"));
}

- (void)testProcessObjectsFromStore_shouldAssignHtmlReferencesToProtocols {
	// setup
	OCMockObject *settings = [self mockSettingsProvider];
	GBProcessor *processor = [GBProcessor processorWithSettingsProvider:settings];
	GBProtocolData *protocol1 = [GBProtocolData protocolDataWithName:@"Protocol1"];
	GBProtocolData *protocol2 = [GBProtocolData protocolDataWithName:@"Protocol2"];
	[[[settings expect] andReturn:@"#protocol1"] htmlReferenceForObject:protocol1 fromSource:protocol1];
	[[[settings expect] andReturn:@"#protocol2"] htmlReferenceForObject:protocol2 fromSource:protocol2];
	[[[settings expect] andReturn:@"protocol1"] htmlReferenceNameForObject:protocol1];
	[[[settings expect] andReturn:@"protocol2"] htmlReferenceNameForObject:protocol2];
	GBStore *store = [[GBStore alloc] init];
	[store registerProtocol:protocol1];
	[store registerProtocol:protocol2];
	// execute
	[processor processObjectsFromStore:store];
	// verify
	assertThat(protocol1.htmlLocalReference, is(@"#protocol1"));
	assertThat(protocol2.htmlLocalReference, is(@"#protocol2"));
	assertThat(protocol1.htmlReferenceName, is(@"protocol1"));
	assertThat(protocol2.htmlReferenceName, is(@"protocol2"));
}

- (void)testProcessObjectsFromStore_shouldAssignHtmlReferencesToMethods {
	// setup
	OCMockObject *settings = [self mockSettingsProvider];
	GBProcessor *processor = [GBProcessor processorWithSettingsProvider:settings];
	GBMethodData *method1 = [GBTestObjectsRegistry classMethodWithNames:@"method1", nil];
	GBMethodData *method2 = [GBTestObjectsRegistry instanceMethodWithNames:@"method2", nil];
	GBMethodData *property = [GBTestObjectsRegistry propertyMethodWithArgument:@"value"];
	[[[settings expect] andReturn:@"#method1"] htmlReferenceForObject:method1 fromSource:OCMOCK_ANY];
	[[[settings expect] andReturn:@"#method2"] htmlReferenceForObject:method2 fromSource:OCMOCK_ANY];
	[[[settings expect] andReturn:@"#property"] htmlReferenceForObject:property fromSource:OCMOCK_ANY];
	[[[settings expect] andReturn:@"method1"] htmlReferenceNameForObject:method1];
	[[[settings expect] andReturn:@"method2"] htmlReferenceNameForObject:method2];
	[[[settings expect] andReturn:@"property"] htmlReferenceNameForObject:property];
	GBClassData *class = [GBClassData classDataWithName:@"Class"];
	[class.methods registerMethod:method1];
	[class.methods registerMethod:method2];
	[class.methods registerMethod:property];
	GBStore *store = [[GBStore alloc] init];
	[store registerClass:class];
	// execute
	[processor processObjectsFromStore:store];
	// verify
	assertThat(method1.htmlLocalReference, is(@"#method1"));
	assertThat(method2.htmlLocalReference, is(@"#method2"));
	assertThat(property.htmlLocalReference, is(@"#property"));
	assertThat(method1.htmlReferenceName, is(@"method1"));
	assertThat(method2.htmlReferenceName, is(@"method2"));
	assertThat(property.htmlReferenceName, is(@"property"));
}

#pragma mark Creation methods

- (OCMockObject *)mockSettingsProvider {
	OCMockObject *result = [GBTestObjectsRegistry mockSettingsProvider];
	[GBTestObjectsRegistry settingsProvider:result keepObjects:YES keepMembers:YES];
	return result;
}


@end
