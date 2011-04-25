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
                If <tt>allowsScientificNotation</tt> is YES (default is NO) this state allows 'e' or 'E' followed by an (optionally explicityly positive or negative) integer to represent 10 to the indicated power. For example, this state will recognize <tt>1e2</tt> as equaling <tt>100</tt>.</p>
*/
@interface PKNumberState : PKTokenizerState {
    BOOL allowsTrailingDot;
    BOOL allowsScientificNotation;
    BOOL allowsOctalNotation;
    BOOL allowsHexadecimalNotation;
    BOOL isDecimal;
    BOOL isFraction;
    BOOL isNegative;
    BOOL isHex;
    BOOL gotADigit;
    NSUInteger len;
    CGFloat base;
    PKUniChar originalCin;
    PKUniChar firstNum;
    PKUniChar c;
    CGFloat floatValue;
    CGFloat exp;
    BOOL isNegativeExp;    
}

/*!
    @property   allowsTrailingDot
    @brief      If YES, numbers are allowed to end with a trialing dot, e.g. <tt>42.<tt>
    @details    default is NO
*/
@property (nonatomic) BOOL allowsTrailingDot;

/*!
    @property   allowsScientificNotation
    @brief      If YES, supports exponential numbers like <tt>42.0e2<tt>, <tt>2E+6<tt>, or <tt>5.1e-6<tt>
    @details    default is NO
*/
@property (nonatomic) BOOL allowsScientificNotation;

/*!
    @property   allowsOctalNotation
    @brief      If YES, supports octal numbers like <tt>020<tt> (16), or <tt>0102<tt> (66)
    @details    default is NO
*/
@property (nonatomic) BOOL allowsOctalNotation;

/*!
    @property   allowsHexidecimalNotation
    @brief      If YES, supports hex numbers like <tt>0x20<tt> (32), or <tt>0xB7<tt> (183)
    @details    default is NO
*/
@property (nonatomic) BOOL allowsHexadecimalNotation;
@end
