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

@class PKToken;

/*!
    @class      PKTerminal
    @brief      An Abstract Class. A <tt>PKTerminal</tt> is a parser that is not a composition of other parsers.
*/
@interface PKTerminal : PKParser {
    NSString *string;
    BOOL discardFlag;
}

/*!
    @brief      Designated Initializer for all concrete <tt>PKTerminal</tt> subclasses.
    @details    Note this is an abtract class and this method must be called on a concrete subclass.
    @param      s the string matched by this parser
    @result     an initialized <tt>PKTerminal</tt> subclass object
*/
- (id)initWithString:(NSString *)s;

/*!
    @brief      By default, terminals push themselves upon a assembly's stack, after a successful match. This method will turn off that behavior.
    @details    This method returns this parser as a convenience for chainging-style usage.
    @result     this parser, returned for chaining/convenience
*/
- (PKTerminal *)discard;

/*!
    @property   string
    @brief      the string matched by this parser.
*/
@property (nonatomic, readonly, copy) NSString *string;
@end
