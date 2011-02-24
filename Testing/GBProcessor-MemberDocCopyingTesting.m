//
//  GBProcessor-MembersDocCopyingTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 7.12.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBApplicationSettingsProvider.h"
#import "GBDataObjects.h"
#import "GBProcessor.h"

@interface GBProcessorMembersDocumentationCopyingTesting : GHTestCase

- (GBProcessor *)processorWithFind:(BOOL)find;
- (GBProcessor *)processorWithFind:(BOOL)find keepObjects:(BOOL)objects keepMembers:(BOOL)members;
- (GBClassData *)classWithName:(NSString *)name superclass:(NSString *)superclass method:(id)method;
- (GBClassData *)classWithName:(NSString *)name adopting:(GBProtocolData *)protocol method:(id)method;
- (GBProtocolData *)protocolWithName:(NSString *)name method:(id)method;
- (GBMethodData *)instanceMethodWithName:(NSString *)name comment:(id)comment;

@end

#pragma mark -

@implementation GBProcessorMembersDocumentationCopyingTesting

#pragma mark Superclass copying testing

- (void)testProcessObjectsFromStore_shouldCopyDocumentationFromSuperclassIfFindIsYes {
	// setup
	GBMethodData *original = [self instanceMethodWithName:@"method" comment:@"comment"];
	GBClassData *superclass = [self classWithName:@"Superclass" superclass:nil method:original];
	GBMethodData *derived = [self instanceMethodWithName:@"method" comment:nil];
	GBClassData *class = [self classWithName:@"Class" superclass:@"Superclass" method:derived];
	GBStore *store = [GBTestObjectsRegistry storeWithObjects:class, superclass, nil];
	GBProcessor *processor = [self processorWithFind:YES];
	// execute
	[processor processObjectsFromStore:store];
	// verify
	assertThat(derived.comment, is(original.comment));
}

- (void)testProcessObjectsFromStore_shouldCopyDocumentationFromAnySuperclassIfFindIsYes {
	// setup
	GBMethodData *original = [self instanceMethodWithName:@"method" comment:@"comment"];
	GBClassData *superclass = [self classWithName:@"Base" superclass:nil method:original];
	GBClassData *middle = [self classWithName:@"Middle" superclass:@"Base" method:nil];
	GBMethodData *derived = [self instanceMethodWithName:@"method" comment:nil];
	GBClassData *class = [self classWithName:@"Class" superclass:@"Middle" method:derived];
	GBStore *store = [GBTestObjectsRegistry storeWithObjects:class, middle, superclass, nil];
	GBProcessor *processor = [self processorWithFind:YES];
	// execute
	[processor processObjectsFromStore:store];
	// verify
	assertThat(derived.comment, is(original.comment));
}

- (void)testProcessObjectsFromStore_shouldNotCopyDocumentationFromSuperclassIfFindIsNo {
	// setup
	GBMethodData *original = [self instanceMethodWithName:@"method" comment:@"comment"];
	GBClassData *superclass = [self classWithName:@"Superclass" superclass:nil method:original];
	GBMethodData *derived = [self instanceMethodWithName:@"method" comment:nil];
	GBClassData *class = [self classWithName:@"Class" superclass:@"Superclass" method:derived];
	GBStore *store = [GBTestObjectsRegistry storeWithObjects:class, superclass, nil];
	GBProcessor *processor = [self processorWithFind:NO];
	// execute
	[processor processObjectsFromStore:store];
	// verify
	assertThat(derived.comment, is(nil));
}

- (void)testProcessObjectsFromStore_shouldCopyDocumentationFromSuperclassEvenIfUndocumentedObjectsShouldBeDeleted {
	// setup
	GBMethodData *original = [self instanceMethodWithName:@"method" comment:@"comment"];
	GBClassData *superclass = [self classWithName:@"Superclass" superclass:nil method:original];
	GBMethodData *derived = [self instanceMethodWithName:@"method" comment:nil];
	GBClassData *class = [self classWithName:@"Class" superclass:@"Superclass" method:derived];
	GBStore *store = [GBTestObjectsRegistry storeWithObjects:class, superclass, nil];
	GBProcessor *processor = [self processorWithFind:YES keepObjects:NO keepMembers:NO];
	// execute
	[processor processObjectsFromStore:store];
	// verify
	assertThat(derived.comment, is(original.comment));
}

#pragma mark Adopted protocols copying testing

- (void)testProcessObjectsFromStore_shouldCopyDocumentationFromAdoptedProtocolIfFindIsYes {
	// setup
	GBMethodData *original = [self instanceMethodWithName:@"method" comment:@"comment"];
	GBProtocolData *protocol = [self protocolWithName:@"Protocol" method:original];
	GBMethodData *derived = [self instanceMethodWithName:@"method" comment:nil];
	GBClassData *class = [self classWithName:@"Class" adopting:protocol method:derived];
	GBStore *store = [GBTestObjectsRegistry storeWithObjects:class, protocol, nil];
	GBProcessor *processor = [self processorWithFind:YES];
	// execute
	[processor processObjectsFromStore:store];
	// verify
	assertThat(derived.comment, is(original.comment));
}

- (void)testProcessObjectsFromStore_shouldCopyDocumentationFromAdoptedProtocolEvenIfUndocumentedObjectsShouldBeDeleted {
	// setup
	GBMethodData *original = [self instanceMethodWithName:@"method" comment:@"comment"];
	GBProtocolData *protocol = [self protocolWithName:@"Protocol" method:original];
	GBMethodData *derived = [self instanceMethodWithName:@"method" comment:nil];
	GBClassData *class = [self classWithName:@"Class" adopting:protocol method:derived];
	GBStore *store = [GBTestObjectsRegistry storeWithObjects:class, protocol, nil];
	GBProcessor *processor = [self processorWithFind:YES keepObjects:NO keepMembers:NO];
	// execute
	[processor processObjectsFromStore:store];
	// verify
	assertThat(derived.comment, is(original.comment));
}

#pragma mark Creation methods

- (GBClassData *)classWithName:(NSString *)name superclass:(NSString *)superclass method:(id)method {
	GBClassData *result = [GBClassData classDataWithName:name];
	result.nameOfSuperclass = superclass;
	if (method) [result.methods registerMethod:method];
	return result;
}

- (GBClassData *)classWithName:(NSString *)name adopting:(GBProtocolData *)protocol method:(id)method {
	GBClassData *result = [GBClassData classDataWithName:name];
	if (protocol) [result.adoptedProtocols registerProtocol:protocol];
	if (method) [result.methods registerMethod:method];
	return result;
}

- (GBProtocolData *)protocolWithName:(NSString *)name method:(id)method {
	GBProtocolData *result = [GBProtocolData protocolDataWithName:name];
	if (method) [result.methods registerMethod:method];
	return result;
}

- (GBMethodData *)instanceMethodWithName:(NSString *)name comment:(id)comment {
	GBMethodData *method = [GBTestObjectsRegistry instanceMethodWithNames:name, nil];
	if ([comment isKindOfClass:[NSString class]]) comment = [GBComment commentWithStringValue:comment];
	method.comment = comment;
	return method;
}

- (GBProcessor *)processorWithFind:(BOOL)find {
	return [self processorWithFind:find keepObjects:YES keepMembers:YES];
}

- (GBProcessor *)processorWithFind:(BOOL)find keepObjects:(BOOL)objects keepMembers:(BOOL)members {
	OCMockObject *settings = [GBTestObjectsRegistry mockSettingsProvider];
	[[[settings stub] andReturnValue:[NSNumber numberWithBool:find]] findUndocumentedMembersDocumentation];
	[[[settings stub] andReturnValue:[NSNumber numberWithBool:objects]] keepUndocumentedObjects];
	[[[settings stub] andReturnValue:[NSNumber numberWithBool:members]] keepUndocumentedMembers];
	[GBTestObjectsRegistry settingsProvider:settings keepObjects:YES keepMembers:YES];
	return [GBProcessor processorWithSettingsProvider:settings];
}

@end
