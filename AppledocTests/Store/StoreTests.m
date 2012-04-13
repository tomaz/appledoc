//
//  StoreTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/12/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "TestCaseBase.h"

@interface Store (TestingPrivateAPI)
- (void)pushRegistrationObject:(id)object;
- (id)popRegistrationObject;
@property (nonatomic, readonly) NSArray *registrationStack;
@property (nonatomic, readonly) id currentRegistrationObject;
@end

#pragma mark - 

@interface StoreTests : TestCaseBase
@end

@interface StoreTests (CreationMethods)
- (void)runWithStore:(void(^)(Store *store))handler;
@end

@implementation StoreTests

#pragma mark - Verify handling of classes, categories and protocols

- (void)testBeginClassWithNameDerivedFromClassWithNameShouldRegisterClassInfo {
	[self runWithStore:^(Store *store) {
		// setup & execute
		[store beginClassWithName:@"Name" derivedFromClassWithName:@"Derived"];
		// verify
		assertThat(store.currentRegistrationObject, instanceOf([ClassInfo class]));
		assertThat([store.currentRegistrationObject nameOfClass], equalTo(@"Name"));
		assertThat([store.currentRegistrationObject nameOfSuperClass], equalTo(@"Derived"));
	}];
}

- (void)testBeginExtensionForClassWithNameShouldRegisterCategoryInfo {
	[self runWithStore:^(Store *store) {
		// setup & execute
		[store beginExtensionForClassWithName:@"Name"];
		// verify
		assertThat(store.currentRegistrationObject, instanceOf([CategoryInfo class]));
		assertThat([store.currentRegistrationObject nameOfClass], equalTo(@"Name"));
		assertThat([store.currentRegistrationObject nameOfCategory], equalTo(nil));
	}];
}

- (void)testBeginCategoryWithNameForClassWithNameShouldRegisterCategoryInfo {
	[self runWithStore:^(Store *store) {
		// setup & execute
		[store beginCategoryWithName:@"Category" forClassWithName:@"Name"];
		// verify
		assertThat(store.currentRegistrationObject, instanceOf([CategoryInfo class]));
		assertThat([store.currentRegistrationObject nameOfClass], equalTo(@"Name"));
		assertThat([store.currentRegistrationObject nameOfCategory], equalTo(@"Category"));
	}];
}

- (void)testBeginProtocolWithNameShouldRegisterProtocolInfo {
	[self runWithStore:^(Store *store) {
		// setup & execute
		[store beginProtocolWithName:@"Name"];
		// verify		
		assertThat(store.currentRegistrationObject, instanceOf([ProtocolInfo class]));
		assertThat([store.currentRegistrationObject nameOfProtocol], equalTo(@"Name"));
	}];
}

- (void)testAppendAdoptedProtocolShouldForwardToCurrentObject {
	[self runWithStore:^(Store *store) {
		// setup
		id mock = [OCMockObject mockForClass:[InterfaceInfoBase class]];
		[[mock expect] appendAdoptedProtocolWithName:@"name"];
		[store pushRegistrationObject:mock];
		// execute
		[store appendAdoptedProtocolWithName:@"name"];
		// verify
		STAssertNoThrow([mock verify], nil);
	}];
}

#pragma mark - Verify forwarding of method group related messages

- (void)testBeginMethodGroupShouldForwardToCurrentObject {
	[self runWithStore:^(Store *store) {
		// setup
		id mock = [OCMockObject mockForClass:[InterfaceInfoBase class]];
		[[mock expect] beginMethodGroup];
		[store pushRegistrationObject:mock];
		// execute
		[store beginMethodGroup];
		// verify
		STAssertNoThrow([mock verify], nil);
	}];
}

- (void)testAppendMethodGroupDescriptionShouldForwardToCurrentObject {
	[self runWithStore:^(Store *store) {
		// setup
		id mock = [OCMockObject mockForClass:[InterfaceInfoBase class]];
		[[mock expect] appendMethodGroupDescription:@"description"];
		[store pushRegistrationObject:mock];
		// execute
		[store appendMethodGroupDescription:@"description"];
		// verify
		STAssertNoThrow([mock verify], nil);
	}];
}

#pragma mark - Verify forwarding of property related messages

- (void)testBeginPropertyDefinitionShouldForwardToCurrentObject {
	[self runWithStore:^(Store *store) {
		// setup
		id mock = [OCMockObject mockForClass:[InterfaceInfoBase class]];
		[[mock expect] beginPropertyDefinition];
		[store pushRegistrationObject:mock];
		// execute
		[store beginPropertyDefinition];
		// verify
		STAssertNoThrow([mock verify], nil);
	}];
}

- (void)testBeginPropertyAttributesShouldForwardToCurrentObject {
	[self runWithStore:^(Store *store) {
		// setup
		id mock = [OCMockObject mockForClass:[InterfaceInfoBase class]];
		[[mock expect] beginPropertyAttributes];
		[store pushRegistrationObject:mock];
		// execute
		[store beginPropertyAttributes];
		// verify
		STAssertNoThrow([mock verify], nil);
	}];
}

- (void)testAppendPropertyNameShouldForwardToCurrentObject {
	[self runWithStore:^(Store *store) {
		// setup
		id mock = [OCMockObject mockForClass:[InterfaceInfoBase class]];
		[[mock expect] appendPropertyName:@"name"];
		[store pushRegistrationObject:mock];
		// execute
		[store appendPropertyName:@"name"];
		// verify
		STAssertNoThrow([mock verify], nil);
	}];
}

#pragma mark - Verify forwarding of method related messages

- (void)testBeginMethodDefinitionShouldForwardToCurrentObject {
	[self runWithStore:^(Store *store) {
		// setup
		id mock = [OCMockObject mockForClass:[InterfaceInfoBase class]];
		[[mock expect] beginMethodDefinition];
		[store pushRegistrationObject:mock];
		// execute
		[store beginMethodDefinition];
		// verify
		STAssertNoThrow([mock verify], nil);
	}];
}

- (void)testAppendMethodTypeShouldForwardToCurrentObject {
	[self runWithStore:^(Store *store) {
		// setup
		id mock = [OCMockObject mockForClass:[InterfaceInfoBase class]];
		[[mock expect] appendMethodType:@"type"];
		[store pushRegistrationObject:mock];
		// execute
		[store appendMethodType:@"type"];
		// verify
		STAssertNoThrow([mock verify], nil);
	}];
}

- (void)testBeginMethodArgumentShouldForwardToCurrentObject {
	[self runWithStore:^(Store *store) {
		// setup
		id mock = [OCMockObject mockForClass:[InterfaceInfoBase class]];
		[[mock expect] beginMethodArgument];
		[store pushRegistrationObject:mock];
		// execute
		[store beginMethodArgument];
		// verify
		STAssertNoThrow([mock verify], nil);
	}];
}

- (void)testAppendMethodArgumentSelectorShouldForwardToCurrentObject {
	[self runWithStore:^(Store *store) {
		// setup
		id mock = [OCMockObject mockForClass:[InterfaceInfoBase class]];
		[[mock expect] appendMethodArgumentSelector:@"selector"];
		[store pushRegistrationObject:mock];
		// execute
		[store appendMethodArgumentSelector:@"selector"];
		// verify
		STAssertNoThrow([mock verify], nil);
	}];
}

- (void)testAppendMethodArgumentVariableShouldForwardToCurrentObject {
	[self runWithStore:^(Store *store) {
		// setup
		id mock = [OCMockObject mockForClass:[InterfaceInfoBase class]];
		[[mock expect] appendMethodArgumentVariable:@"variable"];
		[store pushRegistrationObject:mock];
		// execute
		[store appendMethodArgumentVariable:@"variable"];
		// verify
		STAssertNoThrow([mock verify], nil);
	}];
}

#pragma mark - Verify handling of enumeration related messages

- (void)testBeginEnumerationShouldRegisterEnumInfo {
	[self runWithStore:^(Store *store) {
		// TODO!!! STFail(@"not implemented!");
	}];
}

- (void)testAppendEnumerationItemShouldForwardToCurrentObject {
	[self runWithStore:^(Store *store) {
		// setup
		id mock = [OCMockObject mockForClass:[InterfaceInfoBase class]];
		// TODO!!! [[mock expect] appendEnumerationItem:@"value"];
		[store pushRegistrationObject:mock];
		// execute
		[store appendEnumerationItem:@"value"];
		// verify
		// TODO!!! STAssertNoThrow([mock verify], nil);
	}];
}

- (void)testAppendEnumerationValueShouldForwardToCurrentObject {
	[self runWithStore:^(Store *store) {
		// setup
		id mock = [OCMockObject mockForClass:[InterfaceInfoBase class]];
		// TODO!!! [[mock expect] appendEnumerationValue:@"value"];
		[store pushRegistrationObject:mock];
		// execute
		[store appendEnumerationValue:@"variable"];
		// verify
		// TODO!!! STAssertNoThrow([mock verify], nil);
	}];
}

#pragma mark - Verify handling of struct related messages

- (void)testBeginStructShouldRegistrStructInfo {
	[self runWithStore:^(Store *store) {
		// TODO!!! STFail(@"not implemented!");
	}];
}

#pragma mark - Verify handling of constant related messages

- (void)testBeginConstantShouldRegisterConstantInfoIfRegistrationStackIsEmpty {
	[self runWithStore:^(Store *store) {
		// TODO!!! STFail(@"not implemented!");
	}];
}

- (void)testBeginConstantShouldForwardToCurrentObjectIfAvailable {
	[self runWithStore:^(Store *store) {
		// setup
		id mock = [OCMockObject mockForClass:[InterfaceInfoBase class]];
		// TODO!!! [[mock expect] beginConstant];
		[store pushRegistrationObject:mock];
		// execute
		[store beginConstant];
		// verify
		// TODO!!! STAssertNoThrow([mock verify], nil);
	}];
}

- (void)testAppendConstantTypeShouldForwardToCurrentObject {
	[self runWithStore:^(Store *store) {
		// setup
		id mock = [OCMockObject mockForClass:[InterfaceInfoBase class]];
		// TODO!!! [[mock expect] appendConstantType:@"value"];
		[store pushRegistrationObject:mock];
		// execute
		[store appendConstantType:@"value"];
		// verify
		// TODO!!! STAssertNoThrow([mock verify], nil);
	}];
}

- (void)testAppendConstantNameShouldForwardToCurrentObject {
	[self runWithStore:^(Store *store) {
		// setup
		id mock = [OCMockObject mockForClass:[InterfaceInfoBase class]];
		// TODO!!! [[mock expect] appendConstantName:@"value"];
		[store pushRegistrationObject:mock];
		// execute
		[store appendConstantName:@"value"];
		// verify
		// TODO!!! STAssertNoThrow([mock verify], nil);
	}];
}

#pragma mark - endCurrentObject

- (void)testEndCurrentObjectShouldForwardToCurrentObjectIfAvailable {
	[self runWithStore:^(Store *store) {
		// setup
		id mock = [OCMockObject mockForClass:[InterfaceInfoBase class]];
		[[mock expect] endCurrentObject];
		[store pushRegistrationObject:mock];
		// execute
		[store endCurrentObject];
		// verify
		STAssertNoThrow([mock verify], nil);
	}];
}

- (void)testEndCurrentObjectShouldRemoveCurrentObjectFromStackIfAvailable {
	[self runWithStore:^(Store *store) {
		// setup
		id mock = [OCMockObject niceMockForClass:[InterfaceInfoBase class]];
		[store pushRegistrationObject:mock];
		// execute
		[store endCurrentObject];
		// verify		
		assertThat(store.currentRegistrationObject, equalTo(nil));
		assertThatUnsignedInteger(store.registrationStack.count, equalToUnsignedInteger(0));
	}];
}

#pragma mark - cancelCurrentObject

- (void)testCancelCurrentObjectShouldForwardToCurrentObjectIfAvailable {
	[self runWithStore:^(Store *store) {
		// setup
		id mock = [OCMockObject mockForClass:[InterfaceInfoBase class]];
		[[mock expect] cancelCurrentObject];
		[store pushRegistrationObject:mock];
		// execute
		[store cancelCurrentObject];
		// verify
		STAssertNoThrow([mock verify], nil);
	}];
}

- (void)testCancelCurrentObjectShouldRemoveCurrentObjectFromStackIfAvailable {
	[self runWithStore:^(Store *store) {
		// setup
		id mock = [OCMockObject niceMockForClass:[InterfaceInfoBase class]];
		[store pushRegistrationObject:mock];
		// execute
		[store cancelCurrentObject];
		// verify		
		assertThat(store.currentRegistrationObject, equalTo(nil));
		assertThatUnsignedInteger(store.registrationStack.count, equalToUnsignedInteger(0));
	}];
}

@end

#pragma mark - 

@implementation StoreTests (CreationMethods)

- (void)runWithStore:(void(^)(Store *store))handler {
	Store *store = [Store new];
	handler(store);
}

@end
