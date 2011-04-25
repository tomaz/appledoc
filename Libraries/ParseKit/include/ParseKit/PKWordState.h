//
//  PKWordState.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/20/06.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ParseKit/PKTokenizerState.h>

/*!
    @class      PKWordState 
    @brief      A word state returns a word from a reader.
    @details    <p>Like other states, a tokenizer transfers the job of reading to this state, depending on an initial character. Thus, the tokenizer decides which characters may begin a word, and this state determines which characters may appear as a second or later character in a word. These are typically different sets of characters; in particular, it is typical for digits to appear as parts of a word, but not as the initial character of a word.</p>
                <p>By default, the following characters may appear in a word. The method setWordChars() allows customizing this.</p>
@code
     From     To
      'a'    'z'
      'A'    'Z'
      '0'    '9'
@endcode
                <p>as well as: minus sign <tt>-</tt>, underscore <tt>_</tt>, and apostrophe <tt>'</tt>.</p>
*/
@interface PKWordState : PKTokenizerState {
    NSMutableArray *wordChars;
}

/*!
    @brief      Establish characters in the given range as valid characters for part of a word after the first character. Note that the tokenizer must determine which characters are valid as the beginning character of a word.
    @param      yn true if characters in the given range are word characters
    @param      start the "start" character. e.g. <tt>'a'</tt> or <tt>65</tt>.
    @param      end the "end" character. <tt>'z'</tt> or <tt>90</tt>.
*/
- (void)setWordChars:(BOOL)yn from:(PKUniChar)start to:(PKUniChar)end;

/*!
    @brief      Informs whether the given character is recognized as a word character by this state.
    @param      cin the character to check
    @result     true if the given chracter is recognized as a word character
*/
- (BOOL)isWordChar:(PKUniChar)c;
@end
