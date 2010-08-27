//
//  GBModelBase.h
//  appledoc
//
//  Created by Tomaz Kragelj on 28.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GBComment;

/** Provides common functionality for model objects. */
@interface GBModelBase : NSObject {
	@private
	NSMutableSet *_declaredFiles;
	GBComment *_comment;
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
 
 This allows parsers to register comment string to the associated `comment`. The method created a new `GBComment` instance associated with the receiver and passes it the given string value, but doesn't yet process the value yet. Processing needs to be initiated manually via `GBProcessor` instance. The reason for splitting the functionality is to simplify parsers - they can register comment strings as they appear in current context. Processing comments does take some time, so postponing allows us to parse quicker and the user can see parsing warnings immediately. Further more, processing comments requires the whole object's graph being present so that we can prepare links to other objects, so splitting the two makes even more sense.
 
 Note that in case `nil` is given for string value and a comment is already associated, the comment is changed to `nil` as well!
 
 @param value Comment string or `nil` to clear the comment.
 @see comment
 */
- (void)registerCommentString:(NSString *)value;

/** The comment associated with this object or `nil` if no comment is associated. 
 
 To register a comment, send `registerCommentString:` to receiver. To process the comment send `processParsedData` to receiver.
 
 @see registerCommentString:
 */
@property (readonly) GBComment *comment;

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
