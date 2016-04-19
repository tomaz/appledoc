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
    @class      PKIntersection
    @brief      A <tt>PKIntersection</tt> matches input that matches all of its subparsers. It is basically a representation of "Logical And" or "&".
    @details    The example below would match any token which is both a word and matches the given regular expression pattern. 
                Using a <tt>PKIntersection</tt> in this case would improve performance over using just a <tt>PKPattern</tt> parser as the regular expression would be evaluated fewer times.
 
@code
    PKParser *pattern = [PKPattern patternWithString:@"_.+"];
 
    PKIntersection *wordStartingWithUnderscore = [PKIntersection intersectionWithSubparsers:[PKWord word], pattern, nil];
@endcode 
*/
@interface PKIntersection : PKCollectionParser {

}

/*!
    @brief      Convenience factory method for initializing an autoreleased <tt>PKIntersection</tt> parser.
    @result     an initialized autoreleased <tt>PKIntersection</tt> parser.
*/
+ (PKIntersection *)intersection;

+ (PKIntersection *)intersectionWithSubparsers:(PKParser *)p1, ...;
@end
