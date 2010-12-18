//
//  GBProcessor.h
//  appledoc
//
//  Created by Tomaz Kragelj on 27.8.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Handles processing of parsed data from any given `GBStore`.
 
 Processing phase is where parsed raw data is prepared for output. The most prominent part is processing comment raw values by validating and preparing links, formatting etc.
 */
@interface GBProcessor : NSObject

///---------------------------------------------------------------------------------------
/// @name ￼Initialization & disposal
///---------------------------------------------------------------------------------------

/** Returns autoreleased processor that work with the given `GBApplicationSettingsProvider` implementor.
 
 @param settingsProvider Application-wide settings provider to use for checking parameters.
 @return Returns initialized instance or `nil` if initialization fails.
 @exception NSException Thrown if the given application is `nil`.
 */
+ (id)processorWithSettingsProvider:(id)settingsProvider;

/** Initializes the processor to work with the given `GBApplicationSettingsProvider` implementor.
 
 This is the designated initializer.
 
 @param settingsProvider Application-wide settings provider to use for checking parameters.
 @return Returns initialized instance or `nil` if initialization fails.
 @exception NSException Thrown if the given application is `nil`.
 */
- (id)initWithSettingsProvider:(id)settingsProvider;

///---------------------------------------------------------------------------------------
/// @name Processing handling
///---------------------------------------------------------------------------------------

/** Processes all objects from the given store.
 
 This is the main processing method. It is intended to be invoked from the top level application code. It accepts a `GBStore` with parsed objects and processes all registered objects to make them ready for output. All object's and their data is recursively descended so every object that needs processing is handled properly!
 
 If any kind of inconsistency is detected in source code, a warning is logged and processing continues. This allows us to extract as much information as possible, while ignoring problems.
 
 @param store The store that contains all parsed objects.
 @exception NSException Thrown if a serious problem is detected which prevents us from processing.
 */
- (void)processObjectsFromStore:(id)store;

@end
