//
//  PKEmailState.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 3/31/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ParseKit/PKTokenizerState.h>

/*!
    @class      PKEmailState 
    @brief      An email state returns an email address from a reader.
    @details    
*/
@interface PKEmailState : PKTokenizerState {
    PKUniChar c;
    PKUniChar lastChar;
}

@end
