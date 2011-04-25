//
//  PKLetter.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/14/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <ParseKit/PKTerminal.h>

/*!
    @class      PKLetter 
    @brief      A <tt>PKLetter</tt> matches any letter from a character assembly.
    @details    <tt>-[PKLetter qualifies:]</tt> returns true if an assembly's next element is a letter.
*/
@interface PKLetter : PKTerminal {

}

/*!
    @brief      Convenience factory method for initializing an autoreleased <tt>PKLetter</tt> parser.
    @result     an initialized autoreleased <tt>PKLetter</tt> parser.
*/
+ (id)letter;
@end
