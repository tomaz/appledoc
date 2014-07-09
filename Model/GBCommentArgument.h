//
//  GBCommentArgument.h
//  appledoc
//
//  Created by Tomaz Kragelj on 16.2.11.
//  Copyright 2011 Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GBCommentComponentsList;
@class GBSourceInfo;

/** Handles individual `GBComment` named argument.
 
 A comment argument is either a parameter or exception. In any case, the class allows assigning argument name and description. The description is simply a list of comment components in the form of `GBCommentComponentsList`. This allows every parameter contain arbitrary descriptions!
 */
@interface GBCommentArgument : NSObject

///---------------------------------------------------------------------------------------
/// @name Initialization & disposal
///---------------------------------------------------------------------------------------

/** Returns a new autoreleased instance of the object with the given string value.
 
 This is a helper initializer which allows setting name with a single message. Sending this message is equivalent to sending `argumentWithName:sourceInfo:`, passing the given _value_ and `nil` for source info.
 
 @param name Name of the argument.
 @return Returns initialized object or `nil` if initialization fails.
 @see argumentWithName:sourceInfo:
 */
+ (id)argumentWithName:(NSString *)name;

/** Returns a new autoreleased instance of the comment with the given string value and source info.
 
 This is a helper initializer which allows setting default values with a single message.
 
 @param name Name of the argument.
 @param info Source info to set.
 @return Returns initialized object or `nil` if initialization fails.
 @see argumentWithName:
 */
+ (id)argumentWithName:(NSString *)name sourceInfo:(GBSourceInfo *)info;

///---------------------------------------------------------------------------------------
/// @name Argument description
///---------------------------------------------------------------------------------------

/** The name of the argument.
 */
@property (copy) NSString *argumentName;

/** The description components of the argument as `GBCommentComponentsList`.
 */
@property (strong) GBCommentComponentsList *argumentDescription;

/** Source file information.
 */
@property (strong) GBSourceInfo *sourceInfo;

@end
