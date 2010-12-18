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
    @class      PKQuoteState 
    @brief      A quote state returns a quoted string token from a reader
    @details    This state will collect characters until it sees a match to the character that the tokenizer used to switch to this state. For example, if a tokenizer uses a double- quote character to enter this state, then <tt>-nextToken</tt> will search for another double-quote until it finds one or finds the end of the reader.
*/
@interface PKQuoteState : PKTokenizerState {
    BOOL allowsEOFTerminatedQuotes;
    BOOL balancesEOFTerminatedQuotes;
    BOOL usesCSVStyleEscaping;
}

/*!
    @property   allowsEOFTerminatedQuotes
    @brief      if YES, this state will consider unbalanced quoted strings (quoted strings terminated by EOF) as a quoted string rather than a <tt>'</tt> or <tt>"</tt> symbol token followed by zero or more tokens. Default is YES.
*/
@property (nonatomic) BOOL allowsEOFTerminatedQuotes;

/*!
    @property   balancesEOFTerminatedQuotes
    @brief      if YES, this state will append a matching quote char (<tt>'</tt> or <tt>"</tt>) to strings terminated by EOF. Default is NO.
*/
@property (nonatomic) BOOL balancesEOFTerminatedQuotes;

/*!
    @property   usesCSVStyleEscaping
    @brief      if NO, this state will use slash-style escaping (<tt>\'</tt> or <tt>\"</tt>). If YES, it will use CSV-style escaping, by doubling the quote character (<tt>''</tt> or <tt>""</tt>). The default behaviour is NO (slash-style).
*/
@property (nonatomic) BOOL usesCSVStyleEscaping;
@end
