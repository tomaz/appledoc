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
    @class      PKSequence 
    @brief      A <tt>PKSequence</tt> object is a collection of parsers, all of which must in turn match against an assembly for this parser to successfully match.
*/
@interface PKSequence : PKCollectionParser {

}

/*!
    @brief      Convenience factory method for initializing an autoreleased <tt>PKSequence</tt> parser.
    @result     an initialized autoreleased <tt>PKSequence</tt> parser.
*/
+ (PKSequence *)sequence;

+ (PKSequence *)sequenceWithSubparsers:(PKParser *)p1, ...;
@end
