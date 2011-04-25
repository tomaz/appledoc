//
//  PKEmpty.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 7/13/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ParseKit/PKParser.h>

/*!
    @class      PKEmpty 
    @brief      A <tt>PKEmpty</tt> parser matches any assembly once, and applies its assembler that one time.
    @details    <p>Language elements often contain empty parts. For example, a language may at some point allow a list of parameters in parentheses, and may allow an empty list. An empty parser makes it easy to match, within the parenthesis, either a list of parameters or "empty".</p>
*/
@interface PKEmpty : PKParser {

}

/*!
    @brief      Convenience factory method for initializing an autoreleased <tt>PKEmpty</tt> parser.
    @result     an initialized autoreleased <tt>PKEmpty</tt> parser.
*/
+ (id)empty;
@end
