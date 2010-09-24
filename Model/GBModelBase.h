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

/** Registers the given `GBDeclaredFileData` to `sourceInfos` list.
 
 If file data with the same filename already exists in the set, it is replaced with the given one.
 
 @param filename The name of the file to register.
 @exception NSException Thrown if the given filename is `nil` or empty.
 */
- (void)registerSourceInfo:(GBSourceInfo *)data;

/** Returns the array of all `sourceInfos` sorted by file name.
 
 @see sourceInfos
 @see registerSourceInfo:
 */
- (NSArray *)sourceInfosSortedByName;

/** The list of all declared file data as `GBDeclaredFileData` objects. 
 
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

@end
