//
//  GBMethodDataTesting.m
//  appledocTests
//
//  Created by Jebeom Gyeong on 2/22/20.
//  Copyright © 2020 Gentle Bytes. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "GBTestObjectsRegistry.h"
#import "GBDataObjects.h"

@interface GBMethodData (PrivateAPI)
@property (readonly) NSString *methodSelectorDelimiter;
@property (readonly) NSString *methodPrefix;
@end

@interface GBMethodDataTesting : XCTestCase

@end

@implementation GBMethodDataTesting

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

#pragma mark Initialization testing

- (void)testMethodData_shouldInitializeSingleTypelessInstanceSelector {
    // setup & execute
    GBMethodData *data = [GBTestObjectsRegistry instanceMethodWithArguments:[GBMethodArgument methodArgumentWithName:@"method"], nil];
    // verify
    XCTAssertEqualObjects(data.methodSelector, @"method");
}

- (void)testMethodData_shouldInitializeSingleTypedInstanceSelector {
    // setup & execute
    GBMethodData *data = [GBTestObjectsRegistry instanceMethodWithNames:@"method", nil];
    // verify
    XCTAssertEqualObjects(data.methodSelector, @"method:");
}

- (void)testMethodData_shouldInitializeMultipleArgumentInstanceSelector {
    // setup & execute
    GBMethodData *data = [GBTestObjectsRegistry instanceMethodWithNames:@"delegate", @"checked", @"something", nil];
    // verify
    XCTAssertEqualObjects(data.methodSelector, @"delegate:checked:something:");
}

- (void)testMethodData_shouldInitializeSingleTypelessClassSelector {
    // setup & execute
    GBMethodData *data = [GBTestObjectsRegistry classMethodWithArguments:[GBMethodArgument methodArgumentWithName:@"method"], nil];
    // verify
    XCTAssertEqualObjects(data.methodSelector, @"method");
}

- (void)testMethodData_shouldInitializeSingleTypedClassSelector {
    // setup & execute
    GBMethodData *data = [GBTestObjectsRegistry classMethodWithNames:@"method", nil];
    // verify
    XCTAssertEqualObjects(data.methodSelector, @"method:");
}

- (void)testMethodData_shouldInitializeMultipleArgumentClassSelector {
    // setup & execute
    GBMethodData *data = [GBTestObjectsRegistry classMethodWithNames:@"delegate", @"checked", @"something", nil];
    // verify
    XCTAssertEqualObjects(data.methodSelector, @"delegate:checked:something:");
}

- (void)testMethodData_shouldInitializePropertySelector {
    // setup & execute
    GBMethodData *data = [GBTestObjectsRegistry propertyMethodWithArgument:@"isSelected"];
    // verify
    XCTAssertEqualObjects(data.methodSelector, @"isSelected");
}

#pragma mark - Property initializations

- (void)testMethodData_shouldInitializePropertyWithSingleComponent {
    // setup & execute
    NSArray *attributes = @[@"readonly"];
    NSArray *components = @[@"UIView", @"*", @"value"];
    GBMethodData *data = [GBMethodData propertyDataWithAttributes:attributes components:components];
    // verify
    XCTAssertEqualObjects(data.methodAttributes[0], @"readonly");
    XCTAssertEqualObjects(data.methodResultTypes[0], @"UIView");
    XCTAssertEqualObjects(data.methodResultTypes[1], @"*");
    XCTAssertEqualObjects(data.methodSelector, @"value");
}

- (void)testMethodData_shouldInitializePropertyWithMultipleComponents {
    // setup & execute
    NSArray *attributes = @[@"nonatomic", @"assign"];
    NSArray *components = @[@"IBOutlet", @"UIView", @"*", @"value"];
    GBMethodData *data = [GBMethodData propertyDataWithAttributes:attributes components:components];
    // verify
    XCTAssertEqualObjects(data.methodAttributes[0], @"nonatomic");
    XCTAssertEqualObjects(data.methodResultTypes[0], @"IBOutlet");
    XCTAssertEqualObjects(data.methodResultTypes[1], @"UIView");
    XCTAssertEqualObjects(data.methodResultTypes[2], @"*");
    XCTAssertEqualObjects(data.methodSelector, @"value");
}

#pragma mark Merging testing

- (void)testMergeDataFromObject_shouldMergeImplementationDetails {
    // setup - methods don't merge any data, except they need to send base class merging message!
    GBMethodData *original = [GBTestObjectsRegistry instanceMethodWithNames:@"method", nil];
    GBMethodData *source = [GBTestObjectsRegistry instanceMethodWithNames:@"method", nil];
    [source registerSourceInfo:[GBSourceInfo infoWithFilename:@"file" lineNumber:1]];
    // execute
    [original mergeDataFromObject:source];
    // verify - simple testing here, fully tested in GBModelBaseTesting!
    XCTAssertEqual([original.sourceInfos count], 1);
}

- (void)testMergeDataFromObject_shouldMergeMethodWithDifferentResultType {
    // setup
    GBMethodData *original = [GBMethodData methodDataWithType:GBMethodTypeInstance result:@[@"id"] arguments:@[[GBMethodArgument methodArgumentWithName:@"method"]]];
    GBMethodData *source = [GBMethodData methodDataWithType:GBMethodTypeInstance result:@[@"NSString *"] arguments:@[[GBMethodArgument methodArgumentWithName:@"method"]]];
    // execute
    [original mergeDataFromObject:source];
    // verify - should keep original return type
    XCTAssertEqual([original.methodResultTypes count], 1);
    XCTAssertEqualObjects(original.methodResultTypes[0], @"id");
}

- (void)testMergeDataFromObject_shouldMergePropertyWithDifferentResultType {
    // setup
    GBMethodData *original = [GBMethodData propertyDataWithAttributes:@[@"readonly", @"retain"] components:@[@"id", @"value"]];
    GBMethodData *source = [GBMethodData propertyDataWithAttributes:@[@"readwrite", @"retain"] components:@[@"NSString *", @"value"]];
    // execute
    [original mergeDataFromObject:source];
    // verify - should keep original return type
    XCTAssertEqual([original.methodResultTypes count], 1);
    XCTAssertEqualObjects(original.methodResultTypes[0], @"id");
}

- (void)testMergeDataFromObject_shouldMergePropertyWithDifferentAttributes {
    // setup
    GBMethodData *original = [GBMethodData propertyDataWithAttributes:@[@"readonly", @"retain"] components:@[@"BOOL", @"value"]];
    GBMethodData *source = [GBMethodData propertyDataWithAttributes:@[@"readwrite", @"retain"] components:@[@"BOOL", @"value"]];
    // execute
    [original mergeDataFromObject:source];
    // verify - should keep original attributes
    XCTAssertEqualObjects(original.methodAttributes[0], @"readonly");
    XCTAssertEqualObjects(original.methodAttributes[1], @"retain");
}

- (void)testMergeDataFromObject_shouldMergeManualPropertyGetterImplementation {
    // setup
    GBMethodData *original = [GBMethodData propertyDataWithAttributes:@[@"readonly"] components:@[@"BOOL", @"value"]];
    [original registerSourceInfo:[GBSourceInfo infoWithFilename:@"file1" lineNumber:1]];
    GBMethodArgument *arg = [GBMethodArgument methodArgumentWithName:@"value"];
    GBMethodData *source = [GBMethodData methodDataWithType:GBMethodTypeInstance result:@[@"BOOL"] arguments:@[arg]];
    [source registerSourceInfo:[GBSourceInfo infoWithFilename:@"file2" lineNumber:1]];
    // execute
    [original mergeDataFromObject:source];
    // verify - simple testing here, just to make sure both are used and manual implementation is properly detected (i.e. no exception is thrown), fully tested in GBModelBaseTesting!
    XCTAssertEqual([original.sourceInfos count], 2);
}

- (void)testMergeDataFromObject_shouldMergeManualPropertySetterImplementation {
    // setup
    GBMethodData *original = [GBMethodData propertyDataWithAttributes:@[@"readonly"] components:@[@"BOOL", @"value"]];
    [original registerSourceInfo:[GBSourceInfo infoWithFilename:@"file1" lineNumber:1]];
    GBMethodData *source = [GBTestObjectsRegistry instanceMethodWithNames:@"setValue", nil];
    [source registerSourceInfo:[GBSourceInfo infoWithFilename:@"file2" lineNumber:1]];
    // execute
    [original mergeDataFromObject:source];
    // verify - simple testing here, just to make sure both are used and manual implementation is properly detected (i.e. no exception is thrown), fully tested in GBModelBaseTesting!
    XCTAssertEqual([original.sourceInfos count], 2);
}

- (void)testMergeDataFromObject_shouldMergeManualPropertyGetterAndSetterImplementation {
    // setup
    GBMethodData *original = [GBMethodData propertyDataWithAttributes:@[@"readonly"] components:@[@"BOOL", @"value"]];
    [original registerSourceInfo:[GBSourceInfo infoWithFilename:@"file1" lineNumber:1]];
    GBMethodArgument *arg = [GBMethodArgument methodArgumentWithName:@"value"];
    GBMethodData *getter = [GBMethodData methodDataWithType:GBMethodTypeInstance result:@[@"BOOL"] arguments:@[arg]];
    [getter registerSourceInfo:[GBSourceInfo infoWithFilename:@"file2" lineNumber:1]];
    GBMethodData *setter = [GBTestObjectsRegistry instanceMethodWithNames:@"setValue", nil];
    [setter registerSourceInfo:[GBSourceInfo infoWithFilename:@"file3" lineNumber:1]];
    // execute
    [original mergeDataFromObject:getter];
    [original mergeDataFromObject:setter];
    // verify - simple testing here, just to make sure both are used and manual implementation is properly detected (i.e. no exception is thrown), fully tested in GBModelBaseTesting!
    XCTAssertEqual([original.sourceInfos count], 3);
}

- (void)testMergeDataFromObject_shouldUseArgumentNamesFromComment {
    // setup
    GBMethodArgument *arg1 = [GBMethodArgument methodArgumentWithName:@"method" types:@[@"id"] var:@"var"];
    GBMethodData *original = [GBTestObjectsRegistry instanceMethodWithArguments:arg1, nil];
    GBMethodArgument *arg2 = [GBMethodArgument methodArgumentWithName:@"method" types:@[@"id"] var:@"theVar"];
    GBMethodData *source = [GBTestObjectsRegistry instanceMethodWithArguments:arg2, nil];
    [source setComment:[GBComment commentWithStringValue:@"Comment"]];
    // execute
    [original mergeDataFromObject:source];
    // verify
    GBMethodArgument *mergedArgument = original.methodArguments[0];
    XCTAssertEqualObjects(mergedArgument.argumentVar, @"theVar");
}

#pragma mark Property helpers

- (void)testPropertySelectors_shouldReturnProperValueForProperties {
    // setup & execute
    NSArray *components = @[@"BOOL", @"value"];
    GBMethodData *property1 = [GBMethodData propertyDataWithAttributes:@[@"readonly"] components:components];
    GBMethodData *property2 = [GBMethodData propertyDataWithAttributes:@[@"getter", @"=", @"isValue"] components:components];
    GBMethodData *property3 = [GBMethodData propertyDataWithAttributes:@[@"setter", @"=", @"setTheValue:"] components:components];
    GBMethodData *property4 = [GBMethodData propertyDataWithAttributes:@[@"getter", @"=", @"isValue", @"setter", @"=", @"setTheValue:"] components:components];
    // verify
    XCTAssertEqualObjects(property1.propertyGetterSelector, @"value");
    XCTAssertEqualObjects(property1.propertySetterSelector, @"setValue:");
    XCTAssertEqualObjects(property2.propertyGetterSelector, @"isValue");
    XCTAssertEqualObjects(property2.propertySetterSelector, @"setValue:");
    XCTAssertEqualObjects(property3.propertyGetterSelector, @"value");
    XCTAssertEqualObjects(property3.propertySetterSelector, @"setTheValue:");
    XCTAssertEqualObjects(property4.propertyGetterSelector, @"isValue");
    XCTAssertEqualObjects(property4.propertySetterSelector, @"setTheValue:");
}

- (void)testPropertySelectors_shouldReturnNilForMethods {
    // setup & execute
    GBMethodData *method = [GBTestObjectsRegistry instanceMethodWithNames:@"value", nil];
    // verify
    XCTAssertNil(method.propertyGetterSelector);
    XCTAssertNil(method.propertySetterSelector);
}

#pragma mark Convenience methods testing

- (void)testIsInstanceMethod_shouldReturnProperValue {
    // setup & execute
    GBMethodData *method1 = [GBTestObjectsRegistry classMethodWithNames:@"method", nil];
    GBMethodData *method2 = [GBTestObjectsRegistry instanceMethodWithNames:@"method", nil];
    GBMethodData *method3 = [GBTestObjectsRegistry propertyMethodWithArgument:@"method"];
    // verify
    XCTAssertFalse(method1.isInstanceMethod);
    XCTAssertTrue(method2.isInstanceMethod);
    XCTAssertFalse(method3.isInstanceMethod);
}

- (void)testIsClassMethod_shouldReturnProperValue {
    // setup & execute
    GBMethodData *method1 = [GBTestObjectsRegistry classMethodWithNames:@"method", nil];
    GBMethodData *method2 = [GBTestObjectsRegistry instanceMethodWithNames:@"method", nil];
    GBMethodData *method3 = [GBTestObjectsRegistry propertyMethodWithArgument:@"method"];
    // verify
    XCTAssertTrue(method1.isClassMethod);
    XCTAssertFalse(method2.isClassMethod);
    XCTAssertFalse(method3.isClassMethod);
}

- (void)testIsMethod_shouldReturnProperValue {
    // setup & execute
    GBMethodData *method1 = [GBTestObjectsRegistry classMethodWithNames:@"method", nil];
    GBMethodData *method2 = [GBTestObjectsRegistry instanceMethodWithNames:@"method", nil];
    GBMethodData *method3 = [GBTestObjectsRegistry propertyMethodWithArgument:@"method"];
    // verify
    XCTAssertTrue(method1.isMethod);
    XCTAssertTrue(method2.isMethod);
    XCTAssertFalse(method3.isMethod);
}

- (void)testIsProperty_shouldReturnProperValue {
    // setup & execute
    GBMethodData *method1 = [GBTestObjectsRegistry classMethodWithNames:@"method", nil];
    GBMethodData *method2 = [GBTestObjectsRegistry instanceMethodWithNames:@"method", nil];
    GBMethodData *method3 = [GBTestObjectsRegistry propertyMethodWithArgument:@"method"];
    // verify
    XCTAssertFalse(method1.isProperty);
    XCTAssertFalse(method2.isProperty);
    XCTAssertTrue(method3.isProperty);
}

#pragma mark Formatted components testing

- (void)testFormattedComponents_shouldReturnSimplePropertyComponents {
    // setup
    NSArray *attributes = @[@"readonly"];
    NSArray *components = @[@"BOOL", @"name"];
    GBMethodData *method = [GBMethodData propertyDataWithAttributes:attributes components:components];
    // execute
    NSArray *result = [method formattedComponents];
    // verify: {@property}-{ }-{(}-{readonly}-{)}-{ }-{BOOL}-{ }-{name}
    XCTAssertEqualObjects(result[0], @{@"value": @"@property"});
    XCTAssertEqualObjects(result[1], @{@"value": @" "});
    XCTAssertEqualObjects(result[2], @{@"value": @"("});
    XCTAssertEqualObjects(result[3], @{@"value": @"readonly"});
    XCTAssertEqualObjects(result[4], @{@"value": @")"});
    XCTAssertEqualObjects(result[5], @{@"value": @" "});
    XCTAssertEqualObjects(result[6], @{@"value": @"BOOL"});
    XCTAssertEqualObjects(result[7], @{@"value": @" "});
    XCTAssertEqualObjects(result[8], @{@"value": @"name"});
}

- (void)testFormattedComponents_shouldReturnComplexPropertyComponents {
    // setup
    NSArray *attributes = @[@"readonly", @"nonatomic"];
    NSArray *components = @[@"unsigned", @"int", @"name"];
    GBMethodData *method = [GBMethodData propertyDataWithAttributes:attributes components:components];
    // execute
    NSArray *result = [method formattedComponents];
    // verify: {@property}-{ }-{(}-{readonly}-{,}-{ }-{nonatomic}-{)}-{ }-{unsigned}-{ }-{int}-{ }-{name}
    XCTAssertEqualObjects(result[0], @{@"value": @"@property"});
    XCTAssertEqualObjects(result[1], @{@"value": @" "});
    XCTAssertEqualObjects(result[2], @{@"value": @"("});
    XCTAssertEqualObjects(result[3], @{@"value": @"readonly"});
    XCTAssertEqualObjects(result[4], @{@"value": @","});
    XCTAssertEqualObjects(result[5], @{@"value": @" "});
    XCTAssertEqualObjects(result[6], @{@"value": @"nonatomic"});
    XCTAssertEqualObjects(result[7], @{@"value": @")"});
    XCTAssertEqualObjects(result[8], @{@"value": @" "});
    XCTAssertEqualObjects(result[9], @{@"value": @"unsigned"});
    XCTAssertEqualObjects(result[10], @{@"value": @" "});
    XCTAssertEqualObjects(result[11], @{@"value": @"int"});
    XCTAssertEqualObjects(result[12], @{@"value": @" "});
    XCTAssertEqualObjects(result[13], @{@"value": @"name"});
}

- (void)testFormattedComponents_shouldProperlyHandlePropertyWithNoAttributes {
    // setup
    NSArray *attributes = [NSArray array];
    NSArray *components = @[@"NSString", @"*", @"name"];
    GBMethodData *method = [GBMethodData propertyDataWithAttributes:attributes components:components];
    // execute
    NSArray *result = [method formattedComponents];
    // verify: {@property}-{ }-{NSString}-{ }-{*}-{name}
    XCTAssertEqualObjects(result[0], @{@"value": @"@property"});
    XCTAssertEqualObjects(result[1], @{@"value": @" "});
    XCTAssertEqualObjects(result[2], @{@"value": @"NSString"});
    XCTAssertEqualObjects(result[3], @{@"value": @" "});
    XCTAssertEqualObjects(result[4], @{@"value": @"*"});
    XCTAssertEqualObjects(result[5], @{@"value": @"name"});
}

- (void)testFormattedComponents_shouldReturnPointerPropertyComponents {
    // setup
    NSArray *attributes = @[@"readonly"];
    NSArray *components = @[@"NSString", @"*", @"name"];
    GBMethodData *method = [GBMethodData propertyDataWithAttributes:attributes components:components];
    // execute
    NSArray *result = [method formattedComponents];
    // verify: {@property}-{ }-{(}-{readonly}-{)}-{ }-{NSString}-{ }-{*}-{name}
    XCTAssertEqualObjects(result[0], @{@"value": @"@property"});
    XCTAssertEqualObjects(result[1], @{@"value": @" "});
    XCTAssertEqualObjects(result[2], @{@"value": @"("});
    XCTAssertEqualObjects(result[3], @{@"value": @"readonly"});
    XCTAssertEqualObjects(result[4], @{@"value": @")"});
    XCTAssertEqualObjects(result[5], @{@"value": @" "});
    XCTAssertEqualObjects(result[6], @{@"value": @"NSString"});
    XCTAssertEqualObjects(result[7], @{@"value": @" "});
    XCTAssertEqualObjects(result[8], @{@"value": @"*"});
    XCTAssertEqualObjects(result[9], @{@"value": @"name"});
}

- (void)testFormattedComponents_shouldCombineGetterAndSetterAttributes {
    // setup
    NSArray *attributes = @[@"readonly", @"getter", @"=", @"isName", @"setter", @"=", @"setName:"];
    NSArray *components = @[@"NSString", @"*", @"name"];
    GBMethodData *method = [GBMethodData propertyDataWithAttributes:attributes components:components];
    // execute
    NSArray *result = [method formattedComponents];
    // verify: {@property}-{ }-{(}-{readonly}-{,}-{ }-{getter}-{=}-{isName}-{,}-{ }-{setter}-{=}-{setName:}-{)}-{ }-{NSString}-{ }-{*}-{name}
    XCTAssertEqualObjects(result[0], @{@"value": @"@property"});
    XCTAssertEqualObjects(result[1], @{@"value": @" "});
    XCTAssertEqualObjects(result[2], @{@"value": @"("});
    XCTAssertEqualObjects(result[3], @{@"value": @"readonly"});
    XCTAssertEqualObjects(result[4], @{@"value": @","});
    XCTAssertEqualObjects(result[5], @{@"value": @" "});
    XCTAssertEqualObjects(result[6], @{@"value": @"getter"});
    XCTAssertEqualObjects(result[7], @{@"value": @"="});
    XCTAssertEqualObjects(result[8], @{@"value": @"isName"});
    XCTAssertEqualObjects(result[9], @{@"value": @","});
    XCTAssertEqualObjects(result[10], @{@"value": @" "});
    XCTAssertEqualObjects(result[11], @{@"value": @"setter"});
    XCTAssertEqualObjects(result[12], @{@"value": @"="});
    XCTAssertEqualObjects(result[13], @{@"value": @"setName:"});
    XCTAssertEqualObjects(result[14], @{@"value": @")"});
    XCTAssertEqualObjects(result[15], @{@"value": @" "});
    XCTAssertEqualObjects(result[16], @{@"value": @"NSString"});
    XCTAssertEqualObjects(result[17], @{@"value": @" "});
    XCTAssertEqualObjects(result[18], @{@"value": @"*"});
    XCTAssertEqualObjects(result[19], @{@"value": @"name"});
}

- (void)testFormattedComponents_shouldReturnSimpleInstanceMethodComponents {
    // setup
    NSArray *results = @[@"void"];
    NSArray *arguments = @[[GBMethodArgument methodArgumentWithName:@"method"]];
    GBMethodData *method = [GBMethodData methodDataWithType:GBMethodTypeInstance result:results arguments:arguments];
    // execute
    NSArray *result = [method formattedComponents];
    // verify: {-}-{ }-{(}-{void}-{)}-{method}
    XCTAssertEqualObjects(result[0], @{@"value": @"-"});
    XCTAssertEqualObjects(result[1], @{@"value": @" "});
    XCTAssertEqualObjects(result[2], @{@"value": @"("});
    XCTAssertEqualObjects(result[3], @{@"value": @"void"});
    XCTAssertEqualObjects(result[4], @{@"value": @")"});
    XCTAssertEqualObjects(result[5], @{@"value": @"method"});
}

- (void)testFormattedComponents_shouldReturnSingleArgumentInstanceMethodComponents {
    // setup
    NSArray *results = @[@"unsigned", @"int"];
    NSArray *types = @[@"bla", @"blu"];
    NSArray *arguments = @[[GBMethodArgument methodArgumentWithName:@"method" types:types var:@"val"]];
    GBMethodData *method = [GBMethodData methodDataWithType:GBMethodTypeInstance result:results arguments:arguments];
    // execute
    NSArray *result = [method formattedComponents];
    // verify: {-}-{ }-{(}-{BOOL}-{)}-{method}-{:}-{(}-{int}-{)}-{val}
    XCTAssertEqualObjects(result[0], @{@"value": @"-"});
    XCTAssertEqualObjects(result[1], @{@"value": @" "});
    XCTAssertEqualObjects(result[2], @{@"value": @"("});
    XCTAssertEqualObjects(result[3], @{@"value": @"unsigned"});
    XCTAssertEqualObjects(result[4], @{@"value": @" "});
    XCTAssertEqualObjects(result[5], @{@"value": @"int"});
    XCTAssertEqualObjects(result[6], @{@"value": @")"});
    XCTAssertEqualObjects(result[7], @{@"value": @"method"});
    XCTAssertEqualObjects(result[8], @{@"value": @":"});
    XCTAssertEqualObjects(result[9], @{@"value": @"("});
    XCTAssertEqualObjects(result[10], @{@"value": @"bla"});
    XCTAssertEqualObjects(result[11], @{@"value": @" "});
    XCTAssertEqualObjects(result[12], @{@"value": @"blu"});
    XCTAssertEqualObjects(result[13], @{@"value": @")"});
    XCTAssertEqualObjects(result[14][@"value"], @"val");
    XCTAssertEqualObjects(result[14][@"style"], @(1));
    XCTAssertEqualObjects(result[14][@"emphasized"], @(YES));
}

- (void)testFormattedComponents_shouldReturnMultiArgumentInstanceMethodComponents {
    // setup
    NSArray *results = @[@"BOOL"];
    NSArray *types = @[@"int"];
    NSArray *arguments = @[[GBMethodArgument methodArgumentWithName:@"doSomething" types:types var:@"val"],
            [GBMethodArgument methodArgumentWithName:@"withOperator" types:types var:@"op"]];
    GBMethodData *method = [GBMethodData methodDataWithType:GBMethodTypeInstance result:results arguments:arguments];
    // execute
    NSArray *result = [method formattedComponents];
    // verify: {-}-{ }-{(}-{BOOL}-{)}-{doSomething}-{:}-{(}-{int}-{)}-{val}-{ }-{withOperator}-{:}-{(}-{int}-{)}-{op}
    XCTAssertEqualObjects(result[0], @{@"value": @"-"});
    XCTAssertEqualObjects(result[1], @{@"value": @" "});
    XCTAssertEqualObjects(result[2], @{@"value": @"("});
    XCTAssertEqualObjects(result[3], @{@"value": @"BOOL"});
    XCTAssertEqualObjects(result[4], @{@"value": @")"});
    XCTAssertEqualObjects(result[5], @{@"value": @"doSomething"});
    XCTAssertEqualObjects(result[6], @{@"value": @":"});
    XCTAssertEqualObjects(result[7], @{@"value": @"("});
    XCTAssertEqualObjects(result[8], @{@"value": @"int"});
    XCTAssertEqualObjects(result[9], @{@"value": @")"});
    XCTAssertEqualObjects(result[10][@"value"], @"val");
    XCTAssertEqualObjects(result[10][@"style"], @(1));
    XCTAssertEqualObjects(result[10][@"emphasized"], @(YES));
    XCTAssertEqualObjects(result[11], @{@"value": @" "});
    XCTAssertEqualObjects(result[12], @{@"value": @"withOperator"});
    XCTAssertEqualObjects(result[13], @{@"value": @":"});
    XCTAssertEqualObjects(result[14], @{@"value": @"("});
    XCTAssertEqualObjects(result[15], @{@"value": @"int"});
    XCTAssertEqualObjects(result[16], @{@"value": @")"});
    XCTAssertEqualObjects(result[17][@"value"], @"op");
    XCTAssertEqualObjects(result[17][@"style"], @(1));
    XCTAssertEqualObjects(result[17][@"emphasized"], @(YES));
}

- (void)testFormattedComponents_shouldReturnPointerInstanceMethodComponents {
    // setup
    NSArray *results = @[@"NSArray", @"*"];
    NSArray *types = @[@"NSString", @"*"];
    NSArray *arguments = @[[GBMethodArgument methodArgumentWithName:@"method" types:types var:@"val"]];
    GBMethodData *method = [GBMethodData methodDataWithType:GBMethodTypeInstance result:results arguments:arguments];
    // execute
    NSArray *result = [method formattedComponents];
    // verify: {-}-{ }-{(}-{BOOL}-{)}-{method}-{:}-{(}-{int}-{)}-{val}
    XCTAssertEqualObjects(result[0], @{@"value": @"-"});
    XCTAssertEqualObjects(result[1], @{@"value": @" "});
    XCTAssertEqualObjects(result[2], @{@"value": @"("});
    XCTAssertEqualObjects(result[3], @{@"value": @"NSArray"});
    XCTAssertEqualObjects(result[4], @{@"value": @" "});
    XCTAssertEqualObjects(result[5], @{@"value": @"*"});
    XCTAssertEqualObjects(result[6], @{@"value": @")"});
    XCTAssertEqualObjects(result[7], @{@"value": @"method"});
    XCTAssertEqualObjects(result[8], @{@"value": @":"});
    XCTAssertEqualObjects(result[9], @{@"value": @"("});
    XCTAssertEqualObjects(result[10], @{@"value": @"NSString"});
    XCTAssertEqualObjects(result[11], @{@"value": @" "});
    XCTAssertEqualObjects(result[12], @{@"value": @"*"});
    XCTAssertEqualObjects(result[13], @{@"value": @")"});
    XCTAssertEqualObjects(result[14][@"value"], @"val");
    XCTAssertEqualObjects(result[14][@"style"], @(1));
    XCTAssertEqualObjects(result[14][@"emphasized"], @(YES));
}

- (void)testFormattedComponents_shouldReturnVariableArgumentInstanceMethodComponents {
    // setup
    NSArray *results = @[@"void"];
    NSArray *types = @[@"id"];
    NSArray *macros = [NSArray array];
    NSArray *arguments = @[[GBMethodArgument methodArgumentWithName:@"method" types:types var:@"format" variableArg:YES terminationMacros:macros]];
    GBMethodData *method = [GBMethodData methodDataWithType:GBMethodTypeInstance result:results arguments:arguments];
    // execute
    NSArray *result = [method formattedComponents];
    // verify: {-}-{ }-{(}-{void}-{)}-{method}-{:}-{(}-{id}-{)}-{format}-{,}-{ }-{...}
    XCTAssertEqualObjects(result[0], @{@"value": @"-"});
    XCTAssertEqualObjects(result[1], @{@"value": @" "});
    XCTAssertEqualObjects(result[2], @{@"value": @"("});
    XCTAssertEqualObjects(result[3], @{@"value": @"void"});
    XCTAssertEqualObjects(result[4], @{@"value": @")"});
    XCTAssertEqualObjects(result[5], @{@"value": @"method"});
    XCTAssertEqualObjects(result[6], @{@"value": @":"});
    XCTAssertEqualObjects(result[7], @{@"value": @"("});
    XCTAssertEqualObjects(result[8], @{@"value": @"id"});
    XCTAssertEqualObjects(result[9], @{@"value": @")"});
    XCTAssertEqualObjects(result[10][@"value"], @"format");
    XCTAssertEqualObjects(result[10][@"style"], @(1));
    XCTAssertEqualObjects(result[10][@"emphasized"], @(YES));
    XCTAssertEqualObjects(result[11], @{@"value": @","});
    XCTAssertEqualObjects(result[12], @{@"value": @" "});
    XCTAssertEqualObjects(result[13][@"value"], @"...");
    XCTAssertEqualObjects(result[13][@"style"], @(1));
    XCTAssertEqualObjects(result[13][@"emphasized"], @(YES));
}

- (void)testFormattedComponents_shouldReturnClassMethodComponents {
    // setup
    NSArray *results = @[@"void"];
    NSArray *arguments = @[[GBMethodArgument methodArgumentWithName:@"method"]];
    GBMethodData *method = [GBMethodData methodDataWithType:GBMethodTypeClass result:results arguments:arguments];
    // execute
    NSArray *result = [method formattedComponents];
    // verify: {+}-{ }-{(}-{void}-{)}-{method}
    XCTAssertEqualObjects(result[0], @{@"value": @"+"});
    XCTAssertEqualObjects(result[1], @{@"value": @" "});
    XCTAssertEqualObjects(result[2], @{@"value": @"("});
    XCTAssertEqualObjects(result[3], @{@"value": @"void"});
    XCTAssertEqualObjects(result[4], @{@"value": @")"});
    XCTAssertEqualObjects(result[5], @{@"value": @"method"});
}

- (void)testFormattedComponents_shouldNotAddSpaceForProtocols {
    // setup
    NSArray *results = @[@"NSArray", @"*"];
    NSArray *types = @[@"id", @"<", @"Protocol", @">"];
    NSArray *arguments = @[[GBMethodArgument methodArgumentWithName:@"method" types:types var:@"val"]];
    GBMethodData *method = [GBMethodData methodDataWithType:GBMethodTypeInstance result:results arguments:arguments];
    // execute
    NSArray *result = [method formattedComponents];
    // verify: {-}-{ }-{(}-{BOOL}-{)}-{method}-{:}-{(}-{id}-{<}-{Protocol}-{>}-{)}-{val}
    XCTAssertEqualObjects(result[0], @{@"value": @"-"});
    XCTAssertEqualObjects(result[1], @{@"value": @" "});
    XCTAssertEqualObjects(result[2], @{@"value": @"("});
    XCTAssertEqualObjects(result[3], @{@"value": @"NSArray"});
    XCTAssertEqualObjects(result[4], @{@"value": @" "});
    XCTAssertEqualObjects(result[5], @{@"value": @"*"});
    XCTAssertEqualObjects(result[6], @{@"value": @")"});
    XCTAssertEqualObjects(result[7], @{@"value": @"method"});
    XCTAssertEqualObjects(result[8], @{@"value": @":"});
    XCTAssertEqualObjects(result[9], @{@"value": @"("});
    XCTAssertEqualObjects(result[10], @{@"value": @"id"});
    XCTAssertEqualObjects(result[11], @{@"value": @"<"});
    XCTAssertEqualObjects(result[12], @{@"value": @"Protocol"});
    XCTAssertEqualObjects(result[13], @{@"value": @">"});
    XCTAssertEqualObjects(result[14], @{@"value": @")"});
    XCTAssertEqualObjects(result[15][@"value"], @"val");
    XCTAssertEqualObjects(result[15][@"style"], @(1));
    XCTAssertEqualObjects(result[15][@"emphasized"], @(YES));
}

#pragma mark Helper methods testing

- (void)testMethodSelectorDelimiter_shouldReturnEmptyStringForProperties {
    // setup
    GBMethodData *method = [GBTestObjectsRegistry propertyMethodWithArgument:@"name"];
    // execute & verify
    XCTAssertEqualObjects(method.methodSelectorDelimiter, @"");
}

- (void)testMethodSelectorDelimiter_shouldReturnEmptyStringForMethodsWithoutParameters {
    // setup
    GBMethodArgument *argument = [GBMethodArgument methodArgumentWithName:@"method"];
    GBMethodData *method = [GBTestObjectsRegistry instanceMethodWithArguments:argument, nil];
    // execute & verify
    XCTAssertEqualObjects(method.methodSelectorDelimiter, @"");
}

- (void)testMethodSelectorDelimiter_shouldReturnEmptyStringForMethodsWithParameters {
    // setup
    GBMethodData *method1 = [GBTestObjectsRegistry instanceMethodWithNames:@"method", nil];
    GBMethodData *method2 = [GBTestObjectsRegistry instanceMethodWithNames:@"doSomething", @"withStyle", nil];
    // execute & verify
    XCTAssertEqualObjects(method1.methodSelectorDelimiter, @":");
    XCTAssertEqualObjects(method2.methodSelectorDelimiter, @":");
}

- (void)testMethodPrefix_shouldReturnProperPrefix {
    // setup, execute & verify
    XCTAssertEqualObjects([[GBTestObjectsRegistry propertyMethodWithArgument:@"name"] methodPrefix], @"@property");
    XCTAssertEqualObjects(([[GBTestObjectsRegistry instanceMethodWithNames:@"method", nil] methodPrefix]), @"-");
    XCTAssertEqualObjects(([[GBTestObjectsRegistry classMethodWithNames:@"method", nil] methodPrefix]), @"+");
}

- (void)testIsTopLevelObject_shouldReturnNO {
    // setup & execute
    GBMethodData *method = [GBTestObjectsRegistry instanceMethodWithNames:@"method", nil];
    // verify
    XCTAssertFalse(method.isTopLevelObject);
}
@end
