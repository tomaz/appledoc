//
//  ParserTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/19/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "GBSettings+Appledoc.h"
#import "Extensions.h"
#import "ObjectiveCParser.h"
#import "Parser.h"
#import "TestCaseBase.h"

@interface ParserTests : TestCaseBase
@end

@interface ParserTests (CreationMethods)
- (void)runWithParser:(void(^)(Parser *parser))handler;
@end

#pragma mark - 

@implementation ParserTests

#pragma mark - Properties

- (void)testLazyAccessorsShouldInitializeObjects {
	[self runWithParser:^(Parser *parser) {
		// execute & verify
		assertThat(parser.objectiveCParser, instanceOf([ObjectiveCParser class]));
	}];
}

#pragma mark - runTask

- (void)testRunTaskShouldEnumerateArgumentsOnTheGivenSettings {
	[self runWithParser:^(Parser *parser) {
		// setup
		id arguments = [OCMockObject mockForClass:[NSArray class]];
		[[arguments expect] enumerateObjectsUsingBlock:OCMOCK_ANY];
		id settings = [OCMockObject mockForClass:[GBSettings class]];
		[[[settings expect] andReturn:arguments] arguments];
		// execute
		[parser runWithSettings:settings store:nil];
		// verify
		STAssertNoThrow([settings verify], nil);
		STAssertNoThrow([arguments verify], nil);
	}];
}

- (void)testRunTaskShouldInvokeObjectiveCParserOnSourceFiles {
	[self runWithParser:^(Parser *parser) {
		// setup
		id settings = [OCMockObject niceMockForClass:[GBSettings class]];
		[[[settings stub] andReturn:[NSArray arrayWithObject:@"file.m"]] arguments];
		id objcParser = [OCMockObject niceMockForClass:[ObjectiveCParser class]];
		[[objcParser expect] parseFile:@"file.m" withSettings:settings store:OCMOCK_ANY];
		BOOL yes = YES, no = NO;
		id manager = [OCMockObject niceMockForClass:[NSFileManager class]];
		[[[manager stub] andReturnValue:OCMOCK_VALUE(yes)] fileExistsAtPath:OCMOCK_ANY];
		[[[manager stub] andReturnValue:OCMOCK_VALUE(no)] gb_fileExistsAndIsDirectoryAtPath:OCMOCK_ANY];
		parser.fileManager = manager;
		parser.objectiveCParser = objcParser;
		// execute
		[parser runWithSettings:settings store:nil];
		// verify
		STAssertNoThrow([objcParser verify], nil);
	}];
}

@end

#pragma mark - 

@implementation ParserTests (CreationMethods)

- (void)runWithParser:(void (^)(Parser *))handler {
	Parser *parser = [Parser new];
	handler(parser);
}

@end