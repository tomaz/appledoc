//
//  GBCommentsProcessor.h
//  appledoc
//
//  Created by Tomaz Kragelj on 27.8.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GBComment;

/** Implements comments processing.
 
 The main responsibility of this class is to process comments. As it's a helper class for `GBProcessor`, it's processing is driven by the processor, so there's no need to create instances elsewhere.
 */
@interface GBCommentsProcessor : NSObject

///---------------------------------------------------------------------------------------
/// @name Initialization & disposal
///---------------------------------------------------------------------------------------

/** Returns autoreleased processor to work with the given `GBApplicationSettingsProvider` implementor.
 
 This is the designated initializer.
 
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

/** Processes the given `GBComment` using the given store.
 
 This method processes the given comment's string value and prepares all derives values. It uses the given store for dependent values such as links and similar, so make sure the store has all possible objects already registered.
 
 @param comment The comment to process.
 @param store The store to process against.
 @exception NSException Thrown if any of the given parameters is invalid or processing encounters unexpected error.
 */
- (void)processComment:(GBComment *)comment withStore:(id)store;

@end
