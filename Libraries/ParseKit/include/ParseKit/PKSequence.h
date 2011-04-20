//
//  PKSequence.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 7/13/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

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
+ (id)sequence;

+ (id)sequenceWithSubparsers:(PKParser *)p1, ...;
@end
