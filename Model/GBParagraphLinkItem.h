//
//  GBParagraphLinkItem.h
//  appledoc
//
//  Created by Tomaz Kragelj on 7.9.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBParagraphItem.h"

@protocol GBObjectDataProviding;

/** Specifies a link paragraph item.
 
 Link items wrap a cross reference link with all the data. There are several types of links:
 
 - Link to a URL: Points to a http, ftp or file objects. `stringValue` value represents the link value, while all other properties are `nil`. `isLocal` is `NO`.
 - Link to an object: Points to a known top-level object. `stringValue` value represents nicely formatted object's name and `context` points to the object instance while all other properties are `nil` and `isLocal` is either `YES` if the link's origin is the same object or `NO` if it's a link to another object.
 - Link to a local member: Points to another member of the same known top-level object. `stringValue` value represents nicely formatted link value, `context` points to the object instance and `member` to the object's member instance. `isLocal` value is `YES`.
 - Link to a member of another object: Points to a member of another object. Values representation is the same as in previous option, only `isLocal` value is `NO` in this case.
 */
@interface GBParagraphLinkItem : GBParagraphItem

///---------------------------------------------------------------------------------------
/// @name Values
///---------------------------------------------------------------------------------------

/** The href value to which the link "points" to. 
 
 This can actually be used when generating output to get proper URL of the link item.
 */
@property (retain) NSString *href;

/** The context to which the link's `member` points to or `nil` if this is a `stringValue` link.
 
 The context can be either `GBClassData`, `GBCategoryData` or `GBProtocolData` if provided.
 
 @see member
 @see isLocal
 */
@property (retain) id context;

/** The member to which the link points to or `nil` if this is either a `stringValue` link or `context` link.
 
 This is only used if the link points to a `member` within a `context`. If this is link to the `context` itself or to an `stringValue`, this value is `nil`. The member can only be a `GBMethodData` instance at this point.
 
 @see context
 @see isLocal
 */
@property (retain) id member;

/** Specifies whether the link is local or not.
 
 If a link is local, it points from within a `context` either to the `context` itself (i.e. `member` is `nil`) or to on eof the the same `context`s members. If the link points to another `context` or to one of other `context`s `member`, or this is a `stringValue` link, the value is `NO`. 
 
 @see context
 @see member
 */
@property (assign) BOOL isLocal;

@end
