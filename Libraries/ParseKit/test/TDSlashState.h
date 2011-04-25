//
//  PKSlashState.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/20/06.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ParseKit/PKTokenizerState.h>

@class TDSlashSlashState;
@class TDSlashStarState;

/*!
    @class      TDSlashState 
    @brief      This state will either delegate to a comment-handling state, or return a <tt>PKSymbol</tt> token with just a slash in it.
*/
@interface TDSlashState : PKTokenizerState {
    TDSlashSlashState *slashSlashState;
    TDSlashStarState *slashStarState;
    BOOL reportsCommentTokens;
}


@property (nonatomic) BOOL reportsCommentTokens;
@end
