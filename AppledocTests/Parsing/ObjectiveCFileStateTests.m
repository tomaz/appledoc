//
//  ObjectiveCParserTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectiveCFileState.h"
#import "ObjectiveCParser.h"
#import "TestCaseBase.h"

@interface ObjectiveCParserTests : TestCaseBase
@end

@interface ObjectiveCParserTests (CreationMethods)
- (void)runWithState:(void(^)(ObjectiveCFileState *state))handler;
@end

#pragma mark - 

@implementation ObjectiveCParserTests

@end

#pragma mark - 

@implementation ObjectiveCParserTests (CreationMethods)

- (void)runWithState:(void(^)(ObjectiveCFileState *state))handler {
	ObjectiveCFileState* state = [ObjectiveCFileState new];
	handler(state);
}

@end