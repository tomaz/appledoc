//
//  PKWordOrReservedState.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/14/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ParseKit/PKWordState.h>

/*!
    @class      TDWordOrReservedState 
    @brief      Override <tt>PKWordState</tt> to return known reserved words as tokens of type <tt>TDTT_RESERVED</tt>.
*/
@interface TDWordOrReservedState : PKWordState {
    NSMutableSet *reservedWords;
}

/*!
    @brief      Adds the specified string as a known reserved word.
    @param      s reserved word to add
*/
- (void)addReservedWord:(NSString *)s;
@end
