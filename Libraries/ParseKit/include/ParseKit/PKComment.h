//
//  PKComment.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 12/31/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ParseKit/PKTerminal.h>

/*!
    @class      PKComment
    @brief      A <tt>PKComment</tt> matches a comment from a token assembly.
*/
@interface PKComment : PKTerminal {

}

/*!
    @brief      Convenience factory method for initializing an autoreleased <tt>PKComment</tt> object.
    @result     an initialized autoreleased <tt>PKComment</tt> object
*/
+ (id)comment;
@end
