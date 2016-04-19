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
#import <ParseKit/PKParser.h>

/*!
    @class      PKEmpty 
    @brief      A <tt>PKEmpty</tt> parser matches any assembly once, and applies its assembler that one time.
    @details    <p>Language elements often contain empty parts. For example, a language may at some point allow a list of parameters in parentheses, and may allow an empty list. An empty parser makes it easy to match, within the parenthesis, either a list of parameters or "empty".</p>
*/
@interface PKEmpty : PKParser {

}

/*!
    @brief      Convenience factory method for initializing an autoreleased <tt>PKEmpty</tt> parser.
    @result     an initialized autoreleased <tt>PKEmpty</tt> parser.
*/
+ (PKEmpty *)empty;
@end
