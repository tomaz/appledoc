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

@end
