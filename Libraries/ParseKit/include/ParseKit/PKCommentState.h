//
//  PKCommentState.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 12/28/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ParseKit/PKTokenizerState.h>

@class PKSymbolRootNode;
@class PKSingleLineCommentState;
@class PKMultiLineCommentState;

/*!
    @class      PKCommentState
    @brief      This state will either delegate to a comment-handling state, or return a <tt>PKSymbol</tt> token with just the first char in it.
    @details    By default, C and C++ style comments. (<tt>//</tt> to end of line and <tt>/&0x002A; &0x002A;/</tt>)
*/
@interface PKCommentState : PKTokenizerState {
    PKSymbolRootNode *rootNode;
    PKSingleLineCommentState *singleLineState;
    PKMultiLineCommentState *multiLineState;
    BOOL reportsCommentTokens;
    BOOL balancesEOFTerminatedComments;
}

/*!
    @brief      Adds the given string as a single-line comment start marker. may be multi-char.
    @details    single line comments begin with <tt>start</tt> and continue until the next new line character. e.g. C-style comments (<tt>// comment text</tt>)
    @param      start a single- or multi-character marker that should be recognized as the start of a single-line comment
*/
- (void)addSingleLineStartMarker:(NSString *)start;

/*!
    @brief      Removes the given string as a single-line comment start marker. may be multi-char.
    @details    If <tt>start</tt> was never added as a single-line comment start marker, this has no effect.
    @param      start a single- or multi-character marker that should no longer be recognized as the start of a single-line comment
*/
- (void)removeSingleLineStartMarker:(NSString *)start;

/*!
    @brief      Adds the given strings as a multi-line comment start and end markers. both may be multi-char
    @details    <tt>start</tt> and <tt>end</tt> may be different strings. e.g. <tt>/&0x002A;</tt> and <tt>&0x002A;/</tt>. Also, the actual comment may or may not be multi-line.
    @param      start a single- or multi-character marker that should be recognized as the start of a multi-line comment
    @param      end a single- or multi-character marker that should be recognized as the end of a multi-line comment that began with <tt>start</tt>
*/
- (void)addMultiLineStartMarker:(NSString *)start endMarker:(NSString *)end;

/*!
    @brief      Removes <tt>start</tt> and its orignal <tt>end</tt> counterpart as a multi-line comment start and end markers.
    @details    If <tt>start</tt> was never added as a multi-line comment start marker, this has no effect.
    @param      start a single- or multi-character marker that should no longer be recognized as the start of a multi-line comment
*/
- (void)removeMultiLineStartMarker:(NSString *)start;

/*!
    @property   reportsCommentTokens
    @brief      if true, the tokenizer associated with this state will report comment tokens, otherwise it silently consumes comments
    @details    if true, this state will return <tt>PKToken</tt>s of type <tt>PKTokenTypeComment</tt>.
                Otherwise, it will silently consume comment text and return the next token from another of the tokenizer's states
*/
@property (nonatomic) BOOL reportsCommentTokens;

/*!
    @property   balancesEOFTerminatedComments
    @brief      if true, this state will append a matching comment string (<tt>&0x002A;/</tt> [C++] or <tt>:)</tt> [XQuery]) to quotes terminated by EOF. Default is NO.
*/
@property (nonatomic) BOOL balancesEOFTerminatedComments;
@end
