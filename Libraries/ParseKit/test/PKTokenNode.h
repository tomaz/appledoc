//
//  PKTokenNode.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 7/11/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "PKParseTree.h"

@class PKToken;

@interface PKTokenNode : PKParseTree <NSCopying> {
    PKToken *token;
}

+ (id)tokenNodeWithToken:(PKToken *)tok;

// designated initializer
- (id)initWithToken:(PKToken *)tok;

@property (nonatomic, retain, readonly) PKToken *token;
@end
