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
    @class      PKRepetition 
    @brief      A <tt>PKRepetition</tt> matches its underlying parser repeatedly against a assembly.
*/
@interface PKRepetition : PKParser {
    PKParser *subparser;
}

/*!
    @brief      Convenience factory method for initializing an autoreleased <tt>PKRepetition</tt> parser to repeatedly match against subparser <tt>p</tt>.
    @param      p the subparser against wich to repeatedly match
    @result     an initialized autoreleased <tt>PKRepetition</tt> parser.
*/
+ (PKRepetition *)repetitionWithSubparser:(PKParser *)p;

/*!
    @brief      Designated Initializer. Initialize a <tt>PKRepetition</tt> parser to repeatedly match against subparser <tt>p</tt>.
    @details    Designated Initializer. Initialize a <tt>PKRepetition</tt> parser to repeatedly match against subparser <tt>p</tt>.
    @param      p the subparser against wich to repeatedly match
    @result     an initialized <tt>PKRepetition</tt> parser.
*/
- (id)initWithSubparser:(PKParser *)p;

/*!
    @property   subparser
    @brief      this parser's subparser against which it repeatedly matches
*/
@property (nonatomic, readonly, retain) PKParser *subparser;
@end
