//
//  PKDigit.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/14/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <ParseKit/PKTerminal.h>

/*!
    @class      PKDigit 
    @brief      A <tt>PKDigit</tt> matches a digit from a character assembly.
    @details    <tt>-[PKDitgit qualifies:] returns true if an assembly's next element is a digit.
*/
@interface PKDigit : PKTerminal {

}

/*!
    @brief      Convenience factory method for initializing an autoreleased <tt>PKDigit</tt> parser.
    @result     an initialized autoreleased <tt>PKDigit</tt> parser.
*/
+ (id)digit;
@end
