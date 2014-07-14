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
    BOOL _includeInOutput;
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
 @see prefferedSourceInfo
 */
- (NSArray *)sourceInfosSortedByName;

/** Returns the preffered source info that should be rendered to output.
 
 This investigates `sourceInfos` list and `comment` and returns the most likely used one. If comment is given and has source information attached, that one is used. If comment is not given, source information list from the receiver is used. If header file is found in the list, that one is preffered. If header file is not found, the first file is returned.
 
 @return Returns preffered source information object to be used for output.
 @see sourceInfos
 @see sourceInfosSortedByName
 */
@property (readonly) GBSourceInfo *prefferedSourceInfo;

/** The list of all declared file data as `GBSourceInfo` objects. 
 
 @see registerSourceInfo:
 @see sourceInfosSortedByName
 @see prefferedSourceInfo
 */
@property (readonly) NSSet *sourceInfos;

///---------------------------------------------------------------------------------------
/// @name Comments handling
///---------------------------------------------------------------------------------------

/** The comment associated with this object or `nil` if no comment is associated. */
@property (strong) GBComment *comment;

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
 
 And a link to `comment` and `registerSourceInfo:`.
 
 @param source Source object to merge from.
 */
- (void)mergeDataFromObject:(id)source;

///---------------------------------------------------------------------------------------
/// @name Hierarchy handling
///---------------------------------------------------------------------------------------

/** Object's parent object or `nil` if object has no parent.
 
 This is mostly used for more in-context logging messages.
 */
@property (strong) id parentObject;

/** Specifies whether this is a static object or not.
 
 @see isTopLevelObject
 */
@property (readonly) BOOL isStaticDocument;

/** Specifies whether this is a top level object or not.
 
 Top level objects are classes, categories and protocols.
 
 @see isStaticDocument;
 */
@property (readonly) BOOL isTopLevelObject;

///---------------------------------------------------------------------------------------
/// @name Output generation helpers
///---------------------------------------------------------------------------------------

/** Returns the HTML reference for the object that can be used within the same HTML file.
 
 This is simply a wrapper over `[GBApplicationSettingsProvider htmlReferenceForObject:fromSource:]`, passing the given object as both method arguments. The major reason for introducing this method is the ability to reference it from the output templates! In this way all knowledge about references is handled in a single point and doesn't have to be repeated in various places.
 
 @see htmlReferenceName
 */
@property (copy) NSString *htmlLocalReference;

/** Returns the HTML reference name of the object that can be used as an anchor to link against.
 
 This is simply a wrapper over `[GBApplicationSettingsProvider htmlReferenceNameForObject:]`, passing the given object as the method argument. The major reason for introducing this method is the ability to reference it from the output templates! In this way all knowledge about references is handled in a single point and doesn't have to be repeated in various places.
 
 @see htmlLocalReference
 */
@property (copy) NSString *htmlReferenceName;

/** Whether output should be generated for this class.  If `NO`, this class is purely made available for the processing of other classes. */
@property (assign) BOOL includeInOutput;

@end
