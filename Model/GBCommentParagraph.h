//
//  GBCommentParagraph.h
//  appledoc
//
//  Created by Tomaz Kragelj on 27.8.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/** Describes a paragraph for a `GBComment`.
 
 A paragraph is simply an array of items. It can contain the following objects: `GBCommentText`, `GBCommentList`, `GBCommentSpecial`, `GBCommentLink`, `GBCommentExample`.
 */
@interface GBCommentParagraph : NSObject

///---------------------------------------------------------------------------------------
/// @name Initialization & disposal
///---------------------------------------------------------------------------------------

/** Returns autoreleased paragraph instance. */
+ (id)paragraph;

///---------------------------------------------------------------------------------------
/// @name Input values
///---------------------------------------------------------------------------------------

/** Paragraph's raw string value as declared in source code. */
@property (copy) NSString *stringValue;

@end
