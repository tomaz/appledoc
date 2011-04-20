//
//  PKSymbol.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 7/13/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ParseKit/PKTerminal.h>

@class PKToken;

/*!
    @class      PKSymbol 
    @brief      A <tt>PKSymbol</tt> matches a specific sequence, such as <tt>&lt;</tt>, or <tt>&lt;=</tt> that a tokenizer returns as a symbol.
*/
@interface PKSymbol : PKTerminal {
    PKToken *symbol;
}

/*!
    @brief      Convenience factory method for initializing an autoreleased <tt>PKSymbol</tt> object with a <tt>nil</tt> string value.
    @result     an initialized autoreleased <tt>PKSymbol</tt> object with a <tt>nil</tt> string value
*/
+ (id)symbol;

/*!
    @brief      Convenience factory method for initializing an autoreleased <tt>PKSymbol</tt> object with <tt>s</tt> as a string value.
    @param      s the string represented by this symbol
    @result     an initialized autoreleased <tt>PKSymbol</tt> object with <tt>s</tt> as a string value
*/
+ (id)symbolWithString:(NSString *)s;
@end
