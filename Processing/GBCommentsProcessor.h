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
@interface GBCommentsProcessor : NSObject {
    id currentContext;
    GBComment *currentComment;
    GBStore *store;
    GBApplicationSettingsProvider *settings;
    GBCommentComponentsProvider *components;
    
    NSMutableDictionary *reservedShortDescriptionData;
    GBSourceInfo *currentSourceInfo;
    id lastReferencedObject;
    BOOL alwaysRepeatFirstParagraph;
}

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

/** Processes the given `GBComment` using the given context and store.
 
 This method processes the given comment's string value and prepares all derives values. It uses the given store for dependent values such as links and similar, so make sure the store has all possible objects already registered. In order to properly handle "local" links, the method also takes `context` parameter which identifies top-level object to which the object which's comment we're processing belongs to. You can pass `nil` however this prevents any local links being processed!
 
 @param comment The comment to process.
 @param context The object identifying current context for handling links or `nil`.
 @param store The store to process against.
 @exception NSException Thrown if any of the given parameters is invalid or processing encounters unexpected error.
 @see alwaysRepeatFirstParagraph
 */
- (void)processComment:(GBComment *)comment withContext:(id)context store:(id)store;

/** Specifies whether first paragraph should be repeated or not regardless of settings.
 
 This is used for top level objects and static documents where we want to include full comment text regardless of the settings. In that situation we need to set this flag to `YES` to override settings, however for methods we must set this flag to `NO` to respect user's settings.
 
 @see processComment:withContext:store:
 */
@property (assign) BOOL alwaysRepeatFirstParagraph;

@end
