//
//  ObjectiveCStateTestsBase.h
//  appledoc
//
//  Created by Tomaž Kragelj on 3/28/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectiveCParser.h"
#import "TokensStream.h"
#import "Store.h"
#import "TestCaseBase.h"

typedef void(^GBStateMockBlock)(id parser, id tokens);

@interface ObjectiveCStateTestsBase : TestCaseBase

- (void)runWithString:(NSString *)string block:(GBStateMockBlock)handler;
- (void)runWithFile:(NSString *)file block:(GBStateMockBlock)handler;

@end
