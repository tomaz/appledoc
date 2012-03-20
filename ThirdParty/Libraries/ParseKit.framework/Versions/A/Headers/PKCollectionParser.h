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
    @class      PKCollectionParser 
    @brief      An Abstract class. This class abstracts the behavior common to parsers that consist of a series of other parsers.
*/
@interface PKCollectionParser : PKParser {
    NSMutableArray *subparsers;
}

/*!
    @brief      Designated Initializer. Initialize an instance of a <tt>PKCollectionParser</tt> subclass.
    @param      p1, ... A comma-separated list of parser objects ending with <tt>nil</tt>
    @result     an initialized instance of a <tt>PKCollectionParser</tt> subclass.
*/
- (id)initWithSubparsers:(PKParser *)p1, ...;

/*!
    @brief      Adds a parser to the collection.
    @param      p parser to add
*/
- (void)add:(PKParser *)p;

/*!
    @property   subparsers
    @brief      This parser's subparsers.
*/
@property (nonatomic, readonly, retain) NSMutableArray *subparsers;
@end
