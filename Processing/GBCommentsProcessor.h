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

/** Processes the comment of the given object using the given context and store.
 
 This method processes the given comment's string value and prepares all derives values. It uses the given store for dependent values such as links and similar, so make sure the store has all possible objects already registered. In order to properly handle "local" links, the method also takes `context` parameter which identifies top-level object to which the object which's comment we're processing belongs to. You can pass `nil` however this prevents any local links being processed!
 
 @warning **Important:** Note that this method is similar to `processComment:withContext:store:`, in fact, the only difference is that it stores the given object to internal property and then sends `processComment:withContext:store:` to receiver. The big difference is that this method prevents forming cross references to current member, while `processComment:withContext:store:` doesn't. Therefore, this is preffered method for processing comments. The only reasong for keeping two methods is due to unit tests relying on `processComment:withContext:store:` - as that was previously the entry point for processing, all unit tests use it and I don't want to update all of them. So the quick fix was to introduce another method, make sure it gets called from other parts of the tool and keep it as simple as possible.
 
 @param comment The comment to process.
 @param context The object identifying current context for handling links or `nil`.
 @param store The store to process against.
 @exception NSException Thrown if any of the given parameters is invalid or processing encounters unexpected error.
 @see alwaysRepeatFirstParagraph
 */
- (void)processCommentForObject:(GBModelBase *)object withContext:(id)context store:(id)store;

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
