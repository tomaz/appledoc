//
//  PKDifference.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 6/26/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ParseKit/PKParser.h>

/*!
    @class      PKDifference
    @brief      A <tt>PKDifference</tt> matches anything its <tt>subparser</tt> would match except for anything its <tt>minus</tt> parser would match.
    @details    The example below would match any <tt>Word</tt> token except for <tt>true</tt> or <tt>false</tt>.

@code
    PKParser *trueParser = [PKLiteral literalWithString:@"true"];
    PKParser *falseParser = [PKLiteral literalWithString:@"false"];
    PKAlternation *reservedWords = [PKAlternation alternationWithSubparsers:trueParser, falseParser, nil];

    PKDifference *diff = [PKDifference differenceWithSubparser:[PKWord word] minus:reservedWords];
@endcode
*/
@interface PKDifference : PKParser {
    PKParser *subparser;
    PKParser *minus;
}

/*!
    @brief      Convenience factory method for initializing an autoreleased <tt>PKDifference</tt> parser.
    @param      subparser the parser this parser uses for matching
    @param      minus the parser whose matches will be exluded
    @result     an initialized autoreleased <tt>PKDifference</tt> parser.
*/
+ (id)differenceWithSubparser:(PKParser *)s minus:(PKParser *)m;

/*!
    @brief      Designated initializer
    @param      subparser the parser this parser uses for matching
    @param      minus the parser whose matches will be exluded
    @result     an initialized <tt>PKDifference</tt> parser.
*/
- (id)initWithSubparser:(PKParser *)s minus:(PKParser *)m;

/*!
    @property   subparser
    @brief      this parser's subparser which it will initially match against
*/
@property (nonatomic, retain, readonly) PKParser *subparser;

/*!
    @property   minus
    @brief      after a successful match against <tt>subparser</tt>, matches against <tt>minus</tt> will not be matched by this parser
*/
@property (nonatomic, retain, readonly) PKParser *minus;
@end
