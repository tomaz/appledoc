//  Copyright 2010 Todd Ditchendorf
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

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
