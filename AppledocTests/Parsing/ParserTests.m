//
//  ParserTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/19/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "GBSettings+Appledoc.h"
#import "Parser.h"
#import "TestCaseBase.h"

@interface ParserTests : TestCaseBase
@end

@interface ParserTests (CreationMethods)
- (void)runWithParser:(void(^)(Parser *parser))handler;
@end

#pragma mark - 

@implementation ParserTests

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

@end

#pragma mark - 

@implementation ParserTests (CreationMethods)

- (void)runWithParser:(void (^)(Parser *))handler {
	Parser *parser = [Parser new];
	handler(parser);
}

@end