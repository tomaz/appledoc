//
//  PKSpecificChar.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/14/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <ParseKit/PKTerminal.h>
#import <ParseKit/PKTypes.h>

/*!
    @class      PKSpecificChar 
    @brief      A <tt>PKSpecificChar</tt> matches a specified character from a character assembly.
    @details    <tt>-[PKSpecificChar qualifies:] returns true if an assembly's next element is equal to the character this object was constructed with.
*/
@interface PKSpecificChar : PKTerminal {
    
}

/*!
    @brief      Convenience factory method for initializing an autoreleased <tt>PKSpecificChar</tt> parser.
    @param      c the character this object should match
    @result     an initialized autoreleased <tt>PKSpecificChar</tt> parser.
*/
+ (id)specificCharWithChar:(PKUniChar)c;

/*!
    @brief      Designated Initializer. Initializes a <tt>PKSpecificChar</tt> parser.
    @param      c the character this object should match
    @result     an initialized <tt>PKSpecificChar</tt> parser.
*/
- (id)initWithSpecificChar:(PKUniChar)c;
@end
