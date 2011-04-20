//
//  PKWhitespace.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 6/19/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ParseKit/PKTerminal.h>

/*!
    @class      PKWhitespace
    @brief      A <tt>PKWhitespace</tt> matches a number from a token assembly.
*/
@interface PKWhitespace : PKTerminal {

}

/*!
    @brief      Convenience factory method for initializing an autoreleased <tt>PKWhitespace</tt> object.
    @result     an initialized autoreleased <tt>PKWhitespace</tt> object
*/
+ (id)whitespace;
@end
