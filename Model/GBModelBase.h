//
//  GBModelBase.h
//  appledoc
//
//  Created by Tomaz Kragelj on 28.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GBComment;
@class GBSourceInfo;

/** Provides common functionality for model objects. */
@interface GBModelBase : NSObject {
	@private
	NSMutableSet *_sourceInfos;
	NSMutableDictionary *_sourceInfosByFilenames;
}

///---------------------------------------------------------------------------------------
/// @name Declared files handling
///---------------------------------------------------------------------------------------

/** Registers the given `GBSourceInfo` to `sourceInfos` list.
 
 If file data with the same filename already exists in the set, it is replaced with the given one.
 
 @param data Source information data.
 @exception NSException Thrown if the given filename is `nil` or empty.
 */
- (void)registerSourceInfo:(GBSourceInfo *)data;

/** Returns the array of all `sourceInfos` sorted by file name.
 
 @see sourceInfos
 @see registerSourceInfo:
 */
- (NSArray *)sourceInfosSortedByName;

/** The list of all declared file data as `GBSourceInfo` objects. 
 
 @see registerSourceInfo:
 @see sourceInfosSortedByName
 */
@property (readonly) NSSet *sourceInfos;

///---------------------------------------------------------------------------------------
/// @name Comments handling
///---------------------------------------------------------------------------------------

/** The comment associated with this object or `nil` if no comment is associated. */
@property (retain) GBComment *comment;

///---------------------------------------------------------------------------------------
/// @name Data handling
///---------------------------------------------------------------------------------------

/** Merges all data from the given object.
 
 Source object is left unchanged. If the same object is passed in, nothing happens. Subclasses should override and add their own specifics, however they should send super object the message as well! Here's overriden method example:
 
	- (void)mergeDataFromObject:(GBModelBase *)source {
		// source data validation here...
		[super mergeDataFromObject:source];
		// merge custom data here...
	}
 
 @param source Source object to merge from.
 */
- (void)mergeDataFromObject:(id)source;

///---------------------------------------------------------------------------------------
/// @name Hierarchy handling
///---------------------------------------------------------------------------------------

/** Object's parent object or `nil` if object has no parent.
 
 This is mostly used for more in-context logging messages.
 */
@property (retain) id parentObject;


///---------------------------------------------------------------------------------------
/// @name Output generation helpers
///---------------------------------------------------------------------------------------

/** Returns the HTML reference for the object that can be used within the same HTML file.
 
 This is simply a wrapper over `[GBApplicationSettingsProviding htmlReferenceForObject:fromSource:]`, passing the given object as both method arguments. The major reason for introducing this method is the ability to reference it from the output templates! In this way all knowledge about references is handled in a single point and doesn't have to be repeated in various places.
 
 @see htmlReferenceName
 */
@property (copy) NSString *htmlLocalReference;

/** Returns the HTML reference name of the object that can be used as an anchor to link against.
 
 This is simply a wrapper over `[GBApplicationSettingsProviding htmlReferenceNameForObject:]`, passing the given object as the method argument. The major reason for introducing this method is the ability to reference it from the output templates! In this way all knowledge about references is handled in a single point and doesn't have to be repeated in various places.
 
 @see htmlLocalReference
 */
@property (copy) NSString *htmlReferenceName;

@end
