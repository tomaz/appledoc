//
//  PKNegation.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 7/2/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <ParseKit/PKParser.h>

/*!
    @class      PKNegation
    @brief      A <tt>PKNegation</tt> negates the matching logic of its subparser. It matches anything its subparser would not.
    @details    The example below would match any token except for a <tt>?></tt> symbol token. This could be useful for matching all tokens until an end marker (in this case a PHP end marker) is found.

@code
    PKParser *question = [PKSymbol symbolWithString:@"?>"];
 
    PKNegation *n = [PKNegation negationWithSubparser:question];
@endcode 
*/
@interface PKNegation : PKParser {
    PKParser *subparser;
    PKParser *difference;
}

/*!
    @brief      Convenience factory method for initializing an autoreleased <tt>PKNegation</tt> parser.
    @param      subparser the parser whose matching logic is negated
    @result     an initialized autoreleased <tt>PKNegation</tt> parser.
*/
+ (id)negationWithSubparser:(PKParser *)s;

/*!
    @brief      Designated initializer
    @param      subparser the parser whose matching logic is negated
    @result     an initialized <tt>PKNegation</tt> parser.
*/
- (id)initWithSubparser:(PKParser *)s;

/*!
    @property   subparser
    @brief      this parser's subparser whose matching logic is negated
*/
@property (nonatomic, retain, readonly) PKParser *subparser;
@end
