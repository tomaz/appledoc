//
//  PKSlashSlashState.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/20/06.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ParseKit/PKTokenizerState.h>

/*!
    @class      TDSlashSlashState 
    @brief      A slash slash state ignores everything up to an end-of-line and returns the tokenizer's next token.
*/
@interface TDSlashSlashState : PKTokenizerState {
    
}

@end
