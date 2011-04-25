//
//  PKChar.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/14/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <ParseKit/PKTerminal.h>

/*!
    @class      PKChar 
    @brief      A <tt>PKChar</tt> matches a character from a character assembly.
    @details    <tt>-[PKChar qualifies:]</tt> returns true every time, since this class assumes it is working against a <tt>PKCharacterAssembly</tt>.
*/
@interface PKChar : PKTerminal {

}

/*!
    @brief      Convenience factory method for initializing an autoreleased <tt>PKChar</tt> parser.
    @result     an initialized autoreleased <tt>PKChar</tt> parser.
*/
+ (id)char;
@end
