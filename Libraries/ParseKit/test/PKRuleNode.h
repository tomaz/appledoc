//
//  PKRuleNode.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 7/11/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "PKParseTree.h"

@interface PKRuleNode : PKParseTree <NSCopying> {
    NSString *name;
}

+ (id)ruleNodeWithName:(NSString *)s;

// designated initializer
- (id)initWithName:(NSString *)s;

@property (nonatomic, copy, readonly) NSString *name;
@end
