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

@class PKToken;

/*!
    @class      PKSymbol 
    @brief      A <tt>PKSymbol</tt> matches a specific sequence, such as <tt>&lt;</tt>, or <tt>&lt;=</tt> that a tokenizer returns as a symbol.
*/
@interface PKSymbol : PKTerminal {
    PKToken *symbol;
}

/*!
    @brief      Convenience factory method for initializing an autoreleased <tt>PKSymbol</tt> object with a <tt>nil</tt> string value.
    @result     an initialized autoreleased <tt>PKSymbol</tt> object with a <tt>nil</tt> string value
*/
+ (PKSymbol *)symbol;

/*!
    @brief      Convenience factory method for initializing an autoreleased <tt>PKSymbol</tt> object with <tt>s</tt> as a string value.
    @param      s the string represented by this symbol
    @result     an initialized autoreleased <tt>PKSymbol</tt> object with <tt>s</tt> as a string value
*/
+ (PKSymbol *)symbolWithString:(NSString *)s;
@end
