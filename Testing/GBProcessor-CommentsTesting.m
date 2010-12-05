//
//  GBProcessor-CommentsTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 27.8.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBDataObjects.h"
#import "GBStore.h"
#import "GBProcessor.h"

@interface GBProcessorCommentsTesting : GHTestCase

- (OCMockObject *)niceCommentMockExpectingRegisterParagraph;
- (OCMockObject *)settingsProviderKeepObjects:(BOOL)objects keepMembers:(BOOL)members;
- (GBClassData *)classWithComment:(BOOL)comment;
- (NSArray *)registerMethodsOfCount:(NSUInteger)count withComment:(BOOL)comment toObject:(id<GBObjectDataProviding>)provider;
- (NSString *)randomName;

@end

#pragma mark -

@implementation GBProcessorCommentsTesting

#pragma mark Classes comments processing

- (void)testProcessObjectsFromStore_shouldProcessClassComments {
	// setup
	GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	OCMockObject *comment = [self niceCommentMockExpectingRegisterParagraph];
	GBStore *store = [GBTestObjectsRegistry storeWithClassWithComment:comment];
	// execute
	[processor processObjectsFromStore:store];
	// verify - we just want to make sure we invoke comments processing!
	[comment verify];
}

- (void)testProcessObjectsFromStore_shouldProcessClassMethodComments {
	// setup
	GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	OCMockObject *comment1 = [self niceCommentMockExpectingRegisterParagraph];
	OCMockObject *comment2 = [self niceCommentMockExpectingRegisterParagraph];
	GBClassData *class = [GBClassData classDataWithName:@"Class"];
	[class.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithName:@"method1" comment:comment1]];
	[class.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithName:@"method2" comment:comment2]];
	GBStore *store = [GBTestObjectsRegistry storeByPerformingSelector:@selector(registerClass:) withObject:class];
	// execute
	[processor processObjectsFromStore:store];
	// verify - we just want to make sure we invoke comments processing!
	[comment1 verify];
	[comment2 verify];
}

#pragma mark Categories comments processing

- (void)testProcessObjectsFromStore_shouldProcessCategoryComments {
	// setup
	GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	OCMockObject *comment = [self niceCommentMockExpectingRegisterParagraph];
	GBStore *store = [GBTestObjectsRegistry storeWithCategoryWithComment:comment];
	// execute
	[processor processObjectsFromStore:store];
	// verify - we just want to make sure we invoke comments processing!
	[comment verify];
}

- (void)testProcessObjectsFromStore_shouldProcessCategoryMethodComments {
	// setup
	GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	OCMockObject *comment1 = [self niceCommentMockExpectingRegisterParagraph];
	OCMockObject *comment2 = [self niceCommentMockExpectingRegisterParagraph];
	GBCategoryData *category = [GBCategoryData categoryDataWithName:@"Category" className:@"Class"];
	[category.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithName:@"method1" comment:comment1]];
	[category.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithName:@"method2" comment:comment2]];
	GBStore *store = [GBTestObjectsRegistry storeByPerformingSelector:@selector(registerCategory:) withObject:category];
	// execute
	[processor processObjectsFromStore:store];
	// verify - we just want to make sure we invoke comments processing!
	[comment1 verify];
	[comment2 verify];
}

#pragma mark Protocols comments processing

- (void)testProcessObjectsFromStore_shouldProcessProtocolComments {
	// setup
	GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	OCMockObject *comment = [self niceCommentMockExpectingRegisterParagraph];
	GBStore *store = [GBTestObjectsRegistry storeWithProtocolWithComment:comment];
	// execute
	[processor processObjectsFromStore:store];
	// verify - we just want to make sure we invoke comments processing!
	[comment verify];
}

- (void)testProcessObjectsFromStore_shouldProcessProtocolMethodComments {
	// setup
	GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	OCMockObject *comment1 = [self niceCommentMockExpectingRegisterParagraph];
	OCMockObject *comment2 = [self niceCommentMockExpectingRegisterParagraph];
	GBProtocolData *protocol = [GBProtocolData protocolDataWithName:@"Protocol"];
	[protocol.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithName:@"method1" comment:comment1]];
	[protocol.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithName:@"method2" comment:comment2]];
	GBStore *store = [GBTestObjectsRegistry storeByPerformingSelector:@selector(registerProtocol:) withObject:protocol];
	// execute
	[processor processObjectsFromStore:store];
	// verify - we just want to make sure we invoke comments processing!
	[comment1 verify];
	[comment2 verify];
}

#pragma mark Method comment processing

- (void)testProcesObjectsFromStore_shouldMatchParameterDirectivesWithActualOrder {
	// setup
	GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"@param arg2 Description2\n@param arg3 Description3\n@param arg1 Description1"];
	GBClassData *class = [GBClassData classDataWithName:@"Class"];
	GBMethodData *method = [GBTestObjectsRegistry instanceMethodWithNames:@"arg1", @"arg2", @"arg3", nil];
	[method setComment:comment];
	[class.methods registerMethod:method];
	GBStore *store = [GBTestObjectsRegistry storeByPerformingSelector:@selector(registerClass:) withObject:class];
	// execute
	[processor processObjectsFromStore:store];
	// verify
	assertThatInteger([comment.parameters count], equalToInteger(3));
	assertThat([[comment.parameters objectAtIndex:0] argumentName], is(@"arg1"));
	assertThat([[comment.parameters objectAtIndex:1] argumentName], is(@"arg2"));
	assertThat([[comment.parameters objectAtIndex:2] argumentName], is(@"arg3"));
	assertThat([[[comment.parameters objectAtIndex:0] argumentDescription] stringValue], is(@"Description1"));
	assertThat([[[comment.parameters objectAtIndex:1] argumentDescription] stringValue], is(@"Description2"));
	assertThat([[[comment.parameters objectAtIndex:2] argumentDescription] stringValue], is(@"Description3"));
}

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

#pragma mark Creation methods

- (OCMockObject *)niceCommentMockExpectingRegisterParagraph {
	OCMockObject *result = [OCMockObject niceMockForClass:[GBComment class]];
	[[[result stub] andReturn:@"Paragraph"] stringValue];
	[[result expect] registerParagraph:OCMOCK_ANY];
	return result;
}

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
