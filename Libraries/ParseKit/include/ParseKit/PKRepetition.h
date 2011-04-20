//
//  PKRepetition.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 7/13/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

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
+ (id)repetitionWithSubparser:(PKParser *)p;

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
