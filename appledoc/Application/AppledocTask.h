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
 
 This class simplifies and unifies common behavior for all different tasks. To use it, create concrete subclass(es), then send `runWithSettings:store:` to instantiated objects to have them do their work. Subclass will return exit code - `0` if everything was succesful, or error code otherwise. You can optionally push your custom helper objects prior to running the task - this gives you ways to customize subclass behavior, although it should not be needed under normal circumstances (the hooks are there primarily for unit testing purposes).
 */
@interface AppledocTask : NSObject

- (NSInteger)runWithSettings:(GBSettings *)settings store:(Store *)store;

@property (nonatomic, strong) NSFileManager *fileManager;

@end

#pragma mark - Subclass API

/** Private API for AppledocTask subclasses.
 
 This is sent internally by AppledocTask and should not be used otherwise.
 */
@interface AppledocTask (Subclass)
- (NSInteger)runTask;
@property (nonatomic, strong, readonly) Store *store;
@property (nonatomic, strong, readonly) GBSettings *settings;
@end