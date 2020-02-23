//
//  GBIvarsProviderTesting.m
//  appledocTests
//
//  Created by Jebeom Gyeong on 2/22/20.
//  Copyright © 2020 Gentle Bytes. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <OCMock/OCMockObject.h>

#import "GBIvarsProvider.h"
#import "GBIvarData.h"
#import "GBTestObjectsRegistry.h"

@interface GBIvarsProviderTesting : XCTestCase

@end

@implementation GBIvarsProviderTesting

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

#pragma mark Ivar registration testing

- (void)testRegisterIvar_shouldAddIvarToList {
    // setup
    GBIvarsProvider *provider = [[GBIvarsProvider alloc] initWithParentObject:self];
    GBIvarData *ivar = [GBIvarData ivarDataWithComponents:@[@"NSUInteger", @"_name"]];
    // execute
    [provider registerIvar:ivar];
    // verify
    XCTAssertTrue([provider.ivars containsObject:ivar]);
    XCTAssertEqual([provider.ivars count], 1);
    XCTAssertEqualObjects(provider.ivars[0], ivar);
}

- (void)testRegisterIvar_shouldSetParentObject {
    // setup
    GBIvarsProvider *provider = [[GBIvarsProvider alloc] initWithParentObject:self];
    GBIvarData *ivar = [GBIvarData ivarDataWithComponents:@[@"NSUInteger", @"_name"]];
    // execute
    [provider registerIvar:ivar];
    // verify
    XCTAssertEqualObjects(ivar.parentObject, self);
}

- (void)testRegisterIvar_shouldIgnoreSameInstance {
    // setup
    GBIvarsProvider *provider = [[GBIvarsProvider alloc] initWithParentObject:self];
    GBIvarData *ivar = [GBIvarData ivarDataWithComponents:@[@"NSUInteger", @"_name"]];
    // execute
    [provider registerIvar:ivar];
    [provider registerIvar:ivar];
    // verify
    XCTAssertEqual([provider.ivars count], 1);
}

- (void)testRegisterIvar_shouldMergeDifferentInstanceWithSameName {
    // setup
    GBIvarsProvider *provider = [[GBIvarsProvider alloc] initWithParentObject:self];
    GBIvarData *source = [GBIvarData ivarDataWithComponents:@[@"int", @"_index"]];
    OCMockObject *destination = [OCMockObject niceMockForClass:[GBIvarData class]];
    [[[destination stub] andReturn:@"_index"] nameOfIvar];
    [[destination expect] mergeDataFromObject:source];
    [provider registerIvar:(GBIvarData *)destination];
    // execute
    [provider registerIvar:source];
    // verify
    [destination verify];
}

#pragma mark Merging testing

- (void)testMergeDataFromIvarsProvider_shouldMergeAllDifferentIvars {
    // setup
    GBIvarsProvider *original = [[GBIvarsProvider alloc] initWithParentObject:self];
    [original registerIvar:[GBTestObjectsRegistry ivarWithComponents:@"int", @"_i1", nil]];
    [original registerIvar:[GBTestObjectsRegistry ivarWithComponents:@"int", @"_i2", nil]];
    GBIvarsProvider *source = [[GBIvarsProvider alloc] initWithParentObject:self];
    [source registerIvar:[GBTestObjectsRegistry ivarWithComponents:@"int", @"_i1", nil]];
    [source registerIvar:[GBTestObjectsRegistry ivarWithComponents:@"int", @"_i3", nil]];
    // execute
    [original mergeDataFromIvarsProvider:source];
    // verify - only basic testing here, details at GBIvarDataTesting!
    NSArray *ivars = [original ivars];
    XCTAssertEqual([ivars count], 3);
    XCTAssertEqualObjects([ivars[0] nameOfIvar], @"_i1");
    XCTAssertEqualObjects([ivars[1] nameOfIvar], @"_i2");
    XCTAssertEqualObjects([ivars[2] nameOfIvar], @"_i3");
}

- (void)testMergeDataFromIvarsProvider_shouldPreserveSourceData {
    // setup
    GBIvarsProvider *original = [[GBIvarsProvider alloc] initWithParentObject:self];
    [original registerIvar:[GBTestObjectsRegistry ivarWithComponents:@"int", @"_i1", nil]];
    [original registerIvar:[GBTestObjectsRegistry ivarWithComponents:@"int", @"_i2", nil]];
    GBIvarsProvider *source = [[GBIvarsProvider alloc] initWithParentObject:self];
    [source registerIvar:[GBTestObjectsRegistry ivarWithComponents:@"int", @"_i1", nil]];
    [source registerIvar:[GBTestObjectsRegistry ivarWithComponents:@"int", @"_i3", nil]];
    // execute
    [original mergeDataFromIvarsProvider:source];
    // verify - only basic testing here, details at GBIvarDataTesting!
    NSArray *ivars = [source ivars];
    XCTAssertEqual([ivars count], 2);
    XCTAssertEqualObjects([ivars[0] nameOfIvar], @"_i1");
    XCTAssertEqualObjects([ivars[1] nameOfIvar], @"_i3");
}

@end
