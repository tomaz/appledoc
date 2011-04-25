//
//  PKParseTree.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 7/11/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PKRuleNode;
@class PKTokenNode;
@class PKToken;

@interface PKParseTree : NSObject <NSCopying> {
    PKParseTree *parent;
    NSMutableArray *children;
    id userInfo;
    BOOL matched;
}
+ (id)parseTree;

- (PKRuleNode *)addChildRule:(NSString *)name;
- (PKTokenNode *)addChildToken:(PKToken *)tok;
- (void)addChild:(PKParseTree *)tr;

@property (nonatomic, assign, readonly) PKParseTree *parent;  // weak ref
@property (nonatomic, retain, readonly) NSMutableArray *children;
@property (nonatomic, retain) id userInfo;
@property (nonatomic, getter=isMatched) BOOL matched;
@end
