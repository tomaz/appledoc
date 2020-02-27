//
//  GBMethodsProviderTesting.m
//  appledocTests
//
//  Created by Jebeom Gyeong on 2/22/20.
//  Copyright © 2020 Gentle Bytes. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "GBTestObjectsRegistry.h"
#import "GBDataObjects.h"
#import "GBMethodsProvider.h"

@interface GBMethodsProviderTesting : XCTestCase

@end

@implementation GBMethodsProviderTesting

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

#pragma mark Method registration testing

- (void)testRegisterMethod_shouldAddMethodToList {
    // setup
    GBMethodsProvider *provider = [[GBMethodsProvider alloc] initWithParentObject:self];
    GBMethodData *method = [GBTestObjectsRegistry instanceMethodWithNames:@"method", nil];
    // execute
    [provider registerMethod:method];
    // verify
    XCTAssertEqual([provider.methods count], 1);
    XCTAssertEqualObjects([provider.methods[0] methodSelector], @"method:");
}

- (void)testRegisterMethod_shouldSetParentObject {
    // setup
    GBMethodsProvider *provider = [[GBMethodsProvider alloc] initWithParentObject:self];
    GBMethodData *method = [GBTestObjectsRegistry instanceMethodWithNames:@"method", nil];
    // execute
    [provider registerMethod:method];
    // verify
    XCTAssertEqualObjects(method.parentObject, self);
}

- (void)testRegisterMethod_shouldIgnoreSameInstance {
    // setup
    GBMethodsProvider *provider = [[GBMethodsProvider alloc] initWithParentObject:self];
    GBMethodData *method = [GBTestObjectsRegistry instanceMethodWithNames:@"method", nil];
    // execute
    [provider registerMethod:method];
    [provider registerMethod:method];
    // verify
    XCTAssertEqual([provider.methods count], 1);
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
    XCTAssertEqual([provider.methods count], 2);
    XCTAssertEqualObjects([provider.methods[0] methodSelector], @"method:");
    XCTAssertEqual([provider.methods[0] methodType], GBMethodTypeInstance);
    XCTAssertEqualObjects([provider.methods[1] methodSelector], @"method:");
    XCTAssertEqual([provider.methods[1] methodType], GBMethodTypeClass);
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
    XCTAssertEqualObjects([provider1 methodBySelector:@"method:"], method1);
    XCTAssertEqualObjects([provider2 methodBySelector:@"method:"], method1);
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
    XCTAssertEqualObjects([provider1 methodBySelector:@"method"], method1);
    XCTAssertEqualObjects([provider2 methodBySelector:@"method"], method1);
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
    XCTAssertEqual([provider.classMethods count], 1);
    XCTAssertEqualObjects(provider.classMethods[0], method);
}

- (void)testRegisterMethod_shouldRegisterInstanceMethod {
    // setup
    GBMethodsProvider *provider = [[GBMethodsProvider alloc] initWithParentObject:self];
    GBMethodData *method = [GBTestObjectsRegistry instanceMethodWithNames:@"method", nil];
    // execute
    [provider registerMethod:method];
    // verify
    XCTAssertEqual([provider.instanceMethods count], 1);
    XCTAssertEqualObjects(provider.instanceMethods[0], method);
}

- (void)testRegisterMethod_shouldRegisterProperty {
    // setup
    GBMethodsProvider *provider = [[GBMethodsProvider alloc] initWithParentObject:self];
    GBMethodData *method = [GBTestObjectsRegistry propertyMethodWithArgument:@"name"];
    // execute
    [provider registerMethod:method];
    // verify
    XCTAssertEqual([provider.properties count], 1);
    XCTAssertEqualObjects(provider.properties[0], method);
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
    XCTAssertEqual([provider.classMethods count], 2);
    XCTAssertEqualObjects(provider.classMethods[0], class1);
    XCTAssertEqualObjects(provider.classMethods[1], class2);
    XCTAssertEqual([provider.instanceMethods count], 2);
    XCTAssertEqualObjects(provider.instanceMethods[0], instance1);
    XCTAssertEqualObjects(provider.instanceMethods[1], instance2);
    XCTAssertEqual([provider.properties count], 2);
    XCTAssertEqualObjects(provider.properties[0], property1);
    XCTAssertEqualObjects(provider.properties[1], property2);
}

- (void)testRegisterMethod_shouldProperlyHandlePropertyGettersAndSetters {
    // setup
    GBMethodsProvider *provider = [[GBMethodsProvider alloc] initWithParentObject:self];
    GBMethodData *property1 = [GBTestObjectsRegistry propertyMethodWithArgument:@"name1"];
    GBMethodData *property2 = [GBMethodData propertyDataWithAttributes:@[@"getter", @"=", @"isName2"] components:@[@"BOOL", @"name2"]];
    GBMethodData *property3 = [GBMethodData propertyDataWithAttributes:@[@"setter", @"=", @"setTheName3:"] components:@[@"BOOL", @"name3"]];
    GBMethodData *property4 = [GBMethodData propertyDataWithAttributes:@[@"getter", @"=", @"isName4", @"setter", @"=", @"setTheName4:"] components:@[@"BOOL", @"name4"]];
    // execute
    [provider registerMethod:property1];
    [provider registerMethod:property2];
    [provider registerMethod:property3];
    [provider registerMethod:property4];
    // verify
    XCTAssertEqualObjects([provider methodBySelector:@"name1"], property1);
    XCTAssertNil([provider methodBySelector:@"isName1"]);
    XCTAssertEqualObjects([provider methodBySelector:@"setName1:"], property1);
    XCTAssertNil([provider methodBySelector:@"setTheName1:"]);
    
    XCTAssertEqualObjects([provider methodBySelector:@"name2"], property2);
    XCTAssertEqualObjects([provider methodBySelector:@"isName2"], property2);
    XCTAssertEqualObjects([provider methodBySelector:@"setName2:"], property2);
    XCTAssertNil([provider methodBySelector:@"setTheName2:"]);
    
    XCTAssertEqualObjects([provider methodBySelector:@"name3"], property3);
    XCTAssertNil([provider methodBySelector:@"isName3"]);
    XCTAssertNil([provider methodBySelector:@"setName3:"]);
    XCTAssertEqualObjects([provider methodBySelector:@"setTheName3:"], property3);

    XCTAssertEqualObjects([provider methodBySelector:@"name4"], property4);
    XCTAssertEqualObjects([provider methodBySelector:@"isName4"], property4);
    XCTAssertNil([provider methodBySelector:@"setName4:"]);
    XCTAssertEqualObjects([provider methodBySelector:@"setTheName4:"], property4);
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
    XCTAssertEqual([[section1 methods] count], 0);
    XCTAssertEqual([[section2 methods] count], 1);
    XCTAssertEqualObjects(section2.methods[0], method);
}

- (void)testRegisterMethod_shouldCreateDefaultSectionIfNoneExists {
    // setup
    GBMethodsProvider *provider = [[GBMethodsProvider alloc] initWithParentObject:self];
    GBMethodData *method = [GBTestObjectsRegistry instanceMethodWithNames:@"method", nil];
    // execute
    [provider registerMethod:method];
    // verify
    XCTAssertEqual([[provider sections] count], 1);
    GBMethodSectionData *section = [provider sections][0];
    XCTAssertEqual([[section methods] count], 1);
    XCTAssertEqualObjects(section.methods[0], method);
}

- (void)testRegisterSectionWithName_shouldCreateEmptySectionWithGivenName {
    // setup
    GBMethodsProvider *provider = [[GBMethodsProvider alloc] initWithParentObject:self];
    // execute
    GBMethodSectionData *section = [provider registerSectionWithName:@"section"];
    // verify
    XCTAssertEqual([[provider sections] count], 1);
    XCTAssertEqualObjects(section.sectionName, @"section");
    XCTAssertEqual([section.methods count], 0);
}

- (void)testRegisterSectionIfNameIsValid_shouldAcceptNonEmptyString {
    // setup
    GBMethodsProvider *provider = [[GBMethodsProvider alloc] initWithParentObject:self];
    // execute
    GBMethodSectionData *section = [provider registerSectionIfNameIsValid:@"s"];
    // verify
    XCTAssertNotNil(section);
    XCTAssertEqualObjects(section.sectionName, @"s");
}

- (void)testRegisterSectionIfNameIsValid_shouldRejectNilWhitespaceOnlyOrEmptyString {
    // setup
    GBMethodsProvider *provider = [[GBMethodsProvider alloc] initWithParentObject:self];
    // execute & verify
    XCTAssertNil([provider registerSectionIfNameIsValid:nil]);
    XCTAssertNil([provider registerSectionIfNameIsValid:@" \t\n\r"]);
    XCTAssertNil([provider registerSectionIfNameIsValid:@""]);
}

- (void)testRegisterSectionIfNameIsValid_shouldRejectStringIfEqualsToLastRegisteredSectionName {
    // setup
    GBMethodsProvider *provider = [[GBMethodsProvider alloc] initWithParentObject:self];
    [provider registerSectionWithName:@"name"];
    // execute & verify
    XCTAssertNil([provider registerSectionIfNameIsValid:@"name"]);
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
    XCTAssertEqual([[provider sections] count], 1);
    XCTAssertEqualObjects([[provider sections][0] sectionName], @"Used");
}

#pragma mark Output helpers testing

- (void)testHasSections_shouldReturnProperValue {
    // setup
    GBMethodsProvider *provider = [[GBMethodsProvider alloc] initWithParentObject:self];
    // execute & verify
    XCTAssertFalse(provider.hasSections);
    [provider registerSectionWithName:@"name"];
    XCTAssertTrue(provider.hasSections);
}

- (void)testHasMultipleSections_shouldReturnProperValue {
    // setup
    GBMethodsProvider *provider = [[GBMethodsProvider alloc] initWithParentObject:self];
    // execute & verify
    XCTAssertFalse(provider.hasMultipleSections);
    [provider registerSectionWithName:@"name1"];
    XCTAssertFalse(provider.hasMultipleSections);
    [provider registerSectionWithName:@"name2"];
    XCTAssertTrue(provider.hasMultipleSections);
}

- (void)testHasClassMethods_shouldReturnProperValue {
    // setup
    GBMethodsProvider *provider = [[GBMethodsProvider alloc] initWithParentObject:self];
    // execute & verify
    XCTAssertFalse(provider.hasClassMethods);
    [provider registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"method", nil]];
    XCTAssertFalse(provider.hasClassMethods);
    [provider registerMethod:[GBTestObjectsRegistry propertyMethodWithArgument:@"value"]];
    XCTAssertFalse(provider.hasClassMethods);
    [provider registerMethod:[GBTestObjectsRegistry classMethodWithNames:@"method", nil]];
    XCTAssertTrue(provider.hasClassMethods);
}

- (void)testHasInstanceMethods_shouldReturnProperValue {
    // setup
    GBMethodsProvider *provider = [[GBMethodsProvider alloc] initWithParentObject:self];
    // execute & verify
    XCTAssertFalse(provider.hasInstanceMethods);
    [provider registerMethod:[GBTestObjectsRegistry classMethodWithNames:@"method1", nil]];
    XCTAssertFalse(provider.hasInstanceMethods);
    [provider registerMethod:[GBTestObjectsRegistry propertyMethodWithArgument:@"value"]];
    XCTAssertFalse(provider.hasInstanceMethods);
    [provider registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"method2", nil]];
    XCTAssertTrue(provider.hasInstanceMethods);
}

- (void)testHasProperties_shouldReturnProperValue {
    // setup
    GBMethodsProvider *provider = [[GBMethodsProvider alloc] initWithParentObject:self];
    // execute & verify
    XCTAssertFalse(provider.hasProperties);
    [provider registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"method1", nil]];
    XCTAssertFalse(provider.hasProperties);
    [provider registerMethod:[GBTestObjectsRegistry classMethodWithNames:@"method2", nil]];
    XCTAssertFalse(provider.hasProperties);
    [provider registerMethod:[GBTestObjectsRegistry propertyMethodWithArgument:@"value"]];
    XCTAssertTrue(provider.hasProperties);
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
    XCTAssertEqual([methods count], 3);
    XCTAssertEqualObjects([methods[0] methodSelector], @"m1:");
    XCTAssertEqualObjects([methods[1] methodSelector], @"m2:");
    XCTAssertEqualObjects([methods[2] methodSelector], @"m3:");
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
    XCTAssertEqual([methods count], 2);
    XCTAssertEqualObjects([methods[0] methodSelector], @"m1:");
    XCTAssertEqualObjects([methods[1] methodSelector], @"m3:");
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
    XCTAssertEqual([sections count], 2);
    section = sections[0];
    XCTAssertEqualObjects([section sectionName], @"Section1");
    XCTAssertEqual([section.methods count], 2);
    XCTAssertEqualObjects([section.methods[0] methodSelector], @"m1:");
    XCTAssertEqualObjects([section.methods[1] methodSelector], @"m4:");
    section = sections[1];
    XCTAssertEqualObjects([section sectionName], @"Section2");
    XCTAssertEqual([section.methods count], 2);
    XCTAssertEqualObjects([section.methods[0] methodSelector], @"m2:");
    XCTAssertEqualObjects([section.methods[1] methodSelector], @"m3:");
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
    XCTAssertEqual([sections count], 2);
    section = sections[0];
    XCTAssertEqualObjects([section sectionName], @"Section2");
    XCTAssertEqual([section.methods count], 2);
    XCTAssertEqualObjects([section.methods[0] methodSelector],@"m1:");
    XCTAssertEqualObjects([section.methods[1] methodSelector], @"m3:");
    section = sections[1];
    XCTAssertEqualObjects([section sectionName], @"Section1");
    XCTAssertEqual([section.methods count], 1);
    XCTAssertEqualObjects([section.methods[0] methodSelector], @"m2:");
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
    XCTAssertEqual([sections count], 2);
    section = sections[0];
    XCTAssertEqualObjects([section sectionName], @"Section1");
    XCTAssertEqual([section.methods count], 3);
    XCTAssertEqualObjects([section.methods[0] methodSelector], @"m1:");
    XCTAssertEqualObjects([section.methods[1] methodSelector], @"m3:");
    XCTAssertEqualObjects([section.methods[2] methodSelector], @"m4:");
    section = sections[1];
    XCTAssertEqualObjects([section sectionName], @"Section2");
    XCTAssertEqual([section.methods count], 1);
    XCTAssertEqualObjects([section.methods[0] methodSelector], @"m2:");
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
    XCTAssertEqual([sections count], 1);
    GBMethodSectionData *section = sections[0];
    XCTAssertEqualObjects([section sectionName], @"Section1");
    XCTAssertEqual([section.methods count], 1);
    XCTAssertEqualObjects([section.methods[0] methodSelector], @"m1:");
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
    XCTAssertEqual([sections count], 1);
    GBMethodSectionData *section = sections[0];
    XCTAssertEqualObjects([section sectionName], @"Section1");
    XCTAssertEqual([section.methods count], 1);
    XCTAssertEqualObjects([section.methods[0] methodSelector], @"m1:");
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
    XCTAssertEqual([provider.methods count], 1);
    XCTAssertEqualObjects(provider.methods[0], method2);
}

- (void)testUnregisterMethod_shouldRemoveMethodFromMethodsBySelectors {
    // setup
    GBMethodsProvider *provider = [[GBMethodsProvider alloc] initWithParentObject:self];
    GBMethodData *method = [GBTestObjectsRegistry instanceMethodWithNames:@"method", nil];
    [provider registerMethod:method];
    // execute
    [provider unregisterMethod:method];
    // verify
    XCTAssertNil([provider methodBySelector:@"method:"]);
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
    XCTAssertEqual([provider.classMethods count], 1);
    XCTAssertEqualObjects(provider.classMethods[0], method2);
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
    XCTAssertEqual([provider.instanceMethods count], 1);
    XCTAssertEqualObjects(provider.instanceMethods[0], method2);
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
    XCTAssertEqual([provider.properties count], 1);
    XCTAssertEqualObjects(provider.properties[0], method2);
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
    XCTAssertEqual([provider.sections count], 1);
    GBMethodSectionData *section = provider.sections[0];
    XCTAssertEqual([section.methods count], 1);
    XCTAssertEqualObjects(section.methods[0], method2);
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
    XCTAssertEqual([provider.sections count], 0);
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
    XCTAssertEqualObjects([provider methodBySelector:@"method1:"], method1);
    XCTAssertEqualObjects([provider methodBySelector:@"method:arg:"], method2);
    XCTAssertEqualObjects([provider methodBySelector:@"method3:"], method3);
    XCTAssertEqualObjects([provider methodBySelector:@"name"], property);
    XCTAssertNil([provider methodBySelector:@"some:other:"]);
    XCTAssertNil([provider methodBySelector:@"single"]);
    XCTAssertNil([provider methodBySelector:@""]);
    XCTAssertNil([provider methodBySelector:nil]);
}

- (void)testMethodBySelector_prefersInstanceMethodToClassMethod {
    // setup
    GBMethodsProvider *provider = [[GBMethodsProvider alloc] initWithParentObject:self];
    GBMethodData *method1 = [GBTestObjectsRegistry instanceMethodWithNames:@"method", nil];
    GBMethodData *method2 = [GBTestObjectsRegistry classMethodWithNames:@"method", nil];
    [provider registerMethod:method1];
    [provider registerMethod:method2];
    // execute & verify
    XCTAssertEqualObjects([provider methodBySelector:@"method:"], method1);
}

- (void)testMethodBySelector_prefersPropertyToClassMethod {
    // setup
    GBMethodsProvider *provider = [[GBMethodsProvider alloc] initWithParentObject:self];
    GBMethodData *method1 = [GBTestObjectsRegistry propertyMethodWithArgument:@"method"];
    GBMethodData *method2 = [GBTestObjectsRegistry classMethodWithArguments:[GBMethodArgument methodArgumentWithName:@"method"], nil];
    [provider registerMethod:method1];
    [provider registerMethod:method2];
    // execute & verify
    XCTAssertEqualObjects([provider methodBySelector:@"method"], method1);
}
@end
