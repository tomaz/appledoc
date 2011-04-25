//
//  PKCollectionParser.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 7/13/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

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
