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
    @class      PKDifference
    @brief      A <tt>PKDifference</tt> matches anything its <tt>subparser</tt> would match except for anything its <tt>minus</tt> parser would match.
    @details    The example below would match any <tt>Word</tt> token except for <tt>true</tt> or <tt>false</tt>.

@code
    PKParser *trueParser = [PKLiteral literalWithString:@"true"];
    PKParser *falseParser = [PKLiteral literalWithString:@"false"];
    PKAlternation *reservedWords = [PKAlternation alternationWithSubparsers:trueParser, falseParser, nil];

    PKDifference *diff = [PKDifference differenceWithSubparser:[PKWord word] minus:reservedWords];
@endcode
*/
@interface PKDifference : PKParser {
    PKParser *subparser;
    PKParser *minus;
}

/*!
    @brief      Convenience factory method for initializing an autoreleased <tt>PKDifference</tt> parser.
    @param      subparser the parser this parser uses for matching
    @param      minus the parser whose matches will be exluded
    @result     an initialized autoreleased <tt>PKDifference</tt> parser.
*/
+ (PKDifference *)differenceWithSubparser:(PKParser *)s minus:(PKParser *)m;

/*!
    @brief      Designated initializer
    @param      subparser the parser this parser uses for matching
    @param      minus the parser whose matches will be exluded
    @result     an initialized <tt>PKDifference</tt> parser.
*/
- (id)initWithSubparser:(PKParser *)s minus:(PKParser *)m;

/*!
    @property   subparser
    @brief      this parser's subparser which it will initially match against
*/
@property (nonatomic, retain, readonly) PKParser *subparser;

/*!
    @property   minus
    @brief      after a successful match against <tt>subparser</tt>, matches against <tt>minus</tt> will not be matched by this parser
*/
@property (nonatomic, retain, readonly) PKParser *minus;
@end
