//
//  PKIntersection.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 6/27/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

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
+ (id)intersection;

+ (id)intersectionWithSubparsers:(PKParser *)p1, ...;
@end
