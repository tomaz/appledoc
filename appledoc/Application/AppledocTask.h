//
//  AppledocTask.h
//  appledoc
//
//  Created by Tomaž Kragelj on 3/19/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

@class GBSettings;
@class Store;

/** Helper base class for all main appledoc tasks.
 
 This class simplifies and unifies common behavior for all different tasks.
 */
@interface AppledocTask : NSObject

- (NSInteger)runWithSettings:(GBSettings *)settings store:(Store *)store;

@property (nonatomic, strong, readonly) GBSettings *settings;
@property (nonatomic, strong, readonly) Store *store;

@end

#pragma mark - Subclass API

@interface AppledocTask (Subclass)
- (NSInteger)runTask;
@end