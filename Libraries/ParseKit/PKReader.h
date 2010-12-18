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
#import <ParseKit/PKTypes.h>

/*!
    @class      PKReader 
    @brief      A character-stream reader that allows characters to be pushed back into the stream.
*/
@interface PKReader : NSObject {
    NSString *string;
    NSUInteger offset;
    NSUInteger length;
}

/*!
    @brief      Designated Initializer. Initializes a reader with a given string.
    @details    Designated Initializer.
    @param      s string from which to read
    @result     an initialized reader
*/
- (id)initWithString:(NSString *)s;

/*!
    @brief      Read a single UTF-16 unicode character
    @result     The character read, or <tt>PKEOF</tt> (-1) if the end of the stream has been reached
*/
- (PKUniChar)read;

/*!
    @brief      Push back a single character
    @details    moves the offset back one position
*/
- (void)unread;

/*!
    @brief      Push back count characters
    @param      count of characters to push back
    @details    moves the offset back count positions
*/
- (void)unread:(NSUInteger)count;

/*!
    @property   string
    @brief      This reader's string.
*/
@property (nonatomic, copy) NSString *string;

/*!
    @property   offset
    @brief      This reader's current offset in string
*/
@property (nonatomic, readonly) NSUInteger offset;
@end
