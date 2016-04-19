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

/*!
    @typedef    enum PKTokenType
    @brief      Indicates the type of a <tt>PKToken</tt>
    @var        PKTokenTypeEOF A constant indicating that the endo fo the stream has been read.
    @var        PKTokenTypeNumber A constant indicating that a token is a number, like <tt>3.14</tt>.
    @var        PKTokenTypeQuotedString A constant indicating that a token is a quoted string, like <tt>"Launch Mi"</tt>.
    @var        PKTokenTypeSymbol A constant indicating that a token is a symbol, like <tt>"&lt;="</tt>.
    @var        PKTokenTypeWord A constant indicating that a token is a word, like <tt>cat</tt>.
    @var        PKTokenTypeWhitespace A constant indicating that a token is whitespace, like <tt>\t</tt>.
    @var        PKTokenTypeComment A constant indicating that a token is a comment, like <tt>// this is a hack</tt>.
    @var        PKTokenTypeDelimtedString A constant indicating that a token is a delimitedString, like <tt><#foo></tt>.
*/
typedef enum {
    PKTokenTypeEOF,
    PKTokenTypeNumber,
    PKTokenTypeQuotedString,
    PKTokenTypeSymbol,
    PKTokenTypeWord,
    PKTokenTypeWhitespace,
    PKTokenTypeComment,
    PKTokenTypeDelimitedString,
    PKTokenTypeAny,
    PKTokenTypeURL,
    PKTokenTypeEmail,
    PKTokenTypeTwitter
} PKTokenType;

/*!
    @class      PKToken
    @brief      A token represents a logical chunk of a string.
    @details    For example, a typical tokenizer would break the string <tt>"1.23 &lt;= 12.3"</tt> into three tokens: the number <tt>1.23</tt>, a less-than-or-equal symbol, and the number <tt>12.3</tt>. A token is a receptacle, and relies on a tokenizer to decide precisely how to divide a string into tokens.
*/
@interface PKToken : NSObject <NSCopying> {
    CGFloat floatValue;
    NSString *stringValue;
    PKTokenType tokenType;
    
    BOOL number;
    BOOL quotedString;
    BOOL symbol;
    BOOL word;
    BOOL whitespace;
    BOOL comment;
    BOOL delimitedString;
    BOOL URL;
    BOOL email;
    BOOL twitter;
    
    id value;
    NSUInteger offset;
}

/*!
    @brief      Factory method for creating a singleton <tt>PKToken</tt> used to indicate that there are no more tokens.
    @result     A singleton used to indicate that there are no more tokens.
*/
+ (PKToken *)EOFToken;

/*!
    @brief      Factory convenience method for creating an autoreleased token.
    @param      t the type of this token.
    @param      s the string value of this token.
    @param      n the number falue of this token.
    @result     an autoreleased initialized token.
*/
+ (PKToken *)tokenWithTokenType:(PKTokenType)t stringValue:(NSString *)s floatValue:(CGFloat)n;

/*!
    @brief      Designated initializer. Constructs a token of the indicated type and associated string or numeric values.
    @param      t the type of this token.
    @param      s the string value of this token.
    @param      n the number falue of this token.
    @result     an autoreleased initialized token.
*/
- (id)initWithTokenType:(PKTokenType)t stringValue:(NSString *)s floatValue:(CGFloat)n;

/*!
    @brief      Returns true if the supplied object is an equivalent <tt>PKToken</tt>, ignoring differences in case.
    @param      obj the object to compare this token to.
    @result     true if <tt>obj</tt> is an equivalent <tt>PKToken</tt>, ignoring differences in case.
*/
- (BOOL)isEqualIgnoringCase:(id)obj;

/*!
    @brief      Returns more descriptive textual representation than <tt>-description</tt> which may be useful for debugging puposes only.
    @details    Usually of format similar to: <tt>&lt;QuotedString "Launch Mi"></tt>, <tt>&lt;Word cat></tt>, or <tt>&lt;Number 3.14></tt>
    @result     A textual representation including more descriptive information than <tt>-description</tt>.
*/
- (NSString *)debugDescription;

/*!
    @property   number
    @brief      True if this token is a number. getter=isNumber
*/
@property (nonatomic, readonly, getter=isNumber) BOOL number;

/*!
    @property   quotedString
    @brief      True if this token is a quoted string. getter=isQuotedString
*/
@property (nonatomic, readonly, getter=isQuotedString) BOOL quotedString;

/*!
    @property   symbol
    @brief      True if this token is a symbol. getter=isSymbol
*/
@property (nonatomic, readonly, getter=isSymbol) BOOL symbol;

/*!
    @property   word
    @brief      True if this token is a word. getter=isWord
*/
@property (nonatomic, readonly, getter=isWord) BOOL word;

/*!
    @property   whitespace
    @brief      True if this token is whitespace. getter=isWhitespace
*/
@property (nonatomic, readonly, getter=isWhitespace) BOOL whitespace;

/*!
    @property   comment
    @brief      True if this token is a comment. getter=isComment
*/
@property (nonatomic, readonly, getter=isComment) BOOL comment;

/*!
    @property   delimitedString
    @brief      True if this token is a delimited string. getter=isDelimitedString
*/
@property (nonatomic, readonly, getter=isDelimitedString) BOOL delimitedString;

/*!
    @property   URL
    @brief      True if this token is a URL. getter=isURL
*/
@property (nonatomic, readonly, getter=isURL) BOOL URL;

/*!
    @property   email
    @brief      True if this token is an email address. getter=isEmail
*/
@property (nonatomic, readonly, getter=isEmail) BOOL email;

/*!
    @property   twitter
    @brief      True if this token is an twitter handle. getter=isTwitter
*/
@property (nonatomic, readonly, getter=isTwitter) BOOL twitter;

/*!
    @property   tokenType
    @brief      The type of this token.
*/
@property (nonatomic, readonly) PKTokenType tokenType;

/*!
    @property   floatValue
    @brief      The numeric value of this token.
*/
@property (nonatomic, readonly) CGFloat floatValue;

/*!
    @property   stringValue
    @brief      The string value of this token.
*/
@property (nonatomic, readonly, copy) NSString *stringValue;

/*!
    @property   value
    @brief      Returns an object that represents the value of this token.
*/
@property (nonatomic, readonly, copy) id value;

/*!
    @property   offset
    @brief      The character offset of this token in the original source string.
*/
@property (nonatomic, readonly) NSUInteger offset;
@end
