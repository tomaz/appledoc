//
//  GBAdoptedProtocolsProviderTesting.m
//  appledocTests
//
//  Created by Jebeom Gyeong on 2/22/20.
//  Copyright © 2020 Gentle Bytes. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <OCMock/OCMockObject.h>

#import "GBProtocolData.h"
#import "GBAdoptedProtocolsProvider.h"

@interface GBAdoptedProtocolsProviderTesting : XCTestCase

@end

@implementation GBAdoptedProtocolsProviderTesting

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

#pragma mark Protocol registration testing

- (void)testRegisterProtocol_shouldAddProtocolToList {
    // setup
    GBAdoptedProtocolsProvider *provider = [[GBAdoptedProtocolsProvider alloc] initWithParentObject:self];
    GBProtocolData *protocol = [[GBProtocolData alloc] initWithName:@"MyProtocol"];
    // execute
    [provider registerProtocol:protocol];
    // verify
    XCTAssertTrue([provider.protocols containsObject:protocol]);
    XCTAssertEqual([[provider.protocols allObjects] count], 1);
    XCTAssertEqualObjects([provider.protocols allObjects][0], protocol);
}

- (void)testRegisterProtocol_shouldIgnoreSameInstance {
    // setup
    GBAdoptedProtocolsProvider *provider = [[GBAdoptedProtocolsProvider alloc] initWithParentObject:self];
    GBProtocolData *protocol = [[GBProtocolData alloc] initWithName:@"MyProtocol"];
    // execute
    [provider registerProtocol:protocol];
    [provider registerProtocol:protocol];
    // verify
    XCTAssertEqual([[provider.protocols allObjects] count], 1);
}

- (void)testRegisterProtocol_shouldMergeDifferentInstanceWithSameName {
    // setup
    GBAdoptedProtocolsProvider *provider = [[GBAdoptedProtocolsProvider alloc] initWithParentObject:self];
    GBProtocolData *source = [[GBProtocolData alloc] initWithName:@"MyProtocol"];
    OCMockObject *original = [OCMockObject niceMockForClass:[GBProtocolData class]];
    [[[original stub] andReturn:@"MyProtocol"] nameOfProtocol];
    [[original expect] mergeDataFromObject:source];
    [provider registerProtocol:(GBProtocolData *)original];
    // execute
    [provider registerProtocol:source];
    // verify
    [original verify];
}

#pragma mark Protocol merging handling

- (void)testMergeDataFromProtocolProvider_shouldMergeAllDifferentProtocols {
    // setup
    GBAdoptedProtocolsProvider *original = [[GBAdoptedProtocolsProvider alloc] initWithParentObject:self];
    [original registerProtocol:[GBProtocolData protocolDataWithName:@"P1"]];
    [original registerProtocol:[GBProtocolData protocolDataWithName:@"P2"]];
    GBAdoptedProtocolsProvider *source = [[GBAdoptedProtocolsProvider alloc] initWithParentObject:self];
    [source registerProtocol:[GBProtocolData protocolDataWithName:@"P1"]];
    [source registerProtocol:[GBProtocolData protocolDataWithName:@"P3"]];
    // execute
    [original mergeDataFromProtocolsProvider:source];
    // verify - only basic verification here, details within GBProtocolDataTesting!
    NSArray *protocols = [original protocolsSortedByName];
    XCTAssertEqual([protocols count], 3);
    XCTAssertEqualObjects([protocols[0] nameOfProtocol], @"P1");
    XCTAssertEqualObjects([protocols[1] nameOfProtocol], @"P2");
    XCTAssertEqualObjects([protocols[2] nameOfProtocol], @"P3");
}

- (void)testMergeDataFromProtocolProvider_shouldPreserveSourceData {
    // setup
    GBAdoptedProtocolsProvider *original = [[GBAdoptedProtocolsProvider alloc] initWithParentObject:self];
    [original registerProtocol:[GBProtocolData protocolDataWithName:@"P1"]];
    [original registerProtocol:[GBProtocolData protocolDataWithName:@"P2"]];
    GBAdoptedProtocolsProvider *source = [[GBAdoptedProtocolsProvider alloc] initWithParentObject:self];
    [source registerProtocol:[GBProtocolData protocolDataWithName:@"P1"]];
    [source registerProtocol:[GBProtocolData protocolDataWithName:@"P3"]];
    // execute
    [original mergeDataFromProtocolsProvider:source];
    // verify - only basic verification here, details within GBProtocolDataTesting!
    NSArray *protocols = [source protocolsSortedByName];
    XCTAssertEqual([protocols count], 2);
    XCTAssertEqualObjects([protocols[0] nameOfProtocol], @"P1");
    XCTAssertEqualObjects([protocols[1] nameOfProtocol], @"P3");
}

#pragma mark Protocols replacing handling

- (void)testReplaceProtocolWithProtocol_shouldReplaceObjects {
    // setup
    GBAdoptedProtocolsProvider *provider = [[GBAdoptedProtocolsProvider alloc] initWithParentObject:self];
    GBProtocolData *protocol1 = [GBProtocolData protocolDataWithName:@"P1"];
    GBProtocolData *protocol2 = [GBProtocolData protocolDataWithName:@"P2"];
    GBProtocolData *protocol3 = [GBProtocolData protocolDataWithName:@"P3"];
    [provider registerProtocol:protocol1];
    [provider registerProtocol:protocol2];
    // execute
    [provider replaceProtocol:protocol1 withProtocol:protocol3];
    // verify
    NSArray *protocols = [provider protocolsSortedByName];
    XCTAssertEqual([protocols count], 2);
    XCTAssertEqualObjects([protocols[0] nameOfProtocol], @"P2");
    XCTAssertEqualObjects([protocols[1] nameOfProtocol], @"P3");
}

@end
