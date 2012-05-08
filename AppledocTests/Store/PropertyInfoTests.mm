//
//  PropertyInfoTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/17/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "TestCaseBase.hh"

static void runWithPropertyInfo(void(^handler)(PropertyInfo *info)) {
	PropertyInfo *info = [[PropertyInfo alloc] init];
	handler(info);
	[info release];
}

#pragma mark - 

TEST_BEGIN(PropertyInfoTests)

describe(@"lazy accessors:", ^{
	it(@"should initialize objects", ^{
		runWithPropertyInfo(^(PropertyInfo *info) {
			// execute & verify
			info.propertyType should be_instance_of([TypeInfo class]);
			info.propertyAttributes should be_instance_of([AttributesInfo class]);
			info.propertyDescriptors should be_instance_of([DescriptorsInfo class]);
		});
	});
});

describe(@"getter and setter selectors:", ^{
	it(@"should return default name if no attribute is given", ^{
		runWithPropertyInfo(^(PropertyInfo *info) {
			// setup
			info.propertyName = @"name";
			// execute & verify
			info.propertyGetterSelector should equal(@"name");
			info.propertySetterSelector should equal(@"setName:");
		});
	});
	
	it(@"should return value from attributes if both are given", ^{
		runWithPropertyInfo(^(PropertyInfo *info) {
			// setup
			info.propertyName = @"name";
			info.propertyAttributes.attributeItems = [NSMutableArray arrayWithObjects:@"getter", @"=", @"isName", @"setter", @"=", @"setNewName", nil];
			// execute & verify
			info.propertyGetterSelector should equal(@"isName");
			info.propertySetterSelector should equal(@"setNewName:");
		});
	});
	
	it(@"should return custom getter value and revert to default setter if only getter is specified", ^{
		runWithPropertyInfo(^(PropertyInfo *info) {
			// setup
			info.propertyName = @"name";
			info.propertyAttributes.attributeItems = [NSMutableArray arrayWithObjects:@"getter", @"=", @"isName", nil];
			// execute & verify
			info.propertyGetterSelector should equal(@"isName");
			info.propertySetterSelector should equal(@"setName:");
		});
	});
	
	it(@"should return custom setter value and revert to default getter if only setter is specified", ^{
		runWithPropertyInfo(^(PropertyInfo *info) {
			// setup
			info.propertyName = @"name";
			info.propertyAttributes.attributeItems = [NSMutableArray arrayWithObjects:@"setter", @"=", @"setNewName", nil];
			// execute & verify
			info.propertyGetterSelector should equal(@"name");
			info.propertySetterSelector should equal(@"setNewName:");
		});
	});
});

describe(@"property descriptors registration:", ^{
	it(@"should push descriptors info to registration stack", ^{
		runWithPropertyInfo(^(PropertyInfo *info) {
			// setup
			id mock = [OCMockObject mockForClass:[Store class]];
			[[mock expect] pushRegistrationObject:info.propertyDescriptors];
			info.objectRegistrar = mock;
			// execute
			[info beginPropertyDescriptors];
			// verify
			^{ [mock verify]; } should_not raise_exception();
		});
	});
});

describe(@"property attributes registration:", ^{
	it(@"should push attributes info to registration stack", ^{
		runWithPropertyInfo(^(PropertyInfo *info) {
			// setup
			id mock = [OCMockObject mockForClass:[Store class]];
			[[mock expect] pushRegistrationObject:info.propertyAttributes];
			info.objectRegistrar = mock;
			// execute
			[info beginPropertyAttributes];
			// verify
			^{ [mock verify]; } should_not raise_exception();
		});
	});
});

describe(@"property types registration:", ^{
	it(@"should push property type info to registration stack", ^{
		runWithPropertyInfo(^(PropertyInfo *info) {
			// setup
			id mock = [OCMockObject mockForClass:[Store class]];
			[[mock expect] pushRegistrationObject:info.propertyType];
			info.objectRegistrar = mock;
			// execute
			[info beginPropertyTypes];
			// verify
			^{ [mock verify]; } should_not raise_exception();
		});
	});
});

describe(@"property name registration:", ^{
	it(@"should assign given string", ^{
		runWithPropertyInfo(^(PropertyInfo *info) {
			// execute
			[info appendPropertyName:@"value"];
			// verify
			info.propertyName should equal(@"value");
		});
	});
	
	it(@"should use last value if sent multiple times", ^{
		runWithPropertyInfo(^(PropertyInfo *info) {
			// execute
			[info appendPropertyName:@"value1"];
			[info appendPropertyName:@"value2"];
			// verify
			info.propertyName should equal(@"value2");
		});
	});
});

TEST_END
