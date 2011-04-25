//
//  PKSymbolRootNode.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/20/06.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ParseKit/PKSymbolNode.h>

@class PKReader;

/*!
    @class      PKSymbolRootNode 
    @brief      This class is a special case of a <tt>PKSymbolNode</tt>.
    @details    This class is a special case of a <tt>PKSymbolNode</tt>. A <tt>PKSymbolRootNode</tt> object has no symbol of its own, but has children that represent all possible symbols.
*/
@interface PKSymbolRootNode : PKSymbolNode {
}

/*!
    @brief      Adds the given string as a multi-character symbol.
    @param      s a multi-character symbol that should be recognized as a single symbol token by this state
*/
- (void)add:(NSString *)s;

/*!
    @brief      Removes the given string as a multi-character symbol.
    @param      s a multi-character symbol that should no longer be recognized as a single symbol token by this state
    @details    if <tt>s</tt> was never added as a multi-character symbol, this has no effect
*/
- (void)remove:(NSString *)s;

/*!
    @brief      Return a symbol string from a reader.
    @param      r the reader from which to read
    @param      cin the character from witch to start
    @result     a symbol string from a reader
*/
- (NSString *)nextSymbol:(PKReader *)r startingWith:(PKUniChar)cin;
@end
