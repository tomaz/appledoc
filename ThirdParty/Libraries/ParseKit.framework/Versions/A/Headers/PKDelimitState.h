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

#import <ParseKit/PKTokenizerState.h>

@class PKSymbolRootNode;

/*!
    @class      PKDelimitState 
    @brief      A delimit state returns a delimited string token from a reader
    @details    This state will collect characters until it sees a match to the end marker that corresponds to the start marker the tokenizer used to switch to this state.
*/
@interface PKDelimitState : PKTokenizerState {
    PKSymbolRootNode *rootNode;
    BOOL balancesEOFTerminatedStrings;
    BOOL allowsUnbalancedStrings;

    NSMutableArray *startMarkers;
    NSMutableArray *endMarkers;
    NSMutableArray *characterSets;
}

/*!
    @brief      Adds the given strings as a delimited string start and end markers. both may be multi-char
    @details    <tt>start</tt> and <tt>end</tt> may be different strings. e.g. <tt>&lt;#</tt> and <tt>#&gt;</tt>.
    @param      start a single- or multi-character marker that should be recognized as the start of a multi-line comment
    @param      end a single- or multi-character marker that should be recognized as the end of a multi-line comment that began with <tt>start</tt>
    @param      set of characters allowed to appear within the delimited string or <tt>nil</tt> to allow any non-newline characters
*/
- (void)addStartMarker:(NSString *)start endMarker:(NSString *)end allowedCharacterSet:(NSCharacterSet *)set;

/*!
    @brief      Removes <tt>start</tt> and its orignal <tt>end</tt> counterpart as a delimited string start and end markers.
    @details    If <tt>start</tt> was never added as a delimited string start marker, this has no effect.
    @param      start a single- or multi-character marker that should no longer be recognized as the start of a delimited string
*/
- (void)removeStartMarker:(NSString *)start;

/*!
    @property   balancesEOFTerminatedStrings
    @brief      if YES, this state will append a matching end delimiter marker (e.g. <tt>--></tt> or <tt>%></tt>) to strings terminated by EOF. 
    @details	Default is NO.
*/
@property (nonatomic) BOOL balancesEOFTerminatedStrings;

@property (nonatomic) BOOL allowsUnbalancedStrings;
@end
