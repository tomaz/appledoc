//
//  PKParseTreeAssembler.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 7/11/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PKParseTreeAssembler : NSObject {
    NSMutableDictionary *ruleNames;
    NSString *preassemblerPrefix;
    NSString *assemblerPrefix;
    NSString *suffix;
}

@end
