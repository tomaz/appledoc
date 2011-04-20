//
//  PKTrackException.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 10/14/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const PKTrackExceptionName;

/*!
 @class     PKTrackException
 @brief     Signals that a parser could not match text after a specific point.
 @details   The <tt>userInfo</tt> for this exception contains the following keys:<pre>
            <tt>after</tt> (<tt>NSString *</tt>) - some indication of what text was interpretable before this exception occurred
            <tt>expected</tt> (<tt>NSString *</tt>) - some indication of what kind of thing was expected, such as a ')' token
            <tt>found</tt> (<tt>NSString *</tt>) - the text element the thrower actually found when it expected something else</pre>
*/
@interface PKTrackException : NSException {

}

@end
