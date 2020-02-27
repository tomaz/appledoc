//
//  GBObjectiveCParser-SectionsParsingTesting.m
//  appledocTests
//
//  Created by Jebeom Gyeong on 2/22/20.
//  Copyright © 2020 Gentle Bytes. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "GBStore.h"
#import "GBDataObjects.h"
#import "GBObjectiveCParser.h"
#import "GBTestObjectsRegistry.h"

// Note that we use class for invoking parsing of methods. Probably not the best option - i.e. we could isolate method parsing code altogether and only parse relevant stuff here, but it seemed not much would be gained by doing this. Separating unit tests does avoid repetition in top-level objects testing code - we only need to test specific data there.

@interface GBObjectiveCParser_SectionsParsingTesting : XCTestCase

@end

@implementation GBObjectiveCParser_SectionsParsingTesting

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testParseObjectsFromString_shouldRegisterMethodsToLastSection {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@interface MyClass /** @name Section1 */ /** */ -(id)method1; -(id)method2; @end" sourceFile:@"file" toStore:store];
    // verify
    NSArray *sections = [[[[store classes] anyObject] methods] sections];
    XCTAssertEqual([sections count], 1);
    GBMethodSectionData *section = sections[0];
    XCTAssertEqualObjects(section.sectionName, @"Section1");
    XCTAssertEqual([[section methods] count], 2);
    XCTAssertEqualObjects(((GBMethodData *)[section methods][0]).methodReturnType, @"id");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)[section methods][0]).methodArguments[0]).argumentName, @"method1");
    XCTAssertEqualObjects(((GBMethodData *)[section methods][1]).methodReturnType, @"id");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)[section methods][1]).methodArguments[0]).argumentName, @"method2");
}

- (void)testParseObjectsFromString_shouldRegisterUncommentedMethodsToLastSection {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@interface MyClass /** @name Section1 */ /** */ -(id)method1; /** */ -(id)method2; @end" sourceFile:@"file" toStore:store];
    // verify
    NSArray *sections = [[[[store classes] anyObject] methods] sections];
    XCTAssertEqual([sections count], 1);
    GBMethodSectionData *section = sections[0];
    XCTAssertEqualObjects(section.sectionName, @"Section1");
    XCTAssertEqual([[section methods] count], 2);
    XCTAssertEqualObjects(((GBMethodData *)[section methods][0]).methodReturnType, @"id");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)[section methods][0]).methodArguments[0]).argumentName, @"method1");
    XCTAssertEqualObjects(((GBMethodData *)[section methods][1]).methodReturnType, @"id");
    XCTAssertEqualObjects(((GBMethodArgument *)((GBMethodData *)[section methods][1]).methodArguments[0]).argumentName, @"method2");
}

- (void)testParseObjectsFromString_shouldDetectLongSectionNames {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@interface MyClass /** @name Long section name */ /** */ -(id)method1; @end" sourceFile:@"file" toStore:store];
    // verify
    NSArray *sections = [[[[store classes] anyObject] methods] sections];
    XCTAssertEqual([sections count], 1);
    XCTAssertEqualObjects([sections[0] sectionName], @"Long section name");
}

- (void)testParseObjectsFromString_shouldDetectSectionNameOnlyIfAtStartOfComment {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@interface MyClass /** Some prefix @name Section */ /** */ -(id)method1; @end" sourceFile:@"file" toStore:store];
    // verify - note that we still create default section!
    NSArray *sections = [[[[store classes] anyObject] methods] sections];
    XCTAssertEqual([sections count], 1);
    XCTAssertNil([sections[0] sectionName]);
}

- (void)testParseObjectsFromString_shouldOnlyTakeSectionNameFromTheFirstLineString {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@interface MyClass /** @name\nSection\n\tspanning   multiple\n\n\n\nlines\rwhoa!    */ /** */ -(id)method1; @end" sourceFile:@"file" toStore:store];
    // verify
    NSArray *sections = [[[[store classes] anyObject] methods] sections];
    XCTAssertEqual([sections count], 1);
    XCTAssertEqualObjects([sections[0] sectionName], @"Section");
}

- (void)testParseObjectsFromString_requiresDetectsSectionEvenIfFollowedByUncommentedMethod {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@interface MyClass /** @name Section */ -(id)method1; @end" sourceFile:@"file" toStore:store];
    // verify
    NSArray *sections = [[[[store classes] anyObject] methods] sections];
    XCTAssertEqual([sections count], 1);
    GBMethodSectionData *section = sections[0];
    XCTAssertEqualObjects(section.sectionName, @"Section");
    XCTAssertEqual([section.methods count], 1);
    XCTAssertNil([section.methods[0] comment]);
}

- (void)testParseObjectsFromString_shouldDetectSectionAndCommentForNextCommentedMethod {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    // execute
    [parser parseObjectsFromString:@"@interface MyClass /** @name Section1 */ /* First */ -(id)method1; /** Second */ -(id)method2; @end" sourceFile:@"file" toStore:store];
    // verify
    NSArray *sections = [[[[store classes] anyObject] methods] sections];
    XCTAssertEqual([sections count], 1);
    GBMethodSectionData *section = sections[0];
    XCTAssertEqualObjects(section.sectionName, @"Section1");
    XCTAssertEqual([section.methods count], 2);
    XCTAssertNil([section.methods[0] comment]);
    XCTAssertEqualObjects([(GBComment *)[section.methods[1] comment] stringValue], @"Second");
}

@end
