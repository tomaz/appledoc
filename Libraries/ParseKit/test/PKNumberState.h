//
//  PKNumberState.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/20/06.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ParseKit/PKTokenizerState.h>

/*!
    @class      PKNumberState 
    @brief      A number state returns a number from a reader.
    @details    This state's idea of a number allows an optional, initial minus sign, followed by one or more digits. A decimal point and another string of digits may follow these digits.
                If <tt>allowsScientificNotation</tt> is true (the default) this state allows 'e' or 'E' followed by an (optionally explicityly positive or negative) integer to represent 10 to the indicated power. For example, this state will recognize <tt>1e2</tt> as equaling <tt>100</tt>.</p>
*/
@interface PKNumberState : PKTokenizerState {
    BOOL allowsTrailingDot;
    BOOL gotADigit;
    BOOL negative;
    PKUniChar c;
    CGFloat floatValue;
}

/*!
    @property   allowsTrailingDot
    @brief      If true, numbers are allowed to end with a trialing dot, e.g. <tt>42.<tt>
    @details    false by default.
*/
@property (nonatomic) BOOL allowsTrailingDot;
@end
