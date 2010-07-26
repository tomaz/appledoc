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
#import <ParseKit/PKTerminal.h>

/*!
    @class      PKQuotedString 
    @brief      A <tt>PKQuotedString</tt> matches a quoted string, like "this one" from a token assembly.
*/
@interface PKQuotedString : PKTerminal {

}

/*!
    @brief      Convenience factory method for initializing an autoreleased <tt>PKQuotedString</tt> object.
    @result     an initialized autoreleased <tt>PKQuotedString</tt> object
*/
+ (PKQuotedString *)quotedString;
@end
