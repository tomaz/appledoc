//
//  PKLiteral.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 7/13/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ParseKit/PKTerminal.h>

@class PKToken;

/*!
    @class      PKLiteral 
    @brief      A <tt>PKLiteral</tt> matches a specific word from an assembly.
*/
@interface PKLiteral : PKTerminal {
    PKToken *literal;
}

/*!
    @brief      Convenience factory method for initializing an autoreleased <tt>PKLiteral</tt> object with a given string.
    @param      s the word represented by this literal
    @result     an initialized autoreleased <tt>PKLiteral</tt> object representing <tt>s</tt>
*/
+ (id)literalWithString:(NSString *)s;
@end
