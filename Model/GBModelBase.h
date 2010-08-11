//
//  GBModelBase.h
//  appledoc
//
//  Created by Tomaz Kragelj on 28.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Provides common functionality for model objects. */
@interface GBModelBase : NSObject {
	@private
	NSMutableSet *_declaredFiles;
	NSString *_commentString;
}

///---------------------------------------------------------------------------------------
/// @name Declared files handling
///---------------------------------------------------------------------------------------

/** Registers the given filename to `declaredFiles` list.
 
 If the same filename already exists in the set, nothing happens.
 
 @param filename The name of the file to register.
 @exception NSException Thrown if the given filename is `nil` or empty.
 */
- (void)registerDeclaredFile:(NSString *)filename;

/** Returns the array of all `declaredFiles` sorted by file name.
 
 @see declaredFiles
 @see registerDeclaredFile:
 */
- (NSArray *)declaredFilesSortedByName;

/** The list of all file names without path the object definition or declaration was found in. 
 
 @see registerDeclaredFile:
 @see declaredFilesSortedByName
 */
@property (readonly) NSSet *declaredFiles;

///---------------------------------------------------------------------------------------
/// @name Comments handling
///---------------------------------------------------------------------------------------

/** Registers the given comment string.
 
 @param value Comment string or `nil` to clear the comment.
 */
- (void)registerCommentString:(NSString *)value;

/** The comment string associated with this object or `nil` if no comment is associated. 
 
 @see registerCommentString:
 */
@property (readonly) NSString *commentString;

///---------------------------------------------------------------------------------------
/// @name Merging handling
///---------------------------------------------------------------------------------------

/** Merges all data from the given object.
 
 Source object is left unchanged. If the same object is passed in, nothing happens. Subclasses should override and
 add their own specifics, however they should send super object the message as well! Here's overriden method example:
 
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
