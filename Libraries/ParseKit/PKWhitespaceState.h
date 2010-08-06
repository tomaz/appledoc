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
#import <ParseKit/PKTokenizerState.h>

/*!
    @class      PKWhitespaceState
    @brief      A whitespace state ignores whitespace (such as blanks and tabs), and returns the tokenizer's next token.
    @details    By default, all characters from 0 to 32 are whitespace.
*/
@interface PKWhitespaceState : PKTokenizerState {
    NSMutableArray *whitespaceChars;
    BOOL reportsWhitespaceTokens;
}

/*!
    @brief      Informs whether the given character is recognized as whitespace (and therefore ignored) by this state.
    @param      cin the character to check
    @result     true if the given chracter is recognized as whitespace
*/
- (BOOL)isWhitespaceChar:(PKUniChar)cin;

/*!
    @brief      Establish the given character range as whitespace to ignore.
    @param      yn true if the given character range is whitespace
    @param      start the "start" character. e.g. <tt>'a'</tt> or <tt>65</tt>.
    @param      end the "end" character. <tt>'z'</tt> or <tt>90</tt>.
*/
- (void)setWhitespaceChars:(BOOL)yn from:(PKUniChar)start to:(PKUniChar)end;

/*!
    @property   reportsWhitespaceTokens
    @brief      determines whether a <tt>PKTokenizer</tt> associated with this state reports or silently consumes whitespace tokens. default is <tt>NO</tt> which causes silent consumption of whitespace chars
*/
@property (nonatomic) BOOL reportsWhitespaceTokens;
@end
