//
//  PKTerminal.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 7/13/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ParseKit/PKParser.h>

@class PKToken;

/*!
    @class      PKTerminal
    @brief      An Abstract Class. A <tt>PKTerminal</tt> is a parser that is not a composition of other parsers.
*/
@interface PKTerminal : PKParser {
    NSString *string;
    BOOL discardFlag;
}

/*!
    @brief      Designated Initializer for all concrete <tt>PKTerminal</tt> subclasses.
    @details    Note this is an abtract class and this method must be called on a concrete subclass.
    @param      s the string matched by this parser
    @result     an initialized <tt>PKTerminal</tt> subclass object
*/
- (id)initWithString:(NSString *)s;

/*!
    @brief      By default, terminals push themselves upon a assembly's stack, after a successful match. This method will turn off that behavior.
    @details    This method returns this parser as a convenience for chainging-style usage.
    @result     this parser, returned for chaining/convenience
*/
- (PKTerminal *)discard;

/*!
    @property   string
    @brief      the string matched by this parser.
*/
@property (nonatomic, readonly, copy) NSString *string;
@end
