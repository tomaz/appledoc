//
//  PKToken+GBToken.h
//  appledoc
//
//  Created by Tomaz Kragelj on 23.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import <ParseKit/ParseKit.h>

/** Defines extensions to `PKToken` which simplify parsing code.
 */
@interface PKToken (GBToken)

/** Determines if this token's string value is equal to the given string.
 
 @param string The string to compare with.
 @return Returns `YES` if the string value is equal, `NO` otherwise.
 */
- (BOOL)matches:(NSString *)string;

/** Determines if this token's string value contains the given string.
 
 @param string The string to compare with.
 @return Returns `YES` if the string value contains string, `NO` otherwise.
 */
- (BOOL)contains:(NSString *)string;

/** Determines whether this token is an appledoc comment.
 
 The method returns `YES` if the token is a comment and it has special appledoc comment prefix which for single line comments is composed of three slashes and for multiple line comments from a single slash and two stars.
 
 @return Returns `YES` if the token represents appledoc comment, `NO` otherwise.
 */
- (BOOL)isAppledocComment;

@end
