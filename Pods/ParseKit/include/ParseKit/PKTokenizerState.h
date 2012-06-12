//  Copyright 2010 Todd Ditchendorf
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import <Foundation/Foundation.h>
#import <ParseKit/PKTypes.h>

@class PKToken;
@class PKTokenizer;
@class PKReader;

/*!
    @class      PKTokenizerState 
    @brief      A <tt>PKTokenizerState</tt> returns a token, given a reader, an initial character read from the reader, and a tokenizer that is conducting an overall tokenization of the reader.
    @details    The tokenizer will typically have a character state table that decides which state to use, depending on an initial character. If a single character is insufficient, a state such as <tt>PKCommentState</tt> will read a second character, and may delegate to another state, such as <tt>PKSingleLineCommentState</tt>. This prospect of delegation is the reason that the <tt>-nextToken</tt> method has a tokenizer argument.
*/
@interface PKTokenizerState : NSObject {
    NSMutableString *stringbuf;
    NSUInteger offset;
    PKTokenizerState *fallbackState;
    NSMutableArray *fallbackStates;
}

/*!
    @brief      Return a token that represents a logical piece of a reader.
    @param      r the reader from which to read additional characters
    @param      cin the character that a tokenizer used to determine to use this state
    @param      t the tokenizer currently powering the tokenization
    @result     a token that represents a logical piece of the reader
*/
- (PKToken *)nextTokenFromReader:(PKReader *)r startingWith:(PKUniChar)cin tokenizer:(PKTokenizer *)t;

/*!
    @brief      Change the state this state will defer to upon reading any character between "start" and "end".
    @param      state the fallback state for this character range
    @param      start the "start" character. e.g. <tt>'a'</tt> or <tt>65</tt>.
    @param      end the "end" character. <tt>'z'</tt> or <tt>90</tt>.
*/
- (void)setFallbackState:(PKTokenizerState *)state from:(PKUniChar)start to:(PKUniChar)end;

/*!
    @property   fallbackState
    @brief      The state this tokenizer defers to if it starts, but ultimately aborts recognizing a token
*/
@property (nonatomic, retain) PKTokenizerState *fallbackState;
@end
