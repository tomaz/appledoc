//
//  PKAny.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 12/14/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ParseKit/PKTerminal.h>

/*!
    @class      PKAny 
    @brief      A <tt>PKAny</tt> matches any token from a token assembly.
*/
@interface PKAny : PKTerminal {

}

/*!
    @brief      Convenience factory method for initializing an autoreleased <tt>PKAny</tt> object.
    @result     an initialized autoreleased <tt>PKAny</tt> object
*/
+ (id)any;
@end
