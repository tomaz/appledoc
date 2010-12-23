//
//  GBCommentArgument.h
//  appledoc
//
//  Created by Tomaz Kragelj on 19.9.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GBCommentParagraph;

/** Describes an argument of a `GBComment`.
 
 An argument is a named argument such as parameter or exception. It contains the argument (parameter or exception) name as `argumentName` and corresponding description in the form of `GBCommentParagraph` as `argumentDescription`.
 */
@interface GBCommentArgument : NSObject

///---------------------------------------------------------------------------------------
/// @name Initialization & disposal
///---------------------------------------------------------------------------------------

/** Returns a new autoreleased argument with the given name and description.
 
 Sending this method is equivalent to:
 
	GBCommentArgument *argument = [[[GBCommentArgument alloc] init] autorelease];
	argument.argumentName = name;
	argument.argumentDescription = description;
 
 @param name The name of the argument.
 @param description Description of the argument.
 @return Returns initialized instance.
 @exception NSException Thrown if name is `nil` or empty string or description is `nil`.
 */
+ (id)argumentWithName:(NSString *)name description:(GBCommentParagraph *)description;

/** Returns a new autoreleased argument with no name and description. */
+ (id)argument;

///---------------------------------------------------------------------------------------
/// @name Values
///---------------------------------------------------------------------------------------

/** The name of the argument.
 
 @see argumentDescription
 */
@property (copy) NSString *argumentName;

/** Description of the argument as `GBCommentParagraph`.
 
 @see argumentName
 */
@property (retain) GBCommentParagraph *argumentDescription;

@end
