//
//  GBTemplateVariablesProvider-ObjectSpecificationsTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 3.10.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBApplicationSettingsProvider.h"
#import "GBHTMLTemplateVariablesProvider.h"
#import "GBTokenizer.h"

@interface GBTemplateVariablesProviderObjectSpecificationsTesting : GHTestCase
@end

@implementation GBTemplateVariablesProviderObjectSpecificationsTesting

#pragma mark Inherits from

- (void)testVariablesForClass_inheritsFrom_shouldIgnoreSpecificationForRootClass {
	// setup
	GBHTMLTemplateVariablesProvider *provider = [GBHTMLTemplateVariablesProvider providerWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	GBClassData *class = [GBClassData classDataWithName:@"Class"];
	// execute
	NSDictionary *vars = [provider variablesForClass:class withStore:[GBTestObjectsRegistry store]];
	NSArray *specifications = [vars valueForKeyPath:@"page.specifications.values"];
	// verify
	assertThatInteger([specifications count], equalToInteger(0));
}

- (void)testVariablesForClass_inheritsFrom_shouldPrepareSpecificationForUnknownSuperclass {
	// setup
	GBHTMLTemplateVariablesProvider *provider = [GBHTMLTemplateVariablesProvider providerWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	GBClassData *class = [GBClassData classDataWithName:@"Class"];
	class.nameOfSuperclass = @"NSObject";
	// execute
	NSDictionary *vars = [provider variablesForClass:class withStore:[GBTestObjectsRegistry store]];
	NSArray *specifications = [vars valueForKeyPath:@"page.specifications.values"];
	// verify
	NSDictionary *specification = [specifications objectAtIndex:0];
	NSArray *values = [specification objectForKey:@"values"];
	assertThatInteger([values count], equalToInteger(1));
	assertThat([[values objectAtIndex:0] objectForKey:@"string"], is(@"NSObject"));
	assertThat([[values objectAtIndex:0] objectForKey:@"href"], is(nil));
}

- (void)testVariablesForClass_inheritsFrom_shouldPrepareSpecificationForKnownSuperclass {
	// setup
	GBHTMLTemplateVariablesProvider *provider = [GBHTMLTemplateVariablesProvider providerWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	GBClassData *superclass = [GBClassData classDataWithName:@"Base"];
	GBStore *store = [GBTestObjectsRegistry store];
	[store registerClass:superclass];
	GBClassData *class = [GBClassData classDataWithName:@"Class"];
	class.nameOfSuperclass = superclass.nameOfClass;
	class.superclass = superclass;
	// execute
	NSDictionary *vars = [provider variablesForClass:class withStore:store];
	NSArray *specifications = [vars valueForKeyPath:@"page.specifications.values"];
	// verify
	NSDictionary *specification = [specifications objectAtIndex:0];
	NSArray *values = [specification objectForKey:@"values"];
	assertThatInteger([values count], equalToInteger(1));
	assertThat([[values objectAtIndex:0] objectForKey:@"string"], is(@"Base"));
	assertThat([[values objectAtIndex:0] objectForKey:@"href"], isNot(nil));
}

- (void)testVariablesForClass_inheritsFrom_shouldPrepareSpecificationForClassHierarchy {
	// setup
	GBHTMLTemplateVariablesProvider *provider = [GBHTMLTemplateVariablesProvider providerWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	GBClassData *level2 = [GBClassData classDataWithName:@"Level2"];
	level2.nameOfSuperclass = @"NSObject";
	GBClassData *level1 = [GBClassData classDataWithName:@"Level1"];
	level1.nameOfSuperclass = level2.nameOfClass;
	level1.superclass = level2;
	GBClassData *class = [GBClassData classDataWithName:@"Class"];
	class.nameOfSuperclass = level1.nameOfClass;
	class.superclass = level1;
	GBStore *store = [GBTestObjectsRegistry store];
	[store registerClass:level1];
	[store registerClass:level2];
	// execute
	NSDictionary *vars = [provider variablesForClass:class withStore:store];
	NSArray *specifications = [vars valueForKeyPath:@"page.specifications.values"];
	// verify - note that href is created even if superclass is not registered to store as long as a superclass property is non-nil.
	NSDictionary *specification = [specifications objectAtIndex:0];
	NSArray *values = [specification objectForKey:@"values"];
	assertThatInteger([values count], equalToInteger(3));
	assertThat([[values objectAtIndex:0] objectForKey:@"string"], is(@"Level1"));
	assertThat([[values objectAtIndex:0] objectForKey:@"href"], isNot(nil));
	assertThat([[values objectAtIndex:1] objectForKey:@"string"], is(@"Level2"));
	assertThat([[values objectAtIndex:1] objectForKey:@"href"], isNot(nil));
	assertThat([[values objectAtIndex:2] objectForKey:@"string"], is(@"NSObject"));
	assertThat([[values objectAtIndex:2] objectForKey:@"href"], is(nil));
}

#pragma mark Conforms to

- (void)testVariablesForClass_conformsTo_shouldIgnoreSpecificationForNonAdoptingClass {
	// setup
	GBHTMLTemplateVariablesProvider *provider = [GBHTMLTemplateVariablesProvider providerWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	GBClassData *class = [GBClassData classDataWithName:@"Class"];
	// execute
	NSDictionary *vars = [provider variablesForClass:class withStore:[GBTestObjectsRegistry store]];
	NSArray *specifications = [vars valueForKeyPath:@"page.specifications.values"];
	// verify
	assertThatInteger([specifications count], equalToInteger(0));
}

- (void)testVariablesForClass_conformsTo_shouldPrepareSpecificationForUnknownProtocol {
	// setup
	GBHTMLTemplateVariablesProvider *provider = [GBHTMLTemplateVariablesProvider providerWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	GBClassData *class = [GBClassData classDataWithName:@"Class"];
	[class.adoptedProtocols registerProtocol:[GBProtocolData protocolDataWithName:@"Protocol"]];
	// execute
	NSDictionary *vars = [provider variablesForClass:class withStore:[GBTestObjectsRegistry store]];
	NSArray *specifications = [vars valueForKeyPath:@"page.specifications.values"];
	// verify
	NSDictionary *specification = [specifications objectAtIndex:0];
	NSArray *values = [specification objectForKey:@"values"];
	assertThatInteger([values count], equalToInteger(1));
	assertThat([[values objectAtIndex:0] objectForKey:@"string"], is(@"Protocol"));
	assertThat([[values objectAtIndex:0] objectForKey:@"href"], is(nil));
}

- (void)testVariablesForClass_conformsTo_shouldPrepareSpecificationForKnownProtocol {
	// setup
	GBHTMLTemplateVariablesProvider *provider = [GBHTMLTemplateVariablesProvider providerWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	GBProtocolData *protocol = [GBProtocolData protocolDataWithName:@"Protocol"];
	GBStore *store = [GBTestObjectsRegistry store];
	[store registerProtocol:protocol];
	GBClassData *class = [GBClassData classDataWithName:@"Class"];
	[class.adoptedProtocols registerProtocol:protocol];
	// execute
	NSDictionary *vars = [provider variablesForClass:class withStore:store];
	NSArray *specifications = [vars valueForKeyPath:@"page.specifications.values"];
	// verify
	NSDictionary *specification = [specifications objectAtIndex:0];
	NSArray *values = [specification objectForKey:@"values"];
	assertThatInteger([values count], equalToInteger(1));
	assertThat([[values objectAtIndex:0] objectForKey:@"string"], is(@"Protocol"));
	assertThat([[values objectAtIndex:0] objectForKey:@"href"], isNot(nil));
}

- (void)testVariablesForClass_conformsTo_shouldPrepareSpecificationForComplexProtocolsList {
	// setup
	GBHTMLTemplateVariablesProvider *provider = [GBHTMLTemplateVariablesProvider providerWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	GBProtocolData *protocol1 = [GBProtocolData protocolDataWithName:@"Protocol1"];
	GBProtocolData *protocol2 = [GBProtocolData protocolDataWithName:@"Protocol2"];
	GBProtocolData *protocol3 = [GBProtocolData protocolDataWithName:@"Protocol3"];
	GBStore *store = [GBTestObjectsRegistry store];
	[store registerProtocol:protocol1];
	[store registerProtocol:protocol3];
	GBClassData *class = [GBClassData classDataWithName:@"Class"];
	[class.adoptedProtocols registerProtocol:protocol1];
	[class.adoptedProtocols registerProtocol:protocol2];
	[class.adoptedProtocols registerProtocol:protocol3];
	// execute
	NSDictionary *vars = [provider variablesForClass:class withStore:store];
	NSArray *specifications = [vars valueForKeyPath:@"page.specifications.values"];
	// verify
	NSDictionary *specification = [specifications objectAtIndex:0];
	NSArray *values = [specification objectForKey:@"values"];
	assertThatInteger([values count], equalToInteger(3));
	assertThat([[values objectAtIndex:0] objectForKey:@"string"], is(@"Protocol1"));
	assertThat([[values objectAtIndex:0] objectForKey:@"href"], isNot(nil));
	assertThat([[values objectAtIndex:1] objectForKey:@"string"], is(@"Protocol2"));
	assertThat([[values objectAtIndex:1] objectForKey:@"href"], is(nil));
	assertThat([[values objectAtIndex:2] objectForKey:@"string"], is(@"Protocol3"));
	assertThat([[values objectAtIndex:2] objectForKey:@"href"], isNot(nil));
}

#pragma mark Declared in

- (void)testVariablesForClass_declaredIn_shouldPrepareSpecificationForSingleSourceInfo {
	// setup
	GBHTMLTemplateVariablesProvider *provider = [GBHTMLTemplateVariablesProvider providerWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	GBClassData *class = [GBClassData classDataWithName:@"Class"];
	[class registerSourceInfo:[GBSourceInfo infoWithFilename:@"file.h" lineNumber:10]];
	// execute
	NSDictionary *vars = [provider variablesForClass:class withStore:[GBTestObjectsRegistry store]];
	NSArray *specifications = [vars valueForKeyPath:@"page.specifications.values"];
	// verify
	NSDictionary *specification = [specifications objectAtIndex:0];
	NSArray *values = [specification objectForKey:@"values"];
	assertThatInteger([values count], equalToInteger(1));
	assertThat([[values objectAtIndex:0] objectForKey:@"string"], is(@"file.h"));
	assertThat([[values objectAtIndex:0] objectForKey:@"href"], is(nil));
}

- (void)testVariablesForClass_declaredIn_shouldPrepareSpecificationForMultipleSourceInfos {
	// setup
	GBHTMLTemplateVariablesProvider *provider = [GBHTMLTemplateVariablesProvider providerWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	GBClassData *class = [GBClassData classDataWithName:@"Class"];
	[class registerSourceInfo:[GBSourceInfo infoWithFilename:@"file1.h" lineNumber:10]];
	[class registerSourceInfo:[GBSourceInfo infoWithFilename:@"file2.h" lineNumber:55]];
	// execute
	NSDictionary *vars = [provider variablesForClass:class withStore:[GBTestObjectsRegistry store]];
	NSArray *specifications = [vars valueForKeyPath:@"page.specifications.values"];
	// verify
	NSDictionary *specification = [specifications objectAtIndex:0];
	NSArray *values = [specification objectForKey:@"values"];
	assertThatInteger([values count], equalToInteger(2));
	assertThat([[values objectAtIndex:0] objectForKey:@"string"], is(@"file1.h"));
	assertThat([[values objectAtIndex:0] objectForKey:@"href"], is(nil));
	assertThat([[values objectAtIndex:1] objectForKey:@"string"], is(@"file2.h"));
	assertThat([[values objectAtIndex:1] objectForKey:@"href"], is(nil));
}

@end
