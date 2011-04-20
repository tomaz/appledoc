//
//  PKWord.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 7/13/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ParseKit/PKTerminal.h>

/*!
    @class      PKWord 
    @brief      A <tt>PKWord</tt> matches a word from a token assembly.
*/
@interface PKWord : PKTerminal {

}

/*!
    @brief      Convenience factory method for initializing an autoreleased <tt>PKWord</tt> object.
    @result     an initialized autoreleased <tt>PKWord</tt> object
*/
+ (id)word;
@end
