//
//  PropertyInfoTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/17/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "TestCaseBase.h"

@interface PropertyInfoTests : TestCaseBase
@end

@interface PropertyInfoTests (CreationMethods)
- (void)runWithPropertyInfo:(void(^)(PropertyInfo *info))handler;
@end

@implementation PropertyInfoTests

#pragma mark - Verify lazy initialization

- (void)testLazyInitializersWork {
	[self runWithPropertyInfo:^(PropertyInfo *info) {
		// execute & verify
		assertThat(info.propertyAttributes, instanceOf([AttributesInfo class]));
		assertThat(info.propertyType, instanceOf([TypeInfo class]));
	}];
}

#pragma mark - Verify getter and setter selectors

- (void)testPropertyGetterAndSetterSelectorShouldReturnDefaultName {
	[self runWithPropertyInfo:^(PropertyInfo *info) {
		// setup
		info.propertyName = @"name";
		// execute & verify
		assertThat(info.propertyGetterSelector, equalTo(@"name"));
		assertThat(info.propertySetterSelector, equalTo(@"setName:"));
	}];
}

- (void)testPropertyGetterAndSetterSelectorShouldReturnValueFromAttributes {
	[self runWithPropertyInfo:^(PropertyInfo *info) {
		// setup
		info.propertyName = @"name";
		info.propertyAttributes.attributeItems = [NSMutableArray arrayWithObjects:@"getter", @"=", @"isName", @"setter", @"=", @"setNewName", nil];
		// execute & verify
		assertThat(info.propertyGetterSelector, equalTo(@"isName"));
		assertThat(info.propertySetterSelector, equalTo(@"setNewName:"));
	}];
}

- (void)testPropertyGetterSelectorShouldReturnValueFromAttributesWhileCustomSetterIsNotGiven {
	[self runWithPropertyInfo:^(PropertyInfo *info) {
		// setup
		info.propertyName = @"name";
		info.propertyAttributes.attributeItems = [NSMutableArray arrayWithObjects:@"getter", @"=", @"isName", nil];
		// execute & verify
		assertThat(info.propertyGetterSelector, equalTo(@"isName"));
		assertThat(info.propertySetterSelector, equalTo(@"setName:"));
	}];
}

- (void)testPropertySetterSelectorShouldReturnValueFromAttributesWhileCustomGetterIsNotGiven {
	[self runWithPropertyInfo:^(PropertyInfo *info) {
		// setup
		info.propertyName = @"name";
		info.propertyAttributes.attributeItems = [NSMutableArray arrayWithObjects:@"setter", @"=", @"setNewName", nil];
		// execute & verify
		assertThat(info.propertyGetterSelector, equalTo(@"name"));
		assertThat(info.propertySetterSelector, equalTo(@"setNewName:"));
	}];
}

#pragma mark - beginPropertyAttributes

- (void)testBeginPropertyAttributesShouldChangeCurrentRegistrationObjectToAttributes {
	[self runWithPropertyInfo:^(PropertyInfo *info) {
		// setup
		id mock = [OCMockObject mockForClass:[Store class]];
		[[mock expect] pushRegistrationObject:[OCMArg checkWithBlock:^BOOL(id obj) {
			return [obj isKindOfClass:[AttributesInfo class]];
		}]];
		info.objectRegistrar = mock;
		// execute
		[info beginPropertyAttributes];
		// verify
		STAssertNoThrow([mock verify], nil);
	}];
}

#pragma mark - beginPropertyTypes

- (void)testBeginPropertyTypesShouldChangeCurrentRegistrationObjectToResults {
	[self runWithPropertyInfo:^(PropertyInfo *info) {
		// setup
		id mock = [OCMockObject mockForClass:[Store class]];
		[[mock expect] pushRegistrationObject:[OCMArg checkWithBlock:^BOOL(id obj) {
			return [obj isKindOfClass:[TypeInfo class]];
		}]];
		info.objectRegistrar = mock;
		// execute
		[info beginPropertyTypes];
		// verify
		STAssertNoThrow([mock verify], nil);
	}];
}

#pragma mark - appendPropertyName:

- (void)testAppendPropertyNameShouldAssignGivenString {
	[self runWithPropertyInfo:^(PropertyInfo *info) {
		// execute
		[info appendPropertyName:@"value"];
		// verify
		assertThat(info.propertyName, equalTo(@"value"));
	}];
}

- (void)testAppendPropertyNameSelectorShouldUseLastValueIfSentMultipleTimes {
	[self runWithPropertyInfo:^(PropertyInfo *info) {
		// execute
		[info appendPropertyName:@"value1"];
		[info appendPropertyName:@"value2"];
		// verify
		assertThat(info.propertyName, equalTo(@"value2"));
	}];
}


@end

#pragma mark - 

@implementation PropertyInfoTests (CreationMethods)

- (void)runWithPropertyInfo:(void(^)(PropertyInfo *info))handler {
	PropertyInfo *info = [PropertyInfo new];
	handler(info);
}

@end
