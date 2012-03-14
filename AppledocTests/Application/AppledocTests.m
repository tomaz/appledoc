//
//  AppledocTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/14/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects+TestingPrivateAPI.h"
#import "Appledoc.h"
#import "Settings.h"
#import "TestCaseBase.h"

@interface Appledoc (TestingPrivateAPI)
@property (nonatomic, strong) Settings *settings;
@end

#pragma mark - 

@interface AppledocTests : TestCaseBase
@end

@interface AppledocTests (CreationMethods)
- (void)runWithAppledoc:(void(^)(Appledoc *appledoc))handler;
@end

@implementation AppledocTests
@end

#pragma mark -

@implementation AppledocTests (CreationMethods)

- (void)runWithAppledoc:(void(^)(Appledoc *appledoc))handler {
	Appledoc *appledoc = [[Appledoc alloc] init];
	handler(appledoc);
}

@end
