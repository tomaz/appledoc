//
//  PKQuotedString.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 7/13/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ParseKit/PKTerminal.h>

/*!
    @class      PKQuotedString 
    @brief      A <tt>PKQuotedString</tt> matches a quoted string, like "this one" from a token assembly.
*/
@interface PKQuotedString : PKTerminal {

}

/*!
    @brief      Convenience factory method for initializing an autoreleased <tt>PKQuotedString</tt> object.
    @result     an initialized autoreleased <tt>PKQuotedString</tt> object
*/
+ (id)quotedString;
@end
