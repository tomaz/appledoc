//
//  GBProcessor-UndocumentedObjectsTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 5.12.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBDataObjects.h"
#import "GBStore.h"
#import "GBProcessor.h"

@interface GBProcessorUndocumentedObjectsTesting : GHTestCase

- (OCMockObject *)settingsProviderKeepObjects:(BOOL)objects keepMembers:(BOOL)members;
- (GBClassData *)classWithComment:(BOOL)comment;
- (GBCategoryData *)categoryWithComment:(BOOL)comment;
- (GBProtocolData *)protocolWithComment:(BOOL)comment;
- (NSArray *)registerMethodsOfCount:(NSUInteger)count withComment:(BOOL)comment toObject:(id<GBObjectDataProviding>)provider;
- (NSString *)randomName;

@end

#pragma mark -

@implementation GBProcessorUndocumentedObjectsTesting

#pragma mark Undocumented objects handling

- (void)testProcessObjectsFromStore_shouldKeepUncommentedObjectIfKeepObjectsIsYes {
	// setup
	GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[self settingsProviderKeepObjects:YES keepMembers:NO]];
	GBClassData *class = [self classWithComment:NO];
	GBStore *store = [GBTestObjectsRegistry storeByPerformingSelector:@selector(registerClass:) withObject:class];
	// execute
	[processor processObjectsFromStore:store];
	// verify
	assertThatInteger([store.classes count], equalToInteger(1));
	assertThatBool([store.classes containsObject:class], equalToBool(YES));
}

- (void)testProcessObjectsFromStore_shouldKeepUncommentedObjectIfItHasCommentedMembers {
	// setup
	GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[self settingsProviderKeepObjects:NO keepMembers:NO]];
	GBClassData *class = [self classWithComment:NO];
	GBStore *store = [GBTestObjectsRegistry storeByPerformingSelector:@selector(registerClass:) withObject:class];
	[self registerMethodsOfCount:1 withComment:YES toObject:class];
	[self registerMethodsOfCount:1 withComment:NO toObject:class];
	// execute
	[processor processObjectsFromStore:store];
	// verify
	assertThatInteger([store.classes count], equalToInteger(1));
	assertThatBool([store.classes containsObject:class], equalToBool(YES));
}

- (void)testProcessObjectsFromStore_shouldDeleteUncommentedObjectIfKeepObjectsIsNo {
	// setup
	GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[self settingsProviderKeepObjects:NO keepMembers:NO]];
	GBClassData *class = [self classWithComment:NO];
	GBStore *store = [GBTestObjectsRegistry storeByPerformingSelector:@selector(registerClass:) withObject:class];
	// execute
	[processor processObjectsFromStore:store];
	// verify
	assertThatInteger([store.classes count], equalToInteger(0));
}

- (void)testProcessObjectsFromStore_shouldDeleteUncommentedClassesCategoriesAndProtocols {
	// setup - we just check that all types of top-level objects are handled; we only test other specifics on classes to avoid duplication.
	GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[self settingsProviderKeepObjects:NO keepMembers:NO]];
	GBStore *store = [[GBStore alloc] init];
	[store registerClass:[self classWithComment:NO]];
	[store registerCategory:[self categoryWithComment:NO]];
	[store registerProtocol:[self protocolWithComment:NO]];
	// execute
	[processor processObjectsFromStore:store];
	// verify
	assertThatInteger([store.classes count], equalToInteger(0));
	assertThatInteger([store.categories count], equalToInteger(0));
	assertThatInteger([store.protocols count], equalToInteger(0));
}

#pragma mark Undocumented methods handling

- (void)testProcessObjectsFromStore_shouldKeepUncommentedMethodsIfKeepMembersIsYes {
	// setup
	GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[self settingsProviderKeepObjects:YES keepMembers:YES]];
	GBClassData *class = [self classWithComment:YES];
	NSArray *uncommented = [self registerMethodsOfCount:1 withComment:NO toObject:class];
	GBStore *store = [GBTestObjectsRegistry storeByPerformingSelector:@selector(registerClass:) withObject:class];
	// execute
	[processor processObjectsFromStore:store];
	// verify
	NSArray *methods = [class.methods methods];
 	assertThatInteger([methods count], equalToInteger(1));
	assertThatBool([methods containsObject:[uncommented objectAtIndex:0]], equalToBool(YES));
}

- (void)testProcessObjectsFromStore_shouldDeleteUncommentedMethodsIfKeepMembersIsNo {
	// setup
	GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[self settingsProviderKeepObjects:YES keepMembers:NO]];
	GBClassData *class = [self classWithComment:YES];
	NSArray *commented = [self registerMethodsOfCount:1 withComment:YES toObject:class];
	NSArray *uncommented = [self registerMethodsOfCount:1 withComment:NO toObject:class];
	GBStore *store = [GBTestObjectsRegistry storeByPerformingSelector:@selector(registerClass:) withObject:class];
	// execute
	[processor processObjectsFromStore:store];
	// verify
	NSArray *methods = [class.methods methods];
 	assertThatInteger([methods count], equalToInteger(1));
	assertThatBool([methods containsObject:[commented objectAtIndex:0]], equalToBool(YES));
	assertThatBool([methods containsObject:[uncommented objectAtIndex:0]], equalToBool(NO));
}

- (void)testProcessObjectsFromStore_shouldKeepUncommentedObjectIfAllMethodsAreUnregisteredIfKeepObjectIsYes {
	// setup
	GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[self settingsProviderKeepObjects:YES keepMembers:NO]];
	GBClassData *class = [self classWithComment:NO];
	GBStore *store = [GBTestObjectsRegistry storeByPerformingSelector:@selector(registerClass:) withObject:class];
	[self registerMethodsOfCount:1 withComment:NO toObject:class];
	// execute
	[processor processObjectsFromStore:store];
	// verify
	assertThatBool([store.classes containsObject:class], equalToBool(YES));
}

- (void)testProcessObjectsFromStore_shouldDeleteUncommentedObjectIfAllMethodsAreUnregisteredIfKeepObjectIsNo {
	// setup
	GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[self settingsProviderKeepObjects:NO keepMembers:NO]];
	GBClassData *class = [self classWithComment:NO];
	GBStore *store = [GBTestObjectsRegistry storeByPerformingSelector:@selector(registerClass:) withObject:class];
	[self registerMethodsOfCount:1 withComment:NO toObject:class];
	// execute
	[processor processObjectsFromStore:store];
	// verify
	assertThatBool([store.classes containsObject:class], equalToBool(NO));
}

#pragma mark Creation methods

- (OCMockObject *)settingsProviderKeepObjects:(BOOL)objects keepMembers:(BOOL)members {
	OCMockObject *result = [GBTestObjectsRegistry mockSettingsProvider];
	[GBTestObjectsRegistry settingsProvider:result keepObjects:objects keepMembers:members];
	return result;
}

- (GBClassData *)classWithComment:(BOOL)comment {
	GBClassData *result = [GBClassData classDataWithName:[self randomName]];
	if (comment) result.comment = [GBComment commentWithStringValue:@"comment"];
	return result;
}

- (GBCategoryData *)categoryWithComment:(BOOL)comment {
	GBCategoryData *result = [GBCategoryData categoryDataWithName:[self randomName] className:[self randomName]];
	if (comment) result.comment = [GBComment commentWithStringValue:@"comment"];
	return result;
}

- (GBProtocolData *)protocolWithComment:(BOOL)comment {
	GBProtocolData *result = [GBProtocolData protocolDataWithName:[self randomName]];
	if (comment) result.comment = [GBComment commentWithStringValue:@"comment"];
	return result;
}

- (NSArray *)registerMethodsOfCount:(NSUInteger)count withComment:(BOOL)comment toObject:(id<GBObjectDataProviding>)provider {
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:count];
	for (NSUInteger i=0; i<count; i++) {
		GBMethodData *method = [GBTestObjectsRegistry instanceMethodWithNames:[self randomName], nil];
		if (comment) method.comment = [GBComment commentWithStringValue:@"comment"];
		if (provider) [provider.methods registerMethod:method];
		[result addObject:method];
	}
	return result;
}

- (NSString *)randomName {
	NSUInteger value = random();
	return [NSString stringWithFormat:@"N%ld", value];
}

@end
