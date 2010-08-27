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

@interface GBProcessorCommentsTesting : SenTestCase   
@end

#pragma mark -

@implementation GBProcessorCommentsTesting

#pragma mark Classes processing

- (void)testProcessObjectsFromStore_shouldProcessClassComments {
	// setup
	GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	OCMockObject *comment = [OCMockObject niceMockForClass:[GBComment class]];
	GBStore *store = [GBTestObjectsRegistry storeWithClassWithComment:comment];
	[[comment expect] processCommentWithStore:store];
	// execute
	[processor processObjectsFromStore:store];
	// verify - we only check that comment receive process message here, details are tested with comments!
	[comment verify];
}

- (void)testProcessObjectsFromStore_shouldProcessClassMethodComments {
	// setup
	GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	OCMockObject *comment1 = [OCMockObject niceMockForClass:[GBComment class]];
	OCMockObject *comment2 = [OCMockObject niceMockForClass:[GBComment class]];
	GBClassData *class = [GBClassData classDataWithName:@"Class"];
	[class.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithName:@"method1" comment:comment1]];
	[class.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithName:@"method2" comment:comment2]];
	GBStore *store = [GBTestObjectsRegistry storeByPerformingSelector:@selector(registerClass:) withObject:class];
	[[comment1 expect] processCommentWithStore:store];
	[[comment2 expect] processCommentWithStore:store];
	// execute
	[processor processObjectsFromStore:store];
	// verify - we only check that comments receive process message here, details are tested with comments!
	[comment1 verify];
	[comment2 verify];
}

#pragma mark Categories processing

- (void)testProcessObjectsFromStore_shouldProcessCategoryComments {
	// setup
	GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	OCMockObject *comment = [OCMockObject niceMockForClass:[GBComment class]];
	GBStore *store = [GBTestObjectsRegistry storeWithCategoryWithComment:comment];
	[[comment expect] processCommentWithStore:store];
	// execute
	[processor processObjectsFromStore:store];
	// verify - we only check that comment receive process message here, details are tested with comments!
	[comment verify];
}

- (void)testProcessObjectsFromStore_shouldProcessCategoryMethodComments {
	// setup
	GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	OCMockObject *comment1 = [OCMockObject niceMockForClass:[GBComment class]];
	OCMockObject *comment2 = [OCMockObject niceMockForClass:[GBComment class]];
	GBCategoryData *category = [GBCategoryData categoryDataWithName:@"Category" className:@"Class"];
	[category.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithName:@"method1" comment:comment1]];
	[category.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithName:@"method2" comment:comment2]];
	GBStore *store = [GBTestObjectsRegistry storeByPerformingSelector:@selector(registerCategory:) withObject:category];
	[[comment1 expect] processCommentWithStore:store];
	[[comment2 expect] processCommentWithStore:store];
	// execute
	[processor processObjectsFromStore:store];
	// verify - we only check that comments receive process message here, details are tested with comments!
	[comment1 verify];
	[comment2 verify];
}

#pragma mark Protocols processing

- (void)testProcessObjectsFromStore_shouldProcessProtocolComments {
	// setup
	GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	OCMockObject *comment = [OCMockObject niceMockForClass:[GBComment class]];
	GBStore *store = [GBTestObjectsRegistry storeWithProtocolWithComment:comment];
	[[comment expect] processCommentWithStore:store];
	// execute
	[processor processObjectsFromStore:store];
	// verify - we only check that comment receive process message here, details are tested with comments!
	[comment verify];
}

- (void)testProcessObjectsFromStore_shouldProcessProtocolMethodComments {
	// setup
	GBProcessor *processor = [GBProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	OCMockObject *comment1 = [OCMockObject niceMockForClass:[GBComment class]];
	OCMockObject *comment2 = [OCMockObject niceMockForClass:[GBComment class]];
	GBProtocolData *protocol = [GBProtocolData protocolDataWithName:@"Protocol"];
	[protocol.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithName:@"method1" comment:comment1]];
	[protocol.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithName:@"method2" comment:comment2]];
	GBStore *store = [GBTestObjectsRegistry storeByPerformingSelector:@selector(registerProtocol:) withObject:protocol];
	[[comment1 expect] processCommentWithStore:store];
	[[comment2 expect] processCommentWithStore:store];
	// execute
	[processor processObjectsFromStore:store];
	// verify - we only check that comments receive process message here, details are tested with comments!
	[comment1 verify];
	[comment2 verify];
}

@end
