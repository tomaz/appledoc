//
//  StoreTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/12/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "TestCaseBase.hh"

@interface Store (UnitTestingPrivateAPI)
@property (nonatomic, strong) NSMutableArray *registrationStack;
@end

#pragma mark - 

static void runWithStore(void(^handler)(Store *store)) {
	Store *store = [[Store alloc] init];
	handler(store);
	[store release];
}

#pragma mark - 

TEST_BEGIN(StoreTests)

describe(@"lazy accessors:", ^{
	it(@"should initialize objects", ^{
		runWithStore(^(Store *store) {
			// execute & verify
			store.storeClasses should_not be_nil();
			store.storeExtensions should_not be_nil();
			store.storeCategories should_not be_nil();
			store.storeProtocols should_not be_nil();
			store.storeEnumerations should_not be_nil();
			store.storeStructs should_not be_nil();
			store.storeConstants should_not be_nil();
			store.registrationStack should_not be_nil();
		});
	});
});

describe(@"current source info:", ^{
	it(@"should store info to property", ^{
		runWithStore(^(Store *store) {
			// execute
			store.currentSourceInfo = (PKToken *)@"dummy-source-token";
			// verify
			store.currentSourceInfo should equal(@"dummy-source-token");
		});
	});
	
	it(@"should pass info to current object on registration stack if it supports it", ^{
		runWithStore(^(Store *store) {
			// setup
			id object = [OCMockObject mockForClass:[ObjectInfoBase class]];
			[[object expect] setCurrentSourceInfo:(PKToken *)@"dummy-source-token"];
			[store pushRegistrationObject:object];
			// execute
			[store setCurrentSourceInfo:(PKToken *)@"dummy-source-token"];
			// verify
			^{ [object verify]; } should_not raise_exception();
		});
	});

	it(@"should remember object even if passed to current object on registration stack", ^{
		runWithStore(^(Store *store) {
			// setup
			id object = [OCMockObject niceMockForClass:[ObjectInfoBase class]];
			[store pushRegistrationObject:object];
			// execute
			[store setCurrentSourceInfo:(PKToken *)@"dummy-source-token"];
			// verify
			store.currentSourceInfo should equal(@"dummy-source-token");
		});
	});
	
	it(@"should not pass into to current object on registration stack if it doesn't support it", ^{
		runWithStore(^(Store *store) {
			// setup - note that this will raise exception if any message is sent to object.
			id object = [OCMockObject mockForClass:[NSObject class]];
			[store pushRegistrationObject:object];
			// execute
			[store setCurrentSourceInfo:(PKToken *)@"dummy-source-token"];
		});
	});
});

describe(@"class registration:", ^{
	it(@"should add class info to registration stack", ^{
	   runWithStore(^(Store *store) {
		   // execute
		   [store beginClassWithName:@"name" derivedFromClassWithName:@"derived"];
		   // verify
		   store.currentRegistrationObject should be_instance_of([ClassInfo class]);
		   [store.currentRegistrationObject nameOfSuperClass] should equal(@"derived");
		   [store.currentRegistrationObject objectRegistrar] should equal(store);
	   });
	});
	
	it(@"should add class info to classes array", ^{
		runWithStore(^(Store *store) {
			// execute
			[store beginClassWithName:@"name" derivedFromClassWithName:@"derived"];
			// verify
			store.storeClasses.count should equal(1);
			store.storeClasses should contain(store.currentRegistrationObject);
		});
	});
	
	it(@"should set current source info to class", ^{
		runWithStore(^(Store *store) {
			// setup
			store.currentSourceInfo = (PKToken *)@"dummy-source-info";
			// execute
			[store beginClassWithName:@"name" derivedFromClassWithName:@"derived"];
			// verify
			[store.currentRegistrationObject sourceToken] should equal(store.currentSourceInfo);
		});
	});
});

describe(@"class extension registration:", ^{
	it(@"should add category info to registration stack", ^{
		runWithStore(^(Store *store) {
			// execute
			[store beginExtensionForClassWithName:@"name"];
			// verify
			store.currentRegistrationObject should be_instance_of([CategoryInfo class]);
			[store.currentRegistrationObject nameOfClass] should equal(@"name");
			[store.currentRegistrationObject nameOfCategory] should be_nil();
			[store.currentRegistrationObject objectRegistrar] should equal(store);
		});
	});
	
	it(@"should add category info to extensions array", ^{
		runWithStore(^(Store *store) {
			// execute
			[store beginExtensionForClassWithName:@"name"];
			// verify
			store.storeExtensions.count should equal(1);
			store.storeExtensions should contain(store.currentRegistrationObject);
		});
	});
	
	it(@"should set current source info to category", ^{
		runWithStore(^(Store *store) {
			// setup
			store.currentSourceInfo = (PKToken *)@"dummy-source-info";
			// execute
			[store beginExtensionForClassWithName:@"name"];
			// verify
			[store.currentRegistrationObject sourceToken] should equal(store.currentSourceInfo);
		});
	});
});

describe(@"class category registration:", ^{
	it(@"should add category info to registration stack", ^{
		runWithStore(^(Store *store) {
			// execute
			[store beginCategoryWithName:@"category" forClassWithName:@"name"];
			// verify
			store.currentRegistrationObject should be_instance_of([CategoryInfo class]);
			[store.currentRegistrationObject nameOfClass] should equal(@"name");
			[store.currentRegistrationObject nameOfCategory] should equal(@"category");
			[store.currentRegistrationObject objectRegistrar] should equal(store);
		});
	});
	
	it(@"should add category info to categories array", ^{
		runWithStore(^(Store *store) {
			// execute
			[store beginCategoryWithName:@"category" forClassWithName:@"name"];
			// verify
			store.storeCategories.count should equal(1);
			store.storeCategories should contain(store.currentRegistrationObject);
		});
	});
	
	it(@"should set current source info to class", ^{
		runWithStore(^(Store *store) {
			// setup
			store.currentSourceInfo = (PKToken *)@"dummy-source-info";
			// execute
			[store beginCategoryWithName:@"category" forClassWithName:@"class"];
			// verify
			[store.currentRegistrationObject sourceToken] should equal(store.currentSourceInfo);
		});
	});
});

describe(@"protocol registration:", ^{
	it(@"should add protocol info to registration stack", ^{
		runWithStore(^(Store *store) {
			// execute
			[store beginProtocolWithName:@"name"];
			// verify		
			store.currentRegistrationObject should be_instance_of([ProtocolInfo class]);
			[store.currentRegistrationObject nameOfProtocol] should equal(@"name");
			[store.currentRegistrationObject objectRegistrar] should equal(store);
		});
	});
	
	it(@"should add protocol info to protocols array", ^{
		runWithStore(^(Store *store) {
			// execute
			[store beginProtocolWithName:@"name"];
			// verify
			store.storeProtocols.count should equal(1);
			store.storeProtocols should contain(store.currentRegistrationObject);
		});
	});
	
	it(@"should set current source info to class", ^{
		runWithStore(^(Store *store) {
			// setup
			store.currentSourceInfo = (PKToken *)@"dummy-source-info";
			// execute
			[store beginProtocolWithName:@"name"];
			// verify
			[store.currentRegistrationObject sourceToken] should equal(store.currentSourceInfo);
		});
	});
});

describe(@"interface related methods:", ^{
	it(@"should forward apend adopted protocol to current registration object", ^{
		runWithStore(^(Store *store) {
			// setup
			id mock = [OCMockObject mockForClass:[Store class]];
			[[mock expect] appendAdoptedProtocolWithName:@"name"];
			[store pushRegistrationObject:mock];
			// execute
			[store appendAdoptedProtocolWithName:@"name"];
			// verify
			^{ [mock verify]; } should_not raise_exception();
		});
	});
});

describe(@"method group related methods:", ^{
	it(@"should forward append method group description to current registration object", ^{
		runWithStore(^(Store *store) {
			// setup
			id mock = [OCMockObject mockForClass:[Store class]];
			[[mock expect] appendMethodGroupWithDescription:@"description"];
			[store pushRegistrationObject:mock];
			// execute
			[store appendMethodGroupWithDescription:@"description"];
			// verify
			^{ [mock verify]; } should_not raise_exception();
		});
	});
});

describe(@"property related methods:", ^{
	it(@"should forward begin property definition to current registration object", ^{
		runWithStore(^(Store *store) {			
			// setup
			id mock = [OCMockObject mockForClass:[Store class]];
			[[mock expect] beginPropertyDefinition];
			[store pushRegistrationObject:mock];
			// execute
			[store beginPropertyDefinition];
			// verify
			^{ [mock verify]; } should_not raise_exception();
		});
	});

	it(@"should forward begin property attributes to current registration object", ^{
		runWithStore(^(Store *store) {			
			// setup
			id mock = [OCMockObject mockForClass:[Store class]];
			[[mock expect] beginPropertyAttributes];
			[store pushRegistrationObject:mock];
			// execute
			[store beginPropertyAttributes];
			// verify
			^{ [mock verify]; } should_not raise_exception();
		});
	});

	it(@"should forward begin property types to current registration object", ^{
		runWithStore(^(Store *store) {			
			// setup
			id mock = [OCMockObject mockForClass:[Store class]];
			[[mock expect] beginPropertyTypes];
			[store pushRegistrationObject:mock];
			// execute
			[store beginPropertyTypes];
			// verify
			^{ [mock verify]; } should_not raise_exception();
		});
	});

	it(@"should forward begin property descriptors to current registration object", ^{
		runWithStore(^(Store *store) {			
			// setup
			id mock = [OCMockObject mockForClass:[Store class]];
			[[mock expect] beginPropertyDescriptors];
			[store pushRegistrationObject:mock];
			// execute
			[store beginPropertyDescriptors];
			// verify
			^{ [mock verify]; } should_not raise_exception();
		});
	});

	it(@"should forward append property name to current registration object", ^{
		runWithStore(^(Store *store) {			
			// setup
			id mock = [OCMockObject mockForClass:[Store class]];
			[[mock expect] appendPropertyName:@"name"];
			[store pushRegistrationObject:mock];
			// execute
			[store appendPropertyName:@"name"];
			// verify
			^{ [mock verify]; } should_not raise_exception();
		});
	});
});

describe(@"method related registration:", ^{
	it(@"should forward begin method definition to current registration object", ^{
		runWithStore(^(Store *store) {
			// setup
			id mock = [OCMockObject mockForClass:[Store class]];
			[[mock expect] beginMethodDefinitionWithType:@"type"];
			[store pushRegistrationObject:mock];
			// execute
			[store beginMethodDefinitionWithType:@"type"];
			// verify
			^{ [mock verify]; } should_not raise_exception();
		});
	});

	it(@"should forward begin method results to current registration object", ^{
		runWithStore(^(Store *store) {
			// setup
			id mock = [OCMockObject mockForClass:[Store class]];
			[[mock expect] beginMethodResults];
			[store pushRegistrationObject:mock];
			// execute
			[store beginMethodResults];
			// verify
			^{ [mock verify]; } should_not raise_exception();
		});
	});

	it(@"should forward begin method argument to current registration object", ^{
		runWithStore(^(Store *store) {
			// setup
			id mock = [OCMockObject mockForClass:[Store class]];
			[[mock expect] beginMethodArgument];
			[store pushRegistrationObject:mock];
			// execute
			[store beginMethodArgument];
			// verify
			^{ [mock verify]; } should_not raise_exception();
		});
	});

	it(@"should forward begin method argument types to current registration object", ^{
		runWithStore(^(Store *store) {
			// setup
			id mock = [OCMockObject mockForClass:[Store class]];
			[[mock expect] beginMethodArgumentTypes];
			[store pushRegistrationObject:mock];
			// execute
			[store beginMethodArgumentTypes];
			// verify
			^{ [mock verify]; } should_not raise_exception();
		});
	});

	it(@"should forward begin method descriptors to current registration object", ^{
		runWithStore(^(Store *store) {
			// setup
			id mock = [OCMockObject mockForClass:[Store class]];
			[[mock expect] beginMethodDescriptors];
			[store pushRegistrationObject:mock];
			// execute
			[store beginMethodDescriptors];
			// verify
			^{ [mock verify]; } should_not raise_exception();
		});
	});
	
	it(@"should forward append method argument selector to current registration object", ^{
		runWithStore(^(Store *store) {
			// setup
			id mock = [OCMockObject mockForClass:[Store class]];
			[[mock expect] appendMethodArgumentSelector:@"selector"];
			[store pushRegistrationObject:mock];
			// execute
			[store appendMethodArgumentSelector:@"selector"];
			// verify
			^{ [mock verify]; } should_not raise_exception();
		});
	});
	
	it(@"should forward append method argument variable to current registration object", ^{
		runWithStore(^(Store *store) {
			// setup
			id mock = [OCMockObject mockForClass:[Store class]];
			[[mock expect] appendMethodArgumentVariable:@"variable"];
			[store pushRegistrationObject:mock];
			// execute
			[store appendMethodArgumentVariable:@"variable"];
			// verify
			^{ [mock verify]; } should_not raise_exception();
		});
	});
});

describe(@"enum related registration:", ^{
	it(@"should add enumeration info to registration stack", ^{
		runWithStore(^(Store *store) {			
			// execute
			[store beginEnumeration];
			// verify
			store.currentRegistrationObject should be_instance_of([EnumInfo class]);
			[store.currentRegistrationObject objectRegistrar] should equal(store);
		});
	});

	it(@"should add enumeration info to enumerations array", ^{
		runWithStore(^(Store *store) {			
			// execute
			[store beginEnumeration];
			// verify
			store.storeEnumerations.count should equal(1);
			store.storeEnumerations should contain(store.currentRegistrationObject);
		});
	});
	
	it(@"should set current source info to class", ^{
		runWithStore(^(Store *store) {
			// setup
			store.currentSourceInfo = (PKToken *)@"dummy-source-info";
			// execute
			[store beginEnumeration];
			// verify
			[store.currentRegistrationObject sourceToken] should equal(store.currentSourceInfo);
		});
	});

	it(@"should forward append enumeration name to current registration object", ^{
		runWithStore(^(Store *store) {
			// setup
			id mock = [OCMockObject mockForClass:[Store class]];
			[[mock expect] appendEnumerationName:@"value"];
			[store pushRegistrationObject:mock];
			// execute
			[store appendEnumerationName:@"value"];
			// verify
			^{ [mock verify]; } should_not raise_exception();
		});
	});
	
	it(@"should forward append enumeration item to current registration object", ^{
		runWithStore(^(Store *store) {
			// setup
			id mock = [OCMockObject mockForClass:[Store class]];
			[[mock expect] appendEnumerationItem:@"value"];
			[store pushRegistrationObject:mock];
			// execute
			[store appendEnumerationItem:@"value"];
			// verify
			^{ [mock verify]; } should_not raise_exception();
		});
	});
	
	it(@"should forward append enumeration value to current registration object", ^{
		runWithStore(^(Store *store) {
			// setup
			id mock = [OCMockObject mockForClass:[Store class]];
			[[mock expect] appendEnumerationValue:@"value"];
			[store pushRegistrationObject:mock];
			// execute
			[store appendEnumerationValue:@"value"];
			// verify
			^{ [mock verify]; } should_not raise_exception();
		});
	});
});

describe(@"struct related registration:", ^{
	it(@"should add struct info to registration stack", ^{
		runWithStore(^(Store *store) {
			// execute
			[store beginStruct];
			// verify
			store.currentRegistrationObject should be_instance_of([StructInfo class]);
			[store.currentRegistrationObject objectRegistrar] should equal(store);
		});
	});

	it(@"should add struct info to structs array", ^{
		runWithStore(^(Store *store) {			
			// execute
			[store beginStruct];
			// verify
			store.storeStructs.count should equal(1);
			store.storeStructs should contain(store.currentRegistrationObject);
		});
	});
	
	it(@"should set current source info to class", ^{
		runWithStore(^(Store *store) {
			// setup
			store.currentSourceInfo = (PKToken *)@"dummy-source-info";
			// execute
			[store beginStruct];
			// verify
			[store.currentRegistrationObject sourceToken] should equal(store.currentSourceInfo);
		});
	});
	
	it(@"should forward append struct name to current registration object", ^{
		runWithStore(^(Store *store) {
			// setup
			id mock = [OCMockObject mockForClass:[Store class]];
			[[mock expect] appendStructName:@"value"];
			[store pushRegistrationObject:mock];
			// execute
			[store appendStructName:@"value"];
			// verify
			^{ [mock verify]; } should_not raise_exception();
		});
	});
});

describe(@"constant related registration:", ^{
	describe(@"if registration stack is empty:", ^{
		it(@"should add constant info to registration stack", ^{
			runWithStore(^(Store *store) {
				// execute
				[store beginConstant];
				// verify
				store.currentRegistrationObject should be_instance_of([ConstantInfo class]);
				[store.currentRegistrationObject objectRegistrar] should equal(store);
			});
		});

		it(@"should add constant info to constants array", ^{
			runWithStore(^(Store *store) {
				// execute
				[store beginConstant];
				// verify
				store.storeConstants.count should equal(1);
				store.storeConstants should contain(store.currentRegistrationObject);
			});
		});
		
		it(@"should set current source info to class", ^{
			runWithStore(^(Store *store) {
				// setup
				store.currentSourceInfo = (PKToken *)@"dummy-source-info";
				// execute
				[store beginConstant];
				// verify
				[store.currentRegistrationObject sourceToken] should equal(store.currentSourceInfo);
			});
		});		
	});
	
	describe(@"if registration stack is not empty, but current object doesn't handle constants:", ^{
		it(@"should add constant info to registration stack", ^{
			runWithStore(^(Store *store) {
				// setup
				[store pushRegistrationObject:[[NSObject new] autorelease]];
				// execute
				[store beginConstant];
				// verify
				store.currentRegistrationObject should be_instance_of([ConstantInfo class]);
				[store.currentRegistrationObject objectRegistrar] should equal(store);
			});
		});
		
		it(@"should add constant info to constants array", ^{
			runWithStore(^(Store *store) {
				// setup
				[store pushRegistrationObject:[[NSObject new] autorelease]];
				// execute
				[store beginConstant];
				// verify
				store.storeConstants.count should equal(1);
				store.storeConstants should contain(store.currentRegistrationObject);
			});
		});
	});
	
	describe(@"if current registration object handles constants:", ^{
		it(@"should forward begin constant to curent registration object", ^{
			runWithStore(^(Store *store) {
				// setup
				id mock = [OCMockObject mockForClass:[Store class]];
				[[mock expect] beginConstant];
				[store pushRegistrationObject:mock];
				// execute
				[store beginConstant];
				// verify
				^{ [mock verify]; } should_not raise_exception();
				store.storeConstants.count should equal(0);
			});
		});
	});

	it(@"should forward begin constant types to current registration object", ^{
		runWithStore(^(Store *store) {
			// setup
			id mock = [OCMockObject mockForClass:[Store class]];
			[[mock expect] beginConstantTypes];
			[store pushRegistrationObject:mock];
			// execute
			[store beginConstantTypes];
			// verify
			^{ [mock verify]; } should_not raise_exception();
		});
	});

	it(@"should forward begin constant descriptors to current registration object", ^{
		runWithStore(^(Store *store) {
			// setup
			id mock = [OCMockObject mockForClass:[Store class]];
			[[mock expect] beginConstantDescriptors];
			[store pushRegistrationObject:mock];
			// execute
			[store beginConstantDescriptors];
			// verify
			^{ [mock verify]; } should_not raise_exception();
		});
	});
	
	it(@"should forward append constant name to current registration object", ^{
		runWithStore(^(Store *store) {
			// setup
			id mock = [OCMockObject mockForClass:[Store class]];
			[[mock expect] appendConstantName:@"value"];
			[store pushRegistrationObject:mock];
			// execute
			[store appendConstantName:@"value"];
			// verify
			^{ [mock verify]; } should_not raise_exception();
		});
	});
});

describe(@"common registrations:", ^{
	it(@"should forward append type to current registration object", ^{
		runWithStore(^(Store *store) {
			// setup
			id mock = [OCMockObject mockForClass:[Store class]];
			[[mock expect] appendType:@"value"];
			[store pushRegistrationObject:mock];
			// execute
			[store appendType:@"value"];
			// verify
			^{ [mock verify]; } should_not raise_exception();
		});
	});

	it(@"should forward append attribute to current registration object", ^{
		runWithStore(^(Store *store) {
			// setup
			id mock = [OCMockObject mockForClass:[Store class]];
			[[mock expect] appendAttribute:@"value"];
			[store pushRegistrationObject:mock];
			// execute
			[store appendAttribute:@"value"];
			// verify
			^{ [mock verify]; } should_not raise_exception();
		});
	});

	it(@"should forward append description to current registration object", ^{
		runWithStore(^(Store *store) {
			// setup
			id mock = [OCMockObject mockForClass:[Store class]];
			[[mock expect] appendDescriptor:@"value"];
			[store pushRegistrationObject:mock];
			// execute
			[store appendDescriptor:@"value"];
			// verify
			^{ [mock verify]; } should_not raise_exception();
		});
	});
});

describe(@"comments registrations:", ^{
	describe(@"previous object:", ^{
		it(@"should create comment and add it to last popped object", ^{
			runWithStore(^(Store *store) {
				// setup
				id object = [OCMockObject mockForClass:[ObjectInfoBase class]];
				[[object expect] setComment:[OCMArg checkWithBlock:^BOOL(id obj) {
					if (![obj isKindOfClass:[CommentInfo class]]) return NO;
					if (![[obj sourceString] isEqualToString:@"text"]) return NO;
					return YES;
				}]];
				[store pushRegistrationObject:object];
				[store popRegistrationObject];
				// execute
				[store appendCommentToPreviousObject:@"text"];
				// verify
				^{ [object verify]; } should_not raise_exception();
			});
		});

		it(@"should append current source info to token", ^{
			runWithStore(^(Store *store) {
				// setup
				PKToken *token = [PKToken tokenWithTokenType:PKTokenTypeComment stringValue:@"text" floatValue:0.0];
				id object = [OCMockObject mockForClass:[ObjectInfoBase class]];
				[[object expect] setComment:[OCMArg checkWithBlock:^BOOL(id obj) {
					return ([obj sourceToken] == token);
				}]];
				[store pushRegistrationObject:object];
				[store popRegistrationObject];
				// execute
				[store setCurrentSourceInfo:token];
				[store appendCommentToPreviousObject:@"text"];
				// verify
				^{ [object verify]; } should_not raise_exception();
			});
		});
	});
	
	describe(@"next object", ^{
		it(@"should not add comment to current object", ^{
			runWithStore(^(Store *store) {
				// setup - no expectations needed; strong mock will fail if any unexpected message is received
				id object = [OCMockObject mockForClass:[ObjectInfoBase class]];
				[store pushRegistrationObject:object];
				// execute
				[store appendCommentToNextObject:@"text"];
				// verify
				^{ [object verify]; } should_not raise_exception();
			});
		});

		it(@"should add comment to first object registered after appending comment", ^{
			runWithStore(^(Store *store) {
				// setup
				id object = [OCMockObject mockForClass:[ObjectInfoBase class]];
				[[object expect] setComment:[OCMArg checkWithBlock:^BOOL(id obj) {
					if (![obj isKindOfClass:[CommentInfo class]]) return NO;
					if (![[obj sourceString] isEqualToString:@"text"]) return NO;
					return YES;
				}]];
				// execute
				[store appendCommentToNextObject:@"text"];
				[store pushRegistrationObject:object];
				// verify
				^{ [object verify]; } should_not raise_exception();
			});
		});
		
		it(@"should clear comment after appending to new object", ^{
			runWithStore(^(Store *store) {
				// setup - no expectations required for second mock; strong mocks fail if any unexpected message is received
				id object1 = [OCMockObject niceMockForClass:[ObjectInfoBase class]];
				id object2 = [OCMockObject mockForClass:[ObjectInfoBase class]];
				[store appendCommentToNextObject:@"text"];
				[store pushRegistrationObject:object1];
				// execute
				[store pushRegistrationObject:object2];
				// verify
				^{ [object1 verify]; } should_not raise_exception();
				^{ [object2 verify]; } should_not raise_exception();
			});
		});
	});
});

describe(@"end current object:", ^{
	it(@"should remove last object from registration stack", ^{
		runWithStore(^(Store *store) {
			// setup
			[store pushRegistrationObject:[OCMockObject niceMockForClass:[Store class]]];
			// execute
			[store endCurrentObject];
			// verify
			store.registrationStack.count should equal(0);
			store.currentRegistrationObject should be_nil();
		});
	});

	it(@"should forward to semilast object on registration stack if it handles end message, then remove last object from registration stack", ^{
		runWithStore(^(Store *store) {
			// setup
			id first = [OCMockObject mockForClass:[Store class]];
			[[first expect] endCurrentObject];
			[store pushRegistrationObject:first];
			id second = [OCMockObject mockForClass:[Store class]];
			[store pushRegistrationObject:second];
			// execute
			[store endCurrentObject];
			// verify
			^{ [first verify]; } should_not raise_exception();
			^{ [second verify]; } should_not raise_exception();
			store.registrationStack.count should equal(1);
			store.registrationStack should contain(first);
			store.currentRegistrationObject should equal(first);
		});
	});
	
	it(@"should not forward to semilast object on registration stack if it doesn't respond to end message, but should remove last object from registration stack", ^{
		runWithStore(^(Store *store) {
			// setup
			id first = [OCMockObject mockForClass:[NSObject class]];
			[store pushRegistrationObject:first];
			id second = [OCMockObject mockForClass:[Store class]];
			[[second stub] isKindOfClass:OCMOCK_ANY];
			[store pushRegistrationObject:second];
			// execute
			[store endCurrentObject];
			// verify
			^{ [first verify]; } should_not raise_exception();
			^{ [second verify]; } should_not raise_exception();
			store.registrationStack.count should equal(1);
			store.registrationStack should contain(first);
			store.currentRegistrationObject should equal(first);
		});
	});
	
	it(@"should ignore if registration stack is empty", ^{
		runWithStore(^(Store *store) {
			// execute
			[store endCurrentObject];
			// verify - real code logs a warning, but we don't test that here
			store.registrationStack.count should equal(0);
			store.currentRegistrationObject should be_nil();
		});
	});
});

describe(@"cancel current object:", ^{
	describe(@"if registration stack contains at least two objects:", ^{
		it(@"should forward to semilast object if it responds to message, then remove last object from registration stack", ^{
			runWithStore(^(Store *store) {
				// setup
				id first = [OCMockObject mockForClass:[Store class]];
				[[first expect] cancelCurrentObject];
				[store pushRegistrationObject:first];
				id second = [OCMockObject mockForClass:[Store class]];
				[store pushRegistrationObject:second];
				// execute
				[store cancelCurrentObject];
				// verify
				^{ [first verify]; } should_not raise_exception();
				^{ [second verify]; } should_not raise_exception();
				store.registrationStack.count should equal(1);
				store.registrationStack should contain(first);
				store.currentRegistrationObject should equal(first);
			});
		});

		it(@"should not forward to semilast object if it responds to message, but should remove last object from registration stack", ^{
			runWithStore(^(Store *store) {
				// setup
				id first = [OCMockObject mockForClass:[NSObject class]];
				[store pushRegistrationObject:first];
				id second = [OCMockObject mockForClass:[Store class]];
				[[second stub] isKindOfClass:OCMOCK_ANY];
				[store pushRegistrationObject:second];
				// execute
				[store cancelCurrentObject];
				// verify
				^{ [first verify]; } should_not raise_exception();
				^{ [second verify]; } should_not raise_exception();
				store.registrationStack.count should equal(1);
				store.registrationStack should contain(first);
				store.currentRegistrationObject should equal(first);
			});
		});
	});
	
	describe(@"if registration stack contains one object:", ^{
		it(@"should remove last object from registration stack", ^{
			runWithStore(^(Store *store) {
				// setup
				[store pushRegistrationObject:[OCMockObject niceMockForClass:[Store class]]];
				// execute
				[store cancelCurrentObject];
				// verify
				store.registrationStack.count should equal(0);
				store.currentRegistrationObject should be_nil();
			});
		});
	});
	
	describe(@"if registration stack is emtpy:", ^{
		it(@"should ignore", ^{
			runWithStore(^(Store *store) {
				// execute
				[store cancelCurrentObject];
				// verify - real code logs a warning, but we don't test that here, just verify no exception is thrown
				store.registrationStack.count should equal(0);
				store.currentRegistrationObject should be_nil();
			});
		});
	});
	
	describe(@"registered data handling:", ^{
		it(@"should remove last class", ^{
			runWithStore(^(Store *store) {
				// setup
				[store beginClassWithName:@"name" derivedFromClassWithName:@"derived"];
				// execute
				[store cancelCurrentObject];
				// verify
				store.storeClasses.count should equal(0);
				store.currentRegistrationObject should be_nil();
			});
		});
		
		it(@"should remove last class extension", ^{
			runWithStore(^(Store *store) {
				// setup
				[store beginExtensionForClassWithName:@"name"];
				// execute
				[store cancelCurrentObject];
				// verify
				store.storeExtensions.count should equal(0);
				store.currentRegistrationObject should be_nil();
			});
		});
		
		it(@"should remove last class category", ^{
			runWithStore(^(Store *store) {
				// setup
				[store beginCategoryWithName:@"category" forClassWithName:@"name"];
				// execute
				[store cancelCurrentObject];
				// verify
				store.storeCategories.count should equal(0);
				store.currentRegistrationObject should be_nil();
			});
		});
		
		it(@"should remove last protocol", ^{
			runWithStore(^(Store *store) {
				// setup
				[store beginProtocolWithName:@"name"];
				// execute
				[store cancelCurrentObject];
				// verify
				store.storeProtocols.count should equal(0);
				store.currentRegistrationObject should be_nil();
			});
		});
		
		it(@"should remove last enum", ^{
			runWithStore(^(Store *store) {
				// setup
				[store beginEnumeration];
				// execute
				[store cancelCurrentObject];
				// verify
				store.storeEnumerations.count should equal(0);
				store.currentRegistrationObject should be_nil();
			});
		});
		
		it(@"should remove last struct", ^{
			runWithStore(^(Store *store) {
				// setup
				[store beginStruct];
				// execute
				[store cancelCurrentObject];
				// verify
				store.storeStructs.count should equal(0);
				store.currentRegistrationObject should be_nil();
			});
		});
		
		it(@"should remove last constant", ^{
			runWithStore(^(Store *store) {
				// setup
				[store beginConstant];
				// execute
				[store cancelCurrentObject];
				// verify
				store.storeConstants.count should equal(0);
				store.currentRegistrationObject should be_nil();
			});
		});
	});
});

describe(@"registration stack handling:", ^{
	describe(@"pushing objects:", ^{
		it(@"should push registration object and update current registration object", ^{
			runWithStore(^(Store *store) {
				// setup
				id child = @"child";
				// execute
				[store pushRegistrationObject:child];
				// verify
				store.registrationStack.count should equal(1);
				store.registrationStack should contain(child);
				store.currentRegistrationObject should equal(child);
			});
		});
		
		it(@"should push multiple objects and update current registration object", ^{
			runWithStore(^(Store *store) {
				// setup
				id child1 = @"child1";
				id child2 = @"child2";
				// execute
				[store pushRegistrationObject:child1];
				[store pushRegistrationObject:child2];
				// verify
				store.registrationStack.count should equal(2);
				(store.registrationStack)[0] should equal(child1);
				(store.registrationStack)[1] should equal(child2);
				store.currentRegistrationObject should equal(child2);
			});
		});
	});
	
	describe(@"popping objects:", ^{
		it(@"should remove last object from stack with multiple objects", ^{
			runWithStore(^(Store *store) {
				// setup
				id child1 = @"child1";
				id child2 = @"child2";
				[store pushRegistrationObject:child1];
				[store pushRegistrationObject:child2];
				// execute
				id poppedObject = [store popRegistrationObject];
				// verify
				store.registrationStack.count should equal(1);
				(store.registrationStack)[0] should equal(child1);
				store.currentRegistrationObject should equal(child1);
				poppedObject should equal(child2);
			});
		});
		
		it(@"should remove last object from stack", ^{
			runWithStore(^(Store *store) {
				// setup
				id child = @"child1";
				[store pushRegistrationObject:child];
				// execute
				id poppedObject = [store popRegistrationObject];
				// verify
				store.registrationStack.count should equal(0);
				store.currentRegistrationObject should be_nil();
				poppedObject should equal(child);
			});
		});
		
		it(@"should ignore if stack is empty", ^{
			runWithStore(^(Store *store) {
				// execute
				id poppedObject = [store popRegistrationObject];
				// verify - note that in this case we log a warning, but we don't test that...
				store.registrationStack.count should equal(0);
				store.currentRegistrationObject should be_nil();
				poppedObject should be_nil();
			});
		});
	});
});

describe(@"cache handling:", ^{
	describe(@"top level objects:", ^{
		it(@"should return class", ^{
			runWithStore(^(Store *store) {
				// setup
				[store beginClassWithName:@"name" derivedFromClassWithName:@"super"];
				// execute
				ClassInfo *object = [store topLevelObjectWithName:@"name"];
				// verify
				object should be_instance_of([ClassInfo class]);
				object.nameOfClass should equal(@"name");
				object.nameOfSuperClass should equal(@"super");
			});
		});

		it(@"should return extension", ^{
			runWithStore(^(Store *store) {
				// setup
				[store beginExtensionForClassWithName:@"name"];
				// execute
				CategoryInfo *object = [store topLevelObjectWithName:@"name()"];
				// verify
				object should be_instance_of([CategoryInfo class]);
				object.nameOfClass should equal(@"name");
				object.nameOfCategory should be_nil();
			});
		});
		
		it(@"should return category", ^{
			runWithStore(^(Store *store) {
				// setup
				[store beginCategoryWithName:@"category" forClassWithName:@"name"];
				// execute
				CategoryInfo *object = [store topLevelObjectWithName:@"name(category)"];
				// verify
				object should be_instance_of([CategoryInfo class]);
				object.nameOfClass should equal(@"name");
				object.nameOfCategory should equal(@"category");
			});
		});
	});
});

TEST_END
