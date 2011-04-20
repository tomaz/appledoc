//
//  PKSlashStarState.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/20/06.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ParseKit/PKTokenizerState.h>

/*!
    @class      TDSlashStarState 
    @brief      A slash star state ignores everything up to a closing star and slash, and then returns the tokenizer's next token.
*/
@interface TDSlashStarState : PKTokenizerState {
    
}

@end
