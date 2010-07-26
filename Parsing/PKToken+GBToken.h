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

@end
