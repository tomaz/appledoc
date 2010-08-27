//
//  GBComment.h
//  appledoc
//
//  Created by Tomaz Kragelj on 27.8.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GBStoreProviding;

/** Handles all comment related stuff.
 */
@interface GBComment : NSObject

///---------------------------------------------------------------------------------------
/// @name Initialization & disposal
///---------------------------------------------------------------------------------------

/** Initializes the comment with the given string value.
 
 This is a helper initializer which allows setting string value with a single message.
 
 @param value String value to set.
 @return Returns initialized object or `nil` if initialization fails.
 */
+ (id)commentWithStringValue:(NSString *)value;

///---------------------------------------------------------------------------------------
/// @name Derived values
///---------------------------------------------------------------------------------------

/** Processes `stringValue` and prepares all derived values.
 
 This message should be sent before using derived values. If comment string value contains links, they are validated with the given store, so make sure the store already has all objects registered before sending this message! If any kind of inconsistency is detected, a warning is logged and processing continues. This allows us to extract as much information as possible, while ignoring problems.
 
 @exception NSException Thrown if the given store is `nil` or processing fails due to unexpected error.
 */
- (void)processCommentWithStore:(id<GBStoreProviding>)store;

/** `NSArray` containing all paragraphs of the comment.
 
 The paragraphs are in same order as in the source code. First paragraph is used for short description. Each object is a `GBCommentParagraph` instance. The array is prepared by `GBProcessor` during post-processing and is not available before!
 */
@property (readonly) NSMutableArray *paragraphs;

///---------------------------------------------------------------------------------------
/// @name Input values
///---------------------------------------------------------------------------------------

/** Comment's raw string value as declared in source code. */
@property (copy) NSString *stringValue;

@end
