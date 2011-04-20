//
//  PKSymbolState.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/20/06.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ParseKit/PKTokenizerState.h>

@class PKSymbolRootNode;

/*!
    @class      PKSymbolState 
    @brief      The idea of a symbol is a character that stands on its own, such as an ampersand or a parenthesis.
    @details    <p>The idea of a symbol is a character that stands on its own, such as an ampersand or a parenthesis. For example, when tokenizing the expression (isReady)& (isWilling) , a typical tokenizer would return 7 tokens, including one for each parenthesis and one for the ampersand. Thus a series of symbols such as )&( becomes three tokens, while a series of letters such as isReady becomes a single word token.</p>
                <p>Multi-character symbols are an exception to the rule that a symbol is a standalone character. For example, a tokenizer may want less-than-or-equals to tokenize as a single token. This class provides a method for establishing which multi-character symbols an object of this class should treat as single symbols. This allows, for example, "cat <= dog" to tokenize as three tokens, rather than splitting the less-than and equals symbols into separate tokens.</p>
                <p>By default, this state recognizes the following multi- character symbols: <tt>!=</tt>, <tt>:-</tt>, <tt><=</tt>, <tt>>=</tt></p>
*/
@interface PKSymbolState : PKTokenizerState {
    PKSymbolRootNode *rootNode;
    NSMutableArray *addedSymbols;
}

/*!
    @brief      Adds the given string as a multi-character symbol.
    @param      s a multi-character symbol that should be recognized as a single symbol token by this state
*/
- (void)add:(NSString *)s;

/*!
    @brief      Removes the given string as a multi-character symbol.
    @details    If <tt>s</tt> was never added as a multi-character symbol, this has no effect.
    @param      s a multi-character symbol that should no longer be recognized as a single symbol token by this state
*/
- (void)remove:(NSString *)s;
@end
