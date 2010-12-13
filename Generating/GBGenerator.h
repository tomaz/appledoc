//
//  GBGenerator.h
//  appledoc
//
//  Created by Tomaz Kragelj on 29.9.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Handles generating of parsed and processed data from any given `GBStore`.
 
 Generating phase is where output is generated from parsed and processed data - in other words, this is where the work previous phases has done becomes visible and therefore usable for the users. As such, this class is the engine for generating output, but doesn't do actual generation itself. Instead, it serves as an single and simple entry point for the rest of the application. Internally it delegates actual generation tasks to various lower-level objects, based on user's choices.
 */
@interface GBGenerator : NSObject

///---------------------------------------------------------------------------------------
/// @name Initialization & disposal
///---------------------------------------------------------------------------------------

/** Returns autoreleased generator that work with the given `GBApplicationSettingsProvider` implementor.
 
 @param settingsProvider Application-wide settings provider to use for checking parameters.
 @return Returns initialized instance or `nil` if initialization fails.
 @exception NSException Thrown if the given application is `nil`.
 */
+ (id)generatorWithSettingsProvider:(id)settingsProvider;

/** Initializes the generator to work with the given `GBApplicationSettingsProvider` implementor.
 
 This is the designated initializer.
 
 @param settingsProvider Application-wide settings provider to use for checking parameters.
 @return Returns initialized instance or `nil` if initialization fails.
 @exception NSException Thrown if the given application is `nil`.
 */
- (id)initWithSettingsProvider:(id)settingsProvider;

///---------------------------------------------------------------------------------------
/// @name Generation handling
///---------------------------------------------------------------------------------------

/** Generates all required output from objects registered within the given store.
 
 This is the main generating method. It is intended to be invoked from the top level application code. It accepts a `GBStore` with parsed and processed objects and generates output for all registered objects. All object's and their data is recursively descended so every object that needs to be generated is handled properly!
 
 If any kind of inconsistency is detected in the store, a warning is logged and processing continues. This allows us to generate as much information as possible, while ignoring problems.
 
 @param store The store that contains all parsed and processed objects.
 @exception NSException Thrown if a serious problem is detected which prevents us from processing.
 */
- (void)generateOutputFromStore:(id)store;

@end
