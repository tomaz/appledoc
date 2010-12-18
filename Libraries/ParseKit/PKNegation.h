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

#import <ParseKit/PKParser.h>

/*!
    @class      PKNegation
    @brief      A <tt>PKNegation</tt> negates the matching logic of its subparser. It matches anything its subparser would not.
    @details    The example below would match any token except for a <tt>?></tt> symbol token. This could be useful for matching all tokens until an end marker (in this case a PHP end marker) is found.

@code
    PKParser *question = [PKSymbol symbolWithString:@"?>"];
 
    PKNegation *n = [PKNegation negationWithSubparser:question];
@endcode 
*/
@interface PKNegation : PKParser {
    PKParser *subparser;
    PKParser *difference;
}

/*!
    @brief      Convenience factory method for initializing an autoreleased <tt>PKNegation</tt> parser.
    @param      subparser the parser whose matching logic is negated
    @result     an initialized autoreleased <tt>PKNegation</tt> parser.
*/
+ (PKNegation *)negationWithSubparser:(PKParser *)s;

/*!
    @brief      Designated initializer
    @param      subparser the parser whose matching logic is negated
    @result     an initialized <tt>PKNegation</tt> parser.
*/
- (id)initWithSubparser:(PKParser *)s;

/*!
    @property   subparser
    @brief      this parser's subparser whose matching logic is negated
*/
@property (nonatomic, retain, readonly) PKParser *subparser;
@end
