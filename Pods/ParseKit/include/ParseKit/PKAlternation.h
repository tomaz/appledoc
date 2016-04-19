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
#import <ParseKit/PKCollectionParser.h>

/*!
    @class      PKAlternation
    @brief      A <tt>PKAlternation</tt> object is a collection of parsers, any one of which can successfully match against an assembly. It is basically a representation of "Logical Or" or "|".
*/
@interface PKAlternation : PKCollectionParser {

}

/*!
    @brief      Convenience factory method for initializing an autoreleased <tt>PKAlternation</tt> parser.
    @result     an initialized autoreleased <tt>PKAlternation</tt> parser.
*/
+ (PKAlternation *)alternation;

+ (PKAlternation *)alternationWithSubparsers:(PKParser *)p1, ...;
@end
