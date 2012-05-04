//
//  ObjectiveCParserTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectiveCFileState.h"
#import "ObjectiveCInterfaceState.h"
#import "ObjectiveCPropertyState.h"
#import "ObjectiveCMethodState.h"
#import "ObjectiveCPragmaMarkState.h"
#import "ObjectiveCEnumState.h"
#import "ObjectiveCStructState.h"
#import "ObjectiveCParser.h"
#import "TestCaseBase.hh"

static void runWithParser(void(^handler)(ObjectiveCParser *parser)) {
	ObjectiveCParser *parser = [[ObjectiveCParser alloc] init];
	handler(parser);
	[parser release];
}

#pragma mark - 

SPEC_BEGIN(ObjectiveCParserTests)

describe(@"lazy accessors", ^{
	it(@"shoul initialize objects", ^{
		runWithParser(^(ObjectiveCParser *parser) {
			// execute & verify
			parser.fileState should be_instance_of([ObjectiveCFileState class]);
			parser.interfaceState should be_instance_of([ObjectiveCInterfaceState class]);
			parser.propertyState should be_instance_of([ObjectiveCPropertyState class]);
			parser.methodState should be_instance_of([ObjectiveCMethodState class]);
			parser.pragmaMarkState should be_instance_of([ObjectiveCPragmaMarkState class]);
			parser.enumState should be_instance_of([ObjectiveCEnumState class]);
			parser.structState should be_instance_of([ObjectiveCStructState class]);
			parser.tokenizer should be_instance_of([PKTokenizer class]);
		});
	});
});

SPEC_END
