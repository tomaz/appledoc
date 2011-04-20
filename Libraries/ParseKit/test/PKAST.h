//
//  PKAST.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 7/11/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PKToken;

@interface PKAST : NSObject {
    PKToken *token;
    NSMutableArray *children;
}

+ (id)ASTWithToken:(PKToken *)tok;

- (id)initWithToken:(PKToken *)tok;

- (NSInteger)type;

- (void)addChild:(PKAST *)c;
- (BOOL)isNil;

@end
