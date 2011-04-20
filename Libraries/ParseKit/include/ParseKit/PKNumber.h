//
//  PKNumber.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 7/13/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ParseKit/PKTerminal.h>

/*!
    @class      PKNumber
    @brief      A <tt>PKNumber</tt> matches a number from a token assembly.
*/
@interface PKNumber : PKTerminal {

}

/*!
    @brief      Convenience factory method for initializing an autoreleased <tt>PKNumber</tt> object.
    @result     an initialized autoreleased <tt>PKNumber</tt> object
*/
+ (id)number;
@end
