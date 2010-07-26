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

#import <ParseKit/PKTerminal.h>
#import <ParseKit/PKTypes.h>

/*!
    @class      PKSpecificChar 
    @brief      A <tt>PKSpecificChar</tt> matches a specified character from a character assembly.
    @details    <tt>-[PKSpecificChar qualifies:] returns true if an assembly's next element is equal to the character this object was constructed with.
*/
@interface PKSpecificChar : PKTerminal {
    
}

/*!
    @brief      Convenience factory method for initializing an autoreleased <tt>PKSpecificChar</tt> parser.
    @param      c the character this object should match
    @result     an initialized autoreleased <tt>PKSpecificChar</tt> parser.
*/
+ (PKSpecificChar *)specificCharWithChar:(PKUniChar)c;

/*!
    @brief      Designated Initializer. Initializes a <tt>PKSpecificChar</tt> parser.
    @param      c the character this object should match
    @result     an initialized <tt>PKSpecificChar</tt> parser.
*/
- (id)initWithSpecificChar:(PKUniChar)c;
@end
