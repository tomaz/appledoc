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
#import "ObjectiveCConstantState.h"
#import "ObjectiveCParser.h"
#import "TestCaseBase.h"

@interface ObjectiveCParserTests : TestCaseBase
@end

@interface ObjectiveCParserTests (CreationMethods)
- (void)runWithParser:(void(^)(ObjectiveCParser *parser))handler;
@end

#pragma mark - 

@implementation ObjectiveCParserTests

#pragma mark - Properties

- (void)testLazyAccessorsShouldInitializeObjects {
	[self runWithParser:^(ObjectiveCParser *parser) {
		// execute & verify
		assertThat(parser.fileState, instanceOf([ObjectiveCFileState class]));
		assertThat(parser.interfaceState, instanceOf([ObjectiveCInterfaceState class]));
		assertThat(parser.propertyState, instanceOf([ObjectiveCPropertyState class]));
		assertThat(parser.methodState, instanceOf([ObjectiveCMethodState class]));
		assertThat(parser.pragmaMarkState, instanceOf([ObjectiveCPragmaMarkState class]));
		assertThat(parser.enumState, instanceOf([ObjectiveCEnumState class]));
		assertThat(parser.structState, instanceOf([ObjectiveCStructState class]));
		assertThat(parser.constantState, instanceOf([ObjectiveCConstantState class]));
	}];
}

@end

#pragma mark - 

@implementation ObjectiveCParserTests (CreationMethods)

- (void)runWithParser:(void (^)(ObjectiveCParser *))handler {
	ObjectiveCParser *parser = [ObjectiveCParser new];
	handler(parser);
}

@end