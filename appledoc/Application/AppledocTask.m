//
//  AppledocTask.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/19/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "GBSettings+Appledoc.h"
#import "Store.h"
#import "AppledocTask.h"

@interface AppledocTask ()
@property (nonatomic, strong, readwrite) GBSettings *settings;
@property (nonatomic, strong, readwrite) Store *store;
@end

#pragma mark -

@implementation AppledocTask

@synthesize settings = _settings;
@synthesize store = _store;

#pragma mark - Running the task

- (NSInteger)runWithSettings:(GBSettings *)settings store:(Store *)store {
	self.settings = settings;
	self.store = store;
	return [self runTask];
}

@end
