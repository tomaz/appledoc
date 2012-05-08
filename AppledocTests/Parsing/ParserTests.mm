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
#import "TestCaseBase.hh"

static void runWithParser(void(^handler)(Parser *parser)) {
	Parser *parser = [[Parser alloc] init];
	handler(parser);
	[parser release];
}

#pragma mark - 

TEST_BEGIN(ParserTests)

describe(@"lazy accessors:", ^{
	it(@"should initialize objects", ^{
		runWithParser(^(Parser *parser) {
			// execute & verify
			parser.objectiveCParser should be_instance_of([ObjectiveCParser class]);
		});
	});
});

describe(@"running:", ^{
	it(@"should enumerate arguments on the given settings", ^{
		runWithParser(^(Parser *parser) {
			// setup
			id arguments = [OCMockObject mockForClass:[NSArray class]];
			[[arguments expect] enumerateObjectsUsingBlock:OCMOCK_ANY];
			id settings = [OCMockObject mockForClass:[GBSettings class]];
			[[[settings expect] andReturn:arguments] arguments];
			// execute
			[parser runWithSettings:settings store:nil];
			// verify
			^{ [settings verify]; } should_not raise_exception();
			^{ [arguments verify]; } should_not raise_exception();
		});
	});
	
	it(@"should invoke Objective C parser on source files", ^{
		runWithParser(^(Parser *parser) {
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
			^{ [objcParser verify]; } should_not raise_exception();
		});
	});
});

TEST_END
