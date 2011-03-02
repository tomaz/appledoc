//
//  GBMethodsProviderTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 26.7.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBTestObjectsRegistry.h"
#import "GBDataObjects.h"
#import "GBMethodsProvider.h"

@interface GBMethodsProviderTesting : GHTestCase
@end

@implementation GBMethodsProviderTesting

#pragma mark Method registration testing

- (void)testRegisterMethod_shouldAddMethodToList {
	// setup
	GBMethodsProvider *provider = [[GBMethodsProvider alloc] initWithParentObject:self];
	GBMethodData *method = [GBTestObjectsRegistry instanceMethodWithNames:@"method", nil];
	// execute
	[provider registerMethod:method];
	// verify
	assertThatInteger([provider.methods count], equalToInteger(1));
	assertThat([[provider.methods objectAtIndex:0] methodSelector], is(@"method:"));
}

- (void)testRegisterMethod_shouldSetParentObject {
	// setup
	GBMethodsProvider *provider = [[GBMethodsProvider alloc] initWithParentObject:self];
	GBMethodData *method = [GBTestObjectsRegistry instanceMethodWithNames:@"method", nil];
	// execute
	[provider registerMethod:method];
	// verify
	assertThat(method.parentObject, is(self));
}

- (void)testRegisterMethod_shouldIgnoreSameInstance {
	// setup
	GBMethodsProvider *provider = [[GBMethodsProvider alloc] initWithParentObject:self];
	GBMethodData *method = [GBTestObjectsRegistry instanceMethodWithNames:@"method", nil];
	// execute
	[provider registerMethod:method];
	[provider registerMethod:method];
	// verify
	assertThatInteger([provider.methods count], equalToInteger(1));
}

- (void)testRegisterMethod_shouldAllowSameSelectorIfDifferentType {
	// setup
	GBMethodsProvider *provider = [[GBMethodsProvider alloc] initWithParentObject:self];
	GBMethodData *method1 = [GBTestObjectsRegistry instanceMethodWithNames:@"method", nil];
	GBMethodData *method2 = [GBTestObjectsRegistry classMethodWithNames:@"method", nil];
	// execute
	[provider registerMethod:method1];
	[provider registerMethod:method2];
	// verify
	assertThatInteger([provider.methods count], equalToInteger(2));
	assertThat([[provider.methods objectAtIndex:0] methodSelector], is(@"method:"));
	assertThatInteger([[provider.methods objectAtIndex:0] methodType], equalToInteger(GBMethodTypeInstance));
	assertThat([[provider.methods objectAtIndex:1] methodSelector], is(@"method:"));
	assertThatInteger([[provider.methods objectAtIndex:1] methodType], equalToInteger(GBMethodTypeClass));
}

- (void)testRegisterMethod_shouldMapMethodBySelectorToInstanceMethodRegardlessOfRegistrationOrder {
	// setup
	GBMethodsProvider *provider1 = [[GBMethodsProvider alloc] initWithParentObject:self];
	GBMethodsProvider *provider2 = [[GBMethodsProvider alloc] initWithParentObject:self];
	GBMethodData *method1 = [GBTestObjectsRegistry instanceMethodWithNames:@"method", nil];
	GBMethodData *method2 = [GBTestObjectsRegistry classMethodWithNames:@"method", nil];
	// execute
	[provider1 registerMethod:method1];
	[provider1 registerMethod:method2];
	[provider2 registerMethod:method2];
	[provider2 registerMethod:method1];
	// verify
	assertThat([provider1 methodBySelector:@"method:"], is(method1));
	assertThat([provider2 methodBySelector:@"method:"], is(method1));
}

- (void)testRegisterMethod_shouldMapMethodBySelectorToPropertyRegardlessOfRegistrationOrder {
	// setup
	GBMethodsProvider *provider1 = [[GBMethodsProvider alloc] initWithParentObject:self];
	GBMethodsProvider *provider2 = [[GBMethodsProvider alloc] initWithParentObject:self];
	GBMethodData *method1 = [GBTestObjectsRegistry propertyMethodWithArgument:@"method"];
	GBMethodData *method2 = [GBTestObjectsRegistry classMethodWithArguments:[GBMethodArgument methodArgumentWithName:@"method"],  nil];
	// execute
	[provider1 registerMethod:method1];
	[provider1 registerMethod:method2];
	[provider2 registerMethod:method2];
	[provider2 registerMethod:method1];
	// verify
	assertThat([provider1 methodBySelector:@"method"], is(method1));
	assertThat([provider2 methodBySelector:@"method"], is(method1));
}

- (void)testRegisterMethod_shouldMergeDifferentInstanceWithSameName {
	// setup
	GBMethodType expectedType = GBMethodTypeInstance;
	GBMethodsProvider *provider = [[GBMethodsProvider alloc] initWithParentObject:self];
	GBMethodData *source = [GBTestObjectsRegistry instanceMethodWithNames:@"method", nil];
	OCMockObject *destination = [OCMockObject niceMockForClass:[GBMethodData class]];
	[[[destination stub] andReturn:@"method:"] methodSelector];
	[[[destination stub] andReturnValue:[NSValue value:&expectedType withObjCType:@encode(GBMethodType)]] methodType];
	[[destination expect] mergeDataFromObject:source];
	[provider registerMethod:(GBMethodData *)destination];
	// execute
	[provider registerMethod:source];
	// verify
	[destination verify];
}

#pragma mark Class methods, instance methods & properties handling

- (void)testRegisterMethod_shouldRegisterClassMethod {
	// setup
	GBMethodsProvider *provider = [[GBMethodsProvider alloc] initWithParentObject:self];
	GBMethodData *method = [GBTestObjectsRegistry classMethodWithNames:@"method", nil];
	// execute
	[provider registerMethod:method];
	// verify
	assertThatInteger([provider.classMethods count], equalToInteger(1));
	assertThat([provider.classMethods objectAtIndex:0], is(method));
}

- (void)testRegisterMethod_shouldRegisterInstanceMethod {
	// setup
	GBMethodsProvider *provider = [[GBMethodsProvider alloc] initWithParentObject:self];
	GBMethodData *method = [GBTestObjectsRegistry instanceMethodWithNames:@"method", nil];
	// execute
	[provider registerMethod:method];
	// verify
	assertThatInteger([provider.instanceMethods count], equalToInteger(1));
	assertThat([provider.instanceMethods objectAtIndex:0], is(method));
}

- (void)testRegisterMethod_shouldRegisterProperty {
	// setup
	GBMethodsProvider *provider = [[GBMethodsProvider alloc] initWithParentObject:self];
	GBMethodData *method = [GBTestObjectsRegistry propertyMethodWithArgument:@"name"];
	// execute
	[provider registerMethod:method];
	// verify
	assertThatInteger([provider.properties count], equalToInteger(1));
	assertThat([provider.properties objectAtIndex:0], is(method));
}

- (void)testRegisterMethod_shouldRegisterDifferentTypesOfMethodsAndUseProperSorting {
	// setup
	GBMethodsProvider *provider = [[GBMethodsProvider alloc] initWithParentObject:self];
	GBMethodData *class1 = [GBTestObjectsRegistry classMethodWithNames:@"class1", nil];
	GBMethodData *class2 = [GBTestObjectsRegistry classMethodWithNames:@"class2", nil];
	GBMethodData *instance1 = [GBTestObjectsRegistry instanceMethodWithNames:@"instance1", nil];
	GBMethodData *instance2 = [GBTestObjectsRegistry instanceMethodWithNames:@"instance2", nil];
	GBMethodData *property1 = [GBTestObjectsRegistry propertyMethodWithArgument:@"name1"];
	GBMethodData *property2 = [GBTestObjectsRegistry propertyMethodWithArgument:@"name2"];
	// execute
	[provider registerMethod:class1];
	[provider registerMethod:instance2];
	[provider registerMethod:property2];
	[provider registerMethod:class2];
	[provider registerMethod:property1];
	[provider registerMethod:instance1];
	// verify
	assertThatInteger([provider.classMethods count], equalToInteger(2));
	assertThat([provider.classMethods objectAtIndex:0], is(class1));
	assertThat([provider.classMethods objectAtIndex:1], is(class2));
	assertThatInteger([provider.instanceMethods count], equalToInteger(2));
	assertThat([provider.instanceMethods objectAtIndex:0], is(instance1));
	assertThat([provider.instanceMethods objectAtIndex:1], is(instance2));
	assertThatInteger([provider.properties count], equalToInteger(2));
	assertThat([provider.properties objectAtIndex:0], is(property1));
	assertThat([provider.properties objectAtIndex:1], is(property2));
}

- (void)testRegisterMethod_shouldProperlyHandlePropertyGettersAndSetters {
	// setup
	GBMethodsProvider *provider = [[GBMethodsProvider alloc] initWithParentObject:self];
	GBMethodData *property1 = [GBTestObjectsRegistry propertyMethodWithArgument:@"name1"];
	GBMethodData *property2 = [GBMethodData propertyDataWithAttributes:[NSArray arrayWithObjects:@"getter",@"=",@"isName2", nil] components:[NSArray arrayWithObjects:@"BOOL", @"name2", nil]];
	GBMethodData *property3 = [GBMethodData propertyDataWithAttributes:[NSArray arrayWithObjects:@"setter",@"=",@"setTheName3:", nil] components:[NSArray arrayWithObjects:@"BOOL", @"name3", nil]];
	GBMethodData *property4 = [GBMethodData propertyDataWithAttributes:[NSArray arrayWithObjects:@"getter",@"=",@"isName4", @"setter",@"=",@"setTheName4:", nil] components:[NSArray arrayWithObjects:@"BOOL", @"name4", nil]];
	// execute
	[provider registerMethod:property1];
	[provider registerMethod:property2];
	[provider registerMethod:property3];
	[provider registerMethod:property4];
	// verify
	assertThat([provider methodBySelector:@"name1"], is(property1));
	assertThat([provider methodBySelector:@"isName1"], is(nil));
	assertThat([provider methodBySelector:@"setName1:"], is(property1));
	assertThat([provider methodBySelector:@"setTheName1:"], is(nil));
	
	assertThat([provider methodBySelector:@"name2"], is(property2));
	assertThat([provider methodBySelector:@"isName2"], is(property2));
	assertThat([provider methodBySelector:@"setName2:"], is(property2));
	assertThat([provider methodBySelector:@"setTheName2:"], is(nil));
	
	assertThat([provider methodBySelector:@"name3"], is(property3));
	assertThat([provider methodBySelector:@"isName3"], is(nil));
	assertThat([provider methodBySelector:@"setName3:"], is(nil));
	assertThat([provider methodBySelector:@"setTheName3:"], is(property3));

	assertThat([provider methodBySelector:@"name4"], is(property4));
	assertThat([provider methodBySelector:@"isName4"], is(property4));
	assertThat([provider methodBySelector:@"setName4:"], is(nil));
	assertThat([provider methodBySelector:@"setTheName4:"], is(property4));
}

#pragma mark Sections handling

- (void)testRegisterMethod_shouldAddMethodToLastSection {
	// setup
	GBMethodsProvider *provider = [[GBMethodsProvider alloc] initWithParentObject:self];
	GBMethodData *method = [GBTestObjectsRegistry instanceMethodWithNames:@"method", nil];
	GBMethodSectionData *section1 = [provider registerSectionWithName:@"section"];
	GBMethodSectionData *section2 = [provider registerSectionWithName:@"section"];
	// execute
	[provider registerMethod:method];
	// verify
	assertThatInteger([[section1 methods] count], equalToInteger(0));
	assertThatInteger([[section2 methods] count], equalToInteger(1));
	assertThat([section2.methods objectAtIndex:0], is(method));
}

- (void)testRegisterMethod_shouldCreateDefaultSectionIfNoneExists {
	// setup
	GBMethodsProvider *provider = [[GBMethodsProvider alloc] initWithParentObject:self];
	GBMethodData *method = [GBTestObjectsRegistry instanceMethodWithNames:@"method", nil];
	// execute
	[provider registerMethod:method];
	// verify
	assertThatInteger([[provider sections] count], equalToInteger(1));
	GBMethodSectionData *section = [[provider sections] objectAtIndex:0];
	assertThatInteger([[section methods] count], equalToInteger(1));
	assertThat([section.methods objectAtIndex:0], is(method));
}

- (void)testRegisterSectionWithName_shouldCreateEmptySectionWithGivenName {
	// setup
	GBMethodsProvider *provider = [[GBMethodsProvider alloc] initWithParentObject:self];
	// execute
	GBMethodSectionData *section = [provider registerSectionWithName:@"section"];
	// verify
	assertThatInteger([[provider sections] count], equalToInteger(1));
	assertThat(section.sectionName, is(@"section"));
	assertThatInteger([section.methods count], equalToInteger(0));
}

- (void)testRegisterSectionIfNameIsValid_shouldAcceptNonEmptyString {
	// setup
	GBMethodsProvider *provider = [[GBMethodsProvider alloc] initWithParentObject:self];
	// execute
	GBMethodSectionData *section = [provider registerSectionIfNameIsValid:@"s"];
	// verify
	assertThat(section, isNot(nil));
	assertThat(section.sectionName, is(@"s"));
}

- (void)testRegisterSectionIfNameIsValid_shouldRejectNilWhitespaceOnlyOrEmptyString {
	// setup
	GBMethodsProvider *provider = [[GBMethodsProvider alloc] initWithParentObject:self];
	// execute & verify
	assertThat([provider registerSectionIfNameIsValid:nil], is(nil));
	assertThat([provider registerSectionIfNameIsValid:@" \t\n\r"], is(nil));
	assertThat([provider registerSectionIfNameIsValid:@""], is(nil));
}

- (void)testRegisterSectionIfNameIsValid_shouldRejectStringIfEqualsToLastRegisteredSectionName {
	// setup
	GBMethodsProvider *provider = [[GBMethodsProvider alloc] initWithParentObject:self];
	[provider registerSectionWithName:@"name"];
	// execute & verify
	assertThat([provider registerSectionIfNameIsValid:@"name"], is(nil));
}

- (void)testUnregisterEmptySections_shouldRemoveAllEmptySections {
	// setup
	GBMethodsProvider *provider = [[GBMethodsProvider alloc] initWithParentObject:self];
	[provider registerSectionWithName:@"Empty 1"];
	[provider registerSectionWithName:@"Used"];
	[provider registerMethod:[GBTestObjectsRegistry propertyMethodWithArgument:@"var"]];
	[provider registerSectionWithName:@"Empty 2"];
	// execute
	[provider unregisterEmptySections];
	// verify
	assertThatInteger([[provider sections] count], equalToInteger(1));
	assertThat([[[provider sections] objectAtIndex:0] sectionName], is(@"Used"));
}

#pragma mark Output helpers testing

- (void)testHasSections_shouldReturnProperValue {
	// setup
	GBMethodsProvider *provider = [[GBMethodsProvider alloc] initWithParentObject:self];
	// execute & verify
	assertThatBool(provider.hasSections, equalToBool(NO));
	[provider registerSectionWithName:@"name"];
	assertThatBool(provider.hasSections, equalToBool(YES));
}

- (void)testHasMultipleSections_shouldReturnProperValue {
	// setup
	GBMethodsProvider *provider = [[GBMethodsProvider alloc] initWithParentObject:self];
	// execute & verify
	assertThatBool(provider.hasMultipleSections, equalToBool(NO));
	[provider registerSectionWithName:@"name1"];
	assertThatBool(provider.hasMultipleSections, equalToBool(NO));
	[provider registerSectionWithName:@"name2"];
	assertThatBool(provider.hasMultipleSections, equalToBool(YES));
}

- (void)testHasClassMethods_shouldReturnProperValue {
	// setup
	GBMethodsProvider *provider = [[GBMethodsProvider alloc] initWithParentObject:self];
	// execute & verify
	assertThatBool(provider.hasClassMethods, equalToBool(NO));
	[provider registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"method", nil]];
	assertThatBool(provider.hasClassMethods, equalToBool(NO));
	[provider registerMethod:[GBTestObjectsRegistry propertyMethodWithArgument:@"value"]];
	assertThatBool(provider.hasClassMethods, equalToBool(NO));
	[provider registerMethod:[GBTestObjectsRegistry classMethodWithNames:@"method", nil]];
	assertThatBool(provider.hasClassMethods, equalToBool(YES));
}

- (void)testHasInstanceMethods_shouldReturnProperValue {
	// setup
	GBMethodsProvider *provider = [[GBMethodsProvider alloc] initWithParentObject:self];
	// execute & verify
	assertThatBool(provider.hasInstanceMethods, equalToBool(NO));
	[provider registerMethod:[GBTestObjectsRegistry classMethodWithNames:@"method1", nil]];
	assertThatBool(provider.hasInstanceMethods, equalToBool(NO));
	[provider registerMethod:[GBTestObjectsRegistry propertyMethodWithArgument:@"value"]];
	assertThatBool(provider.hasInstanceMethods, equalToBool(NO));
	[provider registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"method2", nil]];
	assertThatBool(provider.hasInstanceMethods, equalToBool(YES));
}

- (void)testHasProperties_shouldReturnProperValue {
	// setup
	GBMethodsProvider *provider = [[GBMethodsProvider alloc] initWithParentObject:self];
	// execute & verify
	assertThatBool(provider.hasProperties, equalToBool(NO));
	[provider registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"method1", nil]];
	assertThatBool(provider.hasProperties, equalToBool(NO));
	[provider registerMethod:[GBTestObjectsRegistry classMethodWithNames:@"method2", nil]];
	assertThatBool(provider.hasProperties, equalToBool(NO));
	[provider registerMethod:[GBTestObjectsRegistry propertyMethodWithArgument:@"value"]];
	assertThatBool(provider.hasProperties, equalToBool(YES));
}

#pragma mark Method merging testing

- (void)testMergeDataFromObjectsProvider_shouldMergeAllDifferentMethods {
	// setup
	GBMethodsProvider *original = [[GBMethodsProvider alloc] initWithParentObject:self];
	[original registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"m1", nil]];
	[original registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"m2", nil]];
	GBMethodsProvider *source = [[GBMethodsProvider alloc] initWithParentObject:self];
	[source registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"m1", nil]];
	[source registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"m3", nil]];
	// execute
	[original mergeDataFromMethodsProvider:source];
	// verify - only basic testing here, details at GBMethodDataTesting!
	NSArray *methods = [original methods];
	assertThatInteger([methods count], equalToInteger(3));
	assertThat([[methods objectAtIndex:0] methodSelector], is(@"m1:"));
	assertThat([[methods objectAtIndex:1] methodSelector], is(@"m2:"));
	assertThat([[methods objectAtIndex:2] methodSelector], is(@"m3:"));
}

- (void)testMergeDataFromObjectsProvider_shouldPreserveSourceData {
	// setup
	GBMethodsProvider *original = [[GBMethodsProvider alloc] initWithParentObject:self];
	[original registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"m1", nil]];
	[original registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"m2", nil]];
	GBMethodsProvider *source = [[GBMethodsProvider alloc] initWithParentObject:self];
	[source registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"m1", nil]];
	[source registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"m3", nil]];
	// execute
	[original mergeDataFromMethodsProvider:source];
	// verify - only basic testing here, details at GBMethodDataTesting!
	NSArray *methods = [source methods];
	assertThatInteger([methods count], equalToInteger(2));
	assertThat([[methods objectAtIndex:0] methodSelector], is(@"m1:"));
	assertThat([[methods objectAtIndex:1] methodSelector], is(@"m3:"));
}

- (void)testMergeDataFromObjectsProvider_shouldMergeSections {
	// setup
	GBMethodsProvider *original = [[GBMethodsProvider alloc] initWithParentObject:self];
	[original registerSectionWithName:@"Section1"];
	[original registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"m1", nil]];
	GBMethodsProvider *source = [[GBMethodsProvider alloc] initWithParentObject:self];
	[source registerSectionWithName:@"Section2"];
	[source registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"m2", nil]];
	[source registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"m3", nil]];
	[source registerSectionWithName:@"Section1"];
	[source registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"m4", nil]];
	// execute
	[original mergeDataFromMethodsProvider:source];
	// verify
	GBMethodSectionData *section = nil;
	NSArray *sections = [original sections];
	assertThatInteger([sections count], equalToInteger(2));
	section = [sections objectAtIndex:0];
	assertThat([section sectionName], is(@"Section1"));
	assertThatInteger([section.methods count], equalToInteger(2));
	assertThat([[section.methods objectAtIndex:0] methodSelector], is(@"m1:"));
	assertThat([[section.methods objectAtIndex:1] methodSelector], is(@"m4:"));
	section = [sections objectAtIndex:1];
	assertThat([section sectionName], is(@"Section2"));
	assertThatInteger([section.methods count], equalToInteger(2));
	assertThat([[section.methods objectAtIndex:0] methodSelector], is(@"m2:"));
	assertThat([[section.methods objectAtIndex:1] methodSelector], is(@"m3:"));
}

- (void)testMergeDataFromObjectsProvider_shouldAddMergedSectionsToEndOfOriginalSections {
	// setup
	GBMethodsProvider *original = [[GBMethodsProvider alloc] initWithParentObject:self];
	[original registerSectionWithName:@"Section2"];
	[original registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"m1", nil]];
	GBMethodsProvider *source = [[GBMethodsProvider alloc] initWithParentObject:self];
	[source registerSectionWithName:@"Section1"];
	[source registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"m2", nil]];
	[source registerSectionWithName:@"Section2"];
	[source registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"m3", nil]];
	// execute
	[original mergeDataFromMethodsProvider:source];
	// verify
	GBMethodSectionData *section = nil;
	NSArray *sections = [original sections];
	assertThatInteger([sections count], equalToInteger(2));
	section = [sections objectAtIndex:0];
	assertThat([section sectionName], is(@"Section2"));
	assertThatInteger([section.methods count], equalToInteger(2));
	assertThat([[section.methods objectAtIndex:0] methodSelector], is(@"m1:"));
	assertThat([[section.methods objectAtIndex:1] methodSelector], is(@"m3:"));
	section = [sections objectAtIndex:1];
	assertThat([section sectionName], is(@"Section1"));
	assertThatInteger([section.methods count], equalToInteger(1));
	assertThat([[section.methods objectAtIndex:0] methodSelector], is(@"m2:"));
}

- (void)testMergeDataFromObjectsProvider_shouldPreserveCurrentSectionForNewMethods {
	// setup
	GBMethodsProvider *original = [[GBMethodsProvider alloc] initWithParentObject:self];
	[original registerSectionWithName:@"Section1"];
	[original registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"m1", nil]];
	GBMethodsProvider *source = [[GBMethodsProvider alloc] initWithParentObject:self];
	[source registerSectionWithName:@"Section2"];
	[source registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"m2", nil]];
	[original mergeDataFromMethodsProvider:source];
	// execute
	[original registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"m3", nil]];
	[original registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"m4", nil]];
	// verify
	GBMethodSectionData *section = nil;
	NSArray *sections = [original sections];
	assertThatInteger([sections count], equalToInteger(2));
	section = [sections objectAtIndex:0];
	assertThat([section sectionName], is(@"Section1"));
	assertThatInteger([section.methods count], equalToInteger(3));
	assertThat([[section.methods objectAtIndex:0] methodSelector], is(@"m1:"));
	assertThat([[section.methods objectAtIndex:1] methodSelector], is(@"m3:"));
	assertThat([[section.methods objectAtIndex:2] methodSelector], is(@"m4:"));
	section = [sections objectAtIndex:1];
	assertThat([section sectionName], is(@"Section2"));
	assertThatInteger([section.methods count], equalToInteger(1));
	assertThat([[section.methods objectAtIndex:0] methodSelector], is(@"m2:"));
}

- (void)testMergeDataFromObjectsProvider_shouldUseOriginalSectionForExistingMethodsEvenIfFoundInDifferentSection {
	// setup
	GBMethodsProvider *original = [[GBMethodsProvider alloc] initWithParentObject:self];
	[original registerSectionWithName:@"Section1"];
	[original registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"m1", nil]];
	GBMethodsProvider *source = [[GBMethodsProvider alloc] initWithParentObject:self];
	[source registerSectionWithName:@"Section2"];
	[source registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"m1", nil]];
	// execute
	[original mergeDataFromMethodsProvider:source];
	// verify
	NSArray *sections = [original sections];
	assertThatInteger([sections count], equalToInteger(1));
	GBMethodSectionData *section = [sections objectAtIndex:0];
	assertThat([section sectionName], is(@"Section1"));
	assertThatInteger([section.methods count], equalToInteger(1));
	assertThat([[section.methods objectAtIndex:0] methodSelector], is(@"m1:"));
}

- (void)testMergeDataFromObjectsProvider_shouldUseOriginalSectionForExistingMethodsFromDefaultSection {
	// setup
	GBMethodsProvider *original = [[GBMethodsProvider alloc] initWithParentObject:self];
	[original registerSectionWithName:@"Section1"];
	[original registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"m1", nil]];
	GBMethodsProvider *source = [[GBMethodsProvider alloc] initWithParentObject:self];
	[source registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"m1", nil]];
	// execute
	[original mergeDataFromMethodsProvider:source];
	// verify
	NSArray *sections = [original sections];
	assertThatInteger([sections count], equalToInteger(1));
	GBMethodSectionData *section = [sections objectAtIndex:0];
	assertThat([section sectionName], is(@"Section1"));
	assertThatInteger([section.methods count], equalToInteger(1));
	assertThat([[section.methods objectAtIndex:0] methodSelector], is(@"m1:"));
}

#pragma mark Unregistering handling

- (void)testUnregisterMethod_shouldRemoveMethodFromMethods {
	// setup
	GBMethodsProvider *provider = [[GBMethodsProvider alloc] initWithParentObject:self];
	GBMethodData *method1 = [GBTestObjectsRegistry instanceMethodWithNames:@"method1", nil];
	GBMethodData *method2 = [GBTestObjectsRegistry instanceMethodWithNames:@"method2", nil];
	[provider registerMethod:method1];
	[provider registerMethod:method2];
	// execute
	[provider unregisterMethod:method1];
	// verify
	assertThatInteger([provider.methods count], equalToInteger(1));
	assertThat([provider.methods objectAtIndex:0], is(method2));
}

- (void)testUnregisterMethod_shouldRemoveMethodFromMethodsBySelectors {
	// setup
	GBMethodsProvider *provider = [[GBMethodsProvider alloc] initWithParentObject:self];
	GBMethodData *method = [GBTestObjectsRegistry instanceMethodWithNames:@"method", nil];
	[provider registerMethod:method];
	// execute
	[provider unregisterMethod:method];
	// verify
	assertThat([provider methodBySelector:@"method:"], is(nil));
}

- (void)testUnregisterMethod_shouldRemoveMethodFromClassMethods {
	// setup
	GBMethodsProvider *provider = [[GBMethodsProvider alloc] initWithParentObject:self];
	GBMethodData *method1 = [GBTestObjectsRegistry classMethodWithNames:@"method1", nil];
	GBMethodData *method2 = [GBTestObjectsRegistry classMethodWithNames:@"method2", nil];
	[provider registerMethod:method1];
	[provider registerMethod:method2];
	// execute
	[provider unregisterMethod:method1];
	// verify
	assertThatInteger([provider.classMethods count], equalToInteger(1));
	assertThat([provider.classMethods objectAtIndex:0], is(method2));
}

- (void)testUnregisterMethod_shouldRemoveMethodFromInstanceMethods {
	// setup
	GBMethodsProvider *provider = [[GBMethodsProvider alloc] initWithParentObject:self];
	GBMethodData *method1 = [GBTestObjectsRegistry instanceMethodWithNames:@"method1", nil];
	GBMethodData *method2 = [GBTestObjectsRegistry instanceMethodWithNames:@"method2", nil];
	[provider registerMethod:method1];
	[provider registerMethod:method2];
	// execute
	[provider unregisterMethod:method1];
	// verify
	assertThatInteger([provider.instanceMethods count], equalToInteger(1));
	assertThat([provider.instanceMethods objectAtIndex:0], is(method2));
}

- (void)testUnregisterMethod_shouldRemoveMethodFromProperties {
	// setup
	GBMethodsProvider *provider = [[GBMethodsProvider alloc] initWithParentObject:self];
	GBMethodData *method1 = [GBTestObjectsRegistry propertyMethodWithArgument:@"method1"];
	GBMethodData *method2 = [GBTestObjectsRegistry propertyMethodWithArgument:@"method2"];
	[provider registerMethod:method1];
	[provider registerMethod:method2];
	// execute
	[provider unregisterMethod:method1];
	// verify
	assertThatInteger([provider.properties count], equalToInteger(1));
	assertThat([provider.properties objectAtIndex:0], is(method2));
}

- (void)testUnregisterMethod_shouldRemoveMethodFromSection {
	// setup
	GBMethodsProvider *provider = [[GBMethodsProvider alloc] initWithParentObject:self];
	GBMethodData *method1 = [GBTestObjectsRegistry classMethodWithNames:@"method1", nil];
	GBMethodData *method2 = [GBTestObjectsRegistry classMethodWithNames:@"method2", nil];
	[provider registerSectionWithName:@"Section"];
	[provider registerMethod:method1];
	[provider registerMethod:method2];
	// execute
	[provider unregisterMethod:method1];
	// verify
	assertThatInteger([provider.sections count], equalToInteger(1));
	GBMethodSectionData *section = [provider.sections objectAtIndex:0];
	assertThatInteger([section.methods count], equalToInteger(1));
	assertThat([section.methods objectAtIndex:0], is(method2));
}

- (void)testUnregisterMethod_shouldRemoveSectionIfItContainsNoMoreMethod {
	// setup
	GBMethodsProvider *provider = [[GBMethodsProvider alloc] initWithParentObject:self];
	GBMethodData *method1 = [GBTestObjectsRegistry classMethodWithNames:@"method1", nil];
	[provider registerSectionWithName:@"Section1"];
	[provider registerMethod:method1];
	// execute
	[provider unregisterMethod:method1];
	// verify
	assertThatInteger([provider.sections count], equalToInteger(0));
}

#pragma mark Helper methods testing

- (void)testMethodBySelector_shouldReturnProperInstanceOrNil {
	// setup
	GBMethodsProvider *provider = [[GBMethodsProvider alloc] initWithParentObject:self];
	GBMethodData *method1 = [GBTestObjectsRegistry instanceMethodWithNames:@"method1", nil];
	GBMethodData *method2 = [GBTestObjectsRegistry instanceMethodWithNames:@"method", @"arg", nil];
	GBMethodData *method3 = [GBTestObjectsRegistry classMethodWithNames:@"method3", nil];
	GBMethodData *property = [GBTestObjectsRegistry propertyMethodWithArgument:@"name"];
	[provider registerMethod:method1];
	[provider registerMethod:method2];
	[provider registerMethod:method3];
	[provider registerMethod:property];
	// execute & verify
	assertThat([provider methodBySelector:@"method1:"], is(method1));
	assertThat([provider methodBySelector:@"method:arg:"], is(method2));
	assertThat([provider methodBySelector:@"method3:"], is(method3));
	assertThat([provider methodBySelector:@"name"], is(property));
	assertThat([provider methodBySelector:@"some:other:"], is(nil));
	assertThat([provider methodBySelector:@"single"], is(nil));
	assertThat([provider methodBySelector:@""], is(nil));
	assertThat([provider methodBySelector:nil], is(nil));
}

- (void)testMethodBySelector_prefersInstanceMethodToClassMethod {
	// setup
	GBMethodsProvider *provider = [[GBMethodsProvider alloc] initWithParentObject:self];
	GBMethodData *method1 = [GBTestObjectsRegistry instanceMethodWithNames:@"method", nil];
	GBMethodData *method2 = [GBTestObjectsRegistry classMethodWithNames:@"method", nil];
	[provider registerMethod:method1];
	[provider registerMethod:method2];
	// execute & verify
	assertThat([provider methodBySelector:@"method:"], is(method1));
}

- (void)testMethodBySelector_prefersPropertyToClassMethod {
	// setup
	GBMethodsProvider *provider = [[GBMethodsProvider alloc] initWithParentObject:self];
	GBMethodData *method1 = [GBTestObjectsRegistry propertyMethodWithArgument:@"method"];
	GBMethodData *method2 = [GBTestObjectsRegistry classMethodWithArguments:[GBMethodArgument methodArgumentWithName:@"method"], nil];
	[provider registerMethod:method1];
	[provider registerMethod:method2];
	// execute & verify
	assertThat([provider methodBySelector:@"method"], is(method1));
}

@end
